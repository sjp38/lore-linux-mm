Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A0F1B6B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 03:59:48 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r133so4937624pgr.6
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 00:59:48 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y79si1928131pfb.324.2017.08.29.00.59.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 00:59:46 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7T7x6ui058815
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 03:59:46 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cmx61xq7v-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 03:59:45 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 29 Aug 2017 08:59:40 +0100
Subject: Re: [PATCH v2 14/20] mm: Provide speculative fault infrastructure
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1503007519-26777-15-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170827001823.n5wgkfq36z6snvf2@node.shutemov.name>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 29 Aug 2017 09:59:30 +0200
MIME-Version: 1.0
In-Reply-To: <20170827001823.n5wgkfq36z6snvf2@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <507e79d5-59df-c5b5-106d-970c9353d9bc@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 27/08/2017 02:18, Kirill A. Shutemov wrote:
> On Fri, Aug 18, 2017 at 12:05:13AM +0200, Laurent Dufour wrote:
>> +/*
>> + * vm_normal_page() adds some processing which should be done while
>> + * hodling the mmap_sem.
>> + */
>> +int handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>> +			     unsigned int flags)
>> +{
>> +	struct vm_fault vmf = {
>> +		.address = address,
>> +	};
>> +	pgd_t *pgd;
>> +	p4d_t *p4d;
>> +	pud_t *pud;
>> +	pmd_t *pmd;
>> +	int dead, seq, idx, ret = VM_FAULT_RETRY;
>> +	struct vm_area_struct *vma;
>> +	struct mempolicy *pol;
>> +
>> +	/* Clear flags that may lead to release the mmap_sem to retry */
>> +	flags &= ~(FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_KILLABLE);
>> +	flags |= FAULT_FLAG_SPECULATIVE;
>> +
>> +	idx = srcu_read_lock(&vma_srcu);
>> +	vma = find_vma_srcu(mm, address);
>> +	if (!vma)
>> +		goto unlock;
>> +
>> +	/*
>> +	 * Validate the VMA found by the lockless lookup.
>> +	 */
>> +	dead = RB_EMPTY_NODE(&vma->vm_rb);
>> +	seq = raw_read_seqcount(&vma->vm_sequence); /* rmb <-> seqlock,vma_rb_erase() */
>> +	if ((seq & 1) || dead)
>> +		goto unlock;
>> +
>> +	/*
>> +	 * Can't call vm_ops service has we don't know what they would do
>> +	 * with the VMA.
>> +	 * This include huge page from hugetlbfs.
>> +	 */
>> +	if (vma->vm_ops)
>> +		goto unlock;
> 
> I think we need to have a way to white-list safe ->vm_ops.

Hi Kirill,
Yes this would be a good optimization done in a next step.

>> +
>> +	if (unlikely(!vma->anon_vma))
>> +		goto unlock;
> 
> It deserves a comment.

You're right I'll add it in the next version.
For the record, the root cause is that __anon_vma_prepare() requires the
mmap_sem to be held because vm_next and vm_prev must be safe.


>> +
>> +	vmf.vma_flags = READ_ONCE(vma->vm_flags);
>> +	vmf.vma_page_prot = READ_ONCE(vma->vm_page_prot);
>> +
>> +	/* Can't call userland page fault handler in the speculative path */
>> +	if (unlikely(vmf.vma_flags & VM_UFFD_MISSING))
>> +		goto unlock;
>> +
>> +	/*
>> +	 * MPOL_INTERLEAVE implies additional check in mpol_misplaced() which
>> +	 * are not compatible with the speculative page fault processing.
>> +	 */
>> +	pol = __get_vma_policy(vma, address);
>> +	if (!pol)
>> +		pol = get_task_policy(current);
>> +	if (pol && pol->mode == MPOL_INTERLEAVE)
>> +		goto unlock;
>> +
>> +	if (vmf.vma_flags & VM_GROWSDOWN || vmf.vma_flags & VM_GROWSUP)
>> +		/*
>> +		 * This could be detected by the check address against VMA's
>> +		 * boundaries but we want to trace it as not supported instead
>> +		 * of changed.
>> +		 */
>> +		goto unlock;
>> +
>> +	if (address < READ_ONCE(vma->vm_start)
>> +	    || READ_ONCE(vma->vm_end) <= address)
>> +		goto unlock;
>> +
>> +	/*
>> +	 * The three following checks are copied from access_error from
>> +	 * arch/x86/mm/fault.c
>> +	 */
>> +	if (!arch_vma_access_permitted(vma, flags & FAULT_FLAG_WRITE,
>> +				       flags & FAULT_FLAG_INSTRUCTION,
>> +				       flags & FAULT_FLAG_REMOTE))
>> +		goto unlock;
>> +
>> +	/* This is one is required to check that the VMA has write access set */
>> +	if (flags & FAULT_FLAG_WRITE) {
>> +		if (unlikely(!(vmf.vma_flags & VM_WRITE)))
>> +			goto unlock;
>> +	} else {
>> +		if (unlikely(!(vmf.vma_flags & (VM_READ | VM_EXEC | VM_WRITE))))
>> +			goto unlock;
>> +	}
>> +
>> +	/*
>> +	 * Do a speculative lookup of the PTE entry.
>> +	 */
>> +	local_irq_disable();
>> +	pgd = pgd_offset(mm, address);
>> +	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
>> +		goto out_walk;
>> +
>> +	p4d = p4d_alloc(mm, pgd, address);
>> +	if (p4d_none(*p4d) || unlikely(p4d_bad(*p4d)))
>> +		goto out_walk;
>> +
>> +	pud = pud_alloc(mm, p4d, address);
>> +	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
>> +		goto out_walk;
>> +
>> +	pmd = pmd_offset(pud, address);
>> +	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
>> +		goto out_walk;
>> +
>> +	/*
>> +	 * The above does not allocate/instantiate page-tables because doing so
>> +	 * would lead to the possibility of instantiating page-tables after
>> +	 * free_pgtables() -- and consequently leaking them.
>> +	 *
>> +	 * The result is that we take at least one !speculative fault per PMD
>> +	 * in order to instantiate it.
>> +	 */
> 
> 
> Doing all this job and just give up because we cannot allocate page tables
> looks very wasteful to me.
> 
> Have you considered to look how we can hand over from speculative to
> non-speculative path without starting from scratch (when possible)?

Not really, but as mentioned by Benjamin and Andy, this will require care
from the architecture code.
This may be a future optimization, but it will require guarantee from the
architecture code as well.

>> +	/* Transparent huge pages are not supported. */
>> +	if (unlikely(pmd_trans_huge(*pmd)))
>> +		goto out_walk;
> 
> That's looks like a blocker to me.
> 
> Is there any problem with making it supported (besides plain coding)?

To be honest, I can't remember why I added such a check, may be for safety
reason, but I need to double check that again. I'll do so and come back
later with a statement.

Thanks,
Laurent.

>> +
>> +	vmf.vma = vma;
>> +	vmf.pmd = pmd;
>> +	vmf.pgoff = linear_page_index(vma, address);
>> +	vmf.gfp_mask = __get_fault_gfp_mask(vma);
>> +	vmf.sequence = seq;
>> +	vmf.flags = flags;
>> +
>> +	local_irq_enable();
>> +
>> +	/*
>> +	 * We need to re-validate the VMA after checking the bounds, otherwise
>> +	 * we might have a false positive on the bounds.
>> +	 */
>> +	if (read_seqcount_retry(&vma->vm_sequence, seq))
>> +		goto unlock;
>> +
>> +	ret = handle_pte_fault(&vmf);
>> +
>> +unlock:
>> +	srcu_read_unlock(&vma_srcu, idx);
>> +	return ret;
>> +
>> +out_walk:
>> +	local_irq_enable();
>> +	goto unlock;
>> +}
>> +#endif /* __HAVE_ARCH_CALL_SPF */
>> +
>>  /*
>>   * By the time we get here, we already hold the mm semaphore
>>   *
>> -- 
>> 2.7.4
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
