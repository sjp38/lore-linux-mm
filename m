Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 34C346B03A0
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 08:22:22 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 28so130742541iod.14
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:22:22 -0700 (PDT)
Received: from mail-io0-f194.google.com (mail-io0-f194.google.com. [209.85.223.194])
        by mx.google.com with ESMTPS id e190si11134623ioe.102.2017.04.21.05.22.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 05:22:21 -0700 (PDT)
Received: by mail-io0-f194.google.com with SMTP id x86so29794374ioe.3
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 05:22:21 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 12/13] mm, memory_hotplug: fix the section mismatch warning
Date: Fri, 21 Apr 2017 14:21:59 +0200
Message-Id: <20170421122159.24927-1-mhocko@kernel.org>
In-Reply-To: <20170421120512.23960-1-mhocko@kernel.org>
References: <20170421120512.23960-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Tobias Regnery <tobias.regnery@gmail.com>

From: Michal Hocko <mhocko@suse.com>

Tobias has reported following section mismatches introduced by "mm,
memory_hotplug: do not associate hotadded memory to zones until online".

WARNING: mm/built-in.o(.text+0x5a1c2): Section mismatch in reference from the function move_pfn_range_to_zone() to the function .meminit.text:memmap_init_zone()
The function move_pfn_range_to_zone() references
the function __meminit memmap_init_zone().
This is often because move_pfn_range_to_zone lacks a __meminit
annotation or the annotation of memmap_init_zone is wrong.

WARNING: mm/built-in.o(.text+0x5a25b): Section mismatch in reference from the function move_pfn_range_to_zone() to the function .meminit.text:init_currently_empty_zone()
The function move_pfn_range_to_zone() references
the function __meminit init_currently_empty_zone().
This is often because move_pfn_range_to_zone lacks a __meminit
annotation or the annotation of init_currently_empty_zone is wrong.

WARNING: vmlinux.o(.text+0x188aa2): Section mismatch in reference from the function move_pfn_range_to_zone() to the function .meminit.text:memmap_init_zone()
The function move_pfn_range_to_zone() references
the function __meminit memmap_init_zone().
This is often because move_pfn_range_to_zone lacks a __meminit
annotation or the annotation of memmap_init_zone is wrong.

WARNING: vmlinux.o(.text+0x188b3b): Section mismatch in reference from the function move_pfn_range_to_zone() to the function .meminit.text:init_currently_empty_zone()
The function move_pfn_range_to_zone() references
the function __meminit init_currently_empty_zone().
This is often because move_pfn_range_to_zone lacks a __meminit
annotation or the annotation of init_currently_empty_zone is wrong.

Both memmap_init_zone and init_currently_empty_zone are marked __meminit
but move_pfn_range_to_zone is used outside of __meminit sections (e.g.
devm_memremap_pages) so we have to hide it from the checker by __ref
annotation.

Reported-by: Tobias Regnery <tobias.regnery@gmail.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memory_hotplug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c5ca2a8571d0..f9e916a85792 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1070,7 +1070,7 @@ static void __meminit resize_pgdat_range(struct pglist_data *pgdat, unsigned lon
 	pgdat->node_spanned_pages = max(start_pfn + nr_pages, old_end_pfn) - pgdat->node_start_pfn;
 }
 
-void move_pfn_range_to_zone(struct zone *zone,
+void __ref move_pfn_range_to_zone(struct zone *zone,
 		unsigned long start_pfn, unsigned long nr_pages)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
