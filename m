Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F6BFC04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 16:12:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 937A121726
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 16:12:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="h2hFjpxR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 937A121726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09B556B0003; Mon, 20 May 2019 12:12:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 073A86B0008; Mon, 20 May 2019 12:12:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA5476B000A; Mon, 20 May 2019 12:12:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE3A86B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 12:12:17 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 93so9404703plf.14
        for <linux-mm@kvack.org>; Mon, 20 May 2019 09:12:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=if4GvDTlkLUHFwbpOP4ccx+furWZ2hKY8dlwncweNiM=;
        b=jW1QWs9I95Tu6GbLUlXZZODXJm1bDOFGv4Zy2TfTvDzVyAjBbgOFh3BUImUhx0T8K6
         +2/5b8wXaBPj5fMCh1q8oeeNFB1b+5nu0SKfS2jh0Xo/Cc7m8zD09YWR5+kAlkidEaZV
         rcUDTJvlJMNMAENKaq9vtXUS+aBgdJg01QH7aHOQZM6U3JuTplPLgh2KccytNUaInAHX
         AHLDiWx3JMiJ/YjKC26nuVYYEnZH6Z8d2c5k58J67nkkPSAykkd8tfIV9CcwvQr/bBD0
         2WXjW+7iCxVcxLLz5Ls+m2koilYWH7U7B+Drne9MHsJjxxQHyi9QUEKo3SY0UrotxvYO
         vkvw==
X-Gm-Message-State: APjAAAUsEEZ4veQD29FxmqCpynD2badXxigZJOvG9O+FdaRcUjIgixAK
	7RmLFhMcyS/c1lK9fBh8NFf6WmAocaGGv0adU5w7PmpoXEv6mz7mY8sS8AzLxV0EVA12B+L/39M
	6LQdmGggzCih/xrV2tA/KpIMC8VqP4gFeTRj7g3oREtMMm6MT9xnbbpTnvPPGu6hpYw==
X-Received: by 2002:a17:902:82ca:: with SMTP id u10mr63663593plz.231.1558368737086;
        Mon, 20 May 2019 09:12:17 -0700 (PDT)
X-Received: by 2002:a17:902:82ca:: with SMTP id u10mr63663483plz.231.1558368735934;
        Mon, 20 May 2019 09:12:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558368735; cv=none;
        d=google.com; s=arc-20160816;
        b=z4jGcWDBn6dq9PPqg8fdeicitdTTDVx3+tjtske+UGKLZAiaf5OqdWxdIU2NTb52ig
         gPbJoY6ds5iJn+85dwuo7y8vMisj2LTU23nVrMwABoZGvHY0fK5LsYMqpQ+v6hKUf1Y9
         l9WTHiGC3jnHrnQ3GbjUPpX0kofljT73N2quUpwCYxU3dr2xLMYtLITgXaOE9a0pPLHb
         qhaQXSlIPOCcJA8IyM6b++GyTCXqOQPg5YztMBVBgrby+SrZYgk3lH7+YRAhHk5by5vs
         9e/eITrOgV0U8Z7HoWKb1oRKYXEJGzXB5zefbbTjcja1EQNmE24XgyW/kLGdmxB+1mFH
         SsbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=if4GvDTlkLUHFwbpOP4ccx+furWZ2hKY8dlwncweNiM=;
        b=jtq16dWHo+2TPBGzbRB8xbhhgYN0Y/vWZQc2kaUKme6JHldiWRE9yRVghm1236GQQZ
         z6WsLEW6UWC1VJF+llTZYrvTJ/dH3yP5Y9rn2wIClL2PNIEMs5L6BMT3juXwAVrItZOK
         meztNKvgirzNx2/1JLP8ZGR2WhdrMdk53Ja6RhMevRjkxJUSsRYp8Rf8Ni0OHAjh6x7U
         qwqSwgpHL9VAv39T80V+cCPeSpV9SgZJcjpBTxKCDJm0dwmaCJhdo9z92bBTXEgGA6W7
         /J/Rqs+XeITAzw5dY+duG+stL37qzwq+HCtalH+bp4yNsrIePnQmptXZ672pok6uoW+s
         sEdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=h2hFjpxR;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id cf8sor19681509plb.36.2019.05.20.09.12.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 09:12:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=h2hFjpxR;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=if4GvDTlkLUHFwbpOP4ccx+furWZ2hKY8dlwncweNiM=;
        b=h2hFjpxRSc9i6XfAPwfX7okGeUZy2dbzpXO4dt/9o53cdPnASNHB5OSq/WlLMteR6l
         u9EZDByLBaFbtqIr2C9h99V+QU4dvu0z9n1Jdh2GRSlgQ+jNg37VDyA0HEIfdheVt7Qb
         VldgQA4un9H40DroPz6x31dJd8oOovfsiI8Sc=
X-Google-Smtp-Source: APXvYqzHyBj57UOrrBpIt6RQmX7JQTb9PtdoCux39wxuPfKCfZ2k9olwrFNgb7vgdG+OQjxgXKco/g==
X-Received: by 2002:a17:902:e492:: with SMTP id cj18mr19427174plb.341.1558368735635;
        Mon, 20 May 2019 09:12:15 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id a64sm18820673pgc.53.2019.05.20.09.12.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 May 2019 09:12:14 -0700 (PDT)
Date: Mon, 20 May 2019 09:12:13 -0700
From: Kees Cook <keescook@chromium.org>
To: Mathias Krause <minipli@googlemail.com>
Cc: Alexander Potapenko <glider@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	kernel-hardening@lists.openwall.com,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org
Subject: Re: [PATCH 5/4] mm: Introduce SLAB_NO_FREE_INIT and mark excluded
 caches
Message-ID: <201905200902.68FD66AD9E@keescook>
References: <20190514143537.10435-5-glider@google.com>
 <201905161746.16E885F@keescook>
 <CA+rthh9bLiohU78PBMonji_LPjj756rhTy22v9nL8LpL0cTb5g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+rthh9bLiohU78PBMonji_LPjj756rhTy22v9nL8LpL0cTb5g@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 08:10:19AM +0200, Mathias Krause wrote:
> Hi Kees,
> 
> On Fri, 17 May 2019 at 02:50, Kees Cook <keescook@chromium.org> wrote:
> > In order to improve the init_on_free performance, some frequently
> > freed caches with less sensitive contents can be excluded from the
> > init_on_free behavior.
> >
> > This patch is modified from Brad Spengler/PaX Team's code in the
> > last public patch of grsecurity/PaX based on my understanding of the
> > code. Changes or omissions from the original code are mine and don't
> > reflect the original grsecurity/PaX code.
> 
> you might want to give secunet credit for this one, as can be seen here:
> 
>   https://github.com/minipli/linux-grsec/commit/309d494e7a3f6533ca68fc8b3bd89fa76fd2c2df
> 
> However, please keep the "Changes or omissions from the original
> code..." part as your version slightly differs.

Ah-ha! Thanks for finding the specific commit; I'll adjust
attribution. Are you able to describe how you chose the various excluded
kmem caches? (I assume it wasn't just "highest numbers in the stats
reporting".) And why run the ctor after wipe? Doesn't that means you're
just running the ctor again at the next allocation time?

Thanks!

-Kees

> 
> Thanks,
> Mathias
> 
> >
> > Signed-off-by: Kees Cook <keescook@chromium.org>
> > ---
> >  fs/buffer.c          | 2 +-
> >  fs/dcache.c          | 3 ++-
> >  include/linux/slab.h | 3 +++
> >  kernel/fork.c        | 6 ++++--
> >  mm/rmap.c            | 5 +++--
> >  mm/slab.h            | 5 +++--
> >  net/core/skbuff.c    | 6 ++++--
> >  7 files changed, 20 insertions(+), 10 deletions(-)
> >
> > diff --git a/fs/buffer.c b/fs/buffer.c
> > index 0faa41fb4c88..04a85bd4cf2e 100644
> > --- a/fs/buffer.c
> > +++ b/fs/buffer.c
> > @@ -3457,7 +3457,7 @@ void __init buffer_init(void)
> >         bh_cachep = kmem_cache_create("buffer_head",
> >                         sizeof(struct buffer_head), 0,
> >                                 (SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
> > -                               SLAB_MEM_SPREAD),
> > +                               SLAB_MEM_SPREAD|SLAB_NO_FREE_INIT),
> >                                 NULL);
> >
> >         /*
> > diff --git a/fs/dcache.c b/fs/dcache.c
> > index 8136bda27a1f..323b039accba 100644
> > --- a/fs/dcache.c
> > +++ b/fs/dcache.c
> > @@ -3139,7 +3139,8 @@ void __init vfs_caches_init_early(void)
> >  void __init vfs_caches_init(void)
> >  {
> >         names_cachep = kmem_cache_create_usercopy("names_cache", PATH_MAX, 0,
> > -                       SLAB_HWCACHE_ALIGN|SLAB_PANIC, 0, PATH_MAX, NULL);
> > +                       SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NO_FREE_INIT, 0,
> > +                       PATH_MAX, NULL);
> >
> >         dcache_init();
> >         inode_init();
> > diff --git a/include/linux/slab.h b/include/linux/slab.h
> > index 9449b19c5f10..7eba9ad8830d 100644
> > --- a/include/linux/slab.h
> > +++ b/include/linux/slab.h
> > @@ -92,6 +92,9 @@
> >  /* Avoid kmemleak tracing */
> >  #define SLAB_NOLEAKTRACE       ((slab_flags_t __force)0x00800000U)
> >
> > +/* Exclude slab from zero-on-free when init_on_free is enabled */
> > +#define SLAB_NO_FREE_INIT      ((slab_flags_t __force)0x01000000U)
> > +
> >  /* Fault injection mark */
> >  #ifdef CONFIG_FAILSLAB
> >  # define SLAB_FAILSLAB         ((slab_flags_t __force)0x02000000U)
> > diff --git a/kernel/fork.c b/kernel/fork.c
> > index b4cba953040a..9868585f5520 100644
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -2550,11 +2550,13 @@ void __init proc_caches_init(void)
> >
> >         mm_cachep = kmem_cache_create_usercopy("mm_struct",
> >                         mm_size, ARCH_MIN_MMSTRUCT_ALIGN,
> > -                       SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT,
> > +                       SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT|
> > +                       SLAB_NO_FREE_INIT,
> >                         offsetof(struct mm_struct, saved_auxv),
> >                         sizeof_field(struct mm_struct, saved_auxv),
> >                         NULL);
> > -       vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC|SLAB_ACCOUNT);
> > +       vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC|SLAB_ACCOUNT|
> > +                                                   SLAB_NO_FREE_INIT);
> >         mmap_init();
> >         nsproxy_cache_init();
> >  }
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index e5dfe2ae6b0d..b7b8013eeb0a 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -432,10 +432,11 @@ static void anon_vma_ctor(void *data)
> >  void __init anon_vma_init(void)
> >  {
> >         anon_vma_cachep = kmem_cache_create("anon_vma", sizeof(struct anon_vma),
> > -                       0, SLAB_TYPESAFE_BY_RCU|SLAB_PANIC|SLAB_ACCOUNT,
> > +                       0, SLAB_TYPESAFE_BY_RCU|SLAB_PANIC|SLAB_ACCOUNT|
> > +                       SLAB_NO_FREE_INIT,
> >                         anon_vma_ctor);
> >         anon_vma_chain_cachep = KMEM_CACHE(anon_vma_chain,
> > -                       SLAB_PANIC|SLAB_ACCOUNT);
> > +                       SLAB_PANIC|SLAB_ACCOUNT|SLAB_NO_FREE_INIT);
> >  }
> >
> >  /*
> > diff --git a/mm/slab.h b/mm/slab.h
> > index 24ae887359b8..f95b4f03c57b 100644
> > --- a/mm/slab.h
> > +++ b/mm/slab.h
> > @@ -129,7 +129,8 @@ static inline slab_flags_t kmem_cache_flags(unsigned int object_size,
> >  /* Legal flag mask for kmem_cache_create(), for various configurations */
> >  #define SLAB_CORE_FLAGS (SLAB_HWCACHE_ALIGN | SLAB_CACHE_DMA | \
> >                          SLAB_CACHE_DMA32 | SLAB_PANIC | \
> > -                        SLAB_TYPESAFE_BY_RCU | SLAB_DEBUG_OBJECTS )
> > +                        SLAB_TYPESAFE_BY_RCU | SLAB_DEBUG_OBJECTS | \
> > +                        SLAB_NO_FREE_INIT)
> >
> >  #if defined(CONFIG_DEBUG_SLAB)
> >  #define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
> > @@ -535,7 +536,7 @@ static inline bool slab_want_init_on_alloc(gfp_t flags, struct kmem_cache *c)
> >  static inline bool slab_want_init_on_free(struct kmem_cache *c)
> >  {
> >         if (static_branch_unlikely(&init_on_free))
> > -               return !(c->ctor);
> > +               return !(c->ctor) && ((c->flags & SLAB_NO_FREE_INIT) == 0);
> >         else
> >                 return false;
> >  }
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index e89be6282693..b65902d2c042 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -3981,14 +3981,16 @@ void __init skb_init(void)
> >         skbuff_head_cache = kmem_cache_create_usercopy("skbuff_head_cache",
> >                                               sizeof(struct sk_buff),
> >                                               0,
> > -                                             SLAB_HWCACHE_ALIGN|SLAB_PANIC,
> > +                                             SLAB_HWCACHE_ALIGN|SLAB_PANIC|
> > +                                             SLAB_NO_FREE_INIT,
> >                                               offsetof(struct sk_buff, cb),
> >                                               sizeof_field(struct sk_buff, cb),
> >                                               NULL);
> >         skbuff_fclone_cache = kmem_cache_create("skbuff_fclone_cache",
> >                                                 sizeof(struct sk_buff_fclones),
> >                                                 0,
> > -                                               SLAB_HWCACHE_ALIGN|SLAB_PANIC,
> > +                                               SLAB_HWCACHE_ALIGN|SLAB_PANIC|
> > +                                               SLAB_NO_FREE_INIT,
> >                                                 NULL);
> >         skb_extensions_init();
> >  }
> > --
> > 2.17.1
> >
> >
> > --
> > Kees Cook

-- 
Kees Cook

