Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EB3DC31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 21:26:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4ED6E21537
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 21:26:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4ED6E21537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00F0B6B000C; Thu, 13 Jun 2019 17:26:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F02AD6B000D; Thu, 13 Jun 2019 17:26:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC9B76B000E; Thu, 13 Jun 2019 17:26:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A3C316B000C
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:26:45 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 14so225141pgo.14
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 14:26:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3qOWaBsW/Ptjmr4hrCKCHrqpkExqmLYk7sTL4JiPX8g=;
        b=iqNcMHZhNv/dnjdkDuZHGjeMMevj7i4JRAfx0rVGaxhPnxX2PQ+72m9JgN5J/0iwNM
         SEpHqWzDUL/UPNN8xfgxtkMVS7vVfV4zrP0+gl8afDfPcH3P4nSuf5NfyaGh4M/0uXfc
         K8qQUvKjG4Jm37I477ExouX1YmvH63OArKrIwA0aCHCn0nsn2Kihi/vzKQ40i//oG3xp
         MNTH5WNt7XvCxiqlxGzsBKxF+vBzriRZKn3vs0W6zxGptCixDoMlAbpkpuq6PfNuZL4M
         KKfUwZx2LaqzF0Gp2+hNCFACAEEQHBVvWM8A63EwnGprDomsrF9PMsIpOjcuJgXq9GvT
         VmjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWSLsaJFXwtYEwLms92T7N6MDV1qw05ZkntOkRgzjkVzx6MnEcj
	/n6QGyi9Jc8aSE5n+F+sZMImxb4SYAW3gpQJZ6aHq00xR4Z4t5zLJIv8eYpYLcF62MTh3pgdJKd
	6QCcwiAvxc9iM5K6WzkPVFrVM0LWM3RBOHWbc/0+AwY+sLORtIWL/MpSUyHf5Se/zXg==
X-Received: by 2002:aa7:8102:: with SMTP id b2mr69004781pfi.105.1560461205251;
        Thu, 13 Jun 2019 14:26:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4IJJPvcHRPwUHOzmFXLlpCStdDJUf+xAW1D+6tzo3UIQF/OoIGWnoQFr9+Z0WBe6KMylD
X-Received: by 2002:aa7:8102:: with SMTP id b2mr69004736pfi.105.1560461204658;
        Thu, 13 Jun 2019 14:26:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560461204; cv=none;
        d=google.com; s=arc-20160816;
        b=Z2GYyKXgsLl1pXjMaUzN494hmSD6rqWgEC3BQ1YwS1Mq4Ckf+moaCKIEf1G6WhHqji
         K4AZcm9oMoWH6/zlcY8LG3pFnm/nU7EYaKEg8Se+dhRQHxxeDYTbHCjVBdrN1nMRsAlE
         QqtIUEvCnN0sT5knngbHtbqdUkMbpVZbriZ79vrsHQZXqab7X5nlwUZ2gXGao+Mvgipd
         mnnUpaINpJPdccsLW5tY/cv07hzu2L2AI0dBKA+MreAI5qgdUO+jmaKGEbBa8uv41cL5
         Qy8TzQQde6+opoH7PGMis15h4rzDk+te6lA6jgd2Y6JC3qFR/jl1oBsq1wFmDQ+gzNzw
         H9KQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3qOWaBsW/Ptjmr4hrCKCHrqpkExqmLYk7sTL4JiPX8g=;
        b=BRr3libNutVJVm6zKbqlgThjCpDVT24wISGNpbQYVKPFTexYpLZ4IEqGYRqBfGf+SF
         WGhwaK+3tN8WITVqty7cqmBHdo/z0oDxy9pt+BrIFIiX0kG+M935F/IgkLEIcEPKZHbg
         tgA4kuC/THCxb+/k91aw1/MB6QQmmX0azAEW9/Zz+tGN4LwWUGrtmjQo78atsRPyOM6G
         lW1knpvY62WqAvk6iY5E1SZKVogLtiPJJVigT+LtMbBRUkwaGrZ6Dj1SQY1tFYn8QH7I
         ZE4fZELcl8E40nnuCSsuSh1BYkFgRD7Xhbw1THAoI16pnXfpc2Ofk2e1D1nQzB3HzSf7
         eTvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s19si694665pgg.20.2019.06.13.14.26.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 14:26:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Jun 2019 14:26:39 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by FMSMGA003.fm.intel.com with ESMTP; 13 Jun 2019 14:26:38 -0700
Date: Thu, 13 Jun 2019 14:28:01 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>,
	Christoph Hellwig <hch@infradead.org>,
	Shuah Khan <shuah@kernel.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCHv4 1/3] mm/gup: rename nr as nr_pinned in
 get_user_pages_fast()
Message-ID: <20190613212800.GD32404@iweiny-DESK2.sc.intel.com>
References: <1560422702-11403-1-git-send-email-kernelfans@gmail.com>
 <1560422702-11403-2-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560422702-11403-2-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 06:45:00PM +0800, Pingfan Liu wrote:
> To better reflect the held state of pages and make code self-explaining,
> rename nr as nr_pinned.
> 
> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>

Reviewed-by: Ira Weiny <ira.weiny@intel.com>

> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> Cc: Keith Busch <keith.busch@intel.com>
> Cc: Christoph Hellwig <hch@infradead.org>
> Cc: Shuah Khan <shuah@kernel.org>
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/gup.c | 20 ++++++++++----------
>  1 file changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index f173fcb..766ae54 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -2216,7 +2216,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>  			unsigned int gup_flags, struct page **pages)
>  {
>  	unsigned long addr, len, end;
> -	int nr = 0, ret = 0;
> +	int nr_pinned = 0, ret = 0;
>  
>  	start &= PAGE_MASK;
>  	addr = start;
> @@ -2231,25 +2231,25 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>  
>  	if (gup_fast_permitted(start, nr_pages)) {
>  		local_irq_disable();
> -		gup_pgd_range(addr, end, gup_flags, pages, &nr);
> +		gup_pgd_range(addr, end, gup_flags, pages, &nr_pinned);
>  		local_irq_enable();
> -		ret = nr;
> +		ret = nr_pinned;
>  	}
>  
> -	if (nr < nr_pages) {
> +	if (nr_pinned < nr_pages) {
>  		/* Try to get the remaining pages with get_user_pages */
> -		start += nr << PAGE_SHIFT;
> -		pages += nr;
> +		start += nr_pinned << PAGE_SHIFT;
> +		pages += nr_pinned;
>  
> -		ret = __gup_longterm_unlocked(start, nr_pages - nr,
> +		ret = __gup_longterm_unlocked(start, nr_pages - nr_pinned,
>  					      gup_flags, pages);
>  
>  		/* Have to be a bit careful with return values */
> -		if (nr > 0) {
> +		if (nr_pinned > 0) {
>  			if (ret < 0)
> -				ret = nr;
> +				ret = nr_pinned;
>  			else
> -				ret += nr;
> +				ret += nr_pinned;
>  		}
>  	}
>  
> -- 
> 2.7.5
> 

