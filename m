Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 590418E0001
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 13:50:48 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id d35so2828204qtd.20
        for <linux-mm@kvack.org>; Thu, 20 Dec 2018 10:50:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o29sor7677357qve.37.2018.12.20.10.50.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Dec 2018 10:50:47 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: [PATCH v2] mm/page_owner: fix for deferred struct page init
Date: Thu, 20 Dec 2018 13:50:31 -0500
Message-Id: <20181220185031.43146-1-cai@lca.pw>
In-Reply-To: <20181220092202.GD14234@dhcp22.suse.cz>
References: <20181220092202.GD14234@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, Pavel.Tatashin@microsoft.com, mingo@kernel.org, hpa@zytor.com, mgorman@techsingularity.net, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>

When booting a system with "page_owner=on",

start_kernel
  page_ext_init
    invoke_init_callbacks
      init_section_page_ext
        init_page_owner
          init_early_allocated_pages
            init_zones_in_node
              init_pages_in_zone
                lookup_page_ext
                  page_to_nid

The issue here is that page_to_nid() will not work since some page
flags have no node information until later in page_alloc_init_late() due
to DEFERRED_STRUCT_PAGE_INIT. Hence, it could trigger an out-of-bounds
access with an invalid nid.

[    8.666047] UBSAN: Undefined behaviour in ./include/linux/mm.h:1104:50
[    8.672603] index 7 is out of range for type 'zone [5]'

Also, kernel will panic since flags were poisoned earlier with,

CONFIG_DEBUG_VM_PGFLAGS=y
CONFIG_NODE_NOT_IN_PAGE_FLAGS=n

start_kernel
  setup_arch
    pagetable_init
      paging_init
        sparse_init
          sparse_init_nid
            memblock_alloc_try_nid_raw

Although later it tries to set page flags for pages in reserved bootmem
regions,

mm_init
  mem_init
    memblock_free_all
      free_low_memory_core_early
        reserve_bootmem_region

there could still have some freed pages from the page allocator but yet
to be initialized due to DEFERRED_STRUCT_PAGE_INIT. It have already been
dealt with a bit in page_ext_init().

* Take into account DEFERRED_STRUCT_PAGE_INIT.
*/
if (early_pfn_to_nid(pfn) != nid)
	continue;

However it did not handle it well in init_pages_in_zone() which end up
calling page_to_nid().

[   11.917212] page:ffffea0004200000 is uninitialized and poisoned
[   11.917220] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff
ffffffffffffffff
[   11.921745] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff
ffffffffffffffff
[   11.924523] page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
[   11.926498] page_owner info is not active (free page?)
[   12.329560] kernel BUG at include/linux/mm.h:990!
[   12.337632] RIP: 0010:init_page_owner+0x486/0x520

Since there is no other routines depend on page_ext_init() in
start_kernel() and no real benefit to call it so early, just move it
after page_alloc_init_late() to ensure that there is no deferred pages
need to de dealt with.

Suggested-by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Qian Cai <cai@lca.pw>
---

v2: postpone init_page_ext() to after page_alloc_init_late().

 init/main.c   | 2 +-
 mm/page_ext.c | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/init/main.c b/init/main.c
index 2b7b7fe173c9..1aeb062b2cb7 100644
--- a/init/main.c
+++ b/init/main.c
@@ -696,7 +696,6 @@ asmlinkage __visible void __init start_kernel(void)
 		initrd_start = 0;
 	}
 #endif
-	page_ext_init();
 	kmemleak_init();
 	setup_per_cpu_pageset();
 	numa_policy_init();
@@ -1147,6 +1146,7 @@ static noinline void __init kernel_init_freeable(void)
 	sched_init_smp();
 
 	page_alloc_init_late();
+	page_ext_init();
 
 	do_basic_setup();
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index ae44f7adbe07..d76fd51e312a 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -399,9 +399,8 @@ void __init page_ext_init(void)
 			 * -------------pfn-------------->
 			 * N0 | N1 | N2 | N0 | N1 | N2|....
 			 *
-			 * Take into account DEFERRED_STRUCT_PAGE_INIT.
 			 */
-			if (early_pfn_to_nid(pfn) != nid)
+			if (pfn_to_nid(pfn) != nid)
 				continue;
 			if (init_section_page_ext(pfn, nid))
 				goto oom;
-- 
2.17.2 (Apple Git-113)
