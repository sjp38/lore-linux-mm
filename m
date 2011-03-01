Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7C22B8D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 17:35:17 -0500 (EST)
Date: Tue, 1 Mar 2011 14:34:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: compaction: Minimise the time IRQs are disabled
 while isolating pages for migration
Message-Id: <20110301143444.2ed102aa.akpm@linux-foundation.org>
In-Reply-To: <AANLkTimpTyaAU0JzFKp4s14w=ciq152MWSmbgn8xtkOx@mail.gmail.com>
References: <20110301153558.GA2031@barrios-desktop>
	<20110301161900.GA21860@random.random>
	<AANLkTimpTyaAU0JzFKp4s14w=ciq152MWSmbgn8xtkOx@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Arthur Marsh <arthur.marsh@internode.on.net>, Clemens Ladisch <cladisch@googlemail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, 2 Mar 2011 07:22:33 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Wed, Mar 2, 2011 at 1:19 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > On Wed, Mar 02, 2011 at 12:35:58AM +0900, Minchan Kim wrote:
> >> On Tue, Mar 01, 2011 at 01:49:25PM +0900, KAMEZAWA Hiroyuki wrote:
> >> > On Tue, 1 Mar 2011 13:11:46 +0900
> >> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >> >
>
> ...
>
> > pages freed from irq shouldn't be PageLRU.
> 
> Hmm..
> As looking code, it seems to be no problem and I didn't see the any
> comment about such rule. It should have been written down in
> __page_cache_release.
> Just out of curiosity.
> What kinds of problem happen if we release lru page in irq context?

put_page() from irq context has been permissible for ten years.  I
expect there are a number of sites which do this (via subtle code
paths, often).  It might get messy.

> >
> > deferring freeing to workqueue doesn't look ok. firewall loads runs
> > only from irq and this will cause some more work and a delay in the
> > freeing. I doubt it's worhwhile especially for the lru_lock.
> >
> 
> As you said, if it is for decreasing lock contention in SMP to deliver
> overall better performance, maybe we need to check again how much it
> helps.
> If it doesn't help much, could we remove irq_save/restore of lru_lock?
> Do you know any benchmark to prove it had a benefit at that time or
> any thread discussing about that in lkml?


: commit b10a82b195d63575958872de5721008b0e9bef2d
: Author: akpm <akpm>
: Date:   Thu Aug 15 18:21:05 2002 +0000
: 
:     [PATCH] make pagemap_lru_lock irq-safe
:     
:     It is expensive for a CPU to take an interrupt while holding the page
:     LRU lock, because other CPUs will pile up on the lock while the
:     interrupt runs.
:     
:     Disabling interrupts while holding the lock reduces contention by an
:     additional 30% on 4-way.  This is when the only source of interrupts is
:     disk completion.  The improvement will be higher with more CPUs and it
:     will be higher if there is networking happening.
:     
:     The maximum hold time of this lock is 17 microseconds on 500 MHx PIII,
:     which is well inside the kernel's maximum interrupt latency (which was
:     100 usecs when I last looked, a year ago).
:     
:     This optimisation is not needed on uniprocessor, but the patch disables
:     IRQs while holding pagemap_lru_lock anyway, so it becomes an irq-safe
:     spinlock, and pages can be moved from the LRU in interrupt context.
:     
:     pagemap_lru_lock has been renamed to _pagemap_lru_lock to pick up any
:     missed uses, and to reliably break any out-of-tree patches which may be
:     using the old semantics.
:     
:     BKrev: 3d5bf1110yfdAAur4xqJfiLBDJ2Cqw


Ancient stuff, and not a lot of detail.  But I did measure it.  I
measured everything ;) And, as mentioned, I'd expect that the
contention problems would worsen on higher CPU machines and higher
interrupt frequencies.

I expect we could eliminate the irqsave requirement from
rotate_reclaimable_page() simply by switching to a trylock.  Some pages
will end up at the wrong end of the LRU but the effects may be
negligible.  Or perhaps they may not - disk seeks are costly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
