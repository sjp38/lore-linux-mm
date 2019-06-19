Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3151DC31E5D
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:06:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C88421530
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:06:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C88421530
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92D8D6B0007; Wed, 19 Jun 2019 02:06:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EA378E0001; Wed, 19 Jun 2019 02:06:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77F5F8E0001; Wed, 19 Jun 2019 02:06:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 40CBD6B0007
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:06:08 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x18so10990874pfj.4
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:06:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=efV/bOh1lMhwsgpUzGakm9wILLGEQUb8r2cn7Vf8up0=;
        b=hZ6Vt6A4s5GhJVJ5h1hvY/jHAFCQHQzQjImWMi9R/RU4RyI2qI7wFRn7HVUeqHwclc
         nuIOu1fpRIgs7DqeA2NzFmtdwl5XjYvpmUyqrhgL0YxJwis8EkFOlqs3B4ZzeE+q2INA
         YY0vbnn+29jAlEygXpFUiRLkHF6fb+0zmAq9V/vxAi5/a0ldADSjNm0HSFxnDkkGICoE
         bHKq9wlET5LHjbY6YLa44i60SQwmrFz2y5JnjTqTJl00ltRq+0SLqVFwl+XM5m/tgQfB
         k5EKf4FHTpx7XZm3MC6AUI/u0d9YNeQDICDigsW3OzQdGOt95ze1LBx3SBOgi8mzNuwN
         LPCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWC94/PfQMM7SIhIqI+8qSPz4ADQUbeUXL8N28Sa2qWU2sSKP7O
	uvr3Tp6Sf/3KAaaaMSuisGFxQPe+JXliZ1tv4hS/FLgXyMpKOjr+qqV5ty/HwNEFBHe64PpeNmu
	phZQ97ugDrY7TnhNuYHsypakjyo3FKaQjtcmQ/soGBAXC0ENwzEe0Z4Sj29OKHgk2jg==
X-Received: by 2002:a63:4d50:: with SMTP id n16mr6288630pgl.146.1560924367732;
        Tue, 18 Jun 2019 23:06:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGOxfHhva9serZtdxOGtB8ib0WPG+S1r9ma0c2uEygCCpG6Dra90534GMDnK0NzLISAFkv
X-Received: by 2002:a63:4d50:: with SMTP id n16mr6288571pgl.146.1560924366933;
        Tue, 18 Jun 2019 23:06:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560924366; cv=none;
        d=google.com; s=arc-20160816;
        b=qeEF7JZGEmgGNaZ2h3E0EU64y9daua2q82M2HY/5nhA/HWGNZ88lgp9W3+w5piWm2Y
         HCxGfhPVY+4AM4hqgyOwS/D1pGO1Cs3mHppinYe3mLcwNVWyI+YeN/sLNBZc3xkPmf15
         nLDqK9HEPmr+QSnY9b/YjGmCarbRgbWaxA3JCDMOnU9uYrvD4P/Rt27N9b+THMYeoQvd
         qMOtW/elO6v/j9AaBtX4qJ2nYtd4WUrSt5tstZAtGjJhaIyUggY/VldU7Ymsa9VeRvZj
         XVagRGb0zDVUMUcsLaht0tLxHF+SPSb9A1x5hVwZIYaId0wsU/eH4sZsvK+9sF2p3heG
         ZY8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=efV/bOh1lMhwsgpUzGakm9wILLGEQUb8r2cn7Vf8up0=;
        b=t5IcmDyQ+1CHODu0yp+Y6O8vj37UpTmdk4cc7PBootSntgBGI95ZH+Ja7ZPLE6HKSN
         Qco5KJbzV32POKfQTsBQej1W2rUJScPAHRfCmMnz0ysT5NCG9nsvH4A5d4bXKEi6kw3B
         +1SSSr4V0+CD+k40AiIqXs9LUqRnt4wsipjK1u8r4R/OsdEl1ffcaBkptgYc5pTLgLA/
         xMH+G0C9YrW+10Vas3ycyfFzunBjz/hNrhKTChbNtmgG1P0sLj4Z0m8asWiLxeMdWWyW
         SZ0MmAiUELkPVxGins90jZa/YEIX9PRHADIhfm5WgxSX9QxGwwNAXozNTu1iSkhOXrT9
         RrkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id l1si14855891plb.302.2019.06.18.23.06.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:06:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:06:06 -0700
X-IronPort-AV: E=Sophos;i="5.63,392,1557212400"; 
   d="scan'208";a="160271014"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga008-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:06:05 -0700
Subject: [PATCH v10 03/13] mm/sparsemem: Add helpers track active portions
 of a section at boot
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, Oscar Salvador <osalvador@suse.de>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>,
 Jane Chu <jane.chu@oracle.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org,
 linux-kernel@vger.kernel.org
Date: Tue, 18 Jun 2019 22:51:48 -0700
Message-ID: <156092350874.979959.18185938451405518285.stgit@dwillia2-desk3.amr.corp.intel.com>
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

Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
sub-section active bitmask, each bit representing a PMD_SIZE span of the
architecture's memory hotplug section size.

The implications of a partially populated section is that pfn_valid()
needs to go beyond a valid_section() check and either determine that the
section is an "early section", or read the sub-section active ranges
from the bitmask. The expectation is that the bitmask (subsection_map)
fits in the same cacheline as the valid_section() / early_section()
data, so the incremental performance overhead to pfn_valid() should be
negligible.

The rationale for using early_section() to short-ciruit the
subsection_map check is that there are legacy code paths that use
pfn_valid() at section granularity before validating the pfn against
pgdat data. So, the early_section() check allows those traditional
assumptions to persist while also permitting subsection_map to tell the
truth for purposes of populating the unused portions of early sections
with PMEM and other ZONE_DEVICE mappings.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Reported-by: Qian Cai <cai@lca.pw>
Tested-by: Jane Chu <jane.chu@oracle.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h |   33 ++++++++++++++++++++++++++++++++-
 mm/page_alloc.c        |   10 ++++++++--
 mm/sparse.c            |   35 +++++++++++++++++++++++++++++++++++
 3 files changed, 75 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d081c9a1d25d..c4e8843e283c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1179,6 +1179,8 @@ struct mem_section_usage {
 	unsigned long pageblock_flags[0];
 };
 
+void subsection_map_init(unsigned long pfn, unsigned long nr_pages);
+
 struct page;
 struct page_ext;
 struct mem_section {
@@ -1322,12 +1324,40 @@ static inline struct mem_section *__pfn_to_section(unsigned long pfn)
 
 extern int __highest_present_section_nr;
 
+static inline int subsection_map_index(unsigned long pfn)
+{
+	return (pfn & ~(PAGE_SECTION_MASK)) / PAGES_PER_SUBSECTION;
+}
+
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+static inline int pfn_section_valid(struct mem_section *ms, unsigned long pfn)
+{
+	int idx = subsection_map_index(pfn);
+
+	return test_bit(idx, ms->usage->subsection_map);
+}
+#else
+static inline int pfn_section_valid(struct mem_section *ms, unsigned long pfn)
+{
+	return 1;
+}
+#endif
+
 #ifndef CONFIG_HAVE_ARCH_PFN_VALID
 static inline int pfn_valid(unsigned long pfn)
 {
+	struct mem_section *ms;
+
 	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
 		return 0;
-	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
+	ms = __nr_to_section(pfn_to_section_nr(pfn));
+	if (!valid_section(ms))
+		return 0;
+	/*
+	 * Traditionally early sections always returned pfn_valid() for
+	 * the entire section-sized span.
+	 */
+	return early_section(ms) || pfn_section_valid(ms, pfn);
 }
 #endif
 
@@ -1359,6 +1389,7 @@ void sparse_init(void);
 #define sparse_init()	do {} while (0)
 #define sparse_index_init(_sec, _nid)  do {} while (0)
 #define pfn_present pfn_valid
+#define subsection_map_init(_pfn, _nr_pages) do {} while (0)
 #endif /* CONFIG_SPARSEMEM */
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8cc091e87200..8e7215fb6976 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7306,12 +7306,18 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 			       (u64)zone_movable_pfn[i] << PAGE_SHIFT);
 	}
 
-	/* Print out the early node map */
+	/*
+	 * Print out the early node map, and initialize the
+	 * subsection-map relative to active online memory ranges to
+	 * enable future "sub-section" extensions of the memory map.
+	 */
 	pr_info("Early memory node ranges\n");
-	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
+	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid) {
 		pr_info("  node %3d: [mem %#018Lx-%#018Lx]\n", nid,
 			(u64)start_pfn << PAGE_SHIFT,
 			((u64)end_pfn << PAGE_SHIFT) - 1);
+		subsection_map_init(start_pfn, end_pfn - start_pfn);
+	}
 
 	/* Initialise every node */
 	mminit_verify_pageflags_layout();
diff --git a/mm/sparse.c b/mm/sparse.c
index 2031a0694f35..e9fec3c2f7ec 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -210,6 +210,41 @@ static inline unsigned long first_present_section_nr(void)
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
+void __init subsection_map_init(unsigned long pfn, unsigned long nr_pages)
+{
+	int end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
+	int i, start_sec = pfn_to_section_nr(pfn);
+
+	if (!nr_pages)
+		return;
+
+	for (i = start_sec; i <= end_sec; i++) {
+		struct mem_section *ms;
+		unsigned long pfns;
+
+		pfns = min(nr_pages, PAGES_PER_SECTION
+				- (pfn & ~PAGE_SECTION_MASK));
+		ms = __nr_to_section(i);
+		subsection_mask_set(ms->usage->subsection_map, pfn, pfns);
+
+		pr_debug("%s: sec: %d pfns: %ld set(%d, %d)\n", __func__, i,
+				pfns, subsection_map_index(pfn),
+				subsection_map_index(pfn + pfns - 1));
+
+		pfn += pfns;
+		nr_pages -= pfns;
+	}
+}
+
 /* Record a memory area against a node. */
 void __init memory_present(int nid, unsigned long start, unsigned long end)
 {

