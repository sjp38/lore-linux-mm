Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61755C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:10:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DF902070B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 16:10:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DF902070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0DAA8E0005; Thu, 20 Jun 2019 12:10:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BEF58E0001; Thu, 20 Jun 2019 12:10:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AD408E0005; Thu, 20 Jun 2019 12:10:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 537748E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 12:10:47 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i3so1860221plb.8
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 09:10:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=gqq0kQFFP/GC+r+iqn1/8NXq7wLnXIrnyFa+ACUn8WY=;
        b=bH5vB4cDb8IR2sTJCUxaHiM8TBpbw8RyBfyb06U1ox/gvH9jXtZoeC4ErMGLoRxkR/
         3XY6A/tFKOek1I8Sv7kfdrQTu/RBITQGDRY0zSBQFC2ed2zMs0HFfvi+WchpVqhWORpK
         YOVwIOSRj8/UbpLdRgywNUiHvrG4SXISnNsuHsuNaM6eLGRws8CMlIPazG+zgp+f8mUz
         TBiMgNeNTvSda54rE5Cl7uQiaqnMtamRKyVpICnHz3ICN7ipIZN+WTBhSpRd58eILv/l
         tANMHm9iX0l+t3xWPev4lO7iNxfkYrV+TLHL15UOmz7D7SSlt6si+mvaB1MN44ZzF9O3
         A14Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWykSrBmRj/VBm4KfuZap4wQE/mxz6sv+0sgh0T1t7kdeLtkhba
	pr1Vn7m2qAKJIIyAIMpislF2vYi+Eceet3nYs759prW2M9ChDd5khcDc6Nl4btNqGEJ0Dhf7v6x
	GM+aq2jzncXslWaTT+v2+EeSaNJ+6m1SfpvAMD1BlEb5xNSf0jg3dGho0NUSZ8m8iVQ==
X-Received: by 2002:a62:e511:: with SMTP id n17mr121133140pff.181.1561047047016;
        Thu, 20 Jun 2019 09:10:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUo7kpWyv4V7pGm3yqeNY4tHx7SNAthYrQ+p7E6P1szbSXJkljOPiXrfWg69YBtK0oaoTS
X-Received: by 2002:a62:e511:: with SMTP id n17mr121133050pff.181.1561047045821;
        Thu, 20 Jun 2019 09:10:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561047045; cv=none;
        d=google.com; s=arc-20160816;
        b=DQXjkG3j7zafq/XTYt7wiD0GferFuaG6YmA9Exoqm/jXh04keyWo+k/J1nE5E0y/tU
         uu2GuS0B9GVCarltioEifZOeQ3Q8LithoN6iGr+swb/AUZhU6ojIbEsv7xb8q+7VVnsN
         slvquTlWPHgeYDGU6lkDgUeEct0GZ1KdHx3LMGS5g/bbKzHICDC43XkPGqtAQ4yguQjT
         l4y8pFKkIlNvC2Z3+7PZXmnSKKVLSxdimvpup+ki82omEP34ABMjKztCWKl/TZnSZ21p
         NRUHQSJd0RmBKO2unQo6dtexliT4hN203M0lr0ffE2XhxRT7qAKRBQEVQy/f/f2Dw/bJ
         daXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:to:from:subject:message-id;
        bh=gqq0kQFFP/GC+r+iqn1/8NXq7wLnXIrnyFa+ACUn8WY=;
        b=dmNBAIcPDOodWKORIYvRXhXmkJz31s8YfqzBsxjWnWWrxebD7arsEXVtZiPvf/akiB
         c497vPjU0pfj1iwS2YdA1PYokRnj3NG6Mn+KrQ7HNCQHXZ4SHwLbroewqCJ836vjUS4W
         /N+I9Vc7oa5QsvEZQ5upKr4cD1dJCzhZe97vyhBYmUu2rxZNOfAYUuEKKgFX8jS6qjkH
         skJeRFTe4SMbiwPvElbCiEpxLjTS4sIWXp56w2gH8vvKAA2kHUCeyK1jZDtaVaoelXJm
         Q+J0gzom2ifDNAJfbFaP6DJYTP9eINo9kuTc0pnKdMU+ADMLS3bLcEB6G1v0x1XsYzX9
         l/lQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id k10si6595312pgc.9.2019.06.20.09.10.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 09:10:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Jun 2019 09:10:45 -0700
X-IronPort-AV: E=Sophos;i="5.63,397,1557212400"; 
   d="scan'208";a="150979509"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga007-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Jun 2019 09:10:44 -0700
Message-ID: <2299c1a5b8773c955e7d0c3803ad3fc6c83c127a.camel@linux.intel.com>
Subject: Re: [PATCH] mm: fix regression with deferred struct page init
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Juergen Gross <jgross@suse.com>, xen-devel@lists.xenproject.org, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Thu, 20 Jun 2019 09:10:44 -0700
In-Reply-To: <20190620160821.4210-1-jgross@suse.com>
References: <20190620160821.4210-1-jgross@suse.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-06-20 at 18:08 +0200, Juergen Gross wrote:
> Commit 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time
> instead of doing larger sections") is causing a regression on some
> systems when the kernel is booted as Xen dom0.
> 
> The system will just hang in early boot.
> 
> Reason is an endless loop in get_page_from_freelist() in case the first
> zone looked at has no free memory. deferred_grow_zone() is always
> returning true due to the following code snipplet:
> 
>   /* If the zone is empty somebody else may have cleared out the zone */
>   if (!deferred_init_mem_pfn_range_in_zone(&i, zone, &spfn, &epfn,
>                                            first_deferred_pfn)) {
>           pgdat->first_deferred_pfn = ULONG_MAX;
>           pgdat_resize_unlock(pgdat, &flags);
>           return true;
>   }
> 
> This in turn results in the loop as get_page_from_freelist() is
> assuming forward progress can be made by doing some more struct page
> initialization.
> 
> Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> Fixes: 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time instead of doing larger sections")
> Suggested-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> Signed-off-by: Juergen Gross <jgross@suse.com>

Acked-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>

> ---
>  mm/page_alloc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d66bc8abe0af..8e3bc949ebcc 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1826,7 +1826,8 @@ deferred_grow_zone(struct zone *zone, unsigned int order)
>  						 first_deferred_pfn)) {
>  		pgdat->first_deferred_pfn = ULONG_MAX;
>  		pgdat_resize_unlock(pgdat, &flags);
> -		return true;
> +		/* Retry only once. */
> +		return first_deferred_pfn != ULONG_MAX;
>  	}
>  
>  	/*


