Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 568F56B000C
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:35:31 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id g7-v6so2121338qtp.19
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 12:35:31 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id m54-v6si2148909qtk.122.2018.07.26.12.35.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 12:35:30 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v2 1/3] mm: make memmap_init a proper function
Date: Thu, 26 Jul 2018 15:35:07 -0400
Message-Id: <20180726193509.3326-2-pasha.tatashin@oracle.com>
In-Reply-To: <20180726193509.3326-1-pasha.tatashin@oracle.com>
References: <20180726193509.3326-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, linux-mm@kvack.org, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, jrdr.linux@gmail.com, bhe@redhat.com, gregkh@linuxfoundation.org, vbabka@suse.cz, richard.weiyang@gmail.com, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, osalvador@techadventures.net, pasha.tatashin@oracle.com, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

memmap_init is sometimes a macro sometimes a function based on
__HAVE_ARCH_MEMMAP_INIT. It is only a function on ia64. Make
memmap_init a weak function instead, and let ia64 redefine it.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
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
index 2dec8056a091..6796dacd46ac 100644
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
