Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7FF8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 17:02:57 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id d3so2835825pgv.23
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 14:02:57 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f16si9289762pgg.173.2019.01.08.14.02.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 14:02:55 -0800 (PST)
Date: Tue, 8 Jan 2019 14:02:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm/page_owner: fix for deferred struct page init
Message-Id: <20190108140253.5b6db0ab37334b845e9d4fc2@linux-foundation.org>
In-Reply-To: <1546953547.6911.1.camel@lca.pw>
References: <20190103202235.GE31793@dhcp22.suse.cz>
	<a5666d82-b7ad-4b90-5f4e-fd22afc3e1dc@lca.pw>
	<20190104130906.GO31793@dhcp22.suse.cz>
	<e4ad9d12-387d-1cc6-f404-cae6d43ccf80@lca.pw>
	<20190104151737.GT31793@dhcp22.suse.cz>
	<c8faf7eb-d23f-4ef7-3432-0acc7165f883@lca.pw>
	<20190104153245.GV31793@dhcp22.suse.cz>
	<fa135cd8-32e5-86f7-14ee-30685bca91b5@lca.pw>
	<20190107184309.GM31793@dhcp22.suse.cz>
	<bfcd017d-dcf4-b687-1aef-ab0810b12c73@lca.pw>
	<20190108082032.GP31793@dhcp22.suse.cz>
	<1546953547.6911.1.camel@lca.pw>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qian Cai <cai@lca.pw>
Cc: Michal Hocko <mhocko@kernel.org>, Pavel.Tatashin@microsoft.com, mingo@kernel.org, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org


It's unclear (to me) where we stand with this patch.  Shold we proceed
with v3 for now, or is something else planned?


From: Qian Cai <cai@lca.pw>
Subject: mm/page_owner: fix for deferred struct page init

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

However, it did not handle it well in init_pages_in_zone() which end up
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
start_kernel(), just move it after page_alloc_init_late() to ensure that
there is no deferred pages need to de dealt with. If deselected
DEFERRED_STRUCT_PAGE_INIT, it is still better to call page_ext_init()
earlier, so page owner could catch more early page allocation call
sites. This gives us a good compromise between catching good and bad
call sites (See the v1 patch [1]) in case of DEFERRED_STRUCT_PAGE_INIT.

[1] https://lore.kernel.org/lkml/20181220060303.38686-1-cai@lca.pw/

Link: http://lkml.kernel.org/r/20181220203156.43441-1-cai@lca.pw
Fixes: fe53ca54270 (mm: use early_pfn_to_nid in page_ext_init)
Signed-off-by: Qian Cai <cai@lca.pw>
Suggested-by: Michal Hocko <mhocko@kernel.org>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Yang Shi <yang.shi@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 init/main.c   |    5 +++++
 mm/page_ext.c |    3 +--
 2 files changed, 6 insertions(+), 2 deletions(-)

--- a/init/main.c~mm-page_owner-fix-for-deferred-struct-page-init
+++ a/init/main.c
@@ -695,7 +695,9 @@ asmlinkage __visible void __init start_k
 		initrd_start = 0;
 	}
 #endif
+#ifndef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 	page_ext_init();
+#endif
 	kmemleak_init();
 	setup_per_cpu_pageset();
 	numa_policy_init();
@@ -1131,6 +1133,9 @@ static noinline void __init kernel_init_
 	sched_init_smp();
 
 	page_alloc_init_late();
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+	page_ext_init();
+#endif
 
 	do_basic_setup();
 
--- a/mm/page_ext.c~mm-page_owner-fix-for-deferred-struct-page-init
+++ a/mm/page_ext.c
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
_
