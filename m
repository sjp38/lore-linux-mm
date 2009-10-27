Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 53F086B0073
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:52:30 -0400 (EDT)
Date: Tue, 27 Oct 2009 15:52:24 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug #14141] order 2 page allocation failures in iwlagn
Message-ID: <20091027155223.GL8900@csn.ul.ie>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <20091019161815.GA11487@think> <20091020104839.GC11778@csn.ul.ie> <200910262206.13146.elendil@planet.nl> <20091027145435.GG8900@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20091027145435.GG8900@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Chris Mason <chris.mason@oracle.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 27, 2009 at 02:54:35PM +0000, Mel Gorman wrote:
> On Mon, Oct 26, 2009 at 10:06:09PM +0100, Frans Pop wrote:
> > On Tuesday 20 October 2009, Mel Gorman wrote:
> > > I've attached a patch below that should allow us to cheat. When it's
> > > applied, it outputs who called congestion_wait(), how long the timeout
> > > was and how long it waited for. By comparing before and after sleep
> > > times, we should be able to see which of the callers has significantly
> > > changed and if it's something easily addressable.
> > 
> > The results from this look fairly interesting (although I may be a bad 
> > judge as I don't really know what I'm looking at ;-).
> > 
> > I've tested with two kernels:
> > 1) 2.6.31.1: 1 test run
> > 2) 2.6.31.1 + congestion_wait() reverts: 2 test runs
> > 
> > The 1st kernel had the expected "freeze" while reading commits in gitk; 
> > reading commits with the 2nd kernel was more fluent.
> > I did 2 runs with the 2nd kernel as the first run had a fairly long music 
> > skip and more SKB errors than expected. The second run was fairly normal 
> > with no music skips at all even though it had a few SKB errors.
> > 
> > Data for the tests:
> > 				1st kernel	2nd kernel 1	2nd kernel 2
> > end reading commits		1:15		1:00		0:55
> >   "freeze"			yes		no		no
> > branch data shown		1:55		1:15		1:10
> > system quiet			2:25		1:50		1:45
> > # SKB allocation errors		10		53		5
> > 
> > Note that the test is substantially faster with the 2nd kernel and that the 
> > SKB errors don't really affect the duration of the test.
> > 
> 
> Ok. I think that despite expectations, the writeback changes have
> changed the timing significantly enough to be worth examining closer.
> 
> > 
> > - without the revert 'background_writeout' is called a lot less frequently,
> >   but when it's called it gets long delays
> > - without the revert you have 'wb_kupdate', which is relatively expensive
> > - with the revert 'shrink_list' is relatively expensive, although not
> >   really in absolute terms
> > 
> 
> Lets look at the callers that waited in congestion_wait() for at least
> 25 jiffies.
> 
> 2.6.31.1-async-sync-congestion-wait i.e. vanilla kernel
> generated with: cat kern.log_1_test | awk -F ] '{print $2}' | sort -k 5 -n | uniq -c
>      24  background_writeout  congestion_wait sync=0 delay 25 timeout 25
>     203  kswapd               congestion_wait sync=0 delay 25 timeout 25
>       5  shrink_list          congestion_wait sync=0 delay 25 timeout 25
>     155  try_to_free_pages    congestion_wait sync=0 delay 25 timeout 25
>     145  wb_kupdate           congestion_wait sync=0 delay 25 timeout 25
>       2  kswapd               congestion_wait sync=0 delay 26 timeout 25
>       8  wb_kupdate           congestion_wait sync=0 delay 26 timeout 25
>       1  try_to_free_pages    congestion_wait sync=0 delay 54 timeout 25
> 
> 2.6.31.1-write-congestion-wait i.e. kernel with patch reverted
> generated with: cat kern.log_2.1_test | awk -F ] '{print $2}' | sort -k 5 -n | uniq -c
>       2  background_writeout  congestion_wait rw=1 delay 25 timeout 25
>     188  kswapd               congestion_wait rw=1 delay 25 timeout 25
>      14  shrink_list          congestion_wait rw=1 delay 25 timeout 25
>     181  try_to_free_pages    congestion_wait rw=1 delay 25 timeout 25
>       5  kswapd               congestion_wait rw=1 delay 26 timeout 25
>      10  try_to_free_pages    congestion_wait rw=1 delay 26 timeout 25
>       3  try_to_free_pages    congestion_wait rw=1 delay 27 timeout 25
>       1  kswapd               congestion_wait rw=1 delay 29 timeout 25
>       1  __alloc_pages_nodemask congestion_wait rw=1 delay 30 timeout 5
>       1  try_to_free_pages    congestion_wait rw=1 delay 31 timeout 25
>       1  try_to_free_pages    congestion_wait rw=1 delay 35 timeout 25
>       1  kswapd               congestion_wait rw=1 delay 51 timeout 25
>       1  try_to_free_pages    congestion_wait rw=1 delay 56 timeout 25
> 
> So, wb_kupdate and background_writeout are the big movers in terms of waiting,
> not the direct reclaimers which is what we were expecting. Of those big
> movers, wb_kupdate is the most interested because compare the following
> 

Bah, this part is right, but I got the next section the wrong way
around. I should have renamed the damn things instead of remember what
was 1 and what was 2.

1 == vanilla
2 == with-revert

> $ cat kern.log_2.1_test | awk -F ] '{print $2}' | sort -k 5 -n | uniq -c | grep wb_kup
> [ no output ]
> $ $ cat kern.log_1_test | awk -F ] '{print $2}' | sort -k 5 -n | uniq -c | grep wb_kup
>       1  wb_kupdate           congestion_wait sync=0 delay 15 timeout 25
>       1  wb_kupdate           congestion_wait sync=0 delay 23 timeout 25
>     145  wb_kupdate           congestion_wait sync=0 delay 25 timeout 25
>       8  wb_kupdate           congestion_wait sync=0 delay 26 timeout 25
> 
> The vanilla kernel is not waiting in wb_kupdate at all.
> 

The vanilla kernel *is* waiting. The reverted kernel is not. If my patch
makes any difference, it's not for the right reasons.

> Jens, before the congestion_wait() changes, wb_kupdate was waiting on
> congestion and afterwards it's not. Furthermore, look at the number of pages
> that are queued for writeback in the two page allocation failure reports.
> 
> without-revert:	writeback:65653
> with-revert:	writeback:21713
> 

and got it back right again.

kernel 1 == vanilla kernel == without-revert	writeback:65653
kernel 2 == revert  kernel == with-revert	writeback:21713

> So, after the move to async/sync, a lot more pages are getting queued
> for writeback - more than three times the number of pages are queued for
> writeback with the vanilla kernel. This amount of congestion might be why
> direct reclaimers and kswapd's timings have changed so much.
> 

Or more accurately, the vanilla kernel has queued up a lot more pages for
IO than when the patch is reverted. I'm not seeing yet why this is.

> Chris Mason hinted at this but I didn't quite "get it" at the time but is it
> possible that writeback_inodes() is converting what is expected to be async
> IO into sync IO? One way of checking this is if Frans could test the patch
> below that makes wb_kupdate wait on sync instead of async.
> 

This reasoning is rubbish. If the patch makes any difference, it's because
it changes timing. It's probably more important to figure out if a) if the
different number of pages for writeback is relevant and if so b) why has
it changed.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
