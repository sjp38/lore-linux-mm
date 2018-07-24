Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7817F6B0266
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 20:26:02 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o18-v6so5100024qko.21
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 17:26:02 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id e65-v6si75773qkd.158.2018.07.24.17.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 17:26:01 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH 1/3] mm: make memmap_init a proper function
Date: Tue, 24 Jul 2018 19:55:18 -0400
Message-Id: <20180724235520.10200-2-pasha.tatashin@oracle.com>
In-Reply-To: <20180724235520.10200-1-pasha.tatashin@oracle.com>
References: <20180724235520.10200-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, pasha.tatashin@oracle.com, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

memmap_init is sometimes a macro sometimes a function based on
__HAVE_ARCH_MEMMAP_INIT. It is only a function on ia64. Make
memmap_init a weak function instead, and let ia64 redefine it.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 arch/ia64/include/asm/pgtable.h | 1 -
 mm/page_alloc.c                 | 9 +++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index 165827774bea..b1e7468eb65a 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -544,7 +544,6 @@ extern struct page *zero_page_memmap_ptr;
 
 #  ifdef CONFIG_VIRTUAL_MEM_MAP
   /* arch mem_map init routine is needed due to holes in a virtual mem_map */
-#   define __HAVE_ARCH_MEMMAP_INIT
     extern void memmap_init (unsigned long size, int nid, unsigned long zone,
 			     unsigned long start_pfn);
 #  endif /* CONFIG_VIRTUAL_MEM_MAP */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a790ef4be74e..cea749b26394 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5554,10 +5554,11 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 	}
 }
 
-#ifndef __HAVE_ARCH_MEMMAP_INIT
-#define memmap_init(size, nid, zone, start_pfn) \
-	memmap_init_zone((size), (nid), (zone), (start_pfn), MEMMAP_EARLY, NULL)
-#endif
+void __meminit __weak memmap_init(unsigned long size, int nid,
+				  unsigned long zone, unsigned long start_pfn)
+{
+	memmap_init_zone(size, nid, zone, start_pfn, MEMMAP_EARLY, NULL);
+}
 
 static int zone_batchsize(struct zone *zone)
 {
-- 
2.18.0
