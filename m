Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5C79C43444
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 07:41:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A30C021871
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 07:41:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A30C021871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5238B8E0060; Thu,  3 Jan 2019 02:41:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D28A8E0002; Thu,  3 Jan 2019 02:41:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E80A8E0060; Thu,  3 Jan 2019 02:41:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0D838E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 02:41:08 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 202so28366671pgb.6
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 23:41:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=cuI6YYobgBNSIQI1hc6EHFmTl56UF8h1CFyiqxcWqog=;
        b=f4F9wcgtVdlC6wcFbElroFzupZX/ZTC9xS40MAOfur6rRlVNeflOVXfFzuzokmYLNn
         jW9dO7HOWcA8CNzyoJz+OvDV0VNwmdfowqUUCMcIiQygB7paMlSGSK0tzxd2Jv1CR4vH
         iI1er2SfWElDLrN2GyHTGNmP0RZS4gGHKCu6+4IzQXZnzeV3nU6EAIb/oHktbHpgj/c8
         huOfJgILV1ac6f0OiSPhp6yDG1H3Ak9zT4cAW8G2VH0ET24Dg1NCoxFxJQCo0ct166TJ
         6UAOC1V78EIVe+ZTJjAc1/xPpyi/x8c5Ah0GoEuGNlWOUHxZNtJyYhvdWKQSbIqB+5mK
         5vzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AA+aEWaa3l5M8JzFKMCFaU2BEvTlHYwpR6BtzCGqlXGtDwF7T+zX4tKV
	jxYeDgDI20gs1zuBU4zJlIKwwsLEajwpL7Eofy7y7uHmDOPn9wSK3FduruaASnRlCveuHJyr0Kt
	q/xOGTZlhO/YtVns/4/i5u9p+R0ymiqVixVzUwhnvG8HTAdwkM7CYptrMNx7kZNu6Vw==
X-Received: by 2002:a62:b24a:: with SMTP id x71mr48294372pfe.148.1546501268635;
        Wed, 02 Jan 2019 23:41:08 -0800 (PST)
X-Google-Smtp-Source: AFSGD/UpEbgwjCnnO+zfxQIQGxBZdhVXcKgml6J9fJ6GqrTl+0yYIAHRz9wdj3oagwSU4cHCHKo8
X-Received: by 2002:a62:b24a:: with SMTP id x71mr48294358pfe.148.1546501267908;
        Wed, 02 Jan 2019 23:41:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546501267; cv=none;
        d=google.com; s=arc-20160816;
        b=PnCLekIF3gte5chTI8lN3NnSlBy61pYSDOsR3BuIcyQm9WZwWLx6dK5LhdBuSqopKX
         KbLTKKu8sjguDZ4F/oU5bAtI74kId+ir0l6mHyK+r/a8kn0QQOcy1IT+V89+06XEHnjk
         a2r0bhVMbmHIFEFb0GN5kPC56uNMzLFlHvFpSArw7G6gFmU33N6Pwj7MTIQufIh0P8ZT
         DiYItMlD3GSZEFYfKt0dSZKXNIzjiSbfkOQn7AgMiI7FoQ39F4FQV0PP4wac95ykPevb
         oJI9SJx9ZnEMrEwh1FBrOtBpts7uLr+F8NzlKijcPYyDD8cbJRSzIlZXZtW/QRN7EfvV
         eBVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=cuI6YYobgBNSIQI1hc6EHFmTl56UF8h1CFyiqxcWqog=;
        b=q7IMua8FM5LWA5PTDJfRD+8mVZqekQ6AO8OexiWOGZ7bptBM2JEz1DnTe8PZ/I07mm
         OJhL4IFy7q4SH5GT3n6qxc1WxwUCHBCZwjIg74Y4j2GGuKyy0W4tSHqnCKPr88iuvkz5
         waQHWcPvw2n8wj8pJ+Lw1dsutDPDVP0L+3JGQgMV6FphFwBoPyHCYrSBiz3sNzaqu2gx
         XjB5bRd6ZpqpW2FMhNnTZSzZVHbh1ZJhwaWubvSjMyVz4MKfspVStXY04X+CoWiPfnOe
         ShRN6JEW6AVIcPNucm0p/3TqhnKnBp1m/O0ooFwGzru0MhJ1EwAOs0gHEENibLorjBQn
         78uQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id t5si50603594pgc.369.2019.01.02.23.41.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 23:41:07 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 Jan 2019 23:41:07 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,434,1539673200"; 
   d="scan'208";a="264052827"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.13.10])
  by orsmga004.jf.intel.com with ESMTP; 02 Jan 2019 23:41:06 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: <tim.c.chen@intel.com>,  <minchan@kernel.org>,  <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>
Subject: Re: [v4 PATCH 2/2] mm: swap: add comment for swap_vma_readahead
References: <1546145375-793-1-git-send-email-yang.shi@linux.alibaba.com>
	<1546145375-793-2-git-send-email-yang.shi@linux.alibaba.com>
Date: Thu, 03 Jan 2019 15:41:05 +0800
In-Reply-To: <1546145375-793-2-git-send-email-yang.shi@linux.alibaba.com>
	(Yang Shi's message of "Sun, 30 Dec 2018 12:49:35 +0800")
Message-ID: <875zv6w5m6.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/25.2 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103074105.CCCYWNMvEPT6sHvQDp4Paigs17b833IrnIe6SR-c1nQ@z>

Yang Shi <yang.shi@linux.alibaba.com> writes:

> swap_vma_readahead()'s comment is missed, just add it.
>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Tim Chen <tim.c.chen@intel.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  mm/swap_state.c | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
>
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 78d500e..dd8f698 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -698,6 +698,23 @@ static void swap_ra_info(struct vm_fault *vmf,
>  	pte_unmap(orig_pte);
>  }
>  
> +/**
> + * swap_vm_readahead - swap in pages in hope we need them soon

s/swap_vm_readahead/swap_vma_readahead/

> + * @entry: swap entry of this memory
> + * @gfp_mask: memory allocation flags
> + * @vmf: fault information
> + *
> + * Returns the struct page for entry and addr, after queueing swapin.
> + *
> + * Primitive swap readahead code. We simply read in a few pages whoes
> + * virtual addresses are around the fault address in the same vma.
> + *
> + * This has been extended to use the NUMA policies from the mm triggering
> + * the readahead.

What is this?  I know you copy it from swap_cluster_readahead(), but we
have only one mm for vma readahead.

> + * Caller must hold down_read on the vma->vm_mm if vmf->vma is not NULL.

Better to make it explicit that your are talking about mmap_sem?

Best Regards,
Huang, Ying

> + *
> + */
>  static struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
>  				       struct vm_fault *vmf)
>  {

