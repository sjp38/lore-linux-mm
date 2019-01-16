Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7C5418E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 17:37:52 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id u197so6624491qka.8
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 14:37:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o17sor87255255qvn.72.2019.01.16.14.37.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 14:37:51 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: [PATCH] slab: kmemleak no scan alien caches
Date: Wed, 16 Jan 2019 17:37:20 -0500
Message-Id: <20190116223720.84181-1-cai@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: catalin.marinas@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>

Kmemleak throws endless warnings during boot due to in
__alloc_alien_cache(),

alc = kmalloc_node(memsize, gfp, node);
init_arraycache(&alc->ac, entries, batch);
kmemleak_no_scan(ac);

Kmemleak does not track the array cache (alc->ac) but the alien cache
(alc) instead, so let it track the later by lifting kmemleak_no_scan()
out of init_arraycache().

There is another place calls init_arraycache(), but
alloc_kmem_cache_cpus() uses the percpu allocation where will never be
considered as a leak.

[   32.258841] kmemleak: Found object by alias at 0xffff8007b9aa7e38
[   32.258847] CPU: 190 PID: 1 Comm: swapper/0 Not tainted 5.0.0-rc2+ #2
[   32.258851] Call trace:
[   32.258858]  dump_backtrace+0x0/0x168
[   32.258863]  show_stack+0x24/0x30
[   32.258868]  dump_stack+0x88/0xb0
[   32.258873]  lookup_object+0x84/0xac
[   32.258877]  find_and_get_object+0x84/0xe4
[   32.258882]  kmemleak_no_scan+0x74/0xf4
[   32.258887]  setup_kmem_cache_node+0x2b4/0x35c
[   32.258892]  __do_tune_cpucache+0x250/0x2d4
[   32.258896]  do_tune_cpucache+0x4c/0xe4
[   32.258901]  enable_cpucache+0xc8/0x110
[   32.258905]  setup_cpu_cache+0x40/0x1b8
[   32.258909]  __kmem_cache_create+0x240/0x358
[   32.258913]  create_cache+0xc0/0x198
[   32.258918]  kmem_cache_create_usercopy+0x158/0x20c
[   32.258922]  kmem_cache_create+0x50/0x64
[   32.258928]  fsnotify_init+0x58/0x6c
[   32.258932]  do_one_initcall+0x194/0x388
[   32.258937]  kernel_init_freeable+0x668/0x688
[   32.258941]  kernel_init+0x18/0x124
[   32.258946]  ret_from_fork+0x10/0x18
[   32.258950] kmemleak: Object 0xffff8007b9aa7e00 (size 256):
[   32.258954] kmemleak:   comm "swapper/0", pid 1, jiffies 4294697137
[   32.258958] kmemleak:   min_count = 1
[   32.258962] kmemleak:   count = 0
[   32.258965] kmemleak:   flags = 0x1
[   32.258969] kmemleak:   checksum = 0
[   32.258972] kmemleak:   backtrace:
[   32.258977]      kmemleak_alloc+0x84/0xb8
[   32.258982]      kmem_cache_alloc_node_trace+0x31c/0x3a0
[   32.258987]      __kmalloc_node+0x58/0x78
[   32.258991]      setup_kmem_cache_node+0x26c/0x35c
[   32.258996]      __do_tune_cpucache+0x250/0x2d4
[   32.259001]      do_tune_cpucache+0x4c/0xe4
[   32.259005]      enable_cpucache+0xc8/0x110
[   32.259010]      setup_cpu_cache+0x40/0x1b8
[   32.259014]      __kmem_cache_create+0x240/0x358
[   32.259018]      create_cache+0xc0/0x198
[   32.259022]      kmem_cache_create_usercopy+0x158/0x20c
[   32.259026]      kmem_cache_create+0x50/0x64
[   32.259031]      fsnotify_init+0x58/0x6c
[   32.259035]      do_one_initcall+0x194/0x388
[   32.259039]      kernel_init_freeable+0x668/0x688
[   32.259043]      kernel_init+0x18/0x124
[   32.259048] kmemleak: Not scanning unknown object at 0xffff8007b9aa7e38
[   32.259052] CPU: 190 PID: 1 Comm: swapper/0 Not tainted 5.0.0-rc2+ #2
[   32.259056] Call trace:
[   32.259060]  dump_backtrace+0x0/0x168
[   32.259065]  show_stack+0x24/0x30
[   32.259070]  dump_stack+0x88/0xb0
[   32.259074]  kmemleak_no_scan+0x90/0xf4
[   32.259078]  setup_kmem_cache_node+0x2b4/0x35c
[   32.259083]  __do_tune_cpucache+0x250/0x2d4
[   32.259088]  do_tune_cpucache+0x4c/0xe4
[   32.259092]  enable_cpucache+0xc8/0x110
[   32.259096]  setup_cpu_cache+0x40/0x1b8
[   32.259100]  __kmem_cache_create+0x240/0x358
[   32.259104]  create_cache+0xc0/0x198
[   32.259108]  kmem_cache_create_usercopy+0x158/0x20c
[   32.259112]  kmem_cache_create+0x50/0x64
[   32.259116]  fsnotify_init+0x58/0x6c
[   32.259120]  do_one_initcall+0x194/0x388
[   32.259125]  kernel_init_freeable+0x668/0x688
[   32.259129]  kernel_init+0x18/0x124
[   32.259133]  ret_from_fork+0x10/0x18

Fixes: 1fe00d50a9e8 (slab: factor out initialization of array cache)
Signed-off-by: Qian Cai <cai@lca.pw>
---
 mm/slab.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 78eb8c5bf4e4..0aff454f007b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -550,14 +550,6 @@ static void start_cpu_timer(int cpu)
 
 static void init_arraycache(struct array_cache *ac, int limit, int batch)
 {
-	/*
-	 * The array_cache structures contain pointers to free object.
-	 * However, when such objects are allocated or transferred to another
-	 * cache the pointers are not cleared and they could be counted as
-	 * valid references during a kmemleak scan. Therefore, kmemleak must
-	 * not scan such objects.
-	 */
-	kmemleak_no_scan(ac);
 	if (ac) {
 		ac->avail = 0;
 		ac->limit = limit;
@@ -573,6 +565,14 @@ static struct array_cache *alloc_arraycache(int node, int entries,
 	struct array_cache *ac = NULL;
 
 	ac = kmalloc_node(memsize, gfp, node);
+	/*
+	 * The array_cache structures contain pointers to free object.
+	 * However, when such objects are allocated or transferred to another
+	 * cache the pointers are not cleared and they could be counted as
+	 * valid references during a kmemleak scan. Therefore, kmemleak must
+	 * not scan such objects.
+	 */
+	kmemleak_no_scan(ac);
 	init_arraycache(ac, entries, batchcount);
 	return ac;
 }
@@ -667,6 +667,7 @@ static struct alien_cache *__alloc_alien_cache(int node, int entries,
 
 	alc = kmalloc_node(memsize, gfp, node);
 	if (alc) {
+		kmemleak_no_scan(alc);
 		init_arraycache(&alc->ac, entries, batch);
 		spin_lock_init(&alc->lock);
 	}
-- 
2.17.2 (Apple Git-113)
