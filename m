Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 23EDD6B007E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 04:43:55 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id na2so24169318lbb.1
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 01:43:55 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id j201si42982035wmg.66.2016.06.10.01.43.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jun 2016 01:43:53 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r5so16229703wmr.0
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 01:43:53 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/2] slab: do not panic on invalid gfp_mask
Date: Fri, 10 Jun 2016 10:43:20 +0200
Message-Id: <1465548200-11384-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1465548200-11384-1-git-send-email-mhocko@kernel.org>
References: <1465548200-11384-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cristopher Lameter <clameter@sgi.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

both SLAB and SLUB BUG() when a caller provides an invalid gfp_mask.
This is a rather harsh way to announce a non-critical issue. Allocator
is free to ignore invalid flags. Let's simply replace BUG() by
dump_stack to tell the offender and fixup the mask to move on with the
allocation request.

This is an example for kmalloc(GFP_KERNEL|__GFP_HIGHMEM) from a test
module.
[   31.914753] Unexpected gfp: 0x2 (__GFP_HIGHMEM). Fixing up to gfp: 0x24000c0 (GFP_KERNEL). Fix your code!
[   31.914754] CPU: 0 PID: 2916 Comm: insmod Tainted: G           O    4.6.0-slabgfp2-00002-g4cdfc2ef4892-dirty #936
[   31.914755] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Debian-1.8.2-1 04/01/2014
[   31.914756]  0000000000000000 ffff88000d777c00 ffffffff8130e2fb ffff88000ec006c0
[   31.914758]  000000000000000c ffff88000d777c58 ffffffff811791dd 0000000000000246
[   31.914759]  0000000000000246 0000000000000046 00000002024000c0 ffff88000fa1d888
[   31.914759] Call Trace:
[   31.914760]  [<ffffffff8130e2fb>] dump_stack+0x67/0x90
[   31.914762]  [<ffffffff811791dd>] cache_alloc_refill+0x201/0x617
[   31.914763]  [<ffffffff81179b3f>] kmem_cache_alloc_trace+0xa7/0x24a
[   31.914764]  [<ffffffffa0005000>] ? 0xffffffffa0005000
[   31.914765]  [<ffffffffa0005020>] mymodule_init+0x20/0x1000 [test_slab]
[   31.914767]  [<ffffffff81000402>] do_one_initcall+0xe7/0x16c
[   31.914768]  [<ffffffff810b02de>] ? rcu_read_lock_sched_held+0x61/0x69
[   31.914769]  [<ffffffff81179c2f>] ? kmem_cache_alloc_trace+0x197/0x24a
[   31.914771]  [<ffffffff81125edc>] do_init_module+0x5f/0x1d9
[   31.914772]  [<ffffffff810d2c66>] load_module+0x1a3d/0x1f21
[   31.914774]  [<ffffffff81622931>] ? retint_kernel+0x2d/0x2d
[   31.914775]  [<ffffffff810d3232>] SyS_init_module+0xe8/0x10e
[   31.914776]  [<ffffffff810d3232>] ? SyS_init_module+0xe8/0x10e
[   31.914778]  [<ffffffff81001d08>] do_syscall_64+0x68/0x13f
[   31.914779]  [<ffffffff8162201a>] entry_SYSCALL64_slow_path+0x25/0x25

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/slab.c | 6 ++++--
 mm/slub.c | 5 +++--
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 03fb724d6e48..fc9496bdd038 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2687,8 +2687,10 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
 	 */
 	if (unlikely(flags & GFP_SLAB_BUG_MASK)) {
 		gfp_t invalid_mask = flags & GFP_SLAB_BUG_MASK;
-		pr_emerg("Unexpected gfp: %#x (%pGg)\n", invalid_mask, &invalid_mask);
-		BUG();
+		flags &= ~GFP_SLAB_BUG_MASK;
+		pr_warn("Unexpected gfp: %#x (%pGg). Fixing up to gfp: %#x (%pGg). Fix your code!\n",
+				invalid_mask, &invalid_mask, flags, &flags);
+		dump_stack();
 	}
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
diff --git a/mm/slub.c b/mm/slub.c
index dd5a9eee7df5..ca60b414e569 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1629,8 +1629,9 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 {
 	if (unlikely(flags & GFP_SLAB_BUG_MASK)) {
 		gfp_t invalid_mask = flags & GFP_SLAB_BUG_MASK;
-		pr_emerg("Unexpected gfp: %#x (%pGg)\n", invalid_mask, &invalid_mask);
-		BUG();
+		flags &= ~GFP_SLAB_BUG_MASK;
+		pr_warn("Unexpected gfp: %#x (%pGg). Fixing up to gfp: %#x (%pGg). Fix your code!\n",
+				invalid_mask, &invalid_mask, flags, &flags);
 	}
 
 	return allocate_slab(s,
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
