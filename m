Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2A43C28CC6
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:12:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 714C02070B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:12:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 714C02070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A2BB6B0271; Wed,  5 Jun 2019 18:12:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 152FE6B0272; Wed,  5 Jun 2019 18:12:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 044236B0273; Wed,  5 Jun 2019 18:12:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C22BE6B0271
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 18:12:24 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id l4so289121pff.5
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 15:12:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=hae6rk+qL45xxjhpub2qabo/6u1of96bSs3wXLn92Vo=;
        b=oKmJ8VqFD/sNPl5+KQLdvHLWHz27omKXAty5LCgNksK04rYuB9Y5saHwUyETaCbD8M
         tJJz3p6EZZzDrfk/IvObY9RyuTYUpzShzlu2xfLiLdxp6TSTXFBuiz727qEsG/oiJkD9
         XsGV9CSfelEEngC5KBAmRDvmpkBb+ODoMEk3dxHBfFtYNaB4lTXsd68i/p4t2Sps6MUf
         yZTaBf4FS0LME4ZqHoErwNk3i4X9j3XMxDLBs0o0UKZtgb/qkBwTzROnIBPCEeV5ikdG
         LavFZp9rC/x6azfAhBCq6JDhK5sY0xDYFTFbxJrCPCz39mdDWODxgEMz7yWPGRG1QbF4
         K1xg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXxIdIkhCBQTYEnoVeOuLj9svFp8GCKXJBzxXmsoPhbLsFad2W7
	BdL2MPv9cl7gPjpPUlQuEY0k/aJV4w3EMe8o1b/AJ/ER21a4qRssmbJPdjaBPucYLvBMQNGgi6j
	ERMoQ4fZU4Kq7e1Id2GDZZCO1zYKD0ZX/X0652C/1bBKK2a8l/yToY+TMLciYfQrd6w==
X-Received: by 2002:a17:902:12f:: with SMTP id 44mr46457107plb.137.1559772744272;
        Wed, 05 Jun 2019 15:12:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxh5qRiyxRHDkiDDNVkczA1qXX5lo2rWM1BMrAYvpAP/XznMuockBbtI3Z3YLxk59ommzhl
X-Received: by 2002:a17:902:12f:: with SMTP id 44mr46457020plb.137.1559772743432;
        Wed, 05 Jun 2019 15:12:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559772743; cv=none;
        d=google.com; s=arc-20160816;
        b=sLMsGn7IJSqox+hSFcELsuvHrA8/lz5kXY7ycU+kF/MZ7JPEPwBE8dkREmnV30b4tb
         +lDyFeviXhUoq5DdXwyBn7zRC200ZwDdf9SZDCwqbLNbJXKiA6HohL/v2TDwoep92TXw
         EJNCipIcfykNwpz015xgg8mpfD8BK9YFpAbLEUKtZNAJus2Iwk36mTvoJBkyrtkZvynl
         4oTSps0TDCIwF25dsdDrmQdZgN3Oes8V8dZFW7aOO1zuPDIdDU3xwpRC+TFpnkrtCRzQ
         wHI+QzFppo+H3h/+CoHGHpDvmIfIlBnU7XDP+uvQUUnKjBr/Q2MzSwSoh/c2vVoLuvKb
         kCkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=hae6rk+qL45xxjhpub2qabo/6u1of96bSs3wXLn92Vo=;
        b=0PEX8D3jJPFlTr8F1LtLGikghfRUt90Qp0J4ANgrN90XHPMs6FhGgC0uFiJ+bDEwO+
         RpVnuZx/6MdGagwUIj0AGKhQG31U/ggrrITPItuwlnG1TeDDSy8QNw4x8YiUP3c5y8vZ
         Qdo4uZCBePbWRoGQURe+/aTNqtl782IWPgi748epWvR0q9XlCI81F4NJ+LohUWQFaMqk
         8ru2ZPGGkSdV5OILsV0Xb9+okxTWnW2kHzqedmRhqoGah6WcaD/d+0rZCv7D5iSPcbJo
         pSulKWey81HVBb9qaDx+E5N8cNhIGNDnethpECMa5ojjNT/eMPqdUbAsjUvT6pDgPc4d
         3JsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id f1si131894pgi.432.2019.06.05.15.12.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 15:12:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 15:12:22 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by FMSMGA003.fm.intel.com with ESMTP; 05 Jun 2019 15:12:21 -0700
Subject: [PATCH v9 03/12] mm/hotplug: Prepare shrink_{zone,
 pgdat}_span for sub-section removal
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, Oscar Salvador <osalvador@suse.de>,
 linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org,
 osalvador@suse.de, mhocko@suse.com
Date: Wed, 05 Jun 2019 14:58:04 -0700
Message-ID: <155977188458.2443951.9573565800736334460.stgit@dwillia2-desk3.amr.corp.intel.com>
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

Sub-section hotplug support reduces the unit of operation of hotplug
from section-sized-units (PAGES_PER_SECTION) to sub-section-sized units
(PAGES_PER_SUBSECTION). Teach shrink_{zone,pgdat}_span() to consider
PAGES_PER_SUBSECTION boundaries as the points where pfn_valid(), not
valid_section(), can toggle.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/memory_hotplug.c |   29 ++++++++---------------------
 1 file changed, 8 insertions(+), 21 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 7b963c2d3a0d..647859a1d119 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -318,12 +318,8 @@ static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
 				     unsigned long start_pfn,
 				     unsigned long end_pfn)
 {
-	struct mem_section *ms;
-
-	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SECTION) {
-		ms = __pfn_to_section(start_pfn);
-
-		if (unlikely(!valid_section(ms)))
+	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SUBSECTION) {
+		if (unlikely(!pfn_valid(start_pfn)))
 			continue;
 
 		if (unlikely(pfn_to_nid(start_pfn) != nid))
@@ -343,15 +339,12 @@ static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
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
+	for (; pfn >= start_pfn; pfn -= PAGES_PER_SUBSECTION) {
+		if (unlikely(!pfn_valid(pfn)))
 			continue;
 
 		if (unlikely(pfn_to_nid(pfn) != nid))
@@ -373,7 +366,6 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 	unsigned long z = zone_end_pfn(zone); /* zone_end_pfn namespace clash */
 	unsigned long zone_end_pfn = z;
 	unsigned long pfn;
-	struct mem_section *ms;
 	int nid = zone_to_nid(zone);
 
 	zone_span_writelock(zone);
@@ -410,10 +402,8 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 	 * it check the zone has only hole or not.
 	 */
 	pfn = zone_start_pfn;
-	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SECTION) {
-		ms = __pfn_to_section(pfn);
-
-		if (unlikely(!valid_section(ms)))
+	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SUBSECTION) {
+		if (unlikely(!pfn_valid(pfn)))
 			continue;
 
 		if (page_zone(pfn_to_page(pfn)) != zone)
@@ -441,7 +431,6 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 	unsigned long p = pgdat_end_pfn(pgdat); /* pgdat_end_pfn namespace clash */
 	unsigned long pgdat_end_pfn = p;
 	unsigned long pfn;
-	struct mem_section *ms;
 	int nid = pgdat->node_id;
 
 	if (pgdat_start_pfn == start_pfn) {
@@ -478,10 +467,8 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 	 * has only hole or not.
 	 */
 	pfn = pgdat_start_pfn;
-	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SECTION) {
-		ms = __pfn_to_section(pfn);
-
-		if (unlikely(!valid_section(ms)))
+	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SUBSECTION) {
+		if (unlikely(!pfn_valid(pfn)))
 			continue;
 
 		if (pfn_to_nid(pfn) != nid)

