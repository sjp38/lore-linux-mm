Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 072ABC31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:06:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCDF320B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:06:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCDF320B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CD746B0008; Wed, 19 Jun 2019 02:06:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 757F78E0002; Wed, 19 Jun 2019 02:06:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 646868E0001; Wed, 19 Jun 2019 02:06:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 304DB6B0008
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:06:14 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 30so11569438pgk.16
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:06:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=hae6rk+qL45xxjhpub2qabo/6u1of96bSs3wXLn92Vo=;
        b=iRep2NP8MuJ6iX8qVXojdECP1sX5A4d3isJmP0cAzqcngcGp/jHl0SbySUTbQW4ZJZ
         Bnard3ONx3Dqs8EY+WESvSjeCeSl5eWuhiavaSEoXZ8TyJzqpOqhdemnRvP4VDROQGN1
         G+7Belyl1ggLT905ZHckepSlzcwMzva3Pb2Kcpudr0iokJ7Pa1nBlbcGPLMcucJAGbR1
         aRsWy7smHWNmuAhQLJld3IJtnIJJdiEd9xbQSN0yjqjTBmPsr5sOAbCQYRTuQRHpb8Z6
         jMI5kH4jg124JIltQeCFGZNDyjiGyOy10hwoAqMw9iMOqDuS1Y6ccJqaMpuH01KfuXFW
         0MeA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVHSrcEn0iiYFGZCiGhJb1d3w2Vg89pBA0elDhFrleh/ZAcGo9R
	NVn6owJc8oJLemvFcyI/X3x9Ilt4YdJx2LDpjVtlp3e0OV5dfBNQvPGfJqlzFZ8Il2WjrREyKhl
	2ygiSZH72S52BhzOGgTqG2cTLiuXS9+zvA1f7feFmGNwVPvtdMKcnPWXhwLXN9/3w7g==
X-Received: by 2002:a17:90a:db52:: with SMTP id u18mr9421446pjx.107.1560924373875;
        Tue, 18 Jun 2019 23:06:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwumISH0dIPWcBgTN2tMIUqmrUiDsSjSs7/rA4EpFS59luHzFeqF+WfRj3+Y2n14swO+3g1
X-Received: by 2002:a17:90a:db52:: with SMTP id u18mr9421373pjx.107.1560924372768;
        Tue, 18 Jun 2019 23:06:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560924372; cv=none;
        d=google.com; s=arc-20160816;
        b=OqeZrDt5FwoHvU3HiQjzXrRzSGg+G+V2M8h6vKQx9+L1NQFJZjupRRfY/gqbodI0fD
         ugfrzXOsqJe7pJ5ReOSSPVNAVdaQotE2gKgPa9KuINUYVczWzmZaRmeET/zD5itJoFEy
         dXNTbnhha+2T+XVtcZSvlYf7DgCYiG5E7MU9T7csffWy+KlPPovuhKAlhNSBqp4wIVWw
         D/mlw6YXM5bhHv1sBjkdo2QFu5VYG9oRCWbnm+HxifT03Hw77sFeT1JwTpQC+wMm0ya5
         tJbSztXlEr87trp/JJx9V9RMDN2mpNaxOTZ7fuxgNA+QUyg4wOz7FZHRc7oeGurBlVIr
         yIiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=hae6rk+qL45xxjhpub2qabo/6u1of96bSs3wXLn92Vo=;
        b=T33f0GmBYRwBB7YRkbgvMUe3nnmX5dwe0WriX8xn0IE04uyu+1E4Y3l20f+Z3oK/+T
         I7ccSr98fA1zQbBFEmIkK13IydgBWQZcBvgVGAFd5ja5dpHwJrwMlhW0Q1pchCs6NEgq
         /lpxlbZT+2FWKMBrAIKw8ZuqnvraOh9IxMZ7lFW4hIUzTaUHLPHm7ttSY6bMOuE9eosJ
         jWDD+lkGNd2dOzINF5TMN4auyiv9eyAJPaZU1u116R0YCA++t/ZzHymSf/Z3N7n7E6xo
         go+1ulpYkLeejN9fHwSBymiumkBFin/7yacZPLX6cugwwIEtP5YhhOONvRpO/b4dUSwh
         6H3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id j191si2267391pgc.73.2019.06.18.23.06.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:06:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:06:12 -0700
X-IronPort-AV: E=Sophos;i="5.63,392,1557212400"; 
   d="scan'208";a="161956637"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga007-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:06:11 -0700
Subject: [PATCH v10 04/13] mm/hotplug: Prepare shrink_{zone,
 pgdat}_span for sub-section removal
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, Oscar Salvador <osalvador@suse.de>,
 linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Tue, 18 Jun 2019 22:51:55 -0700
Message-ID: <156092351496.979959.12703722803097017492.stgit@dwillia2-desk3.amr.corp.intel.com>
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

