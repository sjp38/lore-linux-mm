Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E6EFF6B000C
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 19:43:32 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s8so9577664pgf.0
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 16:43:32 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id f85si5109969pfj.125.2018.04.24.16.43.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 16:43:31 -0700 (PDT)
Subject: [PATCH v9 6/9] mm, fs,
 dax: handle layout changes to pinned dax mappings
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 24 Apr 2018 16:33:35 -0700
Message-ID: <152461281488.17530.18202569789906788866.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152461278149.17530.2867511144531572045.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152461278149.17530.2867511144531572045.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Jan Kara <jack@suse.cz>, Jeff Moyer <jmoyer@redhat.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <mawilcox@microsoft.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <darrick.wong@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.orgjack@suse.czhch@lst.de

Background:

get_user_pages() in the filesystem pins file backed memory pages for
access by devices performing dma. However, it only pins the memory pages
not the page-to-file offset association. If a file is truncated the
pages are mapped out of the file and dma may continue indefinitely into
a page that is owned by a device driver. This breaks coherency of the
file vs dma, but the assumption is that if userspace wants the
file-space truncated it does not matter what data is inbound from the
device, it is not relevant anymore. The only expectation is that dma can
safely continue while the filesystem reallocates the block(s).

Problem:

This expectation that dma can safely continue while the filesystem
changes the block map is broken by dax. With dax the target dma page
*is* the filesystem block. The model of leaving the page pinned for dma,
but truncating the file block out of the file, means that the filesytem
is free to reallocate a block under active dma to another file and now
the expected data-incoherency situation has turned into active
data-corruption.

Solution:

Defer all filesystem operations (fallocate(), truncate()) on a dax mode
file while any page/block in the file is under active dma. This solution
assumes that dma is transient. Cases where dma operations are known to
not be transient, like RDMA, have been explicitly disabled via
commits like 5f1d43de5416 "IB/core: disable memory registration of
filesystem-dax vmas".

The dax_layout_busy_page() routine is called by filesystems with a lock
held against mm faults (i_mmap_lock) to find pinned / busy dax pages.
The process of looking up a busy page invalidates all mappings
to trigger any subsequent get_user_pages() to block on i_mmap_lock.
The filesystem continues to call dax_layout_busy_page() until it finally
returns no more active pages. This approach assumes that the page
pinning is transient, if that assumption is violated the system would
have likely hung from the uncompleted I/O.

Cc: Jan Kara <jack@suse.cz>
Cc: Jeff Moyer <jmoyer@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <mawilcox@microsoft.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Reported-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/super.c |    2 +
 fs/Kconfig          |    1 +
 fs/dax.c            |   97 +++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/dax.h |    7 ++++
 mm/gup.c            |    1 +
 5 files changed, 107 insertions(+), 1 deletion(-)

diff --git a/drivers/dax/super.c b/drivers/dax/super.c
index 86b3806ea35b..89f21bd9da10 100644
--- a/drivers/dax/super.c
+++ b/drivers/dax/super.c
@@ -167,7 +167,7 @@ struct dax_device {
 #if IS_ENABLED(CONFIG_FS_DAX) && IS_ENABLED(CONFIG_DEV_PAGEMAP_OPS)
 static void generic_dax_pagefree(struct page *page, void *data)
 {
-	/* TODO: wakeup page-idle waiters */
+	wake_up_var(&page->_refcount);
 }
 
 static struct dax_device *__fs_dax_claim(struct dax_device *dax_dev,
diff --git a/fs/Kconfig b/fs/Kconfig
index 1e050e012eb9..c9acbf695ddd 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -40,6 +40,7 @@ config FS_DAX
 	depends on !(ARM || MIPS || SPARC)
 	select DEV_PAGEMAP_OPS if (ZONE_DEVICE && !FS_DAX_LIMITED)
 	select FS_IOMAP
+	select SRCU
 	select DAX
 	help
 	  Direct Access (DAX) can be used on memory-backed block devices.
diff --git a/fs/dax.c b/fs/dax.c
index aaec72ded1b6..e8f61ea690f7 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -351,6 +351,19 @@ static void dax_disassociate_entry(void *entry, struct address_space *mapping,
 	}
 }
 
+static struct page *dax_busy_page(void *entry)
+{
+	unsigned long pfn;
+
+	for_each_mapped_pfn(entry, pfn) {
+		struct page *page = pfn_to_page(pfn);
+
+		if (page_ref_count(page) > 1)
+			return page;
+	}
+	return NULL;
+}
+
 /*
  * Find radix tree entry at given index. If it points to an exceptional entry,
  * return it with the radix tree entry locked. If the radix tree doesn't
@@ -492,6 +505,90 @@ static void *grab_mapping_entry(struct address_space *mapping, pgoff_t index,
 	return entry;
 }
 
+/**
+ * dax_layout_busy_page - find first pinned page in @mapping
+ * @mapping: address space to scan for a page with ref count > 1
+ *
+ * DAX requires ZONE_DEVICE mapped pages. These pages are never
+ * 'onlined' to the page allocator so they are considered idle when
+ * page->count == 1. A filesystem uses this interface to determine if
+ * any page in the mapping is busy, i.e. for DMA, or other
+ * get_user_pages() usages.
+ *
+ * It is expected that the filesystem is holding locks to block the
+ * establishment of new mappings in this address_space. I.e. it expects
+ * to be able to run unmap_mapping_range() and subsequently not race
+ * mapping_mapped() becoming true.
+ */
+struct page *dax_layout_busy_page(struct address_space *mapping)
+{
+	pgoff_t	indices[PAGEVEC_SIZE];
+	struct page *page = NULL;
+	struct pagevec pvec;
+	pgoff_t	index, end;
+	unsigned i;
+
+	/*
+	 * In the 'limited' case get_user_pages() for dax is disabled.
+	 */
+	if (IS_ENABLED(CONFIG_FS_DAX_LIMITED))
+		return NULL;
+
+	if (!dax_mapping(mapping) || !mapping_mapped(mapping))
+		return NULL;
+
+	pagevec_init(&pvec);
+	index = 0;
+	end = -1;
+
+	/*
+	 * If we race get_user_pages_fast() here either we'll see the
+	 * elevated page count in the pagevec_lookup and wait, or
+	 * get_user_pages_fast() will see that the page it took a reference
+	 * against is no longer mapped in the page tables and bail to the
+	 * get_user_pages() slow path.  The slow path is protected by
+	 * pte_lock() and pmd_lock(). New references are not taken without
+	 * holding those locks, and unmap_mapping_range() will not zero the
+	 * pte or pmd without holding the respective lock, so we are
+	 * guaranteed to either see new references or prevent new
+	 * references from being established.
+	 */
+	unmap_mapping_range(mapping, 0, 0, 1);
+
+	while (index < end && pagevec_lookup_entries(&pvec, mapping, index,
+				min(end - index, (pgoff_t)PAGEVEC_SIZE),
+				indices)) {
+		for (i = 0; i < pagevec_count(&pvec); i++) {
+			struct page *pvec_ent = pvec.pages[i];
+			void *entry;
+
+			index = indices[i];
+			if (index >= end)
+				break;
+
+			if (!radix_tree_exceptional_entry(pvec_ent))
+				continue;
+
+			xa_lock_irq(&mapping->i_pages);
+			entry = get_unlocked_mapping_entry(mapping, index, NULL);
+			if (entry)
+				page = dax_busy_page(entry);
+			put_unlocked_mapping_entry(mapping, index, entry);
+			xa_unlock_irq(&mapping->i_pages);
+			if (page)
+				break;
+		}
+		pagevec_remove_exceptionals(&pvec);
+		pagevec_release(&pvec);
+		index++;
+
+		if (page)
+			break;
+	}
+	return page;
+}
+EXPORT_SYMBOL_GPL(dax_layout_busy_page);
+
 static int __dax_invalidate_mapping_entry(struct address_space *mapping,
 					  pgoff_t index, bool trunc)
 {
diff --git a/include/linux/dax.h b/include/linux/dax.h
index f1d6a8366e4b..3369aeb180e8 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -96,6 +96,8 @@ static inline void fs_put_dax(struct dax_device *dax_dev)
 
 int dax_writeback_mapping_range(struct address_space *mapping,
 		struct block_device *bdev, struct writeback_control *wbc);
+
+struct page *dax_layout_busy_page(struct address_space *mapping);
 #else
 static inline int bdev_dax_supported(struct super_block *sb, int blocksize)
 {
@@ -116,6 +118,11 @@ static inline int dax_writeback_mapping_range(struct address_space *mapping,
 {
 	return -EOPNOTSUPP;
 }
+
+static inline struct page *dax_layout_busy_page(struct address_space *mapping)
+{
+	return NULL;
+}
 #endif
 
 #if IS_ENABLED(CONFIG_FS_DAX) && IS_ENABLED(CONFIG_DEV_PAGEMAP_OPS)
diff --git a/mm/gup.c b/mm/gup.c
index 84dd2063ca3d..75ade7ebddb2 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -13,6 +13,7 @@
 #include <linux/sched/signal.h>
 #include <linux/rwsem.h>
 #include <linux/hugetlb.h>
+#include <linux/dax.h>
 
 #include <asm/mmu_context.h>
 #include <asm/pgtable.h>
