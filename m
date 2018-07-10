Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9577F6B000C
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 09:48:36 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w1-v6so12410840plq.8
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 06:48:36 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id b1-v6si16942977plc.403.2018.07.10.06.48.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 06:48:35 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/2] mm: Drop unneeded ->vm_ops checks
Date: Tue, 10 Jul 2018 16:48:21 +0300
Message-Id: <20180710134821.84709-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180710134821.84709-1-kirill.shutemov@linux.intel.com>
References: <20180710134821.84709-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We now have all VMAs with ->vm_ops set and don't need to check it for
NULL everywhere.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/binfmt_elf.c      |  2 +-
 fs/kernfs/file.c     | 20 +-------------------
 fs/proc/task_mmu.c   |  2 +-
 kernel/events/core.c |  2 +-
 kernel/fork.c        |  2 +-
 mm/hugetlb.c         |  2 +-
 mm/memory.c          | 12 ++++++------
 mm/mempolicy.c       | 10 +++++-----
 mm/mmap.c            | 14 +++++++-------
 mm/mremap.c          |  2 +-
 mm/nommu.c           |  4 ++--
 11 files changed, 27 insertions(+), 45 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 0ac456b52bdd..4f171cf21bc2 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -1302,7 +1302,7 @@ static bool always_dump_vma(struct vm_area_struct *vma)
 	 * Assume that all vmas with a .name op should always be dumped.
 	 * If this changes, a new vm_ops field can easily be added.
 	 */
-	if (vma->vm_ops && vma->vm_ops->name && vma->vm_ops->name(vma))
+	if (vma->vm_ops->name && vma->vm_ops->name(vma))
 		return true;
 
 	/*
diff --git a/fs/kernfs/file.c b/fs/kernfs/file.c
index 2015d8c45e4a..945c3d306d8f 100644
--- a/fs/kernfs/file.c
+++ b/fs/kernfs/file.c
@@ -336,9 +336,6 @@ static void kernfs_vma_open(struct vm_area_struct *vma)
 	struct file *file = vma->vm_file;
 	struct kernfs_open_file *of = kernfs_of(file);
 
-	if (!of->vm_ops)
-		return;
-
 	if (!kernfs_get_active(of->kn))
 		return;
 
@@ -354,9 +351,6 @@ static vm_fault_t kernfs_vma_fault(struct vm_fault *vmf)
 	struct kernfs_open_file *of = kernfs_of(file);
 	vm_fault_t ret;
 
-	if (!of->vm_ops)
-		return VM_FAULT_SIGBUS;
-
 	if (!kernfs_get_active(of->kn))
 		return VM_FAULT_SIGBUS;
 
@@ -374,9 +368,6 @@ static vm_fault_t kernfs_vma_page_mkwrite(struct vm_fault *vmf)
 	struct kernfs_open_file *of = kernfs_of(file);
 	vm_fault_t ret;
 
-	if (!of->vm_ops)
-		return VM_FAULT_SIGBUS;
-
 	if (!kernfs_get_active(of->kn))
 		return VM_FAULT_SIGBUS;
 
@@ -397,9 +388,6 @@ static int kernfs_vma_access(struct vm_area_struct *vma, unsigned long addr,
 	struct kernfs_open_file *of = kernfs_of(file);
 	int ret;
 
-	if (!of->vm_ops)
-		return -EINVAL;
-
 	if (!kernfs_get_active(of->kn))
 		return -EINVAL;
 
@@ -419,9 +407,6 @@ static int kernfs_vma_set_policy(struct vm_area_struct *vma,
 	struct kernfs_open_file *of = kernfs_of(file);
 	int ret;
 
-	if (!of->vm_ops)
-		return 0;
-
 	if (!kernfs_get_active(of->kn))
 		return -EINVAL;
 
@@ -440,9 +425,6 @@ static struct mempolicy *kernfs_vma_get_policy(struct vm_area_struct *vma,
 	struct kernfs_open_file *of = kernfs_of(file);
 	struct mempolicy *pol;
 
-	if (!of->vm_ops)
-		return vma->vm_policy;
-
 	if (!kernfs_get_active(of->kn))
 		return vma->vm_policy;
 
@@ -511,7 +493,7 @@ static int kernfs_fop_mmap(struct file *file, struct vm_area_struct *vma)
 	 * So error if someone is trying to use close.
 	 */
 	rc = -EINVAL;
-	if (vma->vm_ops && vma->vm_ops->close)
+	if (vma->vm_ops->close)
 		goto out_put;
 
 	rc = 0;
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index e9679016271f..e959623123e4 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -326,7 +326,7 @@ show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 		goto done;
 	}
 
-	if (vma->vm_ops && vma->vm_ops->name) {
+	if (vma->vm_ops->name) {
 		name = vma->vm_ops->name(vma);
 		if (name)
 			goto done;
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 8f0434a9951a..2e35401a5c68 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -7269,7 +7269,7 @@ static void perf_event_mmap_event(struct perf_mmap_event *mmap_event)
 
 		goto got_name;
 	} else {
-		if (vma->vm_ops && vma->vm_ops->name) {
+		if (vma->vm_ops->name) {
 			name = (char *) vma->vm_ops->name(vma);
 			if (name)
 				goto cpy_name;
diff --git a/kernel/fork.c b/kernel/fork.c
index 9440d61b925c..e5e7a220a124 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -519,7 +519,7 @@ static __latent_entropy int dup_mmap(struct mm_struct *mm,
 		if (!(tmp->vm_flags & VM_WIPEONFORK))
 			retval = copy_page_range(mm, oldmm, mpnt);
 
-		if (tmp->vm_ops && tmp->vm_ops->open)
+		if (tmp->vm_ops->open)
 			tmp->vm_ops->open(tmp);
 
 		if (retval)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 039ddbc574e9..2065acc5a6aa 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -637,7 +637,7 @@ EXPORT_SYMBOL_GPL(linear_hugepage_index);
  */
 unsigned long vma_kernel_pagesize(struct vm_area_struct *vma)
 {
-	if (vma->vm_ops && vma->vm_ops->pagesize)
+	if (vma->vm_ops->pagesize)
 		return vma->vm_ops->pagesize(vma);
 	return PAGE_SIZE;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 7206a634270b..02fbef2bd024 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -768,7 +768,7 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 		 (void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
 	pr_alert("file:%pD fault:%pf mmap:%pf readpage:%pf\n",
 		 vma->vm_file,
-		 vma->vm_ops ? vma->vm_ops->fault : NULL,
+		 vma->vm_ops->fault,
 		 vma->vm_file ? vma->vm_file->f_op->mmap : NULL,
 		 mapping ? mapping->a_ops->readpage : NULL);
 	dump_stack();
@@ -825,7 +825,7 @@ struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 	if (IS_ENABLED(CONFIG_ARCH_HAS_PTE_SPECIAL)) {
 		if (likely(!pte_special(pte)))
 			goto check_pfn;
-		if (vma->vm_ops && vma->vm_ops->find_special_page)
+		if (vma->vm_ops->find_special_page)
 			return vma->vm_ops->find_special_page(vma, addr);
 		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
 			return NULL;
@@ -2404,7 +2404,7 @@ static void fault_dirty_shared_page(struct vm_area_struct *vma,
 {
 	struct address_space *mapping;
 	bool dirtied;
-	bool page_mkwrite = vma->vm_ops && vma->vm_ops->page_mkwrite;
+	bool page_mkwrite = vma->vm_ops->page_mkwrite;
 
 	dirtied = set_page_dirty(page);
 	VM_BUG_ON_PAGE(PageAnon(page), page);
@@ -2648,7 +2648,7 @@ static int wp_pfn_shared(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 
-	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
+	if (vma->vm_ops->pfn_mkwrite) {
 		int ret;
 
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -2669,7 +2669,7 @@ static int wp_page_shared(struct vm_fault *vmf)
 
 	get_page(vmf->page);
 
-	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
+	if (vma->vm_ops->page_mkwrite) {
 		int tmp;
 
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -4439,7 +4439,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 			vma = find_vma(mm, addr);
 			if (!vma || vma->vm_start > addr)
 				break;
-			if (vma->vm_ops && vma->vm_ops->access)
+			if (vma->vm_ops->access)
 				ret = vma->vm_ops->access(vma, addr, buf,
 							  len, write);
 			if (ret <= 0)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 9ac49ef17b4e..f0fcf70bcec7 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -651,13 +651,13 @@ static int vma_replace_policy(struct vm_area_struct *vma,
 	pr_debug("vma %lx-%lx/%lx vm_ops %p vm_file %p set_policy %p\n",
 		 vma->vm_start, vma->vm_end, vma->vm_pgoff,
 		 vma->vm_ops, vma->vm_file,
-		 vma->vm_ops ? vma->vm_ops->set_policy : NULL);
+		 vma->vm_ops->set_policy);
 
 	new = mpol_dup(pol);
 	if (IS_ERR(new))
 		return PTR_ERR(new);
 
-	if (vma->vm_ops && vma->vm_ops->set_policy) {
+	if (vma->vm_ops->set_policy) {
 		err = vma->vm_ops->set_policy(vma, new);
 		if (err)
 			goto err_out;
@@ -845,7 +845,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
 			up_read(&mm->mmap_sem);
 			return -EFAULT;
 		}
-		if (vma->vm_ops && vma->vm_ops->get_policy)
+		if (vma->vm_ops->get_policy)
 			pol = vma->vm_ops->get_policy(vma, addr);
 		else
 			pol = vma->vm_policy;
@@ -1617,7 +1617,7 @@ struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
 	struct mempolicy *pol = NULL;
 
 	if (vma) {
-		if (vma->vm_ops && vma->vm_ops->get_policy) {
+		if (vma->vm_ops->get_policy) {
 			pol = vma->vm_ops->get_policy(vma, addr);
 		} else if (vma->vm_policy) {
 			pol = vma->vm_policy;
@@ -1663,7 +1663,7 @@ bool vma_policy_mof(struct vm_area_struct *vma)
 {
 	struct mempolicy *pol;
 
-	if (vma->vm_ops && vma->vm_ops->get_policy) {
+	if (vma->vm_ops->get_policy) {
 		bool ret = false;
 
 		pol = vma->vm_ops->get_policy(vma, vma->vm_start);
diff --git a/mm/mmap.c b/mm/mmap.c
index 0729ed06b01c..366280686b92 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -180,7 +180,7 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 	struct vm_area_struct *next = vma->vm_next;
 
 	might_sleep();
-	if (vma->vm_ops && vma->vm_ops->close)
+	if (vma->vm_ops->close)
 		vma->vm_ops->close(vma);
 	if (vma->vm_file)
 		fput(vma->vm_file);
@@ -1001,7 +1001,7 @@ static inline int is_mergeable_vma(struct vm_area_struct *vma,
 		return 0;
 	if (vma->vm_file != file)
 		return 0;
-	if (vma->vm_ops && vma->vm_ops->close)
+	if (vma->vm_ops->close)
 		return 0;
 	if (!is_mergeable_vm_userfaultfd_ctx(vma, vm_userfaultfd_ctx))
 		return 0;
@@ -1641,7 +1641,7 @@ int vma_wants_writenotify(struct vm_area_struct *vma, pgprot_t vm_page_prot)
 		return 0;
 
 	/* The backer wishes to know when pages are first written to? */
-	if (vm_ops && (vm_ops->page_mkwrite || vm_ops->pfn_mkwrite))
+	if (vm_ops->page_mkwrite || vm_ops->pfn_mkwrite)
 		return 1;
 
 	/* The open routine did something to the protections that pgprot_modify
@@ -2626,7 +2626,7 @@ int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct vm_area_struct *new;
 	int err;
 
-	if (vma->vm_ops && vma->vm_ops->split) {
+	if (vma->vm_ops->split) {
 		err = vma->vm_ops->split(vma, addr);
 		if (err)
 			return err;
@@ -2659,7 +2659,7 @@ int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (new->vm_file)
 		get_file(new->vm_file);
 
-	if (new->vm_ops && new->vm_ops->open)
+	if (new->vm_ops->open)
 		new->vm_ops->open(new);
 
 	if (new_below)
@@ -2673,7 +2673,7 @@ int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 		return 0;
 
 	/* Clean everything up if vma_adjust failed. */
-	if (new->vm_ops && new->vm_ops->close)
+	if (new->vm_ops->close)
 		new->vm_ops->close(new);
 	if (new->vm_file)
 		fput(new->vm_file);
@@ -3234,7 +3234,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 			goto out_free_mempol;
 		if (new_vma->vm_file)
 			get_file(new_vma->vm_file);
-		if (new_vma->vm_ops && new_vma->vm_ops->open)
+		if (new_vma->vm_ops->open)
 			new_vma->vm_ops->open(new_vma);
 		vma_link(mm, new_vma, prev, rb_link, rb_parent);
 		*need_rmap_locks = false;
diff --git a/mm/mremap.c b/mm/mremap.c
index 5c2e18505f75..7ab222c283de 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -302,7 +302,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 				     need_rmap_locks);
 	if (moved_len < old_len) {
 		err = -ENOMEM;
-	} else if (vma->vm_ops && vma->vm_ops->mremap) {
+	} else if (vma->vm_ops->mremap) {
 		err = vma->vm_ops->mremap(new_vma);
 	}
 
diff --git a/mm/nommu.c b/mm/nommu.c
index 4452d8bd9ae4..e7f447bfd704 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -764,7 +764,7 @@ static void delete_vma_from_mm(struct vm_area_struct *vma)
  */
 static void delete_vma(struct mm_struct *mm, struct vm_area_struct *vma)
 {
-	if (vma->vm_ops && vma->vm_ops->close)
+	if (vma->vm_ops->close)
 		vma->vm_ops->close(vma);
 	if (vma->vm_file)
 		fput(vma->vm_file);
@@ -1489,7 +1489,7 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 		region->vm_pgoff = new->vm_pgoff += npages;
 	}
 
-	if (new->vm_ops && new->vm_ops->open)
+	if (new->vm_ops->open)
 		new->vm_ops->open(new);
 
 	delete_vma_from_mm(vma);
-- 
2.18.0
