Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9EB0C04AB3
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 08:09:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A99B20818
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 08:09:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A99B20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF66B6B0007; Mon, 13 May 2019 04:09:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA8586B0008; Mon, 13 May 2019 04:09:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 995816B000A; Mon, 13 May 2019 04:09:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 49A526B0007
	for <linux-mm@kvack.org>; Mon, 13 May 2019 04:09:33 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d15so16752608edm.7
        for <linux-mm@kvack.org>; Mon, 13 May 2019 01:09:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QB6GAhhsTuzw1SqdRHzIftQoSJ+6UduFS7YRtFpo+0Y=;
        b=FagM+3Z9p2NEwgnjTP515zCL2bjynSGQYvwmKtEISrvpob5On5qcFQY3sqb4jAY7Nx
         6D+qcw0io51L6QxgD7PecE4J+fDCHaYUYlTwoXmevNX/HBkpIapDaXArOAb7F7LEW0Uj
         1XWFspRui5lDa4vb1c9SgQdZ6c7vFgZDp/917Fu/5prPYuvw5ZdcwVzXHUKXxqPz9Bfo
         bPT7AP8TgOgMa0J/cnEcy01vns3O2ErmHnTRCxiOBo/ciZTTomglqKt1XRzoV+Sp4aCg
         ugs2mFbNL5HINzq8P+wfweVrZq2qMjyth2IJMBsQdfQmpLkSRbA6NaGgj+OzqvKWkKTP
         DOEg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXchh8uRw+d20QMifjt1ibAVweP12ynK8GTZfcbpd6aNUsY9yjy
	WeERC3047mw9h4DXIra42Sn+uZcVce5zuNueR1udHVqs9PFJGnYc0KwZU3ysvkPye+zc9zPRaA0
	9i41XAyz1w/DxB1VZWd7awXe5kKFmQI9CTtyPA5N4rn+vWO08TqKjtt5bIITdpQ8=
X-Received: by 2002:a17:906:7047:: with SMTP id r7mr20599972ejj.27.1557734972759;
        Mon, 13 May 2019 01:09:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzglacESHYk0w5Hv4qRhLgZH4vdhhVfvMZ7vZz8laBoZdurbMAALTe+phO7VowghzKWvlpb
X-Received: by 2002:a17:906:7047:: with SMTP id r7mr20599885ejj.27.1557734971571;
        Mon, 13 May 2019 01:09:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557734971; cv=none;
        d=google.com; s=arc-20160816;
        b=FPIN3/kipTWjCPV93K1UPQ74MS6jJkXv8Gqh528mOlp/vlAlkZ44lE5kkMGva7RXD3
         dbubzFkV+E9OB+G0TtoNjxlVHkuQ3XpaPfUvct5qmdvs+CbYJxBJM0J0YCAt3n2d4wzq
         Gt3gEgnYuFev/zuFTjSx8GxcdnvsdDDS0UyseDM4ZYFmIm6tctAAqpTjBibgu98TBHdV
         wrzdqwLt1SI0aoqUY5JdSh0u0UEsLkvjvfv0RaXzM5hmYoPEXm6ABJLoQdyZzR7S8xgD
         8/hfiFGFbEu2SV2qpWnD5e6CWtoz55frIiqFmxMjRBqQn82F0suTEctj48SZC9j3yiL3
         popQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QB6GAhhsTuzw1SqdRHzIftQoSJ+6UduFS7YRtFpo+0Y=;
        b=NECIZFxCyx3ATpzqEWlYFuxCpVrD3+j2inQM0A0FxHfuWcpYbtLClGDOMYmR//c2UF
         wY86xdxeqB6xZwC5oCxNVRNzIDiPOELhQF1evoWXKjey4aAMQSKb/6NUqM4UUYAHFAAb
         Q3Su502GV5d5G/NHMKD045KkWSLZCmuU2yfuvYYESYLBqRWkFIVKJxolti2uIvj0jGzM
         9U6wNmbJMiz/eVmLae4pyA3Bfgq3bTXtf1EFTD4E5VKHJkm1Chc0F6qgLe9NUiYIvyzz
         a3ZTC4QPirh/1b6qZO9McOVGLSVO7qDSd2Eww4cnQRDDcA41h5B1W1RZRdkFCH53fRO5
         kQ7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t57si3425853eda.339.2019.05.13.01.09.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 01:09:31 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C4E52ADAB;
	Mon, 13 May 2019 08:09:30 +0000 (UTC)
Date: Mon, 13 May 2019 10:09:29 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: ying.huang@intel.com, hannes@cmpxchg.org, mgorman@techsingularity.net,
	kirill.shutemov@linux.intel.com, hughd@google.com,
	shakeelb@google.com, william.kucharski@oracle.com,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 PATCH] mm: vmscan: correct nr_reclaimed for THP
Message-ID: <20190513080929.GC24036@dhcp22.suse.cz>
References: <1557505420-21809-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1557505420-21809-1-git-send-email-yang.shi@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat 11-05-19 00:23:40, Yang Shi wrote:
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

You are technically right here. This has been a known issue for a while.
I am wondering whether somebody actually noticed some misbehavior.
Swapping out is a rare event and you have to have a considerable number
of THPs to notice.

> This change may result in more reclaimed pages than scanned pages showed
> by /proc/vmstat since scanning one head page would reclaim 512 base pages.

This is quite nasty and confusing. I am worried that having those two
unsynced begs for subtle issues. Can we account THP as scanning 512 base
pages as well?

> Cc: "Huang, Ying" <ying.huang@intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Hugh Dickins <hughd@google.com>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
> v2: Added Shakeel's Reviewed-by
>     Use hpage_nr_pages instead of compound_order per Huang Ying and William Kucharski
> 
>  mm/vmscan.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index fd9de50..4226d6b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1446,7 +1446,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  
>  		unlock_page(page);
>  free_it:
> -		nr_reclaimed++;
> +		/* 
> +		 * THP may get swapped out in a whole, need account
> +		 * all base pages.
> +		 */
> +		nr_reclaimed += hpage_nr_pages(page);
>  
>  		/*
>  		 * Is there need to periodically free_page_list? It would
> -- 
> 1.8.3.1
> 

-- 
Michal Hocko
SUSE Labs

