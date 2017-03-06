Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 76B6F6B038E
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:04:00 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id u81so76817943uau.6
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:04:00 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l12sor5972515uaf.15.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Mar 2017 08:03:59 -0800 (PST)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 6 Mar 2017 17:03:38 +0100
Message-ID: <CACT4Y+a_wPN==+cCdi8cF+1Sft-M++cpEdL0eFoNMVwOTczQRw@mail.gmail.com>
Subject: kasan: bug in quarantine_remove_cache
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Greg Thelen <gthelen@google.com>

Hi,

I think I see a nasty race condition in quarantine_remove_cache. It
seems to manifest as the following crash, I've seen several of them
but did not have any explanation.


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
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4458b9
RSP: 002b:00007fb911a2cb58 EFLAGS: 00000282 ORIG_RAX: 000000000000002c
RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 00000000004458b9
RDX: 00000000000000ae RSI: 0000000020477000 RDI: 0000000000000005
RBP: 00000000006e1ba0 R08: 0000000020477000 R09: 0000000000000010
R10: 0000000000000040 R11: 0000000000000282 R12: 0000000000708000
R13: 0000000000000000 R14: 00007fb911a2d9c0 R15: 00007fb911a2d700
Code: e5 41 57 41 56 41 55 41 54 53 48 89 f3 48 8b 37 48 85 f6 0f 84
8e 00 00 00 49 89 fd 49 c7 c6 ae 7f 87 81 41 bf 00 00 00 80 eb 1d <48>
63 87 c8 00 00 00 4c 8b 26 4c 89 f2 48 29 c6 e8 4d ce ff ff
RIP: qlist_free_all+0x2e/0xc0 mm/kasan/quarantine.c:155 RSP: ffff88006981f298
CR2: 00000000000000c8
---[ end trace a5485c8c9b67efdd ]---

quarantine_remove_cache frees all pending objects that belong to the
cache, before we destroy the cache itself. However there are 2
possibilities how it can fail to do so.

First, another thread can hold some of the objects from the cache in
temp list in quarantine_put. quarantine_put has a windows of enabled
interrupts, and on_each_cpu in quarantine_remove_cache can finish
right in that window. These objects will be later freed into the
destroyed cache.

Then, quarantine_reduce has the same problem. It grabs a batch of
objects from the global quarantine, then unlocks quarantine_lock and
then frees the batch. quarantine_remove_cache can finish while some
objects from the cache are still in the local to_free list in
quarantine_reduce.

I am trying to find a reasonably simple, elegant and performant
solution for this.
What I have now is this:

diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
index 6f1ed1630873..58c280bd5a4d 100644
--- a/mm/kasan/quarantine.c
+++ b/mm/kasan/quarantine.c
@@ -180,10 +180,7 @@ void quarantine_put(struct kasan_free_meta *info,
struct kmem_cache *cache)
         if (unlikely(q->bytes > QUARANTINE_PERCPU_SIZE))
                 qlist_move_all(q, &temp);

-        local_irq_restore(flags);
-
-        if (unlikely(!qlist_empty(&temp))) {
-                spin_lock_irqsave(&quarantine_lock, flags);
+                spin_lock(&quarantine_lock);
                 WRITE_ONCE(quarantine_size, quarantine_size + temp.bytes);
                 qlist_move_all(&temp, &global_quarantine[quarantine_tail]);
                 if (global_quarantine[quarantine_tail].bytes >=
@@ -196,8 +193,10 @@ void quarantine_put(struct kasan_free_meta *info,
struct kmem_cache *cache)
                         if (new_tail != quarantine_head)
                                 quarantine_tail = new_tail;
                 }
-                spin_unlock_irqrestore(&quarantine_lock, flags);
+                spin_unlock(&quarantine_lock);
         }
+
+        local_irq_restore(flags);
 }

 void quarantine_reduce(void)
@@ -210,7 +209,8 @@ void quarantine_reduce(void)
                    READ_ONCE(quarantine_max_size)))
                 return;

-        spin_lock_irqsave(&quarantine_lock, flags);
+        local_irq_save(flags);
+        spin_lock(&quarantine_lock);

         /*
          * Update quarantine size in case of hotplug. Allocate a fraction of
@@ -234,9 +234,11 @@ void quarantine_reduce(void)
                         quarantine_head = 0;
         }

-        spin_unlock_irqrestore(&quarantine_lock, flags);
+        spin_unlock(&quarantine_lock);

         qlist_free_all(&to_free, NULL);
+
+        local_irq_restore(flags);
 }

 static void qlist_move_cache(struct qlist_head *from,
@@ -288,4 +290,6 @@ void quarantine_remove_cache(struct kmem_cache *cache)
         spin_unlock_irqrestore(&quarantine_lock, flags);

         qlist_free_all(&to_free, cache);
+
+        synchronize_sched();
 }


If we disable interrupts for the most part of quarantine_put and
quarantine_reduce, and do 2 synchronize_sched's in
quarantine_remove_cache (one being on_each_cpu), then it should
resolve the race.
However, I am not sure if it is OK to disable interrupts when we are
freeing a large batch in quarantine_reduce. And probably
synchronize_sched in quarantine_remove_cache will have negative
performance impact for container workloads. What do you think?
Is using rcu_read_lock/unlock and synchronize_rcu better?
Or maybe we could do own simplified version of rcu with 2 epochs
(effectively counters of pending quarantine_put/reduce). But I really
don't like going that way complexity-wise.

Any other suggestions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
