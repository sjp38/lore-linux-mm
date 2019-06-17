Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3DDFC31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 22:22:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5DE520833
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 22:22:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Sn59+fku"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5DE520833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43B3B8E0002; Mon, 17 Jun 2019 18:22:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EABC8E0001; Mon, 17 Jun 2019 18:22:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 301078E0002; Mon, 17 Jun 2019 18:22:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D759E8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 18:21:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i9so18255924edr.13
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 15:21:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mqatRPhG4/yrICubl/YtsP1o46r2J2qqnG2uC01iPb4=;
        b=uKRSAiHIWoxAfzbhD8hSJnKx6CEoycl8QBXjVETTQ0LrYwQPer7Ht7jV4S6F3M1Xqq
         8thZOamvdBHaksPMoMunslyWspEp1U3Naf4ONAjjq7DJvMicah5FLySqvYxjuYKP0XjH
         21ILPPTgN5YZw15oyA39X8yFqkEzjvtU5LKaDOFJT+VvWicamZJ9JKwEN9M/mWBlNo3P
         1lx2mn8PP52mb2G3vN17pOaT3AGn0ekO6nofQf45mlQK78+RvaocM+H/8uPtysiwgxTG
         yLt8IqU+5S6i+AOUjQVeqv2Gk5ly6z9R4OFrhiCESOtZkUUy4YFPex0/5JBo/FDSAz9E
         GUeA==
X-Gm-Message-State: APjAAAWX/873eBTjlzF293n6shFQv7H1EQ23nVDYk8O+SdtGh3F8+2Ed
	QpxSOGD5w8E+ZQbpoOsmUtz4e8KEBZIiVV8rDGfB5i8qe65KxJO2zNv48l8VeG6Fqjj7TKYOtaX
	dOe2q+rQ/RxUTz3gsCigUG5VaMfRiD1sxihakWsVGU556HYav18uO12yBLrJy043kOw==
X-Received: by 2002:aa7:d30d:: with SMTP id p13mr39233066edq.292.1560810119327;
        Mon, 17 Jun 2019 15:21:59 -0700 (PDT)
X-Received: by 2002:aa7:d30d:: with SMTP id p13mr39233017edq.292.1560810118578;
        Mon, 17 Jun 2019 15:21:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560810118; cv=none;
        d=google.com; s=arc-20160816;
        b=OCwC1pNDFrL35Sylj2U2UgA6Ed8fsnoz5e2tS7COjpso2Wt1Kb7sfkT7KArL1WKuWY
         0oz3yLnzP5M0NW7wt27j8qAczLl/Rbtp2cCK4S1RfbLKg2gtQtuHbjMFofoYQDtkHUKa
         uf7UIgtV5JE0TTFeqDXHTUnyByogXtDlQhPL1yohnnoADkDPlvKj2WassMkQHRLbvq7u
         6Pe2bssfL3i2xeuX+KOcIxuAESUdtUnefdqZMWFwMBlyO15DlQBsRMGi0t1DhIsY/PCF
         AHXplN0dTeJRz22C74hdhIMZoOGAvsnIzhaxTQw6b1g+IOvXs4Avogm8kOzQARpBirtz
         f5Ag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=mqatRPhG4/yrICubl/YtsP1o46r2J2qqnG2uC01iPb4=;
        b=zKaSknsNrwjFNsowpMh9a0PLcG2aH28hkqq4xBMTr22hyHZXtvK5vVY/G25OvEY/xi
         uD4aUomzZWOf6K0KknQ3Xf1FmR52n4dtldc+/p0249vn4j8LVL2K6Vg1J1U5nNAh/m0W
         KzGBu69t76v65JpkanoKTQn7MGLsjAsni0SjM/ABYbxnAqecSVjYCFcAAKyRbrIR7N23
         cKiugtHySpeaTmBK9elrv79xNUspi2UOES/DXDa1pE4arQjZpjD6Wif/A+H7j9J6xT/f
         ZgPV+wajB63gfPVQV50qFq6U35ooVhh4bReSRpJ2CfYW24jHjk/JcVL6Q2tiAu7mRFW8
         zM4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Sn59+fku;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c38sor10195103eda.0.2019.06.17.15.21.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 15:21:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Sn59+fku;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=mqatRPhG4/yrICubl/YtsP1o46r2J2qqnG2uC01iPb4=;
        b=Sn59+fkuicsgo3YsVoW2qnw1bCXHgBCm2Otdf4Wce7TS4+FrikSNaMBZfYQNyrU729
         UIMmhjtdabVHowgnlZZW6wyZPaZpNTOvJnjFkMwPMWs0WpyGklGYHwe5Lv4F4lKwkO10
         HdjfYqURaByB1W1qfIy9U2J/5HoBKrePLbtsrhVFDxJ8cb46cSkWFEjDnOG+3w2md9TZ
         TNk8ByFIGCx6a3vMl+dRsBN08rY66zqmgyVrAT/iCyo3F0RD9seGbB8vhYUjKc9UbhPw
         XoRl22CkI3tf4rRvfDhmm80D5wjUGcKLq56Bo/oH1BZHmSrUFsqxgBWviu5hFG2iU1LT
         lEgg==
X-Google-Smtp-Source: APXvYqxwqzx8eCrKbOf4X/zgCe8y6XlGgBmMbdJ0mUO9A9IZ3/LTjmxZolZoJnnaXFo8vDCJdwZNiw==
X-Received: by 2002:a50:8bfd:: with SMTP id n58mr87510972edn.272.1560810118130;
        Mon, 17 Jun 2019 15:21:58 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id f3sm2407908ejo.90.2019.06.17.15.21.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Jun 2019 15:21:57 -0700 (PDT)
Date: Mon, 17 Jun 2019 22:21:56 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Logan Gunthorpe <logang@deltatee.com>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Jane Chu <jane.chu@oracle.com>, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 02/12] mm/sparsemem: Add helpers track active portions
 of a section at boot
Message-ID: <20190617222156.v6eaujbdrmkz35wr@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155977187919.2443951.8925592545929008845.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155977187919.2443951.8925592545929008845.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 02:57:59PM -0700, Dan Williams wrote:
>Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
>sub-section active bitmask, each bit representing a PMD_SIZE span of the
>architecture's memory hotplug section size.
>
>The implications of a partially populated section is that pfn_valid()
>needs to go beyond a valid_section() check and read the sub-section
>active ranges from the bitmask. The expectation is that the bitmask
>(subsection_map) fits in the same cacheline as the valid_section() data,
>so the incremental performance overhead to pfn_valid() should be
>negligible.
>
>Cc: Michal Hocko <mhocko@suse.com>
>Cc: Vlastimil Babka <vbabka@suse.cz>
>Cc: Logan Gunthorpe <logang@deltatee.com>
>Cc: Oscar Salvador <osalvador@suse.de>
>Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>Tested-by: Jane Chu <jane.chu@oracle.com>
>Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>---
> include/linux/mmzone.h |   29 ++++++++++++++++++++++++++++-
> mm/page_alloc.c        |    4 +++-
> mm/sparse.c            |   35 +++++++++++++++++++++++++++++++++++
> 3 files changed, 66 insertions(+), 2 deletions(-)
>
>diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>index ac163f2f274f..6dd52d544857 100644
>--- a/include/linux/mmzone.h
>+++ b/include/linux/mmzone.h
>@@ -1199,6 +1199,8 @@ struct mem_section_usage {
> 	unsigned long pageblock_flags[0];
> };
> 
>+void subsection_map_init(unsigned long pfn, unsigned long nr_pages);
>+
> struct page;
> struct page_ext;
> struct mem_section {
>@@ -1336,12 +1338,36 @@ static inline struct mem_section *__pfn_to_section(unsigned long pfn)
> 
> extern int __highest_present_section_nr;
> 
>+static inline int subsection_map_index(unsigned long pfn)
>+{
>+	return (pfn & ~(PAGE_SECTION_MASK)) / PAGES_PER_SUBSECTION;
>+}
>+
>+#ifdef CONFIG_SPARSEMEM_VMEMMAP
>+static inline int pfn_section_valid(struct mem_section *ms, unsigned long pfn)
>+{
>+	int idx = subsection_map_index(pfn);
>+
>+	return test_bit(idx, ms->usage->subsection_map);
>+}
>+#else
>+static inline int pfn_section_valid(struct mem_section *ms, unsigned long pfn)
>+{
>+	return 1;
>+}
>+#endif
>+
> #ifndef CONFIG_HAVE_ARCH_PFN_VALID
> static inline int pfn_valid(unsigned long pfn)
> {
>+	struct mem_section *ms;
>+
> 	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
> 		return 0;
>-	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
>+	ms = __nr_to_section(pfn_to_section_nr(pfn));
>+	if (!valid_section(ms))
>+		return 0;
>+	return pfn_section_valid(ms, pfn);
> }
> #endif
> 
>@@ -1373,6 +1399,7 @@ void sparse_init(void);
> #define sparse_init()	do {} while (0)
> #define sparse_index_init(_sec, _nid)  do {} while (0)
> #define pfn_present pfn_valid
>+#define subsection_map_init(_pfn, _nr_pages) do {} while (0)
> #endif /* CONFIG_SPARSEMEM */
> 
> /*
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index c6d8224d792e..bd773efe5b82 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -7292,10 +7292,12 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
> 
> 	/* Print out the early node map */
> 	pr_info("Early memory node ranges\n");
>-	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
>+	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid) {
> 		pr_info("  node %3d: [mem %#018Lx-%#018Lx]\n", nid,
> 			(u64)start_pfn << PAGE_SHIFT,
> 			((u64)end_pfn << PAGE_SHIFT) - 1);
>+		subsection_map_init(start_pfn, end_pfn - start_pfn);
>+	}

Just curious about why we set subsection here?

Function free_area_init_nodes() mostly handles pgdat, if I am correct. Setup
subsection here looks like touching some lower level system data structure.

> 
> 	/* Initialise every node */
> 	mminit_verify_pageflags_layout();
>diff --git a/mm/sparse.c b/mm/sparse.c
>index 71da15cc7432..0baa2e55cfdd 100644
>--- a/mm/sparse.c
>+++ b/mm/sparse.c
>@@ -210,6 +210,41 @@ static inline unsigned long first_present_section_nr(void)
> 	return next_present_section_nr(-1);
> }
> 
>+void subsection_mask_set(unsigned long *map, unsigned long pfn,
>+		unsigned long nr_pages)
>+{
>+	int idx = subsection_map_index(pfn);
>+	int end = subsection_map_index(pfn + nr_pages - 1);
>+
>+	bitmap_set(map, idx, end - idx + 1);
>+}
>+
>+void subsection_map_init(unsigned long pfn, unsigned long nr_pages)
>+{
>+	int end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
>+	int i, start_sec = pfn_to_section_nr(pfn);
>+
>+	if (!nr_pages)
>+		return;
>+
>+	for (i = start_sec; i <= end_sec; i++) {
>+		struct mem_section *ms;
>+		unsigned long pfns;
>+
>+		pfns = min(nr_pages, PAGES_PER_SECTION
>+				- (pfn & ~PAGE_SECTION_MASK));
>+		ms = __nr_to_section(i);
>+		subsection_mask_set(ms->usage->subsection_map, pfn, pfns);
>+
>+		pr_debug("%s: sec: %d pfns: %ld set(%d, %d)\n", __func__, i,
>+				pfns, subsection_map_index(pfn),
>+				subsection_map_index(pfn + pfns - 1));
>+
>+		pfn += pfns;
>+		nr_pages -= pfns;
>+	}
>+}
>+
> /* Record a memory area against a node. */
> void __init memory_present(int nid, unsigned long start, unsigned long end)
> {

-- 
Wei Yang
Help you, Help me

