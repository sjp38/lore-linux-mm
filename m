Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AE3826B016B
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 06:17:32 -0400 (EDT)
Subject: [PATCH 2/2] vmscan: use atomic-long for shrinker batching
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 22 Aug 2011 14:17:27 +0300
Message-ID: <20110822101727.19462.55289.stgit@zurg>
In-Reply-To: <20110822101721.19462.63082.stgit@zurg>
References: <20110822101721.19462.63082.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org

Use atomic-long operations instead of looping around cmpxchg().

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/shrinker.h |    2 +-
 mm/vmscan.c              |   17 +++++++----------
 2 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 790651b..ac6b8ee 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -34,7 +34,7 @@ struct shrinker {
 
 	/* These are for internal use */
 	struct list_head list;
-	long nr;	/* objs pending delete */
+	atomic_long_t nr_in_batch; /* objs pending delete */
 };
 #define DEFAULT_SEEKS 2 /* A good number if you don't know better. */
 extern void register_shrinker(struct shrinker *);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f174561..e31c3e2 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -184,7 +184,7 @@ static unsigned long zone_nr_lru_pages(struct zone *zone,
  */
 void register_shrinker(struct shrinker *shrinker)
 {
-	shrinker->nr = 0;
+	atomic_long_set(&shrinker->nr_in_batch, 0);
 	down_write(&shrinker_rwsem);
 	list_add_tail(&shrinker->list, &shrinker_list);
 	up_write(&shrinker_rwsem);
@@ -265,9 +265,7 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 		 * and zero it so that other concurrent shrinker invocations
 		 * don't also do this scanning work.
 		 */
-		do {
-			nr = shrinker->nr;
-		} while (cmpxchg(&shrinker->nr, nr, 0) != nr);
+		nr = atomic_long_xchg(&shrinker->nr_in_batch, 0);
 
 		total_scan = nr;
 		delta = (4 * nr_pages_scanned) / shrinker->seeks;
@@ -329,12 +327,11 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 		 * manner that handles concurrent updates. If we exhausted the
 		 * scan, there is no need to do an update.
 		 */
-		do {
-			nr = shrinker->nr;
-			new_nr = total_scan + nr;
-			if (total_scan <= 0)
-				break;
-		} while (cmpxchg(&shrinker->nr, nr, new_nr) != nr);
+		if (total_scan > 0)
+			new_nr = atomic_long_add_return(total_scan,
+					&shrinker->nr_in_batch);
+		else
+			new_nr = atomic_long_read(&shrinker->nr_in_batch);
 
 		trace_mm_shrink_slab_end(shrinker, shrink_ret, nr, new_nr);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
