Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id ABF5F6B006C
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 13:28:40 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id v10so1669935pde.40
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 10:28:40 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id kb9si15303593pbb.74.2014.12.19.10.28.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Dec 2014 10:28:39 -0800 (PST)
Date: Fri, 19 Dec 2014 21:28:15 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 1/2] mm, vmscan: prevent kswapd livelock due to
 pfmemalloc-throttled process being killed
Message-ID: <20141219182815.GK18274@esperanza>
References: <1418994116-23665-1-git-send-email-vbabka@suse.cz>
 <20141219155747.GA31756@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20141219155747.GA31756@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, stable@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

Hi,

On Fri, Dec 19, 2014 at 04:57:47PM +0100, Michal Hocko wrote:
> On Fri 19-12-14 14:01:55, Vlastimil Babka wrote:
> > Charles Shirron and Paul Cassella from Cray Inc have reported kswapd stuck
> > in a busy loop with nothing left to balance, but kswapd_try_to_sleep() failing
> > to sleep. Their analysis found the cause to be a combination of several
> > factors:
> > 
> > 1. A process is waiting in throttle_direct_reclaim() on pgdat->pfmemalloc_wait
> > 
> > 2. The process has been killed (by OOM in this case), but has not yet been
> >    scheduled to remove itself from the waitqueue and die.
> 
> pfmemalloc_wait is used as wait_event and that one uses
> autoremove_wake_function for wake ups so the task shouldn't stay on the
> queue if it was woken up. Moreover pfmemalloc_wait sleeps are killable
> by the OOM killer AFAICS.
> 
> $ git grep "wait_event.*pfmemalloc_wait"
> mm/vmscan.c:
> wait_event_interruptible_timeout(pgdat->pfmemalloc_wait,
> mm/vmscan.c:    wait_event_killable(zone->zone_pgdat->pfmemalloc_wait,))
> 
> So OOM killer would wake it up already and kswapd shouldn't see this
> task on the waitqueue anymore.

OOM killer will wake up the process, but it won't remove it from the
pfmemalloc_wait queue. Therefore, if kswapd gets scheduled before the
dying process, it will see the wait queue being still active, but won't
be able to wake anyone up, because the waiting process has already been
woken by SIGKILL. I think this is what Vlastimil means.

So AFAIU the problem does exist. However, I think it could be fixed by
simply waking up all processes waiting on pfmemalloc_wait before putting
kswapd to sleep:

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 744e2b491527..2a123634c220 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2984,6 +2984,9 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 	if (remaining)
 		return false;
 
+	if (!pgdat_balanced(pgdat, order, classzone_idx))
+		return false;
+
 	/*
 	 * There is a potential race between when kswapd checks its watermarks
 	 * and a process gets throttled. There is also a potential race if
@@ -2993,12 +2996,9 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 	 * so wake them now if necessary. If necessary, processes will wake
 	 * kswapd and get throttled again
 	 */
-	if (waitqueue_active(&pgdat->pfmemalloc_wait)) {
-		wake_up(&pgdat->pfmemalloc_wait);
-		return false;
-	}
+	wake_up_all(&pgdat->pfmemalloc_wait);
 
-	return pgdat_balanced(pgdat, order, classzone_idx);
+	return true;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
