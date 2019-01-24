Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6258E0068
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 20:52:51 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id t143so1295901itc.9
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 17:52:51 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id s196si2616001itc.63.2019.01.23.17.52.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 17:52:49 -0800 (PST)
Message-Id: <201901240152.x0O1qUUU069046@www262.sakura.ne.jp>
Subject: Re: possible deadlock in =?ISO-2022-JP?B?X19kb19wYWdlX2ZhdWx0?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Thu, 24 Jan 2019 10:52:30 +0900
References: <201901230201.x0N214eq043832@www262.sakura.ne.jp> <20190123155751.GA168927@google.com>
In-Reply-To: <20190123155751.GA168927@google.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Todd Kjos <tkjos@google.com>, syzbot+a76129f18c89f3e2ddd4@syzkaller.appspotmail.com, ak@linux.intel.com, Johannes Weiner <hannes@cmpxchg.org>, jack@suse.cz, jrdr.linux@gmail.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, mawilcox@microsoft.com, mgorman@techsingularity.net, syzkaller-bugs@googlegroups.com, Arve =?UTF-8?B?SGrDuG5uZXbDpWc=?= <arve@android.com>, Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Joel Fernandes wrote:
> > Anyway, I need your checks regarding whether this approach is waiting for
> > completion at all locations which need to wait for completion.
> 
> I think you are waiting in unwanted locations. The only location you need to
> wait in is ashmem_pin_unpin.
> 
> So, to my eyes all that is needed to fix this bug is:
> 
> 1. Delete the range from the ashmem_lru_list
> 2. Release the ashmem_mutex
> 3. fallocate the range.
> 4. Do the completion so that any waiting pin/unpin can proceed.
> 
> Could you clarify why you feel you need to wait for completion at those other
> locations?

Because I don't know how ashmem works.

> 
> Note that once a range is unpinned, it is open sesame and userspace cannot
> really expect consistent data from such range till it is pinned again.

Then, I'm tempted to eliminate shrinker and LRU list (like a draft patch shown
below). I think this is not equivalent to current code because this shrinks
upon only range_alloc() time and I don't know whether it is OK to temporarily
release ashmem_mutex during range_alloc() at "Case #4" of ashmem_pin(), but
can't we go this direction? 

By the way, why not to check range_alloc() failure before calling range_shrink() ?

---
 drivers/staging/android/ashmem.c | 154 +++++--------------------------
 1 file changed, 21 insertions(+), 133 deletions(-)

diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index 90a8a9f1ac7d..90668eebf35b 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -53,7 +53,6 @@ struct ashmem_area {
 
 /**
  * struct ashmem_range - A range of unpinned/evictable pages
- * @lru:	         The entry in the LRU list
  * @unpinned:	         The entry in its area's unpinned list
  * @asma:	         The associated anonymous shared memory area.
  * @pgstart:	         The starting page (inclusive)
@@ -64,7 +63,6 @@ struct ashmem_area {
  * It is protected by 'ashmem_mutex'
  */
 struct ashmem_range {
-	struct list_head lru;
 	struct list_head unpinned;
 	struct ashmem_area *asma;
 	size_t pgstart;
@@ -72,15 +70,8 @@ struct ashmem_range {
 	unsigned int purged;
 };
 
-/* LRU list of unpinned pages, protected by ashmem_mutex */
-static LIST_HEAD(ashmem_lru_list);
-
-/*
- * long lru_count - The count of pages on our LRU list.
- *
- * This is protected by ashmem_mutex.
- */
-static unsigned long lru_count;
+static atomic_t ashmem_purge_inflight = ATOMIC_INIT(0);
+static DECLARE_WAIT_QUEUE_HEAD(ashmem_purge_wait);
 
 /*
  * ashmem_mutex - protects the list of and each individual ashmem_area
@@ -97,7 +88,7 @@ static inline unsigned long range_size(struct ashmem_range *range)
 	return range->pgend - range->pgstart + 1;
 }
 
-static inline bool range_on_lru(struct ashmem_range *range)
+static inline bool range_not_purged(struct ashmem_range *range)
 {
 	return range->purged == ASHMEM_NOT_PURGED;
 }
@@ -133,32 +124,6 @@ static inline bool range_before_page(struct ashmem_range *range, size_t page)
 
 #define PROT_MASK		(PROT_EXEC | PROT_READ | PROT_WRITE)
 
-/**
- * lru_add() - Adds a range of memory to the LRU list
- * @range:     The memory range being added.
- *
- * The range is first added to the end (tail) of the LRU list.
- * After this, the size of the range is added to @lru_count
- */
-static inline void lru_add(struct ashmem_range *range)
-{
-	list_add_tail(&range->lru, &ashmem_lru_list);
-	lru_count += range_size(range);
-}
-
-/**
- * lru_del() - Removes a range of memory from the LRU list
- * @range:     The memory range being removed
- *
- * The range is first deleted from the LRU list.
- * After this, the size of the range is removed from @lru_count
- */
-static inline void lru_del(struct ashmem_range *range)
-{
-	list_del(&range->lru);
-	lru_count -= range_size(range);
-}
-
 /**
  * range_alloc() - Allocates and initializes a new ashmem_range structure
  * @asma:	   The associated ashmem_area
@@ -188,9 +153,23 @@ static int range_alloc(struct ashmem_area *asma,
 
 	list_add_tail(&range->unpinned, &prev_range->unpinned);
 
-	if (range_on_lru(range))
-		lru_add(range);
+	if (range_not_purged(range)) {
+		loff_t start = range->pgstart * PAGE_SIZE;
+		loff_t end = (range->pgend + 1) * PAGE_SIZE;
+		struct file *f = range->asma->file;
 
+		get_file(f);
+		atomic_inc(&ashmem_purge_inflight);
+		range->purged = ASHMEM_WAS_PURGED;
+		mutex_unlock(&ashmem_mutex);
+		f->f_op->fallocate(f,
+				   FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
+				   start, end - start);
+		fput(f);
+		if (atomic_dec_and_test(&ashmem_purge_inflight))
+			wake_up(&ashmem_purge_wait);
+		mutex_lock(&ashmem_mutex);
+	}
 	return 0;
 }
 
@@ -201,8 +180,6 @@ static int range_alloc(struct ashmem_area *asma,
 static void range_del(struct ashmem_range *range)
 {
 	list_del(&range->unpinned);
-	if (range_on_lru(range))
-		lru_del(range);
 	kmem_cache_free(ashmem_range_cachep, range);
 }
 
@@ -214,20 +191,12 @@ static void range_del(struct ashmem_range *range)
  *
  * This does not modify the data inside the existing range in any way - It
  * simply shrinks the boundaries of the range.
- *
- * Theoretically, with a little tweaking, this could eventually be changed
- * to range_resize, and expand the lru_count if the new range is larger.
  */
 static inline void range_shrink(struct ashmem_range *range,
 				size_t start, size_t end)
 {
-	size_t pre = range_size(range);
-
 	range->pgstart = start;
 	range->pgend = end;
-
-	if (range_on_lru(range))
-		lru_count -= pre - range_size(range);
 }
 
 /**
@@ -421,72 +390,6 @@ static int ashmem_mmap(struct file *file, struct vm_area_struct *vma)
 	return ret;
 }
 
-/*
- * ashmem_shrink - our cache shrinker, called from mm/vmscan.c
- *
- * 'nr_to_scan' is the number of objects to scan for freeing.
- *
- * 'gfp_mask' is the mask of the allocation that got us into this mess.
- *
- * Return value is the number of objects freed or -1 if we cannot
- * proceed without risk of deadlock (due to gfp_mask).
- *
- * We approximate LRU via least-recently-unpinned, jettisoning unpinned partial
- * chunks of ashmem regions LRU-wise one-at-a-time until we hit 'nr_to_scan'
- * pages freed.
- */
-static unsigned long
-ashmem_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
-{
-	struct ashmem_range *range, *next;
-	unsigned long freed = 0;
-
-	/* We might recurse into filesystem code, so bail out if necessary */
-	if (!(sc->gfp_mask & __GFP_FS))
-		return SHRINK_STOP;
-
-	if (!mutex_trylock(&ashmem_mutex))
-		return -1;
-
-	list_for_each_entry_safe(range, next, &ashmem_lru_list, lru) {
-		loff_t start = range->pgstart * PAGE_SIZE;
-		loff_t end = (range->pgend + 1) * PAGE_SIZE;
-
-		range->asma->file->f_op->fallocate(range->asma->file,
-				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
-				start, end - start);
-		range->purged = ASHMEM_WAS_PURGED;
-		lru_del(range);
-
-		freed += range_size(range);
-		if (--sc->nr_to_scan <= 0)
-			break;
-	}
-	mutex_unlock(&ashmem_mutex);
-	return freed;
-}
-
-static unsigned long
-ashmem_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
-{
-	/*
-	 * note that lru_count is count of pages on the lru, not a count of
-	 * objects on the list. This means the scan function needs to return the
-	 * number of pages freed, not the number of objects scanned.
-	 */
-	return lru_count;
-}
-
-static struct shrinker ashmem_shrinker = {
-	.count_objects = ashmem_shrink_count,
-	.scan_objects = ashmem_shrink_scan,
-	/*
-	 * XXX (dchinner): I wish people would comment on why they need on
-	 * significant changes to the default value here
-	 */
-	.seeks = DEFAULT_SEEKS * 4,
-};
-
 static int set_prot_mask(struct ashmem_area *asma, unsigned long prot)
 {
 	int ret = 0;
@@ -713,6 +616,7 @@ static int ashmem_pin_unpin(struct ashmem_area *asma, unsigned long cmd,
 		return -EFAULT;
 
 	mutex_lock(&ashmem_mutex);
+	wait_event(ashmem_purge_wait, !atomic_read(&ashmem_purge_inflight));
 
 	if (!asma->file)
 		goto out_unlock;
@@ -787,15 +691,7 @@ static long ashmem_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		ret = ashmem_pin_unpin(asma, cmd, (void __user *)arg);
 		break;
 	case ASHMEM_PURGE_ALL_CACHES:
-		ret = -EPERM;
-		if (capable(CAP_SYS_ADMIN)) {
-			struct shrink_control sc = {
-				.gfp_mask = GFP_KERNEL,
-				.nr_to_scan = LONG_MAX,
-			};
-			ret = ashmem_shrink_count(&ashmem_shrinker, &sc);
-			ashmem_shrink_scan(&ashmem_shrinker, &sc);
-		}
+		ret = capable(CAP_SYS_ADMIN) ? 0 : -EPERM;
 		break;
 	}
 
@@ -883,18 +779,10 @@ static int __init ashmem_init(void)
 		goto out_free2;
 	}
 
-	ret = register_shrinker(&ashmem_shrinker);
-	if (ret) {
-		pr_err("failed to register shrinker!\n");
-		goto out_demisc;
-	}
-
 	pr_info("initialized\n");
 
 	return 0;
 
-out_demisc:
-	misc_deregister(&ashmem_misc);
 out_free2:
 	kmem_cache_destroy(ashmem_range_cachep);
 out_free1:
-- 
2.17.1
