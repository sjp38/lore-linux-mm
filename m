Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAD68C46470
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:53:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A58AE20830
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:53:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A58AE20830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E96F6B0008; Mon,  6 May 2019 19:53:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49B086B000A; Mon,  6 May 2019 19:53:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B2146B000C; Mon,  6 May 2019 19:53:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 063586B0008
	for <linux-mm@kvack.org>; Mon,  6 May 2019 19:53:31 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d1so8998810pgk.21
        for <linux-mm@kvack.org>; Mon, 06 May 2019 16:53:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=YhTLad8qon+eKY9RglTr9sk0iApBZ9IOXEG1Y6Y5HQY=;
        b=nDCcJHq2AC6R1h8iqeMSJEV7VRsDsrBbMCqpcF54m6HmdPwQA5Xbn0L7NDr9Ci0pLQ
         CltrDmSiuOgxqPmUkzQcva9yDLnMCtePZChmBxy4yBj1PeETt7fBaYzXO6SU8gnUhZOm
         ij343XNYbDd2DrSPcxNFrv50ZIUQw23Eob8mq1+WDBrP2Z8HABuCc+Lu4uPE4NyrxZV+
         uNwRpCvd6YRr2K2iixcpd/mqbOnpV+vGcRO0p3U/aVBExcgWvoCFh4fPhn+E5Q0ui4Lq
         LzSASD3xSjkOZmiXQHqtpXS6foc9v3x+WcHGXbMiImBedZhi1nJSoUh2AmsEn+XQEDpQ
         OeZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVtuKGTJlPYnMR/pv3Jh+Q7h1nyv/1J6Zrvh7P6Yh5BKvge5KBq
	y/MO+dGyJq3H/lNiqegw9IZ6SKukhcMVp40GFZbcRtLt5dCNY+xDHPDEx1PZ6bfPD9LHTo9ThTA
	CZkJFxNugOWfeqe94zQCDCIJ3L0jndLHSCSBI+QufKPsGR6AXwMAp4IwWanLscPbV6A==
X-Received: by 2002:a17:902:bd91:: with SMTP id q17mr9959433pls.13.1557186810644;
        Mon, 06 May 2019 16:53:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcu7Pq2OcUJUJn6rmDScvOTpVkVtugbQ+6URjMZI4hGuF5S75n3/dsSVZ1ljqr82K9X6zP
X-Received: by 2002:a17:902:bd91:: with SMTP id q17mr9959384pls.13.1557186809751;
        Mon, 06 May 2019 16:53:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557186809; cv=none;
        d=google.com; s=arc-20160816;
        b=DMci42qi6nHkzK38JMEUEv6/dr8IMbJ6N0HPMioeODugl29gTh3kBYBH8r9FUiO97t
         rW8ZTL3DBMnbi3LB7wL2NQuNbUOF2+94kogsc9HprzQIm+aYOFgx6qQlimEi5X+eEOs6
         JN+oxcn3AUypZ7uHuuyXV6O71LwMWc9Ynghn0JOdJMr1FG2c0x76DeKAITbzV7k3kDaJ
         0u52pmzRr3eQ0e7CK0au/axYGXfKmwGpe6kNn/wCO47VzUpxH0/gfd+xFHwdmCiw+KKA
         HBECMU2ZGaSunKR/wpn7UlbhihTkpw1uAMd7/IRMbhTe/0XjYaYYdziy/OP8DiJWa9S8
         63ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=YhTLad8qon+eKY9RglTr9sk0iApBZ9IOXEG1Y6Y5HQY=;
        b=K3N5ChTLZgkE018GefZr91AamrP5R90DibfgIGuTPNx39izUJnf6VxBpBWqhtVP3gH
         ny/84QkQabSTGtDLtpjUmAR2IpgMbJqZUReQXBCTrnXXUT12m0hk3i+vv80jfFYxrHsQ
         ZWe7qzlrsOQTmZqXcYxsiLfQ0nShx5RgyORTklH/jUWRUWP/WCYOh3OAqKZLVyx7mYTw
         uvQLOBlZRskUpLD9l/oBGZ7y9RppA/wxS0KYnSqpPmOfSPZNhBIHH4P5tvr/O9YzfkYn
         S5nTgTzY3mRnyvGXal6dG4RE/sZkzfIYEIXEr+YXs3GJBAB3lasPCM1PEoCmyy59zlxR
         9FwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a68si17835459pla.60.2019.05.06.16.53.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 16:53:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 May 2019 16:53:29 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,439,1549958400"; 
   d="scan'208";a="147053295"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga008.fm.intel.com with ESMTP; 06 May 2019 16:53:28 -0700
Subject: [PATCH v8 03/12] mm/sparsemem: Add helpers track active portions of
 a section at boot
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, Oscar Salvador <osalvador@suse.de>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, Jane Chu <jane.chu@oracle.com>,
 linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 osalvador@suse.de, mhocko@suse.com
Date: Mon, 06 May 2019 16:39:42 -0700
Message-ID: <155718598213.130019.10989541248734713186.stgit@dwillia2-desk3.amr.corp.intel.com>
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
 mm/sparse.c            |   29 +++++++++++++++++++++++++++++
 3 files changed, 60 insertions(+), 2 deletions(-)

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
index 61c2b54a5b61..13816c5a51eb 100644
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
+		subsection_map_init(start_pfn, end_pfn - start_pfn);
+	}
 
 	/* Initialise every node */
 	mminit_verify_pageflags_layout();
diff --git a/mm/sparse.c b/mm/sparse.c
index f87de7ad32c8..ac47a48050c7 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -210,6 +210,35 @@ static inline unsigned long first_present_section_nr(void)
 	return next_present_section_nr(-1);
 }
 
+void subsection_map_init(unsigned long pfn, unsigned long nr_pages)
+{
+	int end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
+	int i, start_sec = pfn_to_section_nr(pfn);
+
+	if (!nr_pages)
+		return;
+
+	for (i = start_sec; i <= end_sec; i++) {
+		int idx, end;
+		unsigned long pfns;
+		struct mem_section *ms;
+
+		idx = subsection_map_index(pfn);
+		pfns = min(nr_pages, PAGES_PER_SECTION
+				- (pfn & ~PAGE_SECTION_MASK));
+		end = subsection_map_index(pfn + pfns - 1);
+
+		ms = __nr_to_section(i);
+		bitmap_set(ms->usage->subsection_map, idx, end - idx + 1);
+
+		pr_debug("%s: sec: %d pfns: %ld set(%d, %d)\n", __func__, i,
+				pfns, idx, end - idx + 1);
+
+		pfn += pfns;
+		nr_pages -= pfns;
+	}
+}
+
 /* Record a memory area against a node. */
 void __init memory_present(int nid, unsigned long start, unsigned long end)
 {

