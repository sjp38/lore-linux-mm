Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED1D4C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:21:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF2F22184A
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:21:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF2F22184A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D2F88E0004; Thu, 28 Feb 2019 04:21:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45B448E0001; Thu, 28 Feb 2019 04:21:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 325488E0004; Thu, 28 Feb 2019 04:21:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE8B08E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:21:56 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id f2so8084128edm.18
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 01:21:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yV5gV2OWN9iUs3sh4+mN8BswOlVUgShsybwMljzP2+I=;
        b=tNAZzz41MJ0ZaxGbv3mANR1l6a8uzDbwtMafwLGUzprQl3/a51t/9XrdOcSxL2UM9j
         YXITrEpb9t5KZ2K/MGV1LpT7LXWaGIifFoelwl2dvg9antocNprj1E86p0W2q7RS2A3x
         j6+w1FIc8s9y2xFOFnAcCtySKULIsMSlblZqKR44P7zlHavvKo/VYdQEquZD+ohuuFLU
         UBWhTbMgjTkUOvjHYh0u1oc4Y46XFbU5gIUAjuyI4yy3NEMmHSvo6wwsS8hHFBVVIAIS
         W1L4ZylBEbKMCxigCKGLhAgXqSwVDPHm51mlEHGbFeN2tWN1GxmzCl6XThIh0FcMUBkr
         SMUQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubYjR07IQtF8e/RZ8gXVym/1V4VBlx7Ym1NYtU1B2/1QqulrZTy
	hwKlsGYyEMqkUqqHU66LF9lWnMB6ttVDbIPrImAkmIt5nFNMUYI38I+uAURPsdRj+RcIKpnYsfC
	qVh/TfPVKSvIg7LU0CpXYYHZJ+54mrl7Apyq5DkzcSf7oUqbIuYWAsp3GnAWkkn0=
X-Received: by 2002:a17:906:4f12:: with SMTP id t18mr4559199eju.50.1551345716424;
        Thu, 28 Feb 2019 01:21:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZvff0Wdbey3YQA4OHSnfLnV+xbEd1WdRx5O+1S2zpQI351CZGb4jlhp5umcneSZ23ij+We
X-Received: by 2002:a17:906:4f12:: with SMTP id t18mr4559158eju.50.1551345715588;
        Thu, 28 Feb 2019 01:21:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551345715; cv=none;
        d=google.com; s=arc-20160816;
        b=gmEChRr58IctOXt+ka2rvCgvsXoP9JPcwrvllLRDPWYpeayFKJkkzpphm6wrDNbW/r
         WSWJlbEKQIuyRofWTI5XIjJAr9aHhcxdpkxxN8r1K8ubjWh9rTYyTgQNR0aK7arEDHQ9
         /x7XOijo5XOkj7cDUdF+e5jh60JQpDkEeqv+chFxK5uCvHlOPr37vnVd0mmSHPAWxj/y
         oFv1uuRfgLdiUkshe0WT3kTy6TKdEvkFWigVXKWHISHkqq+LbAT3VcZdac66cx893lua
         Mq9qTxFjfrGdoZwGoMYmp5xtersWSRVGWPjzAo5TbBiQRh9BrrJ61UKaEcG0h94ySI1e
         bt+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yV5gV2OWN9iUs3sh4+mN8BswOlVUgShsybwMljzP2+I=;
        b=ikkS7ruF1BJMI/yOAeimSUJVyiQZzdoO8fdh5l4Ai1rW0e9d3mIUhAxIJ1QwBXRuI2
         I/K2xAkEmToTITZjwIFePVimvrtpHB4rNGsq8mJA0wHMh2ITw91j1+pE7gIpYpJA8Dp3
         8uL0QwyIPM0fdJNkP1OluVEn4cA32T5qjjMDQZZzh35Bfp1yvsLvcEL/WaPydnibsuOh
         ja7hvQK2HZuzdaK/LNs+2VXSBzK+KcUhMcygw51KTDVLOKmImDkhdDvgv90jTErzyV6o
         PLw0wgmimMpFhkOzx2nFboNiezcf15Ad2gS0QRT6XY6coPwWyvtMSkm64Liz5w1McBHS
         XdEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si1230107edu.318.2019.02.28.01.21.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 01:21:55 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2EA8BAC5A;
	Thu, 28 Feb 2019 09:21:55 +0000 (UTC)
Date: Thu, 28 Feb 2019 10:21:54 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, david@redhat.com,
	mike.kravetz@oracle.com
Subject: Re: [RFC PATCH] mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
Message-ID: <20190228092154.GV10588@dhcp22.suse.cz>
References: <20190221094212.16906-1-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190221094212.16906-1-osalvador@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 21-02-19 10:42:12, Oscar Salvador wrote:
[...]
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index d5f7afda67db..04f6695b648c 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1337,8 +1337,7 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  		if (!PageHuge(page))
>  			continue;
>  		head = compound_head(page);
> -		if (hugepage_migration_supported(page_hstate(head)) &&
> -		    page_huge_active(head))
> +		if (page_huge_active(head))
>  			return pfn;
>  		skip = (1 << compound_order(head)) - (page - head);
>  		pfn += skip - 1;

Is this part correct? Say we have a gigantic page which is migrateable.
Now scan_movable_pages would skip it and we will not migrate it, no?

> @@ -1378,10 +1377,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  
>  		if (PageHuge(page)) {
>  			struct page *head = compound_head(page);
> -			if (compound_order(head) > PFN_SECTION_SHIFT) {
> -				ret = -EBUSY;
> -				break;
> -			}
>  			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
>  			isolate_huge_page(head, &source);
>  			continue;

I think it would be much easier to have only this check removed in this
patch. Because it is obviously bogus and wrong as well. The other check
might be considered in a separate patch.
-- 
Michal Hocko
SUSE Labs

