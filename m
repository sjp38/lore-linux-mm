Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FDFCC04A6B
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 01:05:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1ECF821479
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 01:05:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="b4bKpqtl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1ECF821479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A74C66B0003; Wed,  8 May 2019 21:05:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A25F46B0005; Wed,  8 May 2019 21:05:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EDF46B0007; Wed,  8 May 2019 21:05:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 590846B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 21:05:12 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s19so481557plp.6
        for <linux-mm@kvack.org>; Wed, 08 May 2019 18:05:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=G13SwZrvXQwLwqfSvC5cLaD8FJjp+bG9vvkSPGdxrhE=;
        b=sRfWmGImQShKinq+jJ2eGiS5SP51pfxU9BzJQLdhHj1Z5VyZMxmZveEbq4SV0GklMq
         bNeaHgxJzjSLxuehPB/BZdyDHd+GzZ5Y8vPW0/2qsZEI0WcY00mNbbG5T51VAOml1+mM
         Xhp0WCNo/nv+DzN6wMAaofaqXLLo7yyLG5LDD77SVsCtEIbEDZr0AndnvuOnUx861CF+
         vfDUBV0jqTOZQgqcEqZLROgNogstsilxxEDIJ1NgleDiETFb+Qo4D4had8HvqCkXxH27
         /CrxRIXJVLDeOPu2GdlntAqnkO5+t0Pl0kAfwHhgftEfNioU9LjA+dK7VuN7v289s3iO
         R9hw==
X-Gm-Message-State: APjAAAXJFvj5TlwGaceWzIt6PjXqCSiOXkMB/liH6ATdIOI3AGoPod+W
	ktKSNBaeQR3kOdKIcp5euCtz/S9Q1WW9Drh6y7dn+MgGKR1TgexkZQT4ZTjnLihcA7ZPUQaqvLG
	ezV7j/M/ZydVgwWMfRV32A7doxuson2B6VUM2nbYBDIUTw2Wprf1GSw5g8SZBH8rePQ==
X-Received: by 2002:a63:2b41:: with SMTP id r62mr1637012pgr.403.1557363911905;
        Wed, 08 May 2019 18:05:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTGYmt5YUuVKfBdQopMlWIc2iY64TcA9MGFlru8Mcgiz8QB8I+YyWsqbWCBQy/Pr8hnpPL
X-Received: by 2002:a63:2b41:: with SMTP id r62mr1636879pgr.403.1557363910933;
        Wed, 08 May 2019 18:05:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557363910; cv=none;
        d=google.com; s=arc-20160816;
        b=sF0dep1vjuBgYNe+s79eFGsUxqGQ/Re8MkVizLk/Fk8u2b0XnsgWT6wOpzMJnOdgMF
         5u7uybnb/juugnMzOniOZyJXGE4RMoBMc2aXh1SvXmVH1udY0UynzN7iaRuTLN1BmTcn
         GcRlGjkkEQ5Ti2aRrZFekCCDJ4O7Z8rwkFC5+S2gaZij2Mo5/ZqBWqKrDt7YbkLaSR1l
         Fsrnqwu3hMzzuygqHfI1FXnNU6uMdclMJ7uCP0e9Hw/y4GQskkfVyr1ikoiTsaGGaEor
         t2yjUDfWqp3wKeOEWFbBqs3gYvjq892x5Uv/1m7BvW2E5msRhlML8AEfsBzBJbhYdCmm
         tOHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=G13SwZrvXQwLwqfSvC5cLaD8FJjp+bG9vvkSPGdxrhE=;
        b=dBJlU931qqMVO+nWeWu1ffwOtCjUqG7T2I6TN6p2C+Y30+44Uytrwg5Najk22vDfnu
         ikAngxJ+SyLn2BqA43Kil3G2geFnPC/lf5ZYLJUmdg1jegQZNXNPpT0oh1zfnK6kWPl3
         fpCSMV9R9t9MldjeC/TVdFP6wNTxerVgAu0rAn1IDRdqM2osME1gsOQf3qEmKLp8ty7M
         XmiboeeWbXv/w8Jp+BY1MInRCWQEijRQdJbYTKXPjIrnYT/hy7VsUZTYSslN2UyX7moG
         fVFJOMOGtBVFMww7y3yex9rds7eD8Z16GuooOSe2b3iOShTTgT7chdwDglOnmdIrBTCp
         XumQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=b4bKpqtl;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a92si667102pla.256.2019.05.08.18.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 08 May 2019 18:05:10 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=b4bKpqtl;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=G13SwZrvXQwLwqfSvC5cLaD8FJjp+bG9vvkSPGdxrhE=; b=b4bKpqtlBzzAQmT4dULJ60Wx/
	4+mV8vaQI2ye68XjE42FuRpIw2V+NKJMAqALzmF4L45TsWnm64cyf9aZYpA8l8d1NVLuDS8uIeCMm
	2B7tvT+bSk4czrUY6K7SQEb6YcRxEbbkhhUCmU6VEmkdwCO+ZFvwQ/ZUJqgP/w4jZo4iHlN3eaVL+
	kK/r7hTkrByF/ZaNFivjTPBINatmyiTOXJz51A7fd2jgcAqqDsyZ7d8uJeCUAQmLsnA5elniY+wKR
	sRgfHraFrxNNMgi36b/ZcrHq1Zw1KU7TahBjwB+7xbQIFWjjkzqDqw82hUi657MF+rES6DBkqzcCu
	rbCtLeMpQ==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hOXUW-0003Al-Pt; Thu, 09 May 2019 01:04:56 +0000
Subject: Re: [PATCH 1/4] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
To: Alexander Potapenko <glider@google.com>, akpm@linux-foundation.org,
 cl@linux.com, keescook@chromium.org, labbott@redhat.com
Cc: linux-mm@kvack.org, linux-security-module@vger.kernel.org,
 kernel-hardening@lists.openwall.com, yamada.masahiro@socionext.com,
 jmorris@namei.org, serge@hallyn.com, ndesaulniers@google.com,
 kcc@google.com, dvyukov@google.com, sspatil@android.com, jannh@google.com,
 mark.rutland@arm.com
References: <20190508153736.256401-1-glider@google.com>
 <20190508153736.256401-2-glider@google.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <6e5ccf92-cc58-ab2b-d025-0f5642d5f4a6@infradead.org>
Date: Wed, 8 May 2019 18:04:55 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190508153736.256401-2-glider@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/8/19 8:37 AM, Alexander Potapenko wrote:
> diff --git a/security/Kconfig.hardening b/security/Kconfig.hardening
> index 0a1d4ca314f4..4a4001f5ad25 100644
> --- a/security/Kconfig.hardening
> +++ b/security/Kconfig.hardening
> @@ -159,6 +159,22 @@ config STACKLEAK_RUNTIME_DISABLE
>  	  runtime to control kernel stack erasing for kernels built with
>  	  CONFIG_GCC_PLUGIN_STACKLEAK.
>  
> +config INIT_ON_ALLOC_DEFAULT_ON
> +	bool "Set init_on_alloc=1 by default"
> +	default false

That should be spelled "default n" but since that is already the default,
just omit the line completely.

> +	help
> +	  Enable init_on_alloc=1 by default, making the kernel initialize every
> +	  page and heap allocation with zeroes.
> +	  init_on_alloc can be overridden via command line.
> +
> +config INIT_ON_FREE_DEFAULT_ON
> +	bool "Set init_on_free=1 by default"
> +	default false

ditto.

> +	help
> +	  Enable init_on_free=1 by default, making the kernel initialize freed
> +	  pages and slab memory with zeroes.
> +	  init_on_free can be overridden via command line.
> +
>  endmenu
>  
>  endmenu


-- 
~Randy

