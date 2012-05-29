Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 206436B005D
	for <linux-mm@kvack.org>; Tue, 29 May 2012 13:14:48 -0400 (EDT)
Date: Tue, 29 May 2012 19:14:07 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 35/35] autonuma: page_autonuma
Message-ID: <20120529171407.GH21339@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <1337965359-29725-36-git-send-email-aarcange@redhat.com>
 <1338309855.26856.130.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338309855.26856.130.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Tue, May 29, 2012 at 06:44:15PM +0200, Peter Zijlstra wrote:
> On Fri, 2012-05-25 at 19:02 +0200, Andrea Arcangeli wrote:
> > Move the AutoNUMA per page information from the "struct page" to a
> > separate page_autonuma data structure allocated in the memsection
> > (with sparsemem) or in the pgdat (with flatmem).
> > 
> > This is done to avoid growing the size of the "struct page" and the
> > page_autonuma data is only allocated if the kernel has been booted on
> > real NUMA hardware (or if noautonuma is passed as parameter to the
> > kernel).
> > 
> 
> Argh, please fold this change back into the series proper. If you want
> to keep it.. as it is its not really an improvement IMO, see below.

The whole objective of this patch is to avoid allocating the
page_autonuma structures when the kernel is booted on not NUMA
hardware.

It's not an improvement when booting the kernel on NUMA hardware
that's for sure.

I didn't merge it with the previous because this was the most
experimental recent change, so I wanted bisectability here. When
something goes wrong here, the kernel won't boot, so unless you use
kvm with gdbstub it's a little tricky to debug (indeed I debugged it
with gdbstub, there it's trivial).

> > +struct page_autonuma {
> > +       /*
> > +        * FIXME: move to pgdat section along with the memcg and allocate
> > +        * at runtime only in presence of a numa system.
> > +        */
> > +       /*
> > +        * To modify autonuma_last_nid lockless the architecture,
> > +        * needs SMP atomic granularity < sizeof(long), not all archs
> > +        * have that, notably some alpha. Archs without that requires
> > +        * autonuma_last_nid to be a long.
> > +        */
> 
> Looking at arch/alpha/include/asm/xchg.h it looks to have that just
> fine, so maybe we simply don't support SMP on those early Alphas that
> had that weirdness.

I agree we should never risk that.

> This makes a shadow page frame of 32 bytes per page, or ~0.8% of memory.
> This isn't in fact an improvement.
> 
> The suggestion done by Rik was to have something like a sqrt(nr_pages)
> (?) scaled array of such things containing the list_head and page
> pointer -- and leave the two nids in the regular page frame. Although I
> think you've got to fight the memcg people over that last word in struct
> page.
> 
> That places a limit on the amount of pages that can be in migration
> concurrently, but also greatly reduces the memory overhead.

Yes, however for the last_nid I'd still need it for every page (and if
I allocate it dynamic I still first need to find a way to remove the
struct page pointer).

I thought to add a pointer in the memsection (or maybe to use a vmemmap
so that it won't even require a pointer in every memsection). I've to
check a few more things before I allow_the autonuma->page translation
without a page pointer, notably to verify the boot time allocations
points won't just allocate power of two blocks of memory (they
shouldn't but I didn't verify).

This is clearly a move in the right direction to avoid the memory
overhead when not booted on NUMA hardware, and I don't think there's
anything fundamental that prevents us remove the page pointer from the
page_autonuma structure, and to later experiment with a limited size
array of async migration structures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
