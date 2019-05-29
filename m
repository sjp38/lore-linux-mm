Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E52C0C28CC1
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 20:12:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADB732411E
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 20:12:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="XrzLaKA5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADB732411E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56BA96B026D; Wed, 29 May 2019 16:12:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51C826B026E; Wed, 29 May 2019 16:12:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40ADC6B026F; Wed, 29 May 2019 16:12:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 097E46B026D
	for <linux-mm@kvack.org>; Wed, 29 May 2019 16:12:28 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 93so2291105plf.14
        for <linux-mm@kvack.org>; Wed, 29 May 2019 13:12:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=0aft1pCaWtRYtnkCVrHz1gsURga5CiN4SjNK2Yoiqfs=;
        b=pHcITjgC1jd5EcgS6TJzGUL1Uy61jugaVlGM+xfSboGLhNxPA4zgq7XqCA0myOcfKB
         kWqY7hWuXUeCBSbutAzH/d8BoSrO+/kjFqViUcbgcHaMUNG+AQqm9EinEl9v5Ekpd4mk
         TJSX6PAsNtQAR3os1IZ18kz1N7Pe3P3NE7EtMp5eCkKvt07t5jl5oD9FwakZdxCzgBqU
         QHA8uH4H8v/f0C4kMfo8LDtz559ubn1qPWRjM/Bv+XSff2JuXfk+XsovK6MypCg8BZkm
         l21S6GAcyc2PesrNuXDJbzl6ZMYSxOlNByVD7FTCeSnuRX3TeiW8lYGjsztN+zXM6QkC
         Fiqw==
X-Gm-Message-State: APjAAAVmFFdg6mdgvT6leSCmaOqgFXqMJxKp0OCEKUv3tiOs8QRSG/Mb
	zV6Jc9ZmASAhKPdHrplbQ3XSyiMgySUDLwA+ogADGbQTrXmUGI+cr7XsE4vCJNdxOw6s93qO3R7
	YJCZwPLtLqugJ0amkT3z6KnV3Sf4orBFPHq42k5izeinc3H/roRKk4I0BwolG5EGOzA==
X-Received: by 2002:aa7:8e46:: with SMTP id d6mr123647042pfr.91.1559160747668;
        Wed, 29 May 2019 13:12:27 -0700 (PDT)
X-Received: by 2002:aa7:8e46:: with SMTP id d6mr123646994pfr.91.1559160747010;
        Wed, 29 May 2019 13:12:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559160747; cv=none;
        d=google.com; s=arc-20160816;
        b=EQmAP6KhYkBChrbuanpiEushK701JfxR9e+7x4D/vxAgS9W5ewXRiAck+9wJPbjP64
         viWgNbpATTW6Zpk3oQfvjFn+mnit272Q8GOyrpDhhPuxzGYgsz2nEfk2IewQHXIL6iGD
         MFWyE2FETHC2JPSQYxdCwLoMTMEJDCBy9GO+FPXdbjidlomoK5jstmPKOt0C35iWZPh2
         iFoziqqKz3N8+9qQlV5fjpxGMNNq93jWs8klFEcupsFoG9a8AqJfnCcbjA9mw/FtORh7
         bZ5iebb5fQmClx03kvTjV19loS4CLFUsBqNloMVxc4hD185a8asQ9alqx0KxZ5u+CrWF
         tVJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=0aft1pCaWtRYtnkCVrHz1gsURga5CiN4SjNK2Yoiqfs=;
        b=tCWYGRsAvzQ+biVkXp8ZGc286G6dBySNZ63ApM3qwMIVSs3SCj5wD15q59bDC+yzeY
         Tx8b+aOixga1Yv7W7S3cyYIpOYlWTEbW9IMsnDxa92+GeMY52hINTciF5rLDy/WF3lkt
         k5wplqOd0N2AjSFMIV9hydaG8n0zXHXWa2cBN4YuZx3McNGBAhoFEWsM5bRr97c2jRgb
         uBixLsJ1N6qO1pmLawb6ZZafGU2K8FoHVJzuo88ucMqJfOusihH8jjfCry4m5efES8L5
         5kBBRxNyxYeit28MFYvtDngYt0k1CUY+DNwUhMCnre6ItiWExM2pDyavVZPA25MAtN2W
         QkCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=XrzLaKA5;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d12sor738176pfh.21.2019.05.29.13.12.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 13:12:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=XrzLaKA5;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=0aft1pCaWtRYtnkCVrHz1gsURga5CiN4SjNK2Yoiqfs=;
        b=XrzLaKA5MBHx0xlQKOcw3TIc85QvkhgJkO2JlDacDh+XCgUjABQyymyiZ/G560P5jJ
         HkAij558NkgyQQddecvDdQLSq5ZIicJMj+V7FdjS/5Qp/CTG9jIYFMaRFN3A7NFwUjgi
         FNTYdjrs48vkuDxAgacSirUU/cz2L2J9fobnY=
X-Google-Smtp-Source: APXvYqwc7/sGYBIou0XJOLY+/Ol3XK8SIbVohsGySQ6NBMh2dCNE0NA9cvRsEXWPqWrlHnSoWF5LlQ==
X-Received: by 2002:aa7:8d81:: with SMTP id i1mr126561827pfr.244.1559160746780;
        Wed, 29 May 2019 13:12:26 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id d9sm220941pgj.34.2019.05.29.13.12.25
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 29 May 2019 13:12:25 -0700 (PDT)
Date: Wed, 29 May 2019 13:12:25 -0700
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
Subject: Re: [PATCH v4 12/14] mips: Replace arch specific way to determine
 32bit task with generic version
Message-ID: <201905291312.7B8EBE955@keescook>
References: <20190526134746.9315-1-alex@ghiti.fr>
 <20190526134746.9315-13-alex@ghiti.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190526134746.9315-13-alex@ghiti.fr>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000010, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 26, 2019 at 09:47:44AM -0400, Alexandre Ghiti wrote:
> Mips uses TASK_IS_32BIT_ADDR to determine if a task is 32bit, but
> this define is mips specific and other arches do not have it: instead,
> use !IS_ENABLED(CONFIG_64BIT) || is_compat_task() condition.
> 
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  arch/mips/mm/mmap.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
> index c052565b76fb..900670ea8531 100644
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
> 2.20.1
> 

-- 
Kees Cook

