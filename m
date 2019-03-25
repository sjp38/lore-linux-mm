Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17B06C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 10:59:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6C8B2075E
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 10:59:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6C8B2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 619736B0007; Mon, 25 Mar 2019 06:59:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C9336B0008; Mon, 25 Mar 2019 06:59:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B9766B000A; Mon, 25 Mar 2019 06:59:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 00C096B0007
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 06:58:59 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 16so4718070wme.0
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 03:58:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=C+XkdW5UCbazRishbJTwKodvr/7TETLM5ifOVXZYhLQ=;
        b=fFf3o+mpdJdchYeQoDiXu3RzQEzB6XJghX/ee88gx5plC6VIl/G1akYJWSxxbP1+fi
         HuZHwwqmcbIlc2PhfHZo+SLJHxrHlmmYp1DJJYwPp9+FKoOj3YusVo8QOZ3UPVSI13ww
         NGDNLfDfh6H7yO7vZpjpicGatSUN2qj+D71N1VMg7MaOxo2OtqGlNN5wzTTpEIMl0gLq
         9rNH22p4f/IyFFVd+jLsJniFlhq6XCZZybl+JwXw10Y+DPWClslAhe+KLfvA4gsh6koi
         5EyxIzMxwJDvY6jO8k1szWg1Yj9ZQxrvvX4qRIFTik2m0RjOsmlRm8X2D2wH1p7vTZRy
         B/UA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAX4f51LTgo8iGQxV7CqokJwEgm1h1PuYqXBbl/pdos30lazPQay
	sRVjmawV8tVBS38zEPFUBvX5/MhHsTesoLWRcQ/IxQ42lEZuF8MSHQHeI+SifBxsO8Zax6Lgskq
	08HQjIzvxHYuwAdR+WqxKFAYZu3hDTleq82y1ryKSV7fZgM4eeHC0qUeM3QoKVyTRmg==
X-Received: by 2002:a7b:c086:: with SMTP id r6mr4792521wmh.123.1553511539448;
        Mon, 25 Mar 2019 03:58:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAqD+Kv3Sbheu25nMTD62hcljocziQRjLi+khCpiB/FJ4lHa/Sp5SN7fel5En+CoNpzmvB
X-Received: by 2002:a7b:c086:: with SMTP id r6mr4792482wmh.123.1553511538474;
        Mon, 25 Mar 2019 03:58:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553511538; cv=none;
        d=google.com; s=arc-20160816;
        b=wXAmNEUjDHwY2Zi2xS92RS2vWSoirT5qh8LiAb4XMCW6f9adOcy4ih+B7Gg/g5a7ok
         z3PM5kDPwAZd4+S5XTd/0hPBrEm70zuXhbUzpSf6a2j5zHsQExbADQ4K3ri4c3S4owMQ
         mqZRKNCL+m8SLPtha8qrN+5z4gbL3ilvfNNva7CwsUv+vFn8RC7t4JEg6AvOROur4Ew5
         RZ4C9NeMWp3hR9vK1uWufwD2ZH06YWT+oDEjVsyF7kg7Oybt7KfodAcWASkJtXmKI2/P
         XiDyjGTkgLCXWc/21a8J7FwF5nl+Vhp6QepNiXdB2qnEEP32FCzhFG6CfJYjjyExjxIv
         Zkkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=C+XkdW5UCbazRishbJTwKodvr/7TETLM5ifOVXZYhLQ=;
        b=DpkWMSIlsHKYsGdp+FWqE7u6AcqP5m+45LRtIpEjCSp9feKtS+k+qG7hHzQvxkFJ97
         WrE+lxGQ1jGKRpF1b7aJaC7GSnbHqRSkL8zX/c8PeBubYnea1o3iuuDeSsv2Uk2IV7RY
         ZHCvbDvln1qg6bdpB/Bc9kN92VVRhieBLDgoTm6Jr83QJbKLh6/48uESVTVnI4ny7HPs
         UwHtcRB0yL1NX1Km1ng0h2xjFz2mRbBuVqtbExNcqtcRc1YOUvojDQJIQLQBgwIGtNMA
         xdnN3sn4K4JF7jo/F6LlKD7S1eZUpinl61+SJAIOjOD+gyl4Z3gsbH2JJ5Q253ViberJ
         X37A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id v11si9875750wro.150.2019.03.25.03.58.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 03:58:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) client-ip=81.17.249.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.35 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id CF2C7989B8
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:58:57 +0000 (UTC)
Received: (qmail 1156 invoked from network); 25 Mar 2019 10:58:57 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 25 Mar 2019 10:58:57 -0000
Date: Mon, 25 Mar 2019 10:58:56 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, Qian Cai <cai@lca.pw>,
	linux-mm@kvack.org, vbabka@suse.cz
Subject: Re: kernel BUG at include/linux/mm.h:1020!
Message-ID: <20190325105856.GI3189@techsingularity.net>
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
 <CABXGCsMcXb_W-w0AA4ZFJ5aKNvSMwFn8oAMaFV7AMHgsH_UB7g@mail.gmail.com>
 <CABXGCsO+DoEu5KMW8bELCKahhfZ1XGJCMYJ3Nka8B0Xi0A=aKg@mail.gmail.com>
 <20190322111527.GG3189@techsingularity.net>
 <CABXGCsMG+oCTxiEv1vmiK0P+fvr7ZiuOsbX-GCE13gapcRi5-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CABXGCsMG+oCTxiEv1vmiK0P+fvr7ZiuOsbX-GCE13gapcRi5-Q@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 23, 2019 at 09:40:04AM +0500, Mikhail Gavrilov wrote:
> >         /*
> >          * Only clear the hint if a sample indicates there is either a
> >          * free page or an LRU page in the block. One or other condition
> >          * is necessary for the block to be a migration source/target.
> >          */
> > -       block_pfn = pageblock_start_pfn(pfn);
> > -       pfn = max(block_pfn, zone->zone_start_pfn);
> > -       page = pfn_to_page(pfn);
> > -       if (zone != page_zone(page))
> > -               return false;
> > -       pfn = block_pfn + pageblock_nr_pages;
> > -       pfn = min(pfn, zone_end_pfn(zone));
> > -       end_page = pfn_to_page(pfn);
> > -
> >         do {
> >                 if (pfn_valid_within(pfn)) {
> >                         if (check_source && PageLRU(page)) {
> 
> Unfortunately this patch didn't helps too.
> 
> kernel log: https://pastebin.com/RHhmXPM2
> 

Ok, it's somewhat of a pity that we don't know what PFN that page
corresponds to. Specifically it would be interesting to know if the PFN
corresponds to a memory hole as DMA32 on your machine has a number of
gaps. What I'm wondering is if the reinit fails to find good starting
points that it picks a PFN that corresponds to an uninitialised page and
trips up later.

Can you try again with this patch please? It replaces the failed patch
entirely.

Thanks.

diff --git a/mm/compaction.c b/mm/compaction.c
index f171a83707ce..caac4b07eb33 100644
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
+	block_pfn = min(block_pfn, zone_end_pfn(zone));
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
@@ -320,6 +327,16 @@ static void __reset_isolation_suitable(struct zone *zone)
 
 	zone->compact_blockskip_flush = false;
 
+
+	/*
+	 * Re-init the scanners and attempt to find a better starting
+	 * position below. This may result in redundant scanning if
+	 * a better position is not found but it avoids the corner
+	 * case whereby the cached PFNs are left in a memory hole with
+	 * no proper struct page backing it.
+	 */
+	reset_cached_positions(zone);
+
 	/*
 	 * Walk the zone and update pageblock skip information. Source looks
 	 * for PageLRU while target looks for PageBuddy. When the scanner
@@ -349,13 +366,6 @@ static void __reset_isolation_suitable(struct zone *zone)
 			zone->compact_cached_free_pfn = reset_free;
 		}
 	}
-
-	/* Leave no distance if no suitable block was reset */
-	if (reset_migrate >= reset_free) {
-		zone->compact_cached_migrate_pfn[0] = migrate_pfn;
-		zone->compact_cached_migrate_pfn[1] = migrate_pfn;
-		zone->compact_cached_free_pfn = free_pfn;
-	}
 }
 
 void reset_isolation_suitable(pg_data_t *pgdat)

-- 
Mel Gorman
SUSE Labs

