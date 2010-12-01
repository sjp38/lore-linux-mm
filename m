Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 209A96B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 22:20:31 -0500 (EST)
Subject: Re: [PATCH 1/3] mm: kswapd: Stop high-order balancing when any
 suitable zone is balanced
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20101201115401.ABB1.A69D9226@jp.fujitsu.com>
References: <20101201112354.ABA8.A69D9226@jp.fujitsu.com>
	 <1291171667.12777.51.camel@sli10-conroe>
	 <20101201115401.ABB1.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 01 Dec 2010 11:20:28 +0800
Message-ID: <1291173628.12777.65.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Simon Kirby <sim@hostway.ca>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-12-01 at 10:59 +0800, KOSAKI Motohiro wrote:
> > On Wed, 2010-12-01 at 10:23 +0800, KOSAKI Motohiro wrote:
> > > > On Wed, 2010-12-01 at 01:15 +0800, Mel Gorman wrote:
> > > > > When the allocator enters its slow path, kswapd is woken up to balance the
> > > > > node. It continues working until all zones within the node are balanced. For
> > > > > order-0 allocations, this makes perfect sense but for higher orders it can
> > > > > have unintended side-effects. If the zone sizes are imbalanced, kswapd
> > > > > may reclaim heavily on a smaller zone discarding an excessive number of
> > > > > pages. The user-visible behaviour is that kswapd is awake and reclaiming
> > > > > even though plenty of pages are free from a suitable zone.
> > > > > 
> > > > > This patch alters the "balance" logic to stop kswapd if any suitable zone
> > > > > becomes balanced to reduce the number of pages it reclaims from other zones.
> > > > from my understanding, the patch will break reclaim high zone if a low
> > > > zone meets the high order allocation, even the high zone doesn't meet
> > > > the high order allocation. This, for example, will make a high order
> > > > allocation from a high zone fallback to low zone and quickly exhaust low
> > > > zone, for example DMA. This will break some drivers.
> > > 
> > > Have you seen patch [3/3]? I think it migigate your pointed issue.
> > yes, it improves a lot, but still possible for small systems.
> 
> Ok, I got you. so please define your "small systems" word? 
an embedded system with less memory memory, obviously

> we can't make
> perfect VM heuristics obviously, then we need to compare pros/cons.
if you don't care about small system, let's consider a NORMAL i386
system with 896m normal zone, and 896M*3 high zone. normal zone will
quickly exhaust by high order high zone allocation, leave a latter
allocation which does need normal zone fail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
