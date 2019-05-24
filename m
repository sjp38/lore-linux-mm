Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9C2BC282DD
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 00:04:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BECE2177E
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 00:04:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="mmoVsIwH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BECE2177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB9CE6B0005; Thu, 23 May 2019 20:04:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6AB16B0006; Thu, 23 May 2019 20:04:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C58E76B0007; Thu, 23 May 2019 20:04:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A31F6B0005
	for <linux-mm@kvack.org>; Thu, 23 May 2019 20:04:52 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id p9so2228724plq.1
        for <linux-mm@kvack.org>; Thu, 23 May 2019 17:04:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=Bg3lp1cp1YsHZIAZ+WZ5FtPbgNHk60LZKuR1dQM5X0o=;
        b=NQR1u8SoYmXLZ1zeywCJBSQg7DMiZiMNzqpxmBTseOSH8wTiU85tMpnNmwegiMY3+J
         N7OeJ4sb6kY3WfJnwAC8Bdw6J93meAhUcNjzTy8KZQDEtBhjt02159dSNEWbfMRC024M
         BE4YCJkdqTYmndOHZnaiRYJ6ku9OZ9xKuSv490UwzLWk7X5I0Le9IXWT+XtMXcrEvBvK
         d+27xIznV4N8kMrTCSFA8vCnuhSNkfxWfiZZFXWbOL9sI3VG4rtaUZnp6c3Y7V4dsx31
         CxQc8777f1XIJxYXBZdEwYBSuQM8JF+N5rHA6+VX4BKFu7ELtZmhiATsd8nchyQjMZ2B
         iFPw==
X-Gm-Message-State: APjAAAXpQLM+T8+4Y561uXJhVuRT7926pxFXPO45Hq5i2no2PxbJUIbq
	JR55Ov7AIZXrOhEvfAmXMdmfv+i9CHHpxyWYmXf1TgAQ/De+TH2nIxuSDYMPE10Odj6HNCN5Lrr
	sLA+aUOH29s4t/s3l+JRF6h5rsYHQHtSK0HAzsaj7Lq2jGZxGaUE+MNhB8xrDF5jSGw==
X-Received: by 2002:aa7:9f01:: with SMTP id g1mr94863464pfr.259.1558656292168;
        Thu, 23 May 2019 17:04:52 -0700 (PDT)
X-Received: by 2002:aa7:9f01:: with SMTP id g1mr94863375pfr.259.1558656291401;
        Thu, 23 May 2019 17:04:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558656291; cv=none;
        d=google.com; s=arc-20160816;
        b=ouqGyS8t86urkvxAMKG7HB6U4zHpSHXnzL6w+SXcvoUumNIFWLMYC7/XJ5vMcm0Fjv
         VoJg4wD3pfBdhxrH0v7Bo8ajs6Rd5yCAZ2lX2pjNQ8LgHq8bSiL5yhxKGxGm20HGoRgD
         B544pUkriFIGgCzIPV2197WvfzWKAOkW0aNzMi1KOis265wZN2/EyiKEWL9M6F5r7uXK
         Kf7OFI4mq4BpG8yhk6sGOSd5rYvRvbuRmYzULVScgIcaDwoLmEhlouFn8ksfQ72mCdAV
         rxxLL7OLD7rRGDtFurkpG+wkNcduj+S/NLjNTu6lvjLJ3x9mX3RaBJbHKo1gIoUdLmpD
         eNOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=Bg3lp1cp1YsHZIAZ+WZ5FtPbgNHk60LZKuR1dQM5X0o=;
        b=CvFWreYuUC57bKR8Q5ONko3sYXFYT/iCxGXKbOtB626xnASc1to93Knab0Rd8XowDS
         CRJ0o8an9b9AwJj+mE4vXlRY3E3TwHiEC/+LbXn43FTJKf2SoTcfYS1cKMVzYaM5UzbA
         w4gkFlEL6nsfcp2bvkLi3hA32TYQr5Q341f3nISIXfOPn+z0R3raNBuTQlNVwqL3OU2r
         UoPXyRWX0UxxPy218ruhLM5S93opR1+C7Yyd0J/8ZSBOivurNS/OkB5LuvW7KSwT3ez+
         t7c4VsLd9b+Cnaci/IcG2zhYualutWW2Ezy7/JC0+g25UegESFMu7+GbtikAPig5UfWM
         OuKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=mmoVsIwH;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v13sor1039878pgr.24.2019.05.23.17.04.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 17:04:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=mmoVsIwH;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=Bg3lp1cp1YsHZIAZ+WZ5FtPbgNHk60LZKuR1dQM5X0o=;
        b=mmoVsIwHReQDPhkE8pfZYV7WXqnOV5tXm/Zklyw0xJ+ipTIIWge6M4WmPf43jJn3Ku
         wNC+tgP1Y9/6J2WES4ibeG2Hlp7iGy/v9AnM7BXbJMKkW4roaMU7xT6Dhyq1lNn2mIen
         RxLb0WX+C2o54dluBacYUimfY7Ll09hMwa7dU=
X-Google-Smtp-Source: APXvYqyctB5V+K3NG1DpFLMcyJb93jrwPDhvUf/DwGjUNUzz8Ua+BzD11CKG169jmEoBbkZnJd67Uw==
X-Received: by 2002:a63:1c16:: with SMTP id c22mr41564941pgc.333.1558656291059;
        Thu, 23 May 2019 17:04:51 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id b18sm625527pfp.32.2019.05.23.17.04.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 17:04:50 -0700 (PDT)
Date: Thu, 23 May 2019 17:04:48 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexander Potapenko <glider@google.com>
Cc: akpm@linux-foundation.org, cl@linux.com,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Michal Hocko <mhocko@kernel.org>, James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v4 1/3] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <201905231647.ED31A5FE30@keescook>
References: <20190523140844.132150-1-glider@google.com>
 <20190523140844.132150-2-glider@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523140844.132150-2-glider@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 04:08:42PM +0200, Alexander Potapenko wrote:
> diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
> index 52e6fbb042cc..68fb6fa41cc1 100644
> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -1673,6 +1673,14 @@
>  
>  	initrd=		[BOOT] Specify the location of the initial ramdisk
>  
> +	init_on_alloc=	[MM] Fill newly allocated pages and heap objects with
> +			zeroes.
> +			Format: 0 | 1
> +			Default set by CONFIG_INIT_ON_ALLOC_DEFAULT_ON.
> +	init_on_free=	[MM] Fill freed pages and heap objects with zeroes.
> +			Format: 0 | 1
> +			Default set by CONFIG_INIT_ON_FREE_DEFAULT_ON.
> +
>  	init_pkru=	[x86] Specify the default memory protection keys rights
>  			register contents for all processes.  0x55555554 by
>  			default (disallow access to all but pkey 0).  Can

Nit: add a blank line between these new options' documentation to match
the others.

> diff --git a/security/Kconfig.hardening b/security/Kconfig.hardening
> index 0a1d4ca314f4..87883e3e3c2a 100644
> --- a/security/Kconfig.hardening
> +++ b/security/Kconfig.hardening
> @@ -159,6 +159,20 @@ config STACKLEAK_RUNTIME_DISABLE
>  	  runtime to control kernel stack erasing for kernels built with
>  	  CONFIG_GCC_PLUGIN_STACKLEAK.
>  
> +config INIT_ON_ALLOC_DEFAULT_ON
> +	bool "Set init_on_alloc=1 by default"
> +	help
> +	  Enable init_on_alloc=1 by default, making the kernel initialize every
> +	  page and heap allocation with zeroes.
> +	  init_on_alloc can be overridden via command line.
> +
> +config INIT_ON_FREE_DEFAULT_ON
> +	bool "Set init_on_free=1 by default"
> +	help
> +	  Enable init_on_free=1 by default, making the kernel initialize freed
> +	  pages and slab memory with zeroes.
> +	  init_on_free can be overridden via command line.
> +

I think these could use a lot more detail. How about something like
these, with more details and performance notes:

config INIT_ON_ALLOC_DEFAULT_ON
	bool "Enable heap memory zeroing on allocation by default"
	help
	  This has the effect of setting "init_on_alloc=1" on the kernel
	  command line. This can be disabled with "init_on_alloc=0".
	  When "init_on_alloc" is enabled, all page allocator and slab
	  allocator memory will be zeroed when allocated, eliminating
	  many kinds of "uninitialized heap memory" flaws, especially
	  heap content exposures. The performance impact varies by
	  workload, but most cases see <1% impact. Some synthetic
	  workloads have measured as high as 7%.

config INIT_ON_FREE_DEFAULT_ON
	bool "Enable heap memory zeroing on free by default"
	help
	  This has the effect of setting "init_on_free=1" on the kernel
	  command line. This can be disabled with "init_on_free=0".
	  Similar to "init_on_alloc", when "init_on_free" is enabled,
	  all page allocator and slab allocator memory will be zeroed
	  when freed, eliminating many kinds of "uninitialized heap memory"
	  flaws, especially heap content exposures. The primary difference
	  with "init_on_free" is that data lifetime in memory is reduced,
	  as anything freed is wiped immediately, making live forensics or
	  cold boot memory attacks unable to recover freed memory contents.
	  The performance impact varies by workload, but is more expensive
	  than "init_on_alloc" due to the negative cache effects of
	  touching "cold" memory areas. Most cases see 3-5% impact. Some
	  synthetic workloads have measured as high as 8%.


-- 
Kees Cook


-- 
Kees Cook

