Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADD6FC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:53:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5793F20663
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:53:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5793F20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F29B36B0266; Wed, 17 Apr 2019 14:53:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F01056B0269; Wed, 17 Apr 2019 14:53:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF3686B026A; Wed, 17 Apr 2019 14:53:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A379B6B0266
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:53:29 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h69so16769209pfd.21
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:53:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=t5+nULTwXja/GMeFymaL9IwyDQFdnrWg57qA6/xBAT0=;
        b=tA2x5+iZ9r6WVL27EQAkoAuV7ft3oa6EjBOKWuOUUatKr9iVQBfpF5Ndtsln4TNl5Z
         MX1QxjnfdjNMN6qXSMpPRMcYWLk+odAGghIZFMQpeBRMtbLn9ZcTF35AHojgrs9LHEb9
         O3C40vf3JkwksZQg+5Co540zqdosgxErVJe8W5TeZzdBq7+x4BH1qzZMPa/Ea2vSRVRN
         TF80cpipeSl+AS4i0fOd3lWDLGC6TVO4FEd/PUNUEPWWg6d95n4qyaixkQmdZbf81DJs
         g2LcPCJCTXpLXaErEkmT5TeszUwx7pKpRWWHZGPygRTRwn7u8yJ7+ocFyva76vKvWvWE
         iNHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU5NDZ0ApT7hc1/nmKdPfRU+TMAtGZBQ179pRdeMCImouvvmebp
	KL4oMtoLU5RSY+6EmLwYZsMAtOqY3t0hepfSSb09ur9zKz27DF/MbSYKVeBmWipKI6MgVOD8aA5
	8xcASuefjIXWN8uwVg15LBwk7gPaBjvMU0XenAdpFWPTqlVDFPK9xYgLZ6ObUTNZ0lQ==
X-Received: by 2002:a63:5466:: with SMTP id e38mr81721073pgm.340.1555527209275;
        Wed, 17 Apr 2019 11:53:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyVj5xK87WkG/1S7bkWkCyc6DqTXwPO1i2hPBXijmmY9XHjVanmySR3BvcVDUUnFWjNdc2
X-Received: by 2002:a63:5466:: with SMTP id e38mr81721009pgm.340.1555527208415;
        Wed, 17 Apr 2019 11:53:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555527208; cv=none;
        d=google.com; s=arc-20160816;
        b=vCYaxMDsZEf4qGXyhrIC1+bM1UK+ZPiiZIoc8OFM5t0a9SyhyaOVDm9Upv2GdP6Ymn
         t/y7oAoiGlSvwdEwKvcMDIE/3UMNEmSuKaqDv8HSe7obzW60oM2whZucLLFBapHWecs+
         CHXeuAnICMW34Cj3CvgK6ByQueY2Il6sHUy5fi7pKRVbYbDbbTDVL1ju/VhuUiFnZ5bk
         8XbVOJY2JuxUO61gLtGa+WRqsIrMgJAbRKzhvM6gopw3st85ZcVLoLCKxWCrY6soakcU
         v4Od8a1NqvAXLjSOfKKJ2UNt17SIPQkhejhM6g3cW++KqfSbOuw5/4kfAWjavo7E9LXu
         Toog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=t5+nULTwXja/GMeFymaL9IwyDQFdnrWg57qA6/xBAT0=;
        b=z9qItVKNRJnTpsUXkYB3suUxN3xtCwKZl0pRViJbqEAJ+b+gBIKGR7F/SHyqxKbrHC
         SUbGlB9k38Hwd8S6HOZpSrxG3HDgI8Sx5uf6C3Ov/880PWzQvKg5XVaoapBTWe5VOUvt
         boQy3hJpD+PVyKARc9uFJkbVG12UAbOEOMfSCENxsGNo5YehZAEREGK6iky6mdlHkDqq
         j0x4IFIuGw1l0pw6WMrvqxizxYbxeJSX6Mb2igr84S6FO0XMGU6/pxU2fSc9OPV2KZJz
         p/e24BVM5CdxMHtAReqsgtW6Ci5rsm4tgqJKoToogm2iza/HGSpzDU0V6/N3cLdSRMMs
         19qA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f20si41529064pgv.584.2019.04.17.11.53.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 11:53:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Apr 2019 11:53:28 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,362,1549958400"; 
   d="scan'208";a="132232393"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga007.jf.intel.com with ESMTP; 17 Apr 2019 11:53:27 -0700
Subject: [PATCH v6 09/12] mm/sparsemem: Support sub-section hotplug
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, mhocko@suse.com,
 david@redhat.com
Date: Wed, 17 Apr 2019 11:39:42 -0700
Message-ID: <155552638228.2015392.2866282581991830795.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
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
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/sparse.c |  224 ++++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 150 insertions(+), 74 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index bd45bff78ca1..3411321998b1 100644
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
@@ -338,6 +345,15 @@ static void __meminit sparse_init_one_section(struct mem_section *ms,
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
@@ -743,10 +759,130 @@ static void free_map_bootmem(struct page *memmap)
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
+	unsigned long mask = section_active_mask(pfn, nr_pages);
+	struct mem_section *ms = __pfn_to_section(pfn);
+	bool early_section = is_early_section(ms);
+	struct page *memmap = NULL;
+
+	if (WARN(!ms->usage || (ms->usage->map_active & mask) != mask,
+			"section already deactivated: active: %#lx mask: %#lx\n",
+			ms->usage ? ms->usage->map_active : 0, mask))
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
+	 * For 1/, when map_active does not go to zero we will not be
+	 * freeing the usage map, but still need to free the vmemmap
+	 * range.
+	 *
+	 * For 2/ and 3/ the SPARSEMEM_VMEMMAP={y,n} cases are unified
+	 */
+	ms->usage->map_active ^= mask;
+	if (ms->usage->map_active == 0) {
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
+	unsigned long mask = section_active_mask(pfn, nr_pages);
+	struct mem_section *ms = __pfn_to_section(pfn);
+	struct mem_section_usage *usage = NULL;
+	struct page *memmap;
+	int rc = 0;
+
+	if (!ms->usage) {
+		usage = kzalloc(mem_section_usage_size(), GFP_KERNEL);
+		if (!usage)
+			return ERR_PTR(-ENOMEM);
+		ms->usage = usage;
+	}
+
+	if (!mask)
+		rc = -EINVAL;
+	else if (mask & ms->usage->map_active)
+		rc = -EEXIST;
+	else
+		ms->usage->map_active |= mask;
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
@@ -760,49 +896,30 @@ int __meminit sparse_add_section(int nid, unsigned long start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap)
 {
 	unsigned long section_nr = pfn_to_section_nr(start_pfn);
-	struct mem_section_usage *usage;
-	struct mem_section *ms;
+	struct mem_section *ms = __pfn_to_section(start_pfn);
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
 
@@ -837,54 +954,13 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
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

