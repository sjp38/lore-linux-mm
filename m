Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1685CC31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:42:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDE242082C
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:42:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDE242082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 775F18E0005; Mon, 17 Jun 2019 21:42:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 726358E0001; Mon, 17 Jun 2019 21:42:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 614EB8E0005; Mon, 17 Jun 2019 21:42:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2DF5F8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 21:42:50 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id t2so6873265plo.10
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 18:42:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=p6H0mL+tlfk+OXys+YnErPASvhlh2UJN/+MjTuBwcq0=;
        b=mtyD9P7GhrKblXh8n5pKWuKGK3iiymM4G1dtImwtVn94uK3+LsDu1TfMyPudO+N6/k
         S/XqOcsaF4UK4RC47mgK+GRrkoVjr8BRncEOAi2S4Y1vpLx+Y7Kxh6RBf29/wUgfKWnA
         eTUylQVW0EMh60bKHrAtoNzH9S51I3e6601/mWCW/em0SsI77qN+mwax7zFlPgPk8jdj
         nv6rvMSgcXcvkkc8kZPq8SXPx1nq0+DcVdiq3EVcGGakPIiXvQE3YIu7hOAHhQF3dUZo
         Do6ZvyqWKM2ZLkpRYR4sUDyGfw+1C6W1F1s4g3NeCOIqt5Mb6xFC08mcbtHKOQlkzcxY
         +NIw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWP09/b/ZZQxCH3aM1nxu9QuP45lZOg7NFGbNBdqE7Nifh7QTMI
	w+8G7gbmSDrvzGRsxKF8Q7fsmLSfKmyr6lg0fqoJCg57Lt070AdDqHx64Y/lkY1NJjBfw3sPPO0
	wheRxHkTCoXNGLA4261WznTUYCXnY9kavGn0WMC2ewhzIfcIaExe4hQdEvfvZq8eF7Q==
X-Received: by 2002:a17:90a:aa85:: with SMTP id l5mr2189925pjq.69.1560822169836;
        Mon, 17 Jun 2019 18:42:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQmCWHe0ShI6Bq2GlwKM1m4/nH1I8NL5Sog2NbJ/G8MFZt7GAN/HsFCACZZbNVirgTXlFs
X-Received: by 2002:a17:90a:aa85:: with SMTP id l5mr2189874pjq.69.1560822169012;
        Mon, 17 Jun 2019 18:42:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560822169; cv=none;
        d=google.com; s=arc-20160816;
        b=fIxrQkdHonmhJ08MXP/SbQJoPMVi8pA2gr4M/I1xhd7XE8SVlbhPSYLIcSeYGzKIuX
         1u7NLlOdd12WjMm6hC+FVY78dmgWMqoXRmh668Mc5POjlKe/2Ec2HSUfb0OILJyvILAd
         jkJLZWIyCZZGGJXZdkVN//J//vwjD3ir6/dkhb3oyAT1bXWZ4VHJEgs6gpj7MAWUwoHF
         6jY32r+oQy1n3bdELgnm0JZgx4XmiN2WAqhaxJppL5OtIyELuaqfWvEqCjtLFcQ77XRv
         2WcJ429Z56BhHKURUQJqy79i0tPGHun1cryLrjFMGRRF17VAmmZZ3MrKL2YugW09at4S
         cNNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date;
        bh=p6H0mL+tlfk+OXys+YnErPASvhlh2UJN/+MjTuBwcq0=;
        b=bJxwx5GwkHSNnCkEYhSGl8bcFmdUK4UAwdpKXf0S0saiOKIeugL/lZmdqt4kO0O5Um
         SgBT9k7ptm9eSH8/AfX6KElMc8O1aKcEIjQovEXBvRpnAA3D13tYhMAjtBesL69IX40F
         iPHgjO/Rz0KAOkjl9ysg6I/JxDVirr0dZNamHqW3Bdwq3jcXr900/kJXdVmzxgUv9L7y
         NHGnsh5rbVTfjZbVzJrSx9sqXLT3YCgA3QLDRKzE7G6Gd2hrMtC3e31KgsXqlIl9yYWm
         +LoWek6bnqUXSSqfz7PLo3T+2+Fc5Oqm0kFVxHxMfdX2p94lW8onQ1AJ4qdIirNaPjBk
         9gAA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id d2si11087789plo.21.2019.06.17.18.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 18:42:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 18:42:48 -0700
X-ExtLoop1: 1
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga005.fm.intel.com with ESMTP; 17 Jun 2019 18:42:46 -0700
Date: Tue, 18 Jun 2019 09:42:23 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>,
	osalvador@suse.de
Subject: Re: [PATCH v9 03/12] mm/hotplug: Prepare shrink_{zone, pgdat}_span
 for sub-section removal
Message-ID: <20190618014223.GD18161@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155977188458.2443951.9573565800736334460.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155977188458.2443951.9573565800736334460.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 02:58:04PM -0700, Dan Williams wrote:
>Sub-section hotplug support reduces the unit of operation of hotplug
>from section-sized-units (PAGES_PER_SECTION) to sub-section-sized units
>(PAGES_PER_SUBSECTION). Teach shrink_{zone,pgdat}_span() to consider
>PAGES_PER_SUBSECTION boundaries as the points where pfn_valid(), not
>valid_section(), can toggle.
>
>Cc: Michal Hocko <mhocko@suse.com>
>Cc: Vlastimil Babka <vbabka@suse.cz>
>Cc: Logan Gunthorpe <logang@deltatee.com>
>Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
>Reviewed-by: Oscar Salvador <osalvador@suse.de>
>Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>---
> mm/memory_hotplug.c |   29 ++++++++---------------------
> 1 file changed, 8 insertions(+), 21 deletions(-)
>
>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index 7b963c2d3a0d..647859a1d119 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -318,12 +318,8 @@ static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
> 				     unsigned long start_pfn,
> 				     unsigned long end_pfn)
> {
>-	struct mem_section *ms;
>-
>-	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SECTION) {
>-		ms = __pfn_to_section(start_pfn);
>-
>-		if (unlikely(!valid_section(ms)))
>+	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SUBSECTION) {
>+		if (unlikely(!pfn_valid(start_pfn)))
> 			continue;

Hmm, we change the granularity of valid section from SECTION to SUBSECTION.
But we didn't change the granularity of node id and zone information.

For example, we found the node id of a pfn mismatch, we can skip the whole
section instead of a subsection.

Maybe this is not a big deal.

> 
> 		if (unlikely(pfn_to_nid(start_pfn) != nid))
>@@ -343,15 +339,12 @@ static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
> 				    unsigned long start_pfn,
> 				    unsigned long end_pfn)
> {
>-	struct mem_section *ms;
> 	unsigned long pfn;
> 
> 	/* pfn is the end pfn of a memory section. */
> 	pfn = end_pfn - 1;
>-	for (; pfn >= start_pfn; pfn -= PAGES_PER_SECTION) {
>-		ms = __pfn_to_section(pfn);
>-
>-		if (unlikely(!valid_section(ms)))
>+	for (; pfn >= start_pfn; pfn -= PAGES_PER_SUBSECTION) {
>+		if (unlikely(!pfn_valid(pfn)))
> 			continue;
> 
> 		if (unlikely(pfn_to_nid(pfn) != nid))
>@@ -373,7 +366,6 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
> 	unsigned long z = zone_end_pfn(zone); /* zone_end_pfn namespace clash */
> 	unsigned long zone_end_pfn = z;
> 	unsigned long pfn;
>-	struct mem_section *ms;
> 	int nid = zone_to_nid(zone);
> 
> 	zone_span_writelock(zone);
>@@ -410,10 +402,8 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
> 	 * it check the zone has only hole or not.
> 	 */
> 	pfn = zone_start_pfn;
>-	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SECTION) {
>-		ms = __pfn_to_section(pfn);
>-
>-		if (unlikely(!valid_section(ms)))
>+	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SUBSECTION) {
>+		if (unlikely(!pfn_valid(pfn)))
> 			continue;
> 
> 		if (page_zone(pfn_to_page(pfn)) != zone)
>@@ -441,7 +431,6 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
> 	unsigned long p = pgdat_end_pfn(pgdat); /* pgdat_end_pfn namespace clash */
> 	unsigned long pgdat_end_pfn = p;
> 	unsigned long pfn;
>-	struct mem_section *ms;
> 	int nid = pgdat->node_id;
> 
> 	if (pgdat_start_pfn == start_pfn) {
>@@ -478,10 +467,8 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
> 	 * has only hole or not.
> 	 */
> 	pfn = pgdat_start_pfn;
>-	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SECTION) {
>-		ms = __pfn_to_section(pfn);
>-
>-		if (unlikely(!valid_section(ms)))
>+	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SUBSECTION) {
>+		if (unlikely(!pfn_valid(pfn)))
> 			continue;
> 
> 		if (pfn_to_nid(pfn) != nid)
>
>_______________________________________________
>Linux-nvdimm mailing list
>Linux-nvdimm@lists.01.org
>https://lists.01.org/mailman/listinfo/linux-nvdimm

-- 
Wei Yang
Help you, Help me

