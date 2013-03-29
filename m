Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id AC64C6B0078
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 05:14:49 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 19/28] hugepage: convert huge zero page shrinker to new shrinker API
Date: Fri, 29 Mar 2013 13:14:01 +0400
Message-Id: <1364548450-28254-20-git-send-email-glommer@parallels.com>
In-Reply-To: <1364548450-28254-1-git-send-email-glommer@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Glauber Costa <glommer@parallels.com>, Dave Chinner <dchinner@redhat.com>

It consists of:

* returning long instead of int
* separating count from scan
* returning the number of freed entities in scan

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Dave Chinner <dchinner@redhat.com>
---
 mm/huge_memory.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e2f7f5aa..8bf43d3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -212,24 +212,30 @@ static void put_huge_zero_page(void)
 	BUG_ON(atomic_dec_and_test(&huge_zero_refcount));
 }
 
-static int shrink_huge_zero_page(struct shrinker *shrink,
-		struct shrink_control *sc)
+
+static long shrink_huge_zero_page_count(struct shrinker *shrink,
+					struct shrink_control *sc)
 {
-	if (!sc->nr_to_scan)
-		/* we can free zero page only if last reference remains */
-		return atomic_read(&huge_zero_refcount) == 1 ? HPAGE_PMD_NR : 0;
+	/* we can free zero page only if last reference remains */
+	return atomic_read(&huge_zero_refcount) == 1 ? HPAGE_PMD_NR : 0;
+}
 
+static long shrink_huge_zero_page_scan(struct shrinker *shrink,
+				       struct shrink_control *sc)
+{
 	if (atomic_cmpxchg(&huge_zero_refcount, 1, 0) == 1) {
 		unsigned long zero_pfn = xchg(&huge_zero_pfn, 0);
 		BUG_ON(zero_pfn == 0);
 		__free_page(__pfn_to_page(zero_pfn));
+		return HPAGE_PMD_NR;
 	}
 
 	return 0;
 }
 
 static struct shrinker huge_zero_page_shrinker = {
-	.shrink = shrink_huge_zero_page,
+	.scan_objects = shrink_huge_zero_page_scan,
+	.count_objects = shrink_huge_zero_page_count,
 	.seeks = DEFAULT_SEEKS,
 };
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
