Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37F1EC606CF
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 22:53:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8E6C205ED
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 22:53:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8E6C205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82D938E0038; Mon,  8 Jul 2019 18:53:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B6B58E0032; Mon,  8 Jul 2019 18:53:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 680E28E0038; Mon,  8 Jul 2019 18:53:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5578E0032
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 18:53:17 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 6so11180161pfz.10
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 15:53:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=SHm+OoQcxUzINuDOA0oBfuERyw7S9vPg0Y52axk87Ck=;
        b=WSjeqZr/sdTUksv1YzEaFWdgoMO2abSmUWipJDFj5yuwnXiAJb7GjMHgKX1RSk81mA
         f977VVUEwVi8rmQpA+pJCfzUBVcbAvRL9x5nhi9LkzBbff+TCKaRP5rkOiwpVmoApIku
         PAwpj/KM9ZgnkSb3RZg3C3rPiv5ceVFR2FVdxgkdJqfA2lLUYhBlK6wRvLJaoLrIVV6c
         9UFjuMXScEKPqEJTFttZBIWZ53YqSBfLKM5u/03lyPGMNbGqnfiH2o1mkx81Wrs/loao
         dbyBPrLcD99BBTg7sxcugq1SAb1iQDk6noBI9Ngm4jfEH7/YeA8mdtqCS/0p4EIebusw
         HTpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVH43Fm60tLZtlLbzINWk0Yfj2C4ewpOXS6CAicOYx86vSC8zx8
	bEYC2tXLoiX+qkG86JQYUztD5yElB/P6on7j6woq7menbsDg4R0kmLBpOLFGWE4qlYJ4mvsUVKO
	+aYPybWP3eWH69LbHwYjPZjCa9Z3EP6Y9BYptf4iZcE9j1jkiflq2uNf2llA2xT2JMg==
X-Received: by 2002:a17:90a:1b4a:: with SMTP id q68mr28774518pjq.61.1562626396822;
        Mon, 08 Jul 2019 15:53:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8lu7ZlzaZodk+l9TUW3AJAVUFD0ozSNY40ebUu0of17MG5NapDyLkkjRdFmhPin0QDLJy
X-Received: by 2002:a17:90a:1b4a:: with SMTP id q68mr28774488pjq.61.1562626396175;
        Mon, 08 Jul 2019 15:53:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562626396; cv=none;
        d=google.com; s=arc-20160816;
        b=ecmBW7Mb5v22r5TCGQGeXSWeqkV5t/LRjTXgu9dtl0l7YxUBDANMOUnESK0kkovJiT
         dEh+s3c2qanOJQiwHJ58EpMTFtQnYVH/R4/CX3rizHs/5bfzGVyGRMWrfJKQ0tjfDa0l
         I4pkHRRrXyy2ZskuyxINNesKjTnERxycc+r5yxOQY1n+jPN2+T8bbaEOA92HgT4PpCUD
         kLaTimA1weWK/4Ji6qimliQ6Cu6H1ImufnADfkVHS+KWOOF39L0BtS/R2Q70SJCpGrFp
         lMhBqpEgwzqOIEp0TO2yUaIyaSlrNNCe9JkfZKnUM4wW0dW9DN59SFM5/LBRvzESDS7+
         /vZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=SHm+OoQcxUzINuDOA0oBfuERyw7S9vPg0Y52axk87Ck=;
        b=yyZ4CdlSgi91jvNP8VC3iWSE3AtwHLdiyFLh2G39BPmahb61HrExv40pTCiJ3J9VDK
         t8YMU4UGBk/L7J1Zv30dxBWCtdUgLBMeFNz86lLGL1+hcDvliUXLJpe7lL2CYGXF0fmM
         2RiiP73+qVaIkeqIxXhp7jyK+M0zHf0tocIl3UK5gMTRx2X8++keXYxjAu1jRRh5ChtB
         UhI5R5VVwtaaI1HpxnFrWDPXQkv8JxunmxnsgO2lDK9MvpgN8dLtNy2d/AhQQcnJLG4C
         WPcAENslM/bWbrmadOsNjTk5w3sFyuAqjnmidLcsWQ+fTywigANhvgRwbWKSJB4EGTLw
         Kq9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id 4si18901398pfo.266.2019.07.08.15.53.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 15:53:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R131e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TWPu3JF_1562626390;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TWPu3JF_1562626390)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 09 Jul 2019 06:53:13 +0800
Subject: Re: [PATCH 2/2 -mm] mm: account lazy free pages into available memory
To: rientjes@google.com, kirill.shutemov@linux.intel.com, mhocko@suse.com,
 hannes@cmpxchg.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1561655524-89276-1-git-send-email-yang.shi@linux.alibaba.com>
 <1561655524-89276-2-git-send-email-yang.shi@linux.alibaba.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <18a6c461-5300-34ec-3a0f-266c72a2733b@linux.alibaba.com>
Date: Mon, 8 Jul 2019 15:53:05 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <1561655524-89276-2-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

And how about this one?


On 6/27/19 10:12 AM, Yang Shi wrote:
> Available memory is one of the most important metrics for memory
> pressure.  Currently, lazy free pages are not accounted into available
> memory, but they are reclaimable actually, like reclaimable slabs.
>
> Accounting lazy free pages into available memory should reflect the real
> memory pressure status, and also would help administrators and/or other
> high level scheduling tools make better decision.
>
> The /proc/meminfo would show more available memory with test which
> creates ~1GB deferred split THP.
>
> Before:
> MemAvailable:   43544272 kB
> ...
> AnonHugePages:     10240 kB
> ShmemHugePages:        0 kB
> ShmemPmdMapped:        0 kB
> LazyFreePages:   1046528 kB
>
> After:
> MemAvailable:   44415124 kB
> ...
> AnonHugePages:      6144 kB
> ShmemHugePages:        0 kB
> ShmemPmdMapped:        0 kB
> LazyFreePages:   1046528 kB
>
> MADV_FREE pages are not accounted for NR_LAZYFREE since they have been
> put on inactive file LRU and accounted into available memory.
> Accounting here would double account them.
>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>   mm/page_alloc.c | 5 +++++
>   1 file changed, 5 insertions(+)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index cab50e8..58ceca5 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5005,6 +5005,7 @@ long si_mem_available(void)
>   	unsigned long wmark_low = 0;
>   	unsigned long pages[NR_LRU_LISTS];
>   	unsigned long reclaimable;
> +	unsigned long lazyfree;
>   	struct zone *zone;
>   	int lru;
>   
> @@ -5038,6 +5039,10 @@ long si_mem_available(void)
>   			global_node_page_state(NR_KERNEL_MISC_RECLAIMABLE);
>   	available += reclaimable - min(reclaimable / 2, wmark_low);
>   
> +	/* Lazyfree pages are reclaimable when memory pressure is hit */
> +	lazyfree = global_node_page_state(NR_LAZYFREE);
> +	available += lazyfree - min(lazyfree / 2, wmark_low);
> +
>   	if (available < 0)
>   		available = 0;
>   	return available;

