Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 511F56B0089
	for <linux-mm@kvack.org>; Thu,  9 May 2013 02:07:13 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v5 19/31] hugepage: convert huge zero page shrinker to new shrinker API
Date: Thu,  9 May 2013 10:06:36 +0400
Message-Id: <1368079608-5611-20-git-send-email-glommer@openvz.org>
In-Reply-To: <1368079608-5611-1-git-send-email-glommer@openvz.org>
References: <1368079608-5611-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

It consists of:

* returning long instead of int
* separating count from scan
* returning the number of freed entities in scan

Signed-off-by: Glauber Costa <glommer@openvz.org>
Reviewed-by: Greg Thelen <gthelen@google.com>
CC: Dave Chinner <dchinner@redhat.com>
CC: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4cb1684..ecfe285 100644
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
