Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7E38C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 08:25:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA021215EA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 08:25:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA021215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C2306B0003; Tue, 25 Jun 2019 04:25:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 373C78E0003; Tue, 25 Jun 2019 04:25:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 263058E0002; Tue, 25 Jun 2019 04:25:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB57B6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 04:25:35 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b3so24456850edd.22
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 01:25:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=nz/ZeWp7t5iLr8Sh72dGgNj82cACFpOAaVVYdDMZUrg=;
        b=jW6lOAeSA/aQr5FiLB48KFH7QNU49rqrJDMLeKodQ/7b1CwVlki7KskYFMUvWcQeql
         RTNDVP3k8jSJ/bSxlt5ildPHXEBvCWAJvD2hRLDPlW0LO08zJcfFtoppnDFsra4oZPYI
         0JD0DhgsMHocNrNwEJh6fsvGX6iF5zNd2d57hx5ORNgOjx49mdzhQz9c/YbYJmegVPeG
         DfZsnzdTIkKHeoeFNoFWYvzz2F8gXpWeC70DU+ET1Xm3Pn2kwMYqCcpDPgnzxfkSuYFB
         YccLB7iWK1BQyxZ5bRRpeoWqdMKFzkjYj683ypmELP1F7tRani6dLkQuaoKvYtv6uyXx
         YsBg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: APjAAAXE5G1WoqNTwT8M5ii4tOZyXtM2JWN1V7D4tqWsyrXFFzaaRxQ1
	5/VKTwHiKRkvdEN9yXwA5DrS2XyDtqh3cxGyBj9agKvdFzMzV7b7EXtXYiPiEOfBx3rM+mNMFjN
	SZ3mvOUboqqXgWwxkvdC54C+EJVJIlSNTi3HavV4rsddS74XbRmRG8e4C11ospfxrLg==
X-Received: by 2002:a17:906:1dcb:: with SMTP id v11mr6904770ejh.218.1561451135368;
        Tue, 25 Jun 2019 01:25:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyy3i8J77ac0wi6gUp2Eyi4SC1Ut9I9asDdwpFuK9SMhZNzAuuATVM/rpa/hrlFMWNRYUme
X-Received: by 2002:a17:906:1dcb:: with SMTP id v11mr6904730ejh.218.1561451134628;
        Tue, 25 Jun 2019 01:25:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561451134; cv=none;
        d=google.com; s=arc-20160816;
        b=hayXoa5DoPgQPh5p+416chlt+oQiDxCIH2F6l2+S6PaKVfghyexMdLQCUkm1tQbVOU
         Yhb4qPA8Ufso5htUMZqsX22Zov9o/Va7XbssJejuG8zOvRsXHfF7J8DOpN4uLQSn9r2c
         ZbuQKm4FMwPk66Y7dX54/OZCZgY4RD8z0fij0PUQOSKghz1+pl5fkrsTG5PnDDhbIDqQ
         00xSvGejC5MX4Nyb1BFwnEu08a6tVwE84D850cbSiqZonjcVJ/huQWreq1x6HkTH0XRx
         8ywccZCrEMhu8u3TaRR5hGcTBGZ8PK0seIt+w+U2cbPMOGlpuflV+gw4FBoOamIRSqTc
         qfKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=nz/ZeWp7t5iLr8Sh72dGgNj82cACFpOAaVVYdDMZUrg=;
        b=hVOY5M0O6Fw1TCy8QoUm2X6bdsXVJD0QH24lCBbqiqYXhBabZEvVXIuhU+D74m5rxS
         3RR5D7GCRl3HnEaD0+cKYG2scCCZPrfsZfA7kM5wsgu210u9E2wZgrWBDNsRSudH5aRc
         L+9xYcaSf76acN9/JTh4S3/kQMQjCThf6PRFF519GDLXkKvuFc0SaFviW+s4cgvnTO/b
         SeJndzEWSwhDhs5KPf+OLwhgaPgWAQmqB9qr6qCeOswn8facc3TPVr4MPApghLBP1xct
         uFP7yRbSPlrlmM3Rcju59bL3V6IBPlPhOMyh+1EuwaigDFvqUtBNx9L6xn6AXw/iffA0
         P/AQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r3si606393ejj.69.2019.06.25.01.25.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 01:25:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E6254AEEE;
	Tue, 25 Jun 2019 08:25:33 +0000 (UTC)
Subject: Re: [PATCH] mm: fix regression with deferred struct page init
To: xen-devel@lists.xenproject.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
References: <20190620160821.4210-1-jgross@suse.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <79797c17-58d6-b09c-3aad-73e375a7f208@suse.com>
Date: Tue, 25 Jun 2019 10:25:33 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190620160821.4210-1-jgross@suse.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Gentle ping.

I'd really like to have that in 5.2 in order to avoid the regression
introduced with 5.2-rc1.


Juergen

On 20.06.19 18:08, Juergen Gross wrote:
> Commit 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time
> instead of doing larger sections") is causing a regression on some
> systems when the kernel is booted as Xen dom0.
> 
> The system will just hang in early boot.
> 
> Reason is an endless loop in get_page_from_freelist() in case the first
> zone looked at has no free memory. deferred_grow_zone() is always
> returning true due to the following code snipplet:
> 
>    /* If the zone is empty somebody else may have cleared out the zone */
>    if (!deferred_init_mem_pfn_range_in_zone(&i, zone, &spfn, &epfn,
>                                             first_deferred_pfn)) {
>            pgdat->first_deferred_pfn = ULONG_MAX;
>            pgdat_resize_unlock(pgdat, &flags);
>            return true;
>    }
> 
> This in turn results in the loop as get_page_from_freelist() is
> assuming forward progress can be made by doing some more struct page
> initialization.
> 
> Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> Fixes: 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time instead of doing larger sections")
> Suggested-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> Signed-off-by: Juergen Gross <jgross@suse.com>
> ---
>   mm/page_alloc.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d66bc8abe0af..8e3bc949ebcc 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1826,7 +1826,8 @@ deferred_grow_zone(struct zone *zone, unsigned int order)
>   						 first_deferred_pfn)) {
>   		pgdat->first_deferred_pfn = ULONG_MAX;
>   		pgdat_resize_unlock(pgdat, &flags);
> -		return true;
> +		/* Retry only once. */
> +		return first_deferred_pfn != ULONG_MAX;
>   	}
>   
>   	/*
> 

