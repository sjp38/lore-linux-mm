Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 803B7C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:06:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 410C621479
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:05:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 410C621479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B515D6B0005; Wed, 19 Jun 2019 02:05:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADB528E0002; Wed, 19 Jun 2019 02:05:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 955148E0001; Wed, 19 Jun 2019 02:05:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB096B0005
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:05:57 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 91so9223995pla.7
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:05:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=Fv9DizISIc0NkVm1MjpeDQZoymFuV0tchADdBluzOhk=;
        b=XnaXF6iw9lETkfyNYTokugPWoxaSk3jHSKuyKtd+3AT/zTzA2du2kAxnOf9al7JH/s
         g2Xi7YD4jS3qmSqVcATfo8e30xQjFgTTctnHPEYHCINeWRGvT9X/wn+c268Upvjmg1UX
         003QTyfgD/zxZ/ZfLkMPnB6jPeuv1+8d5z1rRIPhcWC43uIqsVzM7MaqKBm/HvUOHKOc
         neUAY3JWruSy4e3b1uOL6U/s+Uox4j0OV4OUPTNMnH9LfHhG6cclyQY8hH8A+9/YRyy2
         +FPa5NOnYOhWtKDDiwP+zL5soUV/oCV6pdnhh1X5I0zgwLf3Nh6l1Xq3fYM8EhotLwC4
         7qjA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVmsxWVyGtub9IXy8eIC/m6Qod2JLtyUJy0gg5f0pssRC9nr2Ga
	JTEziePwwSd5Dg/lOdPnAT8wkc2P9LcfTnsYjivRGOLmD5J0FhvKYW9rvhCr7JVDyfry9F/WgmW
	P/gFbxeNz1Fs9vEFIxk8pdPBr150yEsh6d5CrEVHTAScSyLIIXIVY6C0IP8pHBgx0aw==
X-Received: by 2002:a17:902:848c:: with SMTP id c12mr115811508plo.17.1560924357015;
        Tue, 18 Jun 2019 23:05:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEacIQ7IaUuYN79Gj3Dep/IoP8Nkmj7K31oF0HRel2cMv2QfD0KtQeWyzcG1OnQAYPGm9v
X-Received: by 2002:a17:902:848c:: with SMTP id c12mr115811439plo.17.1560924356134;
        Tue, 18 Jun 2019 23:05:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560924356; cv=none;
        d=google.com; s=arc-20160816;
        b=jnZ+TvaT3mCruyg2zZcJ8ViVunRHzn8PfqBnIh8xH/eV6fyIjFVspaRWYRldMgzg+x
         NeVm9tVJI1GN1UEgPS+LN6xE9ujnQFxvlgPX2ibRuwd5E1+Uy/G447WfLbJVZRDpGIsP
         Vtn+lqCOEn2qOBCwLafx+E687lg/Bin0fk22IRC9VBUXHotXdgQzn/xoRj1mpKjan97O
         hQg8NXLJ+3NapPMX717JoKk7DyEOgqN/pcudeh/eRQjKdjn3R9cBxhT8nx00vJKcVfd9
         IfrVbUoMFi05xXvcOi+iihkULlNfNviyzUVMUaG/sEUSmRNEfytTHnW0kCstTssERvKI
         lWZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=Fv9DizISIc0NkVm1MjpeDQZoymFuV0tchADdBluzOhk=;
        b=dYRE7/vwqIZ9d6KUcFRRH+m4dO4IcRPsqHckJI2c1UuAMtq+5h2e4B4BzQ2pp8zJW/
         VY1KEd4raQvNVT6qv+p8t9MtaHhQbrWozcBu9kM9KPjrvOxi1Bb4OMFrKagYBj3TEHEU
         QgnnAT5HPNz+akzn6t4v41EqBxOIwySjVYUPlckIt/FMjhBrS8uwb3MVpjiE1p7X6lmd
         HyJ6iw9FVE++6IV5a5NhTtYwiNNdLJakViUlxStm3mhL8+0K94DkFkoZamWflXDGLTCq
         Rhw6oQsbG8tNnby64M10i52F7rk6CoOUqDd0sauODaM/sFkvYVLJpX86SPzk2nILR52n
         /zBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i10si15316577pfd.226.2019.06.18.23.05.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:05:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:05:55 -0700
X-IronPort-AV: E=Sophos;i="5.63,392,1557212400"; 
   d="scan'208";a="170464316"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga002-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:05:55 -0700
Subject: [PATCH v10 01/13] mm/sparsemem: Introduce struct mem_section_usage
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, Oscar Salvador <osalvador@suse.de>,
 Wei Yang <richardw.yang@linux.intel.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Tue, 18 Jun 2019 22:51:38 -0700
Message-ID: <156092349845.979959.73333291612799019.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Towards enabling memory hotplug to track partial population of a
section, introduce 'struct mem_section_usage'.

A pointer to a 'struct mem_section_usage' instance replaces the existing
pointer to a 'pageblock_flags' bitmap. Effectively it adds one more
'unsigned long' beyond the 'pageblock_flags' (usemap) allocation to
house a new 'subsection_map' bitmap.  The new bitmap enables the memory
hot{plug,remove} implementation to act on incremental sub-divisions of a
section.

SUBSECTION_SHIFT is defined as global constant instead of
per-architecture value like SECTION_SIZE_BITS in order to allow
cross-arch compatibility of subsection users. Specifically a common
subsection size allows for the possibility that persistent memory
namespace configurations be made compatible across architectures.

The primary motivation for this functionality is to support platforms
that mix "System RAM" and "Persistent Memory" within a single section,
or multiple PMEM ranges with different mapping lifetimes within a single
section. The section restriction for hotplug has caused an ongoing saga
of hacks and bugs for devm_memremap_pages() users.

Beyond the fixups to teach existing paths how to retrieve the 'usemap'
from a section, and updates to usemap allocation path, there are no
expected behavior changes.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h |   28 +++++++++++++++--
 mm/memory_hotplug.c    |   18 ++++++-----
 mm/page_alloc.c        |    2 +
 mm/sparse.c            |   81 ++++++++++++++++++++++++------------------------
 4 files changed, 76 insertions(+), 53 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 427b79c39b3c..179680c94262 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1161,6 +1161,24 @@ static inline unsigned long section_nr_to_pfn(unsigned long sec)
 #define SECTION_ALIGN_UP(pfn)	(((pfn) + PAGES_PER_SECTION - 1) & PAGE_SECTION_MASK)
 #define SECTION_ALIGN_DOWN(pfn)	((pfn) & PAGE_SECTION_MASK)
 
+#define SUBSECTION_SHIFT 21
+
+#define PFN_SUBSECTION_SHIFT (SUBSECTION_SHIFT - PAGE_SHIFT)
+#define PAGES_PER_SUBSECTION (1UL << PFN_SUBSECTION_SHIFT)
+#define PAGE_SUBSECTION_MASK (~(PAGES_PER_SUBSECTION-1))
+
+#if SUBSECTION_SHIFT > SECTION_SIZE_BITS
+#error Subsection size exceeds section size
+#else
+#define SUBSECTIONS_PER_SECTION (1UL << (SECTION_SIZE_BITS - SUBSECTION_SHIFT))
+#endif
+
+struct mem_section_usage {
+	DECLARE_BITMAP(subsection_map, SUBSECTIONS_PER_SECTION);
+	/* See declaration of similar field in struct zone */
+	unsigned long pageblock_flags[0];
+};
+
 struct page;
 struct page_ext;
 struct mem_section {
@@ -1178,8 +1196,7 @@ struct mem_section {
 	 */
 	unsigned long section_mem_map;
 
-	/* See declaration of similar field in struct zone */
-	unsigned long *pageblock_flags;
+	struct mem_section_usage *usage;
 #ifdef CONFIG_PAGE_EXTENSION
 	/*
 	 * If SPARSEMEM, pgdat doesn't have page_ext pointer. We use
@@ -1210,6 +1227,11 @@ extern struct mem_section **mem_section;
 extern struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT];
 #endif
 
+static inline unsigned long *section_to_usemap(struct mem_section *ms)
+{
+	return ms->usage->pageblock_flags;
+}
+
 static inline struct mem_section *__nr_to_section(unsigned long nr)
 {
 #ifdef CONFIG_SPARSEMEM_EXTREME
@@ -1221,7 +1243,7 @@ static inline struct mem_section *__nr_to_section(unsigned long nr)
 	return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
 }
 extern int __section_nr(struct mem_section* ms);
-extern unsigned long usemap_size(void);
+extern size_t mem_section_usage_size(void);
 
 /*
  * We use the lower bits of the mem_map pointer to store
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a88c5f334e5a..7b963c2d3a0d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -166,9 +166,10 @@ void put_page_bootmem(struct page *page)
 #ifndef CONFIG_SPARSEMEM_VMEMMAP
 static void register_page_bootmem_info_section(unsigned long start_pfn)
 {
-	unsigned long *usemap, mapsize, section_nr, i;
+	unsigned long mapsize, section_nr, i;
 	struct mem_section *ms;
 	struct page *page, *memmap;
+	struct mem_section_usage *usage;
 
 	section_nr = pfn_to_section_nr(start_pfn);
 	ms = __nr_to_section(section_nr);
@@ -188,10 +189,10 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
 	for (i = 0; i < mapsize; i++, page++)
 		get_page_bootmem(section_nr, page, SECTION_INFO);
 
-	usemap = ms->pageblock_flags;
-	page = virt_to_page(usemap);
+	usage = ms->usage;
+	page = virt_to_page(usage);
 
-	mapsize = PAGE_ALIGN(usemap_size()) >> PAGE_SHIFT;
+	mapsize = PAGE_ALIGN(mem_section_usage_size()) >> PAGE_SHIFT;
 
 	for (i = 0; i < mapsize; i++, page++)
 		get_page_bootmem(section_nr, page, MIX_SECTION_INFO);
@@ -200,9 +201,10 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
 #else /* CONFIG_SPARSEMEM_VMEMMAP */
 static void register_page_bootmem_info_section(unsigned long start_pfn)
 {
-	unsigned long *usemap, mapsize, section_nr, i;
+	unsigned long mapsize, section_nr, i;
 	struct mem_section *ms;
 	struct page *page, *memmap;
+	struct mem_section_usage *usage;
 
 	section_nr = pfn_to_section_nr(start_pfn);
 	ms = __nr_to_section(section_nr);
@@ -211,10 +213,10 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
 
 	register_page_bootmem_memmap(section_nr, memmap, PAGES_PER_SECTION);
 
-	usemap = ms->pageblock_flags;
-	page = virt_to_page(usemap);
+	usage = ms->usage;
+	page = virt_to_page(usage);
 
-	mapsize = PAGE_ALIGN(usemap_size()) >> PAGE_SHIFT;
+	mapsize = PAGE_ALIGN(mem_section_usage_size()) >> PAGE_SHIFT;
 
 	for (i = 0; i < mapsize; i++, page++)
 		get_page_bootmem(section_nr, page, MIX_SECTION_INFO);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f4651a09948c..8cc091e87200 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -403,7 +403,7 @@ static inline unsigned long *get_pageblock_bitmap(struct page *page,
 							unsigned long pfn)
 {
 #ifdef CONFIG_SPARSEMEM
-	return __pfn_to_section(pfn)->pageblock_flags;
+	return section_to_usemap(__pfn_to_section(pfn));
 #else
 	return page_zone(page)->pageblock_flags;
 #endif /* CONFIG_SPARSEMEM */
diff --git a/mm/sparse.c b/mm/sparse.c
index 1552c855d62a..71da15cc7432 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -288,33 +288,31 @@ struct page *sparse_decode_mem_map(unsigned long coded_mem_map, unsigned long pn
 
 static void __meminit sparse_init_one_section(struct mem_section *ms,
 		unsigned long pnum, struct page *mem_map,
-		unsigned long *pageblock_bitmap)
+		struct mem_section_usage *usage)
 {
 	ms->section_mem_map &= ~SECTION_MAP_MASK;
 	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum) |
 							SECTION_HAS_MEM_MAP;
- 	ms->pageblock_flags = pageblock_bitmap;
+	ms->usage = usage;
 }
 
-unsigned long usemap_size(void)
+static unsigned long usemap_size(void)
 {
 	return BITS_TO_LONGS(SECTION_BLOCKFLAGS_BITS) * sizeof(unsigned long);
 }
 
-#ifdef CONFIG_MEMORY_HOTPLUG
-static unsigned long *__kmalloc_section_usemap(void)
+size_t mem_section_usage_size(void)
 {
-	return kmalloc(usemap_size(), GFP_KERNEL);
+	return sizeof(struct mem_section_usage) + usemap_size();
 }
-#endif /* CONFIG_MEMORY_HOTPLUG */
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-static unsigned long * __init
+static struct mem_section_usage * __init
 sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 					 unsigned long size)
 {
+	struct mem_section_usage *usage;
 	unsigned long goal, limit;
-	unsigned long *p;
 	int nid;
 	/*
 	 * A page may contain usemaps for other sections preventing the
@@ -330,15 +328,16 @@ sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 	limit = goal + (1UL << PA_SECTION_SHIFT);
 	nid = early_pfn_to_nid(goal >> PAGE_SHIFT);
 again:
-	p = memblock_alloc_try_nid(size, SMP_CACHE_BYTES, goal, limit, nid);
-	if (!p && limit) {
+	usage = memblock_alloc_try_nid(size, SMP_CACHE_BYTES, goal, limit, nid);
+	if (!usage && limit) {
 		limit = 0;
 		goto again;
 	}
-	return p;
+	return usage;
 }
 
-static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
+static void __init check_usemap_section_nr(int nid,
+		struct mem_section_usage *usage)
 {
 	unsigned long usemap_snr, pgdat_snr;
 	static unsigned long old_usemap_snr;
@@ -352,7 +351,7 @@ static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
 		old_pgdat_snr = NR_MEM_SECTIONS;
 	}
 
-	usemap_snr = pfn_to_section_nr(__pa(usemap) >> PAGE_SHIFT);
+	usemap_snr = pfn_to_section_nr(__pa(usage) >> PAGE_SHIFT);
 	pgdat_snr = pfn_to_section_nr(__pa(pgdat) >> PAGE_SHIFT);
 	if (usemap_snr == pgdat_snr)
 		return;
@@ -380,14 +379,15 @@ static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
 		usemap_snr, pgdat_snr, nid);
 }
 #else
-static unsigned long * __init
+static struct mem_section_usage * __init
 sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 					 unsigned long size)
 {
 	return memblock_alloc_node(size, SMP_CACHE_BYTES, pgdat->node_id);
 }
 
-static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
+static void __init check_usemap_section_nr(int nid,
+		struct mem_section_usage *usage)
 {
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
@@ -474,14 +474,13 @@ static void __init sparse_init_nid(int nid, unsigned long pnum_begin,
 				   unsigned long pnum_end,
 				   unsigned long map_count)
 {
-	unsigned long pnum, usemap_longs, *usemap;
+	struct mem_section_usage *usage;
+	unsigned long pnum;
 	struct page *map;
 
-	usemap_longs = BITS_TO_LONGS(SECTION_BLOCKFLAGS_BITS);
-	usemap = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nid),
-							  usemap_size() *
-							  map_count);
-	if (!usemap) {
+	usage = sparse_early_usemaps_alloc_pgdat_section(NODE_DATA(nid),
+			mem_section_usage_size() * map_count);
+	if (!usage) {
 		pr_err("%s: node[%d] usemap allocation failed", __func__, nid);
 		goto failed;
 	}
@@ -497,9 +496,9 @@ static void __init sparse_init_nid(int nid, unsigned long pnum_begin,
 			pnum_begin = pnum;
 			goto failed;
 		}
-		check_usemap_section_nr(nid, usemap);
-		sparse_init_one_section(__nr_to_section(pnum), pnum, map, usemap);
-		usemap += usemap_longs;
+		check_usemap_section_nr(nid, usage);
+		sparse_init_one_section(__nr_to_section(pnum), pnum, map, usage);
+		usage = (void *) usage + mem_section_usage_size();
 	}
 	sparse_buffer_fini();
 	return;
@@ -697,9 +696,9 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 				     struct vmem_altmap *altmap)
 {
 	unsigned long section_nr = pfn_to_section_nr(start_pfn);
+	struct mem_section_usage *usage;
 	struct mem_section *ms;
 	struct page *memmap;
-	unsigned long *usemap;
 	int ret;
 
 	/*
@@ -713,8 +712,8 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
 	if (!memmap)
 		return -ENOMEM;
-	usemap = __kmalloc_section_usemap();
-	if (!usemap) {
+	usage = kzalloc(mem_section_usage_size(), GFP_KERNEL);
+	if (!usage) {
 		__kfree_section_memmap(memmap, altmap);
 		return -ENOMEM;
 	}
@@ -732,11 +731,11 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	page_init_poison(memmap, sizeof(struct page) * PAGES_PER_SECTION);
 
 	section_mark_present(ms);
-	sparse_init_one_section(ms, section_nr, memmap, usemap);
+	sparse_init_one_section(ms, section_nr, memmap, usage);
 
 out:
 	if (ret < 0) {
-		kfree(usemap);
+		kfree(usage);
 		__kfree_section_memmap(memmap, altmap);
 	}
 	return ret;
@@ -772,20 +771,20 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 }
 #endif
 
-static void free_section_usemap(struct page *memmap, unsigned long *usemap,
-		struct vmem_altmap *altmap)
+static void free_section_usage(struct page *memmap,
+		struct mem_section_usage *usage, struct vmem_altmap *altmap)
 {
-	struct page *usemap_page;
+	struct page *usage_page;
 
-	if (!usemap)
+	if (!usage)
 		return;
 
-	usemap_page = virt_to_page(usemap);
+	usage_page = virt_to_page(usage);
 	/*
 	 * Check to see if allocation came from hot-plug-add
 	 */
-	if (PageSlab(usemap_page) || PageCompound(usemap_page)) {
-		kfree(usemap);
+	if (PageSlab(usage_page) || PageCompound(usage_page)) {
+		kfree(usage);
 		if (memmap)
 			__kfree_section_memmap(memmap, altmap);
 		return;
@@ -804,18 +803,18 @@ void sparse_remove_one_section(struct mem_section *ms, unsigned long map_offset,
 			       struct vmem_altmap *altmap)
 {
 	struct page *memmap = NULL;
-	unsigned long *usemap = NULL;
+	struct mem_section_usage *usage = NULL;
 
 	if (ms->section_mem_map) {
-		usemap = ms->pageblock_flags;
+		usage = ms->usage;
 		memmap = sparse_decode_mem_map(ms->section_mem_map,
 						__section_nr(ms));
 		ms->section_mem_map = 0;
-		ms->pageblock_flags = NULL;
+		ms->usage = NULL;
 	}
 
 	clear_hwpoisoned_pages(memmap + map_offset,
 			PAGES_PER_SECTION - map_offset);
-	free_section_usemap(memmap, usemap, altmap);
+	free_section_usage(memmap, usage, altmap);
 }
 #endif /* CONFIG_MEMORY_HOTPLUG */

