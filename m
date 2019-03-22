Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 568C8C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 11:15:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A184B218A2
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 11:15:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A184B218A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EDA76B0005; Fri, 22 Mar 2019 07:15:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09E626B0008; Fri, 22 Mar 2019 07:15:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF5EB6B000A; Fri, 22 Mar 2019 07:15:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B986F6B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 07:15:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w27so782532edb.13
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 04:15:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CHzkP0Dpn4nGmuGDmZqzQ6Q+FhtuDdep+zRr8TbMsqs=;
        b=cxxMMoI1lOHo085vL4fq0Gty3lXpF5uwFsXy/B7E4xDQLg2fY6IhiYuoebA8490ZKB
         IgtMdf17EA2CBY0ntjevsGbL9I3yzDCMUx4HQErUVvt3c1Ml0+xMRFURGEj8bW2K9MRI
         9eke6WiArSPz/ZwXGo+IbC6TLJE+RbEk9TIQlXEDC9yfuDy+WHR5Zft/hExgm4iaYRxU
         XGn/o97RJpjUnsm0xO4elSJM64Yra/Btl5e0JvTbG7oRtB8Prv6esf9ZOf5C6s/nv7pN
         6ceiOnNJRlX78QH42wnK681QF6sLFHjdCwyU08qbiYAJg4cKaWiJpejLE8u1Tqg4Ghes
         n37A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAV/MjXF73eltxXrLlsPQf3xydH+1y4S68NmHpmW9ZzQd94WQ64C
	kSGTCl9jZKFFJgS8S9D7hB8BhDrKZeA5kP7dEehrRp4Rbe0UqZ/7mDsx0oxFgQuViLJ9PEm+nZe
	uQgcLeLuLpw5XNpZM0YD5xWfyN/OESc2Al2o7WDiLhAMScVn1RPGUC+4ldy3R7j6P9w==
X-Received: by 2002:a17:906:3482:: with SMTP id g2mr5253617ejb.214.1553253331310;
        Fri, 22 Mar 2019 04:15:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZE7sJlbkONJ0VJ9ZWsTpTXxzHMHuHKuk9n2P/cHZoiYoaX+2sxpWfWpFAsikzJ6xL3qIj
X-Received: by 2002:a17:906:3482:: with SMTP id g2mr5253554ejb.214.1553253330217;
        Fri, 22 Mar 2019 04:15:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553253330; cv=none;
        d=google.com; s=arc-20160816;
        b=0rPl1589N28Hv7J4uWpDHxjIsfTdgm6ngD6sgvtL0JYhBIlHN8k6Hbf1C0KW7bo0CN
         qthSuIcwzCO0C/SHt1oj8PaNnDOBNZeW96Qwh6qJc6igFdLgtrp0/Qh+cCGrZWap1kx2
         nIQn05kExoqWo/NDd3WZnmhscJgWgGSIs53ZqS/3urCejESUhIphdodZb5R6xZ2kqQQe
         6exUSNyzvnCa+E3jTRIIwNDE7F70LuGaXMKaAYIixO1y+nRAOlehmNa6H2+aor15TIGT
         B4KtsfInAvXPlG6bWC18SMbWHZbfugHF87d5+txxUsBZoJ8lyVSF6HByPnPcnW1L4jiq
         mz6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CHzkP0Dpn4nGmuGDmZqzQ6Q+FhtuDdep+zRr8TbMsqs=;
        b=CccD9j28aSQGHnR/+YK2nrgUU1gJVgQJBDCOf7siD3XeK40Vg1x92sX0oGjlMqAWrn
         Da7u+vJGwYmrS9LRru0JOb1ivdFsHxcfKZfz8oBeTewj6jhJkByAqIy8H4O1iF3NKt5K
         7cyzLwORB7sjDA5IUU1rMfUWsLew4ecenfJq7HbRMZ/wypTvQWUb2lov96deskh1bbDS
         2gkPvH1yn2Kw3pFshxJTbZrJaiCsSklPYceubtdmBO9JU/FiQLT7M84t71tATAqyv+PN
         n5AnQlIBy5H/yqMPN0hzEZ7Stmdh351xwPvdwJlQczR4SMGo0qfp8b3/RNlPCCwGw+F/
         Cdmw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id t26si246516ejf.25.2019.03.22.04.15.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 04:15:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) client-ip=46.22.139.233;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id 967B61C2EBE
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 11:15:29 +0000 (GMT)
Received: (qmail 14420 invoked from network); 22 Mar 2019 11:15:29 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 22 Mar 2019 11:15:29 -0000
Date: Fri, 22 Mar 2019 11:15:27 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, cai@lca.pw,
	linux-mm@kvack.org, vbabka@suse.cz
Subject: Re: kernel BUG at include/linux/mm.h:1020!
Message-ID: <20190322111527.GG3189@techsingularity.net>
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
 <CABXGCsMcXb_W-w0AA4ZFJ5aKNvSMwFn8oAMaFV7AMHgsH_UB7g@mail.gmail.com>
 <CABXGCsO+DoEu5KMW8bELCKahhfZ1XGJCMYJ3Nka8B0Xi0A=aKg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CABXGCsO+DoEu5KMW8bELCKahhfZ1XGJCMYJ3Nka8B0Xi0A=aKg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 10:39:10AM +0500, Mikhail Gavrilov wrote:
> > # first bad commit: [e332f741a8dd1ec9a6dc8aa997296ecbfe64323e] mm,
> > compaction: be selective about what pageblocks to clear skip hints
> >
> > Also I see that two patches already proposed for fixing this issue.
> > [1] https://patchwork.kernel.org/patch/10862267/
> > [2] https://patchwork.kernel.org/patch/10862519/
> >
> > If I understand correctly, it is enough to apply only the second patch [2].
> >
> 
> I am right now tested the patch [1] and can said that unfortunately it
> not fix my issue.
> [1] https://patchwork.kernel.org/patch/10862519/
> 

Build-tested only but can you try this?

diff --git a/mm/compaction.c b/mm/compaction.c
index f171a83707ce..ba3afcc00d50 100644
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

