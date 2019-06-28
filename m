Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEADCC5B57A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 15:17:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCD28208E3
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 15:17:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCD28208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 575CB6B0005; Fri, 28 Jun 2019 11:17:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5267B8E0003; Fri, 28 Jun 2019 11:17:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EE4A8E0002; Fri, 28 Jun 2019 11:17:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E6E9C6B0005
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:17:54 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y24so9615050edb.1
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 08:17:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=npEr+LbiEzoYw5ycUUVkBss4xo28xXmr/XcAh8bcn5k=;
        b=IaZv2j5fmso8ey/acOTgYvgscPCUzoXUJ7XItT6aapUDHNfgFnFxGHJCIFnTT75mE+
         MypqH24Kcu3p000wdXV0l7o82JH/aiFplWvbMUny1+7r5BTa7Q0XLDsBHocXIKAminU7
         NzGVZA6JDLWr6DPNziptE/so7f+2vnb8PLOBUZtNk7sktSrntypugLpbUsIr4ITkX3/u
         MjAOVr5xZ5+T8kuRoDXTdiQ5mhz8Z8t61Bmu2ga81LBVt1QQz0ob87fe9L1Qbv7OYz0S
         SiX0GwjVoM9hM1EPJ4cOmDnuVmYRbB59a/qoexJ0n2HNiOmZ87Kwxx89PIig7OxhL8Bx
         4t2Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXciN+2HPxAUueWG2XzUcbxVaMu+HcrwsdPwWpHQJp2X3CSQCqJ
	h1DqbUZcYps7P4isf0N6xHu2ZG5Wnp8cGcgt/fcAPVHoZKB3gBfl8LioCBxehSr8q+ZTmX6OzKQ
	fr2XgGMj4v4o28NVtYKVQPbone4QBTVXksSy+O7/KaWG5y5AqIrzqx96KIEkM9Kk=
X-Received: by 2002:a17:906:2e59:: with SMTP id r25mr8992514eji.293.1561735074508;
        Fri, 28 Jun 2019 08:17:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhfE2BlgjyU8BWJ+vMOhfNZ6jLlj/kBcW7FWYNMTQZE22xAOeD0olXz79ED/T7Y4Cbi0W5
X-Received: by 2002:a17:906:2e59:: with SMTP id r25mr8992417eji.293.1561735073339;
        Fri, 28 Jun 2019 08:17:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561735073; cv=none;
        d=google.com; s=arc-20160816;
        b=TzOBMGrzlCfGpTdv1oWTx83K2HDG/wpjudH8GF6Y9Ct8D6GLIwDTe7bDuMvrVrkVES
         /Du5fBqlqFzOne1h/ybN4/dQvbJfeM79c6yNqL4Oegjo6B6nlmDiZYegwlDfN+5xINXc
         aqvBrLbwIDiZWcYEEi7TmZdB1fFSGsV1NdNCw7ik9Ywy8akW8W5nMFW56lPC99DJDNqA
         6QRQv4bSqzVd9sOKetkvpSPdGVJRDYlxrwALitDdja4G7dFIxPeYHr3faWjSfHzrWOvR
         Nu+Vh2nrHq4j+RTSg8yW8qI2uF3Yx8M6TK2VIrtVNCqg8JFugLsN3yIBaYgari4TIzkU
         2DNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=npEr+LbiEzoYw5ycUUVkBss4xo28xXmr/XcAh8bcn5k=;
        b=DUjC2AsIREYi9dF102jCcXsaxWw0ZhbyPjUjhLJR22QQyJGi8ztorEiro1QfPztE5Z
         PYnQ3BMGs2/BQ7qYphk6EC0xcuBQkMUjKqGHPAcFdQUFtQGQzwTsFS/QlYoUCo42goQe
         JGojeQOcGE1xYimpXr9fnGb4m9AQPoK/x3DdKST9FWmth3/Ah4A3NQtNCsmM9stfExrG
         Df7EmzmpE5bqCA3AmOl8L8kdoJJE/rZTtY95fe5Pjs/hmkCs7o+7KC0RJ+SfU/xAPRJV
         4jVT7r6vbi7Yjh41XSB/7VKWNEGv+ww3jBeqRycv1rWfIUlieY/lSgnmwiX0aAUCwsQx
         u23g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s42si2277238edb.446.2019.06.28.08.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 08:17:53 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6AD17ACB4;
	Fri, 28 Jun 2019 15:17:52 +0000 (UTC)
Date: Fri, 28 Jun 2019 17:17:49 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Juergen Gross <jgross@suse.com>
Cc: xen-devel@lists.xenproject.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Subject: Re: [PATCH] mm: fix regression with deferred struct page init
Message-ID: <20190628151749.GA2880@dhcp22.suse.cz>
References: <20190620160821.4210-1-jgross@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190620160821.4210-1-jgross@suse.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 20-06-19 18:08:21, Juergen Gross wrote:
> Commit 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time
> instead of doing larger sections") is causing a regression on some
> systems when the kernel is booted as Xen dom0.
> 
> The system will just hang in early boot.
> 
> Reason is an endless loop in get_page_from_freelist() in case the first
> zone looked at has no free memory. deferred_grow_zone() is always

Could you explain how we ended up with the zone having no memory? Is
xen "stealing" memblock memory without adding it to memory.reserved?
In other words, how do we end up with an empty zone that has non zero
end_pfn?

> returning true due to the following code snipplet:
> 
>   /* If the zone is empty somebody else may have cleared out the zone */
>   if (!deferred_init_mem_pfn_range_in_zone(&i, zone, &spfn, &epfn,
>                                            first_deferred_pfn)) {
>           pgdat->first_deferred_pfn = ULONG_MAX;
>           pgdat_resize_unlock(pgdat, &flags);
>           return true;
>   }
> 
> This in turn results in the loop as get_page_from_freelist() is
> assuming forward progress can be made by doing some more struct page
> initialization.

The patch looks correct. The code is subtle but the comment helps.

> Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> Fixes: 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time instead of doing larger sections")
> Suggested-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> Signed-off-by: Juergen Gross <jgross@suse.com>

Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/page_alloc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d66bc8abe0af..8e3bc949ebcc 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1826,7 +1826,8 @@ deferred_grow_zone(struct zone *zone, unsigned int order)
>  						 first_deferred_pfn)) {
>  		pgdat->first_deferred_pfn = ULONG_MAX;
>  		pgdat_resize_unlock(pgdat, &flags);
> -		return true;
> +		/* Retry only once. */
> +		return first_deferred_pfn != ULONG_MAX;
>  	}
>  
>  	/*
> -- 
> 2.16.4

-- 
Michal Hocko
SUSE Labs

