Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5556DC04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 19:08:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 095552053B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 19:08:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="CFwO3s1B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 095552053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69F286B0003; Wed,  8 May 2019 15:08:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64FC76B0008; Wed,  8 May 2019 15:08:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53E466B000A; Wed,  8 May 2019 15:08:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 335586B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 15:08:41 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id u7so9315961vke.0
        for <linux-mm@kvack.org>; Wed, 08 May 2019 12:08:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=9qI7nQdd3bNYCa2qF4UH/4IqrrO0K8+DgZr0J5nYZ54=;
        b=Vbx4egrvURzl4+8qJV/MZN70Blk23d8qXCwRYx4A+fS6Pi6I8syif3Mw/0iFbU1r2L
         NRrskxa8nd5sb62hbHt5eu86NoFdg4Guasth1o5d3EjzoHsVyrJ11MabGyEMEgF0I7nV
         yyzWiLyjgkyDcVYE2A7XRqyvoWQe/VoqqPJ3iXUGqKxKS8qNJCBDhzjPrgFia2XiIH1y
         7Fptrq0cX/fMWiO2mCQKpXO9/gVp84Zlh27N0mv0SNqtWhwdictb8kQR14UvyBxbSyfM
         mHmFkoretDJFCbcNomM29IFRUBnIQ7oZOSaqKeTi2FLLm7G2WHpAGN7tMDFJUz6TjRMl
         y/hA==
X-Gm-Message-State: APjAAAXfGzHPnKr8h/wkmmS9kp1bJpJqD5EaXhlSfyI3YUqJfXtz0+Jn
	+HWXGN5nz1ZACQNX8WzG1uKl4gCgWHaPSsVArfPrRcptOlXPjzBacE7nmPKACz13DAc03ha1eHf
	AlmTLLOHXEJig+EjSkZ/xRPig4EQybcTjQ1OQAvfDp0guomQT+o68O3GdEPBm7P/BgA==
X-Received: by 2002:a67:8e03:: with SMTP id q3mr21270499vsd.152.1557342520927;
        Wed, 08 May 2019 12:08:40 -0700 (PDT)
X-Received: by 2002:a67:8e03:: with SMTP id q3mr21270441vsd.152.1557342519940;
        Wed, 08 May 2019 12:08:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557342519; cv=none;
        d=google.com; s=arc-20160816;
        b=QkpKDyBU8JbVh6W3YVKsNoj1oiwMPcnFhQn9KBnBBUC3zDvkwQ4rJPHWwyaGRCeGaJ
         7wd9vgaqlwQo2T5qn9Fnt+PSKhIHcDQykCTWdXcqwa+mH6HsGW006Wpu6kyrexg+NC5F
         kZy0EKiPNulNQV8+k1VB0FJ8HQBgKQPn6hDAKnN6I6FVO9y1kSaPgHbHSADR9F7+mppx
         tZY9XEip/WmisriJMyBtPv+9SzQzcmwQRYJk4vD1IbC1/klP+DA+HZ0JhgyPtUzzfw4a
         dG4qz1vt8yKcdwdQzJ1PmUD9LrzDg5TAJJ2iAy3qIuSb8eOqYhTyT25hNfJIEfAAQ7CH
         AM0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=9qI7nQdd3bNYCa2qF4UH/4IqrrO0K8+DgZr0J5nYZ54=;
        b=ZntCy4NrsV2Qsig4hBQpuUbor4YxkwN6ygpoKiPx2swRmyX8mML2AiZ0JfWh4WImZe
         /xiHtdYcz9dZXPcq915dikQCrlEkOvv1mpg8OMtrc7fEMd/tMp9zTxCNDLH2+19NY5jG
         gcBM8UfEOYyKdb6mWkXcxr8YntZyRga16LsChbR1Pd5PjOHnrcF2E6hVSI+6UZzkQR7Y
         Ix9jNKL3sEif3ApEm3q5TBRlJlJzCWuPMhPVHTvU5tsLT5eHbJyEDizs6NTvk1x/Nqjs
         sNtHrYcdg8MQ4yJL5LqpmpSVy+zwUFtg+K/c/s++QaziL/y5e6yqrUMF3hjgk+Znzfns
         KKog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=CFwO3s1B;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v14sor8618663uar.1.2019.05.08.12.08.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 May 2019 12:08:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=CFwO3s1B;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9qI7nQdd3bNYCa2qF4UH/4IqrrO0K8+DgZr0J5nYZ54=;
        b=CFwO3s1B4b6gP84OVgCdY0F8XJ7Y2NgQn0S0V9cEflkmltxNycTIalnzb+5p+pWV3J
         45bh/SDBPLW0AQ3qJzdK4EptfEdJuqhNSAwQcT9ShwAhyA9io4vJn45B57823OdiUHhi
         v9viJPqnmNK011qboLI/zS/IJ7LA/BE7RzBm0=
X-Google-Smtp-Source: APXvYqzTFsShZ3n6zElo8a7IS3HKYRkakPW0DN5KXNjUNzt4QiQVaZqRcjtdkEI/rBId0SvnltoeOA==
X-Received: by 2002:ab0:2692:: with SMTP id t18mr21265913uao.106.1557342519287;
        Wed, 08 May 2019 12:08:39 -0700 (PDT)
Received: from mail-vk1-f177.google.com (mail-vk1-f177.google.com. [209.85.221.177])
        by smtp.gmail.com with ESMTPSA id e76sm5649298vke.48.2019.05.08.12.08.35
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 12:08:35 -0700 (PDT)
Received: by mail-vk1-f177.google.com with SMTP id r195so5245188vke.0
        for <linux-mm@kvack.org>; Wed, 08 May 2019 12:08:35 -0700 (PDT)
X-Received: by 2002:a1f:3804:: with SMTP id f4mr5366867vka.4.1557342514950;
 Wed, 08 May 2019 12:08:34 -0700 (PDT)
MIME-Version: 1.0
References: <20190508153736.256401-1-glider@google.com> <20190508153736.256401-4-glider@google.com>
In-Reply-To: <20190508153736.256401-4-glider@google.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 8 May 2019 12:08:23 -0700
X-Gmail-Original-Message-ID: <CAGXu5jJS=KgLwetdmDAUq9+KhUFTd=jnCES3BZJm+qBwUBmLjQ@mail.gmail.com>
Message-ID: <CAGXu5jJS=KgLwetdmDAUq9+KhUFTd=jnCES3BZJm+qBwUBmLjQ@mail.gmail.com>
Subject: Re: [PATCH 3/4] gfp: mm: introduce __GFP_NOINIT
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, 
	Linux-MM <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 8, 2019 at 8:38 AM Alexander Potapenko <glider@google.com> wrote:
> When passed to an allocator (either pagealloc or SL[AOU]B), __GFP_NOINIT
> tells it to not initialize the requested memory if the init_on_alloc
> boot option is enabled. This can be useful in the cases newly allocated
> memory is going to be initialized by the caller right away.
>
> __GFP_NOINIT doesn't affect init_on_free behavior, except for SLOB,
> where init_on_free implies init_on_alloc.
>
> __GFP_NOINIT basically defeats the hardening against information leaks
> provided by init_on_alloc, so one should use it with caution.
>
> This patch also adds __GFP_NOINIT to alloc_pages() calls in SL[AOU]B.
> Doing so is safe, because the heap allocators initialize the pages they
> receive before passing memory to the callers.
>
> Slowdown for the initialization features compared to init_on_free=0,
> init_on_alloc=0:
>
> hackbench, init_on_free=1:  +6.84% sys time (st.err 0.74%)
> hackbench, init_on_alloc=1: +7.25% sys time (st.err 0.72%)
>
> Linux build with -j12, init_on_free=1:  +8.52% wall time (st.err 0.42%)
> Linux build with -j12, init_on_free=1:  +24.31% sys time (st.err 0.47%)
> Linux build with -j12, init_on_alloc=1: -0.16% wall time (st.err 0.40%)
> Linux build with -j12, init_on_alloc=1: +1.24% sys time (st.err 0.39%)
>
> The slowdown for init_on_free=0, init_on_alloc=0 compared to the
> baseline is within the standard error.
>
> Signed-off-by: Alexander Potapenko <glider@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> Cc: James Morris <jmorris@namei.org>
> Cc: "Serge E. Hallyn" <serge@hallyn.com>
> Cc: Nick Desaulniers <ndesaulniers@google.com>
> Cc: Kostya Serebryany <kcc@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Sandeep Patil <sspatil@android.com>
> Cc: Laura Abbott <labbott@redhat.com>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: Jann Horn <jannh@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: linux-mm@kvack.org
> Cc: linux-security-module@vger.kernel.org
> Cc: kernel-hardening@lists.openwall.com
> ---
>  include/linux/gfp.h | 6 +++++-
>  include/linux/mm.h  | 2 +-
>  kernel/kexec_core.c | 2 +-
>  mm/slab.c           | 2 +-
>  mm/slob.c           | 3 ++-
>  mm/slub.c           | 1 +
>  6 files changed, 11 insertions(+), 5 deletions(-)
>
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index fdab7de7490d..66d7f5604fe2 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -44,6 +44,7 @@ struct vm_area_struct;
>  #else
>  #define ___GFP_NOLOCKDEP       0
>  #endif
> +#define ___GFP_NOINIT          0x1000000u

I mentioned this in the other patch, but I think this needs to be
moved ahead of GFP_NOLOCKDEP and adjust the values for GFP_NOLOCKDEP
and to leave the IS_ENABLED() test in __GFP_BITS_SHIFT alone.

>  /* If the above are modified, __GFP_BITS_SHIFT may need updating */
>
>  /*
> @@ -208,16 +209,19 @@ struct vm_area_struct;
>   * %__GFP_COMP address compound page metadata.
>   *
>   * %__GFP_ZERO returns a zeroed page on success.
> + *
> + * %__GFP_NOINIT requests non-initialized memory from the underlying allocator.
>   */
>  #define __GFP_NOWARN   ((__force gfp_t)___GFP_NOWARN)
>  #define __GFP_COMP     ((__force gfp_t)___GFP_COMP)
>  #define __GFP_ZERO     ((__force gfp_t)___GFP_ZERO)
> +#define __GFP_NOINIT   ((__force gfp_t)___GFP_NOINIT)
>
>  /* Disable lockdep for GFP context tracking */
>  #define __GFP_NOLOCKDEP ((__force gfp_t)___GFP_NOLOCKDEP)
>
>  /* Room for N __GFP_FOO bits */
> -#define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
> +#define __GFP_BITS_SHIFT (25)

AIUI, this will break non-CONFIG_LOCKDEP kernels: it should just be:

-#define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
+#define __GFP_BITS_SHIFT (24 + IS_ENABLED(CONFIG_LOCKDEP))

>  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
>
>  /**
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ee1a1092679c..8ab152750eb4 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2618,7 +2618,7 @@ DECLARE_STATIC_KEY_FALSE(init_on_alloc);
>  static inline bool want_init_on_alloc(gfp_t flags)
>  {
>         if (static_branch_unlikely(&init_on_alloc))
> -               return true;
> +               return !(flags & __GFP_NOINIT);
>         return flags & __GFP_ZERO;

What do you think about renaming __GFP_NOINIT to __GFP_NO_AUTOINIT or something?

Regardless, yes, this is nice.

-- 
Kees Cook

