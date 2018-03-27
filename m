Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 625C06B000A
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 17:45:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id k17so173411pfj.10
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 14:45:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w11sor655477pgq.419.2018.03.27.14.45.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 14:45:36 -0700 (PDT)
Date: Tue, 27 Mar 2018 14:45:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v9 08/24] mm: Protect VMA modifications using VMA sequence
 count
In-Reply-To: <1520963994-28477-9-git-send-email-ldufour@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1803271441290.38095@chino.kir.corp.google.com>
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com> <1520963994-28477-9-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, 13 Mar 2018, Laurent Dufour wrote:

> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 65ae54659833..a2d9c87b7b0b 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1136,8 +1136,11 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  					goto out_mm;
>  				}
>  				for (vma = mm->mmap; vma; vma = vma->vm_next) {
> -					vma->vm_flags &= ~VM_SOFTDIRTY;
> +					vm_write_begin(vma);
> +					WRITE_ONCE(vma->vm_flags,
> +						   vma->vm_flags & ~VM_SOFTDIRTY);
>  					vma_set_page_prot(vma);
> +					vm_write_end(vma);
>  				}
>  				downgrade_write(&mm->mmap_sem);
>  				break;
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index cec550c8468f..b8212ba17695 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -659,8 +659,11 @@ int dup_userfaultfd(struct vm_area_struct *vma, struct list_head *fcs)
>  
>  	octx = vma->vm_userfaultfd_ctx.ctx;
>  	if (!octx || !(octx->features & UFFD_FEATURE_EVENT_FORK)) {
> +		vm_write_begin(vma);
>  		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
> -		vma->vm_flags &= ~(VM_UFFD_WP | VM_UFFD_MISSING);
> +		WRITE_ONCE(vma->vm_flags,
> +			   vma->vm_flags & ~(VM_UFFD_WP | VM_UFFD_MISSING));
> +		vm_write_end(vma);
>  		return 0;
>  	}
>  

In several locations in this patch vm_write_begin(vma) -> 
vm_write_end(vma) is nesting things other than vma->vm_flags, 
vma->vm_policy, etc.  I think it's better to do vm_write_end(vma) as soon 
as the members that the seqcount protects are modified.  In other words, 
this isn't offering protection for vma->vm_userfaultfd_ctx.  There are 
several examples of this in the patch.

> @@ -885,8 +888,10 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
>  			vma = prev;
>  		else
>  			prev = vma;
> -		vma->vm_flags = new_flags;
> +		vm_write_begin(vma);
> +		WRITE_ONCE(vma->vm_flags, new_flags);
>  		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
> +		vm_write_end(vma);
>  	}
>  	up_write(&mm->mmap_sem);
>  	mmput(mm);
> @@ -1434,8 +1439,10 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
>  		 * the next vma was merged into the current one and
>  		 * the current one has not been updated yet.
>  		 */
> -		vma->vm_flags = new_flags;
> +		vm_write_begin(vma);
> +		WRITE_ONCE(vma->vm_flags, new_flags);
>  		vma->vm_userfaultfd_ctx.ctx = ctx;
> +		vm_write_end(vma);
>  
>  	skip:
>  		prev = vma;
> @@ -1592,8 +1599,10 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
>  		 * the next vma was merged into the current one and
>  		 * the current one has not been updated yet.
>  		 */
> -		vma->vm_flags = new_flags;
> +		vm_write_begin(vma);
> +		WRITE_ONCE(vma->vm_flags, new_flags);
>  		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
> +		vm_write_end(vma);
>  
>  	skip:
>  		prev = vma;
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index b7e2268dfc9a..32314e9e48dd 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1006,6 +1006,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	if (mm_find_pmd(mm, address) != pmd)
>  		goto out;
>  
> +	vm_write_begin(vma);
>  	anon_vma_lock_write(vma->anon_vma);
>  
>  	pte = pte_offset_map(pmd, address);
> @@ -1041,6 +1042,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  		pmd_populate(mm, pmd, pmd_pgtable(_pmd));
>  		spin_unlock(pmd_ptl);
>  		anon_vma_unlock_write(vma->anon_vma);
> +		vm_write_end(vma);
>  		result = SCAN_FAIL;
>  		goto out;
>  	}
> @@ -1075,6 +1077,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	set_pmd_at(mm, address, pmd, _pmd);
>  	update_mmu_cache_pmd(vma, address, pmd);
>  	spin_unlock(pmd_ptl);
> +	vm_write_end(vma);
>  
>  	*hpage = NULL;
>  
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 4d3c922ea1a1..e328f7ab5942 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -184,7 +184,9 @@ static long madvise_behavior(struct vm_area_struct *vma,
>  	/*
>  	 * vm_flags is protected by the mmap_sem held in write mode.
>  	 */
> -	vma->vm_flags = new_flags;
> +	vm_write_begin(vma);
> +	WRITE_ONCE(vma->vm_flags, new_flags);
> +	vm_write_end(vma);
>  out:
>  	return error;
>  }
> @@ -450,9 +452,11 @@ static void madvise_free_page_range(struct mmu_gather *tlb,
>  		.private = tlb,
>  	};
>  
> +	vm_write_begin(vma);
>  	tlb_start_vma(tlb, vma);
>  	walk_page_range(addr, end, &free_walk);
>  	tlb_end_vma(tlb, vma);
> +	vm_write_end(vma);
>  }
>  
>  static int madvise_free_single_vma(struct vm_area_struct *vma,
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index e0e706f0b34e..2632c6f93b63 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -380,8 +380,11 @@ void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
>  	struct vm_area_struct *vma;
>  
>  	down_write(&mm->mmap_sem);
> -	for (vma = mm->mmap; vma; vma = vma->vm_next)
> +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +		vm_write_begin(vma);
>  		mpol_rebind_policy(vma->vm_policy, new);
> +		vm_write_end(vma);
> +	}
>  	up_write(&mm->mmap_sem);
>  }
>  
> @@ -554,9 +557,11 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
>  {
>  	int nr_updated;
>  
> +	vm_write_begin(vma);
>  	nr_updated = change_protection(vma, addr, end, PAGE_NONE, 0, 1);
>  	if (nr_updated)
>  		count_vm_numa_events(NUMA_PTE_UPDATES, nr_updated);
> +	vm_write_end(vma);
>  
>  	return nr_updated;
>  }
> @@ -657,6 +662,7 @@ static int vma_replace_policy(struct vm_area_struct *vma,
>  	if (IS_ERR(new))
>  		return PTR_ERR(new);
>  
> +	vm_write_begin(vma);
>  	if (vma->vm_ops && vma->vm_ops->set_policy) {
>  		err = vma->vm_ops->set_policy(vma, new);
>  		if (err)
> @@ -664,11 +670,17 @@ static int vma_replace_policy(struct vm_area_struct *vma,
>  	}
>  
>  	old = vma->vm_policy;
> -	vma->vm_policy = new; /* protected by mmap_sem */
> +	/*
> +	 * The speculative page fault handler access this field without
> +	 * hodling the mmap_sem.
> +	 */

"The speculative page fault handler accesses this field without holding 
vma->vm_mm->mmap_sem"

> +	WRITE_ONCE(vma->vm_policy,  new);
> +	vm_write_end(vma);
>  	mpol_put(old);
>  
>  	return 0;
>   err_out:
> +	vm_write_end(vma);
>  	mpol_put(new);
>  	return err;
>  }

Wait, doesn't vma_dup_policy() also need to protect dst->vm_policy?

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2121,7 +2121,9 @@ int vma_dup_policy(struct vm_area_struct *src, struct vm_area_struct *dst)
 
 	if (IS_ERR(pol))
 		return PTR_ERR(pol);
-	dst->vm_policy = pol;
+	vm_write_begin(dst);
+	WRITE_ONCE(dst->vm_policy, pol);
+	vm_write_end(dst);
 	return 0;
 }
 
