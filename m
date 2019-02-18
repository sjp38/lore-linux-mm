Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE4E3C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:06:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BE8C20C01
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:06:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BE8C20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FC1A8E0004; Mon, 18 Feb 2019 12:06:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 382AD8E0002; Mon, 18 Feb 2019 12:06:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 224568E0004; Mon, 18 Feb 2019 12:06:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B91B68E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 12:06:02 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id y91so7397878edy.21
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 09:06:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0EfH6/OKpVLKE1GqQnLiRuXeHikcAL2GqJlnk6PA4Qo=;
        b=VcDI+0pVfrDCzPAt2Byo3drF0DQg1S5u4srkqAE73AlOa5A7A5pbA7s2xrE/OBHsLP
         0v19Ykf+8Ita/XGp9F/6P9t+/NbMV6/1GE9DIiLicMNxAcHgtu++hUbjbi9z3IS4esaO
         1fT9+BEE8hG64GVul3F/fzsd8COZA0Q/VwkRO0vJqpGENyyI3/m7QU4fQ2y0haxHl6Z2
         CpVlCAiw7W90dCBIyXQ4k/aIJFKCRT/wWsDgd6DQlrZ0e+jXUnse85GFJ3q0SVT47FCf
         87KC+yWVYB7aaLaDg6gqkqDgvDV+MyCGJ2suKZsr+7XwyF38zhWuEeP1w/uKfy7VltGL
         aywA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZJ+r4D36oDJyeQFWPZGCzvaF54ugO9fjJbqytgFjSAKQ5yeQ47
	4SssuQ1z4hiX+4JyVRtBBBXbycABhRkgq5zi/vyNeLz8/xCxnieIk850BOl0RZAQMkcN3a+FHx+
	46Q2XLFptkvS7Zh2ViV1VkhZNz1H8xFfAOHeujQbfCvPyedjTgDouXuI537Mle2k=
X-Received: by 2002:a50:b32f:: with SMTP id q44mr19960086edd.70.1550509562302;
        Mon, 18 Feb 2019 09:06:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iap+dfeM8tBFMzxDIYjYkv4KHrAZUPaIVi1MEbQdUG3U/DJ3P/N8PJ6mHO6ABUZA0/BGfeT
X-Received: by 2002:a50:b32f:: with SMTP id q44mr19960020edd.70.1550509561258;
        Mon, 18 Feb 2019 09:06:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550509561; cv=none;
        d=google.com; s=arc-20160816;
        b=mYOvPVCQsVkaZf45XXI5wwZOTZ2HScBBi8iTUTnnZH6dgfe8m1GpR5W0G543l6D/Om
         uMRH79uznNMZr6S3We6c5EUcXBBl68PaqwbMZ/r6pJKUt6VfFJy0V94Pofrmw/TQspO5
         MaTTwhgSZ2MF0FdNCCTQMM/Ax0b729JRAy1YAm3CIx5jkhd2E08+rrJNpAOntFI4Bmca
         lqFA73J5tuBy9d7UFwjPlQpP55XyDXMAnCJQT4E7pl3sjkXmVy0Yk4JmU+iHuSUSNRfK
         +xSCrbcuXFuWtvrKcA2tQE+goyZ4cGdNHGshlZNL/1hYrfDtDcjsVUlHWRGfl3By8p9X
         CJgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0EfH6/OKpVLKE1GqQnLiRuXeHikcAL2GqJlnk6PA4Qo=;
        b=xG3+DZ6m3qFGMzTd+5irgnrdblnHgcObVWojfIVCcStFEiC1qPBPxjvl8hUgH80Gy0
         f5mEDYUTrTn8sfjAcdEMtr3w84LrErSjJDclfSufTt3KFsJ7GsGL3Bw/+dg3rI6+nhIU
         LNyhxIHeU5FTA/rJL/lfrAdPoMx7FAvx4/bfA6XdBRoOTLdQMYqVv8tKuJEzJZXtMnwX
         s8sLYk6FCLv0ovSnOtp1+L0b9pfDHBQaZ33c4HDo0iyT8HWYO1R0KiiJWO3KYQ2Bq7pT
         KxQhzEQ8BdnFWtdn30x2F2gxH5ObQUHs+Zknz5e6cO/4XdapSI7WhIAq+CS7LuoBE4RA
         MfBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si191396edc.154.2019.02.18.09.06.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 09:06:01 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7AA8EADD3;
	Mon, 18 Feb 2019 17:06:00 +0000 (UTC)
Date: Mon, 18 Feb 2019 18:05:58 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Rong Chen <rong.a.chen@intel.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	linux-kernel@vger.kernel.org,
	Linux Memory Management List <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>, LKP <lkp@01.org>,
	Oscar Salvador <osalvador@suse.de>
Subject: Re: [LKP] efad4e475c [ 40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
Message-ID: <20190218170558.GV4525@dhcp22.suse.cz>
References: <20190218052823.GH29177@shao2-debian>
 <20190218070844.GC4525@dhcp22.suse.cz>
 <20190218085510.GC7251@dhcp22.suse.cz>
 <4c75d424-2c51-0d7d-5c28-78c15600e93c@intel.com>
 <20190218103013.GK4525@dhcp22.suse.cz>
 <20190218140515.GF25446@rapoport-lnx>
 <20190218152050.GS4525@dhcp22.suse.cz>
 <20190218152213.GT4525@dhcp22.suse.cz>
 <20190218164813.GG25446@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218164813.GG25446@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 18-02-19 18:48:14, Mike Rapoport wrote:
> On Mon, Feb 18, 2019 at 04:22:13PM +0100, Michal Hocko wrote:
[...]
> > Thinking about it some more, is it possible that we are overflowing by 1
> > here?
> 
> Looks like that, the end_pfn is actually the first pfn in the next section.

Thanks for the confirmation. I guess it also exaplains why nobody has
noticed this off-by-one. Most people seem to use VMEMMAP SPARSE model
and we are safe there.

> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 124e794867c5..6618b9d3e53a 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -1234,10 +1234,10 @@ bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
> >  {
> >  	struct page *page = pfn_to_page(start_pfn);
> >  	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
> > -	struct page *end_page = pfn_to_page(end_pfn);
> > +	struct page *end_page = pfn_to_page(end_pfn - 1);
> >  
> >  	/* Check the starting page of each pageblock within the range */
> > -	for (; page < end_page; page = next_active_pageblock(page)) {
> > +	for (; page <= end_page; page = next_active_pageblock(page)) {
> >  		if (!is_pageblock_removable_nolock(page))
> >  			return false;
> >  		cond_resched();
> 
> Works with your fix, but I think mine is more intuitive ;-)

I would rather go and rework this to pfns. What about this instead.
Slightly larger but arguably cleared code?

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 124e794867c5..a799a0bdbf34 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1188,11 +1188,13 @@ static inline int pageblock_free(struct page *page)
 	return PageBuddy(page) && page_order(page) >= pageblock_order;
 }
 
-/* Return the start of the next active pageblock after a given page */
-static struct page *next_active_pageblock(struct page *page)
+/* Return the pfn of the start of the next active pageblock after a given pfn */
+static unsigned long next_active_pageblock(unsigned long pfn)
 {
+	struct page *page = pfn_to_page(pfn);
+
 	/* Ensure the starting page is pageblock-aligned */
-	BUG_ON(page_to_pfn(page) & (pageblock_nr_pages - 1));
+	BUG_ON(pfn & (pageblock_nr_pages - 1));
 
 	/* If the entire pageblock is free, move to the end of free page */
 	if (pageblock_free(page)) {
@@ -1200,16 +1202,16 @@ static struct page *next_active_pageblock(struct page *page)
 		/* be careful. we don't have locks, page_order can be changed.*/
 		order = page_order(page);
 		if ((order < MAX_ORDER) && (order >= pageblock_order))
-			return page + (1 << order);
+			return pfn + (1 << order);
 	}
 
-	return page + pageblock_nr_pages;
+	return pfn + pageblock_nr_pages;
 }
 
-static bool is_pageblock_removable_nolock(struct page *page)
+static bool is_pageblock_removable_nolock(unsigned long pfn)
 {
+	struct page *page = pfn_to_page(pfn);
 	struct zone *zone;
-	unsigned long pfn;
 
 	/*
 	 * We have to be careful here because we are iterating over memory
@@ -1232,13 +1234,14 @@ static bool is_pageblock_removable_nolock(struct page *page)
 /* Checks if this range of memory is likely to be hot-removable. */
 bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
 {
-	struct page *page = pfn_to_page(start_pfn);
-	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
-	struct page *end_page = pfn_to_page(end_pfn);
+	unsigned long end_pfn;
+
+	end_pfn = min(start_pfn + nr_pages,
+			zone_end_pfn(page_zone(pfn_to_page(start_pfn))));
 
 	/* Check the starting page of each pageblock within the range */
-	for (; page < end_page; page = next_active_pageblock(page)) {
-		if (!is_pageblock_removable_nolock(page))
+	for (; start_pfn < end_pfn; start_pfn = next_active_pageblock(start_pfn)) {
+		if (!is_pageblock_removable_nolock(start_pfn))
 			return false;
 		cond_resched();
 	}
-- 
Michal Hocko
SUSE Labs

