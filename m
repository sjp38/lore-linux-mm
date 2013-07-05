Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 3A6E26B0033
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 11:54:38 -0400 (EDT)
Subject: [PATCH] mm: strictlimit feature -v3
From: Maxim Patlasov <mpatlasov@parallels.com>
Date: Fri, 05 Jul 2013 19:53:36 +0400
Message-ID: <20130705155113.3586.78292.stgit@maximpc.sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, jack@suse.cz, dev@parallels.com, miklos@szeredi.hu, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, xemul@parallels.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

The feature prevents mistrusted filesystems to grow a large number of dirty
pages before throttling. For such filesystems balance_dirty_pages always
check bdi counters against bdi limits. I.e. even if global "nr_dirty" is under
"freerun", it's not allowed to skip bdi checks. The only use case for now is
fuse: it sets bdi max_ratio to 1% by default and system administrators are
supposed to expect that this limit won't be exceeded.

The feature is on if a BDI is marked by BDI_CAP_STRICTLIMIT flag.
A filesystem may set the flag when it initializes its BDI.

Changed in v2 (thanks to Andrew Morton):
 - added a few explanatory comments
 - cleaned up the mess in backing_dev_info foo_stamp fields: now it's clearly
   stated that bw_time_stamp is measured in jiffies; renamed other foo_stamp
   fields to reflect that they are in units of number-of-pages.

Changed in v3 (thanks to Jan Kara)
 - made strictlimit a bdi flag
 - introduced "bdi_dirty <= bdi_freerun" check
 - removed BDI_idle and BDI_WRITTEN_BACK as redundant
 - moved foo_stamp cleanup to separate patch because it's not related
   to strictlimit feature anymore
 - corrected spelling.

Signed-off-by: Maxim Patlasov <MPatlasov@parallels.com>
---
 fs/fuse/inode.c             |    2 
 include/linux/backing-dev.h |    3 +
 mm/page-writeback.c         |  190 ++++++++++++++++++++++++++++++++++++-------
 3 files changed, 164 insertions(+), 31 deletions(-)

diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 9a0cdde..9aa1932 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -929,7 +929,7 @@ static int fuse_bdi_init(struct fuse_conn *fc, struct super_block *sb)
 	fc->bdi.name = "fuse";
 	fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
 	/* fuse does it's own writeback accounting */
-	fc->bdi.capabilities = BDI_CAP_NO_ACCT_WB;
+	fc->bdi.capabilities = BDI_CAP_NO_ACCT_WB | BDI_CAP_STRICTLIMIT;
 
 	err = bdi_init(&fc->bdi);
 	if (err)
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index ee7eb1a..7166489 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -244,6 +244,8 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
  * BDI_CAP_EXEC_MAP:       Can be mapped for execution
  *
  * BDI_CAP_SWAP_BACKED:    Count shmem/tmpfs objects as swap-backed.
+ *
+ * BDI_CAP_STRICTLIMIT:    Keep number of dirty pages below bdi threshold.
  */
 #define BDI_CAP_NO_ACCT_DIRTY	0x00000001
 #define BDI_CAP_NO_WRITEBACK	0x00000002
@@ -255,6 +257,7 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
 #define BDI_CAP_NO_ACCT_WB	0x00000080
 #define BDI_CAP_SWAP_BACKED	0x00000100
 #define BDI_CAP_STABLE_WRITES	0x00000200
+#define BDI_CAP_STRICTLIMIT	0x00000400
 
 #define BDI_CAP_VMFLAGS \
 	(BDI_CAP_READ_MAP | BDI_CAP_WRITE_MAP | BDI_CAP_EXEC_MAP)
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 088a8db..1f9b5e4 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -585,6 +585,37 @@ unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
 }
 
 /*
+ *                           setpoint - dirty 3
+ *        f(dirty) := 1.0 + (----------------)
+ *                           limit - setpoint
+ *
+ * it's a 3rd order polynomial that subjects to
+ *
+ * (1) f(freerun)  = 2.0 => rampup dirty_ratelimit reasonably fast
+ * (2) f(setpoint) = 1.0 => the balance point
+ * (3) f(limit)    = 0   => the hard limit
+ * (4) df/dx      <= 0	 => negative feedback control
+ * (5) the closer to setpoint, the smaller |df/dx| (and the reverse)
+ *     => fast response on large errors; small oscillation near setpoint
+ */
+static inline long long pos_ratio_polynom(unsigned long setpoint,
+					  unsigned long dirty,
+					  unsigned long limit)
+{
+	long long pos_ratio;
+	long x;
+
+	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
+		    limit - setpoint + 1);
+	pos_ratio = x;
+	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
+	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
+	pos_ratio += 1 << RATELIMIT_CALC_SHIFT;
+
+	return pos_ratio;
+}
+
+/*
  * Dirty position control.
  *
  * (o) global/bdi setpoints
@@ -682,26 +713,75 @@ static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
 	/*
 	 * global setpoint
 	 *
-	 *                           setpoint - dirty 3
-	 *        f(dirty) := 1.0 + (----------------)
-	 *                           limit - setpoint
+	 * See comment for pos_ratio_polynom().
+	 */
+	setpoint = (freerun + limit) / 2;
+	pos_ratio = pos_ratio_polynom(setpoint, dirty, limit);
+
+	/*
+	 * The strictlimit feature is a tool preventing mistrusted filesystems
+	 * from growing a large number of dirty pages before throttling. For
+	 * such filesystems balance_dirty_pages always checks bdi counters
+	 * against bdi limits. Even if global "nr_dirty" is under "freerun".
+	 * This is especially important for fuse which sets bdi->max_ratio to
+	 * 1% by default. Without strictlimit feature, fuse writeback may
+	 * consume arbitrary amount of RAM because it is accounted in
+	 * NR_WRITEBACK_TEMP which is not involved in calculating "nr_dirty".
 	 *
-	 * it's a 3rd order polynomial that subjects to
+	 * Here, in bdi_position_ratio(), we calculate pos_ratio based on
+	 * two values: bdi_dirty and bdi_thresh. Let's consider an example:
+	 * total amount of RAM is 16GB, bdi->max_ratio is equal to 1%, global
+	 * limits are set by default to 10% and 20% (background and throttle).
+	 * Then bdi_thresh is 1% of 20% of 16GB. This amounts to ~8K pages.
+	 * bdi_dirty_limit(bdi, bg_thresh) is about ~4K pages. bdi_setpoint is
+	 * about ~6K pages (as the average of background and throttle bdi
+	 * limits). The 3rd order polynomial will provide positive feedback if
+	 * bdi_dirty is under bdi_setpoint and vice versa.
 	 *
-	 * (1) f(freerun)  = 2.0 => rampup dirty_ratelimit reasonably fast
-	 * (2) f(setpoint) = 1.0 => the balance point
-	 * (3) f(limit)    = 0   => the hard limit
-	 * (4) df/dx      <= 0	 => negative feedback control
-	 * (5) the closer to setpoint, the smaller |df/dx| (and the reverse)
-	 *     => fast response on large errors; small oscillation near setpoint
+	 * Note, that we cannot use global counters in these calculations
+	 * because we want to throttle process writing to a strictlimit BDI
+	 * much earlier than global "freerun" is reached (~23MB vs. ~2.3GB
+	 * in the example above).
 	 */
-	setpoint = (freerun + limit) / 2;
-	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
-		    limit - setpoint + 1);
-	pos_ratio = x;
-	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
-	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
-	pos_ratio += 1 << RATELIMIT_CALC_SHIFT;
+	if (unlikely(bdi->capabilities & BDI_CAP_STRICTLIMIT)) {
+		long long bdi_pos_ratio;
+		unsigned long bdi_bg_thresh;
+
+		if (bdi_dirty < 8)
+			return min_t(long long, pos_ratio * 2,
+				     2 << RATELIMIT_CALC_SHIFT);
+
+		if (bdi_dirty >= bdi_thresh)
+			return 0;
+
+		bdi_bg_thresh = div_u64((u64)bdi_thresh * bg_thresh, thresh);
+		bdi_setpoint = dirty_freerun_ceiling(bdi_thresh,
+						     bdi_bg_thresh);
+
+		if (bdi_setpoint == 0 || bdi_setpoint == bdi_thresh)
+			return 0;
+
+		bdi_pos_ratio = pos_ratio_polynom(bdi_setpoint, bdi_dirty,
+						  bdi_thresh);
+
+		/*
+		 * Typically, for strictlimit case, bdi_setpoint << setpoint
+		 * and pos_ratio >> bdi_pos_ratio. In the other words global
+		 * state ("dirty") is not limiting factor and we have to
+		 * make decision based on bdi counters. But there is an
+		 * important case when global pos_ratio should get precedence:
+		 * global limits are exceeded (e.g. due to activities on other
+		 * BDIs) while given strictlimit BDI is below limit.
+		 *
+		 * "pos_ratio * bdi_pos_ratio" would work for the case above,
+		 * but it would look too non-natural for the case of all
+		 * activity in the system coming from a single strictlimit BDI
+		 * with bdi->max_ratio == 100%.
+		 */
+		pos_ratio = min(pos_ratio, bdi_pos_ratio);
+
+		return min_t(long long, pos_ratio, 2 << RATELIMIT_CALC_SHIFT);
+	}
 
 	/*
 	 * We have computed basic pos_ratio above based on global situation. If
@@ -994,6 +1074,27 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
 	 * keep that period small to reduce time lags).
 	 */
 	step = 0;
+
+	/*
+	 * For strictlimit case, calculations above were based on bdi counters
+	 * and limits (starting from pos_ratio = bdi_position_ratio() and up to
+	 * balanced_dirty_ratelimit = task_ratelimit * write_bw / dirty_rate).
+	 * Hence, to calculate "step" properly, we have to use bdi_dirty as
+	 * "dirty" and bdi_setpoint as "setpoint".
+	 *
+	 * We rampup dirty_ratelimit forcibly if bdi_dirty is low because
+	 * it's possible that bdi_thresh is close to zero due to inactivity
+	 * of backing device (see the implementation of bdi_dirty_limit()).
+	 */
+	if (unlikely(bdi->capabilities & BDI_CAP_STRICTLIMIT)) {
+		dirty = bdi_dirty;
+		if (bdi_dirty < 8)
+			setpoint = bdi_dirty + 1;
+		else
+			setpoint = (bdi_thresh +
+				    bdi_dirty_limit(bdi, bg_thresh)) / 2;
+	}
+
 	if (dirty < setpoint) {
 		x = min(bdi->balanced_dirty_ratelimit,
 			 min(balanced_dirty_ratelimit, task_ratelimit));
@@ -1198,6 +1299,21 @@ static long bdi_min_pause(struct backing_dev_info *bdi,
 	return pages >= DIRTY_POLL_THRESH ? 1 + t / 2 : t;
 }
 
+static inline bool below_freerun_ceiling(unsigned long nr,
+					 unsigned long thresh,
+					 unsigned long bg_thresh,
+					 unsigned long now)
+{
+	if (nr <= dirty_freerun_ceiling(thresh, bg_thresh)) {
+		current->dirty_paused_when = now;
+		current->nr_dirtied = 0;
+		current->nr_dirtied_pause = dirty_poll_interval(nr, thresh);
+		return true;
+	}
+
+	return false;
+}
+
 /*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
@@ -1212,7 +1328,6 @@ static void balance_dirty_pages(struct address_space *mapping,
 	unsigned long bdi_reclaimable;
 	unsigned long nr_dirty;  /* = file_dirty + writeback + unstable_nfs */
 	unsigned long bdi_dirty;
-	unsigned long freerun;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
@@ -1226,6 +1341,7 @@ static void balance_dirty_pages(struct address_space *mapping,
 	unsigned long dirty_ratelimit;
 	unsigned long pos_ratio;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	bool strictlimit = bdi->capabilities & BDI_CAP_STRICTLIMIT;
 	unsigned long start_time = jiffies;
 
 	for (;;) {
@@ -1248,18 +1364,10 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * catch-up. This avoids (excessively) small writeouts
 		 * when the bdi limits are ramping up.
 		 */
-		freerun = dirty_freerun_ceiling(dirty_thresh,
-						background_thresh);
-		if (nr_dirty <= freerun) {
-			current->dirty_paused_when = now;
-			current->nr_dirtied = 0;
-			current->nr_dirtied_pause =
-				dirty_poll_interval(nr_dirty, dirty_thresh);
+		if (likely(!strictlimit) &&
+		    below_freerun_ceiling(nr_dirty, dirty_thresh,
+					  background_thresh, now))
 			break;
-		}
-
-		if (unlikely(!writeback_in_progress(bdi)))
-			bdi_start_background_writeback(bdi);
 
 		/*
 		 * bdi_thresh is not treated as some limiting factor as
@@ -1296,8 +1404,30 @@ static void balance_dirty_pages(struct address_space *mapping,
 				    bdi_stat(bdi, BDI_WRITEBACK);
 		}
 
+		/*
+		 * Throttle it only when the background writeback cannot
+		 * catch-up. But this time (strictlimit case) make decision
+		 * based on the bdi counters and limits. Small writeouts when
+		 * the bdi limits are ramping up are the price we consciously
+		 * pay for strictlimit-ing.
+		 */
+		if (unlikely(strictlimit)) {
+			unsigned long bdi_bg_thresh;
+
+			bdi_bg_thresh = div_u64((u64)bdi_thresh *
+						background_thresh,
+						dirty_thresh);
+
+			if (below_freerun_ceiling(bdi_dirty, bdi_thresh,
+						  bdi_bg_thresh, now))
+				break;
+		}
+
+		if (unlikely(!writeback_in_progress(bdi)))
+			bdi_start_background_writeback(bdi);
+
 		dirty_exceeded = (bdi_dirty > bdi_thresh) &&
-				  (nr_dirty > dirty_thresh);
+				 ((nr_dirty > dirty_thresh) || strictlimit);
 		if (dirty_exceeded && !bdi->dirty_exceeded)
 			bdi->dirty_exceeded = 1;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
