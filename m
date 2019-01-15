Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id F06528E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 15:28:39 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id w19so3578084qto.13
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 12:28:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r14sor83346499qvl.3.2019.01.15.12.28.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 12:28:38 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: [PATCH] Revert "mm: use early_pfn_to_nid in page_ext_init"
Date: Tue, 15 Jan 2019 15:28:12 -0500
Message-Id: <20190115202812.75820-1-cai@lca.pw>
In-Reply-To: <20190109073409.GA2027@dhcp22.suse.cz>
References: <20190109073409.GA2027@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, Pavel.Tatashin@microsoft.com, mingo@kernel.org, hpa@zytor.com, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>

This reverts commit fe53ca54270a757f0a28ee6bf3a54d952b550ed0.

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

It did not handle it well in init_pages_in_zone() which ends up calling
page_to_nid().

page:ffffea0004200000 is uninitialized and poisoned
raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
page_owner info is not active (free page?)
kernel BUG at include/linux/mm.h:990!
RIP: 0010:init_page_owner+0x486/0x520

This means that assumptions behind commit fe53ca54270a ("mm: use
early_pfn_to_nid in page_ext_init") are incomplete. Therefore, revert
the commit for now. A proper way to move the page_owner initialization
to sooner is to hook into memmap initialization.

Acked-by: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Qian Cai <cai@lca.pw>
---
 init/main.c   | 3 ++-
 mm/page_ext.c | 4 +---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/init/main.c b/init/main.c
index e2e80ca3165a..c86a1c8f19f4 100644
--- a/init/main.c
+++ b/init/main.c
@@ -695,7 +695,6 @@ asmlinkage __visible void __init start_kernel(void)
 		initrd_start = 0;
 	}
 #endif
-	page_ext_init();
 	kmemleak_init();
 	setup_per_cpu_pageset();
 	numa_policy_init();
@@ -1131,6 +1130,8 @@ static noinline void __init kernel_init_freeable(void)
 	sched_init_smp();
 
 	page_alloc_init_late();
+	/* Initialize page ext after all struct pages are initialized. */
+	page_ext_init();
 
 	do_basic_setup();
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index ae44f7adbe07..8c78b8d45117 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -398,10 +398,8 @@ void __init page_ext_init(void)
 			 * We know some arch can have a nodes layout such as
 			 * -------------pfn-------------->
 			 * N0 | N1 | N2 | N0 | N1 | N2|....
-			 *
-			 * Take into account DEFERRED_STRUCT_PAGE_INIT.
 			 */
-			if (early_pfn_to_nid(pfn) != nid)
+			if (pfn_to_nid(pfn) != nid)
 				continue;
 			if (init_section_page_ext(pfn, nid))
 				goto oom;
-- 
2.17.2 (Apple Git-113)
