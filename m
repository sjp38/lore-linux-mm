Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D585BC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:11:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83A0421900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:11:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83A0421900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 369A76B000E; Fri, 22 Mar 2019 13:11:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3186D6B0010; Fri, 22 Mar 2019 13:11:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2083D6B0266; Fri, 22 Mar 2019 13:11:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D261B6B000E
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 13:11:11 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e5so2881353pfi.23
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:11:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=hImD7Y00gaX81YIfSMmqjk6E4HgjxDbyb28VwVwb7xc=;
        b=aGrzfsZ3XyR5nxzvMcJEKSXxUsLBT0lSJop0xl6BIVrEhudO67bLSyrpJoe9lh5jlL
         /EaIKBMYz9MvnTJZ9ZAYEmmd6yQwiTtZW4BQRJxtVWs/mp/Gi3Xn59HQZA/WwDgki+8s
         abj3J0lv8Nl7zjb0Q9cxBSUnw3dM3J23QCVFlG+/D4G1NJcbdMoviSJrcL5W/Q7MOJ/6
         TXDGyRT1xtZmfEuWUl6PPdNbkJr59Bnxj7w4PRvaNfqhLwsMWWu06NvDKGoquE5QPyTd
         sHRuDbdAlVdvXtPBnVrun7aPkrnU+FW4atY7qySpJxKSaSry+DOtCg8WCgkuqXILdQgS
         GXDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAURsI9Xs3TMtC6m0PQanYhXFhK5F6mINwiUF4S//CkxlXMISY92
	Vk67iOhu++9OHIvgvcXnn23E6AeGQ61YP7eL4sAGMQQU10tg+sV2ODGBaVjUdORMcUCBMRympQ+
	rhrM5p1b8Y3kSrlGZjMbfEy9CjVQ+cSFXqnEA8XIpQjkX6DtHc+gunO5Uvjxpuy1Otw==
X-Received: by 2002:a17:902:5c5:: with SMTP id f63mr7726880plf.64.1553274671490;
        Fri, 22 Mar 2019 10:11:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBO3KLClO4F6Jp7OHqytRRg822Pn1FLZDL3chP0O9shPVu6160Cxh4zYOolFIz6Z4E05zV
X-Received: by 2002:a17:902:5c5:: with SMTP id f63mr7726813plf.64.1553274670525;
        Fri, 22 Mar 2019 10:11:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553274670; cv=none;
        d=google.com; s=arc-20160816;
        b=nC/KRnZRO3I235CqD//N2ZXDTnlG3PORXElw8jaZasU35BhUEK7P9OXWffJS08eTTt
         OCQxz5mfT/q2WxzcYz2EpOthIMGpxrpXRMKvYEQPLVMns9kAFjSckp+VWP7ovVD+51dv
         lu8YBnEvEg/0u37ZQEB494wHfkxD6+7WA3b+RICwcKk8hTd5z+L7024asK6ppg/bQRoI
         r0peywzrSsqpKqJMu2GPeZVhYmZrfdGpKJZNR70AyhcKgrz7R39WG/BqTGVyKMJVOQZ3
         t1Iy6SDJgIEvxQZVTd+K7wCLp3i+MNc9VSmZ3wk1A1EA8TMHUo4xOoG4W6KiQiBkITh8
         2EdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=hImD7Y00gaX81YIfSMmqjk6E4HgjxDbyb28VwVwb7xc=;
        b=iWoLbSETuc+/zrMtb923gwmJBRSHhxNJT2zlMUojgk03yYRXIop2my4tEFWF09lkFF
         KNUIfKpbIkfSLkem3w9N5shkMRbLlccIxiB88VicTDfGHrckJ7CAJ008rXPObNmzywZl
         SampPhowvaDJ36YYyBwYQF+vzKdI2HkajM7x9wAChkmiA58rGnebRMAe3KVu22UtShxn
         4lq3NyIMyBn7FsdxOoCxHlF/PTlH1Mzmk+ZuRXUJsSYW5+cMpecJjZ66XvAQjtSWBZ+K
         ZPeLitSDW1J4sig2nXz2m6UOHydn3Bi7zjfVz8VGXTCVOObc1dW/G5ZwXlW1/DcPOIIm
         zzxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id r3si6976449pgp.154.2019.03.22.10.11.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 10:11:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Mar 2019 10:11:10 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,256,1549958400"; 
   d="scan'208";a="329775834"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga006.fm.intel.com with ESMTP; 22 Mar 2019 10:11:09 -0700
Subject: [PATCH v5 07/10] mm/sparsemem: Support sub-section hotplug
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Fri, 22 Mar 2019 09:58:30 -0700
Message-ID: <155327391072.225273.15649820215289276904.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
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
 mm/sparse.c |  235 ++++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 158 insertions(+), 77 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 767713c88cf5..d41ad9643f86 100644
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
@@ -743,58 +759,164 @@ static void free_map_bootmem(struct page *memmap)
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
-/*
- * returns the number of sections whose mem_maps were properly
- * set.  If this is <=0, then that means that the passed-in
- * map was not consumed and must be freed.
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
+/**
+ * sparse_add_section() - create a new memmap section, or populate an
+ * existing one
+ * @zone: host zone for the new memory mapping
+ * @start_pfn: first pfn to add (section aligned if zone != ZONE_DEVICE)
+ * @nr_pages: number of new pages to add
+ *
+ * returns the number of sections whose mem_maps were properly set.  If
+ * this is <=0, then that means that the passed-in map was not consumed
+ * and must be freed.
  */
 int __meminit sparse_add_section(int nid, unsigned long start_pfn,
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
 
@@ -829,54 +951,13 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
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

