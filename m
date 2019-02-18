Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B892FC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:27:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66A8B21738
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 09:27:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66A8B21738
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD1AD8E0005; Mon, 18 Feb 2019 04:27:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C80248E0002; Mon, 18 Feb 2019 04:27:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B96CD8E0005; Mon, 18 Feb 2019 04:27:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 78ACA8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 04:27:52 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id h70so13309229pfd.11
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 01:27:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=PZjiJcvfgxMPiW9sIqKOrKGdE27M0UIJb3+NvMR9UcY=;
        b=TR4FcyBcpitUiMGJ8XRuT2mk8ynYv0im0CFTbkujnMFkVG9ZC/dVl9RxAXQ1XHfEZS
         0jdsLkKgrRMmxsYwbLfKR548H7hRcBPDY0d+5uIzCZTMUlgSdgQlHEl1yXEJqotpylN4
         Xy6TEp2ukxJJtInA7tJ+kNg571hVgmPfVdvyDQZa5PJWpRkf84NlUk7PBu4+PNO47AJo
         J69YezTGUy7Kdaroqx2eCpvAZg4VGvc+fM/1ARds5DTnBQTxJNMat0v7VINQpJLuXTIs
         xdIZdg9CLOhm466IhxAgurP7M3ihjfEILelw4khx7iELDmSgQ7vpVYcWMhPDb3BB/eQK
         FK5w==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: AHQUAuaa0ckvAc/Nux0fK2maKy8lEpkuqeWFX0chIS+FkCMOyPhfxyWg
	oYAaiO8pi/bV0XePDf3Rx26pjF/lvNRzYL9TMB2ojbg3L0MwrtB2Km8elqIRS8Qm3mNlT5nNvyg
	Kg/Z7swTzs4c+nTbIxvplJZxSoDIxypuDGwNvWf4vvPvNKQd7uhLqL5CG5hUOP+I=
X-Received: by 2002:aa7:8d53:: with SMTP id s19mr3473988pfe.16.1550482072094;
        Mon, 18 Feb 2019 01:27:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia+YenqNHa/zD7d++UTsium63YRMLfgNG8i2XB4IAx9kZCarsPGaWPYE5CYaZKhsTLAIwk4
X-Received: by 2002:aa7:8d53:: with SMTP id s19mr3473920pfe.16.1550482070940;
        Mon, 18 Feb 2019 01:27:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550482070; cv=none;
        d=google.com; s=arc-20160816;
        b=HjmOeCotAxgMvH7VEuERmk3Tt2D+jz/AYSfgoNMXSkbrXub5ym9UFKYtFqzmadhG+b
         pL860qNIJMvZWXvig4jPQGSY5DkZPnt9NCiytq5003OIdhdAT9uxa/GSYiFrwjljqQ3I
         MQPxIbpeRVShC2tlh9FVUBWlGgiNJdssvtwEMyZMwoDc0IXgUxzolJF8I7A75d58RHYk
         skVQfRWLWPcAkd0q6WrU8JIrEAZZk67xZHuu0U0qojTT0HwDqWLYpgq0lWeB5MuzWR5B
         q9zcx9nESjdquJ9UMIp+49pzcn2VyTcvxRg8vQz+CFKbmEgkWanvusGZbl1yA9ynrRY2
         GTrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=PZjiJcvfgxMPiW9sIqKOrKGdE27M0UIJb3+NvMR9UcY=;
        b=lGj+9Q5LsD9hfw7aNQ5AfsQi6TSuVORXBfM2kCoUMO2oF18NL4X/ZW9dWsxL3lshAq
         0HryZT+NzTvcQvR6HDcZqTCLr9AZzGpbYehviF+k2SL1KJz1vVzKI5NhbvwiVyug6W8I
         WoiZBBQ4yUXekNd2vpG3Qp6lsaWggmluGLO68LelHgf9WussQ5kt27P10yd6/VKvxQ0q
         Cm1JzUVL+Q7JayUmwV1+w/DCus9rwNJBl+L52Q6YbkZzk7xqYkVToJI+PVK92C/iJFie
         d3a0lPZr9PBBD2O3rcG5Qu9YL2T6msXwFcYAQUzToWZ31lGQxDMygSo/fwK+aQl9jyOd
         ThrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id h16si12423794pgh.283.2019.02.18.01.27.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 01:27:50 -0800 (PST)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by ozlabs.org (Postfix) with ESMTPSA id 442z6q1sf4z9s7h;
	Mon, 18 Feb 2019 20:27:47 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Christophe Leroy <christophe.leroy@c-s.fr>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Nicholas Piggin <npiggin@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Subject: Re: [PATCH v5 3/3] powerpc/32: Add KASAN support
In-Reply-To: <3429fe33b68206ecc2a725a740937bbaef2d1ac8.1549935251.git.christophe.leroy@c-s.fr>
References: <cover.1549935247.git.christophe.leroy@c-s.fr> <3429fe33b68206ecc2a725a740937bbaef2d1ac8.1549935251.git.christophe.leroy@c-s.fr>
Date: Mon, 18 Feb 2019 20:27:47 +1100
Message-ID: <87a7itqwdo.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Christophe Leroy <christophe.leroy@c-s.fr> writes:

> diff --git a/arch/powerpc/include/asm/ppc_asm.h b/arch/powerpc/include/asm/ppc_asm.h
> index e0637730a8e7..dba2c1038363 100644
> --- a/arch/powerpc/include/asm/ppc_asm.h
> +++ b/arch/powerpc/include/asm/ppc_asm.h
> @@ -251,6 +251,10 @@ GLUE(.,name):
>  
>  #define _GLOBAL_TOC(name) _GLOBAL(name)
>  
> +#define KASAN_OVERRIDE(x, y) \
> +	.weak x;	     \
> +	.set x, y
> +

Can you add a comment describing what that does and why?

> diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
> index 879b36602748..fc4c42262694 100644
> --- a/arch/powerpc/kernel/Makefile
> +++ b/arch/powerpc/kernel/Makefile
> @@ -16,8 +16,9 @@ CFLAGS_prom_init.o      += -fPIC
>  CFLAGS_btext.o		+= -fPIC
>  endif
>  
> -CFLAGS_cputable.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
> -CFLAGS_prom_init.o += $(DISABLE_LATENT_ENTROPY_PLUGIN)
> +CFLAGS_early_32.o += -DDISABLE_BRANCH_PROFILING
> +CFLAGS_cputable.o += $(DISABLE_LATENT_ENTROPY_PLUGIN) -DDISABLE_BRANCH_PROFILING
> +CFLAGS_prom_init.o += $(DISABLE_LATENT_ENTROPY_PLUGIN) -DDISABLE_BRANCH_PROFILING

Why do we need to disable branch profiling now?

I'd probably be happier if all the CFLAGS changes were done in a leadup
patch to make them more obvious.

> diff --git a/arch/powerpc/kernel/prom_init_check.sh b/arch/powerpc/kernel/prom_init_check.sh
> index 667df97d2595..da6bb16e0876 100644
> --- a/arch/powerpc/kernel/prom_init_check.sh
> +++ b/arch/powerpc/kernel/prom_init_check.sh
> @@ -16,8 +16,16 @@
>  # If you really need to reference something from prom_init.o add
>  # it to the list below:
>  
> +grep CONFIG_KASAN=y .config >/dev/null

Just to be safe "^CONFIG_KASAN=y$" ?

> +if [ $? -eq 0 ]
> +then
> +	MEMFCT="__memcpy __memset"
> +else
> +	MEMFCT="memcpy memset"
> +fi

MEM_FUNCS ?

> diff --git a/arch/powerpc/lib/Makefile b/arch/powerpc/lib/Makefile
> index 3bf9fc6fd36c..ce8d4a9f810a 100644
> --- a/arch/powerpc/lib/Makefile
> +++ b/arch/powerpc/lib/Makefile
> @@ -8,6 +8,14 @@ ccflags-$(CONFIG_PPC64)	:= $(NO_MINIMAL_TOC)
>  CFLAGS_REMOVE_code-patching.o = $(CC_FLAGS_FTRACE)
>  CFLAGS_REMOVE_feature-fixups.o = $(CC_FLAGS_FTRACE)
>  
> +KASAN_SANITIZE_code-patching.o := n
> +KASAN_SANITIZE_feature-fixups.o := n
> +
> +ifdef CONFIG_KASAN
> +CFLAGS_code-patching.o += -DDISABLE_BRANCH_PROFILING
> +CFLAGS_feature-fixups.o += -DDISABLE_BRANCH_PROFILING
> +endif

There's that branch profiling again, though here it's only if KASAN is enabled.

> diff --git a/arch/powerpc/mm/kasan_init.c b/arch/powerpc/mm/kasan_init.c
> new file mode 100644
> index 000000000000..bd8e0a263e12
> --- /dev/null
> +++ b/arch/powerpc/mm/kasan_init.c
> @@ -0,0 +1,114 @@
> +// SPDX-License-Identifier: GPL-2.0
> +
> +#define DISABLE_BRANCH_PROFILING
> +
> +#include <linux/kasan.h>
> +#include <linux/printk.h>
> +#include <linux/memblock.h>
> +#include <linux/sched/task.h>
> +#include <asm/pgalloc.h>
> +
> +void __init kasan_early_init(void)
> +{
> +	unsigned long addr = KASAN_SHADOW_START;
> +	unsigned long end = KASAN_SHADOW_END;
> +	unsigned long next;
> +	pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(addr), addr), addr);

Can none of those fail?


cheers

