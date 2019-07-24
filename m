Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DB9C5C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:16:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACCF320840
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:16:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACCF320840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B1488E0008; Wed, 24 Jul 2019 13:16:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 261D98E0005; Wed, 24 Jul 2019 13:16:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 150BE8E0008; Wed, 24 Jul 2019 13:16:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D06528E0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:16:51 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j22so28934981pfe.11
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:16:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=156P/sv9kl3W4lzShHBiZ6Cb3GP3B3vD0ubCKwHKThU=;
        b=ejoD2EprzBcg6lzYuFfwRhX/nWsPZc8yXcvNRZaKe5NbV6RN5DnpUHkKrMxqVADJ34
         k+kTVOobHvpVlZ16E1PO/p+v50pG78quvRJU03Hh4K0mEqrXXZMG/KxPCeKSg/SWnOIU
         ZFOtVb4vt8yn2agRMdxwR7IVxVL3J0SXEWb78Nd+sBL07hXk4GCnPH8dGhisrf7zdROV
         fX3FVSFElSJzzdn2naHEJHQotNKBnDzPdHgQR9kRSgU1vLTuCGyMSUTQZlbmZXf3F8dS
         TSITWFBzYxVnljFRfGNALdLLWr9aB+gZIsMyZ9ni/IcT9A0TeQHUT/wHG1A0s4vyEBOS
         doIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX4l3AvI1Cc/oVp6v4kUMwk775N8mILMvpNATZqqFL94ZO0OoGs
	BJWeeAPDW6nr/Y5wBoiDGs8sZmWqJ4V2EYgkzh+k8qA45TNJnsH+lJD/b0X4tolfm9phFKsvUxO
	V3lW5JZsg1l12mOIiXC58YYXVPQVYIuxQbhI15Z0+0XPdH+rO+9XgAKL+zvVh0C8=
X-Received: by 2002:a65:500a:: with SMTP id f10mr51549439pgo.105.1563988611462;
        Wed, 24 Jul 2019 10:16:51 -0700 (PDT)
X-Received: by 2002:a65:500a:: with SMTP id f10mr51549403pgo.105.1563988610871;
        Wed, 24 Jul 2019 10:16:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563988610; cv=none;
        d=google.com; s=arc-20160816;
        b=dDg8cOYggnK9LIHwsxpfRqU38dkCqD+NI/q3A2A5iMGJ1f0V9nSva5Ia045Yx8DOmu
         6UdtB/6NSPlWN/MDOfbzWZ/VYoGY2KQDNoOO7s8/bNP572wbR5CLFwkRRitF1UMaEmxN
         mbbQsHA6EHU9rgHNEtuBPqvykffCeHuTAHFqiANlZQECEYOI2PS4PgjVbJzL4GfvvfRS
         Vl0aTK0nWa+DA99V16m2ANGf3vNp3tEUzO9wJifGK2SBhnUwogHwSXDkuBy/7FEfDaAG
         TRsNdzCC4XxE4umtEI/uXeWWBJdOIB3oxtuNXD0KLjAENwfRWbKwTwUo9v9xDQmiZLvy
         D/cQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=156P/sv9kl3W4lzShHBiZ6Cb3GP3B3vD0ubCKwHKThU=;
        b=CbsdugdRP/oOWIjW2OFkoL62JChHzcXX58Mer/otojfBfS9T1poGNsRniVloPh34yv
         HCB4A9ZU7oGMdc8+PMgomcpiZE7t9MLrT7elqk9FYMQmAPDN86HDm+LIojU8rzYsUl9l
         +Bwvb6xu/UNyY8aM+GHs0K/qpHsT1QqQ3YpGY5OQ9f25mA9NjECqnCycWNl79NKAupvZ
         x/z2WR69xavhTd0Ui3YYE/30s4+OtdQemkqTEjUMuvhcHZ1C+xWiv4Pyd6F7p5zzfNkQ
         BVdYHLU0S04JMbdin2ZYnYSE9aRHdLZ7w8jFazbyhkOylaZ/Qd89rolcKtvb6jtzlQ7x
         gFVw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k5sor56470518pjp.16.2019.07.24.10.16.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 10:16:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqwTVGKd3fvTa9LEjWhqIcTFIJiIjYs9TLAcnxEPWXeforQowmcaSvI2CRLGqprBSYmGXcozlQ==
X-Received: by 2002:a17:90a:8a91:: with SMTP id x17mr89006769pjn.95.1563988610289;
        Wed, 24 Jul 2019 10:16:50 -0700 (PDT)
Received: from 42.do-not-panic.com (42.do-not-panic.com. [157.230.128.187])
        by smtp.gmail.com with ESMTPSA id n140sm49450927pfd.132.2019.07.24.10.16.49
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 10:16:49 -0700 (PDT)
Received: by 42.do-not-panic.com (Postfix, from userid 1000)
	id ADB7B402A1; Wed, 24 Jul 2019 17:16:48 +0000 (UTC)
Date: Wed, 24 Jul 2019 17:16:48 +0000
From: Luis Chamberlain <mcgrof@kernel.org>
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
	Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH REBASE v4 12/14] mips: Replace arch specific way to
 determine 32bit task with generic version
Message-ID: <20190724171648.GW19023@42.do-not-panic.com>
References: <20190724055850.6232-1-alex@ghiti.fr>
 <20190724055850.6232-13-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724055850.6232-13-alex@ghiti.fr>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 01:58:48AM -0400, Alexandre Ghiti wrote:
> Mips uses TASK_IS_32BIT_ADDR to determine if a task is 32bit, but
> this define is mips specific and other arches do not have it: instead,
> use !IS_ENABLED(CONFIG_64BIT) || is_compat_task() condition.
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> ---
>  arch/mips/mm/mmap.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
> index faa5aa615389..d4eafbb82789 100644
> --- a/arch/mips/mm/mmap.c
> +++ b/arch/mips/mm/mmap.c
> @@ -17,6 +17,7 @@
>  #include <linux/sched/signal.h>
>  #include <linux/sched/mm.h>
>  #include <linux/sizes.h>
> +#include <linux/compat.h>
>  
>  unsigned long shm_align_mask = PAGE_SIZE - 1;	/* Sane caches */
>  EXPORT_SYMBOL(shm_align_mask);
> @@ -191,7 +192,7 @@ static inline unsigned long brk_rnd(void)
>  
>  	rnd = rnd << PAGE_SHIFT;
>  	/* 32MB for 32bit, 1GB for 64bit */
> -	if (TASK_IS_32BIT_ADDR)
> +	if (!IS_ENABLED(CONFIG_64BIT) || is_compat_task())
>  		rnd = rnd & SZ_32M;
>  	else
>  		rnd = rnd & SZ_1G;
> -- 

Since there are at least two users why not just create an inline for
this which describes what we are looking for and remove the comments?

  Luis

