Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0AB816B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 05:39:47 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so193226060pab.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 02:39:46 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id kn1si18966565pbc.209.2015.11.23.02.39.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 02:39:46 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v2] vmscan: do not force-scan file lru if its absolute size is small
Date: Mon, 23 Nov 2015 13:39:33 +0300
Message-ID: <1448275173-10538-1-git-send-email-vdavydov@virtuozzo.com>
In-Reply-To: <20151120134311.8ff0947215fc522f72f791fe@linux-foundation.org>
References: <20151120134311.8ff0947215fc522f72f791fe@linux-foundation.org>
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
Changes in v2:
 - remove unnecessary > 0 (Johannes)
 - elaborate on the comment (Andrew)

 mm/vmscan.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bd2918e6391a..97ba9e1cde09 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2043,10 +2043,16 @@ static void get_scan_count(struct lruvec *lruvec, int swappiness,
 	}
 
 	/*
-	 * There is enough inactive page cache, do not reclaim
-	 * anything from the anonymous working set right now.
+	 * If there is enough inactive page cache, i.e. if the size of the
+	 * inactive list is greater than that of the active list *and* the
+	 * inactive list actually has some pages to scan on this priority, we
+	 * do not reclaim anything from the anonymous working set right now.
+	 * Without the second condition we could end up never scanning an
+	 * lruvec even if it has plenty of old anonymous pages unless the
+	 * system is under heavy pressure.
 	 */
-	if (!inactive_file_is_low(lruvec)) {
+	if (!inactive_file_is_low(lruvec) &&
+	    get_lru_size(lruvec, LRU_INACTIVE_FILE) >> sc->priority) {
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
