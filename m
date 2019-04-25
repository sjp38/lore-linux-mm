Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 419ABC10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:46:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED29C217D7
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:46:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED29C217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99C266B000A; Thu, 25 Apr 2019 03:46:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94BDC6B000C; Thu, 25 Apr 2019 03:46:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83C0F6B000D; Thu, 25 Apr 2019 03:46:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2CE066B000A
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 03:46:50 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x21so8933754edx.23
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 00:46:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=brmaZtDhP56GJn2X6dZWiSdCQl0li/NIcuMRX3P5P1I=;
        b=Hhbuv+z3bVwiM3vu1rvYuiOf3IS9P57xxPq+mVdGpEwH0GZenlnxKRcrNljdvU99aa
         +mUEkWbHtf0qxasmlYTy5cfGAqLAfpTtUi2tpWXcaMwLQcovOTZTLjncpRMKm0tFUF55
         Brh/cFLSt7bC9xN18LyosYnMMHG8Fw7tbwcb5AGnXb70CaeKQnuEkdx03xXE7yhDSLhq
         z6uD1QnAfOkj+7BCLK9RqdsaDE+M05b9o5V5+98fCeBGlwULOAAk3fgPqk8mXTZ/zGqG
         KK/u83LPVzaf5xiyqUUJ2aS/SEOL7ERx6OdY7I+e5/QKFUnL3JiP48vY8VM5GJKUIoOR
         +LSQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVt5I7rcwuNryJOXqeukETaywDl8ltGVKq60kTBfpnYZDlas8dO
	o2YnWzxfn8AteHMeV+myjC7Rb1oQD27Mu3p2oSNgmYeE33+n8/TONrbKTcxDq3QYRIzAya1CB1F
	umYla1+tDHczHyVbDGsJP89/uIgR0SDtBzVcRMxVf0jRjeKGjy/rPTnEEVH3x2JQ=
X-Received: by 2002:a17:906:2d42:: with SMTP id e2mr18462920eji.153.1556174940532;
        Wed, 24 Apr 2019 23:49:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyE7y08MsAPMEb0rq1kMN/9YqeT7nTvmbJAyOJ5gVOsrsOnqhuH/iaVGzaWiBBsl3ZtMPS1
X-Received: by 2002:a17:906:2d42:: with SMTP id e2mr18462886eji.153.1556174939628;
        Wed, 24 Apr 2019 23:48:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556174939; cv=none;
        d=google.com; s=arc-20160816;
        b=ASZ2/CBmbTx2VekaS7rMvdonHy6j77Uom5ir3HMtcNMmWwPIeyocJf7m/Xluq2ozFy
         zFzXRNphOELQWCbMJPOtMl0RRBSYzAweMHGCRAQ01LN9n/k1WDpxMzh2YFgdWr5G5ctl
         Om8yeUVCkfgpUIt/9Iy69XxT3tRF1VGFl889BhI5ZLFLUjw8bd8DlLpyVaAakXtspig6
         uu1rsHkMCJ/TOLrbxhHcv4Xrk5S5Jt4IF1/TIofVM+QqBB7bGaWHYeKlva/+2p+6weqy
         4I6EtxGxCcMoiuAv3qFeW6vC3WIZZTf/YpyADbyxGdlgPisiMMDtndLdfu/DGyNHq9AQ
         lnhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=brmaZtDhP56GJn2X6dZWiSdCQl0li/NIcuMRX3P5P1I=;
        b=QQTgx8qWQNMBMzGLT6SES7N7G12mF1DvF8ZN8rybN+uqrUX5z5RbBJSuJRFQSuAYPf
         TDzV977iObgLTscow15zT83jomSgUSZOr8T/7eGRwEgCJLaaeXcGdKK3bMKlnQ1139lc
         MEl8n0S9AX1stR1Cdejm6+yCPs9Vz1yQGVbMV4Yl5Vr83u7PHz7gQPDV55F/s4bZONor
         yqTa2d42ImQq6zSY/EU7Hz1vUa5HQ9VrMNyEFOmXJKePo6W1n3330O4x2MpCXFFEjNen
         +yQF4u6JeXEM7HXDEiVcA2pjziFrCxhbCNeB4xPlbLscjqyaCNHk1VsFfoJ7J0qp87y/
         xUiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l15si195330ejq.331.2019.04.24.23.48.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 23:48:59 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0BE0DABF4;
	Thu, 25 Apr 2019 06:48:59 +0000 (UTC)
Date: Thu, 25 Apr 2019 08:48:58 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] memcg: refill_stock for kmem uncharging too
Message-ID: <20190425064858.GL12751@dhcp22.suse.cz>
References: <20190423154405.259178-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190423154405.259178-1-shakeelb@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 23-04-19 08:44:05, Shakeel Butt wrote:
> The commit 475d0487a2ad ("mm: memcontrol: use per-cpu stocks for socket
> memory uncharging") added refill_stock() for skmem uncharging path to
> optimize workloads having high network traffic. Do the same for the kmem
> uncharging as well. Though we can bypass the refill for the offlined
> memcgs but it may impact the performance of network traffic for the
> sockets used by other cgroups.

While the change makes sense, I would really like to see what kind of
effect on performance does it really have. Do you have any specific
workload that benefits from it?

Thanks!

> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
> Changelog since v1:
> - No need to bypass offline memcgs in the refill.
> 
>  mm/memcontrol.c | 6 +-----
>  1 file changed, 1 insertion(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2535e54e7989..2713b45ec3f0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2768,17 +2768,13 @@ void __memcg_kmem_uncharge(struct page *page, int order)
>  	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
>  		page_counter_uncharge(&memcg->kmem, nr_pages);
>  
> -	page_counter_uncharge(&memcg->memory, nr_pages);
> -	if (do_memsw_account())
> -		page_counter_uncharge(&memcg->memsw, nr_pages);
> -
>  	page->mem_cgroup = NULL;
>  
>  	/* slab pages do not have PageKmemcg flag set */
>  	if (PageKmemcg(page))
>  		__ClearPageKmemcg(page);
>  
> -	css_put_many(&memcg->css, nr_pages);
> +	refill_stock(memcg, nr_pages);
>  }
>  #endif /* CONFIG_MEMCG_KMEM */
>  
> -- 
> 2.21.0.593.g511ec345e18-goog
> 

-- 
Michal Hocko
SUSE Labs

