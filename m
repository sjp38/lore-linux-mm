Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53C42C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:21:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 141DC222B1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:21:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 141DC222B1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B64B98E0002; Wed, 13 Feb 2019 08:21:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B15128E0001; Wed, 13 Feb 2019 08:21:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DD438E0002; Wed, 13 Feb 2019 08:21:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 434328E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:21:05 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id s50so995914edd.11
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:21:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=g+KJFui53JWr7Z61LvQD0h0WE0wlBSAWNgK/RkBLveg=;
        b=QAYllYPifLjzw+CCNMNMhYONTXkxQR9eHcn1ZxMs5foSG25P8pTi/Vey0F/5kbKf+6
         4XcMYkMA8jdnvwmUkrVMRDT/S0FANnZ5uW6y60HDkbPmuh4F7SxF9vPGcmuQEqqM6dq2
         s5rKngU1aXU3wOG2AC9Zp+7bpjQyVxndxk7GEurmjl5DB6cPG+mYJgF9G02FQJEdz6Bf
         cQUqWI+jcbZkPvBHrEQSLRaHJ2saB76sA3gCksZKNFLwoqmmZodf0HPD1tjmV3VnNPfn
         PGB3nsGFncikMxgTb8Hrkf+Smwkk6uu0Siy7gVUZFQOLUNKnBunlDE3iZqrTTKD8FKVJ
         ZPow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: AHQUAuZofxa9fTH5wC//TZo9jj0OW3YouY8U2gYxD3JEydyZY9zmg+NS
	XMN6I9SjHC7KCiwmwsqcqs/P1ZPUeBqtv2Tpa7CnbFKqTk6xKrPq74Q9bGu7MdaG2mle44XuFoa
	UXAsLaAF/n++SDaztxdx0mlUmGPel5u5n9qmW4VyOPLaqSaWJAQHyFE4ZmZX3SVgMKA==
X-Received: by 2002:a50:ee94:: with SMTP id f20mr398826edr.240.1550064064839;
        Wed, 13 Feb 2019 05:21:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZeK9Xkh/A0RDkuZtK/rmakBFFUqAx0aISUsqVidWx0akpJiPNq+Lho8aaPuBiRgPWRfEoU
X-Received: by 2002:a50:ee94:: with SMTP id f20mr398786edr.240.1550064064146;
        Wed, 13 Feb 2019 05:21:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550064064; cv=none;
        d=google.com; s=arc-20160816;
        b=J/oAtqokifDFVPMOPposNl3hIfqXKInp15g+mufsukF522hKyRkUJzEFU8xGYg5OwY
         nr6n3HlijQEXKdepNP5c/YRi08HHVIYb/GVHASLoZ2on6KbvxLCpRqHA0CXZBf3er8Jq
         Fxegxm5fj3E/74jtAPV5843GYDMGNX7R+CIm946JMObnFRgk0c18BRS3nyd1g652lPvu
         /HKDsqJ1PgWDb/FjzWmf4eAVsDGSbJzI2IbiAA+bGIPr8qN4mYQt7lNyh0I3W9JFRLNC
         CqzKiEq+7ZFU9uXqWMDJjUE3gKvjNC9mk77FOy+DlO0C8IzOvxgAjM61LAC2eXk9womg
         tFKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=g+KJFui53JWr7Z61LvQD0h0WE0wlBSAWNgK/RkBLveg=;
        b=rEnciwjAdvY09HmKxEra1w4aXhVPp4rKqVSiuc4m6zplj9c4B3cfp6t5bweYtLZV5d
         s5eqJNozIA1i+oHj7YSpU7m0DRmskQvyKSRgOvyx8mJbPDoP4QC0faBpw0jaXy3TAKNr
         RCICLvj1fS3G/SL04RXNQM5jc6oXPjjnB+AN8fxTRYyxGNF5DcUnSarXkkbPd1eRC+Tg
         UUnH8ciTQvYkDScEfFFYm81k1Uid6jU4W3guhWHuCMMcAOCcpCgLD9kMb+pb9vb8Ie/z
         T+5gJIe0JZ+TOgosHJpx3ielUZFTkQ4zaTGoHMpFVX+6B2bWCvtJ9exW23mH0pRwOJHx
         /GEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z23si41601eji.328.2019.02.13.05.21.03
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 05:21:04 -0800 (PST)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 134E480D;
	Wed, 13 Feb 2019 05:21:03 -0800 (PST)
Received: from brain-police (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 59A333F557;
	Wed, 13 Feb 2019 05:21:00 -0800 (PST)
Date: Wed, 13 Feb 2019 13:20:57 +0000
From: Will Deacon <will.deacon@arm.com>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Yury Norov <yury.norov@gmail.com>, Vlastimil Babka <vbabka@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	David Rientjes <rientjes@google.com>,
	Michal Hocko <mhocko@kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] mm, page_alloc: Fix a division by zero error when
 boosting watermarks
Message-ID: <20190213132056.GE5875@brain-police>
References: <20190213131923.GQ9565@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213131923.GQ9565@techsingularity.net>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 01:19:23PM +0000, Mel Gorman wrote:
> Yury Norov reported that an arm64 KVM instance could not boot since after
> v5.0-rc1 and could addressed by reverting the patches
> 
> 1c30844d2dfe272d58c ("mm: reclaim small amounts of memory when an external
> 73444bc4d8f92e46a20 ("mm, page_alloc: do not wake kswapd with zone lock held")
> 
> The problem is that a division by zero error is possible if boosting occurs
> either very early in boot or if the high watermark is very small. This
> patch checks for the conditions and avoids boosting in those cases.
> 
> Fixes: 1c30844d2dfe ("mm: reclaim small amounts of memory when an external fragmentation event occurs")
> Reported-and-tested-by: Yury Norov <yury.norov@gmail.com>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/page_alloc.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d295c9bc01a8..ae7e4ba5b9f5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2170,6 +2170,11 @@ static inline void boost_watermark(struct zone *zone)
>  
>  	max_boost = mult_frac(zone->_watermark[WMARK_HIGH],
>  			watermark_boost_factor, 10000);
> +
> +	/* high watermark be be uninitialised or very small */
> +	if (!max_boost)
> +		return;
> +
>  	max_boost = max(pageblock_nr_pages, max_boost);
>  
>  	zone->watermark_boost = min(zone->watermark_boost + pageblock_nr_pages,

I can confirm that this also allows my KVM guest to boot:

Tested-by: Will Deacon <will.deacon@arm.com>

Will

