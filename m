Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7190C48BE3
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:16:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B8B8208C3
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:16:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B8B8208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15C4B6B0003; Mon, 24 Jun 2019 01:16:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10E068E0002; Mon, 24 Jun 2019 01:16:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F17238E0001; Mon, 24 Jun 2019 01:16:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A5FA66B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:16:17 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l14so18648351edw.20
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:16:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ZRFgzicg77+rcj3QkgTNCzOOesTvIaxUshyWhE6ak/s=;
        b=cogj1FgVUzd7k7j39bXNOcUjQwOtwSX+J756YZChFKnF85zL65zd3qw+mW48wBFzCn
         DdtRBlDX4A6A+sPXHzjGKFMo2MFd/CsPdodTSao1T8mv1WbfkMHHpCDJC2mTgaFa+LjR
         SXZWmGXRn83Y8DVUWxPPoicelBtg3sulvYC+QTBSolPcw0qpahSFYnqg4/MdSLVb76VD
         BfiGR2Xp95eC1YgcMEM50u+CG3hNwejTMId+nkNAyZpy5Oq/BNAeUjeq3Kz/UGjvyzug
         fCIRH7YCMOz4R7Yf9WE+Mpvw3GDj/L4RzYKklBfM1WlAjq8r8sSEG0ZnI6sDcZDCvp8h
         YP3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAWJKwM/gTV/WhO7GJsutSHJpjuQzYu5hF6Xjr/7sPur1LkMzVy9
	Tj+3yorIvn7sJ/rYh4CPivu69kkg9v8CowzygvgSK6mxrew23/kZJq7QUIf5B2ve4mrpgvjS5zE
	PXbXyjLXTSLt6R8bQp2wRV+ZfUuDeT5sWgjkI4F6BMPb5sC2R6SXJowQT6At5wxsuwQ==
X-Received: by 2002:a17:906:4948:: with SMTP id f8mr81690277ejt.79.1561353377240;
        Sun, 23 Jun 2019 22:16:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxGw+D8YgDjOSzvlnRKBE31P+7yHOv9bE7ofLWhggP/C3lPohriXxA9Mq9+hOP5DUKhqHL
X-Received: by 2002:a17:906:4948:: with SMTP id f8mr81690235ejt.79.1561353376526;
        Sun, 23 Jun 2019 22:16:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561353376; cv=none;
        d=google.com; s=arc-20160816;
        b=YEGKwjdrgZBBfpB1cjgh+CTqweY30OYHGaBKuhsg+qIyjVBJwjlLJP0RIv5xUa2kBO
         8EHlB4CK6xz0P/bOnufMbTlgoG67NP0LagQiNZMBM9IAlmk4Hdw04wnlOOiKjNQzvsEA
         nMJhXL8Wx4blk3E+TeFQCCl2WBbdKWxKrWj9XFfIwI8Lrm1objqfEWGAc8MdnPLXiQus
         hw2V2QPu7XrI0MYDvVkEfRt4PkAta0zGBOiFbILBeR+/ZXpMkRefn/JwXXdZYAb6zbY/
         8tx2Y4BUq9pEJxCDqdDZER2++Tbzo6TO3Sm1CaW9ckeKyOS1P2+oKH8Tztq9NYiMlR+w
         SDlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ZRFgzicg77+rcj3QkgTNCzOOesTvIaxUshyWhE6ak/s=;
        b=cvn9Hx8xBMJ/25jU66jSPo1BRJRxy5hWTdWhk9MzRWC8wbEyKGbdY8fnVwRwmuLRsN
         UvgnDqNSNaHY1g2/28MK1LLlAFPiWE9gcNmw8eCXFPoz59wpp8TmqZqhC6lsyyWa/mBC
         510n2CtUzAZrycGo7IXPgs8d1oKI2xvWPGRR2BYDuYN6oFOXxYEHNkepKlyh/T+P7dhk
         QgYqqAiTEq9BksiYnCDk63WdK5VQN6XN9zhQyZmdrap3OCnmwm37Qlo3sSWI4Nmt1Ih4
         2tkOoxOKTppK9GT+CXITDUAcHzY2k53++F9PudAd9k+ih/CHUt6kBSkrq/crYe/oJLp5
         fa4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g34si8737542edb.182.2019.06.23.22.16.15
        for <linux-mm@kvack.org>;
        Sun, 23 Jun 2019 22:16:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 95739344;
	Sun, 23 Jun 2019 22:16:14 -0700 (PDT)
Received: from [10.162.41.123] (p8cg001049571a15.blr.arm.com [10.162.41.123])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E82183F718;
	Sun, 23 Jun 2019 22:18:00 -0700 (PDT)
Subject: Re: [PATCH] mm/hugetlb: allow gigantic page allocation to migrate
 away smaller huge page
To: Pingfan Liu <kernelfans@gmail.com>, linux-mm@kvack.org
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Oscar Salvador
 <osalvador@suse.de>, David Hildenbrand <david@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
References: <1561350068-8966-1-git-send-email-kernelfans@gmail.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <216a335d-f7c6-26ad-2ac1-427c8a73ca2f@arm.com>
Date: Mon, 24 Jun 2019 10:46:36 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <1561350068-8966-1-git-send-email-kernelfans@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/24/2019 09:51 AM, Pingfan Liu wrote:
> The current pfn_range_valid_gigantic() rejects the pud huge page allocation
> if there is a pmd huge page inside the candidate range.
> 
> But pud huge resource is more rare, which should align on 1GB on x86. It is
> worth to allow migrating away pmd huge page to make room for a pud huge
> page.
> 
> The same logic is applied to pgd and pud huge pages.

The huge page in the range can either be a THP or HugeTLB and migrating them has
different costs and chances of success. THP migration will involve splitting if
THP migration is not enabled and all related TLB related costs. Are you sure
that a PUD HugeTLB allocation really should go through these ? Is there any
guarantee that after migration of multiple PMD sized THP/HugeTLB pages on the
given range, the allocation request for PUD will succeed ?

> 
> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/hugetlb.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ac843d3..02d1978 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1081,7 +1081,11 @@ static bool pfn_range_valid_gigantic(struct zone *z,
>  			unsigned long start_pfn, unsigned long nr_pages)
>  {
>  	unsigned long i, end_pfn = start_pfn + nr_pages;
> -	struct page *page;
> +	struct page *page = pfn_to_page(start_pfn);
> +
> +	if (PageHuge(page))
> +		if (compound_order(compound_head(page)) >= nr_pages)
> +			return false;
>  
>  	for (i = start_pfn; i < end_pfn; i++) {
>  		if (!pfn_valid(i))
> @@ -1098,8 +1102,6 @@ static bool pfn_range_valid_gigantic(struct zone *z,
>  		if (page_count(page) > 0)
>  			return false;
>  
> -		if (PageHuge(page))
> -			return false;
>  	}
>  
>  	return true;
> 

So except in the case where there is a bigger huge page in the range this will
attempt migrating everything on the way. As mentioned before if it all this is
a good idea, it needs to differentiate between HugeTLB and THP and also take
into account costs of migrations and chance of subsequence allocation attempt
into account.

