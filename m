Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6B76B028D
	for <linux-mm@kvack.org>; Tue, 15 May 2018 09:09:24 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b192-v6so6000891wmb.1
        for <linux-mm@kvack.org>; Tue, 15 May 2018 06:09:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r133-v6sor114931wmg.25.2018.05.15.06.09.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 May 2018 06:09:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1523975611-15978-19-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com> <1523975611-15978-19-git-send-email-ldufour@linux.vnet.ibm.com>
From: vinayak menon <vinayakm.list@gmail.com>
Date: Tue, 15 May 2018 18:39:20 +0530
Message-ID: <CAOaiJ-nfC0hBup_XWqp2HNzAcDw8kRsfXM8Vxny3qnE3BG8q6A@mail.gmail.com>
Subject: Re: [PATCH v10 18/25] mm: provide speculative fault infrastructure
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, Balbir Singh <bsingharora@gmail.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, Vinayak Menon <vinmenon@codeaurora.org>

On Tue, Apr 17, 2018 at 8:03 PM, Laurent Dufour
<ldufour@linux.vnet.ibm.com> wrote:
>
> +#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
> +
> +#ifndef __HAVE_ARCH_PTE_SPECIAL
> +/* This is required by vm_normal_page() */
> +#error "Speculative page fault handler requires __HAVE_ARCH_PTE_SPECIAL"
> +#endif
> +
> +/*
> + * vm_normal_page() adds some processing which should be done while
> + * hodling the mmap_sem.
> + */
> +int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
> +                              unsigned int flags)
> +{
> +       struct vm_fault vmf = {
> +               .address = address,
> +       };
> +       pgd_t *pgd, pgdval;
> +       p4d_t *p4d, p4dval;
> +       pud_t pudval;
> +       int seq, ret = VM_FAULT_RETRY;
> +       struct vm_area_struct *vma;
> +
> +       /* Clear flags that may lead to release the mmap_sem to retry */
> +       flags &= ~(FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_KILLABLE);
> +       flags |= FAULT_FLAG_SPECULATIVE;
> +
> +       vma = get_vma(mm, address);
> +       if (!vma)
> +               return ret;
> +
> +       seq = raw_read_seqcount(&vma->vm_sequence); /* rmb <-> seqlock,vma_rb_erase() */
> +       if (seq & 1)
> +               goto out_put;
> +
> +       /*
> +        * Can't call vm_ops service has we don't know what they would do
> +        * with the VMA.
> +        * This include huge page from hugetlbfs.
> +        */
> +       if (vma->vm_ops)
> +               goto out_put;
> +
> +       /*
> +        * __anon_vma_prepare() requires the mmap_sem to be held
> +        * because vm_next and vm_prev must be safe. This can't be guaranteed
> +        * in the speculative path.
> +        */
> +       if (unlikely(!vma->anon_vma))
> +               goto out_put;
> +
> +       vmf.vma_flags = READ_ONCE(vma->vm_flags);
> +       vmf.vma_page_prot = READ_ONCE(vma->vm_page_prot);
> +
> +       /* Can't call userland page fault handler in the speculative path */
> +       if (unlikely(vmf.vma_flags & VM_UFFD_MISSING))
> +               goto out_put;
> +
> +       if (vmf.vma_flags & VM_GROWSDOWN || vmf.vma_flags & VM_GROWSUP)
> +               /*
> +                * This could be detected by the check address against VMA's
> +                * boundaries but we want to trace it as not supported instead
> +                * of changed.
> +                */
> +               goto out_put;
> +
> +       if (address < READ_ONCE(vma->vm_start)
> +           || READ_ONCE(vma->vm_end) <= address)
> +               goto out_put;
> +
> +       if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
> +                                      flags & FAULT_FLAG_INSTRUCTION,
> +                                      flags & FAULT_FLAG_REMOTE)) {
> +               ret = VM_FAULT_SIGSEGV;
> +               goto out_put;
> +       }
> +
> +       /* This is one is required to check that the VMA has write access set */
> +       if (flags & FAULT_FLAG_WRITE) {
> +               if (unlikely(!(vmf.vma_flags & VM_WRITE))) {
> +                       ret = VM_FAULT_SIGSEGV;
> +                       goto out_put;
> +               }
> +       } else if (unlikely(!(vmf.vma_flags & (VM_READ|VM_EXEC|VM_WRITE)))) {
> +               ret = VM_FAULT_SIGSEGV;
> +               goto out_put;
> +       }
> +
> +       if (IS_ENABLED(CONFIG_NUMA)) {
> +               struct mempolicy *pol;
> +
> +               /*
> +                * MPOL_INTERLEAVE implies additional checks in
> +                * mpol_misplaced() which are not compatible with the
> +                *speculative page fault processing.
> +                */
> +               pol = __get_vma_policy(vma, address);


This gives a compile time error when CONFIG_NUMA is disabled, as there
is no definition for
__get_vma_policy.


> +               if (!pol)
> +                       pol = get_task_policy(current);
> +               if (pol && pol->mode == MPOL_INTERLEAVE)
> +                       goto out_put;
> +       }
> +
> +       /*
> +        * Do a speculative lookup of the PTE entry.
> +        */
> +       local_irq_disable();
> +       pgd = pgd_offset(mm, address);
> +       pgdval = READ_ONCE(*pgd);
> +       if (pgd_none(pgdval) || unlikely(pgd_bad(pgdval)))
> +               goto out_walk;
> +
> +       p4d = p4d_offset(pgd, address);
> +       p4dval = READ_ONCE(*p4d);
> +       if (p4d_none(p4dval) || unlikely(p4d_bad(p4dval)))
> +               goto out_walk;
> +
> +       vmf.pud = pud_offset(p4d, address);
> +       pudval = READ_ONCE(*vmf.pud);
> +       if (pud_none(pudval) || unlikely(pud_bad(pudval)))
> +               goto out_walk;
> +
> +       /* Huge pages at PUD level are not supported. */
> +       if (unlikely(pud_trans_huge(pudval)))
> +               goto out_walk;
> +
> +       vmf.pmd = pmd_offset(vmf.pud, address);
> +       vmf.orig_pmd = READ_ONCE(*vmf.pmd);
> +       /*
> +        * pmd_none could mean that a hugepage collapse is in progress
> +        * in our back as collapse_huge_page() mark it before
> +        * invalidating the pte (which is done once the IPI is catched
> +        * by all CPU and we have interrupt disabled).
> +        * For this reason we cannot handle THP in a speculative way since we
> +        * can't safely indentify an in progress collapse operation done in our
> +        * back on that PMD.
> +        * Regarding the order of the following checks, see comment in
> +        * pmd_devmap_trans_unstable()
> +        */
> +       if (unlikely(pmd_devmap(vmf.orig_pmd) ||
> +                    pmd_none(vmf.orig_pmd) || pmd_trans_huge(vmf.orig_pmd) ||
> +                    is_swap_pmd(vmf.orig_pmd)))
> +               goto out_walk;
> +
> +       /*
> +        * The above does not allocate/instantiate page-tables because doing so
> +        * would lead to the possibility of instantiating page-tables after
> +        * free_pgtables() -- and consequently leaking them.
> +        *
> +        * The result is that we take at least one !speculative fault per PMD
> +        * in order to instantiate it.
> +        */
> +
> +       vmf.pte = pte_offset_map(vmf.pmd, address);
> +       vmf.orig_pte = READ_ONCE(*vmf.pte);
> +       barrier(); /* See comment in handle_pte_fault() */
> +       if (pte_none(vmf.orig_pte)) {
> +               pte_unmap(vmf.pte);
> +               vmf.pte = NULL;
> +       }
> +
> +       vmf.vma = vma;
> +       vmf.pgoff = linear_page_index(vma, address);
> +       vmf.gfp_mask = __get_fault_gfp_mask(vma);
> +       vmf.sequence = seq;
> +       vmf.flags = flags;
> +
> +       local_irq_enable();
> +
> +       /*
> +        * We need to re-validate the VMA after checking the bounds, otherwise
> +        * we might have a false positive on the bounds.
> +        */
> +       if (read_seqcount_retry(&vma->vm_sequence, seq))
> +               goto out_put;
> +
> +       mem_cgroup_oom_enable();
> +       ret = handle_pte_fault(&vmf);
> +       mem_cgroup_oom_disable();
> +
> +       put_vma(vma);
> +
> +       /*
> +        * The task may have entered a memcg OOM situation but
> +        * if the allocation error was handled gracefully (no
> +        * VM_FAULT_OOM), there is no need to kill anything.
> +        * Just clean up the OOM state peacefully.
> +        */
> +       if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
> +               mem_cgroup_oom_synchronize(false);
> +       return ret;
> +
> +out_walk:
> +       local_irq_enable();
> +out_put:
> +       put_vma(vma);
> +       return ret;
> +}
> +#endif /* CONFIG_SPECULATIVE_PAGE_FAULT */
> +
>  /*
>   * By the time we get here, we already hold the mm semaphore
>   *
> --
> 2.7.4
>
