Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85F13C4649A
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 07:59:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B744218BB
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 07:59:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B744218BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A54236B0003; Fri,  5 Jul 2019 03:59:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A04228E0003; Fri,  5 Jul 2019 03:59:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CC998E0001; Fri,  5 Jul 2019 03:59:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA506B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 03:59:09 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f19so5143329edv.16
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 00:59:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9JuFbAzc1QgOVMLlizNhXHxR+tQzDg00DTVbe/YAJBA=;
        b=fgWKrxTdoiL8EaTZXaFhUlzyNGl1+1R+3JVO3PCh3wrqzRuPuPmaXCUhePzvTAJjel
         PQIg4P2yP1scLFxEExMtodRSTbHCocUM0M6+ORu7j0kIagnQp2i3pil7PzHuJ41oTWFh
         q4jTVe27wO3CXhxmXIy0dHXflJDGmlU0mbq6pRmTNZ+SHFOC4kUG65+uJ2aWNmVS05Y2
         YCRyR9tVJNCpXNfHUip+ZUG5vdP4EuB9im52EAyP/6d2tn5KFJGfWt2bbm62podmf5AW
         VDlcowizb3u7kWSp5d8Ae16bvYwWb+lKgglgui1X1vP2S6dVWFkFEohnXQZSEGhwWdUz
         tMFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUCBj4fTqC+z7nkmrnyEaLu0Gp6vAI02lSOZ1blRCPoTcUm/AtB
	WpJLqtM1yO8juC/aOLqJqMrzjE7CVH89Mqf/KhrYJlAJl5nZIUc8uPKYxMQ81J5YRwI+AG/m2Zj
	LPITQqnJ+/hU3fi9GpRdMX/bHRrrOy4uqajbqQBtev8RHqSxVZG/1FseRAcXkqcXOnQ==
X-Received: by 2002:a17:906:4a10:: with SMTP id w16mr2142402eju.299.1562313548716;
        Fri, 05 Jul 2019 00:59:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuvuTVSBG/Amas3m3OUX5uCI3YO1id/esIV9LUuOhw+Nut79WeWA13ogxj2m2f2xOP9CKU
X-Received: by 2002:a17:906:4a10:: with SMTP id w16mr2142340eju.299.1562313547759;
        Fri, 05 Jul 2019 00:59:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562313547; cv=none;
        d=google.com; s=arc-20160816;
        b=oYzBQefvTTJcdPTqHTFbBPsI+GdpMiHRyvPvOpxf6p3vnpI503HHn73ze3s0v/CIMr
         LJUmx26qpL/8mfoKZ8+CsJboWBrFF5D0m5ApZeUK/vVeBerfIgOijnASncJNgJjNqub9
         aCqZNKME1JStHiugsthq0Wh85v9R/6AfouHLKW3g1Dqy2XRgvT7Fy2bQvoMZqLyu00Ed
         c0RIINAlqC3egEHA0cOZVYTkBurG1igy9HBeHjkVkcLG+RRb5Cl8VkpqUTeVJ3aJdme5
         /sK8zCGCTLWHX0S84U6elB3x4lVF//GjuiirrGbmV7meuTTyRYU/ZA6VrD3ylA7NAt6M
         nHKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9JuFbAzc1QgOVMLlizNhXHxR+tQzDg00DTVbe/YAJBA=;
        b=LiZTcvvBMPaLP6DxWtnCFQuz0ZnS3JnJ7OA+XOPi9wDGx8MBAqQ5/pxSJZcaUl5XIV
         FI3iWTR4JI9d2vxcS/xOg8t73R2trrhtnorwRWOtfZ5iZfd9EV2SSmulMChNwe+K0Gt8
         E+DdZ6h14I3S22exEfDqcfN/gfbantykKRrFC+lDqVQqBRQH4AVAEIaEa9fbHLXCR9lP
         S5aZYsX/k4KSKb0oorlazLNdZUmOLltHx5E2gBkL2Bg2/uAlmbZFncHn3CZ0tQZR6Wmy
         wYZ1xuDq3hQTW+y3tsSz2l4W0dS002lDsmvpEUOX+SnzAkRhdqYONLoYkCFWxve45XK3
         fm0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z1si5114370eja.335.2019.07.05.00.59.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 00:59:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E1F7BACD4;
	Fri,  5 Jul 2019 07:59:06 +0000 (UTC)
Date: Fri, 5 Jul 2019 09:59:04 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>,
	Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/isolate: Drop pre-validating migrate type in
 undo_isolate_page_range()
Message-ID: <20190705075857.GA28725@linux>
References: <1562307161-30554-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1562307161-30554-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 05, 2019 at 11:42:41AM +0530, Anshuman Khandual wrote:
> unset_migratetype_isolate() already validates under zone lock that a given
> page has already been isolated as MIGRATE_ISOLATE. There is no need for
> another check before. Hence just drop this redundant validation.
> 
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
> Is there any particular reason to do this migratetype pre-check without zone
> lock before calling unsert_migrate_isolate() ? If not this should be removed.

I have seen this kinda behavior-checks all over the kernel.
I guess that one of the main goals is to avoid lock contention, so we check
if the page has the right migratetype, and then we check it again under the lock
to see whether that has changed.

e.g: simultaneous calls to undo_isolate_page_range

But I am not sure if the motivation behind was something else, as the changelog
that added this code was quite modest.

Anyway, how did you come across with this?
Do things get speed up without this check? Or what was the motivation to remove it?

thanks


> 
>  mm/page_isolation.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index e3638a5bafff..f529d250c8a5 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -243,7 +243,7 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
>  	     pfn < end_pfn;
>  	     pfn += pageblock_nr_pages) {
>  		page = __first_valid_page(pfn, pageblock_nr_pages);
> -		if (!page || !is_migrate_isolate_page(page))
> +		if (!page)
>  			continue;
>  		unset_migratetype_isolate(page, migratetype);
>  	}
> -- 
> 2.20.1
> 

-- 
Oscar Salvador
SUSE L3

