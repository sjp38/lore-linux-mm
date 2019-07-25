Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E904AC76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:22:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA9A4218DA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:22:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA9A4218DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E40F8E003D; Thu, 25 Jul 2019 02:22:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 594168E0031; Thu, 25 Jul 2019 02:22:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45C538E003D; Thu, 25 Jul 2019 02:22:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EDCBA8E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:22:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b33so31498146edc.17
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 23:22:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=51AIC3JPqwnkDKcGbRstueAsQKK3cIJET1xOLNapmvM=;
        b=n7DswnEkmfdf8FTYMsreR/FB00WOF2QCcRLbSr9JvgcKNIkSdOam3Vb95TIdWrUNVF
         pyCyQLKMajJxgfL3cuWPgOuNjrzVkzSNm7n5pEUyHQlVHK52Gxu4cBZZ2sZNc5RhcfYz
         NNCzD0UhMmCLN1VRn+3/tS+sMyLk+nuxlbeDSXTidsQ8m/2rLK+iC9JME83IfIPs/V/5
         A6dadGpS8fgi77NTnFYilt2ORkoI9NV5Ji6UaOUJwf2s2lt0FJoHIABWf4LmVxipICBj
         3lR7i5LeLw9KCf3WpFeP9eWsv0+uzdIfTNQOxnvJ0pv7nxjUw+8boU32xcC29a1Mi5gu
         ndnA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAU+3vzV/rJRiX3lnLxlqpCN2f9tTIwBey4tf45LuHpKTWIZZl1x
	5aQfurQCvp6cYyFnvOFv13ZEe+P0Zwazq7CgqW+16OIXW/rYTGzhuq6J6irgWDjH+nXx4Yz1rlw
	fWuPYPa2tpSMrJcnlY3RcAunFg/7OoETbs7PoUCzKkXQRJMGKch504wcZql3gEx0=
X-Received: by 2002:a50:ba81:: with SMTP id x1mr74003096ede.257.1564035735549;
        Wed, 24 Jul 2019 23:22:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9xObZnwVysp4k1NSdfMvOMbuzbQ+GY2WKuSEZCBkr0zwRSq3Ut8u9v+rPMM59gAyO77cg
X-Received: by 2002:a50:ba81:: with SMTP id x1mr74002813ede.257.1564035730019;
        Wed, 24 Jul 2019 23:22:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564035730; cv=none;
        d=google.com; s=arc-20160816;
        b=Z+ZfG0r+6RqqK8De85M1blaFtaWegCC8mRhkd4LqrrsCinlsTIfpIIRP/9aYa7D/7c
         8nHmxQaZTvkL8LCTGFmQk5JQhKtTT9TXewjqT1z0RXEp4kqbuvSNtKDQbeY2x+/Nn2Wi
         dHMEPIXvqBDoODTBnlB/RdS+qbK+r33lOgNdq+uIkqHy/2xZhMD5y3xXGufze04i1JPR
         hqxedPSRkm1Z8zJmEIrJqaqW5m0La3StRNcv2icz3kD024rHRYktGZ0mg6D29LJozlMJ
         YqGo2A8smPcqm56B6HbaoY5Xv6WOyS4l89UL1jLW+3frNLAhWaF+NPQtfjNWN2IlCrO9
         rU7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=51AIC3JPqwnkDKcGbRstueAsQKK3cIJET1xOLNapmvM=;
        b=R4LRmBF8YvtNGzOxJu/61oTTxfrjej4oaTQiT8x/UTwdoGp+WtAgDzvpkpLQRogxIw
         9qTq72O7NhyNgVjzCuCxhcItBvrTj5V5J+JYm8KxRNK3VjY6CBKHnS9yfHA9g57rWCpj
         42GyOWVIZgbflTKgvGNu+BdvvxfxdDc8c3sPiMQ4MHGwRTr5jVbjBXV8d+QMQRRjoZuE
         PiCM9hZGqlcSz9eTLsY4Rh+mme6MKhCtUBPZQYTdtmIEzqXQX7s4kPhlXynJNBztc83P
         rEQhdpdxEeDl4f16/Tzy+QE6CnW8ZrbY5dAif33VT1merwnuT0lcrhqmwqzry9F0AQgE
         NQSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [217.70.183.196])
        by mx.google.com with ESMTPS id dt22si8432583ejb.214.2019.07.24.23.22.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Jul 2019 23:22:10 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.196;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.196 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 81.250.144.103
Received: from [10.30.1.20] (lneuilly-657-1-5-103.w81-250.abo.wanadoo.fr [81.250.144.103])
	(Authenticated sender: alex@ghiti.fr)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 5DDD5E000E;
	Thu, 25 Jul 2019 06:22:06 +0000 (UTC)
Subject: Re: [PATCH REBASE v4 11/14] mips: Adjust brk randomization offset to
 fit generic version
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Albert Ou <aou@eecs.berkeley.edu>, Kees Cook <keescook@chromium.org>,
 Catalin Marinas <catalin.marinas@arm.com>, Palmer Dabbelt
 <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>,
 Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Paul Burton <paul.burton@mips.com>, Alexander Viro
 <viro@zeniv.linux.org.uk>, James Hogan <jhogan@kernel.org>,
 linux-fsdevel@vger.kernel.org, linux-riscv@lists.infradead.org,
 linux-mips@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
 linux-arm-kernel@lists.infradead.org, Luis Chamberlain <mcgrof@kernel.org>
References: <20190724055850.6232-1-alex@ghiti.fr>
 <20190724055850.6232-12-alex@ghiti.fr>
From: Alexandre Ghiti <alex@ghiti.fr>
Message-ID: <1ba4061a-c026-3b9e-cd91-3ed3a26fce1b@ghiti.fr>
Date: Thu, 25 Jul 2019 08:22:06 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190724055850.6232-12-alex@ghiti.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: fr
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/24/19 7:58 AM, Alexandre Ghiti wrote:
> This commit simply bumps up to 32MB and 1GB the random offset
> of brk, compared to 8MB and 256MB, for 32bit and 64bit respectively.
>
> Suggested-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> ---
>   arch/mips/mm/mmap.c | 7 ++++---
>   1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
> index a7e84b2e71d7..faa5aa615389 100644
> --- a/arch/mips/mm/mmap.c
> +++ b/arch/mips/mm/mmap.c
> @@ -16,6 +16,7 @@
>   #include <linux/random.h>
>   #include <linux/sched/signal.h>
>   #include <linux/sched/mm.h>
> +#include <linux/sizes.h>
>   
>   unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
>   EXPORT_SYMBOL(shm_align_mask);
> @@ -189,11 +190,11 @@ static inline unsigned long brk_rnd(void)
>   	unsigned long rnd = get_random_long();
>   
>   	rnd = rnd << PAGE_SHIFT;
> -	/* 8MB for 32bit, 256MB for 64bit */
> +	/* 32MB for 32bit, 1GB for 64bit */
>   	if (TASK_IS_32BIT_ADDR)
> -		rnd = rnd & 0x7ffffful;
> +		rnd = rnd & SZ_32M;
>   	else
> -		rnd = rnd & 0xffffffful;
> +		rnd = rnd & SZ_1G;
>   
>   	return rnd;
>   }

Hi Andrew,

I have just noticed that this patch is wrong, do you want me to send
another version of the entire series or is the following diff enough ?
This mistake gets fixed anyway in patch 13/14 when it gets merged with the
generic version.

Sorry about that,

Thanks,

Alex

diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index a7e84b2e71d7..ff6ab87e9c56 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -16,6 +16,7 @@
  #include <linux/random.h>
  #include <linux/sched/signal.h>
  #include <linux/sched/mm.h>
+#include <linux/sizes.h>

  unsigned long shm_align_mask = PAGE_SIZE - 1;  /* Sane caches */
  EXPORT_SYMBOL(shm_align_mask);
@@ -189,11 +190,11 @@ static inline unsigned long brk_rnd(void)
         unsigned long rnd = get_random_long();

         rnd = rnd << PAGE_SHIFT;
-       /* 8MB for 32bit, 256MB for 64bit */
+       /* 32MB for 32bit, 1GB for 64bit */
         if (TASK_IS_32BIT_ADDR)
-               rnd = rnd & 0x7ffffful;
+               rnd = rnd & (SZ_32M - 1);
         else
-               rnd = rnd & 0xffffffful;
+               rnd = rnd & (SZ_1G - 1);

         return rnd;
  }



