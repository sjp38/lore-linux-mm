Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFCA9C28CC1
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 20:12:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8E3F24135
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 20:12:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="mD+XA/C1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8E3F24135
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D2EE6B026A; Wed, 29 May 2019 16:12:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 284026B026D; Wed, 29 May 2019 16:12:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1737D6B026E; Wed, 29 May 2019 16:12:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D422A6B026A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 16:12:13 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 140so2690718pfa.23
        for <linux-mm@kvack.org>; Wed, 29 May 2019 13:12:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=PGcw43rEtHfebZ1ykAg+O3oB9Ib7l867UUY+4n/dk/Q=;
        b=UBWDGi/fuwyhzLpkm2l3HaVDZvfNC/TOcdpqL3q/HZUGTSAFuZNm4mdoua1ukViJWu
         FJvtG9/wtYAPaV8LUbBD28X/QYWXMNYZHNCtp5KVqVs4R1HvRq8wlJHvb7gU2WpATgxp
         5/j9W0dShvDISnH2d0f9kIMlenDgFjL5z7d9yLDJomGyagjgq6EcJxpHuQMtowNrqXgj
         epvMgF5pOj6T/kxnAAlv1pckkuPpiNY7Q79oIFU7P9rhYzU4EA2S2ales6Wfm27mse7d
         2/baZd04Dim2bcgC8WqbLirAfQ5senOzMssJubvPMvo4c5Q2JcQrbu0XQx9BW88UO6pM
         bwnw==
X-Gm-Message-State: APjAAAXItC4u+5QrD+rhiii+2QNVXj1TgPMIqtdwcx7DdnVRelVzUIHC
	0pR/o0DDL+19JpGVeGMW5DILAC93ymVamuRpxl3b1Z+Jmzo4JcSa50x2jw1Dq6Z4q6IwCeB7/rU
	+wpwwfvJ0kBXYPmVVEh2xBUV/YD+cJ1fdNedxPHyHSUDRmbS2W11hwfYKj5hMOTbb+Q==
X-Received: by 2002:a65:4649:: with SMTP id k9mr39946183pgr.239.1559160733440;
        Wed, 29 May 2019 13:12:13 -0700 (PDT)
X-Received: by 2002:a65:4649:: with SMTP id k9mr39946147pgr.239.1559160732756;
        Wed, 29 May 2019 13:12:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559160732; cv=none;
        d=google.com; s=arc-20160816;
        b=QGZqh6d+dq39BPovo3dqiaBJeoZ/1jJQWPwldlyPji9uChg0fcZwIpNt7uTE9ucOuK
         yu79vmJ7mwuytEBpGT4+y0AMGzR4y/RQjj0EfNS35D056b2kJ/AobG73y0sn5VetoK73
         2MQwgi23AnUVi1ejNfSvO0+VLpG0A9JBA7lIy2cUtwyXP2IBB0gLheSRTd/8k0ji+w82
         zHEWP9fCjCmzYt+WsCu5L2M5dUBt14eVllSa9SyQDmt9vi/whsJjtsDarNiTx0cAKXi+
         y03XJnRSS7igep/p7mpr0AEm5gps01CoJgz1z6hElpXnl5zDOBoUhvFITdn5l213p4CL
         rM3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=PGcw43rEtHfebZ1ykAg+O3oB9Ib7l867UUY+4n/dk/Q=;
        b=wiqhNp0IaFYpx0kquWtXPKBpFH0UUrOxK3ORW0AIb9J/yY/7aehTiMv/YXAJUBdD8e
         UGHIToOl+E0N748EB0SHr0g8q7o3wob7h//cqLsnobGce0PIvo+uYyA6XdNsq6Om7Tlo
         S0Y0UtnUoTHER+1zGoVnCBEGV9baJ6XuvWjRPGzzagC7zzLoUnCGnkUdVL9BhCIt3Krt
         cm6A2iA9t8JwdMYFHFD6v+i7lQWvbo5CPQBC6TWrjH2abfRsCdHQlQ0R/CttkUoDjYsn
         M7brnYDybJp6N1cmGUo4irjEz2gjhg1xC7zra8b8o7bu89EwTspHaJVcOv5giEdkGvjz
         LtKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="mD+XA/C1";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u17sor759697pgm.43.2019.05.29.13.12.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 13:12:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b="mD+XA/C1";
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=PGcw43rEtHfebZ1ykAg+O3oB9Ib7l867UUY+4n/dk/Q=;
        b=mD+XA/C1RPTuYpF3bAQXZIvQOGFykfuFTGv2T4SJe7rylVcI8w0NDLRy0IsBLJ66C4
         yVcYvfhvVtwxJaG6tBzpFRpEcG+JM4ZK+8yr+Vmhnc0lkQZ9h7mnNWkXgsjQ03iN9T3Y
         xn9BTzPrq4mJgfWOD9cwdHXpGjo9qYZ06UsdU=
X-Google-Smtp-Source: APXvYqwDEJpc5XVklT3bHvSVgN9OxPIFPApr20V/GjXll3oEfIoQdqDbKTvTIc6ODp034anrn4Q3IQ==
X-Received: by 2002:a63:f551:: with SMTP id e17mr11828943pgk.329.1559160732491;
        Wed, 29 May 2019 13:12:12 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id j2sm494584pfb.157.2019.05.29.13.12.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 13:12:11 -0700 (PDT)
Date: Wed, 29 May 2019 13:12:10 -0700
From: Kees Cook <keescook@chromium.org>
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v4 11/14] mips: Adjust brk randomization offset to fit
 generic version
Message-ID: <201905291311.7E88A71@keescook>
References: <20190526134746.9315-1-alex@ghiti.fr>
 <20190526134746.9315-12-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190526134746.9315-12-alex@ghiti.fr>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 26, 2019 at 09:47:43AM -0400, Alexandre Ghiti wrote:
> This commit simply bumps up to 32MB and 1GB the random offset
> of brk, compared to 8MB and 256MB, for 32bit and 64bit respectively.
> 
> Suggested-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  arch/mips/mm/mmap.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
> index ffbe69f3a7d9..c052565b76fb 100644
> --- a/arch/mips/mm/mmap.c
> +++ b/arch/mips/mm/mmap.c
> @@ -16,6 +16,7 @@
>  #include <linux/random.h>
>  #include <linux/sched/signal.h>
>  #include <linux/sched/mm.h>
> +#include <linux/sizes.h>
>  
>  unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
>  EXPORT_SYMBOL(shm_align_mask);
> @@ -189,11 +190,11 @@ static inline unsigned long brk_rnd(void)
>  	unsigned long rnd = get_random_long();
>  
>  	rnd = rnd << PAGE_SHIFT;
> -	/* 8MB for 32bit, 256MB for 64bit */
> +	/* 32MB for 32bit, 1GB for 64bit */
>  	if (TASK_IS_32BIT_ADDR)
> -		rnd = rnd & 0x7ffffful;
> +		rnd = rnd & SZ_32M;
>  	else
> -		rnd = rnd & 0xffffffful;
> +		rnd = rnd & SZ_1G;
>  
>  	return rnd;
>  }
> -- 
> 2.20.1
> 

-- 
Kees Cook

