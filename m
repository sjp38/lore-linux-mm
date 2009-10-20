Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B19306B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 09:39:56 -0400 (EDT)
Date: Tue, 20 Oct 2009 14:39:57 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bug #14141] order 2 page allocation failures (generic)
Message-ID: <20091020133957.GG11778@csn.ul.ie>
References: <alpine.DEB.2.00.0910191538450.8526@sebohet.brgvxre.pu> <20091019140957.GE9036@csn.ul.ie> <alpine.DEB.2.00.0910191613580.8526@sebohet.brgvxre.pu> <20091019145954.GH9036@csn.ul.ie> <alpine.DEB.2.00.0910192211230.27123@sebohet.brgvxre.pu> <alpine.DEB.2.00.0910192215450.27123@sebohet.brgvxre.pu> <20091020105746.GD11778@csn.ul.ie> <alpine.DEB.2.00.0910201338530.27123@sebohet.brgvxre.pu> <20091020125139.GF11778@csn.ul.ie> <alpine.DEB.2.00.0910201456540.27618@sebohet.brgvxre.pu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0910201456540.27618@sebohet.brgvxre.pu>
Sender: owner-linux-mm@kvack.org
To: Tobias Oetiker <tobi@oetiker.ch>
Cc: Frans Pop <elendil@planet.nl>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Tue, Oct 20, 2009 at 02:58:53PM +0200, Tobias Oetiker wrote:
> Hi Mel,
> 
> Today Mel Gorman wrote:
> 
> > On Tue, Oct 20, 2009 at 01:44:50PM +0200, Tobias Oetiker wrote:
> > > Hi Mel,
> > >
> > > Today Mel Gorman wrote:
> > >
> > > > On Mon, Oct 19, 2009 at 10:17:06PM +0200, Tobias Oetiker wrote:
> > >
> > > > > Oct 19 22:09:52 johan kernel: [11157.121600]  [<ffffffff813ebd42>] skb_copy+0x32/0xa0 [kern.warning]
> > > > > Oct 19 22:09:52 johan kernel: [11157.121615]  [<ffffffffa07dd33c>] vboxNetFltLinuxPacketHandler+0x5c/0xd0 [vboxnetflt] [kern.warning]
> > > > > Oct 19 22:09:52 johan kernel: [11157.121620]  [<ffffffff813f2512>] dev_hard_start_xmit+0x142/0x320 [kern.warning]
> > > >
> > > > Are the number of failures at least reduced or are they occuring at the
> > > > same rate?
> > >
> > > not that it would have any statistical significance, but I had 5
> > > failure (clusters) yesterday morning and 5 this morning ...
> > >
> >
> > Before the patches were applied, how many failures were you seeing in
> > the morning?
> 
> 5 as well ... before an after ...
> 
> > > the failures often show up in groups I saved one on
> > > http://tobi.oetiker.ch/cluster-2009-10-20-08-31.txt
> > >
> > > > Also, what was the last kernel that worked for you with this
> > > > configuration?
> > >
> > > that would be 2.6.24 ... I have not upgraded in quite some time.
> > > But since the io performance of 2.6.31 is about double in my tests
> > > I thought it would be a good thing todo ...
> > >
> >
> > That significant a different in performance may explain differences in timing
> > as well. i.e. the allocator is being put under more pressure now than it
> > was previously as more processes make forward progress.
> 
> you are saing that the problem might be even older ?
> 
> we do have 8GB ram and 16 GB swap, so it should not fail to allocate all that
> often
> 
> top - 14:58:34 up 19:54,  6 users,  load average: 2.09, 1.94, 1.97
> Tasks: 451 total,   1 running, 449 sleeping,   0 stopped,   1 zombie
> Cpu(s):  3.5%us, 15.5%sy,  2.0%ni, 72.2%id,  6.5%wa,  0.1%hi,  0.3%si,  0.0%st
> Mem:   8198504k total,  7599132k used,   599372k free,  1212636k buffers
> Swap: 16777208k total,    83568k used, 16693640k free,   610136k cached
> 

High-order atomic allocations of the type you are trying at that frequency
were always a very long shot. The most likely outcome is that something
has changed that means a burst of allocations trigger an allocation failure
where as before processes would delay long enough for the system not to notice.

1. Have MTU settings changed?
2. As order-5 allocations are required to succeed, I'm surprised in a
   sense that there are only 5 failures because it implies the machine is
   actually recovering and continueing on as normal. Can you think of what
   happens in the morning that causes a burst of allocations to occur?
3. Other than the failures, have you noticed any other problems with the
   machine or does it continue along happily?
4. Does the following patch help by any chance?

Thanks

==== CUT HERE ====
vmscan: Force kswapd to take notice faster when high-order watermarks are being hit

When a high-order allocation fails, kswapd is kicked so that it reclaims
at a higher-order to avoid direct reclaimers stall and to help GFP_ATOMIC
allocations. Something has changed in recent kernels that affect the timing
where high-order GFP_ATOMIC allocations are now failing with more frequency,
particularly under pressure. This patch forces kswapd to notice sooner that
high-order allocations are occuring by checking when watermarks are hit early
and by having kswapd restart quickly when the reclaim order is increased.

Not-signed-off-by-because-this-is-a-hatchet-job: Mel Gorman <mel@csn.ul.ie>
--- 
 mm/page_alloc.c |   14 ++++++++++++--
 mm/vmscan.c     |    9 +++++++++
 2 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2fd7b20..fdbf8c9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1907,6 +1906,17 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 				zonelist, high_zoneidx, nodemask,
 				preferred_zone, migratetype);
 
+	/*
+	 * If after a high-order allocation we are now below watermarks,
+	 * pre-emptively kick kswapd rather than having the next allocation
+	 * fail and have to wake up kswapd, potentially failing GFP_ATOMIC
+	 * allocations or entering direct reclaim
+	 */
+	if (unlikely(order) && page && !zone_watermark_ok(preferred_zone, order,
+				preferred_zone->watermark[ALLOC_WMARK_LOW],
+				zone_idx(preferred_zone), ALLOC_WMARK_LOW))
+		wake_all_kswapd(order, zonelist, high_zoneidx);
+
 	return page;
 }
 EXPORT_SYMBOL(__alloc_pages_nodemask);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9219beb..0e66a6b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1925,6 +1925,15 @@ loop_again:
 					priority != DEF_PRIORITY)
 				continue;
 
+			/*
+			 * Exit quickly to restart if it has been indicated
+			 * that higher orders are required
+			 */
+			if (pgdat->kswapd_max_order > order) {
+				all_zones_ok = 1;
+				goto out;
+			}
+
 			if (!zone_watermark_ok(zone, order,
 					high_wmark_pages(zone), end_zone, 0))
 				all_zones_ok = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
