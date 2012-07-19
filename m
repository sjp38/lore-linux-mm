Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 2408D6B0070
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 10:36:52 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/34] vmscan: shrinker->nr updates race and go wrong
Date: Thu, 19 Jul 2012 15:36:17 +0100
Message-Id: <1342708604-26540-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1342708604-26540-1-git-send-email-mgorman@suse.de>
References: <1342708604-26540-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: "Linux-MM <linux-mm"@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Dave Chinner <dchinner@redhat.com>

commit acf92b485cccf028177f46918e045c0c4e80ee10 upstream.

Stable note: Not tracked in Bugzilla. This patch reduces excessive
	reclaim of slab objects reducing the amount of information
	that has to be brought back in from disk.

shrink_slab() allows shrinkers to be called in parallel so the
struct shrinker can be updated concurrently. It does not provide any
exclusion for such updates, so we can get the shrinker->nr value
increasing or decreasing incorrectly.

As a result, when a shrinker repeatedly returns a value of -1 (e.g.
a VFS shrinker called w/ GFP_NOFS), the shrinker->nr goes haywire,
sometimes updating with the scan count that wasn't used, sometimes
losing it altogether. Worse is when a shrinker does work and that
update is lost due to racy updates, which means the shrinker will do
the work again!

Fix this by making the total_scan calculations independent of
shrinker->nr, and making the shrinker->nr updates atomic w.r.t. to
other updates via cmpxchg loops.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |   45 ++++++++++++++++++++++++++++++++-------------
 1 file changed, 32 insertions(+), 13 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d875058..31b551e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -251,17 +251,29 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 		unsigned long total_scan;
 		unsigned long max_pass;
 		int shrink_ret = 0;
+		long nr;
+		long new_nr;
 
+		/*
+		 * copy the current shrinker scan count into a local variable
+		 * and zero it so that other concurrent shrinker invocations
+		 * don't also do this scanning work.
+		 */
+		do {
+			nr = shrinker->nr;
+		} while (cmpxchg(&shrinker->nr, nr, 0) != nr);
+
+		total_scan = nr;
 		max_pass = do_shrinker_shrink(shrinker, shrink, 0);
 		delta = (4 * nr_pages_scanned) / shrinker->seeks;
 		delta *= max_pass;
 		do_div(delta, lru_pages + 1);
-		shrinker->nr += delta;
-		if (shrinker->nr < 0) {
+		total_scan += delta;
+		if (total_scan < 0) {
 			printk(KERN_ERR "shrink_slab: %pF negative objects to "
 			       "delete nr=%ld\n",
-			       shrinker->shrink, shrinker->nr);
-			shrinker->nr = max_pass;
+			       shrinker->shrink, total_scan);
+			total_scan = max_pass;
 		}
 
 		/*
@@ -269,13 +281,10 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 		 * never try to free more than twice the estimate number of
 		 * freeable entries.
 		 */
-		if (shrinker->nr > max_pass * 2)
-			shrinker->nr = max_pass * 2;
-
-		total_scan = shrinker->nr;
-		shrinker->nr = 0;
+		if (total_scan > max_pass * 2)
+			total_scan = max_pass * 2;
 
-		trace_mm_shrink_slab_start(shrinker, shrink, total_scan,
+		trace_mm_shrink_slab_start(shrinker, shrink, nr,
 					nr_pages_scanned, lru_pages,
 					max_pass, delta, total_scan);
 
@@ -296,9 +305,19 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 			cond_resched();
 		}
 
-		shrinker->nr += total_scan;
-		trace_mm_shrink_slab_end(shrinker, shrink_ret, total_scan,
-					 shrinker->nr);
+		/*
+		 * move the unused scan count back into the shrinker in a
+		 * manner that handles concurrent updates. If we exhausted the
+		 * scan, there is no need to do an update.
+		 */
+		do {
+			nr = shrinker->nr;
+			new_nr = total_scan + nr;
+			if (total_scan <= 0)
+				break;
+		} while (cmpxchg(&shrinker->nr, nr, new_nr) != nr);
+
+		trace_mm_shrink_slab_end(shrinker, shrink_ret, nr, new_nr);
 	}
 	up_read(&shrinker_rwsem);
 out:
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
