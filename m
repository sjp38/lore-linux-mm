Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 8E7E46B00F1
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:32:56 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [PATCH 09/18] Allowing usage of MAP_HUGETLB in mmap
Date: Thu, 16 Feb 2012 15:31:36 +0100
Message-Id: <1329402705-25454-9-git-send-email-mail@smogura.eu>
In-Reply-To: <1329402705-25454-1-git-send-email-mail@smogura.eu>
References: <1329402705-25454-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org

Patch adds support for mapping file with MAP_HUGETLB and does
checks if filesystem supports huge page cache.

Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 mm/mmap.c  |   24 +++++++++++++++-
 mm/shmem.c |   84 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 106 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 3f758c7..19f3016 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -992,6 +992,12 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	vm_flags = calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
 			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 
+	if (flags & MAP_HUGETLB) {
+		vm_flags &= ~VM_NOHUGEPAGE;
+		vm_flags |= VM_HUGEPAGE;
+		printk(KERN_INFO "Setted huge page mapping in do_mmap_pgoff.");
+	}
+
 	if (flags & MAP_LOCKED)
 		if (!can_do_mlock())
 			return -EPERM;
@@ -1086,11 +1092,25 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 
 	if (!(flags & MAP_ANONYMOUS)) {
 		audit_mmap_fd(fd, flags);
-		if (unlikely(flags & MAP_HUGETLB))
-			return -EINVAL;
 		file = fget(fd);
 		if (!file)
 			goto out;
+
+		if (unlikely(flags & MAP_HUGETLB)) {
+#ifdef CONFIG_HUGEPAGECACHE
+			if (!(file->f_mapping->a_ops->defragpage)) {
+				fput(file);
+				retval = -EINVAL;
+				goto out;
+			} else {
+				printk(KERN_INFO "Called to mmap huge with"
+					" good fs type.\n");
+			}
+#else
+			fput(file);
+			return -EINVAL;
+#endif
+		}
 	} else if (flags & MAP_HUGETLB) {
 		struct user_struct *user = NULL;
 		/*
diff --git a/mm/shmem.c b/mm/shmem.c
index 269d049..a834488 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1065,6 +1065,90 @@ static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	return ret;
 }
 
+static int shmem_fault_huge(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
+	int error;
+	int ret = VM_FAULT_LOCKED;
+
+	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_CACHE, &ret);
+	if (error)
+		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
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
+		error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_CACHE,
+			&ret);
+		if (error) {
+			return ((error == -ENOMEM) ?
+				VM_FAULT_OOM : VM_FAULT_SIGBUS);
+		}
+	}
+
+	/* XXX Page & compound lock ordering please... */
+	
+	/* After standard fault page is getted. */
+	if (PageCompound(vmf->page)) {
+		compound_lock(vmf->page);
+		if (!PageHead(vmf->page)) {
+			compound_unlock(vmf->page);
+			goto no_hugepage;
+		}
+	}else {
+		goto no_hugepage;
+	}
+	
+	if (!(ret & VM_FAULT_LOCKED))
+		lock_page(vmf->page);
+	
+	ret |= VM_FAULT_LOCKED;
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
 #ifdef CONFIG_NUMA
 static int shmem_set_policy(struct vm_area_struct *vma, struct mempolicy *mpol)
 {
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
