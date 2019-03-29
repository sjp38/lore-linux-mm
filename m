Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3483BC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 10:40:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAC612075E
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 10:40:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="WhcgmAeA";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="FUxNFofr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAC612075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 785EF6B000E; Fri, 29 Mar 2019 06:40:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 736DB6B0269; Fri, 29 Mar 2019 06:40:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64C4D6B026A; Fri, 29 Mar 2019 06:40:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 27B116B000E
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 06:40:53 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h15so1368381pgi.19
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 03:40:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:dmarc-filter
         :subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=MOwFYSgTdBBIGRgb3yeDcR3pbmrFQDBgPGPRQ8MYQyg=;
        b=fXIGCoe13XbvvDWhHob0po+Zc7gAipShpthp39sUk6P6ccJqwsfO2PP1wlCpBoCOGu
         B2rlJ/nANF+9K9SigEjoiC/33bHEKDHkTXrOqRhbhCJkEGukIxNmbnCAqQ6DglKDJBK0
         Dr+mIKngJmgUkWdTZCJ67OgI5yRvh3khcs2xVWnF+atzAO/Lf+J/geUb9k/Axzlx8nlK
         WCSlz9J0EuccQKWtN4UqNeyzY1mEXFjvnZU4JqCvHbHp3hTtF36LRTc006EZLzNjehFq
         DEyl6L/7bT6j85PZSbszeIDYgxymRr6ND7cAKRnd08DJO0ju/NKCZ65AZhb+FvEOR1zy
         gqtQ==
X-Gm-Message-State: APjAAAVl5DitpJTynKrQPkNlQub8zZoEX1oglHtYgsjrRs5IvB2YlY/T
	UR29i9nYs8D6UhYQew5aG/BTkzrXxv50shnpfFme0aEMZstBhlJHZVprw3BS0ic2VUif42dgFmE
	2NPXKWH047Msx/0z8ufJHPdg//IilOHE/mkxPczRizAWZL80DwZGsN5y0yNIbbI0WKA==
X-Received: by 2002:a65:4342:: with SMTP id k2mr45789080pgq.445.1553856052541;
        Fri, 29 Mar 2019 03:40:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3YcfmJLFYTguAXH3HGteGk8qO0uPtH8rVoutVrGMyzL9gyz7te5z6ONgZW8BHVKPdw0yx
X-Received: by 2002:a65:4342:: with SMTP id k2mr45789023pgq.445.1553856051638;
        Fri, 29 Mar 2019 03:40:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553856051; cv=none;
        d=google.com; s=arc-20160816;
        b=fq3Yoac+lcpx+y2rWj6A5zxpkdd1ZUokE3Mdk4OzSoQtnMUwK6nJqJhOMfLvbTPFHM
         lh9V0NbP57VhjJAawk/RMSHRhk6rfk/InuNZCkE2AJyMwMFUWblUnHfFF5Vx8udT7uER
         OFWs5gtlg5m4aTunY97K+nN20iCms0t0eYGIhK9RV5uNosPEzbzwyCXGyd3GEur/Gjhh
         CGrPdpiL0HSHUP1kOhF9XTy0Llv3Vvjfsjtbp3cHHwgBG+w59KR+pJJmT1ZqGUEsfr/x
         cc1QEm5vkTgf1o4dQ/kbYANJwOjpz56pNf0GQucF8b66dm3okVxIT/bDvMRO4xay4Tf4
         AgOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dmarc-filter:dkim-signature:dkim-signature;
        bh=MOwFYSgTdBBIGRgb3yeDcR3pbmrFQDBgPGPRQ8MYQyg=;
        b=SJHMOfaGZxJXdxgcn3AlkvxY3ko3sMQqsUAhE7bTK7EQLkaxpRGXiquVGx4So3Md1s
         0ClubC45SFu8LXTPxGdEVZElAHiUYbaaxtc0wtqEL9yJ2HvjyUlLOizdgzhDQt/Wzabz
         ZbB2gQz2BMclvQo0IcfkL1DxkUc+nTGbDYGICWQ+GxM20wbjkJm6YNf9zLOhb4/N1V14
         t0RRjRa6E9hLoBKb50KZuVH1uR+aEyzUuXhiYF+sG9798GxeQpN/nGEQTiG40BXnRTuv
         xNdLo3dO4G2cC4AdyUpaXEdNyVRuvhRNMQO8FO4AWYGxkmbXNYB7wdyzAXSiHrMX1608
         x6rg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=WhcgmAeA;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=FUxNFofr;
       spf=pass (google.com: domain of mojha@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=mojha@codeaurora.org
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id d2si1570318pgq.129.2019.03.29.03.40.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 03:40:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of mojha@codeaurora.org designates 198.145.29.96 as permitted sender) client-ip=198.145.29.96;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=WhcgmAeA;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=FUxNFofr;
       spf=pass (google.com: domain of mojha@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=mojha@codeaurora.org
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id 4586E6079C; Fri, 29 Mar 2019 10:40:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1553856051;
	bh=6UJq9H0yEsYd4R3+jgGK+moeeQ9mNyIzO2VgN16P4jY=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=WhcgmAeAnZz3C7CB+VmrjQ8m3NAZiyNsaIcraLxp6ILqvOkOMv25Fb4E/M+CkLMGu
	 FqRgMMUYAcC94cxAzLeOuW76OwSW5+7Eh7tzFPqHC0MUDOl6laC00uc90P4/4/MSlN
	 dTr0BbzHbKZkd9K8JFUH4jwHC4MIuhxkj3rGeI3Y=
Received: from [10.204.79.83] (blr-c-bdr-fw-01_globalnat_allzones-outside.qualcomm.com [103.229.19.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: mojha@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id 12D8060237;
	Fri, 29 Mar 2019 10:40:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1553856050;
	bh=6UJq9H0yEsYd4R3+jgGK+moeeQ9mNyIzO2VgN16P4jY=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=FUxNFofrBoBRI4jRCz0ejj8mWMH2UTW9p9rtjXXMxXRH5HaXvujViOhIguMQ34U5S
	 jchS215FqJt+hNpohVdWo//mQqHdfEhIvObgIaFcnPRnP87pbjFnWIi5PIOgwwgSlb
	 9oX43OCtJ4BlCvXicGVeKQUNy0g7ptMlHY8ry7fw=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org 12D8060237
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=mojha@codeaurora.org
Subject: Re: [PATCH v3 1/2] mm/sparse: Clean up the obsolete code comment
To: Baoquan He <bhe@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, rafael@kernel.org, akpm@linux-foundation.org,
 mhocko@suse.com, osalvador@suse.de, rppt@linux.ibm.com, willy@infradead.org,
 fanc.fnst@cn.fujitsu.com
References: <20190329082915.19763-1-bhe@redhat.com>
From: Mukesh Ojha <mojha@codeaurora.org>
Message-ID: <1a1ff1d0-3bfa-4f06-1534-c49c63a8b58d@codeaurora.org>
Date: Fri, 29 Mar 2019 16:10:44 +0530
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190329082915.19763-1-bhe@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 3/29/2019 1:59 PM, Baoquan He wrote:
> The code comment above sparse_add_one_section() is obsolete and
> incorrect, clean it up and write new one.
>
> Signed-off-by: Baoquan He <bhe@redhat.com>


Reviewed-by: Mukesh Ojha <mojha@codeaurora.org>

Cheers,
-Mukesh

> ---
> v2->v3:
>    Normalize the code comment to use '/**' at 1st line of doc
>    above function.
> v1-v2:
>    Add comments to explain what the returned value means for
>    each error code.
>   mm/sparse.c | 17 +++++++++++++----
>   1 file changed, 13 insertions(+), 4 deletions(-)
>
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 69904aa6165b..363f9d31b511 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -684,10 +684,19 @@ static void free_map_bootmem(struct page *memmap)
>   #endif /* CONFIG_MEMORY_HOTREMOVE */
>   #endif /* CONFIG_SPARSEMEM_VMEMMAP */
>   
> -/*
> - * returns the number of sections whose mem_maps were properly
> - * set.  If this is <=0, then that means that the passed-in
> - * map was not consumed and must be freed.
> +/**
> + * sparse_add_one_section - add a memory section
> + * @nid: The node to add section on
> + * @start_pfn: start pfn of the memory range
> + * @altmap: device page map
> + *
> + * This is only intended for hotplug.
> + *
> + * Returns:
> + *   0 on success.
> + *   Other error code on failure:
> + *     - -EEXIST - section has been present.
> + *     - -ENOMEM - out of memory.
>    */
>   int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>   				     struct vmem_altmap *altmap)

