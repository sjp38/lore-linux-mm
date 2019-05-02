Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C46ACC04AA9
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:09:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 817772089E
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:09:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 817772089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E9836B0008; Thu,  2 May 2019 02:09:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29B066B000A; Thu,  2 May 2019 02:09:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 189A36B000C; Thu,  2 May 2019 02:09:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D5F8C6B0008
	for <linux-mm@kvack.org>; Thu,  2 May 2019 02:09:25 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id v9so713449pgg.8
        for <linux-mm@kvack.org>; Wed, 01 May 2019 23:09:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=h1qZRCxKdav4Z/xZvb0za7BlD7cFxA5vHoQHlWtfT7o=;
        b=j/KEsAkSopx3sA/0PbJdwC8Ux7WK4/+PH4RWFxniMw0+svtU7ezNCqMqhlE8zfsGJp
         eCehqzQxdSuieUD4iy+QV/G335SjjrDuyVBlCmP1ayGGvuHeFT+FLjaCiEskhu8d04VV
         FSTfa8fm7JD5TzW7KqPGhxEfsMXfXRjTyRyTpwmZCmTzA9NPNlTisrk7BVJ2CCu/rQoZ
         EQUWqccWwmOKztJoT1ElNQiwEQ4MMldn+f4TzR7E4S7rXcIXcWtxYj8yW4fhbof4AZwl
         H38v9+tLhXjs29wjFAilkIgnxsZ0GM27FfXikN29Q6qswsnZy7B16V4cuW5wWhSMhn3H
         XrXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWPghJDM8EFcmUkj1nl64gwa+vqY/jqdXo95nlGV+FRzMHZR55j
	/v85ITSFaJNJteWdtUnTT278vNRU0fGNfrsxGvflMPpnfjPINizmR3eYuBg7/MjYMmdEWeG+P7I
	lCGwg85/M6wHPbHk6gJhb6xINtBihkSvb4axQAnSJeNBBWbYCZ0umejaLLJUU3ZMYhQ==
X-Received: by 2002:a62:d244:: with SMTP id c65mr2222170pfg.173.1556777365524;
        Wed, 01 May 2019 23:09:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy74uYzsxIo9sZ3buQujgYy4Tt9UoEti3k86mMVGF+3c2JjF2qW2XdTu9Oe6td7ws0znfyC
X-Received: by 2002:a62:d244:: with SMTP id c65mr2222088pfg.173.1556777364582;
        Wed, 01 May 2019 23:09:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556777364; cv=none;
        d=google.com; s=arc-20160816;
        b=YShVLXy/T2SoEqZQ33nkZbi+HFuy54wT1vw11AZfIvlwHRJt1BklJUpdhcdSY5JaWR
         kz3Rgl/3MEfFuk3JGp+G5hudeng3i0Xwm3/8g4zJlDZFFdvk/bgPwwGAF13ppdPJhS9L
         j33EftUPNoVXkBom8X6EFBjuADLhnqWk5sNbdrD3i0GZDVlHsttudmPAJKZ1WSfMk5dX
         4TYyY5rLtLR8qhb38mVfXAJeH1C1v2V+H+3JM1zN9BOcm24k9QaKt9RfreC4fillXeCZ
         1Zn0sOGefNoFmmci3vj5AXsDy2fcO8Qz9uxqOh8S5ITdQFglS0F+IkW8uCYYW5Xwe1Ex
         W5sQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=h1qZRCxKdav4Z/xZvb0za7BlD7cFxA5vHoQHlWtfT7o=;
        b=wvuA7lA40k52/grC66COuGMqqd95s+IEQaSFWZLiQuLsInTBZetdZRcrkuwzxQYoAr
         8jEbCmI2DjekCAwbOSA9Ho+OLOAg63hu86t/YWCrkHp00wxZGaYzGtM3icTlC+SBSo/T
         svyQCWRwC98ebfAjrRDIY2xtq1wUeGJlbSy7XLmEWZcn/Utl0W2TrRAEoybFo9c/7EGL
         9gI9jVJGrHxtNfBnJofj/MhoIQ3vTTeMKKALebrlnP5LhLRn6I32tRteYvzNTip9ULSU
         qyYet9xpD7OeIVdAW/fz6cZ6zcYCisQluZGRcvnxWqy2/hJlhiG3UZjbAYCtaUx91qc3
         91Ag==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id t14si20369382pgg.32.2019.05.01.23.09.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 23:09:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 May 2019 23:09:24 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,420,1549958400"; 
   d="scan'208";a="296291608"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga004.jf.intel.com with ESMTP; 01 May 2019 23:09:24 -0700
Subject: [PATCH v7 03/12] mm/sparsemem: Add helpers track active portions of
 a section at boot
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, Jane Chu <jane.chu@oracle.com>,
 linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 osalvador@suse.de, mhocko@suse.com
Date: Wed, 01 May 2019 22:55:37 -0700
Message-ID: <155677653785.2336373.11131100812252340469.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
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
Tested-by: Jane Chu <jane.chu@oracle.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h |   29 ++++++++++++++++++++++++++++-
 mm/page_alloc.c        |    4 +++-
 mm/sparse.c            |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 79 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6726fc175b51..cffde898e345 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1175,6 +1175,8 @@ struct mem_section_usage {
 	unsigned long pageblock_flags[0];
 };
 
+void section_active_init(unsigned long pfn, unsigned long nr_pages);
+
 struct page;
 struct page_ext;
 struct mem_section {
@@ -1312,12 +1314,36 @@ static inline struct mem_section *__pfn_to_section(unsigned long pfn)
 
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
 
@@ -1349,6 +1375,7 @@ void sparse_init(void);
 #define sparse_init()	do {} while (0)
 #define sparse_index_init(_sec, _nid)  do {} while (0)
 #define pfn_present pfn_valid
+#define section_active_init(_pfn, _nr_pages) do {} while (0)
 #endif /* CONFIG_SPARSEMEM */
 
 /*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 61c2b54a5b61..a68735c79609 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7291,10 +7291,12 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 
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
index f87de7ad32c8..8d4f28e2c25e 100644
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
+		ms->usage->map_active |= mask;
+		pr_debug("%s: sec: %d mask: %#018lx\n", __func__, i, ms->usage->map_active);
+
+		pfn += pfns;
+		nr_pages -= pfns;
+	}
+}
+
 /* Record a memory area against a node. */
 void __init memory_present(int nid, unsigned long start, unsigned long end)
 {

