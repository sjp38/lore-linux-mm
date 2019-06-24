Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2ABF6C48BE8
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:03:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F002D2089F
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 05:03:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F002D2089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 732686B0003; Mon, 24 Jun 2019 01:03:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BC7B8E0002; Mon, 24 Jun 2019 01:03:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55CDE8E0001; Mon, 24 Jun 2019 01:03:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BD7B6B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 01:03:44 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d190so8820458pfa.0
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 22:03:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=I39Bi0bn1V2qCmzChaXQgVPzQdJt5HaZsOVvSEfHmxQ=;
        b=aexP2qPOILH1WjtTMDycdKg8v9CDO94ebffoK1fG617+SIP0VWNFFXCLNF6YMjk7CU
         NCFt48sn3xq/N8ixE8pXpWBjbzC+FhjzyAWEIRD7YkZ06hnILZhmV2D52RC2OW8pSCAg
         XaD8Lyt1hO3EhFZhh4YQVQF91Dcuumb5WPlHUDJJ00eHvrIYVIljVeaiknbi+j7+m0bB
         55EnVM0BxWcWAYrKgxt5wnJr5XMQj6vzDw0Yw2b2k/FJEd9OWGHulLGcZAhr/160j8A7
         adGl7NsmIeQqVirH1H+K1qe5ygdeB3qbwP2r/rlpnrWMjwrviYiF6B7TzlfZZ6Z8XBpX
         nPng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUBeulm6ITWEf0HHeOGalJW/Psp842EZs0BbckCfUm2a2L1stk/
	HvE/BfNOSdcogAKa0CoTuIAOfWN/HjFQ4PO5HTayAqV4DgJoZKCU5w/AIhyXHVqCMMDojO/pWFB
	t1guoOtWoCrwgBJmdSqURTC/Y7MmVBNAtrDA7xWL7cWqr/PsPEDEgPuWfkLc21qc8dg==
X-Received: by 2002:a17:902:2ae7:: with SMTP id j94mr61623351plb.270.1561352623718;
        Sun, 23 Jun 2019 22:03:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZ21QkUMb0+xt6IlG569PrY3PRAc3zLcg4m+KmGJjvZbedl/+5TFr999BgM1Tzd/ZDbCxH
X-Received: by 2002:a17:902:2ae7:: with SMTP id j94mr61623322plb.270.1561352623071;
        Sun, 23 Jun 2019 22:03:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561352623; cv=none;
        d=google.com; s=arc-20160816;
        b=cCmyn9rHXk1+/H2tXlt/trlaIX+ZuPYquG7cTqbuJE/Wxs5uVlYzva3ANonsx1a6CN
         ftsMwoU7w7jkj0XW0m5t0PFxdaWAkh++elZFx+cOiGmFabMSpYvsqZ2ML7Nwj99mr3ww
         9GZ8cprbH6v21U9rT+ZfvhLEI05J/uSNAKw8SM7VLzvhB86TC2UB9Iev9/7hvPeEsv1y
         U8McQN5ltxGFKDJdiOJtnwcaIyI4bUAQHbxVPVxeFtzn5t18jIpZhogOMoRRqsAACY0q
         f4TotiYkGsY84e29HpEcMCGJx/ecKejHJXPP3sA3Vzl0TK+y6iKUVLnq/OqeahuBSq0+
         +Qfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=I39Bi0bn1V2qCmzChaXQgVPzQdJt5HaZsOVvSEfHmxQ=;
        b=acBRFYkLT8nfh5UjxifTnDyouxRHrZWNg/UdgAGZYkm5TL4PD182Y7GjZR3FnBms6e
         32f+XnYMLBqG3pNQL7iKNSvbPh+/kAf1Ra3QKE02eAi7vHZ5oRkjfa1WqkkA7gXDHMqO
         N3wdaLlPVEQ5xjfE2zvTkLhuEmN67rRqWL7qZ16sqF8chrdYsIvLczXvBdEcPYc9OMTd
         wywmHPrzG7cYoXlcb9+ONp/82eMUx23J38P//Py9jgpQblWbwMqtQSCzcwZu4CFNuoQ8
         v+4Wx9TQggFxOpW/L13HnPbeJWPDfx05JPy6IoyjA6sKgH8rloZ16tJPxMcNEvsiw1XD
         vy3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id j3si9556031pjt.79.2019.06.23.22.03.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jun 2019 22:03:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Jun 2019 22:03:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,411,1557212400"; 
   d="scan'208";a="163216338"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga007.fm.intel.com with ESMTP; 23 Jun 2019 22:03:42 -0700
Date: Sun, 23 Jun 2019 22:03:42 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>,
	Oscar Salvador <osalvador@suse.de>,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hugetlb: allow gigantic page allocation to migrate
 away smaller huge page
Message-ID: <20190624050341.GB30102@iweiny-DESK2.sc.intel.com>
References: <1561350068-8966-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1561350068-8966-1-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 12:21:08PM +0800, Pingfan Liu wrote:
> The current pfn_range_valid_gigantic() rejects the pud huge page allocation
> if there is a pmd huge page inside the candidate range.
> 
> But pud huge resource is more rare, which should align on 1GB on x86. It is
> worth to allow migrating away pmd huge page to make room for a pud huge
> page.
> 
> The same logic is applied to pgd and pud huge pages.

I'm sorry but I don't quite understand why we should do this.  Is this a bug or
an optimization?  It sounds like an optimization.

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

I don't think you want compound_order() here.

Ira

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
> -- 
> 2.7.5
> 

