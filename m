Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59E61C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:50:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1F9F820866
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:50:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="b7Ke+YQB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1F9F820866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B2F96B0279; Thu,  6 Jun 2019 10:50:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 962EC6B027A; Thu,  6 Jun 2019 10:50:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 852A46B027B; Thu,  6 Jun 2019 10:50:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 66B0D6B0279
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 10:50:24 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id 49so2226343qtn.23
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 07:50:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=1KZ92zYILDahESjfhKhGayobjVbu/FpDMrdITCcqxXo=;
        b=Nkk4OV+UtcfdpMvq34KqbTSLdUDQ28G+UrF9nMZpZr0pCxfJvWSAt1ovzZpLE3OPDf
         cK/PteJtkHuiVOjJmGLySObv76fNu3uzyt7kWuUnengIxUruhxueZ5PMIDLdd5Guic5v
         TC9y/z67fIz67IBx/npqVrvg3D0jxnB4AwF3trt5mjX2L4to0cuolrPELhPuPlvnAg8S
         a1d7aMexxYuxQBKx7FJmb6goiXpROvzVWO/t55oxi0Y6HeeItyZZWkTDf97EY6tr4E8F
         FFS/vPF+FLg+TowRynN8jESzAVeXpxRReqiNolVT93j6fglAUTsdxPgMYRZNc/x3GbFl
         0Agg==
X-Gm-Message-State: APjAAAXj3fka4pQUeqmoEZxTUTBbfp2auSHxuxgk9SuSRdYKqaFHIGUk
	MyLEvWo5lRLCmNYDRGu6CLCvrurPoPtND1ffNgFR7AXn54ut3NR/p+Hbi/6wL+kddGV0bMbR4Y1
	TuzU7a3DIaF+I77cZE9WUo4iwmkwzP9m1gnvN+SVKKdpZBpfb1eyKqCP32DBj6+jSTg==
X-Received: by 2002:ac8:1018:: with SMTP id z24mr40245034qti.206.1559832624113;
        Thu, 06 Jun 2019 07:50:24 -0700 (PDT)
X-Received: by 2002:ac8:1018:: with SMTP id z24mr40244722qti.206.1559832619969;
        Thu, 06 Jun 2019 07:50:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559832619; cv=none;
        d=google.com; s=arc-20160816;
        b=sJAI9ofQDlewfseFvjBcX5Yw1NUeuWnXEN+7waf+ZLC1q3/36JbHvusvYCQssAwJ7q
         mtyL2EAKsvLWxKR8V2XmcrvlVxJcWhO6waZIXvWVkRBbdsixEmsWU6KM6TebBuoYuYOt
         pD+tjMS2OzvE90gol3JyuKb0jZeOfU6VcimSYcgVZdiymQxM6myRH6W9+p/y0BwTKwF1
         Thwet9YFcbGCgW8OlaadJpS6sFYqN4rFCmwGSOU8H5iDu91iHR/senKOb5i5Ns9IXNHo
         xY4db9wQ652a/7hJ9wIwNCMl+LABSX1PRG9lm39QkQ28sw/0p4Yla5xUQfW6uFEksXMp
         h+Rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=1KZ92zYILDahESjfhKhGayobjVbu/FpDMrdITCcqxXo=;
        b=oNWQEWk6/QOjyXVN+3OpR02p+18MJrxxlahbswfkb4YAIxB27Sy164vjyvPn2g2HCm
         WmrfVdpps/Qz+64Hofqn936aambiotZdH9KLM8D7WgkyxIANdArKGWdprpC2vKb8yoRr
         P8EnZMtukUx7xwqXGo0Pzdq3YXImCR918ibmBHHEM9zKwPE1MrMeBYFMx5M0dJ/hJxfv
         Hz7QmDX45BxkK8/W6sq2mZidcMKkE6xuNuIcV8F/SmBh3NuIOZnHToPV/EBZhkhfUAbU
         1bGrX+rHmTvtogTNugh03hfee8v7SGZVjGMDaLUz9ktKn7SoDenG0CpTCRJBervernjx
         G4CQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=b7Ke+YQB;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o30sor2374274qtc.51.2019.06.06.07.50.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 07:50:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=b7Ke+YQB;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=1KZ92zYILDahESjfhKhGayobjVbu/FpDMrdITCcqxXo=;
        b=b7Ke+YQBkCx0E3J0pPZLpVAC9+rc5KsP4dWKu6yYwvNpCeAE6ZlL7KwRbHU1HIMTmR
         2RMPZTyzms2qJ9eSY3qs49MIRBlxAbkWtM+PujgB/sGs5ktaPGkmc4WI8d0QDlNDUPHh
         sfNgztIs306AZWaamr9shlfnp6NFEcGjvbPp4UGL/kgELIBzA+NK9H2uVuX+vdYT777X
         BsDBGa52jWe3ot4nZts5c5RUSdmdufhR4MqA97EvW6AppKqL9zcp+ECY2R0nLelNDqrP
         26RpOweY9H0frhbjZy7FHYcVKISux2zzL6bkUzgsTQOA2nnJ3fssOueO1pAMKFpcNIAX
         jCVw==
X-Google-Smtp-Source: APXvYqxuH5l+9gMPCGPPkKKitahZmqZNXo76okgbLdEMX4KzOyGog26q61BBeC0cRApFtWnBihOSAQ==
X-Received: by 2002:aed:2de7:: with SMTP id i94mr41055012qtd.129.1559832619679;
        Thu, 06 Jun 2019 07:50:19 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id 29sm1219227qty.87.2019.06.06.07.50.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 07:50:19 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYtic-0001BO-M8; Thu, 06 Jun 2019 11:50:18 -0300
Date: Thu, 6 Jun 2019 11:50:18 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: rcampbell@nvidia.com, Felix Kuehling <Felix.Kuehling@amd.com>,
	Philip Yang <Philip.Yang@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/5] mm/hmm: hmm_vma_fault() doesn't always call
 hmm_range_unregister()
Message-ID: <20190606145018.GA3658@ziepe.ca>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190506232942.12623-5-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190506232942.12623-5-rcampbell@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 04:29:41PM -0700, rcampbell@nvidia.com wrote:
> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> The helper function hmm_vma_fault() calls hmm_range_register() but is
> missing a call to hmm_range_unregister() in one of the error paths.
> This leads to a reference count leak and ultimately a memory leak on
> struct hmm.
> 
> Always call hmm_range_unregister() if hmm_range_register() succeeded.
>
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/hmm.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 35a429621e1e..fa0671d67269 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -559,6 +559,7 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
>  		return (int)ret;
>  
>  	if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
> +		hmm_range_unregister(range);
>  		/*
>  		 * The mmap_sem was taken by driver we release it here and
>  		 * returns -EAGAIN which correspond to mmap_sem have been
> @@ -570,13 +571,13 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
>  
>  	ret = hmm_range_fault(range, block);
>  	if (ret <= 0) {
> +		hmm_range_unregister(range);

While this seems to be a clear improvement, it seems there is still a
bug in nouveau_svm.c around here as I see it calls hmm_vma_fault() but
never calls hmm_range_unregister() for its on stack range - and
hmm_vma_fault() still returns with the range registered.

As hmm_vma_fault() is only used by nouveau and is marked as
deprecated, I think we need to fix nouveau, either by dropping
hmm_range_fault(), or by adding the missing unregister to nouveau in
this patch.

Also, I see in linux-next that amdgpu_ttm.c has wrongly copied use of
this deprecated API, including these bugs...

amd folks: Can you please push a patch for your driver to stop using
hmm_vma_fault() and correct the use-after free? Ideally I'd like to
delete this function this merge cycle from hmm.git

Also if you missed it, I'm running a clean hmm.git that you can pull
into the AMD tree, if necessary, to get the changes that will go into
5.3 - if you need/wish to do this please consult with me before making a
merge commit, thanks. See:

 https://lore.kernel.org/lkml/20190524124455.GB16845@ziepe.ca/

So Ralph, you'll need to resend this.

Thanks,
Jason

