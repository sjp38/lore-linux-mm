Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id DF40D6B00A6
	for <linux-mm@kvack.org>; Tue, 14 May 2013 08:05:14 -0400 (EDT)
Subject: [3.10-rc1 SLUB?] mm: kmemcheck warning.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201305142105.EBE34832.LOOHFtVSFJOFMQ@I-love.SAKURA.ne.jp>
Date: Tue, 14 May 2013 21:05:09 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

I got below warning.

  WARNING: kmemcheck: Caught 8-bit read from uninitialized memory (ffff880077361b28)
  7500000000000000a8f5fc760088ffff00000000000000000000000000000000
   u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u
                   ^
  RIP: 0010:[<ffffffff812a94d9>]  [<ffffffff812a94d9>] __rb_insert_augmented+0x49/0x1c0
  RSP: 0018:ffff880079cadbc8  EFLAGS: 00010286
  RAX: ffff8800773619c8 RBX: ffff880076980bb8 RCX: ffff880077361b28
  RDX: ffffffff81116630 RSI: ffff880076980bb8 RDI: ffff880076fcf5a8
  RBP: ffff880079cadbf8 R08: ffff8800773619d0 R09: 0000000000000238
  R10: 0000000000000236 R11: 2222222222222222 R12: ffff880076fcf5a8
  R13: ffff880077361918 R14: 0000000000000000 R15: ffff880077115a40
  FS:  0000000000000000(0000) GS:ffff88007b200000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  CR2: ffff88007a6346c8 CR3: 0000000077365000 CR4: 00000000000407f0
  DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
  DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
   [<ffffffff81116c4f>] vma_interval_tree_insert+0x7f/0x90
   [<ffffffff81120013>] __vma_link_file+0x43/0x70
   [<ffffffff811218f9>] vma_adjust+0xf9/0x690
   [<ffffffff81121f91>] __split_vma+0x101/0x1e0
   [<ffffffff811227b7>] do_munmap+0x1f7/0x3a0
   [<ffffffff8112322a>] mmap_region+0x28a/0x630
   [<ffffffff8112389d>] do_mmap_pgoff+0x2cd/0x420
   [<ffffffff8110ec28>] vm_mmap_pgoff+0xa8/0xd0
   [<ffffffff811204b6>] SyS_mmap_pgoff+0x136/0x230
   [<ffffffff81006ed9>] SyS_mmap+0x29/0x30
   [<ffffffff817a7512>] system_call_fastpath+0x16/0x1b
   [<ffffffffffffffff>] 0xffffffffffffffff
  WARNING: kmemcheck: Caught 64-bit read from uninitialized memory (ffff880077361b40)
  3902000000000000481b36770088ffff481b36770088ffff0000000000000000
   u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u u
   ^
  RIP: 0010:[<ffffffff8111705f>]  [<ffffffff8111705f>] vma_interval_tree_remove+0x17f/0x270
  RSP: 0018:ffff880079cadc08  EFLAGS: 00010286
  RAX: 0000000000000239 RBX: 0000000000000239 RCX: ffff880077361b28
  RDX: ffff880076fcf550 RSI: ffff880076980bb8 RDI: 0000000000000000
  RBP: ffff880079cadc18 R08: 0000000000000000 R09: 0000000000000238
  R10: 0000000000000236 R11: ffff8800773619c8 R12: ffff88007a197a20
  R13: 0000003452a3a000 R14: 0000000000000000 R15: ffff880077115a40
  FS:  0000000000000000(0000) GS:ffff88007b200000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  CR2: ffff88007a6346c8 CR3: 0000000077365000 CR4: 00000000000407f0
  DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
  DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000400
   [<ffffffff811219f7>] vma_adjust+0x1f7/0x690
   [<ffffffff81121f91>] __split_vma+0x101/0x1e0
   [<ffffffff811227b7>] do_munmap+0x1f7/0x3a0
   [<ffffffff8112322a>] mmap_region+0x28a/0x630
   [<ffffffff8112389d>] do_mmap_pgoff+0x2cd/0x420
   [<ffffffff8110ec28>] vm_mmap_pgoff+0xa8/0xd0
   [<ffffffff811204b6>] SyS_mmap_pgoff+0x136/0x230
   [<ffffffff81006ed9>] SyS_mmap+0x29/0x30
   [<ffffffff817a7512>] system_call_fastpath+0x16/0x1b
   [<ffffffffffffffff>] 0xffffffffffffffff

Kernel config is at http://I-love.SAKURA.ne.jp/tmp/config-3.10-rc1-kmemcheck
Full dmesg is at http://I-love.SAKURA.ne.jp/tmp/dmesg-3.10-rc1-kmemcheck.txt

By applying below patch, "uninitialized memory" warnings are gone. But it seems
that memory corruption bug is remaining. Thus, 'some field of "struct anon_vma"
and "struct anon_vma_chain" are not initialized' might be caused by SLUB's
problem. (Full dmesg after applying below patch is at
http://I-love.SAKURA.ne.jp/tmp/dmesg-3.10-rc1-kmemcheck2.txt )

Regards.
--------------------
>From 8d4d6df4d112c1b38bf880a3a63d0336c9b7d0e3 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 14 May 2013 16:32:05 +0900
Subject: [PATCH] mm: Fix kmemcheck warning.

Some field of "struct anon_vma" and "struct anon_vma_chain" are not
initialized, resulting kmemcheck warning.

(NOTE: This will likely be a wrong fix. Don't apply blindly.)

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/rmap.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 6280da8..e2fc40d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -69,7 +69,7 @@ static inline struct anon_vma *anon_vma_alloc(void)
 {
 	struct anon_vma *anon_vma;
 
-	anon_vma = kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
+	anon_vma = kmem_cache_zalloc(anon_vma_cachep, GFP_KERNEL);
 	if (anon_vma) {
 		atomic_set(&anon_vma->refcount, 1);
 		/*
@@ -113,7 +113,7 @@ static inline void anon_vma_free(struct anon_vma *anon_vma)
 
 static inline struct anon_vma_chain *anon_vma_chain_alloc(gfp_t gfp)
 {
-	return kmem_cache_alloc(anon_vma_chain_cachep, gfp);
+	return kmem_cache_zalloc(anon_vma_chain_cachep, gfp);
 }
 
 static void anon_vma_chain_free(struct anon_vma_chain *anon_vma_chain)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
