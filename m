Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2F0FC31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 21:37:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AC5B208CA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 21:37:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AC5B208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F1A06B000E; Thu, 13 Jun 2019 17:37:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A2266B0266; Thu, 13 Jun 2019 17:37:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED4796B026A; Thu, 13 Jun 2019 17:37:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B83336B000E
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:37:56 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a21so252369pgh.11
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 14:37:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=By13X09yL97FSwMh6aklOWCz4WgFg5XbT9Q4PzBiefs=;
        b=lEsppLYFF8dXuUyD9Iav2mECC8mJ36FjOaMds28hlBw3bVN4XBt3q2metCf4uWcb3m
         cK1yzroexQy3T+aLNBhs1utkrIqmBt0WJLCEYQRPZnlAfIjFUpkb2eROSJWD1xllJhCe
         n8v8xdkoLksXFpgXvlyhTCo5pgC6U45K+IWYEgPK9nybEJdd2QPrEfwXme/NVxcY11Br
         ytXmPEEdvWZ6m2v7j/JBDMHKvrThI7faxErRZ61dpOZ08I1XuQiTDYw2QO4vJvWnhPPa
         H2ypC7CWlTw8bpJJ1Gx/NlZnCbvWyMV5cqzZGHNZQjOPgESVkil0Cu7jCVwvRokShtTR
         EdSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXS5hJOIFfUQGj4KtS9zXJZKGWHNUfMF02eMVg1qmaeuHdcsRbQ
	xR+WJiGBfWp01o2Y27qmnTM9z3OQ3zy3r7WoDfY1m1hAmPw5nt+exDXmLQK60tTx8KEn+PYpErc
	7Hxwqh0g7xyUaqruV0ezlSU01dn18VSSCbr4CQcNPh8iwFmNqZwD6LHyx/AsP1e8mFg==
X-Received: by 2002:a17:90a:6544:: with SMTP id f4mr7665057pjs.17.1560461876338;
        Thu, 13 Jun 2019 14:37:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynJpRjmC213n3jVmNGU4sfB7yrhuHlEtqzCsSFnF+agQUobk/pU5xUOa/16wefoqvBKzMt
X-Received: by 2002:a17:90a:6544:: with SMTP id f4mr7665004pjs.17.1560461875514;
        Thu, 13 Jun 2019 14:37:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560461875; cv=none;
        d=google.com; s=arc-20160816;
        b=CEwgi3mHY+Mv6RxNtRQ5ShmVW9hhxTNjgqMFOC/sD//HwKItKykWf+HPNSp9BCrn8e
         O7UO/XHLT5HCQIBg6/adj58A4nXeH7wj7yEAU0mH9jC8OFk2U8ME5mbgm1alRIkHwnSh
         rIpepCIhjdgeUaPytmK1EapLOAVQkX/eFSd8ZO98LJciUAWqEmzm55EThqMkAo/YN6xa
         h2cqOyz5RYRzH4As2zdU0F169cfKchr61Vu41twrkJot+RwuteEh7DZHT8nYsREq+pMP
         Tg5Q+25cCicJw3l3B8kULcoBIygtd0ZGnkNxNpFLs1JFE1cyBimFwceTku8bz8Q1UMAf
         rFoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=By13X09yL97FSwMh6aklOWCz4WgFg5XbT9Q4PzBiefs=;
        b=jZwq9rWbx7PQgCaFXYvTmRAdJrxEJhp7SCfKgTGYSU199tmjKuxsgxVhGiPuGDvv7b
         Gr7Ghb8APEeAjXthqLJoerQPZgmk6N6oyJTHQzx9aRI63BtILZzJzpS5EibGlXpODCST
         4HdYMrXTOmP1dAtDkvV6b47epQv72ySTHZQeb9Al1h8IHRdcF6SBhHARKA2xwglLKwOC
         3PtZatWes85TIGaN5oJkJ3FQVaYZuhJKdhXsQAnkU3pjpxXibnzwtHkNK1/EJ7GieaoF
         8fKy5ZrmqMBQg9P9AF2ju+t8aYrs8qDfKmLY9gAfLxRQxQyiZKVlitc1jMLHK2v4G/x4
         Ga0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id v204si687179pgb.80.2019.06.13.14.37.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 14:37:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Jun 2019 14:37:54 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga008.jf.intel.com with ESMTP; 13 Jun 2019 14:37:54 -0700
Date: Thu, 13 Jun 2019 14:39:16 -0700
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
Subject: Re: [PATCHv4 2/3] mm/gup: fix omission of check on FOLL_LONGTERM in
 gup fast path
Message-ID: <20190613213915.GE32404@iweiny-DESK2.sc.intel.com>
References: <1560422702-11403-1-git-send-email-kernelfans@gmail.com>
 <1560422702-11403-3-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560422702-11403-3-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 06:45:01PM +0800, Pingfan Liu wrote:
> FOLL_LONGTERM suggests a pin which is going to be given to hardware and
> can't move. It would truncate CMA permanently and should be excluded.
> 
> FOLL_LONGTERM has already been checked in the slow path, but not checked in
> the fast path, which means a possible leak of CMA page to longterm pinned
> requirement through this crack.
> 
> Place a check in gup_pte_range() in the fast path.
> 
> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
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
>  mm/gup.c | 26 ++++++++++++++++++++++++++
>  1 file changed, 26 insertions(+)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index 766ae54..de1b03f 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1757,6 +1757,14 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
>  		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
>  		page = pte_page(pte);
>  
> +		/*
> +		 * FOLL_LONGTERM suggests a pin given to hardware. Prevent it
> +		 * from truncating CMA area
> +		 */
> +		if (unlikely(flags & FOLL_LONGTERM) &&
> +			is_migrate_cma_page(page))
> +			goto pte_unmap;
> +
>  		head = try_get_compound_head(page, 1);
>  		if (!head)
>  			goto pte_unmap;
> @@ -1900,6 +1908,12 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
>  		refs++;
>  	} while (addr += PAGE_SIZE, addr != end);
>  
> +	if (unlikely(flags & FOLL_LONGTERM) &&
> +		is_migrate_cma_page(page)) {
> +		*nr -= refs;
> +		return 0;
> +	}
> +

Why can't we place this check before the while loop and skip subtracting the
page count?

Can is_migrate_cma_page() operate on any "subpage" of a compound page? 

Here this calls is_magrate_cma_page() on the tail page of the compound page.

I'm not an expert on compound pages nor cma handling so is this ok?

It seems like you need to call is_migrate_cma_page() on each page within the
while loop?

>  	head = try_get_compound_head(pmd_page(orig), refs);
>  	if (!head) {
>  		*nr -= refs;
> @@ -1941,6 +1955,12 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
>  		refs++;
>  	} while (addr += PAGE_SIZE, addr != end);
>  
> +	if (unlikely(flags & FOLL_LONGTERM) &&
> +		is_migrate_cma_page(page)) {
> +		*nr -= refs;
> +		return 0;
> +	}
> +

Same comment here.

>  	head = try_get_compound_head(pud_page(orig), refs);
>  	if (!head) {
>  		*nr -= refs;
> @@ -1978,6 +1998,12 @@ static int gup_huge_pgd(pgd_t orig, pgd_t *pgdp, unsigned long addr,
>  		refs++;
>  	} while (addr += PAGE_SIZE, addr != end);
>  
> +	if (unlikely(flags & FOLL_LONGTERM) &&
> +		is_migrate_cma_page(page)) {
> +		*nr -= refs;
> +		return 0;
> +	}
> +

And here.

Ira

>  	head = try_get_compound_head(pgd_page(orig), refs);
>  	if (!head) {
>  		*nr -= refs;
> -- 
> 2.7.5
> 

