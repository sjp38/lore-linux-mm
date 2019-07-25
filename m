Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4173EC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 08:23:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D774D21851
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 08:23:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D774D21851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70FCE8E0051; Thu, 25 Jul 2019 04:23:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BFC98E0031; Thu, 25 Jul 2019 04:23:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D5B58E0051; Thu, 25 Jul 2019 04:23:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id EFD118E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 04:23:24 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id m25so4971617lfh.3
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 01:23:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=2ABoEykAYVl7QDkI++6FVOv8EdsafWAxIaOgn6zOg+o=;
        b=TF8UWLj9jOlopGTEJfOnJvuIr088G9I8PJx1nXLIJZ87gY6fBEavDkc5EBsPVaW0F4
         3BAiy7PVihwYUgsFzOgi2AXDJ2FSaLBrWi89BhgHg9L80fHHZMZ3IARsB+xSQyL6Kyd8
         SS7B0S/Gya/3AmMyTcoUwAP8ySyHG9l/RpcHQM99SQCAT6D5FUCA3+rd1p+ptjfa/1MW
         INTJXf77ETY55372UaWYwoMOjhgfjPPHScnqgKeHpQS82hdTPj0o5gGzLs++6966ZHxt
         1C2ODf6eqPQxF5x3cxD5NYNJn7HZvgCC3wuuYNM+rKIPqLBduCkm8NHvPKk8v/Vk2NgG
         i1hA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVVUUGBt5WeSbtx/MLk4vA4mkp84Jvl+buCBzMhJnCMorDumYPt
	FyJHHg2zT8DuHVyRKx7uv+Zl7/qNmrmfLjwVKbrFl2+jBISuSlaXh8La8iq6KcCv5xdj5j3x9fF
	t5o40++DQNaDJVOI5mOFoQccmwrCmTRvIj0bIYgRN/Itd6gbHU0vq5scKVjA2gEXboA==
X-Received: by 2002:a2e:9701:: with SMTP id r1mr28652079lji.12.1564043004454;
        Thu, 25 Jul 2019 01:23:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqze5yJv8rAH9HBtcjDsPlszJXBpK1J8bSgDC2TP5SEQUg25mt9Lk7zHVcajmoHJQn5Kozj9
X-Received: by 2002:a2e:9701:: with SMTP id r1mr28652054lji.12.1564043003706;
        Thu, 25 Jul 2019 01:23:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564043003; cv=none;
        d=google.com; s=arc-20160816;
        b=Z1qSmu+HooCAlAboEIzt8ZWx3FydhloTZRJymvEHQ1VReqdiIpRozHpgR2uo1yDLsH
         1ZXuotrDoMcK4VSZ5PHmJ3hHpkIOyLwLPAtfDCJ7xSXAHqEFnhG0O6FcrOrxjL1uyIyd
         xueEbX5S8ngatWWAKw8jF/7Pdz4FuRXcGrS9LFP73OB3TKf2C4Qf6elRiO66GYiyeBSY
         r6vW2lBhnpIiA24DrnJaQTxEJi6YsloRXIOGSckfm8CUJzou7izAQ6WtYd/GURFlW1oe
         MiiK7Y75vfy/8ugZYRQlI6ZxrpcYaRNxVY9UtwBT1zxq3vxzi7yTurE2uAeOOhwH+yqJ
         9Xcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=2ABoEykAYVl7QDkI++6FVOv8EdsafWAxIaOgn6zOg+o=;
        b=ku60bIdYJmrkeQWgokWdXP9mmjLl39uprBsfR3ZN75ivjRYIwhSnZbYlmTMqD7YgOH
         U1xOS5IoRxbB8WXCrFhGB+81QF50hdG+zrz94KNCA939po9zzhyR2jvId1RxKpNnU66p
         XEZr7g0R6CW/A9fFp4OC5nS3LbhDGDsGtyz1bn8juaOzVzKzTXZta1fIhGNUTR1G+kG1
         KTH9M0cdXJTxHz2U/uQ5SoeDX74rsySPg53eU70JPYVWULu+Iyq8T5E+s5t5hAm2biKn
         u33IxsYy7xbHSLS4XL6ST4/lzBBPSUHnoIkTHpi1hwFg/E+95NSW6l/TcRpca8xzBtHF
         koDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id v1si43681921ljc.13.2019.07.25.01.23.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 01:23:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.92)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hqZ1x-0001Op-1z; Thu, 25 Jul 2019 11:23:17 +0300
Subject: Re: [PATCH] mm/rmap.c: remove set but not used variable 'cstart'
To: YueHaibing <yuehaibing@huawei.com>, akpm@linux-foundation.org,
 jglisse@redhat.com, kirill.shutemov@linux.intel.com,
 mike.kravetz@oracle.com, rcampbell@nvidia.com, colin.king@canonical.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190724141453.38536-1-yuehaibing@huawei.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <1d0acd5c-bd49-4d4a-2005-5386b38109dd@virtuozzo.com>
Date: Thu, 25 Jul 2019 11:23:05 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190724141453.38536-1-yuehaibing@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 24.07.2019 17:14, YueHaibing wrote:
> Fixes gcc '-Wunused-but-set-variable' warning:
> 
> mm/rmap.c: In function page_mkclean_one:
> mm/rmap.c:906:17: warning: variable cstart set but not used [-Wunused-but-set-variable]
> 
> It is not used any more since
> commit cdb07bdea28e ("mm/rmap.c: remove redundant variable cend")
> 
> Reported-by: Hulk Robot <hulkci@huawei.com>
> Signed-off-by: YueHaibing <yuehaibing@huawei.com>

Reviewed-by: Kirill Tkhai <ktkhai@virtuozzo.com>

> ---
>  mm/rmap.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index ec1af8b..40e4def 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -903,10 +903,9 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
>  	mmu_notifier_invalidate_range_start(&range);
>  
>  	while (page_vma_mapped_walk(&pvmw)) {
> -		unsigned long cstart;
>  		int ret = 0;
>  
> -		cstart = address = pvmw.address;
> +		address = pvmw.address;
>  		if (pvmw.pte) {
>  			pte_t entry;
>  			pte_t *pte = pvmw.pte;
> @@ -933,7 +932,6 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
>  			entry = pmd_wrprotect(entry);
>  			entry = pmd_mkclean(entry);
>  			set_pmd_at(vma->vm_mm, address, pmd, entry);
> -			cstart &= PMD_MASK;
>  			ret = 1;
>  #else
>  			/* unexpected pmd-mapped page? */
> 

