Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79CA2C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 09:42:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CD1520850
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 09:42:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CD1520850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 064876B0003; Thu, 21 Mar 2019 05:42:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F30AF6B0006; Thu, 21 Mar 2019 05:42:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD2D96B0007; Thu, 21 Mar 2019 05:42:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 82DA96B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 05:42:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o9so1977944edh.10
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 02:42:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ygxDCCfe8fc+VcNrxPZyO4/ItFDOXjtDmIcbVUjZXhU=;
        b=TgjlxH3TPgPi3eK2Qb6rhX0ayZYehhaQtu2zcBBkGE6HmajQjYpz4Z44EXiVB9ozM1
         +Rskyunq3keKo5BcO68VwQyiBSPlhgbzU7mzRgkLO3QQ6bgYWoMIZejLXyh7Rv21basP
         MEbblKm7AV5sMq3fILbWex2gPJFUlOXbRoiEdldEBZ2yc6OWkjs+RCQQjRo6YrWolRyO
         lSe4IJbh9Nt0QGl6KWvg6iP2ySumVE46K1SknmJbK1Syqvm9u/1kzJCfVCSPs1xEJGvj
         5hCXRGOLHCKC+5Ik4vLFLUVOvudsrv1yyreBQ6/5rfdoWFEr0dDpocKCB2EpRMlnIdoC
         cKJw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVhcGV2zX4YhDWt6Td94aJ/o7Cl4SEKKWDh9d5jRtixfubxy8Um
	ROmH7XMK6PrAVZmLd2lM8Sdq5J2d178QaJvCfH/lQ5p/nwzq1TBLRl4Zj+RXWLJ6fatFoZpx6Lg
	DTXAvsTv6If1s8GKqNsuGFTPh58CYAo1cO9uLV/YC/R9w57YtS90scre9nilYPGf9vQ==
X-Received: by 2002:a50:bacc:: with SMTP id x70mr1787105ede.211.1553161362091;
        Thu, 21 Mar 2019 02:42:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyYmfSRHTl5wEpFp1hyhPoFWF7U11K/ICI6r5iycLAFn8v5r+hahTZrMLyzRbwlHM4RmOC
X-Received: by 2002:a50:bacc:: with SMTP id x70mr1787059ede.211.1553161361173;
        Thu, 21 Mar 2019 02:42:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553161361; cv=none;
        d=google.com; s=arc-20160816;
        b=HlEy9xmfWRY4dB7uOWK5BjVIW8nZeVcOxYxIQ/IeAP6lNzTeediyPmDGthBPe/9Vb9
         JBOdCMf2PgOhV+t1KrZX3LYWYeg/nIZK76UYO4GF0EOXXV9X7fQUAD/CCN1W9PKhf9h6
         keNUIj3a0MkJ/CQXL0Vb9+gr7fIUVgSc7USRCqLQd1YXuT+FVBgwYJp3QOlELnoDSAUS
         rlSucf0U90tK12OE4TEtY8RHDF4wHLae0Y9Xmg569N5h80P6UOu5qiBvonmnk/E7pJ/h
         W5ebPcKWRKyQ7VegqZ+cUY4RZoTh/25XwrMovqn2iy8m38YodkaTeJmUURGpOQXbZJUG
         dSNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ygxDCCfe8fc+VcNrxPZyO4/ItFDOXjtDmIcbVUjZXhU=;
        b=ijrkVayfpgSfgufSVgWXfNRT7TV8rRlwRuyQBUUX/rXkTYWQZjK01h3z5oIYszO/vr
         NP3gv1BYCxOHP84NMzSB74EpbLssqtM79N7NKilehev8SMS+RY5qwLvL1O2YSypgaBKw
         CHxU+i2VyrM9MBxoB6p2elyZUInIUd0v/DrDzPJUmZwImP4kVYSDHYezHtMPhaVuKlNk
         5d8EMz1f1OSxqe3M3GN/KcMRFEYP6vBORBjV5MFx3ObHhazK6PSUOK0oCsmLInj9+NNp
         Yk0O2tyC1Q2/Y9H3Hw3FMu0scDgclmc8G7Yi17HwqVXgTRvGDeINzSTK5kNdidFGvhy8
         uong==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id w18si1507767ejf.297.2019.03.21.02.42.40
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 02:42:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 462B4464A; Thu, 21 Mar 2019 10:42:40 +0100 (CET)
Date: Thu, 21 Mar 2019 10:42:40 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	mike.kravetz@oracle.com, zi.yan@cs.rutgers.edu, mhocko@suse.com,
	akpm@linux-foundation.org
Subject: Re: [PATCH] mm/isolation: Remove redundant pfn_valid_within() in
 __first_valid_page()
Message-ID: <20190321094237.onu3kar2ez7xv5wj@d104.suse.de>
References: <1553141595-26907-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1553141595-26907-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 09:43:15AM +0530, Anshuman Khandual wrote:
> pfn_valid_within() calls pfn_valid() when CONFIG_HOLES_IN_ZONE making it
> redundant for both definitions (w/wo CONFIG_MEMORY_HOTPLUG) of the helper
> pfn_to_online_page() which either calls pfn_valid() or pfn_valid_within().
> pfn_valid_within() being 1 when !CONFIG_HOLES_IN_ZONE is irrelevant either
> way. This does not change functionality.
> 
> Fixes: 2ce13640b3f4 ("mm: __first_valid_page skip over offline pages")
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

About the "Fixes:" tag issue, I agree with Michal that the code is not
really broken, but perhaps "suboptimal" depending on how much can affect
performance on those systems where pfn_valid_within() is more complicated than
simple returning true.

I see that on arm64, that calls memblock_is_map_memory()->memblock_search(),
to trigger a search for the region containing the address, so I guess it
is an expensive operation.

Depending on how much time we can shave, it might be worth to have the tag
Fixes, but the removal of the code is fine anyway, so:

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
>  mm/page_isolation.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index ce323e56b34d..d9b02bb13d60 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -150,8 +150,6 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
>  	for (i = 0; i < nr_pages; i++) {
>  		struct page *page;
>  
> -		if (!pfn_valid_within(pfn + i))
> -			continue;
>  		page = pfn_to_online_page(pfn + i);
>  		if (!page)
>  			continue;
> -- 
> 2.20.1
> 

-- 
Oscar Salvador
SUSE L3

