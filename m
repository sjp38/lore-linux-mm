Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 493ADC5B579
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:53:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16B82205F4
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:53:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16B82205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEE746B0003; Fri, 28 Jun 2019 14:53:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9F2E8E0007; Fri, 28 Jun 2019 14:53:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98D018E0002; Fri, 28 Jun 2019 14:53:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f78.google.com (mail-io1-f78.google.com [209.85.166.78])
	by kanga.kvack.org (Postfix) with ESMTP id 78DDB6B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 14:53:24 -0400 (EDT)
Received: by mail-io1-f78.google.com with SMTP id r27so7590480iob.14
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:53:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=SP1JOZtvrsQNHsgJFRuda84Pm8hd9dSywWTvq2N+Tq4=;
        b=Obxc5k9Fhv0h78WexlKXvEgQ1v7eOV6iKGPn85Z92H/nJ4NR+hroZSXb+7BxalQysE
         37mOhoYhkqY+kkza4We605JcF3rZPABaElCLmplRs/91Pv6ipYqMsTPjnVMCXyyoo37o
         +faUdW3/ncSDF+a/D9uUw0wFX0ZtaVGeyQkEiqFu9u05jCUFH6YUEim+un33pePI3+eq
         +yVCUqg7dnSrgdvDScTzbR+WQpSVWPWLygjX5cpKCLh2rhGBnAO83dkhHa/f6R7ZukxI
         oVdSH6QfCGDYQXANj99YE7e7WZKGOiTfpSXLOIRHUkt1aFGjKpLJQ30Vegr3N311mdkh
         MlhQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAX5xUUhhnoS5jLkiqCcscsBZ8cZKt7j7llUOENATwnnBQZ00qw4
	3gcyPgfeInEDICi1lY4j5Gr++G3PgYpGX5iBt7zWApbXGuIO/dP1ysVKrp96NbnPy+VDMQYXE0F
	PezE/ZiynoUKL2h/IFbzYthjm/Vivxu7yKPejySYPV2AxYbqWAcXwjE8NISNJSYOJZA==
X-Received: by 2002:a5d:97d8:: with SMTP id k24mr9002811ios.84.1561748004285;
        Fri, 28 Jun 2019 11:53:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyT+4o0JtLIUMZlzKkhtvWprTC8NmLynOcO7Kwyis/ecMVCYN+u2lcD1y8znQYeg6fHkNW1
X-Received: by 2002:a5d:97d8:: with SMTP id k24mr9002748ios.84.1561748003471;
        Fri, 28 Jun 2019 11:53:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561748003; cv=none;
        d=google.com; s=arc-20160816;
        b=GCrZ4wBL2DD6E3k5xPlpLt85n6kgYVCy48HbPh+IpsdP9ZZoMAbTlYS+F7u9X+R57y
         99wdoMsQtktwli7A8P1E96GuiJ31jV1oe1QF6jFnDJjAujUagJewzFcx/oGdBhS+4hQt
         nDXF6zCQWtD+4PShnpfxlit5jqHgUS+7f6wVJFGlyTR7cfJP0oA7Hcb8u0SAp1P0wd3c
         R6w4lVtF6VoYtwr6i6qN4BOSOh9U0+x8GEYUpBqzn6VCr0q5O0bnxt4HNtAPdLWHw7dn
         Ir0HnOTpHSyRAiBHFDV4BMCBAkni9Y9Cc167LlHTA123NYRGhaLySsQHeSmS6npCh1Qp
         /DUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=SP1JOZtvrsQNHsgJFRuda84Pm8hd9dSywWTvq2N+Tq4=;
        b=CnZmUpt1OmLkrqW3HLcufmzx+zC3mCqjCBgNg0Vik94kyLVELx/CtdraNUoWkjEm1A
         A8BopMIk80iHTlKnaWzC2e0lkU38FnzqEDxTqDYpalB3FegtcjhB/TFAXxjpCzeURVm7
         d/QMu5X7pNALyKNWn/RM1K87GlpPc0v4X8r4oyMsB8yoMa/820eITxJfzme/41KeK+n0
         yFwMe8Mxn0WGkQYoloFArqq6+7qdpRNdBbsvhqNkQB0t5zGG9YLqHGETePXVbQIn09p9
         sp10u4IxSMvTiWl2YdmMPXaW4f0I/IHt4pI9D7dUnpeezOBJxaFEZhBOt9FknwMd8SBY
         gOkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id a20si4496181ios.80.2019.06.28.11.53.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 11:53:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R931e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TVRxcr9_1561747966;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TVRxcr9_1561747966)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 29 Jun 2019 02:52:57 +0800
Subject: Re: [PATCH] mm, vmscan: prevent useless kswapd loops
To: Shakeel Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>,
 Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>,
 Hillf Danton <hdanton@sina.com>, Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190628015520.13357-1-shakeelb@google.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <6e28c8ce-96e1-5a1e-bd06-d1df5856094e@linux.alibaba.com>
Date: Fri, 28 Jun 2019 11:52:46 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190628015520.13357-1-shakeelb@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 6/27/19 6:55 PM, Shakeel Butt wrote:
> On production we have noticed hard lockups on large machines running
> large jobs due to kswaps hoarding lru lock within isolate_lru_pages when
> sc->reclaim_idx is 0 which is a small zone. The lru was couple hundred
> GiBs and the condition (page_zonenum(page) > sc->reclaim_idx) in
> isolate_lru_pages was basically skipping GiBs of pages while holding the
> LRU spinlock with interrupt disabled.
>
> On further inspection, it seems like there are two issues:
>
> 1) If the kswapd on the return from balance_pgdat() could not sleep
> (maybe all zones are still unbalanced), the classzone_idx is set to 0,
> unintentionally, and the whole reclaim cycle of kswapd will try to reclaim
> only the lowest and smallest zone while traversing the whole memory.
>
> 2) Fundamentally isolate_lru_pages() is really bad when the allocation
> has woken kswapd for a smaller zone on a very large machine running very
> large jobs. It can hoard the LRU spinlock while skipping over 100s of
> GiBs of pages.
>
> This patch only fixes the (1). The (2) needs a more fundamental solution.
>
> Fixes: e716f2eb24de ("mm, vmscan: prevent kswapd sleeping prematurely
> due to mismatched classzone_idx")
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
>   mm/vmscan.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 9e3292ee5c7c..786dacfdfe29 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3908,7 +3908,7 @@ static int kswapd(void *p)
>   
>   		/* Read the new order and classzone_idx */
>   		alloc_order = reclaim_order = pgdat->kswapd_order;
> -		classzone_idx = kswapd_classzone_idx(pgdat, 0);
> +		classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);

I'm a little bit confused by the fix. What happen if kswapd is waken for 
a lower zone? It looks kswapd may just reclaim the higher zone instead 
of the lower zone?

For example, after bootup, classzone_idx should be (MAX_NR_ZONES - 1), 
if GFP_DMA is used for allocation and kswapd is waken up for ZONE_DMA, 
kswapd_classzone_idx would still return (MAX_NR_ZONES - 1) since 
kswapd_classzone_idx(pgdat, classzone_idx) returns the max classzone_idx.

>   		pgdat->kswapd_order = 0;
>   		pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
>   

