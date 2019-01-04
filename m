Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB9F48E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 09:29:27 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id x67so10785338pfk.16
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 06:29:27 -0800 (PST)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id h13si528422pgs.17.2019.01.04.06.29.26
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 04 Jan 2019 06:29:26 -0800 (PST)
From: <zhe.he@windriver.com>
Subject: [PATCH] mm: kmemleak: Turn kmemleak_lock to spin lock and RCU primitives
Date: Fri, 4 Jan 2019 22:29:13 +0800
Message-ID: <1546612153-451172-1-git-send-email-zhe.he@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhe.he@windriver.com

From: He Zhe <zhe.he@windriver.com>

It's not necessary to keep consistency between readers and writers of
kmemleak_lock. RCU is more proper for this case. And in order to gain better
performance, we turn the reader locks to RCU read locks and writer locks to
normal spin locks.

"time echo scan > /sys/kernel/debug/kmemleak" is improved from around 1.010s to
0.475s, without lock debug options, tested on Intel Corporation Broadwell Client
platform/Basking Ridge.

spin_lock_nested is replaced with irqsave version since the original outside
irqsave lock is gone. Otherwise we might have the following potential deadlock,
reported by lockdep.

WARNING: HARDIRQ-safe -> HARDIRQ-unsafe lock order detected
4.20.0-standard #1 Not tainted
-----------------------------------------------------
kmemleak/163 [HC0[0]:SC0[0]:HE0:SE1] is trying to acquire:
000000008d7de78e (&(&object->lock)->rlock/1){+.+.}, at: scan_block+0xc4/0x1e0

and this task is already holding:
000000009178399c (&(&object->lock)->rlock){..-.}, at: scan_gray_list+0xec/0x180
which would create a new lock dependency:
 (&(&object->lock)->rlock){..-.} -> (&(&object->lock)->rlock/1){+.+.}

but this new dependency connects a HARDIRQ-irq-safe lock:
 (&(&ehci->lock)->rlock){-.-.}

snip

       CPU0                    CPU1
       ----                    ----
  lock(&(&object->lock)->rlock/1);
                               local_irq_disable();
                               lock(&(&ehci->lock)->rlock);
                               lock(&(&object->lock)->rlock);
  <Interrupt>
    lock(&(&ehci->lock)->rlock);

Signed-off-by: He Zhe <zhe.he@windriver.com>
Cc: catalin.marinas@arm.com
---
 mm/kmemleak.c | 38 ++++++++++++++++----------------------
 1 file changed, 16 insertions(+), 22 deletions(-)

diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index f9d9dc2..ef9ea00 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -26,7 +26,7 @@
  *
  * The following locks and mutexes are used by kmemleak:
  *
- * - kmemleak_lock (rwlock): protects the object_list modifications and
+ * - kmemleak_lock (spinlock): protects the object_list modifications and
  *   accesses to the object_tree_root. The object_list is the main list
  *   holding the metadata (struct kmemleak_object) for the allocated memory
  *   blocks. The object_tree_root is a red black tree used to look-up
@@ -199,7 +199,7 @@ static LIST_HEAD(gray_list);
 /* search tree for object boundaries */
 static struct rb_root object_tree_root = RB_ROOT;
 /* rw_lock protecting the access to object_list and object_tree_root */
-static DEFINE_RWLOCK(kmemleak_lock);
+static DEFINE_SPINLOCK(kmemleak_lock);
 
 /* allocation caches for kmemleak internal data */
 static struct kmem_cache *object_cache;
@@ -515,9 +515,7 @@ static struct kmemleak_object *find_and_get_object(unsigned long ptr, int alias)
 	struct kmemleak_object *object;
 
 	rcu_read_lock();
-	read_lock_irqsave(&kmemleak_lock, flags);
 	object = lookup_object(ptr, alias);
-	read_unlock_irqrestore(&kmemleak_lock, flags);
 
 	/* check whether the object is still available */
 	if (object && !get_object(object))
@@ -537,13 +535,13 @@ static struct kmemleak_object *find_and_remove_object(unsigned long ptr, int ali
 	unsigned long flags;
 	struct kmemleak_object *object;
 
-	write_lock_irqsave(&kmemleak_lock, flags);
+	spin_lock_irqsave(&kmemleak_lock, flags);
 	object = lookup_object(ptr, alias);
 	if (object) {
 		rb_erase(&object->rb_node, &object_tree_root);
 		list_del_rcu(&object->object_list);
 	}
-	write_unlock_irqrestore(&kmemleak_lock, flags);
+	spin_unlock_irqrestore(&kmemleak_lock, flags);
 
 	return object;
 }
@@ -617,7 +615,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 	/* kernel backtrace */
 	object->trace_len = __save_stack_trace(object->trace);
 
-	write_lock_irqsave(&kmemleak_lock, flags);
+	spin_lock_irqsave(&kmemleak_lock, flags);
 
 	min_addr = min(min_addr, ptr);
 	max_addr = max(max_addr, ptr + size);
@@ -648,7 +646,7 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
 
 	list_add_tail_rcu(&object->object_list, &object_list);
 out:
-	write_unlock_irqrestore(&kmemleak_lock, flags);
+	spin_unlock_irqrestore(&kmemleak_lock, flags);
 	return object;
 }
 
@@ -1334,7 +1332,7 @@ static void scan_block(void *_start, void *_end,
 	unsigned long *end = _end - (BYTES_PER_POINTER - 1);
 	unsigned long flags;
 
-	read_lock_irqsave(&kmemleak_lock, flags);
+	rcu_read_lock();
 	for (ptr = start; ptr < end; ptr++) {
 		struct kmemleak_object *object;
 		unsigned long pointer;
@@ -1350,14 +1348,8 @@ static void scan_block(void *_start, void *_end,
 		if (pointer < min_addr || pointer >= max_addr)
 			continue;
 
-		/*
-		 * No need for get_object() here since we hold kmemleak_lock.
-		 * object->use_count cannot be dropped to 0 while the object
-		 * is still present in object_tree_root and object_list
-		 * (with updates protected by kmemleak_lock).
-		 */
 		object = lookup_object(pointer, 1);
-		if (!object)
+		if (!object || !get_object(object))
 			continue;
 		if (object == scanned)
 			/* self referenced, ignore */
@@ -1368,7 +1360,8 @@ static void scan_block(void *_start, void *_end,
 		 * previously acquired in scan_object(). These locks are
 		 * enclosed by scan_mutex.
 		 */
-		spin_lock_nested(&object->lock, SINGLE_DEPTH_NESTING);
+		spin_lock_irqsave_nested(&object->lock, flags,
+					 SINGLE_DEPTH_NESTING);
 		/* only pass surplus references (object already gray) */
 		if (color_gray(object)) {
 			excess_ref = object->excess_ref;
@@ -1377,21 +1370,22 @@ static void scan_block(void *_start, void *_end,
 			excess_ref = 0;
 			update_refs(object);
 		}
-		spin_unlock(&object->lock);
+		spin_unlock_irqrestore(&object->lock, flags);
 
 		if (excess_ref) {
 			object = lookup_object(excess_ref, 0);
-			if (!object)
+			if (!object || !get_object(object))
 				continue;
 			if (object == scanned)
 				/* circular reference, ignore */
 				continue;
-			spin_lock_nested(&object->lock, SINGLE_DEPTH_NESTING);
+			spin_lock_irqsave_nested(&object->lock, flags,
+						 SINGLE_DEPTH_NESTING);
 			update_refs(object);
-			spin_unlock(&object->lock);
+			spin_unlock_irqrestore(&object->lock, flags);
 		}
 	}
-	read_unlock_irqrestore(&kmemleak_lock, flags);
+	rcu_read_unlock();
 }
 
 /*
-- 
2.7.4
