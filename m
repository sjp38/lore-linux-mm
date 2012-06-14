Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id A54646B006C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 04:54:37 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AB1053EE0BC
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 17:54:35 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F24745DE55
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 17:54:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7765645DE58
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 17:54:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 679E91DB803C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 17:54:35 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CE5B1DB8043
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 17:54:35 +0900 (JST)
Message-ID: <4FD9A625.1050300@jp.fujitsu.com>
Date: Thu, 14 Jun 2012 17:51:49 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [resend][PATCH] mm, vmscan: fix do_try_to_free_pages() livelock
References: <1339661592-3915-1-git-send-email-kosaki.motohiro@gmail.com>
In-Reply-To: <1339661592-3915-1-git-send-email-kosaki.motohiro@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>

(2012/06/14 17:13), kosaki.motohiro@gmail.com wrote:
> From: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> 
> Currently, do_try_to_free_pages() can enter livelock. Because of,
> now vmscan has two conflicted policies.
> 
> 1) kswapd sleep when it couldn't reclaim any page when reaching
>     priority 0. This is because to avoid kswapd() infinite
>     loop. That said, kswapd assume direct reclaim makes enough
>     free pages to use either regular page reclaim or oom-killer.
>     This logic makes kswapd ->  direct-reclaim dependency.
> 2) direct reclaim continue to reclaim without oom-killer until
>     kswapd turn on zone->all_unreclaimble. This is because
>     to avoid too early oom-kill.
>     This logic makes direct-reclaim ->  kswapd dependency.
> 
> In worst case, direct-reclaim may continue to page reclaim forever
> when kswapd sleeps forever.
> 
> We can't turn on zone->all_unreclaimable from direct reclaim path
> because direct reclaim path don't take any lock and this way is racy.
> 
> Thus this patch removes zone->all_unreclaimable field completely and
> recalculates zone reclaimable state every time.
> 
> Note: we can't take the idea that direct-reclaim see zone->pages_scanned
> directly and kswapd continue to use zone->all_unreclaimable. Because, it
> is racy. commit 929bea7c71 (vmscan: all_unreclaimable() use
> zone->all_unreclaimable as a name) describes the detail.
> 
> Reported-by: Aaditya Kumar<aaditya.kumar.30@gmail.com>
> Reported-by: Ying Han<yinghan@google.com>
> Cc: Nick Piggin<npiggin@gmail.com>
> Acked-by: Rik van Riel<riel@redhat.com>
> Cc: Michal Hocko<mhocko@suse.cz>
> Cc: Johannes Weiner<hannes@cmpxchg.org>
> Cc: Mel Gorman<mel@csn.ul.ie>
> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Minchan Kim<minchan.kim@gmail.com>
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

I like this.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
