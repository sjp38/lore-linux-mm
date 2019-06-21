Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DDE7C48BE0
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 07:09:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC9CB20679
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 07:09:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC9CB20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E741D6B0005; Fri, 21 Jun 2019 03:09:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E25098E0002; Fri, 21 Jun 2019 03:09:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D136A8E0001; Fri, 21 Jun 2019 03:09:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 813696B0005
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 03:09:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d13so7936912edo.5
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 00:09:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cgp+8nBWSnEfDdIQm5qc/FYznVQVgcoqfLpOQVoe0nw=;
        b=Cr4QLAtPUQpep80hMc0xMDybmFfaM3B7UlV+uvGvAv644yKbl9y9gu5CrcFBRTJ9aX
         zCj8mAHn0Fo8jqTjA/0mAsf2ZfyptgwXMRSxHvwrDuIv6sB6kGxKeEcJtXCJMo7dnHhJ
         QQZagg6OhjXrWgdVlg8Wg7On3BUo8D5oRXV+PJxtyC5K5Zon7Uqk4pVYQmjBfD9vejiu
         TLhKLyhpdj2zyQKpthdH/IXM2VYxCEEQFexdexXWNLDyRu5YJLhWjYR/WWIsZeimCf42
         4LeD7okWI3XamP3hKj+2wvI2nafWaWRG/84/VYmx8jobrxy4NjL0Cq1njmQBqJjd0ijj
         Ivfg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV1+OPfFQQuFnWYkavy7i24qO1yTgAZtJ5F3NvDcckY9TOgZTXZ
	XCA54yWKYBB81BDcFh5OHJmHDjC+0ivWTnt/T4Oz1UATOxMyFVtp4XDGo/ms+QR0TYc24lrd6sK
	V+ZrIvQlIxSZAsY4u2M5X6YVkHw0rBdHYpqiK2Ymh1ZuxEg95b5JZyDcWrOykZAg=
X-Received: by 2002:a17:906:d50b:: with SMTP id ge11mr63820807ejb.227.1561100949990;
        Fri, 21 Jun 2019 00:09:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqySsoOPCei76MGSFe8msNzD/mboYqpJBKC22LAI4n9Uq++AQHPMnZ0avgmJDN9TbPVw//P5
X-Received: by 2002:a17:906:d50b:: with SMTP id ge11mr63820735ejb.227.1561100948826;
        Fri, 21 Jun 2019 00:09:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561100948; cv=none;
        d=google.com; s=arc-20160816;
        b=jb9uLGMjD7wWA1yzbstHdLoTMuyBGH7zhMzvj2Jr6g7W0y5E63cvO1QeyvhLk/3RjR
         8aac1tKeE3uRrmvDKZrF5iNswzBmwDcwKTJIy9ZYc8RxcKceTLMFKVJ1j86zp1A+3syv
         fO/b6+MImS4WCBm+PMd+gYFvAHcf/YIKD4mNNK7nOiOAd1QshdFF81H/K3O3/CB/zR3Y
         jX1JvT474OgvJxgzEvXuMGV9ryYiZdwZ39RQTPfzN+7mpG8omaA4dx1T+5UKjTQXYHFG
         fTtNNx4V7PbfBafVg2o6qF8e+kcwls2A5FoK92T1sar905lHRAIgMAdUcxyvO+dhH/eG
         NxBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cgp+8nBWSnEfDdIQm5qc/FYznVQVgcoqfLpOQVoe0nw=;
        b=maDFAuTsQaB16to7goN6u6yd7stzyzJFDllVLgPthm/ShQSU4YNLvP1BS5+WtZ6vvo
         3R14coi9I29GodO9ig0bZp5nfEPfWhIRyvuvcG2jJVEpSCpe7radBnrQKMZk88lTsAd2
         +vetSzxBrUIMpRvhwbvcF2iXEtTsWL3MmR5v6CnUmiT4VGASaDTOVyrAbQfq0RjYZBV3
         fyA/gP0WHhkgN+I2BxhQpURUJerBa20ovQGIkzbjE1MHmz8/YdW7MdgDFpWxs1iQpA0n
         sjsx8nSpNlqDTukjUrq8JNeimVDKFUvkqp997AhvALM8vgCqITPUYe+P10LFffT6h7Jt
         V0kw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k2si1688456eds.64.2019.06.21.00.09.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 00:09:08 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D6DB5ACC5;
	Fri, 21 Jun 2019 07:09:07 +0000 (UTC)
Date: Fri, 21 Jun 2019 09:09:05 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>,
	linux-mm@kvack.org, linux-security-module@vger.kernel.org,
	kernel-hardening@lists.openwall.com
Subject: Re: [PATCH v7 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <20190621070905.GA3429@dhcp22.suse.cz>
References: <20190617151050.92663-1-glider@google.com>
 <20190617151050.92663-2-glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617151050.92663-2-glider@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 17-06-19 17:10:49, Alexander Potapenko wrote:
> The new options are needed to prevent possible information leaks and
> make control-flow bugs that depend on uninitialized values more
> deterministic.
> 
> init_on_alloc=1 makes the kernel initialize newly allocated pages and heap
> objects with zeroes. Initialization is done at allocation time at the
> places where checks for __GFP_ZERO are performed.
> 
> init_on_free=1 makes the kernel initialize freed pages and heap objects
> with zeroes upon their deletion. This helps to ensure sensitive data
> doesn't leak via use-after-free accesses.
> 
> Both init_on_alloc=1 and init_on_free=1 guarantee that the allocator
> returns zeroed memory. The two exceptions are slab caches with
> constructors and SLAB_TYPESAFE_BY_RCU flag. Those are never
> zero-initialized to preserve their semantics.
> 
> Both init_on_alloc and init_on_free default to zero, but those defaults
> can be overridden with CONFIG_INIT_ON_ALLOC_DEFAULT_ON and
> CONFIG_INIT_ON_FREE_DEFAULT_ON.
> 
> Slowdown for the new features compared to init_on_free=0,
> init_on_alloc=0:
> 
> hackbench, init_on_free=1:  +7.62% sys time (st.err 0.74%)
> hackbench, init_on_alloc=1: +7.75% sys time (st.err 2.14%)
> 
> Linux build with -j12, init_on_free=1:  +8.38% wall time (st.err 0.39%)
> Linux build with -j12, init_on_free=1:  +24.42% sys time (st.err 0.52%)
> Linux build with -j12, init_on_alloc=1: -0.13% wall time (st.err 0.42%)
> Linux build with -j12, init_on_alloc=1: +0.57% sys time (st.err 0.40%)
> 
> The slowdown for init_on_free=0, init_on_alloc=0 compared to the
> baseline is within the standard error.
> 
> The new features are also going to pave the way for hardware memory
> tagging (e.g. arm64's MTE), which will require both on_alloc and on_free
> hooks to set the tags for heap objects. With MTE, tagging will have the
> same cost as memory initialization.
> 
> Although init_on_free is rather costly, there are paranoid use-cases where
> in-memory data lifetime is desired to be minimized. There are various
> arguments for/against the realism of the associated threat models, but
> given that we'll need the infrastructre for MTE anyway, and there are
> people who want wipe-on-free behavior no matter what the performance cost,
> it seems reasonable to include it in this series.

Thanks for reworking the original implemenation. This looks much better!

> Signed-off-by: Alexander Potapenko <glider@google.com>
> Acked-by: Kees Cook <keescook@chromium.org>
> To: Andrew Morton <akpm@linux-foundation.org>
> To: Christoph Lameter <cl@linux.com>
> To: Kees Cook <keescook@chromium.org>
> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: James Morris <jmorris@namei.org>
> Cc: "Serge E. Hallyn" <serge@hallyn.com>
> Cc: Nick Desaulniers <ndesaulniers@google.com>
> Cc: Kostya Serebryany <kcc@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Sandeep Patil <sspatil@android.com>
> Cc: Laura Abbott <labbott@redhat.com>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: Jann Horn <jannh@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Marco Elver <elver@google.com>
> Cc: linux-mm@kvack.org
> Cc: linux-security-module@vger.kernel.org
> Cc: kernel-hardening@lists.openwall.com

Acked-by: Michal Hocko <mhocko@suse.cz> # page allocator parts.

kmalloc based parts look good to me as well but I am not sure I fill
qualified to give my ack there without much more digging and I do not
have much time for that now.

[...]
> diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> index fd5c95ff9251..2f75dd0d0d81 100644
> --- a/kernel/kexec_core.c
> +++ b/kernel/kexec_core.c
> @@ -315,7 +315,7 @@ static struct page *kimage_alloc_pages(gfp_t gfp_mask, unsigned int order)
>  		arch_kexec_post_alloc_pages(page_address(pages), count,
>  					    gfp_mask);
>  
> -		if (gfp_mask & __GFP_ZERO)
> +		if (want_init_on_alloc(gfp_mask))
>  			for (i = 0; i < count; i++)
>  				clear_highpage(pages + i);
>  	}

I am not really sure I follow here. Why do we want to handle
want_init_on_alloc here? The allocated memory comes from the page
allocator and so it will get zeroed there. arch_kexec_post_alloc_pages
might touch the content there but is there any actual risk of any kind
of leak?

> diff --git a/mm/dmapool.c b/mm/dmapool.c
> index 8c94c89a6f7e..e164012d3491 100644
> --- a/mm/dmapool.c
> +++ b/mm/dmapool.c
> @@ -378,7 +378,7 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
>  #endif
>  	spin_unlock_irqrestore(&pool->lock, flags);
>  
> -	if (mem_flags & __GFP_ZERO)
> +	if (want_init_on_alloc(mem_flags))
>  		memset(retval, 0, pool->size);
>  
>  	return retval;

Don't you miss dma_pool_free and want_init_on_free?
-- 
Michal Hocko
SUSE Labs

