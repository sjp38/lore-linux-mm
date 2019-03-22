Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9833EC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:10:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55DAF21900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:10:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55DAF21900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A9F36B0008; Fri, 22 Mar 2019 13:10:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 059CA6B000A; Fri, 22 Mar 2019 13:10:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB1E46B000C; Fri, 22 Mar 2019 13:10:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B3A226B0008
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 13:10:50 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 14so2676868pgf.22
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:10:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=BSK6TVzzGaTdUDjLhcyDZLPy3x+xOocQH7fiYXagYSQ=;
        b=jvctoEqilEk1WwcPF6pO/rT2O7jJl0Ce8X/2r6xPK1cWHQL5snz69VCcbF8QIZgmcp
         i19eF7CFV5sdmuL8qpEGeo6jlXyBRq2wRIhiL5H7LQ2L/XmqmxhIP5c81v0zEZ0rOAmC
         SoKyD+b05MtIte/fWCKs7uxB3FBbsEuNaAWpw3gxGpb70oZS2ZQV4SShlb5M6PdMdrsC
         zeO/hymoc2LFZH9VRihCYZ/eh+RcbFOlTajx1JCnYh0ve2++uqJGc2OCDKnEc+Hfe4Lm
         dXn8m7CeuBkHOwOqHfHut1/zy/RF061NAXnTMB2gbpL6aFJFSm4pH0tcK0K55bXbv83W
         Q7Vg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXbRdybeIQ5c4ezwlmTOy0pXFZIY/+no6ty5NVa6x9Tf57MMI/B
	p76FGuXrMtKOibxWtHVMvoJmp3e4oQ9eXaCWrkXcZZmcZi8BRaarkG5hgYvOlJST8ePjafRdb69
	g0OzdS0yxDERt6JBqJV2rCdcN96TMKS+8Bhf/NC84NGSTEmcj/IeEQI6knliellBFmw==
X-Received: by 2002:a62:ea0f:: with SMTP id t15mr10456110pfh.124.1553274650404;
        Fri, 22 Mar 2019 10:10:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyY+TRjGE5qLyPPr/CxOYyu9EHbrLsWlgupgGpbJXTo2KQBUUOH6kmIWfWMJdzswUFjQbKY
X-Received: by 2002:a62:ea0f:: with SMTP id t15mr10456048pfh.124.1553274649608;
        Fri, 22 Mar 2019 10:10:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553274649; cv=none;
        d=google.com; s=arc-20160816;
        b=a2Z7lhatb5h6/mo8aSCPIctf3OjnlLx4735SZ2Usq6peB4PRD3MekodBildH1prBjm
         Ek6eqKtlp6spUUMHIiK9TdqQU0LUbQmEzmMHpzz5LLnz2KXoTBACwYqqJYvtXEz2yix4
         6X0uWP2Yu+BP5cGIJP5kLuSAfzrelJjZdJklaK1/YTCezBk/2IyO/P0iSHySoyxEOm5G
         1tKE2qHFSRd6rJ/VjT0aYFz6ss9UiZ1P0E4laVU/hJ++/ULzyB6KywVFxlOstFiw+rpb
         /elHWZn7xulamsFcdkWhfeQeDxMQmonbFVF77swKCgR3KHJzsCoV8gwvbOgznEt+bYAD
         F18Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=BSK6TVzzGaTdUDjLhcyDZLPy3x+xOocQH7fiYXagYSQ=;
        b=Q9tVMY2813dzN7MQp6IFNHMDzx0wCJfn/Bxxjfs1jLH0YG7oz/LmLpGyk2cbJc11jD
         Nxyn6puu+LH3UsUYxoRgGhy05d4Rw7bpOCmFbdUsZ/biVErTE0i5QogAwbDejddjTC2t
         Ri86zFamI28wv7ZkWUYOTjdTW70BDgNmb+N9vjhwRDZJQDOOHo87Kejs541c95Ktbnh6
         6f5/TAySVa6fnNs3N1HJvAMwKTjcXm/smQFk3SeEAUBMl0pWgez5iw7xKrnqP8d8PUtX
         I+5JCpwpRQk1gwXmdK/55YAPBGyzx9/i1DfUczrxGuzDpRjBF2h0O5JUoceJ0EvqfiRx
         DcpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id t7si6940653pgp.196.2019.03.22.10.10.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 10:10:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Mar 2019 10:10:49 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,256,1549958400"; 
   d="scan'208";a="144365061"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga002.jf.intel.com with ESMTP; 22 Mar 2019 10:10:49 -0700
Subject: [PATCH v5 03/10] mm/sparsemem: Add helpers track active portions of
 a section at boot
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Fri, 22 Mar 2019 09:58:10 -0700
Message-ID: <155327389029.225273.1972826189687261996.stgit@dwillia2-desk3.amr.corp.intel.com>
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

Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
section active bitmask, each bit representing 2MB (SECTION_SIZE (128M) /
map_active bitmask length (64)). If it turns out that 2MB is too large
of an active tracking granularity it is trivial to increase the size of
the map_active bitmap.

The implications of a partially populated section is that pfn_valid()
needs to go beyond a valid_section() check and read the sub-section
active ranges from the bitmask.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h |   29 ++++++++++++++++++++++++++++-
 mm/page_alloc.c        |    4 +++-
 mm/sparse.c            |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 79 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 69b9cb9cb2ed..ae4aa7f63d2e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1122,6 +1122,8 @@ struct mem_section_usage {
 	unsigned long pageblock_flags[0];
 };
 
+void section_active_init(unsigned long pfn, unsigned long nr_pages);
+
 struct page;
 struct page_ext;
 struct mem_section {
@@ -1259,12 +1261,36 @@ static inline struct mem_section *__pfn_to_section(unsigned long pfn)
 
 extern int __highest_present_section_nr;
 
+static inline int section_active_index(phys_addr_t phys)
+{
+	return (phys & ~(PA_SECTION_MASK)) / SECTION_ACTIVE_SIZE;
+}
+
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+static inline int pfn_section_valid(struct mem_section *ms, unsigned long pfn)
+{
+	int idx = section_active_index(PFN_PHYS(pfn));
+
+	return !!(ms->usage->map_active & (1UL << idx));
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
+	return pfn_section_valid(ms, pfn);
 }
 #endif
 
@@ -1295,6 +1321,7 @@ void sparse_init(void);
 #else
 #define sparse_init()	do {} while (0)
 #define sparse_index_init(_sec, _nid)  do {} while (0)
+#define section_active_init(_pfn, _nr_pages) do {} while (0)
 #endif /* CONFIG_SPARSEMEM */
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bf23bc0b8399..508a810fd514 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7221,10 +7221,12 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 
 	/* Print out the early node map */
 	pr_info("Early memory node ranges\n");
-	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
+	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid) {
 		pr_info("  node %3d: [mem %#018Lx-%#018Lx]\n", nid,
 			(u64)start_pfn << PAGE_SHIFT,
 			((u64)end_pfn << PAGE_SHIFT) - 1);
+		section_active_init(start_pfn, end_pfn - start_pfn);
+	}
 
 	/* Initialise every node */
 	mminit_verify_pageflags_layout();
diff --git a/mm/sparse.c b/mm/sparse.c
index cdd2978d0ffe..3cd7ce46e749 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -210,6 +210,54 @@ static inline unsigned long first_present_section_nr(void)
 	return next_present_section_nr(-1);
 }
 
+static unsigned long section_active_mask(unsigned long pfn,
+		unsigned long nr_pages)
+{
+	int idx_start, idx_size;
+	phys_addr_t start, size;
+
+	if (!nr_pages)
+		return 0;
+
+	start = PFN_PHYS(pfn);
+	size = PFN_PHYS(min(nr_pages, PAGES_PER_SECTION
+				- (pfn & ~PAGE_SECTION_MASK)));
+	size = ALIGN(size, SECTION_ACTIVE_SIZE);
+
+	idx_start = section_active_index(start);
+	idx_size = section_active_index(size);
+
+	if (idx_size == 0)
+		return -1;
+	return ((1UL << idx_size) - 1) << idx_start;
+}
+
+void section_active_init(unsigned long pfn, unsigned long nr_pages)
+{
+	int end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
+	int i, start_sec = pfn_to_section_nr(pfn);
+
+	if (!nr_pages)
+		return;
+
+	for (i = start_sec; i <= end_sec; i++) {
+		struct mem_section *ms;
+		unsigned long mask;
+		unsigned long pfns;
+
+		pfns = min(nr_pages, PAGES_PER_SECTION
+				- (pfn & ~PAGE_SECTION_MASK));
+		mask = section_active_mask(pfn, pfns);
+
+		ms = __nr_to_section(i);
+		pr_debug("%s: sec: %d mask: %#018lx\n", __func__, i, mask);
+		ms->usage->map_active = mask;
+
+		pfn += pfns;
+		nr_pages -= pfns;
+	}
+}
+
 /* Record a memory area against a node. */
 void __init memory_present(int nid, unsigned long start, unsigned long end)
 {

