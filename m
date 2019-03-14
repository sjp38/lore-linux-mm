Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAA94C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 08:09:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC03121019
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 08:09:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC03121019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 482068E0003; Thu, 14 Mar 2019 04:09:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40AB08E0001; Thu, 14 Mar 2019 04:09:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2AD018E0003; Thu, 14 Mar 2019 04:09:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BC62C8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 04:09:24 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x13so2033010edq.11
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:09:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=TjJp3FhtNfoDIqcDisyKsRNdguL4eRxWcutwHU3fCjI=;
        b=P+nqyV2mt/pkcj2awBtK+riOo5ps7F+kWJ43wtadWbE5NJboJ68URZ1UhDS/Avy6e8
         7tU4JmfXK4zGHVZlnmhpjp37oNnqHgGUALM5wgr2sn5JcsgMDLrDjDZqhAWTJpd7/Dak
         5qGeKFQr/WPJP4Om+kzir2zKNIfOaAJ4obXjRbPHSOqFTMjulYkm5utugxTu6DNkvlST
         cdmbQwrFhr5bG64NNpEZVPm5s/ifrChmOssLVNP1Myo09JB8Zl84NuDawGC9Cm7PmW19
         2qwwiLTZXjCS1X6f3LlRMUN2+IhAg+MZlE1h5rXDJTltrJrDljmjLJH2v1yQZqLM0qk2
         t0rg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXjdFOEDd2a5qQGr5j/Zt5NNfhAQjEG/lZ0FhR724L0BoiMNqxT
	odmc6rAk45NUfHiWHtdzC0XrSpo4+zOkVhuWNdG5ARX2Ys16QSvBms3zpzYlkcVWwgTgU1+Qx8q
	tLetocKptdIQBuimCyYxtns5ePg44skYf0LyIGKvDOh+laxJ+HUVEOuDj+8j8bDg=
X-Received: by 2002:a50:b8a5:: with SMTP id l34mr10433218ede.196.1552550964340;
        Thu, 14 Mar 2019 01:09:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUJEmNOJ4HlJrete5Ph8KhuJ2yE06uhkp+nH27m2i7Ty8iv8YCU4sCsMxE35R+qiyMzUkQ
X-Received: by 2002:a50:b8a5:: with SMTP id l34mr10433170ede.196.1552550963493;
        Thu, 14 Mar 2019 01:09:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552550963; cv=none;
        d=google.com; s=arc-20160816;
        b=VImOVLDHU5+dm179PyDluI1d47g92797bCJm9yCnKXZVpqgO5cj+qi2OMNXN6ZQerh
         dQo9cXkj4ENgEfn7QubAeahOy66HI3kmSu7bSz0inC0YfnJKUHyV1/wRZJh9FBPnAgvK
         yz2eGyK1nFPFUl4sWzbp5oFGeFAC2z1n4+m2xf/j3YR7+zNcOrdC2pRPjEQtOkBRSRPi
         5bFG8JWLXbyTxFwJiF71F87mJ05qiVP1E0D4OGEld3RjrRMWfAS/7m944HBkkRjH2tAv
         lz3IZLFAwL+uW0KQPNeO4xgyKsD8/GmoBOzK52CXQ3UGX3M8rfEplwPssWZWSxeycobk
         pJOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=TjJp3FhtNfoDIqcDisyKsRNdguL4eRxWcutwHU3fCjI=;
        b=OLZtUufzT93Rlg3MbDTlO4R86U6WrlcNnL4lnUfalerrxdFRt63X+KYOVaiE831I0r
         5li+g3hIR1eVTrAsMdvEuF+gCfsMISgzJ6KwmpFqfKGf8cp34/K1o3ZKaS196f+e6PQe
         fI+b5/RJEcm6TfcHtNCUzii/PAp9T/Rn9XjWNzavySEzj5+Hx/jC0rAYVFJ0nAl4T4JH
         jB92hlQDjAQrZefI46TH+VY8LO1bV7htqpnKqGaKVd9EJ2ugFM/gbtAgWvnL/8F9Fpr1
         Ax+o5pRj68QwfF1fzWq+4shIUOViwGkv1DkKLCKA2uXsqQJuq6ilfi4fLryhHzOSdf03
         AIGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id m26si1503696ejb.46.2019.03.14.01.09.23
        for <linux-mm@kvack.org>;
        Thu, 14 Mar 2019 01:09:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id CB6F94571; Thu, 14 Mar 2019 09:09:22 +0100 (CET)
Date: Thu, 14 Mar 2019 09:09:22 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm/hotplug: fix offline undo_isolate_page_range()
Message-ID: <20190314080922.dk5ljg7fbtarzrog@d104.suse.de>
References: <20190313143133.46200-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190313143133.46200-1-cai@lca.pw>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 10:31:33AM -0400, Qian Cai wrote:
> Also, after calling the "useless" undo_isolate_page_range() here, it
> reaches the point of no returning by notifying MEM_OFFLINE. Those pages
> will be marked as MIGRATE_MOVABLE again once onlining. The only thing
> left to do is to decrease the number of isolated pageblocks zone
> counter which would make some paths of the page allocation slower that
> the above commit introduced. A memory block is usually at most 1GiB in
> size, so an "int" should be enough to represent the number of pageblocks
> in a block. Fix an incorrect comment along the way.

Well, x86_64's memblocks can be up to 2GB depending on the memory we got.
Plus the fact that alloc_contig_range can be used to isolate 16GB-hugetlb
pages on powerpc, and that could be a lot of pageblocks.

While an "int" could still hold, I think we should use "long" just to be
more future-proof.

> 
> Fixes: 2ce13640b3f4 ("mm: __first_valid_page skip over offline pages")
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
> 
> v2: return the nubmer of isolated pageblocks in start_isolate_page_range() per
>     Oscar; take the zone lock when undoing zone->nr_isolate_pageblock per
>     Michal.
> 
>  mm/memory_hotplug.c | 17 +++++++++++++----
>  mm/page_alloc.c     |  2 +-
>  mm/page_isolation.c | 16 ++++++++++------
>  mm/sparse.c         |  2 +-
>  4 files changed, 25 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index cd23c081924d..8ffe844766da 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1580,7 +1580,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  {
>  	unsigned long pfn, nr_pages;
>  	long offlined_pages;
> -	int ret, node;
> +	int ret, node, count;

I would rather use a meaningful name here, like "nr_isolated_pageblocks" or
something like that.
 

-- 
Oscar Salvador
SUSE L3

