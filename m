Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DBBD68D003B
	for <linux-mm@kvack.org>; Wed, 18 May 2011 02:06:17 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6F8783EE0C3
	for <linux-mm@kvack.org>; Wed, 18 May 2011 15:06:14 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FAD145DEA0
	for <linux-mm@kvack.org>; Wed, 18 May 2011 15:06:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 24B1045DE91
	for <linux-mm@kvack.org>; Wed, 18 May 2011 15:06:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1116AE08004
	for <linux-mm@kvack.org>; Wed, 18 May 2011 15:06:14 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C24141DB803C
	for <linux-mm@kvack.org>; Wed, 18 May 2011 15:06:13 +0900 (JST)
Message-ID: <4DD361C0.5030904@jp.fujitsu.com>
Date: Wed, 18 May 2011 15:05:52 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
References: <1305295404-12129-1-git-send-email-mgorman@suse.de>	<1305295404-12129-5-git-send-email-mgorman@suse.de>	<4DCFAA80.7040109@jp.fujitsu.com>	<1305519711.4806.7.camel@mulgrave.site>	<BANLkTi=oe4Ties6awwhHFPf42EXCn2U4MQ@mail.gmail.com>	<20110516084558.GE5279@suse.de>	<BANLkTinW4s6aT2bZ79sHNgdh5j8VYyJz2w@mail.gmail.com>	<20110516102753.GF5279@suse.de>	<BANLkTi=5ON_ttuwFFhFObfoP8EBKPdFgAA@mail.gmail.com>	<4DD31B6E.8040502@jp.fujitsu.com> <BANLkTikLuWPEt7MitUYdJtzqyBSOkz2zxg@mail.gmail.com>
In-Reply-To: <BANLkTikLuWPEt7MitUYdJtzqyBSOkz2zxg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: mgorman@suse.de, James.Bottomley@hansenpartnership.com, akpm@linux-foundation.org, colin.king@canonical.com, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

>>>>>> While it appears unlikely, there are bad conditions which can result
>>>>
>>>> in cond_resched() being avoided.
>>
>> Every reclaim priority decreasing or every shrink_zone() calling makes more
>> fine grained preemption. I think.
>
> It could be.
> But in direct reclaim case, I have a concern about losing pages
> reclaimed to other tasks by preemption.

Nope, I proposed to add cond_resched() into balance_pgdat().

> Hmm,, anyway, we also needs test.
> Hmm,, how long should we bother them(Colins and James)?
> First of all, Let's fix one just between us and ask test to them and
> send the last patch to akpm.
>
> 1. shrink_slab
> 2. right after balance_pgdat
> 3. shrink_zone
> 4. reclaim priority decreasing routine.
>
> Now, I vote 1) and 2).
>
> Mel, KOSAKI?

I think following patch makes enough preemption.

Thanks.



 From e7d88be1916184ea7c93a6f2746b15c7a32d1973 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 18 May 2011 15:00:39 +0900
Subject: [PATCH] vmscan: balance_pgdat() call cond_resched() unconditionally

Under constant allocation pressure, kswapd can be in the situation where
sleeping_prematurely() will always return true even if kswapd has been
running a long time. Check if kswapd needs to be scheduled.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Colin King <colin.king@canonical.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
---
  mm/vmscan.c |    3 +--
  1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 19e179b..87c88fd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2449,6 +2449,7 @@ loop_again:
  			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
  			total_scanned += sc.nr_scanned;

+			cond_resched();
  			if (zone->all_unreclaimable)
  				continue;
  			if (nr_slab == 0 &&
@@ -2518,8 +2519,6 @@ out:
  	 *             for the node to be balanced
  	 */
  	if (!(all_zones_ok || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))) {
-		cond_resched();
-
  		try_to_freeze();

  		/*
-- 
1.7.3.1




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
