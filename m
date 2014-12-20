Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id DA6376B0032
	for <linux-mm@kvack.org>; Sat, 20 Dec 2014 09:18:47 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so3015718pab.34
        for <linux-mm@kvack.org>; Sat, 20 Dec 2014 06:18:47 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id id2si18179025pad.93.2014.12.20.06.18.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Dec 2014 06:18:46 -0800 (PST)
Date: Sat, 20 Dec 2014 17:18:24 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 1/2] mm, vmscan: prevent kswapd livelock due to
 pfmemalloc-throttled process being killed
Message-ID: <20141220141824.GM18274@esperanza>
References: <1418994116-23665-1-git-send-email-vbabka@suse.cz>
 <20141219155747.GA31756@dhcp22.suse.cz>
 <20141219182815.GK18274@esperanza>
 <20141220104746.GB6306@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20141220104746.GB6306@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, stable@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Sat, Dec 20, 2014 at 11:47:46AM +0100, Michal Hocko wrote:
> On Fri 19-12-14 21:28:15, Vladimir Davydov wrote:
> > So AFAIU the problem does exist. However, I think it could be fixed by
> > simply waking up all processes waiting on pfmemalloc_wait before putting
> > kswapd to sleep:
> 
> I think that a simple cond_resched() in kswapd_try_to_sleep should be
> sufficient and less risky fix, so basically what Vlastimil was proposing
> in the beginning.

With such a solution we implicitly rely upon the scheduler
implementation, which AFAIU is wrong. E.g. suppose processes are
governed by FIFO and kswapd happens to have a higher prio than the
process killed by OOM. Then after cond_resched kswapd will be picked for
execution again, and the killing process won't have a chance to remove
itself from the wait queue.

> 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 744e2b491527..2a123634c220 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2984,6 +2984,9 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
> >  	if (remaining)
> >  		return false;
> >  
> > +	if (!pgdat_balanced(pgdat, order, classzone_idx))
> > +		return false;
> > +
> 
> What would be consequences of not waking up pfmemalloc waiters while the
> node is not balanced?

They will get woken up a bit later in balanced_pgdat. This might result
in latency spikes though. In order not to change the original behaviour
we could always wake all pfmemalloc waiters no matter if we are going to
sleep or not:

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 744e2b491527..a21e0bd563c3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2993,10 +2993,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 	 * so wake them now if necessary. If necessary, processes will wake
 	 * kswapd and get throttled again
 	 */
-	if (waitqueue_active(&pgdat->pfmemalloc_wait)) {
-		wake_up(&pgdat->pfmemalloc_wait);
-		return false;
-	}
+	wake_up_all(&pgdat->pfmemalloc_wait);
 
 	return pgdat_balanced(pgdat, order, classzone_idx);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
