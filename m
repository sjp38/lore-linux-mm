Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 752E1C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 09:23:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35D302190A
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 09:23:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35D302190A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B05956B000E; Fri, 22 Mar 2019 05:23:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE6846B0266; Fri, 22 Mar 2019 05:23:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F2036B0010; Fri, 22 Mar 2019 05:23:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 45D136B000D
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 05:23:50 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t4so695812eds.1
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 02:23:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aTtjmdyx974LqwBl6IryqyAWveFeGrmq/p2jnURbpEg=;
        b=JyKy3abGuuGGs8cyvDvbVcU77C79229QJ7a2bTmjY9lGUziJMMtd3lOk9PTe3O4xPk
         okubPPQxmFc0wjB6cf4nBCY3oSrbovSSpK99eS1EpassPhvZ2nFJ8LceJsupYvUh9X+N
         cty3evfRHMRd7CXENGilwQXyIZoh3OpMOIm8/g1+QWN1KJGEgLZvaLMgTXWLZFDr76gh
         QySQEkGUDYk5a+7R4I/XPmFCXHR+gHGzcnYr1WvGTJxzw8dq/upsTsCYm2PI8j1yHQGQ
         jHyagY5gSztzH0mC2+sDxaOKqRibAricQBHuzYt4XhVbCRkA2mb4LXEDf0FHMWY0CX8k
         TMTw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWEPYTL5J08hOnfRTq5yNY8kTrn+WIocWuWsEBF8WSrSxzTnNVm
	bdCVG8zN9w1gkdYeoQNQUHsxy5QIbepGW3A7JRSboDUyinka4NtHXzKFklqSunOpMDQFAQpsB6H
	0AmAD3pavTnfwh7BQcPdve/4121Nny5uNrOxH7VBY6JQND5RTy2z39uSilvymCEU=
X-Received: by 2002:a17:906:b291:: with SMTP id q17mr5003083ejz.56.1553246629723;
        Fri, 22 Mar 2019 02:23:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwaDJtYncx9+bZBVWqQzfN8hcQ9b1rs8ZFLAvgEyPI1EYZJxaxJXa8TvNBx7kBbK2ltPD59
X-Received: by 2002:a17:906:b291:: with SMTP id q17mr5003037ejz.56.1553246628794;
        Fri, 22 Mar 2019 02:23:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553246628; cv=none;
        d=google.com; s=arc-20160816;
        b=G26RBNfICxrbT6u3NMLeVWzi428KZpD8jOBJv/5qk1GUXTWum4pkenkMskgQYyzK8q
         NGO0tAmj5MCMhyj43ju5Ke/+Whdk3OQe3fg8ZB9NeH3rInU3DiNjvHaX/bYJfM3JpdlU
         sBLRtLBj/IvTQCCPXmZMR4BFxW29TQfGTMNyvTZclY/m9dBkqHdwvJ31vzgFM6PeAVZl
         88gA8I9eDlN39mUz3ZFOM1Sey9xvhVTneU6EOqRWpJY3uAl3n9ESCEqImdjCenrrIvGd
         v3eCl7hu5B+lsUtI+/uQm/gVLfId8VzJfYbrI4TdgY+oHmRDld+LH8L+PYqEwUFt+65F
         MGUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=aTtjmdyx974LqwBl6IryqyAWveFeGrmq/p2jnURbpEg=;
        b=SxUeZbr2l7t6KyQGQbGVYsvSPK/z/Owz71EYV7C/La+Ds8X1igF/m9pY/aRp9ndlLN
         it3IqQIwHTnCdN64pFETdbqpMLAQ3Lk8FTY0ASydY+1Inmm48CKolpEGvqVXjBiDEkxJ
         Np+vavUwDa5I5tvgoFBN/Gf0NQH25OhXw3P0Yzz/Cqnn2gbqT8DBjHkhg4alJTp6xd3A
         8aoMhGIGOeqSsdxRJLgCCGQ+nwgKOCEjjRxLPZJgD2dlQT/JiGq1GtJQd+ngCp48RPVq
         afTro0PbP/VEX3BSO09Ax5m+09Rj8HP2IS6kdYoMOmGNfpTmHvbcsn9DLsUC5pefIR9d
         R5EA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 90si2144174edq.392.2019.03.22.02.23.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 02:23:48 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 42A9CAFBE;
	Fri, 22 Mar 2019 09:23:48 +0000 (UTC)
Date: Fri, 22 Mar 2019 10:23:47 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	mike.kravetz@oracle.com, zi.yan@cs.rutgers.edu, osalvador@suse.de,
	akpm@linux-foundation.org
Subject: Re: [PATCH] mm/isolation: Remove redundant pfn_valid_within() in
 __first_valid_page()
Message-ID: <20190322092347.GA32508@dhcp22.suse.cz>
References: <1553141595-26907-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1553141595-26907-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 21-03-19 09:43:15, Anshuman Khandual wrote:
> pfn_valid_within() calls pfn_valid() when CONFIG_HOLES_IN_ZONE making it
> redundant for both definitions (w/wo CONFIG_MEMORY_HOTPLUG) of the helper
> pfn_to_online_page() which either calls pfn_valid() or pfn_valid_within().
> pfn_valid_within() being 1 when !CONFIG_HOLES_IN_ZONE is irrelevant either
> way. This does not change functionality.
> 
> Fixes: 2ce13640b3f4 ("mm: __first_valid_page skip over offline pages")
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

Forgot about
Acked-by: Michal Hocko <mhocko@suse.com>

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
Michal Hocko
SUSE Labs

