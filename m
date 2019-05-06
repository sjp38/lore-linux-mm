Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0B3CC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:54:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5187620830
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:54:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5187620830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 007F06B0266; Mon,  6 May 2019 19:54:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFB686B0269; Mon,  6 May 2019 19:54:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEB126B026A; Mon,  6 May 2019 19:54:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9889B6B0266
	for <linux-mm@kvack.org>; Mon,  6 May 2019 19:54:02 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z7so9029189pgc.1
        for <linux-mm@kvack.org>; Mon, 06 May 2019 16:54:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=9IcdRL5YLg/41s5JMHxLfYLM3xlXQfXisf5ES6NCxjw=;
        b=fzgzbBfAHxFerM92o+eKNvOY9K5DPppZ4IJ7G2v8j/S3ifbHhy44otUt/4L9MgA5HS
         HjBDZE6jI5VOKKV4dIqFIJd/PW3UevrTrkA61Ns73CL3guTJ5pqj7HIYVvRKTBX8QbND
         S1hO0t+CyZ73QwOQ5915H/+TdWuKTTx6t5UqWOzmQ3pbZ8SuuaeILCbguqbyXvZBgSUg
         TDB71RhFUbhmxXkEA+z6STTuE2If+uFtMSv2xXb/vvUvEzGTCdUC5f6pgjy5j7rLQNOe
         jenJDqbxHwpcGGn3gzBQzTnUq+g8rNpFHWKZn/SIggqy6W7WHys36j5KhaGHTlpkuj5+
         keYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVXAeBqb6seYQv13nF6JIknqsMKMEMEsXdQlrijCUgFpc+7Si97
	3r+MlDQjP4CxR/RLJsQZZBVS3xADt6uI4tmJTVJ2V/W4Qo0rxMpnVjZwFxfZwOpmtRQAtNdNDJo
	AUdx8Mz518EcyfWOp3DMoiPj3j0aer9tgLYaSKMDl8W5lRnTfbJzS4jvZ/8XtaGyqPw==
X-Received: by 2002:aa7:80d1:: with SMTP id a17mr36635418pfn.156.1557186842207;
        Mon, 06 May 2019 16:54:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1viLX0Q3dqPOhAL63XSFESzzqOFqRXyksGsVyRedk/dvocwyfs1XYiBroSMeDFPV2M3kP
X-Received: by 2002:aa7:80d1:: with SMTP id a17mr36635341pfn.156.1557186841185;
        Mon, 06 May 2019 16:54:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557186841; cv=none;
        d=google.com; s=arc-20160816;
        b=duLe9QL8WJtfz8GSwGuBWTc8013J+Tj1ZlLf2OgawsgKhV9PfmWTO/sHt4drnTaOup
         s5qvpJE+jmOpaMTjnHAw5kk0bfElLpDPDpHKqUzWUNEdKrMIe8hTCXaKG2bzYe2+dtTI
         k6rF3oDllrtIaL2Auzink0xKyL7LnOIdHHsQICxaDUzt49Tp+RQ8GLIJxEOsPEnH33GE
         EH071DL4ThxMo3dDu8KJFgaua4sLg1ap+wGDxTJ/HVcYS5iAB5HPubdE+9ir9iUbl2Ps
         ayfK51IAacX70SHF5dnyowuJBB4+pwAP1bgJv5vXIn3GZLH0bulIb48xuHw/86hae5zj
         Ag+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=9IcdRL5YLg/41s5JMHxLfYLM3xlXQfXisf5ES6NCxjw=;
        b=LpDb3sb4DfnEmTydyI/1WlrebqHUQ2x563YktPpcVe3IGW6zBhMJ/kp861sWyx9edq
         iLo5a3PCJZFGsnTYR0OpFUnaj5j+IJ4qCm2bApA7RUyjDXFEjqS5UPQPGbQ4Co6/f00V
         gT9AP8ROTJHc+NaSOZEM9DM0CDXARSP+lIqsAAM9XTxqIBP0yhIMuuuzGSGqj0Jte8rI
         ncGeZOp1/+/GgA9viYxU0ZHDcTMQfOPyVJURahRzuB0HtFpAt6H0SZZWtj5UPLD+vRts
         iwXYLfaCZpksJVP2tfdwu8AMlKvpmmCHREE8Cgxdp/N6jhrS5h/A4J6BX4E3X/eQaErK
         /mhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 101si5459284plb.31.2019.05.06.16.54.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 16:54:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 May 2019 16:54:00 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,439,1549958400"; 
   d="scan'208";a="297766722"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga004.jf.intel.com with ESMTP; 06 May 2019 16:54:00 -0700
Subject: [PATCH v8 09/12] mm/sparsemem: Support sub-section hotplug
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, Oscar Salvador <osalvador@suse.de>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, linux-nvdimm@lists.01.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, osalvador@suse.de,
 mhocko@suse.com
Date: Mon, 06 May 2019 16:40:14 -0700
Message-ID: <155718601407.130019.14248061058774128227.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The libnvdimm sub-system has suffered a series of hacks and broken
workarounds for the memory-hotplug implementation's awkward
section-aligned (128MB) granularity. For example the following backtrace
is emitted when attempting arch_add_memory() with physical address
ranges that intersect 'System RAM' (RAM) with 'Persistent Memory' (PMEM)
within a given section:

 WARNING: CPU: 0 PID: 558 at kernel/memremap.c:300 devm_memremap_pages+0x3b5/0x4c0
 devm_memremap_pages attempted on mixed region [mem 0x200000000-0x2fbffffff flags 0x200]
 [..]
 Call Trace:
   dump_stack+0x86/0xc3
   __warn+0xcb/0xf0
   warn_slowpath_fmt+0x5f/0x80
   devm_memremap_pages+0x3b5/0x4c0
   __wrap_devm_memremap_pages+0x58/0x70 [nfit_test_iomap]
   pmem_attach_disk+0x19a/0x440 [nd_pmem]

Recently it was discovered that the problem goes beyond RAM vs PMEM
collisions as some platform produce PMEM vs PMEM collisions within a
given section. The libnvdimm workaround for that case revealed that the
libnvdimm section-alignment-padding implementation has been broken for a
long while. A fix for that long-standing breakage introduces as many
problems as it solves as it would require a backward-incompatible change
to the namespace metadata interpretation. Instead of that dubious route
[1], address the root problem in the memory-hotplug implementation.

[1]: https://lore.kernel.org/r/155000671719.348031.2347363160141119237.stgit@dwillia2-desk3.amr.corp.intel.com
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/sparse.c |  255 ++++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 175 insertions(+), 80 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 8867f8901ee2..34f322d14e62 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -83,8 +83,15 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
 	unsigned long root = SECTION_NR_TO_ROOT(section_nr);
 	struct mem_section *section;
 
+	/*
+	 * An existing section is possible in the sub-section hotplug
+	 * case. First hot-add instantiates, follow-on hot-add reuses
+	 * the existing section.
+	 *
+	 * The mem_hotplug_lock resolves the apparent race below.
+	 */
 	if (mem_section[root])
-		return -EEXIST;
+		return 0;
 
 	section = sparse_index_alloc(nid);
 	if (!section)
@@ -210,6 +217,15 @@ static inline unsigned long first_present_section_nr(void)
 	return next_present_section_nr(-1);
 }
 
+void subsection_mask_set(unsigned long *map, unsigned long pfn,
+		unsigned long nr_pages)
+{
+	int idx = subsection_map_index(pfn);
+	int end = subsection_map_index(pfn + nr_pages - 1);
+
+	bitmap_set(map, idx, end - idx + 1);
+}
+
 void subsection_map_init(unsigned long pfn, unsigned long nr_pages)
 {
 	int end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
@@ -219,20 +235,17 @@ void subsection_map_init(unsigned long pfn, unsigned long nr_pages)
 		return;
 
 	for (i = start_sec; i <= end_sec; i++) {
-		int idx, end;
-		unsigned long pfns;
 		struct mem_section *ms;
+		unsigned long pfns;
 
-		idx = subsection_map_index(pfn);
 		pfns = min(nr_pages, PAGES_PER_SECTION
 				- (pfn & ~PAGE_SECTION_MASK));
-		end = subsection_map_index(pfn + pfns - 1);
-
 		ms = __nr_to_section(i);
-		bitmap_set(ms->usage->subsection_map, idx, end - idx + 1);
+		subsection_mask_set(ms->usage->subsection_map, pfn, pfns);
 
 		pr_debug("%s: sec: %d pfns: %ld set(%d, %d)\n", __func__, i,
-				pfns, idx, end - idx + 1);
+				pfns, subsection_map_index(pfn),
+				subsection_map_index(pfn + pfns - 1));
 
 		pfn += pfns;
 		nr_pages -= pfns;
@@ -319,6 +332,15 @@ static void __meminit sparse_init_one_section(struct mem_section *ms,
 		unsigned long pnum, struct page *mem_map,
 		struct mem_section_usage *usage)
 {
+	/*
+	 * Given that SPARSEMEM_VMEMMAP=y supports sub-section hotplug,
+	 * ->section_mem_map can not be guaranteed to point to a full
+	 *  section's worth of memory.  The field is only valid / used
+	 *  in the SPARSEMEM_VMEMMAP=n case.
+	 */
+	if (IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP))
+		mem_map = NULL;
+
 	ms->section_mem_map &= ~SECTION_MAP_MASK;
 	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum) |
 							SECTION_HAS_MEM_MAP;
@@ -724,10 +746,142 @@ static void free_map_bootmem(struct page *memmap)
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
+#ifndef CONFIG_MEMORY_HOTREMOVE
+static void free_map_bootmem(struct page *memmap)
+{
+}
+#endif
+
+static bool is_early_section(struct mem_section *ms)
+{
+	struct page *usage_page;
+
+	usage_page = virt_to_page(ms->usage);
+	if (PageSlab(usage_page) || PageCompound(usage_page))
+		return false;
+	else
+		return true;
+}
+
+static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
+		int nid, struct vmem_altmap *altmap)
+{
+	DECLARE_BITMAP(map, SUBSECTIONS_PER_SECTION) = { 0 };
+	DECLARE_BITMAP(tmp, SUBSECTIONS_PER_SECTION) = { 0 };
+	struct mem_section *ms = __pfn_to_section(pfn);
+	bool early_section = is_early_section(ms);
+	struct page *memmap = NULL;
+	unsigned long *subsection_map = ms->usage
+		? &ms->usage->subsection_map[0] : NULL;
+
+	subsection_mask_set(map, pfn, nr_pages);
+	if (subsection_map)
+		bitmap_and(tmp, map, subsection_map, SUBSECTIONS_PER_SECTION);
+
+	if (WARN(!subsection_map || !bitmap_equal(tmp, map, SUBSECTIONS_PER_SECTION),
+				"section already deactivated (%#lx + %ld)\n",
+				pfn, nr_pages))
+		return;
+
+	if (WARN(!IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP)
+				&& nr_pages < PAGES_PER_SECTION,
+				"partial memory section removal not supported\n"))
+		return;
+
+	/*
+	 * There are 3 cases to handle across two configurations
+	 * (SPARSEMEM_VMEMMAP={y,n}):
+	 *
+	 * 1/ deactivation of a partial hot-added section (only possible
+	 * in the SPARSEMEM_VMEMMAP=y case).
+	 *    a/ section was present at memory init
+	 *    b/ section was hot-added post memory init
+	 * 2/ deactivation of a complete hot-added section
+	 * 3/ deactivation of a complete section from memory init
+	 *
+	 * For 1/, when subsection_map does not empty we will not be
+	 * freeing the usage map, but still need to free the vmemmap
+	 * range.
+	 *
+	 * For 2/ and 3/ the SPARSEMEM_VMEMMAP={y,n} cases are unified
+	 */
+	bitmap_xor(subsection_map, map, subsection_map, SUBSECTIONS_PER_SECTION);
+	if (bitmap_empty(subsection_map, SUBSECTIONS_PER_SECTION)) {
+		unsigned long section_nr = pfn_to_section_nr(pfn);
+
+		if (!early_section) {
+			kfree(ms->usage);
+			ms->usage = NULL;
+		}
+		memmap = sparse_decode_mem_map(ms->section_mem_map, section_nr);
+		ms->section_mem_map = sparse_encode_mem_map(NULL, section_nr);
+	}
+
+	if (early_section && memmap)
+		free_map_bootmem(memmap);
+	else
+		depopulate_section_memmap(pfn, nr_pages, altmap);
+}
+
+static struct page * __meminit section_activate(int nid, unsigned long pfn,
+		unsigned long nr_pages, struct vmem_altmap *altmap)
+{
+	DECLARE_BITMAP(map, SUBSECTIONS_PER_SECTION) = { 0 };
+	struct mem_section *ms = __pfn_to_section(pfn);
+	struct mem_section_usage *usage = NULL;
+	unsigned long *subsection_map;
+	struct page *memmap;
+	int rc = 0;
+
+	subsection_mask_set(map, pfn, nr_pages);
+
+	if (!ms->usage) {
+		usage = kzalloc(mem_section_usage_size(), GFP_KERNEL);
+		if (!usage)
+			return ERR_PTR(-ENOMEM);
+		ms->usage = usage;
+	}
+	subsection_map = &ms->usage->subsection_map[0];
+
+	if (bitmap_empty(map, SUBSECTIONS_PER_SECTION))
+		rc = -EINVAL;
+	else if (bitmap_intersects(map, subsection_map, SUBSECTIONS_PER_SECTION))
+		rc = -EEXIST;
+	else
+		bitmap_or(subsection_map, map, subsection_map,
+				SUBSECTIONS_PER_SECTION);
+
+	if (rc) {
+		if (usage)
+			ms->usage = NULL;
+		kfree(usage);
+		return ERR_PTR(rc);
+	}
+
+	/*
+	 * The early init code does not consider partially populated
+	 * initial sections, it simply assumes that memory will never be
+	 * referenced.  If we hot-add memory into such a section then we
+	 * do not need to populate the memmap and can simply reuse what
+	 * is already there.
+	 */
+	if (nr_pages < PAGES_PER_SECTION && is_early_section(ms))
+		return pfn_to_page(pfn);
+
+	memmap = populate_section_memmap(pfn, nr_pages, nid, altmap);
+	if (!memmap) {
+		section_deactivate(pfn, nr_pages, nid, altmap);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	return memmap;
+}
+
 /**
- * sparse_add_one_section - add a memory section
+ * sparse_add_section - add a memory section, or populate an existing one
  * @nid: The node to add section on
  * @start_pfn: start pfn of the memory range
+ * @nr_pages: number of pfns to add in the section
  * @altmap: device page map
  *
  * This is only intended for hotplug.
@@ -741,49 +895,31 @@ int __meminit sparse_add_section(int nid, unsigned long start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap)
 {
 	unsigned long section_nr = pfn_to_section_nr(start_pfn);
-	struct mem_section_usage *usage;
 	struct mem_section *ms;
 	struct page *memmap;
 	int ret;
 
-	/*
-	 * no locking for this, because it does its own
-	 * plus, it does a kmalloc
-	 */
 	ret = sparse_index_init(section_nr, nid);
 	if (ret < 0 && ret != -EEXIST)
 		return ret;
-	ret = 0;
-	memmap = populate_section_memmap(start_pfn, PAGES_PER_SECTION, nid,
-			altmap);
-	if (!memmap)
-		return -ENOMEM;
-	usage = kzalloc(mem_section_usage_size(), GFP_KERNEL);
-	if (!usage) {
-		depopulate_section_memmap(start_pfn, PAGES_PER_SECTION, altmap);
-		return -ENOMEM;
-	}
 
-	ms = __pfn_to_section(start_pfn);
-	if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
-		ret = -EEXIST;
-		goto out;
-	}
+	memmap = section_activate(nid, start_pfn, nr_pages, altmap);
+	if (IS_ERR(memmap))
+		return PTR_ERR(memmap);
+	ret = 0;
 
 	/*
 	 * Poison uninitialized struct pages in order to catch invalid flags
 	 * combinations.
 	 */
-	page_init_poison(memmap, sizeof(struct page) * PAGES_PER_SECTION);
+	page_init_poison(pfn_to_page(start_pfn), sizeof(struct page) * nr_pages);
 
+	ms = __pfn_to_section(start_pfn);
 	section_mark_present(ms);
-	sparse_init_one_section(ms, section_nr, memmap, usage);
+	sparse_init_one_section(ms, section_nr, memmap, ms->usage);
 
-out:
-	if (ret < 0) {
-		kfree(usage);
-		depopulate_section_memmap(start_pfn, PAGES_PER_SECTION, altmap);
-	}
+	if (ret < 0)
+		section_deactivate(start_pfn, nr_pages, nid, altmap);
 	return ret;
 }
 
@@ -818,54 +954,13 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 }
 #endif
 
-static void free_section_usage(struct page *memmap,
-		struct mem_section_usage *usage, unsigned long pfn,
-		unsigned long nr_pages, struct vmem_altmap *altmap)
-{
-	struct page *usage_page;
-
-	if (!usage)
-		return;
-
-	usage_page = virt_to_page(usage);
-	/*
-	 * Check to see if allocation came from hot-plug-add
-	 */
-	if (PageSlab(usage_page) || PageCompound(usage_page)) {
-		kfree(usage);
-		if (memmap)
-			depopulate_section_memmap(pfn, nr_pages, altmap);
-		return;
-	}
-
-	/*
-	 * The usemap came from bootmem. This is packed with other usemaps
-	 * on the section which has pgdat at boot time. Just keep it as is now.
-	 */
-
-	if (memmap)
-		free_map_bootmem(memmap);
-}
-
 void sparse_remove_section(struct zone *zone, struct mem_section *ms,
 		unsigned long pfn, unsigned long nr_pages,
 		unsigned long map_offset, struct vmem_altmap *altmap)
 {
-	struct page *memmap = NULL;
-	struct mem_section_usage *usage = NULL;
-
-	if (ms->section_mem_map) {
-		usage = ms->usage;
-		memmap = sparse_decode_mem_map(ms->section_mem_map,
-						__section_nr(ms));
-		ms->section_mem_map = 0;
-		ms->usage = NULL;
-	}
-
-	clear_hwpoisoned_pages(memmap + map_offset,
-			PAGES_PER_SECTION - map_offset);
-	free_section_usage(memmap, usage, section_nr_to_pfn(__section_nr(ms)),
-			PAGES_PER_SECTION, altmap);
+	clear_hwpoisoned_pages(pfn_to_page(pfn) + map_offset,
+			nr_pages - map_offset);
+	section_deactivate(pfn, nr_pages, zone_to_nid(zone), altmap);
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_MEMORY_HOTPLUG */

