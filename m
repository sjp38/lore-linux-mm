Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 011D76B012F
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 22:50:34 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9E2oWRU009785
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 Oct 2010 11:50:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 627F145DE6F
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 11:50:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 36AED45DE4D
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 11:50:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2137EEF8004
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 11:50:32 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D2AD51DB8037
	for <linux-mm@kvack.org>; Thu, 14 Oct 2010 11:50:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [experimental][PATCH] mm,vmstat: per cpu stat flush too when per cpu page cache flushed
In-Reply-To: <20101013132246.GO30667@csn.ul.ie>
References: <20101013160640.ADC9.A69D9226@jp.fujitsu.com> <20101013132246.GO30667@csn.ul.ie>
Message-Id: <20101014114541.8B89.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 Oct 2010 11:50:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Wed, Oct 13, 2010 at 04:10:43PM +0900, KOSAKI Motohiro wrote:
> > When memory shortage, we are using drain_pages() for flushing per cpu
> > page cache. In this case, per cpu stat should be flushed too. because
> > now we are under memory shortage and we need to know exact free pages.
> > 
> > Otherwise get_page_from_freelist() may fail even though pcp was flushed.
> > 
> 
> With my patch adjusting the threshold to a small value while kswapd is awake,
> it seems less necessary. 

I agree this.

> It's also very hard to predict the performance of
> this. We are certainly going to take a hit to do the flush but we *might*
> gain slightly if an allocation succeeds because a watermark check passed
> when the counters were updated. It's a definite hit for a possible gain
> though which is not a great trade-off. Would need some performance testing.
> 
> I still think my patch on adjusting thresholds is our best proposal so
> far on how to reduce Shaohua's performance problems while still being
> safer from livelocks due to memory exhaustion.

OK, I will try to explain a detai of my worry.

Initial variable ZVC commit (df9ecaba3f1) says 

>     [PATCH] ZVC: Scale thresholds depending on the size of the system
> 
>     The ZVC counter update threshold is currently set to a fixed value of 32.
>     This patch sets up the threshold depending on the number of processors and
>     the sizes of the zones in the system.
> 
>     With the current threshold of 32, I was able to observe slight contention
>     when more than 130-140 processors concurrently updated the counters.  The
>     contention vanished when I either increased the threshold to 64 or used
>     Andrew's idea of overstepping the interval (see ZVC overstep patch).
> 
>     However, we saw contention again at 220-230 processors.  So we need higher
>     values for larger systems.

So, I'm worry about your patch reintroduce old cache contention issue that Christoph
observed when run 128-256cpus system.  May I ask how do you think this issue?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
