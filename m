Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFCF5C04AB1
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 00:40:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 556FB2182B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 00:40:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BnWMeilq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 556FB2182B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C43E76B0003; Thu,  9 May 2019 20:40:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF4F66B0006; Thu,  9 May 2019 20:40:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABC2A6B0007; Thu,  9 May 2019 20:40:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9F46B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 20:40:10 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id q188so6836583ywc.15
        for <linux-mm@kvack.org>; Thu, 09 May 2019 17:40:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=kJIkcAZ6u5IJ9XmF7NOxVNNYB8HdaXRsalPuY1w3/z8=;
        b=cIk0RqIBT8SaLZPw9IhEcAvGg510CRwZLoa/xDzuEsIELK0GISCby+EylQ6f046KnH
         vz3ZYBHOUXwqs21MWxWT5n56FbvBzbPb/5eo8tFSa2YeFHxJR3m9t3AnlXS3KV/IC3Sf
         OEJS6AYvttDL3Yayrb8LANix3MZ4zA4aqDm4s2gghJchkQVrPwQrbzGQfgB63OVdekvW
         MYaKVfTCjvPu7GK4aFUgsfsf9SelJOkjcx3+yE8QBqajBp56+1rW9JelI3WQ5bKU7Mm9
         v+OqxzJvTVfvXmBlTK8PfNBeDNqd2jFPXg+1qYuiSto7BTd0HK7BP5pmsPdrK2c0dn3y
         Y22w==
X-Gm-Message-State: APjAAAXj4Lc+YfEfYXudV8Wh4IUt1VJIFmXAoRX0aQi1NwWw9IBKAxB+
	mlxx0HOA4G2IQCECISIKWeSkoMKJQMQpVAJHhwwshivz8cK8lplM9Ezq+YSkX0P0gaoalinCVmU
	9/iDArZeSSPjJMSENxTwK2tl32v4YqZu47ec8UHoVPQbk++6N7Kc8EGll0rAiTzP6iA==
X-Received: by 2002:a25:585:: with SMTP id 127mr3889321ybf.60.1557448810318;
        Thu, 09 May 2019 17:40:10 -0700 (PDT)
X-Received: by 2002:a25:585:: with SMTP id 127mr3889308ybf.60.1557448809679;
        Thu, 09 May 2019 17:40:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557448809; cv=none;
        d=google.com; s=arc-20160816;
        b=OgTaVJP1H+mxNdpkF2oaE6Pg7jiXHlBVE/+ltbPj5aw5BsnsHL4YA+wBoAZOITwBys
         5gYm9RAeVLEFmqeniv2HY8vG3GDncjsOts6jKVBsrSEN/nc72nTVCm/HqcfcCodFh8v+
         H7fJfHiUxH77kjGWThidLHd7Q/01idWZJJKr+Cby255RfMaGn6rS34Edm0JFsqcnJJDQ
         xrX4pZJDwmDN2DocP7S9XBkcmJnPU2DQ0CZFDu4HXSaKsAz11BlccvN5iJzTB915PlK4
         7qmYoBqNN+o7j1xT1RPOoq7JeN5AwYZaA9Kja2ROcYh+mQknicM/L1ffexKkK2gdsE4q
         NdKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=kJIkcAZ6u5IJ9XmF7NOxVNNYB8HdaXRsalPuY1w3/z8=;
        b=sF0sMpyavJnyBEDFQjthPkExNNnStLa7zcIrf8sBwBJHYGU/vuAc9tdyrLtqVVthEJ
         Ixss5pAr9G5LqCGVEZQQ02KN6s8SiOveBvDjuUZ5hdWRiMBgPjk0XjDLcMnO6T02NHce
         hQJeYGTh5Y/EgK6Gxiad210jOg8C69QZKrN7/CWDfo/AP1GNHr6bHyMRayoOPVpMAyjr
         9I/3YHfVvyLLcZJYXTHl4082BVxufjUXZorLUEXTEznY63ycApuxVQPTzBvFn88C99oN
         /uD0rbE7H6BnNE+kaD/Wc5ls7+jFSddtv3WnnoK9abHkHFFAkm/js7TVn1pgYRkL5Oin
         LxFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BnWMeilq;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i63sor1865138ybg.17.2019.05.09.17.40.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 17:40:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BnWMeilq;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=kJIkcAZ6u5IJ9XmF7NOxVNNYB8HdaXRsalPuY1w3/z8=;
        b=BnWMeilq5CmV7xEOS7UTY0R8GZBvNiJUb5X8thIrkLC146CGJ28ux8O51ka94luUji
         ko51fW4KRyCWVOi/von/XCjTv5Bq+D0G0m8PuWDLMU8pmLoHkVAidAi/9MCw72ZNpUBN
         q7xTRHcayJCQmsiAPDShWGpwdLShGMWkoOMABic60GtN3IaFoPIX9eSVsFIkBfxpV7pe
         K1YZw/DNtI7wDyhVsKXKTR6evCj+wKBM/ZCKAVbXjVWRlyOHkScfk3FLQ4FnRkjbDi/x
         TcZbJlD57h5bUMnjLqNuuD1i4+gmaFje2JyxaP3cHRb97P+2aaN1Ctg2LNMnSUH9vTQS
         7NZA==
X-Google-Smtp-Source: APXvYqw2dVC2ET7GPFNXeSlt/NpFnxG8e1iXqGKojoN4LujAfzUVvhzsWFouCtyUPIv6d5hMLtOYG5Es5WGTXBS03mU=
X-Received: by 2002:a25:4147:: with SMTP id o68mr4131573yba.148.1557448809031;
 Thu, 09 May 2019 17:40:09 -0700 (PDT)
MIME-Version: 1.0
References: <1557447392-61607-1-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1557447392-61607-1-git-send-email-yang.shi@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 9 May 2019 17:39:57 -0700
Message-ID: <CALvZod5LjCMxsPhbY68QRggFy4QjVsTDXh192PqSW6qsMCKknw@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: correct nr_reclaimed for THP
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yang Shi <yang.shi@linux.alibaba.com>
Date: Thu, May 9, 2019 at 5:16 PM
To: <ying.huang@intel.com>, <hannes@cmpxchg.org>, <mhocko@suse.com>,
<mgorman@techsingularity.net>, <kirill.shutemov@linux.intel.com>,
<hughd@google.com>, <akpm@linux-foundation.org>
Cc: <yang.shi@linux.alibaba.com>, <linux-mm@kvack.org>,
<linux-kernel@vger.kernel.org>

> Since commit bd4c82c22c36 ("mm, THP, swap: delay splitting THP after
> swapped out"), THP can be swapped out in a whole.  But, nr_reclaimed
> still gets inc'ed by one even though a whole THP (512 pages) gets
> swapped out.
>
> This doesn't make too much sense to memory reclaim.  For example, direct
> reclaim may just need reclaim SWAP_CLUSTER_MAX pages, reclaiming one THP
> could fulfill it.  But, if nr_reclaimed is not increased correctly,
> direct reclaim may just waste time to reclaim more pages,
> SWAP_CLUSTER_MAX * 512 pages in worst case.
>
> This change may result in more reclaimed pages than scanned pages showed
> by /proc/vmstat since scanning one head page would reclaim 512 base pages.
>
> Cc: "Huang, Ying" <ying.huang@intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Nice find.

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
> I'm not quite sure if it was the intended behavior or just omission. I tried
> to dig into the review history, but didn't find any clue. I may miss some
> discussion.
>
>  mm/vmscan.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index fd9de50..7e026ec 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1446,7 +1446,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>
>                 unlock_page(page);
>  free_it:
> -               nr_reclaimed++;
> +               /*
> +                * THP may get swapped out in a whole, need account
> +                * all base pages.
> +                */
> +               nr_reclaimed += (1 << compound_order(page));
>
>                 /*
>                  * Is there need to periodically free_page_list? It would
> --
> 1.8.3.1
>

