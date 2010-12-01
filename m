Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BFF436B004A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 21:23:15 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB12NDB4000617
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Dec 2010 11:23:13 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E8E0745DE4F
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 11:23:12 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CC64945DE4C
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 11:23:12 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B146E1DB8014
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 11:23:12 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 31A6E1DB8015
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 11:23:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] mm: kswapd: Stop high-order balancing when any suitable zone is balanced
In-Reply-To: <1291169636.12777.43.camel@sli10-conroe>
References: <1291137339-6323-2-git-send-email-mel@csn.ul.ie> <1291169636.12777.43.camel@sli10-conroe>
Message-Id: <20101201112354.ABA8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Wed,  1 Dec 2010 11:23:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Simon Kirby <sim@hostway.ca>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 2010-12-01 at 01:15 +0800, Mel Gorman wrote:
> > When the allocator enters its slow path, kswapd is woken up to balance the
> > node. It continues working until all zones within the node are balanced. For
> > order-0 allocations, this makes perfect sense but for higher orders it can
> > have unintended side-effects. If the zone sizes are imbalanced, kswapd
> > may reclaim heavily on a smaller zone discarding an excessive number of
> > pages. The user-visible behaviour is that kswapd is awake and reclaiming
> > even though plenty of pages are free from a suitable zone.
> > 
> > This patch alters the "balance" logic to stop kswapd if any suitable zone
> > becomes balanced to reduce the number of pages it reclaims from other zones.
> from my understanding, the patch will break reclaim high zone if a low
> zone meets the high order allocation, even the high zone doesn't meet
> the high order allocation. This, for example, will make a high order
> allocation from a high zone fallback to low zone and quickly exhaust low
> zone, for example DMA. This will break some drivers.

Have you seen patch [3/3]? I think it migigate your pointed issue.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
