Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6207DC04AA9
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:09:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F38C2085A
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:09:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F38C2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C604D6B000A; Thu,  2 May 2019 02:09:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE9786B000C; Thu,  2 May 2019 02:09:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AFFE46B000D; Thu,  2 May 2019 02:09:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0476B000A
	for <linux-mm@kvack.org>; Thu,  2 May 2019 02:09:31 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x13so712548pgl.10
        for <linux-mm@kvack.org>; Wed, 01 May 2019 23:09:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=hjdIGXbMx4GcFibb2CVeLHDFdsRvl1weqFUALYsiTZU=;
        b=Upfsooq9yAkjQ/cr4Bl7/VRwnhvKcngmMyiBZOVi3rlAwwQ8T9O72slEBvCKKMvoDQ
         SGoq36OXDbyw/8180/xEZwXi+GB/7tuYdtq3hi6aRh2ivzw7Is/Gv3einAuwzqeSGKiw
         N73tmHOMnpOa6aXzO0pTRucbgPUM4zYKNBOu9E7RIsEcrzholQgzTg2JtNjKZRLl22cd
         piwdiUeeLYYFtkg6fWBz82tcDxiQmycTZdfrTu3G7UpIyqZefJCWidRb8NImHSuwK7F2
         qVMCSC0TqxXOe1tpzbj6nkFxvPMVsMTq1donVG2MhmoMiI0+LIWqyMZWQVGYFTvR6izT
         +rAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX9CZQvjCB5VDvI/G/+NCANv4Kt92PGLd0XaaDdOfG4jRc8AJoK
	gkY/HbNA3mx20Z8o/ClkW9mERi89rtbbW3v/TaWvxl7R3KtYpqrEeBd6rIPtefK7CXURG/QvjJT
	6BYaonSa9OyOfxy/6mIT0xp281VbMgpap+nMWg5uO19RpAy8M2Woixd+aWG/ICncm/A==
X-Received: by 2002:a63:690:: with SMTP id 138mr2105765pgg.415.1556777371165;
        Wed, 01 May 2019 23:09:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwGLoerteCk/lyE13lw1AagNtxsyyXZIBQCuYP+8kJrTrMHrjTGVEBHLRM2SLuLyyT5Qh3d
X-Received: by 2002:a63:690:: with SMTP id 138mr2105681pgg.415.1556777370129;
        Wed, 01 May 2019 23:09:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556777370; cv=none;
        d=google.com; s=arc-20160816;
        b=eCSNiJFnDo4JlTlYvit2KnMqYgfnyn0tdcYF2f0hkBll7SRbb//Fxb7sUvZ7bw6NiX
         xzdLbzN1QcFGb4AGJa2xEccxaMB1radzNCtHO9BRmNiWrHv06bzRSZeAjmGMnz4x1Fgr
         OVb3b+PAYTlwoeCHqAETQ5Gdvyt1i72eeoTWIasM9HnUnXewUq3JpLWkQU/elpCPZA4P
         NF0zHj/+8yv0V7KR7HAGAe9m1Yuccokh9SFoA6lvfvhJ9tp2zM9HXMJKyEIrto+VClxa
         mZ4QvBju1BiYP9UYustmVbjBRxekpvSgQgLSJSKG6A5r2gOxdWPS9t9pX8NBhfsg1/KK
         T/zA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=hjdIGXbMx4GcFibb2CVeLHDFdsRvl1weqFUALYsiTZU=;
        b=YaYFRdt/JRNhqawWXbuubklPb8mlMZO7nYoKz0t1H3rINEGF7wxdqxVNEM6qMZiW7H
         LlfHhPHX/WgEvbq6/mGmmiKv7K4/+ySIMxK1hWrz+dqOLu9DUawxdrafbpQnMVQ24twA
         qFa4gVHjT3bD+KFadfTQwwH1h1YL0eiB9YpKLGf2fKjpd9XGb30vcccK0o3ZXJrOFj96
         Oc7YlVf1WCNPsEpv+h4IfWW66UYlaVF6O0khBD73qRkEYT9Pt6zOjWVX9JoxfPTuUGq+
         hR0J44ldrEj/Rn7qd0hCNv6wCRDP7JRLSPBMGuXYRcDopIecidEyva5M06SM00u4em2p
         9G/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id u22si43155258plq.193.2019.05.01.23.09.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 23:09:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 May 2019 23:09:29 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,420,1549958400"; 
   d="scan'208";a="342689748"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga006.fm.intel.com with ESMTP; 01 May 2019 23:09:29 -0700
Subject: [PATCH v7 04/12] mm/hotplug: Prepare shrink_{zone,
 pgdat}_span for sub-section removal
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, Oscar Salvador <osalvador@suse.de>,
 linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 osalvador@suse.de, mhocko@suse.com
Date: Wed, 01 May 2019 22:55:43 -0700
Message-ID: <155677654297.2336373.3779112213402789415.stgit@dwillia2-desk3.amr.corp.intel.com>
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

Sub-section hotplug support reduces the unit of operation of hotplug
from section-sized-units (PAGES_PER_SECTION) to sub-section-sized units
(PAGES_PER_SUBSECTION). Teach shrink_{zone,pgdat}_span() to consider
PAGES_PER_SUBSECTION boundaries as the points where pfn_valid(), not
valid_section(), can toggle.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h |    2 ++
 mm/memory_hotplug.c    |   29 ++++++++---------------------
 2 files changed, 10 insertions(+), 21 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index cffde898e345..b13f0cddf75e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1164,6 +1164,8 @@ static inline unsigned long section_nr_to_pfn(unsigned long sec)
 
 #define SECTION_ACTIVE_SIZE ((1UL << SECTION_SIZE_BITS) / BITS_PER_LONG)
 #define SECTION_ACTIVE_MASK (~(SECTION_ACTIVE_SIZE - 1))
+#define PAGES_PER_SUB_SECTION (SECTION_ACTIVE_SIZE / PAGE_SIZE)
+#define PAGE_SUB_SECTION_MASK (~(PAGES_PER_SUB_SECTION-1))
 
 struct mem_section_usage {
 	/*
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a76fc6a6e9fe..0d379da0f1a8 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -325,12 +325,8 @@ static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
 				     unsigned long start_pfn,
 				     unsigned long end_pfn)
 {
-	struct mem_section *ms;
-
-	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SECTION) {
-		ms = __pfn_to_section(start_pfn);
-
-		if (unlikely(!valid_section(ms)))
+	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SUB_SECTION) {
+		if (unlikely(!pfn_valid(start_pfn)))
 			continue;
 
 		if (unlikely(pfn_to_nid(start_pfn) != nid))
@@ -350,15 +346,12 @@ static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
 				    unsigned long start_pfn,
 				    unsigned long end_pfn)
 {
-	struct mem_section *ms;
 	unsigned long pfn;
 
 	/* pfn is the end pfn of a memory section. */
 	pfn = end_pfn - 1;
-	for (; pfn >= start_pfn; pfn -= PAGES_PER_SECTION) {
-		ms = __pfn_to_section(pfn);
-
-		if (unlikely(!valid_section(ms)))
+	for (; pfn >= start_pfn; pfn -= PAGES_PER_SUB_SECTION) {
+		if (unlikely(!pfn_valid(pfn)))
 			continue;
 
 		if (unlikely(pfn_to_nid(pfn) != nid))
@@ -380,7 +373,6 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 	unsigned long z = zone_end_pfn(zone); /* zone_end_pfn namespace clash */
 	unsigned long zone_end_pfn = z;
 	unsigned long pfn;
-	struct mem_section *ms;
 	int nid = zone_to_nid(zone);
 
 	zone_span_writelock(zone);
@@ -417,10 +409,8 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 	 * it check the zone has only hole or not.
 	 */
 	pfn = zone_start_pfn;
-	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SECTION) {
-		ms = __pfn_to_section(pfn);
-
-		if (unlikely(!valid_section(ms)))
+	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SUB_SECTION) {
+		if (unlikely(!pfn_valid(pfn)))
 			continue;
 
 		if (page_zone(pfn_to_page(pfn)) != zone)
@@ -448,7 +438,6 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 	unsigned long p = pgdat_end_pfn(pgdat); /* pgdat_end_pfn namespace clash */
 	unsigned long pgdat_end_pfn = p;
 	unsigned long pfn;
-	struct mem_section *ms;
 	int nid = pgdat->node_id;
 
 	if (pgdat_start_pfn == start_pfn) {
@@ -485,10 +474,8 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 	 * has only hole or not.
 	 */
 	pfn = pgdat_start_pfn;
-	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SECTION) {
-		ms = __pfn_to_section(pfn);
-
-		if (unlikely(!valid_section(ms)))
+	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SUB_SECTION) {
+		if (unlikely(!pfn_valid(pfn)))
 			continue;
 
 		if (pfn_to_nid(pfn) != nid)

