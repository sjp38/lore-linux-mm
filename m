Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C89A36B0092
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 08:01:20 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 800823EE0B5
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 22:01:18 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 657FF45DE51
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 22:01:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 49E8445DE54
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 22:01:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DB5DEF8001
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 22:01:18 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 01E3CEF8003
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 22:01:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] mm: fix deferred congestion timeout if preferred zone is not allowed
In-Reply-To: <alpine.DEB.2.00.1101181211100.18781@chino.kir.corp.google.com>
References: <20110118101547.GF27152@csn.ul.ie> <alpine.DEB.2.00.1101181211100.18781@chino.kir.corp.google.com>
Message-Id: <20110119215500.2833.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 19 Jan 2011 22:01:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > This patch resets preferred_zone to an allowed zone in the slowpath if
> > > the allocation context is constrained by current's cpuset. 
> > 
> > Well, preferred_zone has meaning. If it's not possible to allocate from
> > that zone in the current cpuset context, it's not really preferred. Why
> > not set it in the fast path so there isn't a useless call to
> > get_page_from_freelist()?
> > 
> 
> It may be the preferred zone even if it isn't allowed by current's cpuset 
> such as if the allocation is __GFP_WAIT or the task has been oom killed 
> and has the TIF_MEMDIE bit set, so the preferred zone in the fastpath is 
> accurate in these cases.  In the slowpath, the former is protected by 
> checking for ALLOC_CPUSET and the latter is usually only set after the 
> page allocator has looped at least once and triggered the oom killer to be 
> killed.
> 
> I didn't want to add a branch to test for these possibilities in the 
> fastpath, however, since preferred_zone isn't of critical importance until 
> it's used in the slowpath (ignoring the statistical usage).

I'm glad to you are keeping fastpath concern. However you don't need
nodemask-and in this case. Because zonelist->zref[0] is always in nodemask.
Please see policy_zonelist(). So, you can just replace nodemask with cpuset_mems_allowed.

This is not only simple, but also improve a consisteny of mempolicy.

---
 mm/page_alloc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 07a6544..876de04 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2146,7 +2146,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 
 	get_mems_allowed();
 	/* The preferred zone is used for statistics later */
-	first_zones_zonelist(zonelist, high_zoneidx, nodemask, &preferred_zone);
+	first_zones_zonelist(zonelist, high_zoneidx,
+			     &cpuset_current_mems_allowed, &preferred_zone);
 	if (!preferred_zone) {
 		put_mems_allowed();
 		return NULL;
-- 
1.6.5.2




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
