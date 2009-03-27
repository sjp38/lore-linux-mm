Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BD4D66B0047
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 00:57:20 -0400 (EDT)
Date: Thu, 26 Mar 2009 22:04:09 -0700 (PDT)
Message-Id: <20090326.220409.72126250.davem@davemloft.net>
Subject: Re: tlb_gather_mmu() and semantics of "fullmm"
From: David Miller <davem@davemloft.net>
In-Reply-To: <1238106824.16498.7.camel@pasglop>
References: <1238043674.25062.823.camel@pasglop>
	<Pine.LNX.4.64.0903261232060.27412@blonde.anvils>
	<1238106824.16498.7.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: benh@kernel.crashing.org
Cc: hugh@veritas.com, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, npiggin@suse.de, zach@vmware.com, jeremy@goop.org
List-ID: <linux-mm.kvack.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 27 Mar 2009 09:33:44 +1100

> > I'd be surprised if there are still such optimizations to be made:
> > maybe a whole different strategy could be more efficient, but I'd be
> > surprised if there's really a superfluous TLB flush to be tweaked away.
> > 
> > Although it looks as if there's a TLB flush at the end of every batch,
> > isn't that deceptive (on x86 anyway)?  I'm thinking that the first
> > flush_tlb_mm() will end up calling leave_mm(), and the subsequent
> > ones do nothing because the cpu_vm_mask is then empty.
> 
> Ok, well, that's a bit different on other archs like powerpc where we virtually
> never remove bits from cpu_vm_mask... (though we probably could... to be looked
> at).

We do this on sparc64 when the mm->mm_users == 1 and 'mm' is the
current->active_mm

See arch/sparc/kernel/smp_64.c:smp_flush_tlb_pending() where we go:

	if (mm == current->active_mm && atomic_read(&mm->mm_users) == 1)
		mm->cpu_vm_mask = cpumask_of_cpu(cpu);
	else
		smp_cross_call_masked(&xcall_flush_tlb_pending,
				      ctx, nr, (unsigned long) vaddrs,
				      &mm->cpu_vm_mask);

	__flush_tlb_pending(ctx, nr, vaddrs);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
