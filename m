Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2504DC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 20:31:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B639620848
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 20:31:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B639620848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 173A76B0003; Mon, 25 Mar 2019 16:31:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1239F6B0006; Mon, 25 Mar 2019 16:31:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03B2D6B0007; Mon, 25 Mar 2019 16:31:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AB5DB6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 16:31:45 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s27so4277622eda.16
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 13:31:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DWxqwBbrgqQE+WUxRoDzXnFkkPc3GAkEiEr4A//nMW8=;
        b=uRt162n2zzemcPJocWqhgPE4/I/+FmfOlC+MEraTAkdyJFCYJ1sc1hxgBWj/mz92u/
         Z1rI3yd8E2XevGJjD8MMC18QdjRZ17HJN5Rbm+hRQ97f6gxy3/cPrNNeuUrCNWbXUKYO
         jYxzywfno7MeyQ3Y2d4oqgmU5MFxTvgWOI1bQNnjq1Ju4nfTGR3xDMoXp91gtbsh24OP
         o5taAUOQi/cw3X4Q/DUrfaQ/3KLn8KzFqppO6qdytyBf4oZevMt6Cd4tfMOTO7ZI/BQ3
         vhMMG/DsathX2GWddCiUtksZs9Xw6KJ8ADnxnxT2XdjRBEbvNJQaV/M+7XFdRhMe026T
         YyCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAW36WDxpoeiYkGwTiaakXtYwGHvteko03P0xEJpyYOW0C8882/8
	mS4dbZeiAiS596oeT1KrJqtAqSJsLN3J1gO9WRy+dlfxhPY6+8NmjOA/eZPCXUvQQx8kqgcN21G
	1w+TH3axvYny96zoyIJqc2Dyt7CbT+WOU+rUXDupbqB56u6Z6ylH/pr23o5ooXLZ2tQ==
X-Received: by 2002:aa7:d3d8:: with SMTP id o24mr18283590edr.53.1553545905261;
        Mon, 25 Mar 2019 13:31:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwDB1WQwCOzAzZSpWNM/GQr38DM/A12MdEF4cZv9HA1GQXNaSvcJEUFhXYsG5ANdNOwK0I
X-Received: by 2002:aa7:d3d8:: with SMTP id o24mr18283546edr.53.1553545904123;
        Mon, 25 Mar 2019 13:31:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553545904; cv=none;
        d=google.com; s=arc-20160816;
        b=VNAZFhG8FizMX7mULNJO0MGDZRJtSBQJLibhlhj6VAq8qRqnO8qW421HeTsA9cH/jF
         AM1Ba0cqIfqD2RCmqKPtSIIqZkMMvm9YFXl875FX/1nUNOjGZIk+LmepC/lK0aS5w9pp
         48n0n/UtWOdQe9Z42PprMNF9Cp204SUSmzWTBsRUa5TAa1WfLvlWVOSijG4wGZDcyt4j
         zuVLTptI2vmcgWyaIHMc+ViOjAts+kaYNrwqQDgvVpAR5xVPEbpynRByuAa53vJeJ8b3
         lWwkDmjFPCg5kTaYzKrZESFsnRv7qKRUgyu36cVXGGItcCIcZGVGFKQB1pwtdbc9YNsR
         92Fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DWxqwBbrgqQE+WUxRoDzXnFkkPc3GAkEiEr4A//nMW8=;
        b=pi3KDRy+Hpu0PXGG1ciXc+cmcBs2pK0sT5i6bICZdTidibc4ZClMYPgF0vMscwhiY2
         knpM0by1rUqJ9lB7vC6ekWuQnZgxDCoJ+dLbc0QURx/8WawBM0iXY2bf3uosn1K+/uKV
         4+/8/zph0b4xvYroc53mtirvUIMsPNIgX+hdzxFPcMgP3ztmLvSQwbQDMtmRfvI2v+rU
         8+OzXQ75GEWbbd5guKo85eGQbRt4sfL4RIHVZ5cU5RE4wFrL5wwsfUlK7/dLC52SXZtS
         G+Qvu91sLrgY6Re8jLO/q8qLhkUAG0h3vKw3pKVH2Qni5/roEqbWXJzEBMkNdF5U5iCc
         Jx5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id z13si940819edh.384.2019.03.25.13.31.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 13:31:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) client-ip=81.17.249.8;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.8 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id B800998AD0
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 20:31:43 +0000 (UTC)
Received: (qmail 5782 invoked from network); 25 Mar 2019 20:31:43 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 25 Mar 2019 20:31:43 -0000
Date: Mon, 25 Mar 2019 20:31:42 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, Qian Cai <cai@lca.pw>,
	linux-mm@kvack.org, vbabka@suse.cz
Subject: Re: kernel BUG at include/linux/mm.h:1020!
Message-ID: <20190325203142.GJ3189@techsingularity.net>
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
 <CABXGCsMcXb_W-w0AA4ZFJ5aKNvSMwFn8oAMaFV7AMHgsH_UB7g@mail.gmail.com>
 <CABXGCsO+DoEu5KMW8bELCKahhfZ1XGJCMYJ3Nka8B0Xi0A=aKg@mail.gmail.com>
 <20190322111527.GG3189@techsingularity.net>
 <CABXGCsMG+oCTxiEv1vmiK0P+fvr7ZiuOsbX-GCE13gapcRi5-Q@mail.gmail.com>
 <20190325105856.GI3189@techsingularity.net>
 <CABXGCsMjY4uQ_xpOXZ93idyzTS5yR2k-ZQ2R2neOgm_hDxd7Og@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CABXGCsMjY4uQ_xpOXZ93idyzTS5yR2k-ZQ2R2neOgm_hDxd7Og@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 09:06:14PM +0500, Mikhail Gavrilov wrote:
> >         }
> > -
> > -       /* Leave no distance if no suitable block was reset */
> > -       if (reset_migrate >= reset_free) {
> > -               zone->compact_cached_migrate_pfn[0] = migrate_pfn;
> > -               zone->compact_cached_migrate_pfn[1] = migrate_pfn;
> > -               zone->compact_cached_free_pfn = free_pfn;
> > -       }
> >  }
> >
> >  void reset_isolation_suitable(pg_data_t *pgdat)
> >
> 
> Kernel panic are still occurs.
> 

Ok, thanks.

Trying one last time before putting together a debugging patch to see
exactly what PFNs are triggering as I still have not reproduced this on a
local machine. This is another replacement that is based on the assumption
that it's the free_pfn at the end of the zone that is triggering the
warning and it happens to be the case the end of a zone is aligned. Sorry
for the frustration with this and for persisting.

diff --git a/mm/compaction.c b/mm/compaction.c
index f171a83707ce..b4930bf93c8a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -242,6 +242,7 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
 							bool check_target)
 {
 	struct page *page = pfn_to_online_page(pfn);
+	struct page *block_page;
 	struct page *end_page;
 	unsigned long block_pfn;
 
@@ -267,20 +268,26 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
 	    get_pageblock_migratetype(page) != MIGRATE_MOVABLE)
 		return false;
 
+	/* Ensure the start of the pageblock or zone is online and valid */
+	block_pfn = pageblock_start_pfn(pfn);
+	block_page = pfn_to_online_page(max(block_pfn, zone->zone_start_pfn));
+	if (block_page) {
+		page = block_page;
+		pfn = block_pfn;
+	}
+
+	/* Ensure the end of the pageblock or zone is online and valid */
+	block_pfn += pageblock_nr_pages;
+	block_pfn = min(block_pfn, zone_end_pfn(zone) - 1);
+	end_page = pfn_to_online_page(block_pfn);
+	if (!end_page)
+		return false;
+
 	/*
 	 * Only clear the hint if a sample indicates there is either a
 	 * free page or an LRU page in the block. One or other condition
 	 * is necessary for the block to be a migration source/target.
 	 */
-	block_pfn = pageblock_start_pfn(pfn);
-	pfn = max(block_pfn, zone->zone_start_pfn);
-	page = pfn_to_page(pfn);
-	if (zone != page_zone(page))
-		return false;
-	pfn = block_pfn + pageblock_nr_pages;
-	pfn = min(pfn, zone_end_pfn(zone));
-	end_page = pfn_to_page(pfn);
-
 	do {
 		if (pfn_valid_within(pfn)) {
 			if (check_source && PageLRU(page)) {
@@ -309,7 +316,7 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
 static void __reset_isolation_suitable(struct zone *zone)
 {
 	unsigned long migrate_pfn = zone->zone_start_pfn;
-	unsigned long free_pfn = zone_end_pfn(zone);
+	unsigned long free_pfn = zone_end_pfn(zone) - 1;
 	unsigned long reset_migrate = free_pfn;
 	unsigned long reset_free = migrate_pfn;
 	bool source_set = false;



-- 
Mel Gorman
SUSE Labs

