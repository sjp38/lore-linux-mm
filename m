Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5964C6B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 13:24:32 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id b11-v6so1361586pla.19
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 10:24:32 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0104.outbound.protection.outlook.com. [104.47.1.104])
        by mx.google.com with ESMTPS id u10si7277005pgp.45.2018.04.06.10.24.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 06 Apr 2018 10:24:30 -0700 (PDT)
Subject: Re: [PATCH v2 3/4] mm/vmscan: Don't change pgdat state on base of a
 single LRU list state.
References: <20180323152029.11084-1-aryabinin@virtuozzo.com>
 <20180323152029.11084-4-aryabinin@virtuozzo.com>
 <20180406162835.GD20806@cmpxchg.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <312906df-80c4-aaaf-3d0f-caaeeceb9f39@virtuozzo.com>
Date: Fri, 6 Apr 2018 20:25:10 +0300
MIME-Version: 1.0
In-Reply-To: <20180406162835.GD20806@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org



On 04/06/2018 07:28 PM, Johannes Weiner wrote:
> 
> This isn't quite equivalent to what we have right now.
> 
> Yes, nr_dirty, nr_unqueued_dirty and nr_congested apply to file pages
> only. That part is about waking the flushers and avoiding writing
> files in 4k chunks from reclaim context. So those numbers do need to
> be compared against scanned *file* pages.
> 
> But nr_writeback and nr_immediate is about throttling reclaim when we
> hit too many pages under writeout, and that applies to both file and
> anonymous/swap pages. We do want to throttle on swapout, too.
> 
> So nr_writeback needs to check against all nr_taken, not just file.
> 

Agreed, the fix bellow. It causes conflict in the next 4/4 patch,
so I'll just send v3 with all fixes folded.

---
 mm/vmscan.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4d848b8df01f..c45497475e84 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -124,6 +124,7 @@ struct scan_control {
 		unsigned int writeback;
 		unsigned int immediate;
 		unsigned int file_taken;
+		unsigned int taken;
 	} nr;
 };
 
@@ -1771,6 +1772,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	sc->nr.unqueued_dirty += stat.nr_unqueued_dirty;
 	sc->nr.writeback += stat.nr_writeback;
 	sc->nr.immediate += stat.nr_immediate;
+	sc->nr.taken += nr_taken;
 	if (file)
 		sc->nr.file_taken += nr_taken;
 
@@ -2553,7 +2555,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 		 * number of pages under pages flagged for immediate reclaim and
 		 * stall if any are encountered in the nr_immediate check below.
 		 */
-		if (sc->nr.writeback && sc->nr.writeback == sc->nr.file_taken)
+		if (sc->nr.writeback && sc->nr.writeback == sc->nr.taken)
 			set_bit(PGDAT_WRITEBACK, &pgdat->flags);
 
 		/*
-- 
2.16.1
