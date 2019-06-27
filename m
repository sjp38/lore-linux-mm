Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59B3DC48BD9
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:25:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 054D52083B
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:25:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="NJGqvKtl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 054D52083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98CA88E0010; Thu, 27 Jun 2019 09:25:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93D268E0002; Thu, 27 Jun 2019 09:25:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 803EA8E0010; Thu, 27 Jun 2019 09:25:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5807B8E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:25:16 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id v80so2329372qkb.19
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 06:25:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=6dS3lxY+6EGsl1bJa7+i9LW6SNznGkP6HMwHj3NIN/A=;
        b=FuiPh4c3c1k27KabTn/xw/n69FiZe6wp1JFPhodbqNPxURfKcqECYPhMN3ra6lqPbT
         FXxs4uwdbtue/+edVxF8DHXPMgfdEcSahgjg6HI7r/jhheGyvGIZ8E+LsvQ2jXbdDpZ3
         kP9EHWE6b2RZu8LC8jcY5wwem12LNQI5PW+ahFopVNRgZoPhMzFBu8yvOd6tRjtX1y1x
         Ic9YrYKICnPEOcwc5t14O5KzT9FsBoa0+E/K6LK/5dNgnNwkAnkQvrz2ztr+qlKQ7cAM
         6b81dqi2Q8oYhomcF0nQtO6EfekUBX1pdvl3N6Ob4gr2G6bduDPtOFp1pPGnRnxd7ztD
         1i2A==
X-Gm-Message-State: APjAAAUihIzAOADEW65ckCyo/VHW1RtBaY6Y2EWk/TEFpuM7bXhMlbGe
	+jhHLqOqG2YMY+eQ3ehY0QS+hlhedcXi8N2lPgsyIkjFYzPF0KogEAcuBTU0jK9XWratdyLQBlb
	0xoWJ1JdFDT3RxmZZhp6zVP5sxz+cVlyP9ftR7Ry/zJ7433XHinKFT2st3s5liC6gQQ==
X-Received: by 2002:ac8:124c:: with SMTP id g12mr2979262qtj.57.1561641916000;
        Thu, 27 Jun 2019 06:25:16 -0700 (PDT)
X-Received: by 2002:ac8:124c:: with SMTP id g12mr2979176qtj.57.1561641914754;
        Thu, 27 Jun 2019 06:25:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561641914; cv=none;
        d=google.com; s=arc-20160816;
        b=top4Hom+kLItGSaeXDiFdSV8zGJoigx/aB1kvuEcqdzyzer202G8MIbrctv+fc1g6J
         FThsqsTrri++nj8bxKILJfS2oHvo4vbMfs+jb7QbLVOO7lq+8NqMxbsGEuSSGzjuU4yu
         EmGWZD/Lr5vPKR+ljJYZd75YFe9Gy9zwb17T/CCu+UE2MCKJFkI+dEdCzf+N24nqGLra
         YMUPzU4BOs9i/+keLdPQA+IKxh4CvszPBVmi8PGpXJTpAWHGzLXNIbA5sQQshEa25suo
         Vyt69tr1VonzE3Yx6Bz6hvaNWzHR6YB2OnV7E41fPJylwr7tdVRzIWU74Xlc6GkXm37b
         ALjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=6dS3lxY+6EGsl1bJa7+i9LW6SNznGkP6HMwHj3NIN/A=;
        b=LXVoMNEXwkFljVpG7UkpV3hmHsA4Kwl2KlZuq1rWZP+8mMK2/JZVd44dzHSHK6R5ns
         wsQa3HruGpYqYo6CulluCRk8C9B3Yk/8I0SLyC58dNnPAgNVoc9VUQpATsSKB+wFXp+W
         4kjfUwwmzZRdjFROgYIyxVyGP+Tfm0xue7KEIfxvBLfREe1itDu660Oaj/+o4eYiFf9k
         o62+5fiume5SFvhfQlHJIvtsdbMZpBPXpC5HjiEUzRgRabyUHinYxM1L7QmTIDZX/hKD
         CCPV7L3CUxcZjZX50+L8vQKc5i076L1mkoniiwLoALNhDJgWRGH0wIydXPsCeReQKdi2
         dsFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=NJGqvKtl;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w10sor1417167qkf.61.2019.06.27.06.25.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 06:25:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=NJGqvKtl;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=6dS3lxY+6EGsl1bJa7+i9LW6SNznGkP6HMwHj3NIN/A=;
        b=NJGqvKtlIPxFOauWJUR9WMIXM3Y1QfzwsvGo/QUka/d4KPuX6SROyYl/lXtZU+/19/
         pF5h8tKhexbgWax/3bsZiSB0tsSFdfvKmPSYYgo8cvDxjXHJJ3xeKh4z2H9dSVADqeUN
         EmNu3GG7M8udo9lDfl6uMJkiaPNh/0YKObYDLOObQVDo9MXfYFuDrbk6Y/MjFKDlsrUr
         vycPQNWxZRlUlk3QJz5ly7OkHFeXw4ajWmT4dFWGk87cjJ80RDl6QSEomyuu+f+8iGY0
         jdH7bgtf+rDUMzADko4mtSdExKXyHgmDbmuG/5fzcwgVmJJ4rHwCX67Efri3gjT0+r7d
         Dhsg==
X-Google-Smtp-Source: APXvYqxGmNRFG25wd8rTFNhGb4AmrBfzueilTyzIom7703cRMHXPDCleM1XRyWawpO/qc1lOy8TY1g==
X-Received: by 2002:a37:668c:: with SMTP id a134mr3401556qkc.477.1561641914329;
        Thu, 27 Jun 2019 06:25:14 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id k40sm1085585qta.50.2019.06.27.06.25.12
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 06:25:13 -0700 (PDT)
Message-ID: <1561641911.5154.85.camel@lca.pw>
Subject: Re: [PATCH v9 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
From: Qian Cai <cai@lca.pw>
To: Alexander Potapenko <glider@google.com>, Andrew Morton
	 <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Kees Cook
	 <keescook@chromium.org>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Hocko
 <mhocko@kernel.org>, James Morris <jmorris@namei.org>, "Serge E. Hallyn"
 <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, Kostya
 Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep
 Patil <sspatil@android.com>,  Laura Abbott <labbott@redhat.com>, Randy
 Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,  Mark Rutland
 <mark.rutland@arm.com>, Marco Elver <elver@google.com>, linux-mm@kvack.org,
  linux-security-module@vger.kernel.org, kernel-hardening@lists.openwall.com
Date: Thu, 27 Jun 2019 09:25:11 -0400
In-Reply-To: <20190627130316.254309-2-glider@google.com>
References: <20190627130316.254309-1-glider@google.com>
	 <20190627130316.254309-2-glider@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-06-27 at 15:03 +0200, Alexander Potapenko wrote:
> The new options are needed to prevent possible information leaks and
> make control-flow bugs that depend on uninitialized values more
> deterministic.
> 
> This is expected to be on-by-default on Android and Chrome OS. And it
> gives the opportunity for anyone else to use it under distros too via
> the boot args. (The init_on_free feature is regularly requested by
> folks where memory forensics is included in their threat models.)
> 
> init_on_alloc=1 makes the kernel initialize newly allocated pages and heap
> objects with zeroes. Initialization is done at allocation time at the
> places where checks for __GFP_ZERO are performed.
> 
> init_on_free=1 makes the kernel initialize freed pages and heap objects
> with zeroes upon their deletion. This helps to ensure sensitive data
> doesn't leak via use-after-free accesses.
> 
> Both init_on_alloc=1 and init_on_free=1 guarantee that the allocator
> returns zeroed memory. The two exceptions are slab caches with
> constructors and SLAB_TYPESAFE_BY_RCU flag. Those are never
> zero-initialized to preserve their semantics.
> 
> Both init_on_alloc and init_on_free default to zero, but those defaults
> can be overridden with CONFIG_INIT_ON_ALLOC_DEFAULT_ON and
> CONFIG_INIT_ON_FREE_DEFAULT_ON.
> 
> If either SLUB poisoning or page poisoning is enabled, those options
> take precedence over init_on_alloc and init_on_free: initialization is
> only applied to unpoisoned allocations.
> 
> Slowdown for the new features compared to init_on_free=0,
> init_on_alloc=0:
> 
> hackbench, init_on_free=1:  +7.62% sys time (st.err 0.74%)
> hackbench, init_on_alloc=1: +7.75% sys time (st.err 2.14%)
> 
> Linux build with -j12, init_on_free=1:  +8.38% wall time (st.err 0.39%)
> Linux build with -j12, init_on_free=1:  +24.42% sys time (st.err 0.52%)
> Linux build with -j12, init_on_alloc=1: -0.13% wall time (st.err 0.42%)
> Linux build with -j12, init_on_alloc=1: +0.57% sys time (st.err 0.40%)
> 
> The slowdown for init_on_free=0, init_on_alloc=0 compared to the
> baseline is within the standard error.
> 
> The new features are also going to pave the way for hardware memory
> tagging (e.g. arm64's MTE), which will require both on_alloc and on_free
> hooks to set the tags for heap objects. With MTE, tagging will have the
> same cost as memory initialization.
> 
> Although init_on_free is rather costly, there are paranoid use-cases where
> in-memory data lifetime is desired to be minimized. There are various
> arguments for/against the realism of the associated threat models, but
> given that we'll need the infrastructure for MTE anyway, and there are
> people who want wipe-on-free behavior no matter what the performance cost,
> it seems reasonable to include it in this series.
> 
> Signed-off-by: Alexander Potapenko <glider@google.com>
> Acked-by: Kees Cook <keescook@chromium.org>
> To: Andrew Morton <akpm@linux-foundation.org>
> To: Christoph Lameter <cl@linux.com>
> To: Kees Cook <keescook@chromium.org>
> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: James Morris <jmorris@namei.org>
> Cc: "Serge E. Hallyn" <serge@hallyn.com>
> Cc: Nick Desaulniers <ndesaulniers@google.com>
> Cc: Kostya Serebryany <kcc@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Sandeep Patil <sspatil@android.com>
> Cc: Laura Abbott <labbott@redhat.com>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: Jann Horn <jannh@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Marco Elver <elver@google.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: linux-mm@kvack.org
> Cc: linux-security-module@vger.kernel.org
> Cc: kernel-hardening@lists.openwall.com
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>  v2:
>   - unconditionally initialize pages in kernel_init_free_pages()
>   - comment from Randy Dunlap: drop 'default false' lines from
> Kconfig.hardening
>  v3:
>   - don't call kernel_init_free_pages() from memblock_free_pages()
>   - adopted some Kees' comments for the patch description
>  v4:
>   - use NULL instead of 0 in slab_alloc_node() (found by kbuild test robot)
>   - don't write to NULL object in slab_alloc_node() (found by Android
>     testing)
>  v5:
>   - adjusted documentation wording as suggested by Kees
>   - disable SLAB_POISON if auto-initialization is on
>   - don't wipe RCU cache allocations made without __GFP_ZERO
>   - dropped SLOB support
>  v7:
>   - rebase the patch, added the Acked-by: tag
>  v8:
>   - addressed comments by Michal Hocko: revert kernel/kexec_core.c and
>     apply initialization in dma_pool_free()
>   - disable init_on_alloc/init_on_free if slab poisoning or page
>     poisoning are enabled, as requested by Qian Cai
>   - skip the redzone when initializing a freed heap object, as requested
>     by Qian Cai and Kees Cook
>   - use s->offset to address the freeptr (suggested by Kees Cook)
>   - updated the patch description, added Signed-off-by: tag
>  v9:
>   - picked up -mm fixes from Qian Cai and Andrew Morton (order of calls
>     in free_pages_prepare(), export init_on_alloc)
>   - exported init_on_free
>   - allowed using init_on_alloc/init_on_free with SLUB poisoning and
>     page poisoning. Poisoning supersedes zero-initialization, so some
>     tests may behave differently with poisoning enabled.
> ---
>  .../admin-guide/kernel-parameters.txt         |  9 +++
>  drivers/infiniband/core/uverbs_ioctl.c        |  2 +-
>  include/linux/mm.h                            | 24 +++++++
>  mm/dmapool.c                                  |  4 +-
>  mm/page_alloc.c                               | 71 +++++++++++++++++--
>  mm/slab.c                                     | 16 ++++-
>  mm/slab.h                                     | 20 ++++++
>  mm/slub.c                                     | 41 +++++++++--
>  net/core/sock.c                               |  2 +-
>  security/Kconfig.hardening                    | 29 ++++++++
>  10 files changed, 200 insertions(+), 18 deletions(-)
> 
> diff --git a/Documentation/admin-guide/kernel-parameters.txt
> b/Documentation/admin-guide/kernel-parameters.txt
> index 138f6664b2e2..84ee1121a2b9 100644
> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -1673,6 +1673,15 @@
>  
>  	initrd=		[BOOT] Specify the location of the initial
> ramdisk
>  
> +	init_on_alloc=	[MM] Fill newly allocated pages and heap
> objects with
> +			zeroes.
> +			Format: 0 | 1
> +			Default set by CONFIG_INIT_ON_ALLOC_DEFAULT_ON.
> +
> +	init_on_free=	[MM] Fill freed pages and heap objects with
> zeroes.
> +			Format: 0 | 1
> +			Default set by CONFIG_INIT_ON_FREE_DEFAULT_ON.
> +
>  	init_pkru=	[x86] Specify the default memory protection keys
> rights
>  			register contents for all processes.  0x55555554 by
>  			default (disallow access to all but pkey 0).  Can
> diff --git a/drivers/infiniband/core/uverbs_ioctl.c
> b/drivers/infiniband/core/uverbs_ioctl.c
> index 829b0c6944d8..61758201d9b2 100644
> --- a/drivers/infiniband/core/uverbs_ioctl.c
> +++ b/drivers/infiniband/core/uverbs_ioctl.c
> @@ -127,7 +127,7 @@ __malloc void *_uverbs_alloc(struct uverbs_attr_bundle
> *bundle, size_t size,
>  	res = (void *)pbundle->internal_buffer + pbundle->internal_used;
>  	pbundle->internal_used =
>  		ALIGN(new_used, sizeof(*pbundle->internal_buffer));
> -	if (flags & __GFP_ZERO)
> +	if (want_init_on_alloc(flags))
>  		memset(res, 0, size);
>  	return res;
>  }
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index dd0b5f4e1e45..81b582657854 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2696,6 +2696,30 @@ static inline void kernel_poison_pages(struct page
> *page, int numpages,
>  					int enable) { }
>  #endif
>  
> +#ifdef CONFIG_INIT_ON_ALLOC_DEFAULT_ON
> +DECLARE_STATIC_KEY_TRUE(init_on_alloc);
> +#else
> +DECLARE_STATIC_KEY_FALSE(init_on_alloc);
> +#endif
> +static inline bool want_init_on_alloc(gfp_t flags)
> +{
> +	if (static_branch_unlikely(&init_on_alloc) &&
> +	    !page_poisoning_enabled())
> +		return true;
> +	return flags & __GFP_ZERO;
> +}
> +
> +#ifdef CONFIG_INIT_ON_FREE_DEFAULT_ON
> +DECLARE_STATIC_KEY_TRUE(init_on_free);
> +#else
> +DECLARE_STATIC_KEY_FALSE(init_on_free);
> +#endif
> +static inline bool want_init_on_free(void)
> +{
> +	return static_branch_unlikely(&init_on_free) &&
> +	       !page_poisoning_enabled();
> +}
> +
>  extern bool _debug_pagealloc_enabled;
>  
>  static inline bool debug_pagealloc_enabled(void)
> diff --git a/mm/dmapool.c b/mm/dmapool.c
> index 8c94c89a6f7e..fe5d33060415 100644
> --- a/mm/dmapool.c
> +++ b/mm/dmapool.c
> @@ -378,7 +378,7 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t
> mem_flags,
>  #endif
>  	spin_unlock_irqrestore(&pool->lock, flags);
>  
> -	if (mem_flags & __GFP_ZERO)
> +	if (want_init_on_alloc(mem_flags))
>  		memset(retval, 0, pool->size);
>  
>  	return retval;
> @@ -428,6 +428,8 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr,
> dma_addr_t dma)
>  	}
>  
>  	offset = vaddr - page->vaddr;
> +	if (want_init_on_free())
> +		memset(vaddr, 0, pool->size);
>  #ifdef	DMAPOOL_DEBUG
>  	if ((dma - page->dma) != offset) {
>  		spin_unlock_irqrestore(&pool->lock, flags);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index d66bc8abe0af..c3123fa41bba 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -136,6 +136,55 @@ unsigned long totalcma_pages __read_mostly;
>  
>  int percpu_pagelist_fraction;
>  gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
> +#ifdef CONFIG_INIT_ON_ALLOC_DEFAULT_ON
> +DEFINE_STATIC_KEY_TRUE(init_on_alloc);
> +#else
> +DEFINE_STATIC_KEY_FALSE(init_on_alloc);
> +#endif
> +EXPORT_SYMBOL(init_on_alloc);
> +
> +#ifdef CONFIG_INIT_ON_FREE_DEFAULT_ON
> +DEFINE_STATIC_KEY_TRUE(init_on_free);
> +#else
> +DEFINE_STATIC_KEY_FALSE(init_on_free);
> +#endif
> +EXPORT_SYMBOL(init_on_free);
> +
> +static int __init early_init_on_alloc(char *buf)
> +{
> +	int ret;
> +	bool bool_result;
> +
> +	if (!buf)
> +		return -EINVAL;
> +	ret = kstrtobool(buf, &bool_result);
> +	if (bool_result && IS_ENABLED(CONFIG_PAGE_POISONING))
> +		pr_warn("mem auto-init: CONFIG_PAGE_POISONING is on, will
> take precedence over init_on_alloc\n");

I don't like the warning here. It makes people think it is bug that need to be
fixed, but actually it is just information. People could enable both in a debug
kernel.

> +	if (bool_result)
> +		static_branch_enable(&init_on_alloc);
> +	else
> +		static_branch_disable(&init_on_alloc);
> +	return ret;
> +}
> +early_param("init_on_alloc", early_init_on_alloc);
> +
> +static int __init early_init_on_free(char *buf)
> +{
> +	int ret;
> +	bool bool_result;
> +
> +	if (!buf)
> +		return -EINVAL;
> +	ret = kstrtobool(buf, &bool_result);
> +	if (bool_result && IS_ENABLED(CONFIG_PAGE_POISONING))
> +		pr_warn("mem auto-init: CONFIG_PAGE_POISONING is on, will
> take precedence over init_on_free\n");

Ditto.

> +	if (bool_result)
> +		static_branch_enable(&init_on_free);
> +	else
> +		static_branch_disable(&init_on_free);
> +	return ret;
> +}
> +early_param("init_on_free", early_init_on_free);
>  
>  /*
>   * A cached value of the page's pageblock's migratetype, used when the page
> is
> @@ -1090,6 +1139,14 @@ static int free_tail_pages_check(struct page
> *head_page, struct page *page)
>  	return ret;
>  }
>  
> +static void kernel_init_free_pages(struct page *page, int numpages)
> +{
> +	int i;
> +
> +	for (i = 0; i < numpages; i++)
> +		clear_highpage(page + i);
> +}
> +
>  static __always_inline bool free_pages_prepare(struct page *page,
>  					unsigned int order, bool check_free)
>  {
> @@ -1141,6 +1198,9 @@ static __always_inline bool free_pages_prepare(struct
> page *page,
>  					   PAGE_SIZE << order);
>  	}
>  	arch_free_page(page, order);
> +	if (want_init_on_free())
> +		kernel_init_free_pages(page, 1 << order);
> +
>  	kernel_poison_pages(page, 1 << order, 0);
>  	if (debug_pagealloc_enabled())
>  		kernel_map_pages(page, 1 << order, 0);
> @@ -2020,8 +2080,8 @@ static inline int check_new_page(struct page *page)
>  
>  static inline bool free_pages_prezeroed(void)
>  {
> -	return IS_ENABLED(CONFIG_PAGE_POISONING_ZERO) &&
> -		page_poisoning_enabled();
> +	return (IS_ENABLED(CONFIG_PAGE_POISONING_ZERO) &&
> +		page_poisoning_enabled()) || want_init_on_free();
>  }
>  
>  #ifdef CONFIG_DEBUG_VM
> @@ -2075,13 +2135,10 @@ inline void post_alloc_hook(struct page *page,
> unsigned int order,
>  static void prep_new_page(struct page *page, unsigned int order, gfp_t
> gfp_flags,
>  							unsigned int
> alloc_flags)
>  {
> -	int i;
> -
>  	post_alloc_hook(page, order, gfp_flags);
>  
> -	if (!free_pages_prezeroed() && (gfp_flags & __GFP_ZERO))
> -		for (i = 0; i < (1 << order); i++)
> -			clear_highpage(page + i);
> +	if (!free_pages_prezeroed() && want_init_on_alloc(gfp_flags))
> +		kernel_init_free_pages(page, 1 << order);
>  
>  	if (order && (gfp_flags & __GFP_COMP))
>  		prep_compound_page(page, order);
> diff --git a/mm/slab.c b/mm/slab.c
> index f7117ad9b3a3..98a89d7c922d 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1830,6 +1830,14 @@ static bool set_objfreelist_slab_cache(struct
> kmem_cache *cachep,
>  
>  	cachep->num = 0;
>  
> +	/*
> +	 * If slab auto-initialization on free is enabled, store the freelist
> +	 * off-slab, so that its contents don't end up in one of the
> allocated
> +	 * objects.
> +	 */
> +	if (unlikely(slab_want_init_on_free(cachep)))
> +		return false;
> +
>  	if (cachep->ctor || flags & SLAB_TYPESAFE_BY_RCU)
>  		return false;
>  
> @@ -3263,7 +3271,7 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags,
> int nodeid,
>  	local_irq_restore(save_flags);
>  	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, caller);
>  
> -	if (unlikely(flags & __GFP_ZERO) && ptr)
> +	if (unlikely(slab_want_init_on_alloc(flags, cachep)) && ptr)
>  		memset(ptr, 0, cachep->object_size);
>  
>  	slab_post_alloc_hook(cachep, flags, 1, &ptr);
> @@ -3320,7 +3328,7 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags,
> unsigned long caller)
>  	objp = cache_alloc_debugcheck_after(cachep, flags, objp, caller);
>  	prefetchw(objp);
>  
> -	if (unlikely(flags & __GFP_ZERO) && objp)
> +	if (unlikely(slab_want_init_on_alloc(flags, cachep)) && objp)
>  		memset(objp, 0, cachep->object_size);
>  
>  	slab_post_alloc_hook(cachep, flags, 1, &objp);
> @@ -3441,6 +3449,8 @@ void ___cache_free(struct kmem_cache *cachep, void
> *objp,
>  	struct array_cache *ac = cpu_cache_get(cachep);
>  
>  	check_irq_off();
> +	if (unlikely(slab_want_init_on_free(cachep)))
> +		memset(objp, 0, cachep->object_size);
>  	kmemleak_free_recursive(objp, cachep->flags);
>  	objp = cache_free_debugcheck(cachep, objp, caller);
>  
> @@ -3528,7 +3538,7 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t
> flags, size_t size,
>  	cache_alloc_debugcheck_after_bulk(s, flags, size, p, _RET_IP_);
>  
>  	/* Clear memory outside IRQ disabled section */
> -	if (unlikely(flags & __GFP_ZERO))
> +	if (unlikely(slab_want_init_on_alloc(flags, s)))
>  		for (i = 0; i < size; i++)
>  			memset(p[i], 0, s->object_size);
>  
> diff --git a/mm/slab.h b/mm/slab.h
> index 43ac818b8592..d3f585e604bb 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -524,4 +524,24 @@ static inline int cache_random_seq_create(struct
> kmem_cache *cachep,
>  static inline void cache_random_seq_destroy(struct kmem_cache *cachep) { }
>  #endif /* CONFIG_SLAB_FREELIST_RANDOM */
>  
> +static inline bool slab_want_init_on_alloc(gfp_t flags, struct kmem_cache *c)
> +{
> +	if (static_branch_unlikely(&init_on_alloc)) {
> +		if (c->ctor)
> +			return false;
> +		if (c->flags & (SLAB_TYPESAFE_BY_RCU | SLAB_POISON))
> +			return flags & __GFP_ZERO;
> +		return true;
> +	}
> +	return flags & __GFP_ZERO;
> +}
> +
> +static inline bool slab_want_init_on_free(struct kmem_cache *c)
> +{
> +	if (static_branch_unlikely(&init_on_free))
> +		return !(c->ctor ||
> +			 (c->flags & (SLAB_TYPESAFE_BY_RCU | SLAB_POISON)));
> +	return false;
> +}
> +
>  #endif /* MM_SLAB_H */
> diff --git a/mm/slub.c b/mm/slub.c
> index cd04dbd2b5d0..3ccdab86f253 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1279,6 +1279,11 @@ static int __init setup_slub_debug(char *str)
>  	if (*str == ',')
>  		slub_debug_slabs = str + 1;
>  out:
> +	if ((static_branch_unlikely(&init_on_alloc) ||
> +	     static_branch_unlikely(&init_on_free)) &&
> +	    (slub_debug & SLAB_POISON)) {
> +		pr_warn("mem auto-init: SLAB_POISON will take precedence over
> init_on_alloc/init_on_free\n");
> +	}

Ditto

