Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDBF4C48BE3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 01:01:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A53472085A
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 01:01:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="PbKjdPWc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A53472085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EC266B0005; Thu, 20 Jun 2019 21:01:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39DC58E0002; Thu, 20 Jun 2019 21:01:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 265438E0001; Thu, 20 Jun 2019 21:01:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DFFC56B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 21:01:44 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c17so3198066pfb.21
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 18:01:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=jOk3PreZ3YiInlE3LTXkzPl68+QbundNai30bAJKnEU=;
        b=eKLTmUR6Yx2q+egWYXiNFnlab+m4a2b2pMXj0Xi3hZD1G8bUKCGio9VVH03IDb0gn9
         01dZ8eCBGWHC+pxlvkJpkAoWO0SzD6fKaRe5sBnJIRFiwLfg6/VEhRXUSJBVzACkbdei
         BiUDN/4eYwQ+h1nXHLlVY2fqUMmOUY4pgx8zwCIRTqGWj1PvC9IpayDzUWQ0aC/qqkj1
         jmVwg7VZKwxAXAFbHgqk0qICa5txj19iFXKcZ8etP3yUkrkHL+9sTGC7h6CwBS7hz6is
         6LpZd+cZ1kOWi48tgVgn22sBOPrFcRPpL+JCkaj/M5vy5S2mUL3TkzjudhpMNW6UzWKo
         i7ww==
X-Gm-Message-State: APjAAAWZKRm6cH0TZJgXlRqE12jP9kA8l6VpFaPV8/zgUs9RYEbedG2R
	NpK4LQD0gso5gV5N+vNpjRfg8OM7AUfKdt6zFUIFzv1R8Icu+ZsrttowOgmTMFWALi630y6WKCr
	n30YCSXegY6cNosFOSrahSJyTkZjGd28WI4gJWkSEiuP6LXWVjZWlS1DF1dAxM1pkaA==
X-Received: by 2002:a17:90a:b011:: with SMTP id x17mr2746720pjq.113.1561078904387;
        Thu, 20 Jun 2019 18:01:44 -0700 (PDT)
X-Received: by 2002:a17:90a:b011:: with SMTP id x17mr2746620pjq.113.1561078903469;
        Thu, 20 Jun 2019 18:01:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561078903; cv=none;
        d=google.com; s=arc-20160816;
        b=N/XTJZB9hkNVpsZfpTv0zDNlqlzk3nThh+vasyKF46ssZY3vW6YM7GiTiYYMgXxwrT
         HHLHP1VvzqmL8VkcFTg6Nb2GGLxRmTrKmFmWmjTO3wZZ0YXLbtaPAERa+frLQvNvV8BH
         SygCBo0O7xGjloZa8dwPPyiY+WVxqP0u5ATmFCdhhosdFiia0jw2yeRerVAARdcZ2Cku
         upTfvjO6X8MOYRlE2CNIT+aA8A0hyuxVi3JpBe0CDPYZlMipAVu58rqug4citiVTDEkd
         FDMXtt9xMK/pntsaXio4XmvnPxJySw1ZKOKDOq0BuT7NpKwSXg0rMa4N0lQp0e6iNBO9
         xHeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=jOk3PreZ3YiInlE3LTXkzPl68+QbundNai30bAJKnEU=;
        b=WY38muJdV3kicWvJ47xXSj3x99gJ9NCr8sPUDp+ToVfTlqb03+kB9EIFw8ig8uoHTc
         Hqg5VyUSWAam9gXxu9q9jhO9/4opaVVzSUlO7o91G3NA2/c7WCFKv2ctmKqJ5WHZtNBi
         QIbrxRLWyh++hINW/FfaBS1gMPf+a+mBXxum2/7GDQOSJqdPdfpkdLHzCdRkuMtmAYXg
         ppxmKdKVvyTpzUv827NCflcjPoTqIV3w9C7BDSDmBniM+xoBHYQZW3q8Ymr5uPrSAyx/
         LwinMQ0yPQyFMDKmwN+Qr6AQEFgZMQDEH4RvD1CCzh0gZzB2o1WRdk0b8DosrJW9EpP8
         9QZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=PbKjdPWc;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r3sor1108373pgj.74.2019.06.20.18.01.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 20 Jun 2019 18:01:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=PbKjdPWc;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=jOk3PreZ3YiInlE3LTXkzPl68+QbundNai30bAJKnEU=;
        b=PbKjdPWcdAzMqG/JzK1HR0UcqG/UX8eh2967eEegjSLi4avW+I1MWzePzFoaR/RhDz
         v936+ryvXqtDcxrnJqsy5S/83EDuAVf5GwkEF/Kd7NU5M9kBznE739f8ulkLOKnCN5TP
         BgbRDjDHZ8uwDaNrUzaVY5sjhf5UK5VV4W7MA=
X-Google-Smtp-Source: APXvYqwVLiWe21jhFrAmpCuL2rGWSXFn0Xn+zlSdAo/GWr7qvi7R3zAyZAmL5tMFTjfT5QVEED6QXQ==
X-Received: by 2002:a65:50c3:: with SMTP id s3mr15343980pgp.177.1561078902926;
        Thu, 20 Jun 2019 18:01:42 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id v13sm650415pfe.105.2019.06.20.18.01.41
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 20 Jun 2019 18:01:42 -0700 (PDT)
Date: Thu, 20 Jun 2019 18:01:41 -0700
From: Kees Cook <keescook@chromium.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, glider@google.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH -next v2] mm/page_alloc: fix a false memory corruption
Message-ID: <201906201801.9CFC9225@keescook>
References: <1561063566-16335-1-git-send-email-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1561063566-16335-1-git-send-email-cai@lca.pw>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 20, 2019 at 04:46:06PM -0400, Qian Cai wrote:
> The linux-next commit "mm: security: introduce init_on_alloc=1 and
> init_on_free=1 boot options" [1] introduced a false positive when
> init_on_free=1 and page_poison=on, due to the page_poison expects the
> pattern 0xaa when allocating pages which were overwritten by
> init_on_free=1 with 0.
> 
> Fix it by switching the order between kernel_init_free_pages() and
> kernel_poison_pages() in free_pages_prepare().

Cool; this seems like the right approach. Alexander, what do you think?

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> 
> [1] https://patchwork.kernel.org/patch/10999465/
> 
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
> 
> v2: After further debugging, the issue after switching order is likely a
>     separate issue as clear_page() should not cause issues with future
>     accesses.
> 
>  mm/page_alloc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 54dacf35d200..32bbd30c5f85 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1172,9 +1172,10 @@ static __always_inline bool free_pages_prepare(struct page *page,
>  					   PAGE_SIZE << order);
>  	}
>  	arch_free_page(page, order);
> -	kernel_poison_pages(page, 1 << order, 0);
>  	if (want_init_on_free())
>  		kernel_init_free_pages(page, 1 << order);
> +
> +	kernel_poison_pages(page, 1 << order, 0);
>  	if (debug_pagealloc_enabled())
>  		kernel_map_pages(page, 1 << order, 0);
>  
> -- 
> 1.8.3.1
> 

-- 
Kees Cook

