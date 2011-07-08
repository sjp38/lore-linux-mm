Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9EF9E90011A
	for <linux-mm@kvack.org>; Fri,  8 Jul 2011 00:15:06 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 05/14] vmscan: add customisable shrinker batch size
Date: Fri,  8 Jul 2011 14:14:37 +1000
Message-Id: <1310098486-6453-6-git-send-email-david@fromorbit.com>
In-Reply-To: <1310098486-6453-1-git-send-email-david@fromorbit.com>
References: <1310098486-6453-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Dave Chinner <dchinner@redhat.com>

For shrinkers that have their own cond_resched* calls, having
shrink_slab break the work down into small batches is not
paticularly efficient. Add a custom batchsize field to the struct
shrinker so that shrinkers can use a larger batch size if they
desire.

A value of zero (uninitialised) means "use the default", so
behaviour is unchanged by this patch.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 include/linux/mm.h |    1 +
 mm/vmscan.c        |   11 ++++++-----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9670f71..9b9777a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1150,6 +1150,7 @@ struct shrink_control {
 struct shrinker {
 	int (*shrink)(struct shrinker *, struct shrink_control *sc);
 	int seeks;	/* seeks to recreate an obj */
+	long batch;	/* reclaim batch size, 0 = default */
 
 	/* These are for internal use */
 	struct list_head list;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 01036ed..afaedc0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -253,6 +253,8 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 		int shrink_ret = 0;
 		long nr;
 		long new_nr;
+		long batch_size = shrinker->batch ? shrinker->batch
+						  : SHRINK_BATCH;
 
 		/*
 		 * copy the current shrinker scan count into a local variable
@@ -303,19 +305,18 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 					nr_pages_scanned, lru_pages,
 					max_pass, delta, total_scan);
 
-		while (total_scan >= SHRINK_BATCH) {
-			long this_scan = SHRINK_BATCH;
+		while (total_scan >= batch_size) {
 			int nr_before;
 
 			nr_before = do_shrinker_shrink(shrinker, shrink, 0);
 			shrink_ret = do_shrinker_shrink(shrinker, shrink,
-							this_scan);
+							batch_size);
 			if (shrink_ret == -1)
 				break;
 			if (shrink_ret < nr_before)
 				ret += nr_before - shrink_ret;
-			count_vm_events(SLABS_SCANNED, this_scan);
-			total_scan -= this_scan;
+			count_vm_events(SLABS_SCANNED, batch_size);
+			total_scan -= batch_size;
 
 			cond_resched();
 		}
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
