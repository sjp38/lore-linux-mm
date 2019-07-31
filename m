Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A10C6C32753
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 22:40:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5229A214DA
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 22:40:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=sifive.com header.i=@sifive.com header.b="QvM5gURg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5229A214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sifive.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DDE078E0005; Wed, 31 Jul 2019 18:40:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D67308E0001; Wed, 31 Jul 2019 18:40:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C07A48E0005; Wed, 31 Jul 2019 18:40:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id A22EA8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 18:40:38 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id p12so76841938iog.19
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 15:40:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=egRpxJBa9oK7OchDbNGXXbbAvoOMUOmZrCvbt5gO8zI=;
        b=XzGRYfqzHHjDsC4NBMEsxj884Fv1DXDmVqCBRv6rxYIRBc3etEH+qnN4Drd6Zrnbs8
         w4TBXJGzg15L+2mmvODP+szNoDNbkLHlRA+xyUvZo0p0vG2Y7dZjjnknSu4dhVhi/zYw
         IKw8R3qGvEyxEZZGdkhqR+Pn34Q9y4k4DjcjRSDbo29BnRGCu/JBaTKHFK/XrdIVMYqU
         UKMRLDBrRlJ/B8M4SWNoiCErjnJerZco+gqIlLY98rb+aAkDjSWIMNxnufF/oYihO80I
         3bX2O4qoeTk5CLhVOWPtQrCGqIPZNzQ8SFVKwNDR6/E/7YYdeanDjhixoprNxR4tKuyh
         QZRg==
X-Gm-Message-State: APjAAAU5a8WTwGpnW6FJQA9h+OwpSjV54RLEwOV0MXAdesuCQOkEWGSm
	D6b3qLLpyl13aJ2J2Y9YAGYnlyty5lgU5RrdHbhEyrSYCJOy0zw+UKwdQI0ss66HFt7RqihRzul
	rdWoxCak8vztq6stBka4n6t9Esw8yIXszEkWFR6OGGQgBq5EJjMfWhhMg08FHyMoSrQ==
X-Received: by 2002:a02:8663:: with SMTP id e90mr126575166jai.98.1564612838337;
        Wed, 31 Jul 2019 15:40:38 -0700 (PDT)
X-Received: by 2002:a02:8663:: with SMTP id e90mr126575049jai.98.1564612837046;
        Wed, 31 Jul 2019 15:40:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564612837; cv=none;
        d=google.com; s=arc-20160816;
        b=J0dHiXatDhJEWMTVvG6Sl4eglqVzPw2p5vR/eM4IebNBVGlUWI9b5cXuYsgeo28jAc
         gW5UwaLEIoBZp4Kbi20OqRnHnVgBj3PB6w86fFW+vIHUjdvwGAwVVHL0SMWNk1q+RkdB
         Wj9tPySKuXkn3n0UMPGzcrf4B1DzFOKOkkM2mcE3GgF/KdigeXBclFYoyXonfiXkcFPq
         VZnntMkp8WzO5RiZNaRXPoqNg7JpXcP3GgRwnsJk7s5PXyTnJIV7+MyDJih/eEq41rAe
         ZhCr3l/HwMm6VV63S22BSvuownlKHFzsbWZSQ7LckhAzxqo+L3CRnu9UAh3CJAk0lWRC
         whLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=egRpxJBa9oK7OchDbNGXXbbAvoOMUOmZrCvbt5gO8zI=;
        b=nUXVJIQRSgy/zaCzqd9L4y4j+77irWItwrKwoW74McRcbR6+rtgD7afKxjZxl1FAc7
         92LC8ObAzNYTUiS1yiat7RJv4jm/haw7bpt7dtHoPLIFvxP3FyLnXtrz7sKvBwUJ7Rqw
         1vLRW1REXOScvq+on9kaHLhDtooajHKj8M+9GJJRK1/xYu4chv5VsThPwRNuDgFL2gA6
         jZ4nHA+dtBL+Z3fWBh4nszq8hXB+Ex1yovz86GlAu9cd8BDuq6vVAz16Bmg3EZoAnZ+K
         SziKbKo7vSPFgNRzUYHBi76wHhTJbDV630FF3Wx/CgAYcIFc2sP7P/2kjHJPx4fjyYEX
         u10w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sifive.com header.s=google header.b=QvM5gURg;
       spf=pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=paul.walmsley@sifive.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e18sor29846312iot.134.2019.07.31.15.40.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 15:40:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sifive.com header.s=google header.b=QvM5gURg;
       spf=pass (google.com: domain of paul.walmsley@sifive.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=paul.walmsley@sifive.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=sifive.com; s=google;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=egRpxJBa9oK7OchDbNGXXbbAvoOMUOmZrCvbt5gO8zI=;
        b=QvM5gURgmBtYYb5ewAA6jGZY4ljdEgJDQkLHHqVikVD66zPlOj6SuWDfLaZFvi4LUF
         FQdJPeaP2xBSfu5VhEpovno9nnLQOcyhglyYB0pRP4JDwGr0eAqZbpbagc3uUt7s9USv
         Mpj2IzZzl+bJl5mUIlw221ntI2T0Gd3i5626L0lZpF3NQf2YbT9pIlRRSe+aFdedyfsu
         M2J7DASUn+cy4TT7B8G64SBFNLwKRalGaUFXLhzgYJLwUMSwiCHsd5R54xYkxPti/wZi
         C3bY3XL25Z5iZQrpq93tCxIGxwS4lBIYfZ/mctkv1io4wB2KYJZz7fo2JWv6xUDgj8Db
         lqfQ==
X-Google-Smtp-Source: APXvYqwrG00LBhTpDLsR7IvSvLbPRzUfGNUjyuov0y6Pr5JYCZwHs6hWm99dQiGbrjWMUvsaR2nw9Q==
X-Received: by 2002:a6b:f406:: with SMTP id i6mr44093290iog.110.1564612836637;
        Wed, 31 Jul 2019 15:40:36 -0700 (PDT)
Received: from localhost ([170.10.65.222])
        by smtp.gmail.com with ESMTPSA id a7sm56245658iok.19.2019.07.31.15.40.35
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 15:40:35 -0700 (PDT)
Date: Wed, 31 Jul 2019 15:40:35 -0700 (PDT)
From: Paul Walmsley <paul.walmsley@sifive.com>
X-X-Sender: paulw@viisi.sifive.com
To: Alexandre Ghiti <alex@ghiti.fr>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Albert Ou <aou@eecs.berkeley.edu>, Kees Cook <keescook@chromium.org>, 
    Catalin Marinas <catalin.marinas@arm.com>, 
    Palmer Dabbelt <palmer@sifive.com>, Will Deacon <will.deacon@arm.com>, 
    Russell King <linux@armlinux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    Luis Chamberlain <mcgrof@kernel.org>, Paul Burton <paul.burton@mips.com>, 
    James Hogan <jhogan@kernel.org>, linux-fsdevel@vger.kernel.org, 
    linux-riscv@lists.infradead.org, linux-mips@vger.kernel.org, 
    Christoph Hellwig <hch@lst.de>, linux-arm-kernel@lists.infradead.org, 
    Alexander Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH v5 14/14] riscv: Make mmap allocation top-down by
 default
In-Reply-To: <20190730055113.23635-15-alex@ghiti.fr>
Message-ID: <alpine.DEB.2.21.9999.1907311538460.22372@viisi.sifive.com>
References: <20190730055113.23635-1-alex@ghiti.fr> <20190730055113.23635-15-alex@ghiti.fr>
User-Agent: Alpine 2.21.9999 (DEB 301 2018-08-15)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jul 2019, Alexandre Ghiti wrote:

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
> 2de81000-2dea2000 rw-p 00000000 00:00 0          [heap]
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
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>

Acked-by: Paul Walmsley <paul.walmsley@sifive.com> # for arch/riscv

As Alex notes, this patch depends on "[PATCH] riscv: kbuild: add virtual 
memory system selection":

https://lore.kernel.org/linux-riscv/alpine.DEB.2.21.9999.1907301218560.3486@viisi.sifive.com/T/#t

which will likely go up during v5.3-rc.


- Paul

