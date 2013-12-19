Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B008E6B0031
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 22:45:35 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kl14so572689pab.37
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 19:45:35 -0800 (PST)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id j8si1501339pad.265.2013.12.18.19.45.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 19:45:34 -0800 (PST)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 19 Dec 2013 09:15:30 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 814A4394005B
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 09:15:27 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBJ3jJma37486784
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 09:15:20 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBJ3jQtP005385
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 09:15:26 +0530
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2] mm/rmap: fix BUG at rmap_walk 
Date: Thu, 19 Dec 2013 11:45:20 +0800
Message-Id: <1387424720-22826-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>

page_get_anon_vma() called in page_referenced_anon() will lock and increase 
the refcount of anon_vma, page won't be locked for anonymous page if the page 
is not locked by the caller. This patch fix the BUG_ON by reuse referenced 
field in page_referenced_arg to capture locked anonymous page for page_referenced(), 
if the anonymous page is locked by the caller, the referenced field will remember 
it, rmap_walk_anon will check if page locked if caller lock it. 

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
 mm/rmap.c | 20 ++++++++++++++++++--
 2 files changed, 23 insertions(+), 2 deletions(-)

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
index d792e71..db83961 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -769,6 +769,10 @@ int page_referenced(struct page *page,
 	struct page_referenced_arg pra = {
 		.mapcount = page_mapcount(page),
 		.memcg = memcg,
+		/*
+		 * reuse referenced field for the locked anonymous page check
+		 */
+		.referenced = is_locked && PageAnon(page) && !PageKsm(page),
 	};
 	struct rmap_walk_control rwc = {
 		.rmap_one = page_referenced_one,
@@ -1587,6 +1591,12 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
+	struct page_referenced_arg *pra = rwc->arg;
+
+	if (pra->referenced) {
+		VM_BUG_ON(!PageLocked(page));
+		pra->referenced = 0;
+	}
 
 	anon_vma = rmap_walk_anon_lock(page, rwc);
 	if (!anon_vma)
@@ -1629,6 +1639,14 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
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
@@ -1660,8 +1678,6 @@ done:
 
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
