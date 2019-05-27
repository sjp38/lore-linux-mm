Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D41BEC07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 07:42:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 967942075B
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 07:42:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 967942075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1434E6B000C; Mon, 27 May 2019 03:42:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F5C56B0266; Mon, 27 May 2019 03:42:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00A086B026B; Mon, 27 May 2019 03:42:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC9706B000C
	for <linux-mm@kvack.org>; Mon, 27 May 2019 03:42:39 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id i3so6048937plb.8
        for <linux-mm@kvack.org>; Mon, 27 May 2019 00:42:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=J5I4j1Hti2yfs8VW+Ja4Ke4bGwI3St88SlVFLetH7Ww=;
        b=nmpEUSOZ10QXRFUsqc8Iqz0aup5edFaXSJA09+XqOZwVF/+UKYrnuW0vpQZDvTeTuK
         aZH9fSWnjMtxUQFYB2YWPj0wH1/6aW32GEjBisnXgwOuUBB+oNMIwjXvj24xE++ura21
         kC2UgphA3zCVXmYCq8a9Rv+rUfGTXC57cuxpyItAf8JFn447fCK036Ud9n/e5ONUym9Q
         IrepiMey+k5DTXIVoQKu/szwLMLcITTGYkXyCPx//9lPNFrIGlqAUGkusM4fsSij0ALG
         4FRLnZk5rcAxVL8prYbshVVBmxJEGWAnRTG7mP7DlqSAnOhjl58L36X2JO/ke+sC7dml
         0KJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAU0VIJLKfPqBc/fi1ZoEEisBKkp6DBfaBBacrXnRV6nMyCvH+OT
	O1B+tf7PIE5/BQUdiBn658Ezp5/HDcg3gHEEE6V0eqNCzSJi3/tcQYRU0D5B8DosJ2Hq8EKV+fp
	ELfoe2tQKo9yQQuIdNrYdW0FvaeS2KKgcR4b4NFEqkTw6j+E82+6cz/YmxRAXijC8fQ==
X-Received: by 2002:a17:90a:d582:: with SMTP id v2mr28385768pju.22.1558942959389;
        Mon, 27 May 2019 00:42:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRbrWi9pknZXWa3urmEXrKIIuoTdGszARx1YswPSpCZmBhQlFvvfzrf4TZ2V0l7EwGw7Co
X-Received: by 2002:a17:90a:d582:: with SMTP id v2mr28385656pju.22.1558942958231;
        Mon, 27 May 2019 00:42:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558942958; cv=none;
        d=google.com; s=arc-20160816;
        b=fHj/GRCL+1tPnzWqANLH/MGtraFSWjc+LPrQNHW1WC+ZZZPRxWRfWq/DM1CPIt4AWK
         iZBZ+YureDybrCDiwuM23eR+X9xZVQbA9XHJR9FE2jNS6mRwrvQfTp7BMvJ5q+dyFzOy
         pEeMIyvu2TQhuCj9YEy3gTEnL4Ca3JZ9Bt5ze1N5RfuS2a9gJVQNnil+CkXGWa0bMMVx
         vU5ShGlnih14kmCa7WirSqCsGJb6CY9XcDnJVpXlFapYIJkqu07AQY0Ep+zOlkitSm4A
         R2qZvuzozgKU9+W4mKLU5Iw9XusmLPHHJ90Ug8/uMfjckx6lUofjYDX/Gv3Ga/2FexzG
         Co+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=J5I4j1Hti2yfs8VW+Ja4Ke4bGwI3St88SlVFLetH7Ww=;
        b=Ah/0UEbdDmVnVpK1iTOj9ua2xPjHjdjgnell55HuaS1ga6S80r6Wi91rcOIcEP8J6G
         zuQXgvDaclldcWi26ZPlu0XuE3OK30+KlvKF8AccVSWaQJ7MPIB1HQQNUGD24MXvr5qs
         5fKsItZAiGKX0WVT6XheneID2fLogPjCOp0u4PGPR0/Pzum00Y9Jk6LgPnHHcXUNB7+p
         VWwmk7n+rYHWsa5AibjKQfaBiUZpQUgZ9liH+60aLY2Lg3fNhH0vaHCAcCMhdMrVe0cV
         myj6L2iADnfd58DzZBnjSUr9PQWup7cTQGgN60c46eO3YMbCNdQ2p9yOD0juRq8KAWqy
         J7pw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id i22si15899204pju.81.2019.05.27.00.42.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 00:42:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TSnEAVx_1558942942;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TSnEAVx_1558942942)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 27 May 2019 15:42:23 +0800
Subject: Re: [PATCH] mm: vmscan: Add warn on inadvertently reclaiming mapped
 page
To: Hillf Danton <hdanton@sina.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>,
 Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
References: <20190526062353.14684-1-hdanton@sina.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <6168defb-06e3-7e98-3e7d-32c71e654fed@linux.alibaba.com>
Date: Mon, 27 May 2019 15:42:21 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <20190526062353.14684-1-hdanton@sina.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/26/19 2:23 PM, Hillf Danton wrote:
> In the function isolate_lru_pages(), we check scan_control::may_unmap and set
> isolation mode accordingly in order to not isolate from the lru list any page
> that does not match the isolation mode. For example, we should skip all sill
> mapped pages if isolation mode is set to be ISOLATE_UNMAPPED.
>
> So complain, while scanning the isolated pages, about the very unlikely event
> that we hit a mapped page that we should never have isolated. Note no change
> is added in the current scanning behavior without VM debug configured.
>
> And cut off one line of comment that goes stale.

Looks good to me. Reviewed-by: Yang Shi <yang.shi@linux.alibaba.com>

>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Yang Shi <yang.shi@linux.alibaba.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Hillf Danton <hdanton@sina.com>
> ---
>   mm/vmscan.c | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d9c3e87..799ad9e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1134,8 +1134,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>   		if (unlikely(!page_evictable(page)))
>   			goto activate_locked;
>   
> -		if (!sc->may_unmap && page_mapped(page))
> +		if (!sc->may_unmap && page_mapped(page)) {
> +			VM_WARN_ON(true);
>   			goto keep_locked;
> +		}
>   
>   		/* Double the slab pressure for mapped and swapcache pages */
>   		if ((page_mapped(page) || PageSwapCache(page)) &&
> @@ -1632,7 +1634,6 @@ static __always_inline void update_lru_sizes(struct lruvec *lruvec,
>    * @dst:	The temp list to put pages on to.
>    * @nr_scanned:	The number of pages that were scanned.
>    * @sc:		The scan_control struct for this reclaim session
> - * @mode:	One of the LRU isolation modes
>    * @lru:	LRU list id for isolating
>    *
>    * returns how many pages were moved onto *@dst.
> --

