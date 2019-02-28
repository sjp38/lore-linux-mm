Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35780C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 21:56:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E74D620675
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 21:56:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E74D620675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F1418E0003; Thu, 28 Feb 2019 16:56:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A1AD8E0001; Thu, 28 Feb 2019 16:56:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68F348E0003; Thu, 28 Feb 2019 16:56:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 118438E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 16:56:50 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id h16so9102176edq.16
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 13:56:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=G9FVqmPGfbV2nh5IFsLul1hD5yn9e1TBUbSLtPF4MaU=;
        b=AtJWPZzzXH5UFq68+b7I5Oj7XehcE74XjdWOyBvVTHfdRwuRPVYNeZMEOCnp9rkWi4
         mDtpJGgcTHeVmVZ/oMLUn+6PtZlnUt1yKcw3YvfQMBbZuEpwEuTCYg3gqMz6fUnTFXkZ
         8kv1kLGojjPAEL2+uqSsauYexevX1VNmhFnyisMRMMrVmyNzQ2o4wQT10tOJNt3UkeiN
         +CefsWEaSmclnML4Gp2QNM83P7ZzPcpEFmkSsXCLg7jXbdsBLFbFHtPa3nONKx4ypN1p
         vn8QJI95I/tZIbuVpmkOHcXXL96QZyiyUeeciOYp9BpQAZNQUyai03pHHZ3TfF6AndfO
         0YDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAU+zXVSS60r4m9z0JJyPyDwOeczDoFNcX6mliY2DrS7Wf9g5coR
	63/7gax6iQ4D7y38ChChRzKUt4M7LMO4MP9TfLDxyw+HFoRLdXYyQS0zSUUr1jYeVSi97SMLSPK
	PfPeRIOqvyg+/o7OtQxZ0BWx2DdNuYjQSq7D57NHartaPFZItlzULITSXvNE/wWh05A==
X-Received: by 2002:a50:ed0b:: with SMTP id j11mr1434499eds.102.1551391009574;
        Thu, 28 Feb 2019 13:56:49 -0800 (PST)
X-Google-Smtp-Source: APXvYqwX5SWANi83i5RvQFDkv4kWfopMbIiSnIdRttJUW3lltsbxKkrAx3JiXmCFI2Zo1ekCzJq5
X-Received: by 2002:a50:ed0b:: with SMTP id j11mr1434464eds.102.1551391008686;
        Thu, 28 Feb 2019 13:56:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551391008; cv=none;
        d=google.com; s=arc-20160816;
        b=gvJT/rHQPR0oIvoVIEwK0EWhfH1QmGok1E2gE4gwMPzZrwoUyAsOa3LevP5bH16c39
         BI2vOOwU+lvJkYsiRxbJQ7wSG7HMCtE8mio57s8drhdEQrpwym1jLAgXRb54c3HNrPgU
         e7HUiujad1/efU3ksKG/ysO7YWHjRlDJkEbjjMq0rC4xMgcH6IDeFFu6E4vwAXNGYZI2
         7KjqDCjM7wPcy8kvtzAnAWwuJHXXcUl1sqZtMJ80VXTKniyOzh3DKLxw8Yf8or6Ys589
         RmgNtjUycsmtfXCesspLECXMaEx1Q2MQF2L5aUvdyZc4ky+wtnEESvRcfzalyJUkXTLh
         0HbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=G9FVqmPGfbV2nh5IFsLul1hD5yn9e1TBUbSLtPF4MaU=;
        b=xl48luageTp4nXK6T+cV6ruxXDu/DwgbMorV6ekkbS2gnlMQS6zbzhm2cajLcPU9I9
         o1Gjkk89MbhFLyBLrp/LSGaDJFy+U+yMJeVChU1LO7QtphcRiXGXuVz+utknDP5YObRQ
         8lXRExnFx7bK/PStqsAgx9P7MEG81nOagsFqiTsHy05a/RtE7Rq2irS1OjedwoMfxohe
         aWMoiZeay9YoiuCItYb3DQkGydiQvLsczfImLsUF6ajA+VNyTWJ8XONTcJMVkJTNp+Pw
         WtL6eWscF61FEcwwtgDE3JPKK33EUVDNWOHyd5659PmjmITnKEPeYBrecwMkmJiZxJzT
         pHWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n11si2336784edn.99.2019.02.28.13.56.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 13:56:48 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 04C3AADD6;
	Thu, 28 Feb 2019 21:56:47 +0000 (UTC)
Subject: Re: [PATCH v2 2/4] mm: remove zone_lru_lock() function access
 ->lru_lock directly
To: John Hubbard <jhubbard@nvidia.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>
References: <20190228083329.31892-1-aryabinin@virtuozzo.com>
 <20190228083329.31892-2-aryabinin@virtuozzo.com>
 <44ffadb4-4235-76c9-332f-680dda5da521@nvidia.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <67a79bb9-12b5-e668-abb1-ef91a9cbfea8@suse.cz>
Date: Thu, 28 Feb 2019 22:56:35 +0100
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <44ffadb4-4235-76c9-332f-680dda5da521@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/28/2019 10:44 PM, John Hubbard wrote:
> Instead of removing that function, let's change it, and add another
> (since you have two cases: either a page* or a pgdat* is available),
> and move it to where it can compile, like this:
> 
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 80bb6408fe73..cea3437f5d68 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1167,6 +1167,16 @@ static inline pg_data_t *page_pgdat(const struct page *page)
>         return NODE_DATA(page_to_nid(page));
>  }
>  
> +static inline spinlock_t *zone_lru_lock(pg_data_t *pgdat)

In that case it should now be named node_lru_lock(). zone_lru_lock() was a
wrapper introduced to make the conversion of per-zone to per-node lru_lock smoother.

> +{
> +       return &pgdat->lru_lock;
> +}
> +
> +static inline spinlock_t *zone_lru_lock_from_page(struct page *page)

Ditto. Or maybe even page_node_lru_lock()?

> +{
> +       return zone_lru_lock(page_pgdat(page));
> +}
> +
>  #ifdef SECTION_IN_PAGE_FLAGS
>  static inline void set_page_section(struct page *page, unsigned long section)
>  {
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 842f9189537b..e03042fe1d88 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -728,11 +728,6 @@ typedef struct pglist_data {
>  
>  #define node_start_pfn(nid)    (NODE_DATA(nid)->node_start_pfn)
>  #define node_end_pfn(nid) pgdat_end_pfn(NODE_DATA(nid))
> -static inline spinlock_t *zone_lru_lock(struct zone *zone)
> -{
> -       return &zone->zone_pgdat->lru_lock;
> -}
> -
>  static inline struct lruvec *node_lruvec(struct pglist_data *pgdat)
>  {
>         return &pgdat->lruvec;
> 
> 
> 
> Like it?
> 
> thanks,
> 

