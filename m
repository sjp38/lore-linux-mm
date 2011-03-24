Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 099328D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 02:16:29 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2A0F13EE081
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 15:16:27 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E16745DE52
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 15:16:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E92E145DE4E
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 15:16:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DB6001DB803E
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 15:16:26 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A11EA1DB8037
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 15:16:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] vmscan: remove all_unreclaimable check from direct reclaim path completely
In-Reply-To: <AANLkTik0AUXX2O9-=7dpF2-_CovqXtqenieZA9HRanEc@mail.gmail.com>
References: <20110324143541.CC78.A69D9226@jp.fujitsu.com> <AANLkTik0AUXX2O9-=7dpF2-_CovqXtqenieZA9HRanEc@mail.gmail.com>
Message-Id: <20110324151701.CC7F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 24 Mar 2011 15:16:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>

Hi

> Thanks for your effort, Kosaki.
> But I still doubt this patch is good.
> 
> This patch makes early oom killing in hibernation as it skip
> all_unreclaimable check.
> Normally,  hibernation needs many memory so page_reclaim pressure
> would be big in small memory system. So I don't like early give up.

Wait. When occur big pressure? hibernation reclaim pressure
(sc->nr_to_recliam) depend on physical memory size. therefore
a pressure seems to don't depend on the size.


> Do you think my patch has a problem? Personally, I think it's very
> simple and clear. :)

To be honest, I dislike following parts. It's madness on madness.

	static bool zone_reclaimable(struct zone *zone)
	{
	        if (zone->all_unreclaimable)
	                return false;
	
	        return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
	}


The function require a reviewer know 

 o pages_scanned and all_unreclaimable are racy
 o at hibernation, zone->all_unreclaimable can be false negative,
   but can't be false positive.

And, a function comment of all_unreclaimable() says

	 /*
	  * As hibernation is going on, kswapd is freezed so that it can't mark
	  * the zone into all_unreclaimable. It can't handle OOM during hibernation.
	  * So let's check zone's unreclaimable in direct reclaim as well as kswapd.
	  */

But, now it is no longer copy of kswapd algorithm. 

If you strongly prefer this idea even if you hear above explanation,
please consider to add much and much comments. I can't say
current your patch is enough readable/reviewable.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
