Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA21597
	for <linux-mm@kvack.org>; Wed, 13 Nov 2002 13:40:30 -0800 (PST)
Message-ID: <3DD2C6CC.F831A6F2@digeo.com>
Date: Wed, 13 Nov 2002 13:40:28 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.47-mm2
References: <3DD21113.B4F3857@digeo.com> <20021113091116.GG23425@holomorphy.com> <3DD287EF.DCBFB5D0@digeo.com> <20021113212252.GW22031@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> 
> On Wed, Nov 13, 2002 at 12:45:07AM -0800, Andrew Morton wrote:
> >>> page-reservation.patch
> >>>   Page reservation API
> 
> William Lee Irwin III wrote:
> >> Don't drop it yet, I've got a caller of this on the back burner.
> 
> On Wed, Nov 13, 2002 at 09:12:15AM -0800, Andrew Morton wrote:
> > Well so have I.  Right now, if pte_chain_alloc() fails the
> > kernel oopses.
> 
> That's the one. I keep choking on mm/slab.c though. =(
> 

Well my plan here is to go to all code paths which end up allocating
a pte chain and do:

	reserve_local_pages(GFP_KERNEL, 2);
	spin_lock(some_lock);
	<lotsa code>
	pte_alloc_map();	/* That's one */
	pte_chain_alloc();	/* That's two */
	spin_unlock(some_lock);
	release_local_pages(GFP_KERNEL, 2);

When you're inside reserve_local_pages(), you are running atomically:
preempt is disabled.  Because the reserved pages are per-cpu.

Consequently all those pagetable allocation functions can no longer
use GFP_KERNEL and they can not have their sleep-and-try-again
stuff.  They must be atomic.  That's why the above code reserved
a page for them too.

This assumes that every architecture's pagetable allocation code
only uses zero-order pages.  If that's not true I am screwed.

Only allocations which use __GFP_RESERVE may dip into those pages.

With this we _could_ take out all the (nasty) dropping of page_table_lock
everywhere where we allocate a pagetable page.  But I figured
I'd keep that there because it works, and memsetting a whole page
while holding page_table_lock is unfriendly.


A similar bunch-o-crap needs to be done for ratnode allocations.

It isn't going to be pretty, but I haven't really been able to
come up with anything better.  A per-task reserved page pool
would not be very good - either we pin boatloads of memory or
we do tons more allocations and frees than necessary...

What do you think?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
