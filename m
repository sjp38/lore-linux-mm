Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 21DA36B00F6
	for <linux-mm@kvack.org>; Thu,  3 May 2012 10:57:23 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so1608175wgb.26
        for <linux-mm@kvack.org>; Thu, 03 May 2012 07:57:21 -0700 (PDT)
From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH v1 4/6] mm: make lru_drain selective where it schedules work
Date: Thu,  3 May 2012 17:56:00 +0300
Message-Id: <1336056962-10465-5-git-send-email-gilad@benyossef.com>
In-Reply-To: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

lru drain work is being done by scheduling a work queue on each
CPU, whether it has LRU pages to drain or not, thus creating
interference on isolated CPUs.

This patch uses schedule_on_each_cpu_cond() to schedule the work
only on CPUs where it seems that there are LRUs to drain.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Tejun Heo <tj@kernel.org>
CC: John Stultz <johnstul@us.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Mel Gorman <mel@csn.ul.ie>
CC: Mike Frysinger <vapier@gentoo.org>
CC: David Rientjes <rientjes@google.com>
CC: Hugh Dickins <hughd@google.com>
CC: Minchan Kim <minchan.kim@gmail.com>
CC: Konstantin Khlebnikov <khlebnikov@openvz.org>
CC: Christoph Lameter <cl@linux.com>
CC: Chris Metcalf <cmetcalf@tilera.com>
CC: Hakan Akkan <hakanakkan@gmail.com>
CC: Max Krasnyansky <maxk@qualcomm.com>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: linux-kernel@vger.kernel.org
CC: linux-mm@kvack.org
---
 mm/swap.c |   25 ++++++++++++++++++++++++-
 1 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 5c13f13..ab07b62 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -562,12 +562,35 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
 	lru_add_drain();
 }
 
+static bool lru_drain_cpu(int cpu)
+{
+	struct pagevec *pvecs = per_cpu(lru_add_pvecs, cpu);
+	struct pagevec *pvec;
+	int lru;
+
+	for_each_lru(lru) {
+		pvec = &pvecs[lru - LRU_BASE];
+		if (pagevec_count(pvec))
+			return true;
+	}
+
+	pvec = &per_cpu(lru_rotate_pvecs, cpu);
+	if (pagevec_count(pvec))
+		return true;
+
+	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
+	if (pagevec_count(pvec))
+		return true;
+
+	return false;
+}
+
 /*
  * Returns 0 for success
  */
 int lru_add_drain_all(void)
 {
-	return schedule_on_each_cpu(lru_add_drain_per_cpu);
+	return schedule_on_each_cpu_cond(lru_add_drain_per_cpu, lru_drain_cpu);
 }
 
 /*
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
