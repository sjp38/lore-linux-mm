Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A91B6B0006
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 14:22:03 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v11so10611028wri.13
        for <linux-mm@kvack.org>; Sun, 15 Apr 2018 11:22:03 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id r53si10873531edd.42.2018.04.15.11.22.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Apr 2018 11:22:01 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v4 2/3] mm/shmem: update file sealing comments and file checking
Date: Sun, 15 Apr 2018 11:21:18 -0700
Message-Id: <20180415182119.4517-3-mike.kravetz@oracle.com>
In-Reply-To: <20180415182119.4517-1-mike.kravetz@oracle.com>
References: <20180415182119.4517-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, =?UTF-8?q?Marc-Andr=C3=A9=20Lureau?= <marcandre.lureau@gmail.com>, David Herrmann <dh.herrmann@gmail.com>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

In preparation for memfd code restructure, update comments,
definitions and function names dealing with file sealing to
indicate that tmpfs and hugetlbfs are the supported filesystems.
Also, change file pointer checks in memfd_file_seals_ptr
to use defined interfaces instead of directly referencing
file_operation structs.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/shmem.c | 50 ++++++++++++++++++++++++++------------------------
 1 file changed, 26 insertions(+), 24 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index c7bad16fe884..a8bff40a10cd 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2621,12 +2621,13 @@ static loff_t shmem_file_llseek(struct file *file, loff_t offset, int whence)
 
 /*
  * We need a tag: a new tag would expand every radix_tree_node by 8 bytes,
- * so reuse a tag which we firmly believe is never set or cleared on shmem.
+ * so reuse a tag which we firmly believe is never set or cleared on tmpfs
+ * or hugetlbfs because they are memory only filesystems.
  */
-#define SHMEM_TAG_PINNED        PAGECACHE_TAG_TOWRITE
+#define MEMFD_TAG_PINNED        PAGECACHE_TAG_TOWRITE
 #define LAST_SCAN               4       /* about 150ms max */
 
-static void shmem_tag_pins(struct address_space *mapping)
+static void memfd_tag_pins(struct address_space *mapping)
 {
 	struct radix_tree_iter iter;
 	void __rcu **slot;
@@ -2647,7 +2648,7 @@ static void shmem_tag_pins(struct address_space *mapping)
 		} else if (page_count(page) - page_mapcount(page) > 1) {
 			spin_lock_irq(&mapping->tree_lock);
 			radix_tree_tag_set(&mapping->page_tree, iter.index,
-					   SHMEM_TAG_PINNED);
+					   MEMFD_TAG_PINNED);
 			spin_unlock_irq(&mapping->tree_lock);
 		}
 
@@ -2668,7 +2669,7 @@ static void shmem_tag_pins(struct address_space *mapping)
  * The caller must guarantee that no new user will acquire writable references
  * to those pages to avoid races.
  */
-static int shmem_wait_for_pins(struct address_space *mapping)
+static int memfd_wait_for_pins(struct address_space *mapping)
 {
 	struct radix_tree_iter iter;
 	void __rcu **slot;
@@ -2676,11 +2677,11 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 	struct page *page;
 	int error, scan;
 
-	shmem_tag_pins(mapping);
+	memfd_tag_pins(mapping);
 
 	error = 0;
 	for (scan = 0; scan <= LAST_SCAN; scan++) {
-		if (!radix_tree_tagged(&mapping->page_tree, SHMEM_TAG_PINNED))
+		if (!radix_tree_tagged(&mapping->page_tree, MEMFD_TAG_PINNED))
 			break;
 
 		if (!scan)
@@ -2691,7 +2692,7 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 		start = 0;
 		rcu_read_lock();
 		radix_tree_for_each_tagged(slot, &mapping->page_tree, &iter,
-					   start, SHMEM_TAG_PINNED) {
+					   start, MEMFD_TAG_PINNED) {
 
 			page = radix_tree_deref_slot(slot);
 			if (radix_tree_exception(page)) {
@@ -2718,7 +2719,7 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 
 			spin_lock_irq(&mapping->tree_lock);
 			radix_tree_tag_clear(&mapping->page_tree,
-					     iter.index, SHMEM_TAG_PINNED);
+					     iter.index, MEMFD_TAG_PINNED);
 			spin_unlock_irq(&mapping->tree_lock);
 continue_resched:
 			if (need_resched()) {
@@ -2734,11 +2735,11 @@ static int shmem_wait_for_pins(struct address_space *mapping)
 
 static unsigned int *memfd_file_seals_ptr(struct file *file)
 {
-	if (file->f_op == &shmem_file_operations)
+	if (shmem_file(file))
 		return &SHMEM_I(file_inode(file))->seals;
 
 #ifdef CONFIG_HUGETLBFS
-	if (file->f_op == &hugetlbfs_file_operations)
+	if (is_file_hugepages(file))
 		return &HUGETLBFS_I(file_inode(file))->seals;
 #endif
 
@@ -2758,16 +2759,17 @@ static int memfd_add_seals(struct file *file, unsigned int seals)
 
 	/*
 	 * SEALING
-	 * Sealing allows multiple parties to share a shmem-file but restrict
-	 * access to a specific subset of file operations. Seals can only be
-	 * added, but never removed. This way, mutually untrusted parties can
-	 * share common memory regions with a well-defined policy. A malicious
-	 * peer can thus never perform unwanted operations on a shared object.
+	 * Sealing allows multiple parties to share a tmpfs or hugetlbfs file
+	 * but restrict access to a specific subset of file operations. Seals
+	 * can only be added, but never removed. This way, mutually untrusted
+	 * parties can share common memory regions with a well-defined policy.
+	 * A malicious peer can thus never perform unwanted operations on a
+	 * shared object.
 	 *
-	 * Seals are only supported on special shmem-files and always affect
-	 * the whole underlying inode. Once a seal is set, it may prevent some
-	 * kinds of access to the file. Currently, the following seals are
-	 * defined:
+	 * Seals are only supported on special tmpfs or hugetlbfs files and
+	 * always affect the whole underlying inode. Once a seal is set, it
+	 * may prevent some kinds of access to the file. Currently, the
+	 * following seals are defined:
 	 *   SEAL_SEAL: Prevent further seals from being set on this file
 	 *   SEAL_SHRINK: Prevent the file from shrinking
 	 *   SEAL_GROW: Prevent the file from growing
@@ -2781,9 +2783,9 @@ static int memfd_add_seals(struct file *file, unsigned int seals)
 	 * added.
 	 *
 	 * Semantics of sealing are only defined on volatile files. Only
-	 * anonymous shmem files support sealing. More importantly, seals are
-	 * never written to disk. Therefore, there's no plan to support it on
-	 * other file types.
+	 * anonymous tmpfs and hugetlbfs files support sealing. More
+	 * importantly, seals are never written to disk. Therefore, there's
+	 * no plan to support it on other file types.
 	 */
 
 	if (!(file->f_mode & FMODE_WRITE))
@@ -2809,7 +2811,7 @@ static int memfd_add_seals(struct file *file, unsigned int seals)
 		if (error)
 			goto unlock;
 
-		error = shmem_wait_for_pins(file->f_mapping);
+		error = memfd_wait_for_pins(file->f_mapping);
 		if (error) {
 			mapping_allow_writable(file->f_mapping);
 			goto unlock;
-- 
2.13.6
