Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35030C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:46:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00C8524267
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:46:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00C8524267
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DD296B000A; Thu, 30 May 2019 17:46:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 895DB6B0266; Thu, 30 May 2019 17:46:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77D5D6B026A; Thu, 30 May 2019 17:46:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4176E6B000A
	for <linux-mm@kvack.org>; Thu, 30 May 2019 17:46:36 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d7so3173827pgc.8
        for <linux-mm@kvack.org>; Thu, 30 May 2019 14:46:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=oc9hItpI/FRIQClQww39z7Qln7Gifr8/ffDEC0elnlc=;
        b=ctg0rZ9rlI63hAuVFJXoJ8a2ncIauCTkHHTHKlEM5oRRVV/77nmd6SEnMoYm6nqJ1U
         Y9HVxPSTSNN3tWqs4XT0ssT+j5t8/iG7krxD9YSL0moK9U+RrzoLnisczyITxKkAYpRb
         rWZx+08kD7kGiIig05qetTrGMy0cP7WnS6D/lm3LVAVPsG/9JTNuGLSasg/PnTEguXwp
         mlEIYW/Cl+StXADyrEwpH+dyO2F8VkiyvNIlcKdMAOrA0F8zZ451eX9L0vFJ4NRmrcgI
         vTZLQUSyNX5NdKs5RRvuXuK6PzCfpKd3l+AxiANivcIxBAWvjuPvPPTFY+HgYKmwLrh+
         4d6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVvsPqPNPFGyFeWLjFMHwMPSX5TqMYyUGMcC8XvrG7R34ywzCVi
	7S6f+gmCLHntMb2YT4riufYtsxsfqf/SOijgzfAiLxUmcF0QuKlLTLDZEHaKSguB84DdyvPh+l6
	R9itjSpYmkec+tPaEQ6w2RT8vlmNlEsYTuvvIFYR2wrpLrZ6zkj4DZKWdvkRl+gcJkQ==
X-Received: by 2002:a17:902:8ec3:: with SMTP id x3mr5489529plo.340.1559252795809;
        Thu, 30 May 2019 14:46:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJ3gB8YiDt6yt1QfHvJ7kjAOc7pLD0RMHn6vZGmY3A9RLjx8/t7757A22sutfDYtUHZf2U
X-Received: by 2002:a17:902:8ec3:: with SMTP id x3mr5489467plo.340.1559252794981;
        Thu, 30 May 2019 14:46:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559252794; cv=none;
        d=google.com; s=arc-20160816;
        b=nWbwmOdruzj1BqOl/5j0kv9WticCUjJQEu1hcfZbfZCGTlJOI8ZYstkTLQpKbCEJ0s
         JBka5xqjkM/hRI7ZOkDtK7qcCtQO4WlIN1+ckY23G1BZZK8kQIVPMIjDAr2iyaSaZTIE
         u1lGp4mYDGIrmLd1mASP3A40Adt+viDMVt8KHmMRhHpG8WfRLm1QV/xO5d3opVwzKJrS
         jYmDwT7eGiR3ct56H0nyCi6QHcFgQk2wzUbAVRtIufr6c1YuSRrHDk5L6tL3bzXwU8iP
         aL6jpRR2aKgyCVBWsGr8ECYIvvovBHWKuy8KnXw9/NoEXG2QQDXtOX1mMT0eLTAdj9Vt
         Iztg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=oc9hItpI/FRIQClQww39z7Qln7Gifr8/ffDEC0elnlc=;
        b=w8pb8FkpByGneE2PqhxOGV6MV3CPZm1ZQ11G9zA1YFWXeQUAg7bF39SS8VWmSXOn0k
         HYh4em+RSi8r4kwcqtYTtfWpw6jdVibSQY0wQSrHwOzmQC48gq7UR4YW+ZH6hFnPHvF6
         N2oun+lCEy3m+idYByyvHowUMEZ3NksbACYB5xCNg/t872Y35SgueoSoZaCE9Zemx35p
         Y6fRY+F94/ztItoXMC2FdzijkNPLxWRdrS/OzAuEBf+TtLJwriHWmnB4GjLdSA+qBWvS
         J5qJoEk1cHFzf4Z8E/nS1G8x3KGnu3woax/hUhqcKDDYa4XB1goUxTsH9Tp18s4G1zLI
         kKMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id t74si3782171pgc.265.2019.05.30.14.46.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 14:46:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 May 2019 14:46:34 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga007.jf.intel.com with ESMTP; 30 May 2019 14:46:33 -0700
Date: Thu, 30 May 2019 14:47:26 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
Message-ID: <20190530214726.GA14000@iweiny-DESK2.sc.intel.com>
References: <1559170444-3304-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559170444-3304-1-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 06:54:04AM +0800, Pingfan Liu wrote:
> As for FOLL_LONGTERM, it is checked in the slow path
> __gup_longterm_unlocked(). But it is not checked in the fast path, which
> means a possible leak of CMA page to longterm pinned requirement through
> this crack.
> 
> Place a check in the fast path.
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
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/gup.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index f173fcb..00feab3 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -2235,6 +2235,18 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>  		local_irq_enable();
>  		ret = nr;
>  	}
> +#if defined(CONFIG_CMA)
> +	if (unlikely(gup_flags & FOLL_LONGTERM)) {
> +		int i, j;
> +
> +		for (i = 0; i < nr; i++)
> +			if (is_migrate_cma_page(pages[i])) {
> +				for (j = i; j < nr; j++)
> +					put_page(pages[j]);

Should be put_user_page() now.  For now that just calls put_page() but it is
slated to change soon.

I also wonder if this would be more efficient as a check as we are walking the
page tables and bail early.

Perhaps the code complexity is not worth it?

> +				nr = i;

Why not just break from the loop here?

Or better yet just use 'i' in the inner loop...

Ira

> +			}
> +	}
> +#endif
>  
>  	if (nr < nr_pages) {
>  		/* Try to get the remaining pages with get_user_pages */
> -- 
> 2.7.5
> 

