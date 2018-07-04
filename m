Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8255F6B026D
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 17:51:00 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id p91-v6so455780plb.12
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 14:51:00 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id l33-v6si4423827pld.514.2018.07.04.14.50.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 14:50:59 -0700 (PDT)
Subject: [PATCH v5 07/11] filesystem-dax: Introduce dax_lock_mapping_entry()
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 04 Jul 2018 14:41:00 -0700
Message-ID: <153074046078.27838.5465590228767136915.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153074042316.27838.17319837331947007626.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153074042316.27838.17319837331947007626.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: hch@lst.dehch@lst.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jack@suse.cz, ross.zwisler@linux.intel.com

In preparation for implementing support for memory poison (media error)
handling via dax mappings, implement a lock_page() equivalent. Poison
error handling requires rmap and needs guarantees that the page->mapping
association is maintained / valid (inode not freed) for the duration of
the lookup.

In the device-dax case it is sufficient to simply hold a dev_pagemap
reference. In the filesystem-dax case we need to use the entry lock.

Export the entry lock via dax_lock_mapping_entry() that uses
rcu_read_lock() to protect against the inode being freed, and
revalidates the page->mapping association under xa_lock().

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/dax.c            |  109 ++++++++++++++++++++++++++++++++++++++++++++++++---
 include/linux/dax.h |   24 +++++++++++
 2 files changed, 127 insertions(+), 6 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 4de11ed463ce..57ec272038da 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -226,8 +226,8 @@ static inline void *unlock_slot(struct address_space *mapping, void **slot)
  *
  * Must be called with the i_pages lock held.
  */
-static void *get_unlocked_mapping_entry(struct address_space *mapping,
-					pgoff_t index, void ***slotp)
+static void *__get_unlocked_mapping_entry(struct address_space *mapping,
+		pgoff_t index, void ***slotp, bool (*wait_fn)(void))
 {
 	void *entry, **slot;
 	struct wait_exceptional_entry_queue ewait;
@@ -237,6 +237,8 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 	ewait.wait.func = wake_exceptional_entry_func;
 
 	for (;;) {
+		bool revalidate;
+
 		entry = __radix_tree_lookup(&mapping->i_pages, index, NULL,
 					  &slot);
 		if (!entry ||
@@ -251,14 +253,31 @@ static void *get_unlocked_mapping_entry(struct address_space *mapping,
 		prepare_to_wait_exclusive(wq, &ewait.wait,
 					  TASK_UNINTERRUPTIBLE);
 		xa_unlock_irq(&mapping->i_pages);
-		schedule();
+		revalidate = wait_fn();
 		finish_wait(wq, &ewait.wait);
 		xa_lock_irq(&mapping->i_pages);
+		if (revalidate)
+			return ERR_PTR(-EAGAIN);
 	}
 }
 
-static void dax_unlock_mapping_entry(struct address_space *mapping,
-				     pgoff_t index)
+static bool entry_wait(void)
+{
+	schedule();
+	/*
+	 * Never return an ERR_PTR() from
+	 * __get_unlocked_mapping_entry(), just keep looping.
+	 */
+	return false;
+}
+
+static void *get_unlocked_mapping_entry(struct address_space *mapping,
+		pgoff_t index, void ***slotp)
+{
+	return __get_unlocked_mapping_entry(mapping, index, slotp, entry_wait);
+}
+
+static void unlock_mapping_entry(struct address_space *mapping, pgoff_t index)
 {
 	void *entry, **slot;
 
@@ -277,7 +296,7 @@ static void dax_unlock_mapping_entry(struct address_space *mapping,
 static void put_locked_mapping_entry(struct address_space *mapping,
 		pgoff_t index)
 {
-	dax_unlock_mapping_entry(mapping, index);
+	unlock_mapping_entry(mapping, index);
 }
 
 /*
@@ -374,6 +393,84 @@ static struct page *dax_busy_page(void *entry)
 	return NULL;
 }
 
+static bool entry_wait_revalidate(void)
+{
+	rcu_read_unlock();
+	schedule();
+	rcu_read_lock();
+
+	/*
+	 * Tell __get_unlocked_mapping_entry() to take a break, we need
+	 * to revalidate page->mapping after dropping locks
+	 */
+	return true;
+}
+
+bool dax_lock_mapping_entry(struct page *page)
+{
+	pgoff_t index;
+	struct inode *inode;
+	bool did_lock = false;
+	void *entry = NULL, **slot;
+	struct address_space *mapping;
+
+	rcu_read_lock();
+	for (;;) {
+		mapping = READ_ONCE(page->mapping);
+
+		if (!dax_mapping(mapping))
+			break;
+
+		/*
+		 * In the device-dax case there's no need to lock, a
+		 * struct dev_pagemap pin is sufficient to keep the
+		 * inode alive, and we assume we have dev_pagemap pin
+		 * otherwise we would not have a valid pfn_to_page()
+		 * translation.
+		 */
+		inode = mapping->host;
+		if (S_ISCHR(inode->i_mode)) {
+			did_lock = true;
+			break;
+		}
+
+		xa_lock_irq(&mapping->i_pages);
+		if (mapping != page->mapping) {
+			xa_unlock_irq(&mapping->i_pages);
+			continue;
+		}
+		index = page->index;
+
+		entry = __get_unlocked_mapping_entry(mapping, index, &slot,
+				entry_wait_revalidate);
+		if (!entry) {
+			xa_unlock_irq(&mapping->i_pages);
+			break;
+		} else if (IS_ERR(entry)) {
+			WARN_ON_ONCE(PTR_ERR(entry) != -EAGAIN);
+			continue;
+		}
+		lock_slot(mapping, slot);
+		did_lock = true;
+		xa_unlock_irq(&mapping->i_pages);
+		break;
+	}
+	rcu_read_unlock();
+
+	return did_lock;
+}
+
+void dax_unlock_mapping_entry(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	struct inode *inode = mapping->host;
+
+	if (S_ISCHR(inode->i_mode))
+		return;
+
+	unlock_mapping_entry(mapping, page->index);
+}
+
 /*
  * Find radix tree entry at given index. If it points to an exceptional entry,
  * return it with the radix tree entry locked. If the radix tree doesn't
diff --git a/include/linux/dax.h b/include/linux/dax.h
index deb0f663252f..82b9856faf7f 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -88,6 +88,8 @@ int dax_writeback_mapping_range(struct address_space *mapping,
 		struct block_device *bdev, struct writeback_control *wbc);
 
 struct page *dax_layout_busy_page(struct address_space *mapping);
+bool dax_lock_mapping_entry(struct page *page);
+void dax_unlock_mapping_entry(struct page *page);
 #else
 static inline bool bdev_dax_supported(struct block_device *bdev,
 		int blocksize)
@@ -119,6 +121,28 @@ static inline int dax_writeback_mapping_range(struct address_space *mapping,
 {
 	return -EOPNOTSUPP;
 }
+
+
+static inline bool dax_lock_mapping_entry(struct page *page)
+{
+	struct page *page = pfn_to_page(pfn);
+
+	if (IS_DAX(page->mapping->host))
+		return true;
+	return false;
+}
+
+void dax_unlock_mapping_entry(struct page *page)
+{
+}
+
+static inline struct page *dax_lock_page(unsigned long pfn)
+{
+}
+
+static inline void dax_unlock_page(struct page *page)
+{
+}
 #endif
 
 int dax_read_lock(void);
