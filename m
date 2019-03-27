Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16214C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 12:45:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA0E12087C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 12:45:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA0E12087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 563046B000A; Wed, 27 Mar 2019 08:45:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EBA46B000C; Wed, 27 Mar 2019 08:45:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38D3A6B000D; Wed, 27 Mar 2019 08:45:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D96076B000A
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 08:45:23 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id j3so3572482edb.14
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 05:45:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AYL1l5IOD+/pDrGz8VKfZiBT+nX2aSOsCkqW3uvrhcI=;
        b=C1YEZRNEzLcW78I9GN39hJA4YOuxg5dzbjxP5h+8MjIXPhBpwsqDecC7R/sCXjMU9u
         3F7XpnlG/7FvSbLVtPFgbSucOyYb2vD3lsxeTRlstd+PKcU+XYpXKY9UJSQo5IHDobOA
         orvkz0R1iA69jhY0OEVD9bj5m0dGkSJrYyoitCGBk8rjdfznyHVMbm98es0O76z6Aoso
         p7QcK7ti+u3fVHCSJIwRhHeV7hhYOgAwZtI79frDQ10A8AJv7Nanzom5GWuLOy7q0pVf
         tQ7irpcWkeM3uWAuuLyReY+LJlbJux7zkB2F0BpM0da1zi/x7q6taf70L3nVoGRFAT3y
         kjMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.245 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAUgtOmz1GLMjPY0OD8sUVhd2TZaQVImUd/5aY6nTKUn37rrYIe0
	0OKqeeM2f6iu+OlEqzWBsyWefAdRo4qP3+8VVJ5zXanSiodH+PPLLTcONtLE9fA2m44MezR/rOe
	CLxWQqp6lwI4dpGVelac1yQyQeeNsn6zPdxjNUu4xPtGW+vOEiwV+Es8rfyEciyQQzQ==
X-Received: by 2002:a50:91d3:: with SMTP id h19mr24493593eda.218.1553690723295;
        Wed, 27 Mar 2019 05:45:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2E7D1zwkdmsBsqTUwVZOIo2typs9m6ArugfcHrGIbcFdTUP+wCRbZ3XX1zeDdBkMjB8oP
X-Received: by 2002:a50:91d3:: with SMTP id h19mr24493547eda.218.1553690722441;
        Wed, 27 Mar 2019 05:45:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553690722; cv=none;
        d=google.com; s=arc-20160816;
        b=wVIv34NUJ8kxpObYgmTSpYQxkF5gAQi4OypPu8hu8xUpivaMwsLq1HNasSnaBmM0fX
         30eByWZtVUkIhLCj/FVqjY6ws6gJy4bhF1yyPZGBLKzeVSN80e8Tl+QRukiaotfcjF+C
         EOU951CKmLvzinAphd+QUGjEIYokjvvkvKhXVz65GTuDrpUpiY1lThPD3mHdb2HJbzH2
         /K6zMADUEpjkRBxRJn6mHONlLTChRTQNsASspWDrK0S9eFCZwwg9b7eBmuM0bAlU4cAy
         lUvKYQgRe4jOOaTEovTBzB0t6KV5kwHBvXdM9BAi5cretYZEmD04MVV0mtWwqDVl+OrC
         /spA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AYL1l5IOD+/pDrGz8VKfZiBT+nX2aSOsCkqW3uvrhcI=;
        b=A9VhVw5PiUL698INyPyPkRiC2dBpRp/S39ZFrOfHBNYXzshE9srGx/FcsWqTHSyMeQ
         ZAIEzckWOZ6XGWLRIkaMDA8Io0HZ7OPmL73cqMGPm8LHDUwV7/iiiNjS5bwXt4vWgCSy
         KEASk3KP3FTCZ8kCYafMjMS+zGCnoOLlLIJPN0Ek7XRnMc/fsoCvdL1AkW9bMHH1K2Cb
         Wn86TOJ1U+Zj6LTQNOZYQvFbw9PjiqjBbLm3lRKxBbR+zlA/6Wmr0Awmmy8CHmIcPw5A
         B0XF+8EIE9bux37XuRIOsZS85o2FPwadYpiUBNI9lkZ2DB5QG25SGy0D6wT/U5wRZ/cz
         vZJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.245 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp18.blacknight.com (outbound-smtp18.blacknight.com. [46.22.139.245])
        by mx.google.com with ESMTPS id t10si3398034eju.172.2019.03.27.05.45.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 05:45:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.245 as permitted sender) client-ip=46.22.139.245;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.245 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp18.blacknight.com (Postfix) with ESMTPS id 0685F1C2D40
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 12:45:22 +0000 (GMT)
Received: (qmail 24906 invoked from network); 27 Mar 2019 12:45:21 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 27 Mar 2019 12:45:21 -0000
Date: Wed, 27 Mar 2019 12:45:20 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>, Qian Cai <cai@lca.pw>,
	linux-mm@kvack.org, vbabka@suse.cz, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Correct zone boundary handling when resetting pageblock
 skip hints
Message-ID: <20190327124520.GN3189@techsingularity.net>
References: <20190327085424.GL3189@techsingularity.net>
 <084b92cd-94e9-f8e5-cce1-862d984c8eac@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <084b92cd-94e9-f8e5-cce1-862d984c8eac@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 27, 2019 at 05:47:06PM +0530, Anshuman Khandual wrote:
> > @@ -267,20 +268,26 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
> >  	    get_pageblock_migratetype(page) != MIGRATE_MOVABLE)
> >  		return false;
> >  
> > +	/* Ensure the start of the pageblock or zone is online and valid */
> > +	block_pfn = pageblock_start_pfn(pfn);
> > +	block_page = pfn_to_online_page(max(block_pfn, zone->zone_start_pfn));
> > +	if (block_page) {
> > +		page = block_page;
> > +		pfn = block_pfn;
> > +	}
> > +
> > +	/* Ensure the end of the pageblock or zone is online and valid */
> > +	block_pfn += pageblock_nr_pages;
> > +	block_pfn = min(block_pfn, zone_end_pfn(zone) - 1);
> > +	end_page = pfn_to_online_page(block_pfn);
> > +	if (!end_page)
> > +		return false;
> 
> Should not we check zone against page_zone() from both start and end page here.

The lower address has the max(block_pfn, zone->zone_start_pfn) and the
upper address has the min(block_pfn, zone_end_pfn(zone) - 1) check to
keep the PFN within the zone boundary.

-- 
Mel Gorman
SUSE Labs

