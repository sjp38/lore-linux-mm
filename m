Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EB71A6B008A
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 20:18:56 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAP1IrWA020882
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 25 Nov 2010 10:18:53 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BA12645DE58
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 10:18:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A43845DE54
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 10:18:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E22BE38002
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 10:18:53 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F3A1E08001
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 10:18:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <20101124191749.GA29511@hostway.ca>
References: <20101124092753.GS19571@csn.ul.ie> <20101124191749.GA29511@hostway.ca>
Message-Id: <20101125101803.F450.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 25 Nov 2010 10:18:52 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Simon Kirby <sim@hostway.ca>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, Nov 24, 2010 at 09:27:53AM +0000, Mel Gorman wrote:
> 
> > On Tue, Nov 23, 2010 at 10:43:29PM -0800, Simon Kirby wrote:
> > > On Tue, Nov 23, 2010 at 10:04:03AM +0000, Mel Gorman wrote:
> > > 
> > > > On Mon, Nov 22, 2010 at 03:44:19PM -0800, Andrew Morton wrote:
> > > > > On Mon, 15 Nov 2010 11:52:46 -0800
> > > > > Simon Kirby <sim@hostway.ca> wrote:
> > > > > 
> > > > > > I noticed that CONFIG_NUMA seems to enable some more complicated
> > > > > > reclaiming bits and figured it might help since most stock kernels seem
> > > > > > to ship with it now.  This seems to have helped, but it may just be
> > > > > > wishful thinking.  We still see this happening, though maybe to a lesser
> > > > > > degree.  (The following observations are with CONFIG_NUMA enabled.)
> > > > > > 
> > > > 
> > > > Hi,
> > > > 
> > > > As this is a NUMA machine, what is the value of
> > > > /proc/sys/vm/zone_reclaim_mode ? When enabled, this reclaims memory
> > > > local to the node in preference to using remote nodes. For certain
> > > > workloads this performs better but for users that expect all of memory
> > > > to be used, it has surprising results.
> > > > 
> > > > If set to 1, try testing with it set to 0 and see if it makes a
> > > > difference. Thanks
> > > 
> > > Hi Mel,
> > > 
> > > It is set to 0.  It's an Intel EM64T...I only enabled CONFIG_NUMA since
> > > it seemed to enable some more complicated handling, and I figured it
> > > might help, but it didn't seem to.  It's also required for
> > > CONFIG_COMPACTION, but that is still marked experimental.
> > > 
> > 
> > I'm surprised a little that you are bringing compaction up because unless
> > there are high-order involved, it wouldn't make a difference. Is there
> > a constant source of high-order allocations in the system e.g. a network
> > card configured to use jumbo frames? A possible consequence of that is that
> > reclaim is kicking in early to free order-[2-4] pages that would prevent 100%
> > of memory being used.
> 
> We /were/ using jumbo frames, but only over a local cross-over connection
> to another node (for DRBD), so I disabled jumbo frames on this interface
> and reconnected DRBD.  Even with MTUs set to 1500, we saw GFP_ATOMIC
> order=3 allocations coming from __alloc_skb:
> 
> perf record --event kmem:mm_page_alloc --filter 'order>=3' -a --call-graph sleep 10
> perf trace
> 
> 	imap-20599 [002] 1287672.803567: mm_page_alloc: page=0xffffea00004536c0 pfn=4536000 order=3 migratetype=0 gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP
> 
> perf report shows:
> 
> __alloc_pages_nodemask
> alloc_pages_current
> new_slab
> __slab_alloc
> __kmalloc_node_track_caller
> __alloc_skb
> __netdev_alloc_skb
> bnx2_poll_work
> 
> Dave was seeing these on his laptop with an Intel NIC as well.  Ralf
> noted that the slab cache grows in higher order blocks, so this is
> normal.  The GFP_ATOMIC bubbles up from *alloc_skb, I guess.

Please try SLAB instead SLUB (it can be switched by kernel build option).
SLUB try to use high order allocation implicitly.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
