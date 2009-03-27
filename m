Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2C5226B003D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 01:31:52 -0400 (EDT)
Subject: Re: tlb_gather_mmu() and semantics of "fullmm"
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20090326.220409.72126250.davem@davemloft.net>
References: <1238043674.25062.823.camel@pasglop>
	 <Pine.LNX.4.64.0903261232060.27412@blonde.anvils>
	 <1238106824.16498.7.camel@pasglop>
	 <20090326.220409.72126250.davem@davemloft.net>
Content-Type: text/plain
Date: Fri, 27 Mar 2009 16:38:07 +1100
Message-Id: <1238132287.20197.47.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: hugh@veritas.com, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, npiggin@suse.de, zach@vmware.com, jeremy@goop.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-03-26 at 22:04 -0700, David Miller wrote:
> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Fri, 27 Mar 2009 09:33:44 +1100
> 
> > > I'd be surprised if there are still such optimizations to be made:
> > > maybe a whole different strategy could be more efficient, but I'd be
> > > surprised if there's really a superfluous TLB flush to be tweaked away.
> > > 
> > > Although it looks as if there's a TLB flush at the end of every batch,
> > > isn't that deceptive (on x86 anyway)?  I'm thinking that the first
> > > flush_tlb_mm() will end up calling leave_mm(), and the subsequent
> > > ones do nothing because the cpu_vm_mask is then empty.
> > 
> > Ok, well, that's a bit different on other archs like powerpc where we virtually
> > never remove bits from cpu_vm_mask... (though we probably could... to be looked
> > at).
> 
> We do this on sparc64 when the mm->mm_users == 1 and 'mm' is the
> current->active_mm

That doesn't sound right ... mm_user seems to represent how many tasks
have task->mm set to this mm, but now how many processors have it as
the "active_mm" due to lazy switching.

If you look at context_switch() in kernel/sched.c, it increments
mm_count when using the pevious guy's mm as the "active_mm" of a kernel
thread, not mm_user.

So effectively, mm_user can be any value, that doesn't represent how
many processors can have the mm currently active on them.

You could have mm_user be 1 due to the mm being active and in userspace
on another CPU, and have it locally be the active_mm because your local
CPU is in keventd or similar, flushing the other guy's mm as a result
of some unmap_mapping_range() call due to a network filesystem doing
coherency stuff for example.

Cheers,
Ben.

> See arch/sparc/kernel/smp_64.c:smp_flush_tlb_pending() where we go:
> 
> 	if (mm == current->active_mm && atomic_read(&mm->mm_users) == 1)
> 		mm->cpu_vm_mask = cpumask_of_cpu(cpu);
> 	else
> 		smp_cross_call_masked(&xcall_flush_tlb_pending,
> 				      ctx, nr, (unsigned long) vaddrs,
> 				      &mm->cpu_vm_mask);
> 
> 	__flush_tlb_pending(ctx, nr, vaddrs);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
