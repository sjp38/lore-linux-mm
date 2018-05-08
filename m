Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5FFF36B000A
	for <linux-mm@kvack.org>; Mon,  7 May 2018 22:34:37 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l65so2943313qke.21
        for <linux-mm@kvack.org>; Mon, 07 May 2018 19:34:37 -0700 (PDT)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.201])
        by mx.google.com with ESMTPS id p27-v6si109460qtl.92.2018.05.07.19.34.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 May 2018 19:34:36 -0700 (PDT)
From: Huaisheng HS1 Ye <yehs1@lenovo.com>
Subject: [External]  [RFC PATCH v1 5/6] mm: get zone spanned pages separately
 for DRAM and NVDIMM
Date: Tue, 8 May 2018 02:34:17 +0000
Message-ID: <HK2PR03MB16843F0A91E190ECDBB28F2F929A0@HK2PR03MB1684.apcprd03.prod.outlook.com>
References: <1525746628-114136-1-git-send-email-yehs1@lenovo.com>
 <1525746628-114136-6-git-send-email-yehs1@lenovo.com>
In-Reply-To: <1525746628-114136-6-git-send-email-yehs1@lenovo.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "willy@infradead.org" <willy@infradead.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "pasha.tatashin@oracle.com" <pasha.tatashin@oracle.com>, "alexander.levin@verizon.com" <alexander.levin@verizon.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "penguin-kernel@I-love.SAKURA.ne.jp" <penguin-kernel@I-love.SAKURA.ne.jp>, "colyli@suse.de" <colyli@suse.de>, NingTing Cheng <chengnt@lenovo.com>, Ocean HY1 He <hehy1@lenovo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

DRAM and NVDIMM are divided into separate zones, thus NVM
zone is dedicated for NVDIMMs.

During zone_spanned_pages_in_node, spanned pages of zones
are calculated separately for DRAM and NVDIMM by flags
MEMBLOCK_NONE and MEMBLOCK_NVDIMM.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Signed-off-by: Ocean He <hehy1@lenovo.com>
---
 mm/nobootmem.c  |  5 +++--
 mm/page_alloc.c | 40 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 9b02fda..19b5291 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -143,8 +143,9 @@ static unsigned long __init free_low_memory_core_early(=
void)
 	 *  because in some case like Node0 doesn't have RAM installed
 	 *  low ram will be on Node1
 	 */
-	for_each_free_mem_range(i, NUMA_NO_NODE, MEMBLOCK_NONE, &start, &end,
-				NULL)
+	for_each_free_mem_range(i, NUMA_NO_NODE,
+				MEMBLOCK_NONE | MEMBLOCK_NVDIMM,
+				&start, &end, NULL)
 		count +=3D __free_memory_core(start, end);
=20
 	return count;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d8bd20d..3fd0d95 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4221,6 +4221,11 @@ static inline void finalise_ac(gfp_t gfp_mask,
 	 * also used as the starting point for the zonelist iterator. It
 	 * may get reset for allocations that ignore memory policies.
 	 */
+#ifdef CONFIG_ZONE_NVM
+	/* Bypass ZONE_NVM for Normal alloctions */
+	if (ac->high_zoneidx > ZONE_NVM)
+		ac->high_zoneidx =3D ZONE_NORMAL;
+#endif
 	ac->preferred_zoneref =3D first_zones_zonelist(ac->zonelist,
 					ac->high_zoneidx, ac->nodemask);
 }
@@ -5808,6 +5813,10 @@ static unsigned long __meminit zone_spanned_pages_in=
_node(int nid,
 					unsigned long *zone_end_pfn,
 					unsigned long *ignored)
 {
+#ifdef CONFIG_ZONE_NVM
+	unsigned long start_pfn, end_pfn;
+#endif
+
 	/* When hotadd a new node from cpu_up(), the node should be empty */
 	if (!node_start_pfn && !node_end_pfn)
 		return 0;
@@ -5815,6 +5824,26 @@ static unsigned long __meminit zone_spanned_pages_in=
_node(int nid,
 	/* Get the start and end of the zone */
 	*zone_start_pfn =3D arch_zone_lowest_possible_pfn[zone_type];
 	*zone_end_pfn =3D arch_zone_highest_possible_pfn[zone_type];
+
+#ifdef CONFIG_ZONE_NVM
+	/*
+	 * Use zone_type to adjust zone size again.
+	 */
+	if (zone_type =3D=3D ZONE_NVM) {
+		get_pfn_range_for_nid_with_flags(nid, &start_pfn, &end_pfn,
+							MEMBLOCK_NVDIMM);
+	} else {
+		get_pfn_range_for_nid_with_flags(nid, &start_pfn, &end_pfn,
+							MEMBLOCK_NONE);
+	}
+
+	if (*zone_end_pfn < start_pfn || *zone_start_pfn > end_pfn)
+		return 0;
+	/* Move the zone boundaries inside the possile_pfn if necessary */
+	*zone_end_pfn =3D min(*zone_end_pfn, end_pfn);
+	*zone_start_pfn =3D max(*zone_start_pfn, start_pfn);
+#endif
+
 	adjust_zone_range_for_zone_movable(nid, zone_type,
 				node_start_pfn, node_end_pfn,
 				zone_start_pfn, zone_end_pfn);
@@ -6680,6 +6709,17 @@ void __init free_area_init_nodes(unsigned long *max_=
zone_pfn)
 		start_pfn =3D end_pfn;
 	}
=20
+#ifdef CONFIG_ZONE_NVM
+	/*
+	 * Adjust nvm zone included in normal zone
+	 */
+	get_pfn_range_for_nid_with_flags(MAX_NUMNODES, &start_pfn, &end_pfn,
+							    MEMBLOCK_NVDIMM);
+
+	arch_zone_lowest_possible_pfn[ZONE_NVM] =3D start_pfn;
+	arch_zone_highest_possible_pfn[ZONE_NVM] =3D end_pfn;
+#endif
+
 	/* Find the PFNs that ZONE_MOVABLE begins at in each node */
 	memset(zone_movable_pfn, 0, sizeof(zone_movable_pfn));
 	find_zone_movable_pfns_for_nodes();
--=20
1.8.3.1
