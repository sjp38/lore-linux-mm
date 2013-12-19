Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 641DE6B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 00:42:11 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so650852pdj.40
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 21:42:10 -0800 (PST)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id zi8si1692826pac.243.2013.12.18.21.42.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 21:42:09 -0800 (PST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 19 Dec 2013 15:42:04 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 9BEAA3578050
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 16:42:00 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBJ5flhp2687418
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 16:41:48 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBJ5fxKH000600
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 16:41:59 +1100
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v3] mm/rmap: fix BUG at rmap_walk
Date: Thu, 19 Dec 2013 13:41:55 +0800
Message-Id: <1387431715-6786-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

This bug is introduced by commit 37f093cdf(mm/rmap: use rmap_walk() in 
page_referenced()). page_get_anon_vma() called in page_referenced_anon() 
will lock and increase the refcount of anon_vma. PageLocked is not required 
by page_referenced_anon() and there is not any assertion before, commit 
37f093cdf introduced this extra BUG_ON() checking for anon page by mistake.
This patch fix it by remove rmap_walk()'s VM_BUG_ON() and comment reason why 
the page must be locked for rmap_walk_ksm() and rmap_walk_file().

[  588.698828] kernel BUG at mm/rmap.c:1663!
[  588.699380] invalid opcode: 0000 [#2] PREEMPT SMP DEBUG_PAGEALLOC
[  588.700347] Dumping ftrace buffer:
[  588.701186]    (ftrace buffer empty)
[  588.702062] Modules linked in:
[  588.702759] CPU: 0 PID: 4647 Comm: kswapd0 Tainted: G      D W    3.13.0-rc4-next-20131218-sasha-00012-g1962367-dirty #4155
[  588.704330] task: ffff880062bcb000 ti: ffff880062450000 task.ti: ffff880062450000
[  588.705507] RIP: 0010:[<ffffffff81289c80>]  [<ffffffff81289c80>] rmap_walk+0x10/0x50
[  588.706800] RSP: 0018:ffff8800624518d8  EFLAGS: 00010246
[  588.707515] RAX: 000fffff80080048 RBX: ffffea00000227c0 RCX: 0000000000000000
[  588.707515] RDX: 0000000000000000 RSI: ffff8800624518e8 RDI: ffffea00000227c0
[  588.707515] RBP: ffff8800624518d8 R08: ffff8800624518e8 R09: 0000000000000000
[  588.707515] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8800624519d8
[  588.707515] R13: 0000000000000000 R14: ffffea00000227e0 R15: 0000000000000000
[  588.707515] FS:  0000000000000000(0000) GS:ffff880065200000(0000) knlGS:0000000000000000
[  588.707515] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  588.707515] CR2: 00007fec40cbe0f8 CR3: 00000000c2382000 CR4: 00000000000006f0
[  588.707515] Stack:
[  588.707515]  ffff880062451958 ffffffff81289f4b ffff880062451918 ffffffff81289f80
[  588.707515]  0000000000000000 0000000000000000 ffffffff8128af60 0000000000000000
[  588.707515]  0000000000000024 0000000000000000 0000000000000000 0000000000000286
[  588.707515] Call Trace:
[  588.707515]  [<ffffffff81289f4b>] page_referenced+0xcb/0x100
[  588.707515]  [<ffffffff81289f80>] ? page_referenced+0x100/0x100
[  588.707515]  [<ffffffff8128af60>] ? invalid_page_referenced_vma+0x170/0x170
[  588.707515]  [<ffffffff81264302>] shrink_active_list+0x212/0x330
[  588.707515]  [<ffffffff81260e23>] ? inactive_file_is_low+0x33/0x50
[  588.707515]  [<ffffffff812646f5>] shrink_lruvec+0x2d5/0x300
[  588.707515]  [<ffffffff812647b6>] shrink_zone+0x96/0x1e0
[  588.707515]  [<ffffffff81265b06>] kswapd_shrink_zone+0xf6/0x1c0
[  588.707515]  [<ffffffff81265f43>] balance_pgdat+0x373/0x550
[  588.707515]  [<ffffffff81266d63>] kswapd+0x2f3/0x350
[  588.707515]  [<ffffffff81266a70>] ? perf_trace_mm_vmscan_lru_isolate_template+0x120/0x120
[  588.707515]  [<ffffffff8115c9c5>] kthread+0x105/0x110
[  588.707515]  [<ffffffff8115c8c0>] ? set_kthreadd_affinity+0x30/0x30
[  588.707515]  [<ffffffff843a6a7c>] ret_from_fork+0x7c/0xb0
[  588.707515]  [<ffffffff8115c8c0>] ? set_kthreadd_affinity+0x30/0x30
[  588.707515] Code: c0 48 83 c4 18 89 d0 5b 41 5c 41 5d 41 5e 41 5f c9 c3 66 0f 1f 84
00 00 00 00 00 55 48 89 e5 66 66 66 66 90 48 8b 07 a8 01 75 10 <0f> 0b 66 0f 1f 44 00 0
0 eb fe 66 0f 1f 44 00 00 f6 47 08 01 74
[  588.707515] RIP  [<ffffffff81289c80>] rmap_walk+0x10/0x50
[  588.707515]  RSP <ffff8800624518d8>

Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/ksm.c  |  5 +++++
 mm/rmap.c | 10 ++++++++--
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index c9a28dd..76d96df 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1899,6 +1899,11 @@ int rmap_walk_ksm(struct page *page, struct rmap_walk_control *rwc)
 	int search_new_forks = 0;
 
 	VM_BUG_ON(!PageKsm(page));
+
+	/*
+	 * Rely on the page lock to protect against concurrent modifications
+	 * to that page's node of the stable tree.
+	 */
 	VM_BUG_ON(!PageLocked(page));
 
 	stable_node = page_stable_node(page);
diff --git a/mm/rmap.c b/mm/rmap.c
index d792e71..a0a199d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1629,6 +1629,14 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 	struct vm_area_struct *vma;
 	int ret = SWAP_AGAIN;
 
+	/*
+	 * The page lock not only makes sure that page->mapping cannot
+	 * suddenly be NULLified by truncation, it makes sure that the
+	 * structure at mapping cannot be freed and reused yet,
+	 * so we can safely take mapping->i_mmap_mutex.
+	 */
+	VM_BUG_ON(!PageLocked(page));
+
 	if (!mapping)
 		return ret;
 	mutex_lock(&mapping->i_mmap_mutex);
@@ -1660,8 +1668,6 @@ done:
 
 int rmap_walk(struct page *page, struct rmap_walk_control *rwc)
 {
-	VM_BUG_ON(!PageLocked(page));
-
 	if (unlikely(PageKsm(page)))
 		return rmap_walk_ksm(page, rwc);
 	else if (PageAnon(page))
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
