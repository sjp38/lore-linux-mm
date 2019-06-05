Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80647C28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:13:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36F172075B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:13:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36F172075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D89AF6B0277; Wed,  5 Jun 2019 18:13:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D38606B0278; Wed,  5 Jun 2019 18:13:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4EE06B0279; Wed,  5 Jun 2019 18:13:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8843F6B0277
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 18:13:01 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q2so179102plr.19
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 15:13:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=iSwXzQQbTQrIqHqiTk0MZs9qCXr7kdVRZXlzTAF7W04=;
        b=dnl+oF0CHZ45unWqa2qOXFJcO4OcExft3TKMf84KPats3TJ/n9FA6mP330gS22vO7+
         e9XTKkpLvxKgI4WDjYHyAb4lcvknUqJDVSlVilF3EGw+t9XgM1fpC9ccG/pm0W9SCMis
         TJbMl2ccK6q3km6f6mjH8NAvX20mxtyqKhpWPVuNVbrLeXMvFpa5HrxLMUJbXR6wnzmh
         1O8HtezLLLDFW6acpgYaAa47bPrkH++4d53mwz+bHrLhg4NqjTyDypGkODZxB6mFUQv8
         YtZbH5c762HLDo1IU7R6hKOGIBXpW2F1+YZojBf1MHPAlHrw4EFRn1fTrYuEMziyZt/m
         cQPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW2722t1+dMLghRobw+fzPRhp0l1e0LfwcjCtyEcaW4Qr8bv1Tw
	A6Ybu7jZUspSiDTBZT7gU3qhzed+57M3T5p0PzKlrQXo4UyTLZq59gA9J57Z1Mh/BRpBtXYpkFA
	pp/lj554pKUpY9Ft11rv4rGaa+sE8nDOOwUMAMoag8lgcSOTj/Fqz2D4APQOvx/Z0JA==
X-Received: by 2002:a17:902:a986:: with SMTP id bh6mr45103546plb.100.1559772781001;
        Wed, 05 Jun 2019 15:13:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAJELr1MWYX3fJ/K1EHVkweJjKVoZRsKnYebwHJshL4fk0STMxhTKhCTo6kM55ZiUnNIoJ
X-Received: by 2002:a17:902:a986:: with SMTP id bh6mr45103427plb.100.1559772779878;
        Wed, 05 Jun 2019 15:12:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559772779; cv=none;
        d=google.com; s=arc-20160816;
        b=s+k9Jsv082mJaf9jORfpxcXiNKNSoUslHfGFyZL9735BUCd55Qsk4b781BzB19hbLJ
         w3fOX0e506rWmBdjjQ7ZFq4owNYNyhcUSaEJJd45pDWVp+20zDPSfdgqmGT8wsLL5FbO
         3k6KZM0FADYqR4EfLflctVAyGpqTIeZg5kGToQzFw9XWqvJzTX47eVMU4xttOXRjsUqg
         yMt9qtgoY+6+eAWBJyXORiQxpTwJxKiJ0wDksbIRj1ftby54DgrQaOqub/jh8wuInUS+
         ABJBuguN7c22XOwrkCpUHOOrm14uQtRVHbaqiJs2ulwlbrNskaEzPYcJc6R4UuYFvQ7m
         YtyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=iSwXzQQbTQrIqHqiTk0MZs9qCXr7kdVRZXlzTAF7W04=;
        b=GvwzAMrmo61U//s1UgyzsQZP777Zfk0ihr8YmVS0cTSXZIpV9slVro17UmNdSMMeLy
         hoEZJq17MmYpolPCsmAdXwbGV/b3ZZWn936nVdSG5TuO51bp8+WsyiwR8npZHRigs34r
         76DbO503347a46nlN84tqGjRn+uiweDj9KbmwBXGaKXYPDq0OyrruF0EGyUGAbBwCNpg
         r3Za0icf88MXDaTH0ihKaqgsh5SfrT+q+0/TISnwmHyjfILkvLUvdDx1Z2miWHnQF1+j
         1wDeJ+qQnL8WqzvH8NtLYPd99gf5ID/8hsF2RuL/+KeluQPIZ9ljUDiqvmPi4tcaSpKJ
         kVYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t1si127205pgh.406.2019.06.05.15.12.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 15:12:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 15:12:59 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga003.jf.intel.com with ESMTP; 05 Jun 2019 15:12:59 -0700
Subject: [PATCH v9 08/12] mm/sparsemem: Support sub-section hotplug
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, Oscar Salvador <osalvador@suse.de>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, osalvador@suse.de,
 mhocko@suse.com
Date: Wed, 05 Jun 2019 14:58:42 -0700
Message-ID: <155977192280.2443951.13941265207662462739.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
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
 include/linux/memory_hotplug.h |    2 
 mm/memory_hotplug.c            |    7 -
 mm/page_alloc.c                |    2 
 mm/sparse.c                    |  225 +++++++++++++++++++++++++++-------------
 4 files changed, 155 insertions(+), 81 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 3ab0282b4fe5..0b8a5e5ef2da 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -350,7 +350,7 @@ extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 extern bool is_memblock_offlined(struct memory_block *mem);
 extern int sparse_add_section(int nid, unsigned long pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap);
-extern void sparse_remove_one_section(struct mem_section *ms,
+extern void sparse_remove_section(struct mem_section *ms,
 		unsigned long pfn, unsigned long nr_pages,
 		unsigned long map_offset, struct vmem_altmap *altmap);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 399bf78bccc5..8188be7a9edb 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -255,13 +255,10 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
 static int __meminit __add_section(int nid, unsigned long pfn,
 		unsigned long nr_pages,	struct vmem_altmap *altmap)
 {
-	int ret;
-
 	if (pfn_valid(pfn))
 		return -EEXIST;
 
-	ret = sparse_add_section(nid, pfn, nr_pages, altmap);
-	return ret < 0 ? ret : 0;
+	return sparse_add_section(nid, pfn, nr_pages, altmap);
 }
 
 static int check_pfn_span(unsigned long pfn, unsigned long nr_pages,
@@ -541,7 +538,7 @@ static void __remove_section(struct zone *zone, unsigned long pfn,
 		return;
 
 	__remove_zone(zone, pfn, nr_pages);
-	sparse_remove_one_section(ms, pfn, nr_pages, map_offset, altmap);
+	sparse_remove_section(ms, pfn, nr_pages, map_offset, altmap);
 }
 
 /**
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5dff3f49a372..af260cc469cd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5915,7 +5915,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
 		 * pfn out of zone.
 		 *
 		 * Please note that MEMMAP_HOTPLUG path doesn't clear memmap
-		 * because this is done early in sparse_add_one_section
+		 * because this is done early in section_activate()
 		 */
 		if (!(pfn & (pageblock_nr_pages - 1))) {
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
diff --git a/mm/sparse.c b/mm/sparse.c
index f65206deaf49..d83bac5d1324 100644
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
@@ -325,6 +332,15 @@ static void __meminit sparse_init_one_section(struct mem_section *ms,
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
@@ -726,10 +742,131 @@ static void free_map_bootmem(struct page *memmap)
 }
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
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
+		struct vmem_altmap *altmap)
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
+		section_deactivate(pfn, nr_pages, altmap);
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
@@ -743,50 +880,29 @@ int __meminit sparse_add_section(int nid, unsigned long start_pfn,
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
-	if (ret < 0 && ret != -EEXIST)
+	if (ret < 0)
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
-	return ret;
+	return 0;
 }
 
 #ifdef CONFIG_MEMORY_FAILURE
@@ -819,51 +935,12 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
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
-void sparse_remove_one_section(struct mem_section *ms, unsigned long pfn,
+void sparse_remove_section(struct mem_section *ms, unsigned long pfn,
 		unsigned long nr_pages, unsigned long map_offset,
 		struct vmem_altmap *altmap)
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
-	clear_hwpoisoned_pages(memmap + map_offset, nr_pages - map_offset);
-	free_section_usage(memmap, usage, pfn, nr_pages, altmap);
+	clear_hwpoisoned_pages(pfn_to_page(pfn) + map_offset,
+			nr_pages - map_offset);
+	section_deactivate(pfn, nr_pages, altmap);
 }
 #endif /* CONFIG_MEMORY_HOTPLUG */

