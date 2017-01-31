Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 952376B0033
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 03:28:03 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id 78so202814606vkj.2
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 00:28:03 -0800 (PST)
Received: from mail-ua0-x233.google.com (mail-ua0-x233.google.com. [2607:f8b0:400c:c08::233])
        by mx.google.com with ESMTPS id t35si4552071uat.176.2017.01.31.00.28.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 00:28:02 -0800 (PST)
Received: by mail-ua0-x233.google.com with SMTP id 35so267897383uak.1
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 00:28:02 -0800 (PST)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 31 Jan 2017 09:27:41 +0100
Message-ID: <CACT4Y+Y+mAg82iUD4gMA_DPoEBzjA3uO=kVki1x9NCJRQKwhHg@mail.gmail.com>
Subject: mm: sleeping function called from invalid context shmem_undo_range
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: syzkaller <syzkaller@googlegroups.com>

Hello,

I've got the following report while running syzkaller fuzzer on
fd694aaa46c7ed811b72eb47d5eb11ce7ab3f7f1:

BUG: sleeping function called from invalid context at mm/shmem.c:852
in_atomic(): 1, irqs_disabled(): 0, pid: 529, name: khugepaged
3 locks held by khugepaged/529:
 #0:  (shrinker_rwsem){++++..}, at: [<ffffffff818d7ef1>]
shrink_slab.part.59+0x121/0xd30 mm/vmscan.c:451
 #1:  (&type->s_umount_key#29){++++..}, at: [<ffffffff81a63630>]
trylock_super+0x20/0x100 fs/super.c:392
 #2:  (&(&sbinfo->shrinklist_lock)->rlock){+.+.-.}, at:
[<ffffffff818fd83e>] spin_lock include/linux/spinlock.h:302 [inline]
 #2:  (&(&sbinfo->shrinklist_lock)->rlock){+.+.-.}, at:
[<ffffffff818fd83e>] shmem_unused_huge_shrink+0x28e/0x1490
mm/shmem.c:427
CPU: 2 PID: 529 Comm: khugepaged Not tainted 4.10.0-rc5+ #201
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 ___might_sleep+0x47e/0x650 kernel/sched/core.c:7780
 shmem_undo_range+0xb20/0x2710 mm/shmem.c:852
 shmem_truncate_range+0x27/0xa0 mm/shmem.c:939
 shmem_evict_inode+0x35f/0xca0 mm/shmem.c:1030
 evict+0x46e/0x980 fs/inode.c:553
 iput_final fs/inode.c:1515 [inline]
 iput+0x589/0xb20 fs/inode.c:1542
 shmem_unused_huge_shrink+0xbad/0x1490 mm/shmem.c:446
 shmem_unused_huge_scan+0x10c/0x170 mm/shmem.c:512
 super_cache_scan+0x376/0x450 fs/super.c:106
 do_shrink_slab mm/vmscan.c:378 [inline]
 shrink_slab.part.59+0x543/0xd30 mm/vmscan.c:481
 shrink_slab mm/vmscan.c:2592 [inline]
 shrink_node+0x2c7/0x870 mm/vmscan.c:2592
 shrink_zones mm/vmscan.c:2734 [inline]
 do_try_to_free_pages+0x369/0xc80 mm/vmscan.c:2776
 try_to_free_pages+0x3c6/0x900 mm/vmscan.c:2982
 __perform_reclaim mm/page_alloc.c:3301 [inline]
 __alloc_pages_direct_reclaim mm/page_alloc.c:3322 [inline]
 __alloc_pages_slowpath+0xa24/0x1c30 mm/page_alloc.c:3683
 __alloc_pages_nodemask+0x544/0xae0 mm/page_alloc.c:3848
 __alloc_pages include/linux/gfp.h:426 [inline]
 __alloc_pages_node include/linux/gfp.h:439 [inline]
 khugepaged_alloc_page+0xc2/0x1b0 mm/khugepaged.c:750
 collapse_huge_page+0x182/0x1fe0 mm/khugepaged.c:955
 khugepaged_scan_pmd+0xfdf/0x12a0 mm/khugepaged.c:1208
 khugepaged_scan_mm_slot mm/khugepaged.c:1727 [inline]
 khugepaged_do_scan mm/khugepaged.c:1808 [inline]
 khugepaged+0xe9b/0x1590 mm/khugepaged.c:1853
 kthread+0x326/0x3f0 kernel/kthread.c:227
 ret_from_fork+0x31/0x40 arch/x86/entry/entry_64.S:430

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
