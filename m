Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D2EBC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 21:50:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8DEC2173E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 21:50:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8DEC2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 674C86B0003; Mon,  1 Jul 2019 17:50:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 625498E0003; Mon,  1 Jul 2019 17:50:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4ECD58E0002; Mon,  1 Jul 2019 17:50:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f208.google.com (mail-pl1-f208.google.com [209.85.214.208])
	by kanga.kvack.org (Postfix) with ESMTP id 17C9F6B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 17:50:13 -0400 (EDT)
Received: by mail-pl1-f208.google.com with SMTP id 59so7873194plb.14
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 14:50:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=T2u4+/W53YKTxFJoPGPjndLDL9DluTp7wyUpeg48GFU=;
        b=JrF73TGBDHCz5T6rnz+VfiBiIZ/HH7ey1RcYe6UEF26TrgL13mAxKPf8GN5pwgTV1u
         v/RX3CpY+CnEcLAWQlrvtnmZkhehptufX9QFA38wHMUVp32xz48cuLFv2B5Fy1nOfbI/
         AMngJSo0SPUTLK8d/05o8cmcOKOGjCHaIndddChN0npdB6VjyKpTo1A6GQiTGrRGJ7x/
         OoootP2Yc6OpXA4CSh4aVdx8GkZy6D7tnhi5c3SrUgW97JsTZE/UIbxIxxj+YyA+hDOF
         GLZ3uogEnLRRjj7obF/YeNp8EvrqbQ+OKd/hKAtCMWUMY47WXrUIlpSaJs+pyS9XqV79
         En+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXYYKooBCkUl64PjcYLM+ojrbdooi9D0yqWhtPXr3NwOYXLBd3L
	97I9gNaQlZQA2yoGXf7dUDuDnGNZL4XJcq0vA94HzCZTTtHPNvJiF0wAZKHucVWNDkHuAuqKkj9
	d+ciy4W7RW0v/Xk3+dQsXVEHQaup9IEm2vhTr/YAGmIAB1jlJ9zU23wQ1RpJXEACEVw==
X-Received: by 2002:a63:5202:: with SMTP id g2mr26856820pgb.386.1562017812652;
        Mon, 01 Jul 2019 14:50:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYz6XvrbLqEBBs6+qNISpxYbjR3iIejqioQNh+CSxZCSM92V0W9gPSTKWplg69athhIZOc
X-Received: by 2002:a63:5202:: with SMTP id g2mr26856733pgb.386.1562017811437;
        Mon, 01 Jul 2019 14:50:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562017811; cv=none;
        d=google.com; s=arc-20160816;
        b=g0ucnYvEPPdWZamLBp69ApjyZM11C9OlZWz0b6ZOcNqBB22Kqa0q43kaHuynQlnjLo
         BG13K9/CZgxLAMGE7SoymHewVEYFMqCLKJndDDNQkn4F4GqoeU2OZ91Wmnpvu1UN9QJu
         K67Wun+VglazOWFJQBCVxT6jjHF+WcN/6OC5/rH8lAtK2ZKL9F+0Vj8FwWNONPdDUQXy
         VjLGsXGvyG3SBhLb8t/73kig46W68H9g/uyTkqMn9D20KgEiPzfOWqFWC5ECSB5PTqSy
         dVZ8ciCyj4ofqEe/SjxSmpBCA27OQohwv1/TXonU/eS9ok3ghmLLwCK7I//yXvIOkpge
         xABA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=T2u4+/W53YKTxFJoPGPjndLDL9DluTp7wyUpeg48GFU=;
        b=nz3AMyprGuty7oZJcWxeIAHzFp/5COigLeCaxMoMbCrtuZ4ge/U539ucv/1y/VMp+Z
         a5d57LxLSRwR+WlDcyjifa3jX9/IP0VWXvcfslM3HGcEgODMflsUIHnQPFXmcZHmhoN5
         kY6DKD6QjRe2HkuyRh/iydA9yVOxzsKcYHSvGz6eU3OcGj2LWoYB5tfAy+WOoy4ZZgPW
         omhP/YJwB+P31jueUBBhu+xaLviS0DfTKevh8chPGldmEYSIPdPj9eo6jU9dXZcroQYv
         9ZJEUklrt2iu2D3HnWmzH+bulikx28/mub6rO2hS/IpvfhUwRm9sclIDrGF4warxQujc
         PluA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id a3si11904506pff.117.2019.07.01.14.50.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 14:50:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R501e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TVobKD8_1562017791;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TVobKD8_1562017791)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 02 Jul 2019 05:50:07 +0800
Subject: Re: [PATCH v2] mm, vmscan: prevent useless kswapd loops
To: Shakeel Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>,
 Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>,
 Hillf Danton <hdanton@sina.com>, Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190701201847.251028-1-shakeelb@google.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <350a5c6f-4cf2-953e-7b6c-89460b11d297@linux.alibaba.com>
Date: Mon, 1 Jul 2019 14:49:50 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190701201847.251028-1-shakeelb@google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/1/19 1:18 PM, Shakeel Butt wrote:
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
> (i.e. node is still unbalanced), the classzone_idx is unintentionally
> set to 0  and the whole reclaim cycle of kswapd will try to reclaim
> only the lowest and smallest zone while traversing the whole memory.
>
> 2) Fundamentally isolate_lru_pages() is really bad when the allocation
> has woken kswapd for a smaller zone on a very large machine running very
> large jobs. It can hoard the LRU spinlock while skipping over 100s of
> GiBs of pages.
>
> This patch only fixes the (1). The (2) needs a more fundamental solution.
> To fix (1), in the kswapd context, if pgdat->kswapd_classzone_idx is
> invalid use the classzone_idx of the previous kswapd loop otherwise use
> the one the waker has requested.
>
> Fixes: e716f2eb24de ("mm, vmscan: prevent kswapd sleeping prematurely
> due to mismatched classzone_idx")
>
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
> Changelog since v1:
> - fixed the patch based on Yang Shi's comment.
>
>   mm/vmscan.c | 27 +++++++++++++++------------
>   1 file changed, 15 insertions(+), 12 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 9e3292ee5c7c..eacf87f07afe 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3760,19 +3760,18 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>   }
>   
>   /*
> - * pgdat->kswapd_classzone_idx is the highest zone index that a recent
> - * allocation request woke kswapd for. When kswapd has not woken recently,
> - * the value is MAX_NR_ZONES which is not a valid index. This compares a
> - * given classzone and returns it or the highest classzone index kswapd
> - * was recently woke for.
> + * The pgdat->kswapd_classzone_idx is used to pass the highest zone index to be
> + * reclaimed by kswapd from the waker. If the value is MAX_NR_ZONES which is not
> + * a valid index then either kswapd runs for first time or kswapd couldn't sleep
> + * after previous reclaim attempt (node is still unbalanced). In that case
> + * return the zone index of the previous kswapd reclaim cycle.
>    */
>   static enum zone_type kswapd_classzone_idx(pg_data_t *pgdat,
> -					   enum zone_type classzone_idx)
> +					   enum zone_type prev_classzone_idx)
>   {
>   	if (pgdat->kswapd_classzone_idx == MAX_NR_ZONES)
> -		return classzone_idx;
> -
> -	return max(pgdat->kswapd_classzone_idx, classzone_idx);
> +		return prev_classzone_idx;
> +	return pgdat->kswapd_classzone_idx;
>   }
>   
>   static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_order,
> @@ -3908,7 +3907,7 @@ static int kswapd(void *p)
>   
>   		/* Read the new order and classzone_idx */
>   		alloc_order = reclaim_order = pgdat->kswapd_order;
> -		classzone_idx = kswapd_classzone_idx(pgdat, 0);
> +		classzone_idx = kswapd_classzone_idx(pgdat, classzone_idx);
>   		pgdat->kswapd_order = 0;
>   		pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
>   
> @@ -3961,8 +3960,12 @@ void wakeup_kswapd(struct zone *zone, gfp_t gfp_flags, int order,
>   	if (!cpuset_zone_allowed(zone, gfp_flags))
>   		return;
>   	pgdat = zone->zone_pgdat;
> -	pgdat->kswapd_classzone_idx = kswapd_classzone_idx(pgdat,
> -							   classzone_idx);
> +
> +	if (pgdat->kswapd_classzone_idx == MAX_NR_ZONES)
> +		pgdat->kswapd_classzone_idx = classzone_idx;
> +	else
> +		pgdat->kswapd_classzone_idx = max(pgdat->kswapd_classzone_idx,
> +						  classzone_idx);
>   	pgdat->kswapd_order = max(pgdat->kswapd_order, order);
>   	if (!waitqueue_active(&pgdat->kswapd_wait))
>   		return;

I agree the manipulation to classzone_idx looks convoluted. This version 
looks correct to me. You could add: Reviewed-by: Yang Shi 
<yang.shi@linux.alibaba.com>


