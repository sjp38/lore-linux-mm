Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 421836B002C
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:48:48 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [WIP 11/18] Basic support (faulting) for huge pages for shmfs
Date: Thu, 16 Feb 2012 15:47:50 +0100
Message-Id: <1329403677-25629-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org

This is basic support for shmfs, allowing bootstraping of huge pages
in user address space.

This patch is just one first setep, it breakes kernel, because of
missing other requirements for page cache, but establishing is
done :D. Yupi!

Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 include/linux/fs.h |    4 ++--
 include/linux/mm.h |    4 ++--
 mm/shmem.c         |   30 ++++++++++++++----------------
 3 files changed, 18 insertions(+), 20 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 7288166..7afc38b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -595,7 +595,7 @@ struct address_space_operations {
 
 	/** Same as \a set_page_dirty but for huge page */
 	int (*set_page_dirty_huge)(struct page *page);
-	
+
 	int (*readpages)(struct file *filp, struct address_space *mapping,
 			struct list_head *pages, unsigned nr_pages);
 
@@ -627,7 +627,7 @@ struct address_space_operations {
 	 */
 	int (*split_page) (struct file *file, struct address_space *mapping,
 		loff_t pos, struct page *hueg_page);
-	
+
 	/* Unfortunately this kludge is needed for FIBMAP. Don't use it */
 	sector_t (*bmap)(struct address_space *, sector_t);
 	void (*invalidatepage) (struct page *, unsigned long);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 27a10c8..236a6be 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -210,7 +210,7 @@ struct vm_operations_struct {
 	 * If function fails, then caller may try again with fault.
 	 */
 	int (*fault_huge)(struct vm_area_struct *vma, struct vm_fault *vmf);
-	
+
 	/* notification that a previously read-only page is about to become
 	 * writable, if an error is returned it will cause a SIGBUS */
 	int (*page_mkwrite)(struct vm_area_struct *vma, struct vm_fault *vmf);
@@ -218,7 +218,7 @@ struct vm_operations_struct {
 	/** Same as \a page_mkwrite, but for huge page. */
 	int (*page_mkwrite_huge)(struct vm_area_struct *vma,
 				 struct vm_fault *vmf);
-	
+
 	/* called by access_process_vm when get_user_pages() fails, typically
 	 * for use by special VMAs that can switch between memory and hardware
 	 */
diff --git a/mm/shmem.c b/mm/shmem.c
index a834488..97e76b9 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -67,6 +67,10 @@ static struct vfsmount *shm_mnt;
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 
+#ifdef CONFIG_HUGEPAGECACHE
+#include <linux/defrag-pagecache.h>
+#endif
+
 #define BLOCKS_PER_PAGE  (PAGE_CACHE_SIZE/512)
 #define VM_ACCT(size)    (PAGE_CACHE_ALIGN(size) >> PAGE_SHIFT)
 
@@ -1119,24 +1123,12 @@ static int shmem_fault_huge(struct vm_area_struct *vma, struct vm_fault *vmf)
 		}
 	}
 
-	/* XXX Page & compound lock ordering please... */
-	
 	/* After standard fault page is getted. */
-	if (PageCompound(vmf->page)) {
-		compound_lock(vmf->page);
-		if (!PageHead(vmf->page)) {
-			compound_unlock(vmf->page);
-			goto no_hugepage;
-		}
-	}else {
+	if (!compound_get(vmf->page))
 		goto no_hugepage;
-	}
-	
-	if (!(ret & VM_FAULT_LOCKED))
-		lock_page(vmf->page);
-	
-	ret |= VM_FAULT_LOCKED;
-	
+
+	get_page_tails_for_fmap(vmf->page);
+
 	if (ret & VM_FAULT_MAJOR) {
 		count_vm_event(PGMAJFAULT);
 		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
@@ -2381,6 +2373,9 @@ static const struct address_space_operations shmem_aops = {
 #endif
 	.migratepage	= migrate_page,
 	.error_remove_page = generic_error_remove_page,
+#ifdef CONFIG_HUGEPAGECACHE
+	.defragpage = defrag_generic_shm,
+#endif
 };
 
 static const struct file_operations shmem_file_operations = {
@@ -2458,6 +2453,9 @@ static const struct super_operations shmem_ops = {
 
 static const struct vm_operations_struct shmem_vm_ops = {
 	.fault		= shmem_fault,
+#ifdef CONFIG_SHMEM_HUGEPAGECACHE
+	.fault_huge	= shmem_fault_huge,
+#endif
 #ifdef CONFIG_NUMA
 	.set_policy     = shmem_set_policy,
 	.get_policy     = shmem_get_policy,
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
