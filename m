Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A5D9A6B02ED
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 11:25:16 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v25-v6so3818972pfm.11
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 08:25:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e91-v6sor5170966plb.66.2018.07.09.08.25.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 08:25:14 -0700 (PDT)
Date: Mon, 9 Jul 2018 18:25:08 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel BUG at mm/memory.c:LINE!
Message-ID: <20180709152508.smwg252x57pnfkoq@kshutemo-mobl1>
References: <0000000000004a7da505708a9915@google.com>
 <20180709101558.63vkwppwcgzcv3dg@kshutemo-mobl1>
 <CACT4Y+a=8NOg+h6fBzpmVHiZ-vNUiG7SW4QgQvK3vD=KBqQ3_Q@mail.gmail.com>
 <CACT4Y+baBmOHwH6rUL3DjKhGk-JjBAvKOmnq65_4z6b96ohrBQ@mail.gmail.com>
 <20180709142155.jlgytrhdmkyvowzh@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180709142155.jlgytrhdmkyvowzh@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+3f84280d52be9b7083cc@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, ldufour@linux.vnet.ibm.com, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Matthew Wilcox <willy@infradead.org>, ying.huang@intel.com

On Mon, Jul 09, 2018 at 05:21:55PM +0300, Kirill A. Shutemov wrote:
> > This also happened only once so far:
> > https://syzkaller.appspot.com/bug?extid=3f84280d52be9b7083cc
> > and I can't reproduce it rerunning this program. So it's either a very
> > subtle race, or fd in the middle of netlink address magically matched
> > some fd once, or something else...
> 
> Okay, I've got it reproduced. See below.
> 
> The problem is that kcov doesn't set vm_ops for the VMA and it makes
> kernel think that the VMA is anonymous.
> 
> It's not necessary the way it was triggered by syzkaller. I just found
> that kcov's ->mmap doesn't set vm_ops. There can more such cases.
> vma_is_anonymous() is what we need to fix.
> 
> ( Although, I found logic around mmaping the file second time questinable
>   at best. It seems broken to me. )
> 
> It is known that vma_is_anonymous() can produce false-positives. It tried
> to fix it once[1], but it back-fired[2].
> 
> I'll look at this again.

Below is a patch that seems work. But it definately requires more testing.

Dmitry, could you give it a try in syzkaller?

diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index ffeb60d3434c..f0a8b0b1768b 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -708,6 +708,7 @@ static int mmap_zero(struct file *file, struct vm_area_struct *vma)
 #endif
 	if (vma->vm_flags & VM_SHARED)
 		return shmem_zero_setup(vma);
+	vma->vm_ops = &anon_vm_ops;
 	return 0;
 }
 
diff --git a/fs/exec.c b/fs/exec.c
index 2d4e0075bd24..a1a246062561 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -307,6 +307,7 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 	 * configured yet.
 	 */
 	BUILD_BUG_ON(VM_STACK_FLAGS & VM_STACK_INCOMPLETE_SETUP);
+	vma->vm_ops = &anon_vm_ops;
 	vma->vm_end = STACK_TOP_MAX;
 	vma->vm_start = vma->vm_end - PAGE_SIZE;
 	vma->vm_flags = VM_SOFTDIRTY | VM_STACK_FLAGS | VM_STACK_INCOMPLETE_SETUP;
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
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a0fbb9ffe380..f1db03c919c3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1536,9 +1536,11 @@ int clear_page_dirty_for_io(struct page *page);
 
 int get_cmdline(struct task_struct *task, char *buffer, int buflen);
 
+extern const struct vm_operations_struct anon_vm_ops;
+
 static inline bool vma_is_anonymous(struct vm_area_struct *vma)
 {
-	return !vma->vm_ops;
+	return vma->vm_ops == &anon_vm_ops;
 }
 
 #ifdef CONFIG_SHMEM
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
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index d7b2a4bf8671..5ae34097aed1 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -440,7 +440,7 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
 		 * page fault if needed.
 		 */
 		return 0;
-	if (vma->vm_ops || (vm_flags & VM_NO_KHUGEPAGED))
+	if (!vma_is_anonymous(vma) || (vm_flags & VM_NO_KHUGEPAGED))
 		/* khugepaged not yet working on file or special mappings */
 		return 0;
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
@@ -831,7 +831,7 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 		return IS_ALIGNED((vma->vm_start >> PAGE_SHIFT) - vma->vm_pgoff,
 				HPAGE_PMD_NR);
 	}
-	if (!vma->anon_vma || vma->vm_ops)
+	if (!vma->anon_vma || !vma_is_anonymous(vma))
 		return false;
 	if (is_vma_temporary_stack(vma))
 		return false;
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
index d1eb87ef4b1a..516fb5c5bfe5 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -71,6 +71,8 @@ int mmap_rnd_compat_bits __read_mostly = CONFIG_ARCH_MMAP_RND_COMPAT_BITS;
 static bool ignore_rlimit_data;
 core_param(ignore_rlimit_data, ignore_rlimit_data, bool, 0644);
 
+const struct vm_operations_struct anon_vm_ops = {};
+
 static void unmap_region(struct mm_struct *mm,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
 		unsigned long start, unsigned long end);
@@ -177,7 +179,7 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 	struct vm_area_struct *next = vma->vm_next;
 
 	might_sleep();
-	if (vma->vm_ops && vma->vm_ops->close)
+	if (vma->vm_ops->close)
 		vma->vm_ops->close(vma);
 	if (vma->vm_file)
 		fput(vma->vm_file);
@@ -561,6 +563,8 @@ static unsigned long count_vma_pages_range(struct mm_struct *mm,
 void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct rb_node **rb_link, struct rb_node *rb_parent)
 {
+	WARN_ONCE(!vma->vm_ops, "missing vma->vm_ops");
+
 	/* Update tracking information for the gap following the new vma. */
 	if (vma->vm_next)
 		vma_gap_update(vma->vm_next);
@@ -996,7 +1000,7 @@ static inline int is_mergeable_vma(struct vm_area_struct *vma,
 		return 0;
 	if (vma->vm_file != file)
 		return 0;
-	if (vma->vm_ops && vma->vm_ops->close)
+	if (vma->vm_ops->close)
 		return 0;
 	if (!is_mergeable_vm_userfaultfd_ctx(vma, vm_userfaultfd_ctx))
 		return 0;
@@ -1636,7 +1640,7 @@ int vma_wants_writenotify(struct vm_area_struct *vma, pgprot_t vm_page_prot)
 		return 0;
 
 	/* The backer wishes to know when pages are first written to? */
-	if (vm_ops && (vm_ops->page_mkwrite || vm_ops->pfn_mkwrite))
+	if (vm_ops->page_mkwrite || vm_ops->pfn_mkwrite)
 		return 1;
 
 	/* The open routine did something to the protections that pgprot_modify
@@ -1774,12 +1778,20 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 		 */
 		WARN_ON_ONCE(addr != vma->vm_start);
 
+		/* All mappings must have ->vm_ops set */
+		if (!vma->vm_ops) {
+			static const struct vm_operations_struct dummy_ops = {};
+			vma->vm_ops = &dummy_ops;
+		}
+
 		addr = vma->vm_start;
 		vm_flags = vma->vm_flags;
 	} else if (vm_flags & VM_SHARED) {
 		error = shmem_zero_setup(vma);
 		if (error)
 			goto free_vma;
+	} else {
+		vma->vm_ops = &anon_vm_ops;
 	}
 
 	vma_link(mm, vma, prev, rb_link, rb_parent);
@@ -2614,7 +2626,7 @@ int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct vm_area_struct *new;
 	int err;
 
-	if (vma->vm_ops && vma->vm_ops->split) {
+	if (vma->vm_ops->split) {
 		err = vma->vm_ops->split(vma, addr);
 		if (err)
 			return err;
@@ -2647,7 +2659,7 @@ int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (new->vm_file)
 		get_file(new->vm_file);
 
-	if (new->vm_ops && new->vm_ops->open)
+	if (new->vm_ops->open)
 		new->vm_ops->open(new);
 
 	if (new_below)
@@ -2661,7 +2673,7 @@ int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 		return 0;
 
 	/* Clean everything up if vma_adjust failed. */
-	if (new->vm_ops && new->vm_ops->close)
+	if (new->vm_ops->close)
 		new->vm_ops->close(new);
 	if (new->vm_file)
 		fput(new->vm_file);
@@ -2999,6 +3011,7 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
 	vma->vm_mm = mm;
+	vma->vm_ops = &anon_vm_ops;
 	vma->vm_start = addr;
 	vma->vm_end = addr + len;
 	vma->vm_pgoff = pgoff;
@@ -3221,7 +3234,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
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
diff --git a/mm/shmem.c b/mm/shmem.c
index 2cab84403055..bf991c9230b3 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1424,6 +1424,7 @@ static void shmem_pseudo_vma_init(struct vm_area_struct *vma,
 	/* Bias interleave by inode number to distribute better across nodes */
 	vma->vm_pgoff = index + info->vfs_inode.i_ino;
 	vma->vm_policy = mpol_shared_policy_lookup(&info->policy, index);
+	vma->vm_ops = &anon_vm_ops;
 }
 
 static void shmem_pseudo_vma_destroy(struct vm_area_struct *vma)
-- 
 Kirill A. Shutemov
