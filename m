Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 327B0C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 07:33:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE7F02177E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 07:33:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE7F02177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F2748E0002; Tue, 29 Jan 2019 02:33:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77BB28E0001; Tue, 29 Jan 2019 02:33:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6450F8E0002; Tue, 29 Jan 2019 02:33:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9E38E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 02:33:38 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id m13so13691242pls.15
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 23:33:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PBNiN+7bZkqEptaRmsPd3lc5ddPmifnQ0l7PtW/87TY=;
        b=G5Gm95LAR0JcFfNPLExRw2OPeaK5UxZB1IE0k/3VKviRsPbQ9ngPaeL4qSTYTFPi8C
         Ilb3coVDjvUuIYlw8RvIKRGYgcPj1hfXdElv4zOmojztIIqp94BrPx5dkdvODsE/fs3o
         B8h3M3rEZZP9PdqP6fSs9A2hdwk2j3oMz124o2WMAK0z1Lg+qd2wnDN21LPSUQ2EWnwu
         f3s+RA9B81iX/ItnLQL3/IgUQYZ7EJx9vTvZR/pMY3lM2OvIPMN5bzgkqEETRE6N0Fks
         G0UQNvfyS8VzH/khRg2jMuiqCnG4y2P52ffJy8F2lOCdCE/s9d4mtGa/Fbj6GdXLUdrW
         6RHA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukcr9DNmqGSd8MPj3C9Tal1nJ2c9RXqJ98eADPKI6/Zd7+8tlQgC
	AE2AAiWyYLwlQD0chIbS/aQULQv/M4YXtwIgObP6htSJqiHrcVRzLLMEufpV9VGWjkepXHfdtP/
	+n+6R9FYMUSB+kp9df1tSI5R7huw+u8KiSyFFP2hlvaErl3EYMw2YRCVSKYeZnBk=
X-Received: by 2002:aa7:8758:: with SMTP id g24mr24594351pfo.250.1548747217797;
        Mon, 28 Jan 2019 23:33:37 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6Gi3r18hG3XKYr46gUXFEflAoZ0rOPuXztCmWAdmJXoz48eJOlS1xmB+TjpSfZU0mF7w4U
X-Received: by 2002:aa7:8758:: with SMTP id g24mr24594311pfo.250.1548747217106;
        Mon, 28 Jan 2019 23:33:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548747217; cv=none;
        d=google.com; s=arc-20160816;
        b=NdqWYcEi4vQIYVVO4MJXpZEfTZNVMH6MfvVeu8z2s2/RkaaM00sJ+7CtyXkTKm2Vu+
         NWe92KvX6vU6clDilaB62sb4DZl0PoygmwdproT7PadjtzJt2UQmYyD79AEdAQ55YstA
         0PWj/qvae56x9aNa5kCCA2O2gctK5mcmvJhqPHfgBCUcJmnWX7YVv7KUwERUNmMoW5QH
         mtCL4zqKp+gFzfF6aTqgokxZ4yAEwDEOEfe48WuMryF0uUmzVtLAgmKpMyv2MJAYCmLX
         LSWrkxzTGk5viPIroLFsjcyyDv6foxpyoZgYeFJvGI9mBNw3yZpMURPVCH3JUbftQ5OY
         AsAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PBNiN+7bZkqEptaRmsPd3lc5ddPmifnQ0l7PtW/87TY=;
        b=VapMifa/HAZnm4Rqi/ftK2WQLMECX2iHBdpUNEyrN9Ux4tHShXCeNwpk6CZbHvEnRM
         CoQeCJYaYGXoOMTEqb4Wxx6l43Y3u0l1R/DdpDPz2xAMxGHx0OIn64WoN+s+QEZtkJ8/
         2IsZdQ39/I/lPHlIAzwMxl39SbRdLIQZY60hbmaeXAhH6FMbkXqTSaPCgNt4yaaTgxfD
         YpmqhpWL7THNYZ/bfVJ2DKc46SgqQPcWhxqMCUCwYPgFZ5zoex75jih93pf0pg4EWPvM
         V/U3ECwGDC9NsdTIz/mh+6DtEzpMaue2jHM66vISfyJbE03YvLPCOVTNCEAJCac3138P
         aMRg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 2si31761060pgw.13.2019.01.28.23.33.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 23:33:37 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0B807AE60;
	Tue, 29 Jan 2019 07:33:34 +0000 (UTC)
Date: Tue, 29 Jan 2019 08:33:32 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>,
	David Hildenbrand <david@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm,memory_hotplug: Fix scan_movable_pages for gigantic
 hugepages
Message-ID: <20190129073332.GB18811@dhcp22.suse.cz>
References: <20190122154407.18417-1-osalvador@suse.de>
 <5368e2b4-5aca-40dd-fe18-67d861a04a29@redhat.com>
 <20190125075830.6mqw2io4rwz7wxx5@d104.suse.de>
 <20190128145309.c7dcf075b469d6a54694327d@linux-foundation.org>
 <20190128145617.069b3a5436fc7e34bdebb104@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128145617.069b3a5436fc7e34bdebb104@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 28-01-19 14:56:17, Andrew Morton wrote:
[...]
> --- a/mm/memory_hotplug.c~mmmemory_hotplug-fix-scan_movable_pages-for-gigantic-hugepages-fix
> +++ a/mm/memory_hotplug.c
> @@ -1305,28 +1305,27 @@ int test_pages_in_a_zone(unsigned long s
>  static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  {
>  	unsigned long pfn;
> -	struct page *page;
> +
>  	for (pfn = start; pfn < end; pfn++) {
> -		if (pfn_valid(pfn)) {
> -			page = pfn_to_page(pfn);
> -			if (PageLRU(page))
> -				return pfn;
> -			if (__PageMovable(page))
> -				return pfn;
> -			if (PageHuge(page)) {
> -				struct page *head = compound_head(page);
> +		struct page *page, *head;
> +		unsigned long skip;
>  
> -				if (hugepage_migration_supported(page_hstate(head)) &&
> -				    page_huge_active(head))
> -					return pfn;
> -				else {
> -					unsigned long skip;
> +		if (!pfn_valid(pfn))
> +			continue;
> +		page = pfn_to_page(pfn);
> +		if (PageLRU(page))
> +			return pfn;
> +		if (__PageMovable(page))
> +			return pfn;
>  
> -					skip = (1 << compound_order(head)) - (page - head);
> -					pfn += skip - 1;
> -				}
> -			}
> -		}
> +		if (!PageHuge(page))
> +			continue;
> +		head = compound_head(page);
> +		if (hugepage_migration_supported(page_hstate(head)) &&
> +		    page_huge_active(head))
> +			return pfn;
> +		skip = (1 << compound_order(head)) - (page - head);
> +		pfn += skip - 1;
>  	}
>  	return 0;
>  }
> _
> 

LGTM
-- 
Michal Hocko
SUSE Labs

