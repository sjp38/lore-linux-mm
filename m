Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6F3CD6B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 05:11:14 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n319BMDa005847
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 1 Apr 2009 18:11:22 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FE6345DE55
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 18:11:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D1EC145DD79
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 18:11:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 903A11DB803F
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 18:11:21 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 432FC1DB8041
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 18:11:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: memcg needs may_swap (Re: [patch] vmscan: rename  sc.may_swap to may_unmap)
In-Reply-To: <20090401180445.80b11d90.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090401040951.GA1548@cmpxchg.org> <20090401180445.80b11d90.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090401180756.B1F1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  1 Apr 2009 18:11:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>

> memory cgroup has 2 calls to this shrink_zone.
>  1. memory usage hits the limit.
>  2. mem+swap usage hits the limit.
> 
> At "2", swap-out doesn't decrease the usage of mem+swap, then set may_swap=0.
> So, we want to kick out only file caches.
> But, we can reclaim file cache and "unmap file cache and reclaim it!" is 
> necessary even if may_swap=0.
> 
> Then, scanning only FILE LRU makes sense at may_swap=0 *if* memcg is
> the only user of may_swap=0.
> 
> Let's see others.
> 
>  - __zone_reclaim sets may_unmap to be 0 when they don't want swap-out.
>    .....can be replaced with may_swap.
> 
>  - shrink_all_memory sets may_swap to be 0. Is this called by hibernation ?
>    If you don't want to unmap file caches while hibernation, adding may_unmap
>    as *new* paramter makes sense, I think.
> 
> The change you proposed is for dropping unused SwapCache pages. Right ?
> But this will be dropped by kswapd if necessary.
> 
> As far as memcg concerns, scanning ANON LRU even when may_swap=0 is just
> a waste of cpu time.

this sentence just explain my intention.

1. memcg, zone_reclaim scanning ANON LRU is just waste of cpu.
2. kswapd and normal direct reclaim can reclaim stealed swapcache anyway.
   then above trick don't cause any system hang-up and performance degression.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
