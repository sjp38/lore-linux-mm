Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2EF956B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 13:07:08 -0400 (EDT)
Received: by qkhg32 with SMTP id g32so81163197qkh.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 10:07:08 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g13si3090356qhc.50.2015.06.08.10.07.05
        for <linux-mm@kvack.org>;
        Mon, 08 Jun 2015 10:07:06 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [RFC PATCH] mm: kmemleak: Optimise kmemleak_lock acquiring during kmemleak_scan
Date: Mon,  8 Jun 2015 18:06:59 +0100
Message-Id: <1433783219-14453-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

The kmemleak memory scanning uses finer grained object->lock spinlocks
primarily to avoid races with the memory block freeing. However, the
pointer lookup in the rb tree requires the kmemleak_lock to be held.
This is currently done in the find_and_get_object() function for each
pointer-like location read during scanning. While this allows a low
latency on kmemleak_*() callbacks on other CPUs, the memory scanning is
slower.

This patch moves the kmemleak_lock outside the core scan_block()
function allowing the spinlock to be acquired/released only once per
scanned memory block rather than individual pointer-like values. The
memory scanning performance is significantly improved (by an order of
magnitude on an arm64 system).

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---

Andrew,

While sorting out some of the kmemleak disabling races, I realised that
kmemleak scanning performance can be improved. On an arm64 system I
tested (albeit not a fast one but with 6 CPUs and 8GB of RAM),
immediately after boot an "time echo scan > /sys/kernel/debug/kmemleak"
takes on average 70 sec. With this patch applied, I get on average 4.7
sec.

IMHO, this patch is worth applying even though the scalability during
kmemleak scanning may be slightly reduced. OTOH, it compensates by the
scanning now taking much less time.

A next step would be to investigate whether individual object->lock
can be completely removed and just live with the coarse kmemleak_lock
(though we won't see as big an improvement).

Thanks,

Catalin

 mm/kmemleak.c | 38 ++++++++++++++++++++++++++------------
 1 file changed, 26 insertions(+), 12 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index c0fd7769d227..b8e52617ac32 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -53,10 +53,12 @@
  *   modifications to the memory scanning parameters including the scan_thread
  *   pointer
  *
- * Locks and mutexes should only be acquired/nested in the following order:
+ * Locks and mutexes are acquired/nested in the following order:
  *
- *   scan_mutex -> object->lock -> other_object->lock (SINGLE_DEPTH_NESTING)
- *				-> kmemleak_lock
+ *   scan_mutex [-> object->lock] -> kmemleak_lock -> other_object->lock (SINGLE_DEPTH_NESTING)
+ *
+ * No kmemleak_lock and object->lock nesting is allowed outside scan_mutex
+ * regions.
  *
  * The kmemleak_object structures have a use_count incremented or decremented
  * using the get_object()/put_object() functions. When the use_count becomes
@@ -490,8 +492,7 @@ static struct kmemleak_object *find_and_get_object(unsigned long ptr, int alias)
 
 	rcu_read_lock();
 	read_lock_irqsave(&kmemleak_lock, flags);
-	if (ptr >= min_addr && ptr < max_addr)
-		object = lookup_object(ptr, alias);
+	object = lookup_object(ptr, alias);
 	read_unlock_irqrestore(&kmemleak_lock, flags);
 
 	/* check whether the object is still available */
@@ -1175,14 +1176,19 @@ static void scan_block(void *_start, void *_end,
 	unsigned long *ptr;
 	unsigned long *start = PTR_ALIGN(_start, BYTES_PER_POINTER);
 	unsigned long *end = _end - (BYTES_PER_POINTER - 1);
+	unsigned long klflags;
 
+	read_lock_irqsave(&kmemleak_lock, klflags);
 	for (ptr = start; ptr < end; ptr++) {
 		struct kmemleak_object *object;
 		unsigned long flags;
 		unsigned long pointer;
 
-		if (allow_resched)
+		if (allow_resched && need_resched()) {
+			read_unlock_irqrestore(&kmemleak_lock, klflags);
 			cond_resched();
+			read_lock_irqsave(&kmemleak_lock, klflags);
+		}
 		if (scan_should_stop())
 			break;
 
@@ -1195,14 +1201,21 @@ static void scan_block(void *_start, void *_end,
 		pointer = *ptr;
 		kasan_enable_current();
 
-		object = find_and_get_object(pointer, 1);
+		if (pointer < min_addr || pointer >= max_addr)
+			continue;
+
+		/*
+		 * No need for get_object() here since we hold kmemleak_lock.
+		 * object->use_count cannot be dropped to 0 while the object
+		 * is still present in object_tree_root and object_list
+		 * (with updates protected by kmemleak_lock).
+		 */
+		object = lookup_object(pointer, 1);
 		if (!object)
 			continue;
-		if (object == scanned) {
+		if (object == scanned)
 			/* self referenced, ignore */
-			put_object(object);
 			continue;
-		}
 
 		/*
 		 * Avoid the lockdep recursive warning on object->lock being
@@ -1214,7 +1227,6 @@ static void scan_block(void *_start, void *_end,
 		if (!color_white(object)) {
 			/* non-orphan, ignored or new */
 			spin_unlock_irqrestore(&object->lock, flags);
-			put_object(object);
 			continue;
 		}
 
@@ -1226,14 +1238,16 @@ static void scan_block(void *_start, void *_end,
 		 */
 		object->count++;
 		if (color_gray(object)) {
+			/* put_object() called when removing from gray_list */
+			WARN_ON(!get_object(object));
 			list_add_tail(&object->gray_list, &gray_list);
 			spin_unlock_irqrestore(&object->lock, flags);
 			continue;
 		}
 
 		spin_unlock_irqrestore(&object->lock, flags);
-		put_object(object);
 	}
+	read_unlock_irqrestore(&kmemleak_lock, klflags);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
