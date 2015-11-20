Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E6FA66B0038
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 12:03:08 -0500 (EST)
Received: by padhx2 with SMTP id hx2so121691457pad.1
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 09:03:08 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id px4si481561pac.14.2015.11.20.09.03.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Nov 2015 09:03:07 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] vmscan: do not force-scan file lru if its absolute size is small
Date: Fri, 20 Nov 2015 20:02:56 +0300
Message-ID: <1448038976-28796-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We assume there is enough inactive page cache if the size of inactive
file lru is greater than the size of active file lru, in which case we
force-scan file lru ignoring anonymous pages. While this logic works
fine when there are plenty of page cache pages, it fails if the size of
file lru is small (several MB): in this case (lru_size >> prio) will be
0 for normal scan priorities, as a result, if inactive file lru happens
to be larger than active file lru, anonymous pages of a cgroup will
never get evicted unless the system experiences severe memory pressure,
even if there are gigabytes of unused anonymous memory there, which is
unfair in respect to other cgroups, whose workloads might be page cache
oriented.

This patch attempts to fix this by elaborating the "enough inactive page
cache" check: it makes it not only check that inactive lru size > active
lru size, but also that we will scan something from the cgroup at the
current scan priority. If these conditions do not hold, we proceed to
SCAN_FRACT as usual.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 mm/vmscan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bd2918e6391a..2c9b2a053987 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2046,7 +2046,8 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 	 * There is enough inactive page cache, do not reclaim
 	 * anything from the anonymous working set right now.
 	 */
-	if (!inactive_file_is_low(lruvec)) {
+	if (!inactive_file_is_low(lruvec) &&
+	    get_lru_size(lruvec, LRU_INACTIVE_FILE) >> sc->priority > 0) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
