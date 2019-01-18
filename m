Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A1A998E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 21:16:54 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id w185so10404992qka.9
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 18:16:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w190sor48924830qkw.68.2019.01.17.18.16.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 Jan 2019 18:16:53 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/hotplug: invalid PFNs from pfn_to_online_page()
Date: Thu, 17 Jan 2019 21:16:50 -0500
Message-Id: <20190118021650.93222-1-cai@lca.pw>
In-Reply-To: <51e79597-21ef-3073-9036-cfc33291f395@lca.pw>
References: <51e79597-21ef-3073-9036-cfc33291f395@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: osalvador@suse.de, catalin.marinas@arm.com, mhocko@kernel.org, vbabka@suse.cz, linux-mm@kvack.org, Qian Cai <cai@lca.pw>

On an arm64 ThunderX2 server, the first kmemleak scan would crash [1]
with CONFIG_DEBUG_VM_PGFLAGS=y due to page_to_nid() found a pfn that is
not directly mapped (MEMBLOCK_NOMAP). Hence, the page->flags is
uninitialized.

This is due to the commit 9f1eb38e0e11 ("mm, kmemleak: little
optimization while scanning") starts to use pfn_to_online_page() instead
of pfn_valid(). However, in the CONFIG_MEMORY_HOTPLUG=y case,
pfn_to_online_page() does not call memblock_is_map_memory() while
pfn_valid() does.

[1]
[  102.195320] Unable to handle kernel NULL pointer dereference at virtual address 0000000000000006
[  102.204113] Mem abort info:
[  102.206921]   ESR = 0x96000005
[  102.209997]   Exception class = DABT (current EL), IL = 32 bits
[  102.215926]   SET = 0, FnV = 0
[  102.218993]   EA = 0, S1PTW = 0
[  102.222150] Data abort info:
[  102.225047]   ISV = 0, ISS = 0x00000005
[  102.228887]   CM = 0, WnR = 0
[  102.231866] user pgtable: 64k pages, 48-bit VAs, pgdp = (____ptrval____)
[  102.238572] [0000000000000006] pgd=0000000000000000, pud=0000000000000000
[  102.245448] Internal error: Oops: 96000005 [#1] SMP
[  102.264062] CPU: 60 PID: 1408 Comm: kmemleak Not tainted 5.0.0-rc2+ #8
[  102.280403] pstate: 60400009 (nZCv daif +PAN -UAO)
[  102.280409] pc : page_mapping+0x24/0x144
[  102.280415] lr : __dump_page+0x34/0x3dc
[  102.292923] sp : ffff00003a5cfd10
[  102.296229] x29: ffff00003a5cfd10 x28: 000000000000802f
[  102.301533] x27: 0000000000000000 x26: 0000000000277d00
[  102.306835] x25: ffff000010791f56 x24: ffff7fe000000000
[  102.312138] x23: ffff000010772f8b x22: ffff00001125f670
[  102.317442] x21: ffff000011311000 x20: ffff000010772f8b
[  102.322747] x19: fffffffffffffffe x18: 0000000000000000
[  102.328049] x17: 0000000000000000 x16: 0000000000000000
[  102.333352] x15: 0000000000000000 x14: ffff802698b19600
[  102.338654] x13: ffff802698b1a200 x12: ffff802698b16f00
[  102.343956] x11: ffff802698b1a400 x10: 0000000000001400
[  102.349260] x9 : 0000000000000001 x8 : ffff00001121a000
[  102.354563] x7 : 0000000000000000 x6 : ffff0000102c53b8
[  102.359868] x5 : 0000000000000000 x4 : 0000000000000003
[  102.365173] x3 : 0000000000000100 x2 : 0000000000000000
[  102.370476] x1 : ffff000010772f8b x0 : ffffffffffffffff
[  102.375782] Process kmemleak (pid: 1408, stack limit = 0x(____ptrval____))
[  102.382648] Call trace:
[  102.385091]  page_mapping+0x24/0x144
[  102.388659]  __dump_page+0x34/0x3dc
[  102.392140]  dump_page+0x28/0x4c
[  102.395363]  kmemleak_scan+0x4ac/0x680
[  102.399106]  kmemleak_scan_thread+0xb4/0xdc
[  102.403285]  kthread+0x12c/0x13c
[  102.406509]  ret_from_fork+0x10/0x18
[  102.410080] Code: d503201f f9400660 36000040 d1000413 (f9400661)
[  102.416357] ---[ end trace 4d4bd7f573490c8e ]---
[  102.420966] Kernel panic - not syncing: Fatal exception
[  102.426293] SMP: stopping secondary CPUs
[  102.431830] Kernel Offset: disabled
[  102.435311] CPU features: 0x002,20000c38
[  102.439223] Memory Limit: none
[  102.442384] ---[ end Kernel panic - not syncing: Fatal exception ]---

Fixes: 2d070eab2e82 ("mm: consider zone which is not fully populated to
have holes")
Signed-off-by: Qian Cai <cai@lca.pw>
---
 include/linux/memory_hotplug.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 07da5c6c5ba0..b8b36e6ac43b 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -26,7 +26,7 @@ struct vmem_altmap;
 	struct page *___page = NULL;			\
 	unsigned long ___nr = pfn_to_section_nr(pfn);	\
 							\
-	if (___nr < NR_MEM_SECTIONS && online_section_nr(___nr))\
+	if (online_section_nr(___nr) && pfn_valid(pfn))	\
 		___page = pfn_to_page(pfn);		\
 	___page;					\
 })
-- 
2.17.2 (Apple Git-113)
