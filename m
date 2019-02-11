Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CB49C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 08:59:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D509520818
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 08:59:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D509520818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B8D68E00D3; Mon, 11 Feb 2019 03:59:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 640FD8E00D2; Mon, 11 Feb 2019 03:59:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BB0C8E00D3; Mon, 11 Feb 2019 03:59:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1CF398E00D2
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 03:59:00 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id w124so11529808qkc.14
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 00:59:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=cZG8pweEg3COGd4FzuuyCBJqqeJZ9BxmaZwLjWtYDrk=;
        b=q7L72obUFzOgPK/bFX1IsrSNf2afdKfV3R0N6nCXiWMfrX8mDBmZTVBKuGVdrxU5pf
         8s5unUIxU40BUAECp17Pzu+Az7jeLpCEgsGoms9u4z6fZt0c8GzEVo/gErU0XGpFf3D/
         rTKglO2s+WY8KQCidV/lel2GS/XvsvdkEM6lmU/kvQOHKFXuO2UM0soD3IF/oes+3CjC
         ojgLa+D9xBupg3tnNWl+rT7Pqa6xTXHXohior1iS16kd8odMPi+yWJBDoMogVmsnbakt
         cFVBMUsnZl+MZ2IB9oAYVzh7wiC2gM0+wYhXrPg71/e3/v4Xmv2PBLZIXZtlIhtVKoRo
         pnIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYDY+drxl2jYZwPj/gWwoOilKS2tImlJIX8qTNwleiJ0b6F8qaE
	2X1hJD/6FSpgOTQJDbnZFkgBjQfKTW0XZoDLx1RobyRtNh4xzQakyvHz0hIzqgKIq4NTUf2pcen
	syIcuZCEQT2Y3jSuoOpTkC4wA8KvGS0E/q8bNsB76+yPnf5JYWwSzur6DrrL0WvPuzw==
X-Received: by 2002:ac8:2ca9:: with SMTP id 38mr26812448qtw.338.1549875539759;
        Mon, 11 Feb 2019 00:58:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZYgLJFf28n/S4TQKwdElZ7RaQSosZ68f/DXwZqqJqvDut2ptpZBqItZEnMTUuV3FOMpU8M
X-Received: by 2002:ac8:2ca9:: with SMTP id 38mr26812431qtw.338.1549875539352;
        Mon, 11 Feb 2019 00:58:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549875539; cv=none;
        d=google.com; s=arc-20160816;
        b=ieNEXeYoBF99xJA6c6JmHo2stw+pw3pvZQE8GL3uRAfqQRCY1y2J4iN4vkjqUDXnto
         +V9khh5hiRKP1M+zczOjKv3I/LWF4hAngaYCdegGJVuB2NMSpOKvYfwIyjWi7D8iDOW/
         tQrF2HjAB+Px1uqd1q8DRVghgYeVG7giVyZHkXI3GGUqgitEs1gfCtQhLehAXTWKDTaG
         gpR9KJF8S6hnzVt9y82FUih6A9egtzvgD8idjlBmm/rwax8tAxHXVhTvz+qKU6MnZpi5
         6g76cOopdhA24GEthgBV8EmfyiG6ELKqngXgHEmoXQkBjbnn4Ke6k//MOCsnS3XsTLs7
         /JbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=cZG8pweEg3COGd4FzuuyCBJqqeJZ9BxmaZwLjWtYDrk=;
        b=RJWUWPAo1nqCLzxKRMLvvpwD24m95AI1Y1c0THinpJDNWe3K5UPN4apWQnnaqB0XKe
         msV+qMrjY14r0Oyd6tYdQdhagBCfcgCYxaodPfdt9umxMxFvqc2cL4VYe5pOZWXZSK4X
         ZXso/aT8X4Rb7ZTvGQ8E0UUpA4HksGayWC5lFNwBV4vb2oVvS1K0G3Miakk/xOxo4bk1
         3S0sRkiyI6mNIy1Gfyfrosqmf6WO1UB4TM7sEdSqi0OG91uGalAbVJuLVz5KNrJ+hRO7
         b6g0q8eUjjNdw4dt4ZTS1Y1Apg7bhRu5Tp3rV8b5hV9JyjD/Ol/+tvRJ8Hfn53QozQsi
         3qwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z2si1764084qvj.66.2019.02.11.00.58.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 00:58:59 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 85290356C4;
	Mon, 11 Feb 2019 08:58:58 +0000 (UTC)
Received: from [10.36.116.241] (ovpn-116-241.ams2.redhat.com [10.36.116.241])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1975C10E81C0;
	Mon, 11 Feb 2019 08:58:56 +0000 (UTC)
Subject: Re: [PATCH] mm,memory_hotplug: Explicitly pass the head to
 isolate_huge_page
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: mhocko@suse.com, anthony.yznaga@oracle.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190208090604.975-1-osalvador@suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <1b36e2a9-daf4-ed39-88da-f95fb0d25171@redhat.com>
Date: Mon, 11 Feb 2019 09:58:56 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190208090604.975-1-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Mon, 11 Feb 2019 08:58:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08.02.19 10:06, Oscar Salvador wrote:
> isolate_huge_page() expects we pass the head of hugetlb page to it:
> 
> bool isolate_huge_page(...)
> {
> 	...
> 	VM_BUG_ON_PAGE(!PageHead(page), page);
> 	...
> }
> 
> While I really cannot think of any situation where we end up with a
> non-head page between hands in do_migrate_range(), let us make sure
> the code is as sane as possible by explicitly passing the Head.
> Since we already got the pointer, it does not take us extra effort.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  mm/memory_hotplug.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 656ff386ac15..d5f7afda67db 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1378,12 +1378,12 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  
>  		if (PageHuge(page)) {
>  			struct page *head = compound_head(page);
> -			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
>  			if (compound_order(head) > PFN_SECTION_SHIFT) {
>  				ret = -EBUSY;
>  				break;
>  			}
> -			isolate_huge_page(page, &source);
> +			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
> +			isolate_huge_page(head, &source);
>  			continue;
>  		} else if (PageTransHuge(page))
>  			pfn = page_to_pfn(compound_head(page))
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

