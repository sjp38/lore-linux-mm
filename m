Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03A0EC10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:08:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B34EE20674
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:08:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B34EE20674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D1076B000A; Thu, 18 Apr 2019 09:08:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08BE56B000D; Thu, 18 Apr 2019 09:08:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E89916B000E; Thu, 18 Apr 2019 09:08:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C33086B000A
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:08:18 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id g25so1629652qkm.22
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 06:08:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=YcVGaAqMLPmvnvsiIp499fp7o7uoFxsU3fn7+zPfnJw=;
        b=FP2ZFNxzie9p3R06Zc/+iEX5YiLMzJ9f0Ua1hCWbNi8LuTgP21fFE/yUz3q3mine7A
         Uf8qQXjF+8bOcvuizXSgfzMJtNhEFToukFFgDxU4Ni2HCdMWSNPE5soEUMylEet4ckrJ
         1/PjEQanhtHcb3gSaEde+su9qKNOdlHA4Dt5+dGOJztqtYtMcpouk7wD6L25GNg7imu3
         AySL8c7xfgATbwMe7GyX/luRKeRDKA4/4QswAW7uwCNyYVrByTkPI2QUT2Fqj2eDdoV1
         ltBFg9gOOo0dr9ri2QyOk7QfPUKQS0da3/dlNDWOQRxRXt2xoUAiaXqcs8/t045tXDh9
         zh9Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pagupta@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV7h1+zfZyLzGgzjpGifLY2QEm++xVBefZ+DxjsCuygnHDLaLF9
	iD7R5S+0effNmKs6xWe9ZRO4aHBq3ZeSH/mpvvvmv1zTriiVy3lnvTlUR4ZjSdUCQOR2rM1ujJp
	Ze8pRUy9WxHjJIcn1SPyjHAF8Y4ub/jtlNuYsrP0KPTLC5aERJKECOXHMUH5rxb0v0Q==
X-Received: by 2002:ac8:1a55:: with SMTP id q21mr77803709qtk.20.1555592898451;
        Thu, 18 Apr 2019 06:08:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0MTOPYfyoZEnFIIVdgr/uhwfUf8/DKs6NcmN8iH93WX1JX3WxtZfe7ypAPnkSknnQPweA
X-Received: by 2002:ac8:1a55:: with SMTP id q21mr77803644qtk.20.1555592897771;
        Thu, 18 Apr 2019 06:08:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555592897; cv=none;
        d=google.com; s=arc-20160816;
        b=cTvQpiaS+c/mDYnHeQD1ogUz7EpPjO8w452JPQinY6XrOFnsFa+fOekNkQFpS4fjoT
         XTjL047ySbsbrB5TmL/rRBQDjJy9Sf4ATyuOORHrSNL8KgK8abMWp660uBH5V7SO5pPM
         EUj/w7NCN2Ngxy5RK61BfZI/lBPtx3G2d0xq4812jnImUrj4wlucfDygwOVNOfKXGgL+
         l5nnxBIn1UJexU/R/QVGiELSeaYoPRlwj0rbvGaIfkhnBcst039ZgyUVTI/COr+hNmWm
         ndS07xPZDf2r7T2AiD5q4XYOJU1T/ObQ5jgR+P+c4lLIozVReOUS/+bdnI4HDCElNvod
         1AuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=YcVGaAqMLPmvnvsiIp499fp7o7uoFxsU3fn7+zPfnJw=;
        b=GjEtu3mTaptL1JRyrmNMKXryWiyJ1QA8PmodJuML+KKgAhSTb0aezk0aIMaufDpYxr
         nfki006V5Q+DhfcgwU6FFj2toWBN98O8wg5bOXghLyYVdc3e2GFdwuwaljZmkE6cCd65
         0W5aiP4izQzKGFSpADFr6j8LLdkpWTHrM/1x38oyKdwReQaIEe6XmHZdAiGbodzaRj1b
         zTgQYkmkFOxV0WZXkhcWBU9MVj49N8HF1VyHC5Nbu6oNefdolHgKg0uNuiHbLAA3gzIL
         DYush4g4B/t+gBha56N20HLp2Mw0jOTfN+2Ht6OJ2gujghlU4r6Gm64fvGXAu45G0p8B
         shwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pagupta@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r58si1471926qvc.210.2019.04.18.06.08.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 06:08:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of pagupta@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pagupta@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0463D81227;
	Thu, 18 Apr 2019 13:08:17 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id E9F175C205;
	Thu, 18 Apr 2019 13:08:16 +0000 (UTC)
Received: from zmail21.collab.prod.int.phx2.redhat.com (zmail21.collab.prod.int.phx2.redhat.com [10.5.83.24])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id B4CAF41F3C;
	Thu, 18 Apr 2019 13:08:16 +0000 (UTC)
Date: Thu, 18 Apr 2019 09:08:16 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: mhocko@suse.com, vbabka@suse.cz, akpm@linux-foundation.org, 
	linux-mm@kvack.org, shaoyafang@didiglobal.com
Message-ID: <1356622727.22481182.1555592896337.JavaMail.zimbra@redhat.com>
In-Reply-To: <1555591709-11744-1-git-send-email-laoar.shao@gmail.com>
References: <1555591709-11744-1-git-send-email-laoar.shao@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: remove unnecessary parameter in
 rmqueue_pcplist
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.67.116.67, 10.4.195.18]
Thread-Topic: mm/page_alloc: remove unnecessary parameter in rmqueue_pcplist
Thread-Index: x3KRwlatpm629OBg+w9KSVonyroxgg==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 18 Apr 2019 13:08:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> 
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> ---
>  mm/page_alloc.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f752025..25518bf 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3096,9 +3096,8 @@ static struct page *__rmqueue_pcplist(struct zone
> *zone, int migratetype,
>  
>  /* Lock and remove page from the per-cpu list */
>  static struct page *rmqueue_pcplist(struct zone *preferred_zone,
> -			struct zone *zone, unsigned int order,
> -			gfp_t gfp_flags, int migratetype,
> -			unsigned int alloc_flags)
> +			struct zone *zone, gfp_t gfp_flags,
> +			int migratetype, unsigned int alloc_flags)
>  {
>  	struct per_cpu_pages *pcp;
>  	struct list_head *list;
> @@ -3110,7 +3109,7 @@ static struct page *rmqueue_pcplist(struct zone
> *preferred_zone,
>  	list = &pcp->lists[migratetype];
>  	page = __rmqueue_pcplist(zone,  migratetype, alloc_flags, pcp, list);
>  	if (page) {
> -		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
> +		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1);
>  		zone_statistics(preferred_zone, zone);
>  	}
>  	local_irq_restore(flags);
> @@ -3130,8 +3129,8 @@ struct page *rmqueue(struct zone *preferred_zone,
>  	struct page *page;
>  
>  	if (likely(order == 0)) {
> -		page = rmqueue_pcplist(preferred_zone, zone, order,
> -				gfp_flags, migratetype, alloc_flags);
> +		page = rmqueue_pcplist(preferred_zone, zone, gfp_flags,
> +					migratetype, alloc_flags);
>  		goto out;
>  	}
>  
> --
> 1.8.3.1

Patch looks good to me.

Acked-by: Pankaj Gupta <pagupta@redhat.com>


> 
> 

