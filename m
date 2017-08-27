Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 172EF2808AE
	for <linux-mm@kvack.org>; Sat, 26 Aug 2017 20:18:35 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 136so4473871wmm.11
        for <linux-mm@kvack.org>; Sat, 26 Aug 2017 17:18:35 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id z5si10937277edb.39.2017.08.26.17.18.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Aug 2017 17:18:33 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id r13so1009770wmf.4
        for <linux-mm@kvack.org>; Sat, 26 Aug 2017 17:18:33 -0700 (PDT)
Date: Sun, 27 Aug 2017 03:18:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 14/20] mm: Provide speculative fault infrastructure
Message-ID: <20170827001823.n5wgkfq36z6snvf2@node.shutemov.name>
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1503007519-26777-15-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1503007519-26777-15-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Fri, Aug 18, 2017 at 12:05:13AM +0200, Laurent Dufour wrote:
> +/*
> + * vm_normal_page() adds some processing which should be done while
> + * hodling the mmap_sem.
> + */
> +int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
> +			     unsigned int flags)
> +{
> +	struct vm_fault vmf = {
> +		.address = address,
> +	};
> +	pgd_t *pgd;
> +	p4d_t *p4d;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	int dead, seq, idx, ret = VM_FAULT_RETRY;
> +	struct vm_area_struct *vma;
> +	struct mempolicy *pol;
> +
> +	/* Clear flags that may lead to release the mmap_sem to retry */
> +	flags &= ~(FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_KILLABLE);
> +	flags |= FAULT_FLAG_SPECULATIVE;
> +
> +	idx = srcu_read_lock(&vma_srcu);
> +	vma = find_vma_srcu(mm, address);
> +	if (!vma)
> +		goto unlock;
> +
> +	/*
> +	 * Validate the VMA found by the lockless lookup.
> +	 */
> +	dead = RB_EMPTY_NODE(&vma->vm_rb);
> +	seq = raw_read_seqcount(&vma->vm_sequence); /* rmb <-> seqlock,vma_rb_erase() */
> +	if ((seq & 1) || dead)
> +		goto unlock;
> +
> +	/*
> +	 * Can't call vm_ops service has we don't know what they would do
> +	 * with the VMA.
> +	 * This include huge page from hugetlbfs.
> +	 */
> +	if (vma->vm_ops)
> +		goto unlock;

I think we need to have a way to white-list safe ->vm_ops.

> +
> +	if (unlikely(!vma->anon_vma))
> +		goto unlock;

It deserves a comment.

> +
> +	vmf.vma_flags = READ_ONCE(vma->vm_flags);
> +	vmf.vma_page_prot = READ_ONCE(vma->vm_page_prot);
> +
> +	/* Can't call userland page fault handler in the speculative path */
> +	if (unlikely(vmf.vma_flags & VM_UFFD_MISSING))
> +		goto unlock;
> +
> +	/*
> +	 * MPOL_INTERLEAVE implies additional check in mpol_misplaced() which
> +	 * are not compatible with the speculative page fault processing.
> +	 */
> +	pol = __get_vma_policy(vma, address);
> +	if (!pol)
> +		pol = get_task_policy(current);
> +	if (pol && pol->mode == MPOL_INTERLEAVE)
> +		goto unlock;
> +
> +	if (vmf.vma_flags & VM_GROWSDOWN || vmf.vma_flags & VM_GROWSUP)
> +		/*
> +		 * This could be detected by the check address against VMA's
> +		 * boundaries but we want to trace it as not supported instead
> +		 * of changed.
> +		 */
> +		goto unlock;
> +
> +	if (address < READ_ONCE(vma->vm_start)
> +	    || READ_ONCE(vma->vm_end) <= address)
> +		goto unlock;
> +
> +	/*
> +	 * The three following checks are copied from access_error from
> +	 * arch/x86/mm/fault.c
> +	 */
> +	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
> +				       flags & FAULT_FLAG_INSTRUCTION,
> +				       flags & FAULT_FLAG_REMOTE))
> +		goto unlock;
> +
> +	/* This is one is required to check that the VMA has write access set */
> +	if (flags & FAULT_FLAG_WRITE) {
> +		if (unlikely(!(vmf.vma_flags & VM_WRITE)))
> +			goto unlock;
> +	} else {
> +		if (unlikely(!(vmf.vma_flags & (VM_READ | VM_EXEC | VM_WRITE))))
> +			goto unlock;
> +	}
> +
> +	/*
> +	 * Do a speculative lookup of the PTE entry.
> +	 */
> +	local_irq_disable();
> +	pgd = pgd_offset(mm, address);
> +	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
> +		goto out_walk;
> +
> +	p4d = p4d_alloc(mm, pgd, address);
> +	if (p4d_none(*p4d) || unlikely(p4d_bad(*p4d)))
> +		goto out_walk;
> +
> +	pud = pud_alloc(mm, p4d, address);
> +	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
> +		goto out_walk;
> +
> +	pmd = pmd_offset(pud, address);
> +	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
> +		goto out_walk;
> +
> +	/*
> +	 * The above does not allocate/instantiate page-tables because doing so
> +	 * would lead to the possibility of instantiating page-tables after
> +	 * free_pgtables() -- and consequently leaking them.
> +	 *
> +	 * The result is that we take at least one !speculative fault per PMD
> +	 * in order to instantiate it.
> +	 */


Doing all this job and just give up because we cannot allocate page tables
looks very wasteful to me.

Have you considered to look how we can hand over from speculative to
non-speculative path without starting from scratch (when possible)?

> +	/* Transparent huge pages are not supported. */
> +	if (unlikely(pmd_trans_huge(*pmd)))
> +		goto out_walk;

That's looks like a blocker to me.

Is there any problem with making it supported (besides plain coding)?

> +
> +	vmf.vma = vma;
> +	vmf.pmd = pmd;
> +	vmf.pgoff = linear_page_index(vma, address);
> +	vmf.gfp_mask = __get_fault_gfp_mask(vma);
> +	vmf.sequence = seq;
> +	vmf.flags = flags;
> +
> +	local_irq_enable();
> +
> +	/*
> +	 * We need to re-validate the VMA after checking the bounds, otherwise
> +	 * we might have a false positive on the bounds.
> +	 */
> +	if (read_seqcount_retry(&vma->vm_sequence, seq))
> +		goto unlock;
> +
> +	ret = handle_pte_fault(&vmf);
> +
> +unlock:
> +	srcu_read_unlock(&vma_srcu, idx);
> +	return ret;
> +
> +out_walk:
> +	local_irq_enable();
> +	goto unlock;
> +}
> +#endif /* __HAVE_ARCH_CALL_SPF */
> +
>  /*
>   * By the time we get here, we already hold the mm semaphore
>   *
> -- 
> 2.7.4
> 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
