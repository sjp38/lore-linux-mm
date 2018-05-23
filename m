Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2C1796B000C
	for <linux-mm@kvack.org>; Wed, 23 May 2018 08:56:06 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n17-v6so2285725wmc.8
        for <linux-mm@kvack.org>; Wed, 23 May 2018 05:56:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z11-v6sor6792424wre.74.2018.05.23.05.56.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 May 2018 05:56:04 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] mm, memory_hotplug: make has_unmovable_pages more robust
Date: Wed, 23 May 2018 14:55:54 +0200
Message-Id: <20180523125555.30039-2-mhocko@kernel.org>
In-Reply-To: <20180523125555.30039-1-mhocko@kernel.org>
References: <20180523125555.30039-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@techadventures.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Oscar has reported:
: Due to an unfortunate setting with movablecore, memblocks containing bootmem
: memory (pages marked by get_page_bootmem()) ended up marked in zone_movable.
: So while trying to remove that memory, the system failed in do_migrate_range
: and __offline_pages never returned.
:
: This can be reproduced by running
: qemu-system-x86_64 -m 6G,slots=8,maxmem=8G -numa node,mem=4096M -numa node,mem=2048M
: and movablecore=4G kernel command line
:
: linux kernel: BIOS-provided physical RAM map:
: linux kernel: BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
: linux kernel: BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
: linux kernel: BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
: linux kernel: BIOS-e820: [mem 0x0000000000100000-0x00000000bffdffff] usable
: linux kernel: BIOS-e820: [mem 0x00000000bffe0000-0x00000000bfffffff] reserved
: linux kernel: BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
: linux kernel: BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
: linux kernel: BIOS-e820: [mem 0x0000000100000000-0x00000001bfffffff] usable
: linux kernel: NX (Execute Disable) protection: active
: linux kernel: SMBIOS 2.8 present.
: linux kernel: DMI: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.0.0-prebuilt.qemu-project.org
: linux kernel: Hypervisor detected: KVM
: linux kernel: e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
: linux kernel: e820: remove [mem 0x000a0000-0x000fffff] usable
: linux kernel: last_pfn = 0x1c0000 max_arch_pfn = 0x400000000
:
: linux kernel: SRAT: PXM 0 -> APIC 0x00 -> Node 0
: linux kernel: SRAT: PXM 1 -> APIC 0x01 -> Node 1
: linux kernel: ACPI: SRAT: Node 0 PXM 0 [mem 0x00000000-0x0009ffff]
: linux kernel: ACPI: SRAT: Node 0 PXM 0 [mem 0x00100000-0xbfffffff]
: linux kernel: ACPI: SRAT: Node 0 PXM 0 [mem 0x100000000-0x13fffffff]
: linux kernel: ACPI: SRAT: Node 1 PXM 1 [mem 0x140000000-0x1bfffffff]
: linux kernel: ACPI: SRAT: Node 0 PXM 0 [mem 0x1c0000000-0x43fffffff] hotplug
: linux kernel: NUMA: Node 0 [mem 0x00000000-0x0009ffff] + [mem 0x00100000-0xbfffffff] -> [mem 0x0
: linux kernel: NUMA: Node 0 [mem 0x00000000-0xbfffffff] + [mem 0x100000000-0x13fffffff] -> [mem 0
: linux kernel: NODE_DATA(0) allocated [mem 0x13ffd6000-0x13fffffff]
: linux kernel: NODE_DATA(1) allocated [mem 0x1bffd3000-0x1bfffcfff]
:
: zoneinfo shows that the zone movable is placed into both numa nodes:
: Node 0, zone  Movable
:   pages free     160140
:         min      1823
:         low      2278
:         high     2733
:         spanned  262144
:         present  262144
:         managed  245670
: Node 1, zone  Movable
:   pages free     448427
:         min      3827
:         low      4783
:         high     5739
:         spanned  524288
:         present  524288
:         managed  515766

Note how only Node 0 has a hutplugable memory region which would rule
it out from the early memblock allocations (most likely memmap). Node1
will surely contain memmaps on the same node and those would prevent
offlining to succeed. So this is arguably a configuration issue.
Although one could argue that we should be more clever and rule early
allocations from the zone movable. This would be correct but probably
not worth the effort considering what a hack movablecore is.

Anyway, We could do better for those cases though. We rely on
start_isolate_page_range resp. has_unmovable_pages to do their job. The
first one isolates the whole range to be offlined so that we do not
allocate from it anymore and the later makes sure we are not stumbling
over non-migrateable pages.

has_unmovable_pages is overly optimistic, however. It doesn't check all
the pages if we are withing zone_movable because we rely that those
pages will be always migrateable. As it turns out we are still not
perfect there. While bootmem pages in zonemovable sound like a clear bug
which should be fixed let's remove the optimization for now and warn if
we encounter unmovable pages in zone_movable in the meantime. That
should help for now at least.

Btw. this wasn't a real problem until 72b39cfc4d75 ("mm, memory_hotplug:
do not fail offlining too early") because we used to have a small number
of retries and then failed. This turned out to be too fragile though.

Reported-by: Oscar Salvador <osalvador@techadventures.net>
Tested-by: Oscar Salvador <osalvador@techadventures.net>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/page_alloc.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3c6f4008ea55..b9a45753244d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7629,11 +7629,12 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	unsigned long pfn, iter, found;
 
 	/*
-	 * For avoiding noise data, lru_add_drain_all() should be called
-	 * If ZONE_MOVABLE, the zone never contains unmovable pages
+	 * TODO we could make this much more efficient by not checking every
+	 * page in the range if we know all of them are in MOVABLE_ZONE and
+	 * that the movable zone guarantees that pages are migratable but
+	 * the later is not the case right now unfortunatelly. E.g. movablecore
+	 * can still lead to having bootmem allocations in zone_movable.
 	 */
-	if (zone_idx(zone) == ZONE_MOVABLE)
-		return false;
 
 	/*
 	 * CMA allocations (alloc_contig_range) really need to mark isolate
@@ -7654,7 +7655,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 		page = pfn_to_page(check);
 
 		if (PageReserved(page))
-			return true;
+			goto unmovable;
 
 		/*
 		 * Hugepages are not in LRU lists, but they're movable.
@@ -7704,9 +7705,12 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 		 * page at boot.
 		 */
 		if (found > count)
-			return true;
+			goto unmovable;
 	}
 	return false;
+unmovable:
+	WARN_ON_ONCE(zone_idx(zone) == ZONE_MOVABLE);
+	return true;
 }
 
 #if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
-- 
2.17.0
