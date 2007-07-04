Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id l647WHpT625620
	for <linux-mm@kvack.org>; Wed, 4 Jul 2007 07:32:17 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l647WHPM278692
	for <linux-mm@kvack.org>; Wed, 4 Jul 2007 09:32:17 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l647WGlu002480
	for <linux-mm@kvack.org>; Wed, 4 Jul 2007 09:32:17 +0200
Subject: Re: [patch 5/5] s390 tlb flush fix.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <Pine.LNX.4.64.0707031921270.8155@blonde.wat.veritas.com>
References: <20070703111822.418649776@de.ibm.com>
	 <20070703121229.180281096@de.ibm.com>
	 <Pine.LNX.4.64.0707031921270.8155@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Wed, 04 Jul 2007 09:34:34 +0200
Message-Id: <1183534474.1208.20.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: akpm@linux-foundation.org, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-07-03 at 19:58 +0100, Hugh Dickins wrote:
> On Tue, 3 Jul 2007, Martin Schwidefsky wrote:
> > +
> > +static inline struct mmu_gather *tlb_gather_mmu(struct mm_struct *mm,
> > +						unsigned int full_mm_flush)
> > +{
> > +	struct mmu_gather *tlb = &get_cpu_var(mmu_gathers);
> > +
> > +	tlb->mm = mm;
> > +	tlb->fullmm = full_mm_flush || (num_online_cpus() == 1) ||
> > +		(atomic_read(&mm->mm_users) <= 1);
> > +	tlb->nr_ptes = 0;
> > +	tlb->nr_pmds = TLB_NR_PTRS;
> > +	if (tlb->fullmm)
> > +		__tlb_flush_mm(mm);
> > +	return tlb;
> > +}
> 
> I'm afraid that mm_users test (and probably some of your other
> mm_users tests) is not good: because this also gets called when
> a file is truncated while it is mapped - the active mm at that
> time is likely not to be one of the mm_users.  (Do any other
> arches use mm_users in that way?  No: that should be a warning.)

Good catch, that would have caused me some headache. So I need to add a
current->active_mm==mm check if mm_users==1.

> You might do better to make more use of cpu_vm_mask (though I
> didn't see where any bits get cleared from it on s390 at present).

We don't clear any of the bits in cpu_vm_mask. I though about it for a
while and got tangled in race conditions. The cpu_vm_mask optimization
works for short-lived processes which always executed on the same cpu.

> Though it seems sensible to aim for one TLB flush at the beginning
> as you're doing, that's not what other arches do (some have to
> worry about speculative execution, but you don't?), and it
> worries me that you're taking s390 further away into its own
> implementation: which you're surely entitled to do, but then
> we're more likely to screw you over by mistake in future.

We do not have to worry about speculative execution because s390 uses
special instruction to do user access (mvcs, mvcp and mvcos) and the
kernel has its own address space. The compiler doesn't know about these
instruction and cannot "accidentally" access a user space address over
the user page table when it shouldn't.

> Is there perhaps another architecture whose procedures you
> can copy?  Changing a pte while another cpu is accessing it
> is not a problem unique to s390.

No, I don't think so. s390 is quite unique with the restriction that you
may not do a set_pte_at .. flush_tlb_xxx while a pte might get accessed
by a different cpu.

> Patches 1-4 looked fine to me, but I believe this 5/5
> is the rationale behind all of them.

Yes, indeed the tlb flush fix and the 1K/2K page tables are my reasons
for all these patches.

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
