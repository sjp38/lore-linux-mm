Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 51CBF6B00E9
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:48:54 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [WIP 17/18] [Experimental] Support for huge pages in EXT 4
Date: Thu, 16 Feb 2012 15:47:56 +0100
Message-Id: <1329403677-25629-7-git-send-email-mail@smogura.eu>
In-Reply-To: <1329403677-25629-1-git-send-email-mail@smogura.eu>
References: <1329403677-25629-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org

It's rather experimental to uncover all leaks in adding huge page cache
support for shm, not for giving any real support for huge pages for
EXT4 file system. This will test if some concepts was good or bad.

In any case target is that some segments of glibc may be mapped as huge
pages, only if it will be aligned to huge page boundaries.

Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 fs/ext4/Kconfig                  |    9 ++++
 fs/ext4/file.c                   |    3 +
 fs/ext4/inode.c                  |   15 +++++++
 include/linux/defrag-pagecache.h |    4 ++
 include/linux/mm.h               |    4 ++
 mm/defrag-pagecache.c            |   19 +++++++++
 mm/filemap.c                     |   82 ++++++++++++++++++++++++++++++++++++++
 7 files changed, 136 insertions(+), 0 deletions(-)

diff --git a/fs/ext4/Kconfig b/fs/ext4/Kconfig
index 9ed1bb1..1a33bb0 100644
--- a/fs/ext4/Kconfig
+++ b/fs/ext4/Kconfig
@@ -83,3 +83,12 @@ config EXT4_DEBUG
 
 	  If you select Y here, then you will be able to turn on debugging
 	  with a command such as "echo 1 > /sys/kernel/debug/ext4/mballoc-debug"
+
+config EXT4_HUGEPAGECACHE
+	bool "EXT4 Huge Page Cache Support [Danegerous]"
+	depends on EXT4_FS
+	depends on HUGEPAGECACHE
+	help
+	  It's rather experimental to uncover all leaks in adding huge page cache
+	  support for shm, not for giving any real support for huge pages for
+	  EXT4 file system. This will test if some concepts was quite good.
diff --git a/fs/ext4/file.c b/fs/ext4/file.c
index cb70f18..57698df 100644
--- a/fs/ext4/file.c
+++ b/fs/ext4/file.c
@@ -143,6 +143,9 @@ ext4_file_write(struct kiocb *iocb, const struct iovec *iov,
 
 static const struct vm_operations_struct ext4_file_vm_ops = {
 	.fault		= filemap_fault,
+#ifdef CONFIG_EXT4_HUGEPAGECACHE
+	.fault_huge	= filemap_fault_huge,
+#endif
 	.page_mkwrite   = ext4_page_mkwrite,
 };
 
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index feaa82f..8bbda5a 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -45,6 +45,9 @@
 
 #include <trace/events/ext4.h>
 
+#ifdef CONFIG_EXT4_HUGEPAGECACHE
+#include <linux/defrag-pagecache.h>
+#endif
 #define MPAGE_DA_EXTENT_TAIL 0x01
 
 static inline int ext4_begin_ordered_truncate(struct inode *inode,
@@ -3036,6 +3039,9 @@ static const struct address_space_operations ext4_ordered_aops = {
 	.migratepage		= buffer_migrate_page,
 	.is_partially_uptodate  = block_is_partially_uptodate,
 	.error_remove_page	= generic_error_remove_page,
+#ifdef CONFIG_EXT4_HUGEPAGECACHE
+	.defragpage		= defrag_generic_file,
+#endif
 };
 
 static const struct address_space_operations ext4_writeback_aops = {
@@ -3051,6 +3057,9 @@ static const struct address_space_operations ext4_writeback_aops = {
 	.migratepage		= buffer_migrate_page,
 	.is_partially_uptodate  = block_is_partially_uptodate,
 	.error_remove_page	= generic_error_remove_page,
+#ifdef CONFIG_EXT4_HUGEPAGECACHE
+	.defragpage		= defrag_generic_file,
+#endif
 };
 
 static const struct address_space_operations ext4_journalled_aops = {
@@ -3066,6 +3075,9 @@ static const struct address_space_operations ext4_journalled_aops = {
 	.direct_IO		= ext4_direct_IO,
 	.is_partially_uptodate  = block_is_partially_uptodate,
 	.error_remove_page	= generic_error_remove_page,
+#ifdef CONFIG_EXT4_HUGEPAGECACHE
+	.defragpage		= defrag_generic_file,
+#endif
 };
 
 static const struct address_space_operations ext4_da_aops = {
@@ -3082,6 +3094,9 @@ static const struct address_space_operations ext4_da_aops = {
 	.migratepage		= buffer_migrate_page,
 	.is_partially_uptodate  = block_is_partially_uptodate,
 	.error_remove_page	= generic_error_remove_page,
+#ifdef CONFIG_EXT4_HUGEPAGECACHE
+	.defragpage		= defrag_generic_file,
+#endif
 };
 
 void ext4_set_aops(struct inode *inode)
diff --git a/include/linux/defrag-pagecache.h b/include/linux/defrag-pagecache.h
index 4ca3468..fb305c8 100644
--- a/include/linux/defrag-pagecache.h
+++ b/include/linux/defrag-pagecache.h
@@ -42,5 +42,9 @@ extern int defrag_generic_shm(struct file *file, struct address_space *mapping,
 			   loff_t pos,
 			   struct page **pagep,
 			   struct defrag_pagecache_ctl *ctl);
+extern int defrag_generic_file(struct file *file, struct address_space *mapping,
+			   loff_t pos,
+			   struct page **pagep,
+			   struct defrag_pagecache_ctl *ctl);
 #endif	/* DEFRAG_PAGECACHE_H */
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4c67555..24c2c6c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1620,6 +1620,10 @@ extern void truncate_inode_pages_range(struct address_space *,
 /* generic vm_area_ops exported for stackable file systems */
 extern int filemap_fault(struct vm_area_struct *, struct vm_fault *);
 
+#ifdef CONFIG_HUGEPAGECACHE
+extern int filemap_fault_huge(struct vm_area_struct *vma, struct vm_fault *vmf);
+#endif
+
 /* mm/page-writeback.c */
 int write_one_page(struct page *page, int wait);
 void task_dirty_inc(struct task_struct *tsk);
diff --git a/mm/defrag-pagecache.c b/mm/defrag-pagecache.c
index 5a14fe8..6a87814 100644
--- a/mm/defrag-pagecache.c
+++ b/mm/defrag-pagecache.c
@@ -104,6 +104,16 @@ struct page *shmem_defrag_get_page(const struct defrag_pagecache_ctl *ctl,
 				mapping_gfp_mask(inode->i_mapping));
 }
 
+/** Callback for getting page for tmpfs.
+ * Tmpfs uses {@link shmem_read_mapping_page_gfp} function to read
+ * page from page cache.
+ */
+struct page *file_defrag_get_page(const struct defrag_pagecache_ctl *ctl,
+	struct inode *inode, pgoff_t pageIndex)
+{
+	return read_mapping_page(inode->i_mapping, pageIndex, NULL);
+}
+
 static void defrag_generic_mig_result(struct page *oldPage,
 	struct page *newPage, struct migration_ctl *ctl, int result)
 {
@@ -258,6 +268,15 @@ int defrag_generic_shm(struct file *file, struct address_space *mapping,
 }
 EXPORT_SYMBOL(defrag_generic_shm);
 
+int defrag_generic_file(struct file *file, struct address_space *mapping,
+			   loff_t pos,
+			   struct page **pagep,
+			   struct defrag_pagecache_ctl *ctl)
+{
+	return defrageOneHugePage(file, pos, pagep, ctl, file_defrag_get_page);
+}
+EXPORT_SYMBOL(defrag_generic_file);
+
 int defrag_generic_pagecache(struct file *file,
 			struct address_space *mapping,
 			loff_t pos,
diff --git a/mm/filemap.c b/mm/filemap.c
index 8363cd9..f050209 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -43,6 +43,9 @@
 
 #include <asm/mman.h>
 
+#ifdef CONFIG_HUGEPAGECACHE
+#include <linux/defrag-pagecache.h>
+#endif
 /*
  * Shared mappings implemented 30.11.1994. It's not fully working yet,
  * though.
@@ -1771,6 +1774,85 @@ page_not_uptodate:
 }
 EXPORT_SYMBOL(filemap_fault);
 
+#ifdef CONFIG_HUGEPAGECACHE
+/** DO NOT USE THIS METHOD IS STILL EXPERIMENTAL. */
+int filemap_fault_huge(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
+	int error;
+	int ret = VM_FAULT_LOCKED;
+
+	error = vma->vm_ops->fault(vma, vmf);
+	/* XXX Repeatable flags in __do fault etc. */
+	if (error & (VM_FAULT_ERROR | VM_FAULT_NOPAGE
+		| VM_FAULT_RETRY | VM_FAULT_NOHUGE)) {
+		return error;
+	}
+
+	/* Just portion of developer code, to force defragmentation, as we have
+	 * no external interface to make defragmentation (or daemon to do it).
+	 */
+	if ((vma->vm_flags & VM_HUGEPAGE) && !PageCompound(vmf->page)) {
+		/* Force defrag - mainly devo code */
+		int defragResult;
+		const loff_t hugeChunkSize = 1 << (PMD_SHIFT - PAGE_SHIFT);
+
+		const loff_t vmaSizeToMap = (vma->vm_start
+				+ ((vmf->pgoff + vma->vm_pgoff + hugeChunkSize)
+				<< PAGE_SHIFT) <= vma->vm_end) ?
+					hugeChunkSize : 0;
+
+		const loff_t inodeSizeToMap =
+				(vmf->pgoff + vma->vm_pgoff + hugeChunkSize <
+				inode->i_size) ? hugeChunkSize : 0;
+
+		const struct defrag_pagecache_ctl defragControl = {
+			.fillPages = 1,
+			.requireFillPages = 1,
+			.force = 1
+		};
+
+		if (ret & VM_FAULT_LOCKED) {
+			unlock_page(vmf->page);
+		}
+		put_page(vmf->page);
+
+		defragResult = defragPageCache(vma->vm_file,
+			vmf->pgoff,
+			min(vmaSizeToMap, min(inodeSizeToMap, hugeChunkSize)),
+			&defragControl);
+		printk(KERN_INFO "Page defragmented with result %d\n",
+			defragResult);
+
+		/* Retake page. */
+		error = vma->vm_ops->fault(vma, vmf);
+		if (error & (VM_FAULT_ERROR | VM_FAULT_NOPAGE
+			| VM_FAULT_RETRY | VM_FAULT_NOHUGE)) {
+			return error;
+		}
+	}
+
+	/* After standard fault page is getted. */
+	if (!compound_get(vmf->page))
+		goto no_hugepage;
+
+	get_page_tails_for_fmap(vmf->page);
+
+	if (ret & VM_FAULT_MAJOR) {
+		count_vm_event(PGMAJFAULT);
+		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
+	}
+	return ret;
+no_hugepage:
+	if (ret & VM_FAULT_LOCKED)
+		unlock_page(vmf->page);
+	page_cache_release(vmf->page);
+	vmf->page = NULL;
+	return VM_FAULT_NOHUGE;
+}
+EXPORT_SYMBOL(filemap_fault_huge);
+#endif
+
 const struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
 };
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
