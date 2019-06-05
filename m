Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76FA1C28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:12:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33CE42075B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:12:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33CE42075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B67A76B0270; Wed,  5 Jun 2019 18:12:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B17416B0271; Wed,  5 Jun 2019 18:12:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A069C6B0272; Wed,  5 Jun 2019 18:12:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 682FB6B0270
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 18:12:18 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d19so218033pls.1
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 15:12:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=n8hi6N/kizta8FqBmW4FQV8wLCzVOtOh6NRdhaV269k=;
        b=teTT5OcFablUVGTDoaXtzFThJkfosr6MF6Y2p0Q96adaRxsaRAZwgnoUfOzc/gBlwI
         rZUspMTlRW2wInYqsAonmjan012TZNg9CVrMqKDUPDPK77d+rt/E36TV05tstX5Btq9H
         ox1v8tcIS+UyoyBh0bm77fxpy0PNZXTcL2P5swNES2Fv/ta8D0Jah5+kj0RaRbm2Ywkr
         aLCJS9jbEgtys/qgj132Uc7eq+bwFxmaVgFAC1fRjd0FHOPI7I6epxWAWu+VJF1vcdGQ
         e1gZA/lH/8zGEe5EU/E+acP5LYOdssgE0G1oH6jLI2yGs8hTg/TtDX/ydqvKDgzAijCH
         Dt4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU+lxOVb3VHHERa+7Ulrq/7u/aGFGpi6Ejo87hZHABZZVMSdbWf
	JGIrUsGpCCArqghAH3+Jsy3S1Uodj0dkjKZjvvcoo09sLz7mRVFVdTiWuBAE+sJUk9wxg42/h2+
	ygLM0BqFtp0E7/f28jBxFpKcyPkNMyPkAeU2o4eRz4smpxcSJrRIPZIZvBYuV8qdbsQ==
X-Received: by 2002:a62:5253:: with SMTP id g80mr1902016pfb.179.1559772737922;
        Wed, 05 Jun 2019 15:12:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyMBfr7G6xQf6V3dByW8sOzVulRwriOAasyx+SZ97GtxSwbEA/g+rHIUu7qVflGERdCmgKF
X-Received: by 2002:a62:5253:: with SMTP id g80mr1901884pfb.179.1559772736769;
        Wed, 05 Jun 2019 15:12:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559772736; cv=none;
        d=google.com; s=arc-20160816;
        b=ubtbuvScNDz1SyNsXEKSbhoImth6reVRn5ce/FFtsSzhrR9nh44Lzii9uSpXIIzZeO
         5FdeBfkyYMmmPhI5vbtl43n+3N9hN9Fai0/ytS5lXoi+NPW5OXTbX3DWAxpBrklVhxgC
         7pAfx7kgq+WWNFjKWg+UaaUnpz8CEPRz7nRlwlZfFnTlyDoZUrIIomq0RhTEfydn4Wma
         1fuCAdq2tmxucyWPPhlKeNkrKSB665Y5zf9MrzJCpEYxskp41jXjU+k5waNJl6sKjJJr
         nmKTML8XyCwAG74NorNbTVGxQsRdXOwWkiUQXkMqvu7HT91AyOwPptzP9RbNEnvI7cwi
         FEnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=n8hi6N/kizta8FqBmW4FQV8wLCzVOtOh6NRdhaV269k=;
        b=x/B2ieLn+EnbECYvqnCT/iXG1JkdiFqftmOwmxeJGq38YDJXiM29z6XaiXbG0ZAXa7
         Ml031SmWKI4lgEnITdW9tsbQk84dnVrfyOHrjoSTEsM79qaPVX47+p09IU0Erf5zlS4f
         DJS3CyjXEetFOJBK1t7XUJFCkWzjtoC8L+ERs/FnvpLBPTP8VFgVdeEfL7AqdbFKR9oq
         g7BsarQh4anCouF7QBmo7gttq/inSHeURrg64mFKBEKOMA7uvroJezlpTRctCPUvBOVY
         btSgBcHsFetEPbxnsF44gHvqmB4YFJQaHVBpwIN/17lUL8tVKldG114zzIfmEiOiTiuT
         qnPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id o10si30054993pfo.196.2019.06.05.15.12.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 15:12:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 15:12:16 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga004.fm.intel.com with ESMTP; 05 Jun 2019 15:12:15 -0700
Subject: [PATCH v9 02/12] mm/sparsemem: Add helpers track active portions of
 a section at boot
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, Oscar Salvador <osalvador@suse.de>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, Jane Chu <jane.chu@oracle.com>,
 linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org,
 osalvador@suse.de, mhocko@suse.com
Date: Wed, 05 Jun 2019 14:57:59 -0700
Message-ID: <155977187919.2443951.8925592545929008845.stgit@dwillia2-desk3.amr.corp.intel.com>
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

Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
sub-section active bitmask, each bit representing a PMD_SIZE span of the
architecture's memory hotplug section size.

The implications of a partially populated section is that pfn_valid()
needs to go beyond a valid_section() check and read the sub-section
active ranges from the bitmask. The expectation is that the bitmask
(subsection_map) fits in the same cacheline as the valid_section() data,
so the incremental performance overhead to pfn_valid() should be
negligible.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Tested-by: Jane Chu <jane.chu@oracle.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h |   29 ++++++++++++++++++++++++++++-
 mm/page_alloc.c        |    4 +++-
 mm/sparse.c            |   35 +++++++++++++++++++++++++++++++++++
 3 files changed, 66 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ac163f2f274f..6dd52d544857 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1199,6 +1199,8 @@ struct mem_section_usage {
 	unsigned long pageblock_flags[0];
 };
 
+void subsection_map_init(unsigned long pfn, unsigned long nr_pages);
+
 struct page;
 struct page_ext;
 struct mem_section {
@@ -1336,12 +1338,36 @@ static inline struct mem_section *__pfn_to_section(unsigned long pfn)
 
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
+	return pfn_section_valid(ms, pfn);
 }
 #endif
 
@@ -1373,6 +1399,7 @@ void sparse_init(void);
 #define sparse_init()	do {} while (0)
 #define sparse_index_init(_sec, _nid)  do {} while (0)
 #define pfn_present pfn_valid
+#define subsection_map_init(_pfn, _nr_pages) do {} while (0)
 #endif /* CONFIG_SPARSEMEM */
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c6d8224d792e..bd773efe5b82 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7292,10 +7292,12 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 
 	/* Print out the early node map */
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
index 71da15cc7432..0baa2e55cfdd 100644
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
+void subsection_map_init(unsigned long pfn, unsigned long nr_pages)
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

