Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id AA2766B0005
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 10:20:47 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id b5-v6so24851392ple.20
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 07:20:47 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id d64-v6si31256951pfc.31.2018.07.16.07.20.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 07:20:45 -0700 (PDT)
Date: Mon, 16 Jul 2018 17:20:49 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: REGRESSION: [PATCHv2 2/2] mm: Drop unneeded ->vm_ops checks
Message-ID: <20180716142049.ioa2irsd2d7sphn4@black.fi.intel.com>
References: <20180712145626.41665-1-kirill.shutemov@linux.intel.com>
 <20180712145626.41665-3-kirill.shutemov@linux.intel.com>
 <1531747832.6547.7.camel@toradex.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1531747832.6547.7.camel@toradex.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcel Ziswiler <marcel.ziswiler@toradex.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "dvyukov@google.com" <dvyukov@google.com>, "oleg@redhat.com" <oleg@redhat.com>, "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>

On Mon, Jul 16, 2018 at 01:30:34PM +0000, Marcel Ziswiler wrote:
> On Thu, 2018-07-12 at 17:56 +0300, Kirill A. Shutemov wrote:
> > We now have all VMAs with ->vm_ops set and don't need to check it for
> > NULL everywhere.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  fs/binfmt_elf.c      |  2 +-
> >  fs/kernfs/file.c     | 20 +-------------------
> >  fs/proc/task_mmu.c   |  2 +-
> >  kernel/events/core.c |  2 +-
> >  kernel/fork.c        |  2 +-
> >  mm/gup.c             |  2 +-
> >  mm/hugetlb.c         |  2 +-
> >  mm/memory.c          | 12 ++++++------
> >  mm/mempolicy.c       | 10 +++++-----
> >  mm/mmap.c            | 14 +++++++-------
> >  mm/mremap.c          |  2 +-
> >  mm/nommu.c           |  4 ++--
> >  12 files changed, 28 insertions(+), 46 deletions(-)
> > 
> > diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> > index 0ac456b52bdd..4f171cf21bc2 100644
> > --- a/fs/binfmt_elf.c
> > +++ b/fs/binfmt_elf.c
> > @@ -1302,7 +1302,7 @@ static bool always_dump_vma(struct
> > vm_area_struct *vma)
> >  	 * Assume that all vmas with a .name op should always be
> > dumped.
> >  	 * If this changes, a new vm_ops field can easily be added.
> >  	 */
> > -	if (vma->vm_ops && vma->vm_ops->name && vma->vm_ops-
> > >name(vma))
> > +	if (vma->vm_ops->name && vma->vm_ops->name(vma))
> >  		return true;
> >  
> >  	/*
> > diff --git a/fs/kernfs/file.c b/fs/kernfs/file.c
> > index 2015d8c45e4a..945c3d306d8f 100644
> > --- a/fs/kernfs/file.c
> > +++ b/fs/kernfs/file.c
> > @@ -336,9 +336,6 @@ static void kernfs_vma_open(struct vm_area_struct
> > *vma)
> >  	struct file *file = vma->vm_file;
> >  	struct kernfs_open_file *of = kernfs_of(file);
> >  
> > -	if (!of->vm_ops)
> > -		return;
> > -
> >  	if (!kernfs_get_active(of->kn))
> >  		return;
> >  
> > @@ -354,9 +351,6 @@ static vm_fault_t kernfs_vma_fault(struct
> > vm_fault *vmf)
> >  	struct kernfs_open_file *of = kernfs_of(file);
> >  	vm_fault_t ret;
> >  
> > -	if (!of->vm_ops)
> > -		return VM_FAULT_SIGBUS;
> > -
> >  	if (!kernfs_get_active(of->kn))
> >  		return VM_FAULT_SIGBUS;
> >  
> > @@ -374,9 +368,6 @@ static vm_fault_t kernfs_vma_page_mkwrite(struct
> > vm_fault *vmf)
> >  	struct kernfs_open_file *of = kernfs_of(file);
> >  	vm_fault_t ret;
> >  
> > -	if (!of->vm_ops)
> > -		return VM_FAULT_SIGBUS;
> > -
> >  	if (!kernfs_get_active(of->kn))
> >  		return VM_FAULT_SIGBUS;
> >  
> > @@ -397,9 +388,6 @@ static int kernfs_vma_access(struct
> > vm_area_struct *vma, unsigned long addr,
> >  	struct kernfs_open_file *of = kernfs_of(file);
> >  	int ret;
> >  
> > -	if (!of->vm_ops)
> > -		return -EINVAL;
> > -
> >  	if (!kernfs_get_active(of->kn))
> >  		return -EINVAL;
> >  
> > @@ -419,9 +407,6 @@ static int kernfs_vma_set_policy(struct
> > vm_area_struct *vma,
> >  	struct kernfs_open_file *of = kernfs_of(file);
> >  	int ret;
> >  
> > -	if (!of->vm_ops)
> > -		return 0;
> > -
> >  	if (!kernfs_get_active(of->kn))
> >  		return -EINVAL;
> >  
> > @@ -440,9 +425,6 @@ static struct mempolicy
> > *kernfs_vma_get_policy(struct vm_area_struct *vma,
> >  	struct kernfs_open_file *of = kernfs_of(file);
> >  	struct mempolicy *pol;
> >  
> > -	if (!of->vm_ops)
> > -		return vma->vm_policy;
> > -
> >  	if (!kernfs_get_active(of->kn))
> >  		return vma->vm_policy;
> >  
> > @@ -511,7 +493,7 @@ static int kernfs_fop_mmap(struct file *file,
> > struct vm_area_struct *vma)
> >  	 * So error if someone is trying to use close.
> >  	 */
> >  	rc = -EINVAL;
> > -	if (vma->vm_ops && vma->vm_ops->close)
> > +	if (vma->vm_ops->close)
> >  		goto out_put;
> >  
> >  	rc = 0;
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index e9679016271f..e959623123e4 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -326,7 +326,7 @@ show_map_vma(struct seq_file *m, struct
> > vm_area_struct *vma, int is_pid)
> >  		goto done;
> >  	}
> >  
> > -	if (vma->vm_ops && vma->vm_ops->name) {
> > +	if (vma->vm_ops->name) {
> >  		name = vma->vm_ops->name(vma);
> >  		if (name)
> >  			goto done;
> > diff --git a/kernel/events/core.c b/kernel/events/core.c
> > index 8f0434a9951a..2e35401a5c68 100644
> > --- a/kernel/events/core.c
> > +++ b/kernel/events/core.c
> > @@ -7269,7 +7269,7 @@ static void perf_event_mmap_event(struct
> > perf_mmap_event *mmap_event)
> >  
> >  		goto got_name;
> >  	} else {
> > -		if (vma->vm_ops && vma->vm_ops->name) {
> > +		if (vma->vm_ops->name) {
> >  			name = (char *) vma->vm_ops->name(vma);
> >  			if (name)
> >  				goto cpy_name;
> > diff --git a/kernel/fork.c b/kernel/fork.c
> > index 9440d61b925c..e5e7a220a124 100644
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -519,7 +519,7 @@ static __latent_entropy int dup_mmap(struct
> > mm_struct *mm,
> >  		if (!(tmp->vm_flags & VM_WIPEONFORK))
> >  			retval = copy_page_range(mm, oldmm, mpnt);
> >  
> > -		if (tmp->vm_ops && tmp->vm_ops->open)
> > +		if (tmp->vm_ops->open)
> >  			tmp->vm_ops->open(tmp);
> >  
> >  		if (retval)
> > diff --git a/mm/gup.c b/mm/gup.c
> > index b70d7ba7cc13..b732768ed3ac 100644
> > --- a/mm/gup.c
> > +++ b/mm/gup.c
> > @@ -31,7 +31,7 @@ static struct page *no_page_table(struct
> > vm_area_struct *vma,
> >  	 * But we can only make this optimization where a hole would
> > surely
> >  	 * be zero-filled if handle_mm_fault() actually did handle
> > it.
> >  	 */
> > -	if ((flags & FOLL_DUMP) && (!vma->vm_ops || !vma->vm_ops-
> > >fault))
> > +	if ((flags & FOLL_DUMP) && !vma->vm_ops->fault)
> >  		return ERR_PTR(-EFAULT);
> >  	return NULL;
> >  }
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 039ddbc574e9..2065acc5a6aa 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -637,7 +637,7 @@ EXPORT_SYMBOL_GPL(linear_hugepage_index);
> >   */
> >  unsigned long vma_kernel_pagesize(struct vm_area_struct *vma)
> >  {
> > -	if (vma->vm_ops && vma->vm_ops->pagesize)
> > +	if (vma->vm_ops->pagesize)
> >  		return vma->vm_ops->pagesize(vma);
> >  	return PAGE_SIZE;
> >  }
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 7206a634270b..02fbef2bd024 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -768,7 +768,7 @@ static void print_bad_pte(struct vm_area_struct
> > *vma, unsigned long addr,
> >  		 (void *)addr, vma->vm_flags, vma->anon_vma,
> > mapping, index);
> >  	pr_alert("file:%pD fault:%pf mmap:%pf readpage:%pf\n",
> >  		 vma->vm_file,
> > -		 vma->vm_ops ? vma->vm_ops->fault : NULL,
> > +		 vma->vm_ops->fault,
> >  		 vma->vm_file ? vma->vm_file->f_op->mmap : NULL,
> >  		 mapping ? mapping->a_ops->readpage : NULL);
> >  	dump_stack();
> > @@ -825,7 +825,7 @@ struct page *_vm_normal_page(struct
> > vm_area_struct *vma, unsigned long addr,
> >  	if (IS_ENABLED(CONFIG_ARCH_HAS_PTE_SPECIAL)) {
> >  		if (likely(!pte_special(pte)))
> >  			goto check_pfn;
> > -		if (vma->vm_ops && vma->vm_ops->find_special_page)
> > +		if (vma->vm_ops->find_special_page)
> >  			return vma->vm_ops->find_special_page(vma,
> > addr);
> >  		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
> >  			return NULL;
> > @@ -2404,7 +2404,7 @@ static void fault_dirty_shared_page(struct
> > vm_area_struct *vma,
> >  {
> >  	struct address_space *mapping;
> >  	bool dirtied;
> > -	bool page_mkwrite = vma->vm_ops && vma->vm_ops-
> > >page_mkwrite;
> > +	bool page_mkwrite = vma->vm_ops->page_mkwrite;
> >  
> >  	dirtied = set_page_dirty(page);
> >  	VM_BUG_ON_PAGE(PageAnon(page), page);
> > @@ -2648,7 +2648,7 @@ static int wp_pfn_shared(struct vm_fault *vmf)
> >  {
> >  	struct vm_area_struct *vma = vmf->vma;
> >  
> > -	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
> > +	if (vma->vm_ops->pfn_mkwrite) {
> >  		int ret;
> >  
> >  		pte_unmap_unlock(vmf->pte, vmf->ptl);
> > @@ -2669,7 +2669,7 @@ static int wp_page_shared(struct vm_fault *vmf)
> >  
> >  	get_page(vmf->page);
> >  
> > -	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
> > +	if (vma->vm_ops->page_mkwrite) {
> >  		int tmp;
> >  
> >  		pte_unmap_unlock(vmf->pte, vmf->ptl);
> > @@ -4439,7 +4439,7 @@ int __access_remote_vm(struct task_struct *tsk,
> > struct mm_struct *mm,
> >  			vma = find_vma(mm, addr);
> >  			if (!vma || vma->vm_start > addr)
> >  				break;
> > -			if (vma->vm_ops && vma->vm_ops->access)
> > +			if (vma->vm_ops->access)
> >  				ret = vma->vm_ops->access(vma, addr,
> > buf,
> >  							  len,
> > write);
> >  			if (ret <= 0)
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index 9ac49ef17b4e..f0fcf70bcec7 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -651,13 +651,13 @@ static int vma_replace_policy(struct
> > vm_area_struct *vma,
> >  	pr_debug("vma %lx-%lx/%lx vm_ops %p vm_file %p set_policy
> > %p\n",
> >  		 vma->vm_start, vma->vm_end, vma->vm_pgoff,
> >  		 vma->vm_ops, vma->vm_file,
> > -		 vma->vm_ops ? vma->vm_ops->set_policy : NULL);
> > +		 vma->vm_ops->set_policy);
> >  
> >  	new = mpol_dup(pol);
> >  	if (IS_ERR(new))
> >  		return PTR_ERR(new);
> >  
> > -	if (vma->vm_ops && vma->vm_ops->set_policy) {
> > +	if (vma->vm_ops->set_policy) {
> >  		err = vma->vm_ops->set_policy(vma, new);
> >  		if (err)
> >  			goto err_out;
> > @@ -845,7 +845,7 @@ static long do_get_mempolicy(int *policy,
> > nodemask_t *nmask,
> >  			up_read(&mm->mmap_sem);
> >  			return -EFAULT;
> >  		}
> > -		if (vma->vm_ops && vma->vm_ops->get_policy)
> > +		if (vma->vm_ops->get_policy)
> >  			pol = vma->vm_ops->get_policy(vma, addr);
> >  		else
> >  			pol = vma->vm_policy;
> > @@ -1617,7 +1617,7 @@ struct mempolicy *__get_vma_policy(struct
> > vm_area_struct *vma,
> >  	struct mempolicy *pol = NULL;
> >  
> >  	if (vma) {
> > -		if (vma->vm_ops && vma->vm_ops->get_policy) {
> > +		if (vma->vm_ops->get_policy) {
> >  			pol = vma->vm_ops->get_policy(vma, addr);
> >  		} else if (vma->vm_policy) {
> >  			pol = vma->vm_policy;
> > @@ -1663,7 +1663,7 @@ bool vma_policy_mof(struct vm_area_struct *vma)
> >  {
> >  	struct mempolicy *pol;
> >  
> > -	if (vma->vm_ops && vma->vm_ops->get_policy) {
> > +	if (vma->vm_ops->get_policy) {
> >  		bool ret = false;
> >  
> >  		pol = vma->vm_ops->get_policy(vma, vma->vm_start);
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index 527c17f31635..5adaf9f9b941 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -177,7 +177,7 @@ static struct vm_area_struct *remove_vma(struct
> > vm_area_struct *vma)
> >  	struct vm_area_struct *next = vma->vm_next;
> >  
> >  	might_sleep();
> > -	if (vma->vm_ops && vma->vm_ops->close)
> > +	if (vma->vm_ops->close)
> >  		vma->vm_ops->close(vma);
> >  	if (vma->vm_file)
> >  		fput(vma->vm_file);
> > @@ -998,7 +998,7 @@ static inline int is_mergeable_vma(struct
> > vm_area_struct *vma,
> >  		return 0;
> >  	if (vma->vm_file != file)
> >  		return 0;
> > -	if (vma->vm_ops && vma->vm_ops->close)
> > +	if (vma->vm_ops->close)
> >  		return 0;
> >  	if (!is_mergeable_vm_userfaultfd_ctx(vma,
> > vm_userfaultfd_ctx))
> >  		return 0;
> > @@ -1638,7 +1638,7 @@ int vma_wants_writenotify(struct vm_area_struct
> > *vma, pgprot_t vm_page_prot)
> >  		return 0;
> >  
> >  	/* The backer wishes to know when pages are first written
> > to? */
> > -	if (vm_ops && (vm_ops->page_mkwrite || vm_ops->pfn_mkwrite))
> > +	if (vm_ops->page_mkwrite || vm_ops->pfn_mkwrite)
> >  		return 1;
> >  
> >  	/* The open routine did something to the protections that
> > pgprot_modify
> > @@ -2624,7 +2624,7 @@ int __split_vma(struct mm_struct *mm, struct
> > vm_area_struct *vma,
> >  	struct vm_area_struct *new;
> >  	int err;
> >  
> > -	if (vma->vm_ops && vma->vm_ops->split) {
> > +	if (vma->vm_ops->split) {
> >  		err = vma->vm_ops->split(vma, addr);
> >  		if (err)
> >  			return err;
> > @@ -2657,7 +2657,7 @@ int __split_vma(struct mm_struct *mm, struct
> > vm_area_struct *vma,
> >  	if (new->vm_file)
> >  		get_file(new->vm_file);
> >  
> > -	if (new->vm_ops && new->vm_ops->open)
> > +	if (new->vm_ops->open)
> >  		new->vm_ops->open(new);
> >  
> >  	if (new_below)
> > @@ -2671,7 +2671,7 @@ int __split_vma(struct mm_struct *mm, struct
> > vm_area_struct *vma,
> >  		return 0;
> >  
> >  	/* Clean everything up if vma_adjust failed. */
> > -	if (new->vm_ops && new->vm_ops->close)
> > +	if (new->vm_ops->close)
> >  		new->vm_ops->close(new);
> >  	if (new->vm_file)
> >  		fput(new->vm_file);
> > @@ -3232,7 +3232,7 @@ struct vm_area_struct *copy_vma(struct
> > vm_area_struct **vmap,
> >  			goto out_free_mempol;
> >  		if (new_vma->vm_file)
> >  			get_file(new_vma->vm_file);
> > -		if (new_vma->vm_ops && new_vma->vm_ops->open)
> > +		if (new_vma->vm_ops->open)
> >  			new_vma->vm_ops->open(new_vma);
> >  		vma_link(mm, new_vma, prev, rb_link, rb_parent);
> >  		*need_rmap_locks = false;
> > diff --git a/mm/mremap.c b/mm/mremap.c
> > index 5c2e18505f75..7ab222c283de 100644
> > --- a/mm/mremap.c
> > +++ b/mm/mremap.c
> > @@ -302,7 +302,7 @@ static unsigned long move_vma(struct
> > vm_area_struct *vma,
> >  				     need_rmap_locks);
> >  	if (moved_len < old_len) {
> >  		err = -ENOMEM;
> > -	} else if (vma->vm_ops && vma->vm_ops->mremap) {
> > +	} else if (vma->vm_ops->mremap) {
> >  		err = vma->vm_ops->mremap(new_vma);
> >  	}
> >  
> > diff --git a/mm/nommu.c b/mm/nommu.c
> > index f00f209833ab..73f66e81cfb0 100644
> > --- a/mm/nommu.c
> > +++ b/mm/nommu.c
> > @@ -764,7 +764,7 @@ static void delete_vma_from_mm(struct
> > vm_area_struct *vma)
> >   */
> >  static void delete_vma(struct mm_struct *mm, struct vm_area_struct
> > *vma)
> >  {
> > -	if (vma->vm_ops && vma->vm_ops->close)
> > +	if (vma->vm_ops->close)
> >  		vma->vm_ops->close(vma);
> >  	if (vma->vm_file)
> >  		fput(vma->vm_file);
> > @@ -1496,7 +1496,7 @@ int split_vma(struct mm_struct *mm, struct
> > vm_area_struct *vma,
> >  		region->vm_pgoff = new->vm_pgoff += npages;
> >  	}
> >  
> > -	if (new->vm_ops && new->vm_ops->open)
> > +	if (new->vm_ops->open)
> >  		new->vm_ops->open(new);
> >  
> >  	delete_vma_from_mm(vma);
> 
> Today's -next on Apalis T30 [1] gives the following error upon boot:
> 
> [   16.147496] Unable to handle kernel NULL pointer dereference at
> virtual address 0000002c
> [   16.156152] pgd = 843045af
> [   16.158986] [0000002c] *pgd=facd9831
> [   16.162578] Internal error: Oops: 17 [#1] PREEMPT SMP ARM
> [   16.167970] Modules linked in:
> [   16.171034] CPU: 2 PID: 442 Comm: polkitd Not tainted 4.18.0-rc5-
> next-20180716-dirty #75
> [   16.179111] Hardware name: NVIDIA Tegra SoC (Flattened Device Tree)
> [   16.185382] PC is at show_map_vma.constprop.3+0xac/0x158
> [   16.190686] LR is at show_map_vma.constprop.3+0xa8/0x158
> [   16.195989] pc : [<c02c4900>]    lr : [<c02c48fc>]    psr: 800e0013
> [   16.202243] sp : ec02de60  ip : 000003ce  fp : c0f09a3c
> [   16.207457] r10: ec02df78  r9 : 00000000  r8 : 00000000
> [   16.212672] r7 : 00000000  r6 : eda8ec48  r5 : 00000000  r4 :
> c0f09a3c
> [   16.219188] r3 : 00000000  r2 : ed1df000  r1 : 00000020  r0 :
> eda8ec48
> [   16.225705] Flags: Nzcv  IRQs on  FIQs on  Mode SVC_32  ISA
> ARM  Segment none
> [   16.232829] Control: 10c5387d  Table: ac01804a  DAC: 00000051
> [   16.238573] Process polkitd (pid: 442, stack limit = 0xc0e83ce5)
> [   16.244572] Stack: (0xec02de60 to 0xec02e000)
> [   16.248928] de60: 00000000 00000000 00000000 00000000 eda8ec48
> eda8ec48 c0f09a3c 000003a6
> [   16.257097] de80: ecf46300 00000096 00000000 c02c4efc eda8ec48
> 00000000 000003a6 c0289908
> [   16.265287] dea0: 0000000c eda8ec78 ecf46300 000003f4 00081114
> eda8ec60 00000000 c0f04c48
> [   16.273482] dec0: c028956c 00000400 ec02df78 00000000 00081108
> 00000400 00000000 c0263b20
> [   16.281671] dee0: 5b4c9a7c 0ee6b280 000039ea 00000000 c0f04c48
> 8bb3ec56 c0f04c48 be8c7a00
> [   16.289853] df00: ecf46308 00000000 000007ff c0f04c48 00000001
> 00000000 00000000 00000000
> [   16.298037] df20: 00000000 8bb3ec56 000039ea 8bb3ec56 ecf46300
> 00081108 00000400 ec02df78
> [   16.306210] df40: 00000000 00081108 00000400 c0263cdc c0f04c48
> b686ac78 000005e8 c0f04c48
> [   16.314381] df60: ecf46303 00002400 00000000 ecf46300 00081108
> c02641c0 00002400 00000000
> [   16.322549] df80: 00000000 8bb3ec56 00022698 b686ac78 000005e8
> 00000003 c0101204 ec02c000
> [   16.330718] dfa0: 00000003 c0101000 00022698 b686ac78 00000009
> 00081108 00000400 000000c2
> [   16.338886] dfc0: 00022698 b686ac78 000005e8 00000003 0000004b
> be8c7af4 00000000 00000000
> [   16.347053] dfe0: 0004d1b2 be8c7a84 b686b94c b686ac98 000e0010
> 00000009 00000000 00000000
> [   16.355237] [<c02c4900>] (show_map_vma.constprop.3) from
> [<c02c4efc>] (show_pid_map+0x10/0x34)  
> [   16.363846] [<c02c4efc>] (show_pid_map) from [<c0289908>]
> (seq_read+0x39c/0x4f4)
> [   16.371264] [<c0289908>] (seq_read) from [<c0263b20>]
> (__vfs_read+0x2c/0x15c)
> [   16.378401] [<c0263b20>] (__vfs_read) from [<c0263cdc>]
> (vfs_read+0x8c/0x110)
> [   16.385546] [<c0263cdc>] (vfs_read) from [<c02641c0>]
> (ksys_read+0x4c/0xac)
> [   16.392519] [<c02641c0>] (ksys_read) from [<c0101000>]
> (ret_fast_syscall+0x0/0x54)
> [   16.400083] Exception stack(0xec02dfa8 to 0xec02dff0)
> [   16.405135] dfa0:                   00022698 b686ac78 00000009
> 00081108 00000400 000000c2
> [   16.413311] dfc0: 00022698 b686ac78 000005e8 00000003 0000004b
> be8c7af4 00000000 00000000
> [   16.421485] dfe0: 0004d1b2 be8c7a84 b686b94c b686ac98
> [   16.426542] Code: e1cd80f0 e5947020 ebfffb4f e5943048 (e593302c)
> [   16.432734] ---[ end trace 5dbf91c64da6bd91 ]---
> 
> Reverting this makes it behave as expected again. Anybody knows what is
> going on?

Could you check if this fixup helps?

diff --git a/arch/arm/kernel/process.c b/arch/arm/kernel/process.c
index 225d1c58d2de..553262999564 100644
--- a/arch/arm/kernel/process.c
+++ b/arch/arm/kernel/process.c
@@ -334,6 +334,7 @@ static struct vm_area_struct gate_vma = {
 	.vm_start	= 0xffff0000,
 	.vm_end		= 0xffff0000 + PAGE_SIZE,
 	.vm_flags	= VM_READ | VM_EXEC | VM_MAYREAD | VM_MAYEXEC,
+	.vm_ops		= &dummy_vm_ops,
 };
 
 static int __init gate_vma_init(void)
-- 
 Kirill A. Shutemov
