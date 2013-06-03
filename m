Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 3907A6B004D
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 15:37:29 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v10 23/35] hugepage: convert huge zero page shrinker to new shrinker API
Date: Mon,  3 Jun 2013 23:29:52 +0400
Message-Id: <1370287804-3481-24-git-send-email-glommer@openvz.org>
In-Reply-To: <1370287804-3481-1-git-send-email-glommer@openvz.org>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>

It consists of:

* returning long instead of int
* separating count from scan
* returning the number of freed entities in scan

Signed-off-by: Glauber Costa <glommer@openvz.org>
Reviewed-by: Greg Thelen <gthelen@google.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
CC: Dave Chinner <dchinner@redhat.com>
---
 mm/huge_memory.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 243e710..8dc36f5 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -211,24 +211,29 @@ static void put_huge_zero_page(void)
 	BUG_ON(atomic_dec_and_test(&huge_zero_refcount));
 }
 
-static int shrink_huge_zero_page(struct shrinker *shrink,
-		struct shrink_control *sc)
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
 		struct page *zero_page = xchg(&huge_zero_page, NULL);
 		BUG_ON(zero_page == NULL);
 		__free_page(zero_page);
+		return HPAGE_PMD_NR;
 	}
 
 	return 0;
 }
 
 static struct shrinker huge_zero_page_shrinker = {
-	.shrink = shrink_huge_zero_page,
+	.count_objects = shrink_huge_zero_page_count,
+	.scan_objects = shrink_huge_zero_page_scan,
 	.seeks = DEFAULT_SEEKS,
 };
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
