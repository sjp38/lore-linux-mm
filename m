From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 16/16] bdi: convert bdi_writeback_congested.refcnt from atomic_t to refcount_t
Date: Wed, 15 Nov 2017 16:03:40 +0200
Message-ID: <1510754620-27088-17-git-send-email-elena.reshetova@intel.com>
References: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1510754620-27088-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-fsdevel-owner@vger.kernel.org
To: mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, tj@kernel.org, hannes@cmpxchg.org, lizefan@huawei.com, acme@kernel.org, alexander.shishkin@linux.intel.com, eparis@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, keescook@chromium.org, tglx@linutronix.de, dvhart@infradead.org, ebiederm@xmission.com, linux-mm@kvack.org, axboe@kernel.dk, Elena Reshetova <elena.reshetova@intel.com>
List-Id: linux-mm.kvack.org

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable bdi_writeback_congested.refcnt is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

**Important note for maintainers:

Some functions from refcount_t API defined in lib/refcount.c
have different memory ordering guarantees than their atomic
counterparts.
The full comparison can be seen in
https://lkml.org/lkml/2017/11/15/57 and it is hopefully soon
in state to be merged to the documentation tree.
Normally the differences should not matter since refcount_t provides
enough guarantees to satisfy the refcounting use cases, but in
some rare cases it might matter.
Please double check that you don't have some undocumented
memory guarantees for this variable usage.

For the bdi_writeback_congested.refcnt it might make a difference
in following places:
 - wb_congested_put() in include/linux/backing-dev.h:
   decrement in refcount_dec_and_test() only
   provides RELEASE ordering and control dependency on success
   vs. fully ordered atomic counterpart
 - wb_congested_put() in mm/backing-dev.c: decrement in
   refcount_dec_and_lock() only
   provides RELEASE ordering, control dependency on success
   and hold spin_lock() on success vs. fully ordered atomic
   counterpart. Note, there is no difference in spin lock
   locking.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 include/linux/backing-dev-defs.h |  3 ++-
 include/linux/backing-dev.h      |  4 ++--
 mm/backing-dev.c                 | 14 ++++++++------
 3 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/include/linux/backing-dev-defs.h b/include/linux/backing-dev-defs.h
index bfe86b5..0b1bcce 100644
--- a/include/linux/backing-dev-defs.h
+++ b/include/linux/backing-dev-defs.h
@@ -5,6 +5,7 @@
 #include <linux/list.h>
 #include <linux/radix-tree.h>
 #include <linux/rbtree.h>
+#include <linux/refcount.h>
 #include <linux/spinlock.h>
 #include <linux/percpu_counter.h>
 #include <linux/percpu-refcount.h>
@@ -76,7 +77,7 @@ enum wb_reason {
  */
 struct bdi_writeback_congested {
 	unsigned long state;		/* WB_[a]sync_congested flags */
-	atomic_t refcnt;		/* nr of attached wb's and blkg */
+	refcount_t refcnt;		/* nr of attached wb's and blkg */
 
 #ifdef CONFIG_CGROUP_WRITEBACK
 	struct backing_dev_info *__bdi;	/* the associated bdi, set to NULL
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index e54e7e0..d6bac2e 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -402,13 +402,13 @@ static inline bool inode_cgwb_enabled(struct inode *inode)
 static inline struct bdi_writeback_congested *
 wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
 {
-	atomic_inc(&bdi->wb_congested->refcnt);
+	refcount_inc(&bdi->wb_congested->refcnt);
 	return bdi->wb_congested;
 }
 
 static inline void wb_congested_put(struct bdi_writeback_congested *congested)
 {
-	if (atomic_dec_and_test(&congested->refcnt))
+	if (refcount_dec_and_test(&congested->refcnt))
 		kfree(congested);
 }
 
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 74b52df..e92a20f 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -440,14 +440,17 @@ wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
 			node = &parent->rb_left;
 		else if (congested->blkcg_id > blkcg_id)
 			node = &parent->rb_right;
-		else
-			goto found;
+		else {
+			refcount_inc(&congested->refcnt);
+ 			goto found;
+		}
 	}
 
 	if (new_congested) {
 		/* !found and storage for new one already allocated, insert */
 		congested = new_congested;
 		new_congested = NULL;
+		refcount_set(&congested->refcnt, 1);
 		rb_link_node(&congested->rb_node, parent, node);
 		rb_insert_color(&congested->rb_node, &bdi->cgwb_congested_tree);
 		goto found;
@@ -460,13 +463,12 @@ wb_congested_get_create(struct backing_dev_info *bdi, int blkcg_id, gfp_t gfp)
 	if (!new_congested)
 		return NULL;
 
-	atomic_set(&new_congested->refcnt, 0);
+	refcount_set(&new_congested->refcnt, 0);
 	new_congested->__bdi = bdi;
 	new_congested->blkcg_id = blkcg_id;
 	goto retry;
 
 found:
-	atomic_inc(&congested->refcnt);
 	spin_unlock_irqrestore(&cgwb_lock, flags);
 	kfree(new_congested);
 	return congested;
@@ -483,7 +485,7 @@ void wb_congested_put(struct bdi_writeback_congested *congested)
 	unsigned long flags;
 
 	local_irq_save(flags);
-	if (!atomic_dec_and_lock(&congested->refcnt, &cgwb_lock)) {
+	if (!refcount_dec_and_lock(&congested->refcnt, &cgwb_lock)) {
 		local_irq_restore(flags);
 		return;
 	}
@@ -793,7 +795,7 @@ static int cgwb_bdi_init(struct backing_dev_info *bdi)
 	if (!bdi->wb_congested)
 		return -ENOMEM;
 
-	atomic_set(&bdi->wb_congested->refcnt, 1);
+	refcount_set(&bdi->wb_congested->refcnt, 1);
 
 	err = wb_init(&bdi->wb, bdi, 1, GFP_KERNEL);
 	if (err) {
-- 
2.7.4
