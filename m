Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 44C3A6B03DA
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 10:15:38 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v190so11604815wme.0
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:15:38 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id 59si4761393wre.100.2017.03.08.07.15.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 07:15:36 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id t189so33399242wmt.1
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:15:36 -0800 (PST)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] kasan: fix races in quarantine_remove_cache()
Date: Wed,  8 Mar 2017 16:15:32 +0100
Message-Id: <20170308151532.5070-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, Greg Thelen <gthelen@google.com>

quarantine_remove_cache() frees all pending objects that belong to the
cache, before we destroy the cache itself. However there are currently
two possibilities how it can fail to do so.

First, another thread can hold some of the objects from the cache in
temp list in quarantine_put(). quarantine_put() has a windows of enabled
interrupts, and on_each_cpu() in quarantine_remove_cache() can finish
right in that window. These objects will be later freed into the
destroyed cache.

Then, quarantine_reduce() has the same problem. It grabs a batch of
objects from the global quarantine, then unlocks quarantine_lock and
then frees the batch. quarantine_remove_cache() can finish while some
objects from the cache are still in the local to_free list in
quarantine_reduce().

Fix the race with quarantine_put() by disabling interrupts for the
whole duration of quarantine_put(). In combination with on_each_cpu()
in quarantine_remove_cache() it ensures that quarantine_remove_cache()
either sees the objects in the per-cpu list or in the global list.

Fix the race with quarantine_reduce() by protecting quarantine_reduce()
with srcu critical section and then doing synchronize_srcu() at the end
of quarantine_remove_cache().

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: kasan-dev@googlegroups.com
Cc: linux-mm@kvack.org
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Greg Thelen <gthelen@google.com>

---
I've done some assessment of how good synchronize_srcu() works in this
case. And on a 4 CPU VM I see that it blocks waiting for pending read
critical sections in about 2-3% of cases. Which looks good to me.

I suspect that these races are the root cause of some GPFs that
I episodically hit. Previously I did not have any explanation for them.

BUG: unable to handle kernel NULL pointer dereference at 00000000000000c8
IP: qlist_free_all+0x2e/0xc0 mm/kasan/quarantine.c:155
PGD 6aeea067
PUD 60ed7067
PMD 0
Oops: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 0 PID: 13667 Comm: syz-executor2 Not tainted 4.10.0+ #60
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88005f948040 task.stack: ffff880069818000
RIP: 0010:qlist_free_all+0x2e/0xc0 mm/kasan/quarantine.c:155
RSP: 0018:ffff88006981f298 EFLAGS: 00010246
RAX: ffffea0000ffff00 RBX: 0000000000000000 RCX: ffffea0000ffff1f
RDX: 0000000000000000 RSI: ffff88003fffc3e0 RDI: 0000000000000000
RBP: ffff88006981f2c0 R08: ffff88002fed7bd8 R09: 00000001001f000d
R10: 00000000001f000d R11: ffff88006981f000 R12: ffff88003fffc3e0
R13: ffff88006981f2d0 R14: ffffffff81877fae R15: 0000000080000000
FS:  00007fb911a2d700(0000) GS:ffff88003ec00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00000000000000c8 CR3: 0000000060ed6000 CR4: 00000000000006f0
Call Trace:
 quarantine_reduce+0x10e/0x120 mm/kasan/quarantine.c:239
 kasan_kmalloc+0xca/0xe0 mm/kasan/kasan.c:590
 kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544
 slab_post_alloc_hook mm/slab.h:456 [inline]
 slab_alloc_node mm/slub.c:2718 [inline]
 kmem_cache_alloc_node+0x1d3/0x280 mm/slub.c:2754
 __alloc_skb+0x10f/0x770 net/core/skbuff.c:219
 alloc_skb include/linux/skbuff.h:932 [inline]
 _sctp_make_chunk+0x3b/0x260 net/sctp/sm_make_chunk.c:1388
 sctp_make_data net/sctp/sm_make_chunk.c:1420 [inline]
 sctp_make_datafrag_empty+0x208/0x360 net/sctp/sm_make_chunk.c:746
 sctp_datamsg_from_user+0x7e8/0x11d0 net/sctp/chunk.c:266
 sctp_sendmsg+0x2611/0x3970 net/sctp/socket.c:1962
 inet_sendmsg+0x164/0x5b0 net/ipv4/af_inet.c:761
 sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 SYSC_sendto+0x660/0x810 net/socket.c:1685
 SyS_sendto+0x40/0x50 net/socket.c:1653
---
 mm/kasan/quarantine.c | 42 ++++++++++++++++++++++++++++++++++++------
 1 file changed, 36 insertions(+), 6 deletions(-)

diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index 6f1ed1630873..075422c3cee3 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -27,6 +27,7 @@
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/types.h>
+#include <linux/srcu.h>
 
 #include "../slab.h"
 #include "kasan.h"
@@ -103,6 +104,7 @@ static int quarantine_tail;
 /* Total size of all objects in global_quarantine across all batches. */
 static unsigned long quarantine_size;
 static DEFINE_SPINLOCK(quarantine_lock);
+DEFINE_STATIC_SRCU(remove_cache_srcu);
 
 /* Maximum size of the global queue. */
 static unsigned long quarantine_max_size;
@@ -173,17 +175,22 @@ void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache)
 	struct qlist_head *q;
 	struct qlist_head temp = QLIST_INIT;
 
+	/*
+	 * Note: irq must be disabled until after we move the batch to the
+	 * global quarantine. Otherwise quarantine_remove_cache() can miss
+	 * some objects belonging to the cache if they are in our local temp
+	 * list. quarantine_remove_cache() executes on_each_cpu() at the
+	 * beginning which ensures that it either sees the objects in per-cpu
+	 * lists or in the global quarantine.
+	 */
 	local_irq_save(flags);
 
 	q = this_cpu_ptr(&cpu_quarantine);
 	qlist_put(q, &info->quarantine_link, cache->size);
-	if (unlikely(q->bytes > QUARANTINE_PERCPU_SIZE))
+	if (unlikely(q->bytes > QUARANTINE_PERCPU_SIZE)) {
 		qlist_move_all(q, &temp);
 
-	local_irq_restore(flags);
-
-	if (unlikely(!qlist_empty(&temp))) {
-		spin_lock_irqsave(&quarantine_lock, flags);
+		spin_lock(&quarantine_lock);
 		WRITE_ONCE(quarantine_size, quarantine_size + temp.bytes);
 		qlist_move_all(&temp, &global_quarantine[quarantine_tail]);
 		if (global_quarantine[quarantine_tail].bytes >=
@@ -196,20 +203,33 @@ void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache)
 			if (new_tail != quarantine_head)
 				quarantine_tail = new_tail;
 		}
-		spin_unlock_irqrestore(&quarantine_lock, flags);
+		spin_unlock(&quarantine_lock);
 	}
+
+	local_irq_restore(flags);
 }
 
 void quarantine_reduce(void)
 {
 	size_t total_size, new_quarantine_size, percpu_quarantines;
 	unsigned long flags;
+	int srcu_idx;
 	struct qlist_head to_free = QLIST_INIT;
 
 	if (likely(READ_ONCE(quarantine_size) <=
 		   READ_ONCE(quarantine_max_size)))
 		return;
 
+	/*
+	 * srcu critical section ensures that quarantine_remove_cache()
+	 * will not miss objects belonging to the cache while they are in our
+	 * local to_free list. srcu is chosen because (1) it gives us private
+	 * grace period domain that does not interfere with anything else,
+	 * and (2) it allows synchronize_srcu() to return without waiting
+	 * if there are no pending read critical sections (which is the
+	 * expected case).
+	 */
+	srcu_idx = srcu_read_lock(&remove_cache_srcu);
 	spin_lock_irqsave(&quarantine_lock, flags);
 
 	/*
@@ -237,6 +257,7 @@ void quarantine_reduce(void)
 	spin_unlock_irqrestore(&quarantine_lock, flags);
 
 	qlist_free_all(&to_free, NULL);
+	srcu_read_unlock(&remove_cache_srcu, srcu_idx);
 }
 
 static void qlist_move_cache(struct qlist_head *from,
@@ -280,6 +301,13 @@ void quarantine_remove_cache(struct kmem_cache *cache)
 	unsigned long flags, i;
 	struct qlist_head to_free = QLIST_INIT;
 
+	/*
+	 * Must be careful to not miss any objects that are being moved from
+	 * per-cpu list to the global quarantine in quarantine_put(),
+	 * nor objects being freed in quarantine_reduce(). on_each_cpu()
+	 * achieves the first goal, while synchronize_srcu() achieves the
+	 * second.
+	 */
 	on_each_cpu(per_cpu_remove_cache, cache, 1);
 
 	spin_lock_irqsave(&quarantine_lock, flags);
@@ -288,4 +316,6 @@ void quarantine_remove_cache(struct kmem_cache *cache)
 	spin_unlock_irqrestore(&quarantine_lock, flags);
 
 	qlist_free_all(&to_free, cache);
+
+	synchronize_srcu(&remove_cache_srcu);
 }
-- 
2.12.0.246.ga2ecc84866-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
