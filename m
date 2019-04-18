Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CB53C10F0B
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:32:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2C9E21479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:32:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="eKENM7Vl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2C9E21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CB3F6B0005; Thu, 18 Apr 2019 01:32:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77BED6B0008; Thu, 18 Apr 2019 01:32:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66B316B000A; Thu, 18 Apr 2019 01:32:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 45B936B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 01:32:14 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id j193so189675vsd.2
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:32:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=I49wvlYq7D5JlBzIeYIfPLcNWvP+zL3hNSqD7FZ7LkY=;
        b=Zdl4Wx+jJIUluEOBFWA+YZFuqQ6sXWp9KVHKvFxJjanL9PKn+GGlO16I2F17xAAgs6
         JwW6H1q0wuNEg3kQc5p6XhM7WlM/Q4fgpl74vPaN2MFv38QY2ZUGi7lH437lSBk2H41k
         /UTqQCYjdmQ1omviYWgRrtnjGp6QqCgNZr9ygB0tTZutVVrhKaaQcSRjhZ5/bk2UuJrD
         NedopClIeS4DfyBFOFqO8glmd+cMcukI+8ZEC64Tbc01dm5i7xQ8YncB94MFdGRpTIzO
         kVy1zP243Jled/6r1gg/V7FEPb3JUhNge2qttkcYzvILCkZmE4n+mW7YT8OGV7gJza3Y
         geZw==
X-Gm-Message-State: APjAAAVHuRkThpbFCfSgUMGLHtTnPP4OxCF0ZYPKaqf69OWTsP5dhpcd
	gNxZzee/e4lkT8GdPZOVRqTjvkNsvOVejjW5xF7OQe+k8Yja/gUzI1JC5EbSnLi5h2JlGWBdfTe
	om5PyvOoOSAVHKAOi9p4h0NsBozC4hYZKNC346cPw7EgZ7h8dwjLw+W+5gHW2yn+vUA==
X-Received: by 2002:a9f:352a:: with SMTP id o39mr46092140uao.78.1555565534041;
        Wed, 17 Apr 2019 22:32:14 -0700 (PDT)
X-Received: by 2002:a9f:352a:: with SMTP id o39mr46092118uao.78.1555565533351;
        Wed, 17 Apr 2019 22:32:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555565533; cv=none;
        d=google.com; s=arc-20160816;
        b=IMJ8lYq9tXYZOWNyI8DbB74XBhfTnn07a+2DmRYHw+J3tjj4xnjACaPPr2RCXclG4V
         nle4POsoE75kKci8N/WN9WURT1FfLMWNT91tCvIC32tcLNAeHSuqs/gGmJtgOdwTz6BH
         ycHxx2gkRhzUKhuOpEJocNOdwM1lfG2/JgegijAm1zTdaJRrlyDSPn1q0JTee4+hyMEi
         lrdO4mGvWeDBn53JSZOxicxFoLEr+wO697dZ82g+Ivb4WSmImwEp2w9jSxRdwi0v+sQr
         0pZbRljl7GDk2a0LUh7AuVZuVquwOwIT7mQlBznbJRkjO4d9yLvQIYUfsAqqAc++NwXG
         qGyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=I49wvlYq7D5JlBzIeYIfPLcNWvP+zL3hNSqD7FZ7LkY=;
        b=ud2BqEMQ/VgrQW0cyW8oxmztVnbiFIvfI8WNIjnbruajyY1l+PE3s7Ry+pd0XOwP02
         Hk9H/XK2jM7TO8/fHtTQn+EpSmxxI6RkVQMkjSbcICaasL9BzmHIN2vZCoKZrg4U/nJ5
         IhpKDgtltgDYO0p07XfFtA2Sl8f8OlizJvEXd5Tw2sZi3eAmkBBTH4IhZ2diBuBuC6sV
         6xYXJh48lsYyfP9bOR84qw4573B4tRLAGCm4J6iIdRgojsANOldyDByUBwVjzMH55It3
         h2oAB/4T+Y8SlxdJZ3/jDJHEocgHqOFRHA516z+NWXUxZZK1dVEZH2AE/acx9fEY5yWE
         XXLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=eKENM7Vl;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 82sor309534vkn.1.2019.04.17.22.32.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 22:32:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=eKENM7Vl;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=I49wvlYq7D5JlBzIeYIfPLcNWvP+zL3hNSqD7FZ7LkY=;
        b=eKENM7VlYogZiu9LKw1HvlthciY0efM2NRwfvhdnWH5UYz7IY9RnPN4yev4Q+SyM9W
         YdiBLhyiVJeHQ9+caxTPQbD0pWn+V0WnnHXoprAgGsJToXR/dAfi6b1L2J3wzGcPrtzu
         FLBCSBvonUpQIBIMq//yfXcrvRxsfl6ta/QN4=
X-Google-Smtp-Source: APXvYqyJkx1z0uAz6/1GOt3LdwKYlmXDbdIe94Y4yUrZsxrULT7SssmGiEvO+/v+YPrgx9DtwHsWIg==
X-Received: by 2002:a1f:e542:: with SMTP id c63mr50538887vkh.3.1555565532214;
        Wed, 17 Apr 2019 22:32:12 -0700 (PDT)
Received: from mail-vk1-f179.google.com (mail-vk1-f179.google.com. [209.85.221.179])
        by smtp.gmail.com with ESMTPSA id w79sm310594vkw.51.2019.04.17.22.32.10
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 22:32:11 -0700 (PDT)
Received: by mail-vk1-f179.google.com with SMTP id h71so215789vkf.5
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:32:10 -0700 (PDT)
X-Received: by 2002:a1f:3c83:: with SMTP id j125mr2514890vka.92.1555565530282;
 Wed, 17 Apr 2019 22:32:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190417052247.17809-1-alex@ghiti.fr> <20190417052247.17809-12-alex@ghiti.fr>
In-Reply-To: <20190417052247.17809-12-alex@ghiti.fr>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 18 Apr 2019 00:31:58 -0500
X-Gmail-Original-Message-ID: <CAGXu5jJcQzDQGy907H0WXu-q1sPQaXgjuFbHHW60ajUuksZb3A@mail.gmail.com>
Message-ID: <CAGXu5jJcQzDQGy907H0WXu-q1sPQaXgjuFbHHW60ajUuksZb3A@mail.gmail.com>
Subject: Re: [PATCH v3 11/11] riscv: Make mmap allocation top-down by default
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, 
	Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Ralf Baechle <ralf@linux-mips.org>, 
	Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, 
	Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Luis Chamberlain <mcgrof@kernel.org>, 
	Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-mips@vger.kernel.org, 
	linux-riscv@lists.infradead.org, 
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 12:34 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>
> In order to avoid wasting user address space by using bottom-up mmap
> allocation scheme, prefer top-down scheme when possible.
>
> Before:
> root@qemuriscv64:~# cat /proc/self/maps
> 00010000-00016000 r-xp 00000000 fe:00 6389       /bin/cat.coreutils
> 00016000-00017000 r--p 00005000 fe:00 6389       /bin/cat.coreutils
> 00017000-00018000 rw-p 00006000 fe:00 6389       /bin/cat.coreutils
> 00018000-00039000 rw-p 00000000 00:00 0          [heap]
> 1555556000-155556d000 r-xp 00000000 fe:00 7193   /lib/ld-2.28.so
> 155556d000-155556e000 r--p 00016000 fe:00 7193   /lib/ld-2.28.so
> 155556e000-155556f000 rw-p 00017000 fe:00 7193   /lib/ld-2.28.so
> 155556f000-1555570000 rw-p 00000000 00:00 0
> 1555570000-1555572000 r-xp 00000000 00:00 0      [vdso]
> 1555574000-1555576000 rw-p 00000000 00:00 0
> 1555576000-1555674000 r-xp 00000000 fe:00 7187   /lib/libc-2.28.so
> 1555674000-1555678000 r--p 000fd000 fe:00 7187   /lib/libc-2.28.so
> 1555678000-155567a000 rw-p 00101000 fe:00 7187   /lib/libc-2.28.so
> 155567a000-15556a0000 rw-p 00000000 00:00 0
> 3fffb90000-3fffbb1000 rw-p 00000000 00:00 0      [stack]
>
> After:
> root@qemuriscv64:~# cat /proc/self/maps
> 00010000-00016000 r-xp 00000000 fe:00 6389       /bin/cat.coreutils
> 00016000-00017000 r--p 00005000 fe:00 6389       /bin/cat.coreutils
> 00017000-00018000 rw-p 00006000 fe:00 6389       /bin/cat.coreutils
> 00018000-00039000 rw-p 00000000 00:00 0          [heap]
> 3ff7eb6000-3ff7ed8000 rw-p 00000000 00:00 0
> 3ff7ed8000-3ff7fd6000 r-xp 00000000 fe:00 7187   /lib/libc-2.28.so
> 3ff7fd6000-3ff7fda000 r--p 000fd000 fe:00 7187   /lib/libc-2.28.so
> 3ff7fda000-3ff7fdc000 rw-p 00101000 fe:00 7187   /lib/libc-2.28.so
> 3ff7fdc000-3ff7fe2000 rw-p 00000000 00:00 0
> 3ff7fe4000-3ff7fe6000 r-xp 00000000 00:00 0      [vdso]
> 3ff7fe6000-3ff7ffd000 r-xp 00000000 fe:00 7193   /lib/ld-2.28.so
> 3ff7ffd000-3ff7ffe000 r--p 00016000 fe:00 7193   /lib/ld-2.28.so
> 3ff7ffe000-3ff7fff000 rw-p 00017000 fe:00 7193   /lib/ld-2.28.so
> 3ff7fff000-3ff8000000 rw-p 00000000 00:00 0
> 3fff888000-3fff8a9000 rw-p 00000000 00:00 0      [stack]
>
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  arch/riscv/Kconfig | 11 +++++++++++
>  1 file changed, 11 insertions(+)
>
> diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
> index eb56c82d8aa1..f5897e0dbc1c 100644
> --- a/arch/riscv/Kconfig
> +++ b/arch/riscv/Kconfig
> @@ -49,6 +49,17 @@ config RISCV
>         select GENERIC_IRQ_MULTI_HANDLER
>         select ARCH_HAS_PTE_SPECIAL
>         select HAVE_EBPF_JIT if 64BIT
> +       select ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT if MMU
> +       select HAVE_ARCH_MMAP_RND_BITS
> +
> +config ARCH_MMAP_RND_BITS_MIN
> +       default 18
> +
> +# max bits determined by the following formula:
> +#  VA_BITS - PAGE_SHIFT - 3
> +config ARCH_MMAP_RND_BITS_MAX
> +       default 33 if 64BIT # SV48 based
> +       default 18
>
>  config MMU
>         def_bool y
> --
> 2.20.1
>


-- 
Kees Cook

