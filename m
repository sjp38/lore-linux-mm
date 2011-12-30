Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 316286B004D
	for <linux-mm@kvack.org>; Fri, 30 Dec 2011 01:36:55 -0500 (EST)
From: Tao Ma <tm@tao.ma>
Subject: [PATCH] mm: do not drain pagevecs for mlock
Date: Fri, 30 Dec 2011 14:36:01 +0800
Message-Id: <1325226961-4271-1-git-send-email-tm@tao.ma>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

In our test of mlock, we have found some severe performance regression
in it. Some more investigations show that mlocked is blocked heavily
by lur_add_drain_all which calls schedule_on_each_cpu and flush the work
queue which is very slower if we have several cpus.

So we have tried 2 ways to solve it:
1. Add a per cpu counter for all the pagevecs so that we don't schedule
   and flush the lru_drain work if the cpu doesn't have any pagevecs(I
   have finished the codes already).
2. Remove the lru_add_drain_all.

The first one has some problems since in our product system, all the cpus
are busy, so I guess there is very little chance for a cpu to have 0 pagevecs
except that you run several consecutive mlocks.

>From the commit log which added this function(8891d6da), it seems that we
don't have to call it. So the 2nd one seems to be both easy and workable and
comes this patch.

Thanks
Tao
