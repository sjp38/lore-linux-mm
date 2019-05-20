Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA66AC072A4
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 06:10:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 646BB20851
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 06:10:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=googlemail.com header.i=@googlemail.com header.b="Y0j6sgfc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 646BB20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=googlemail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F31276B026B; Mon, 20 May 2019 02:10:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBB0F6B026C; Mon, 20 May 2019 02:10:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D81FC6B026D; Mon, 20 May 2019 02:10:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id B1A936B026B
	for <linux-mm@kvack.org>; Mon, 20 May 2019 02:10:31 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id q17so11748599qkc.23
        for <linux-mm@kvack.org>; Sun, 19 May 2019 23:10:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=NFukLdZ7lb89NEuXmBM0ev5FCwA/kWpf23+eFLzEIzc=;
        b=WahwSSpyfH87pLCoINO13svrog2/8Xwqs5lL/sWChCwAJLP2dmnWwE240GOQUVpp6E
         1SORHndhydRLK2ErnepQy+0cI/Ah6fUGGy3bYaogqXyKweiWPqshIbBRU2w9UyeyTg3V
         AV6QKL7WtS4ckNdLuDLW+rn2qds0GPp9xu6OUe700tyVEnAZDnhZdC8brHyLanzctple
         ppuynt5hydRBzunlC/6yyNa1t6PeyUscC3ZRVUU/DaR5tJrjX+TRjb7uU2j6q4AGCoHO
         57FqnmPhEjfcHklVImf6QRWbmvWlDBqYJNe0KbK1tgGy9KLgnPiMU7+TtaAUanFLRfZN
         jkgQ==
X-Gm-Message-State: APjAAAUSd2nMgwdmFO1IBubrNUovuEJVhd7QGq6FailgS0YpwwPbUmbR
	bP4IAgsKIxamhCLyvC4sZ8o/OGE6hKNhK6Y62ahJbpmrDgC385zcwcr9qppfP/NhsWD+SiD+OXQ
	OzJaQBDQko4Xl/OKAAVrLhHjliSOg04Pg1qZHAPQAJOLFQpCxY9avwabqdumDL03Oyw==
X-Received: by 2002:a0c:87cd:: with SMTP id 13mr32231043qvk.218.1558332631474;
        Sun, 19 May 2019 23:10:31 -0700 (PDT)
X-Received: by 2002:a0c:87cd:: with SMTP id 13mr32230995qvk.218.1558332630559;
        Sun, 19 May 2019 23:10:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558332630; cv=none;
        d=google.com; s=arc-20160816;
        b=ZCmlTDWwTySE/ez8ALyKIgOZsEeZmF+0IFXe/lHxQkwUegstlnXW795QJVUyCov3Ff
         BLqFDB+2Pod5nrBYRL7CuIeLKsfScu2wk7oHWlx1qKSVpc4clQ54Hi3IlBIcLz/sxgEB
         184rhdMDLpaWv9r8Ie43SsvKw2Sc4mV7arbsT3VbY8jeNrEoTFFYI80p7cXzIrRSyPTi
         o8hVIju625hzk9dgbn4mRBFLlcuZKYfyIhCvav4OdzD9S28SztgnKOE5tfZRRl37/JuT
         hosQClN9IMGv6NsERwgiQ0cZ1JeHoOU42Hwns2HKf3DyCj+Ai2mXHXJdhgIs8O4yWLQ0
         QXFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NFukLdZ7lb89NEuXmBM0ev5FCwA/kWpf23+eFLzEIzc=;
        b=zTCk7nNMPT5ANdXyUBHN/UzWCGqY1pVSJqW/6vq9Rr79LQ4+nr0iG+ma7MwM9IPsJz
         U1spy8JDfDSmr7X+sg1ukXz9/0YTuKhKgluzG4CCk62t/aELsVJ+4xuXcEdrXjpZwQ4D
         7V2IEsKaeZdLkomaIcQtSo7jEqv+gxN7RfwNLZf/Ny0PvUXNI05E2air9VRiC9fG7WYN
         7Qt06KNgu9GOE7z4Lm0K2/gl7PhXqrmnDZXyT0ZS3fQDLZmjSQtvL2vIyB/0IK0Orp9j
         R30bDN2ZxZRGK9L+D406UPoAT32nbatcfFT/JJYfGq1WUOiNaIQsbzlub1BqDNdpAJjJ
         cj3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@googlemail.com header.s=20161025 header.b=Y0j6sgfc;
       spf=pass (google.com: domain of minipli@googlemail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minipli@googlemail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=googlemail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t130sor8892370qke.67.2019.05.19.23.10.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 19 May 2019 23:10:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of minipli@googlemail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@googlemail.com header.s=20161025 header.b=Y0j6sgfc;
       spf=pass (google.com: domain of minipli@googlemail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minipli@googlemail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=googlemail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=googlemail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NFukLdZ7lb89NEuXmBM0ev5FCwA/kWpf23+eFLzEIzc=;
        b=Y0j6sgfc8k9053lZUMt5CBFGP0kn69SC0iJEQW0SB6iNThpcQOmoG99zvBBpusukVZ
         qA4kSf3AQnhuJgAcUxy6UuCw21GAZA6aj4EBvN4bY3FVkGlSAfQE2ruxt+Kkl658PCqX
         MwZcFB/DwMSAmeq1+Nkcj/G40xH7lWYAslj7bLerr/3XAbdteF6FwjNgA3VWzkPGQ2IX
         s32DEctR+QFtSws0fK7dWAUspu83t0DVKiNxQcBcLTOc88uPJPzxwbY2HpO2URmzy/Bm
         /vrXXLx5jZ0hICGuwDA6cVtAeDAd7R3/V0KJ1YLrLnHNqidbInrrROqP1gBuCXqfziVK
         wzCg==
X-Google-Smtp-Source: APXvYqxhDBaw1gzS0+uR0z6oe2PI6vSPUSrFMeRAnod4ezCaN0wue1Ets49Z3HT+wJ4G1Ljd7FkZBW40qgfo4D/nd9s=
X-Received: by 2002:a05:620a:5ed:: with SMTP id z13mr20140322qkg.84.1558332630219;
 Sun, 19 May 2019 23:10:30 -0700 (PDT)
MIME-Version: 1.0
References: <20190514143537.10435-5-glider@google.com> <201905161746.16E885F@keescook>
In-Reply-To: <201905161746.16E885F@keescook>
From: Mathias Krause <minipli@googlemail.com>
Date: Mon, 20 May 2019 08:10:19 +0200
Message-ID: <CA+rthh9bLiohU78PBMonji_LPjj756rhTy22v9nL8LpL0cTb5g@mail.gmail.com>
Subject: Re: [PATCH 5/4] mm: Introduce SLAB_NO_FREE_INIT and mark excluded caches
To: Kees Cook <keescook@chromium.org>
Cc: Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Christoph Lameter <cl@linux.com>, kernel-hardening@lists.openwall.com, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, linux-mm@kvack.org, 
	linux-security-module@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Kees,

On Fri, 17 May 2019 at 02:50, Kees Cook <keescook@chromium.org> wrote:
> In order to improve the init_on_free performance, some frequently
> freed caches with less sensitive contents can be excluded from the
> init_on_free behavior.
>
> This patch is modified from Brad Spengler/PaX Team's code in the
> last public patch of grsecurity/PaX based on my understanding of the
> code. Changes or omissions from the original code are mine and don't
> reflect the original grsecurity/PaX code.

you might want to give secunet credit for this one, as can be seen here:

  https://github.com/minipli/linux-grsec/commit/309d494e7a3f6533ca68fc8b3bd89fa76fd2c2df

However, please keep the "Changes or omissions from the original
code..." part as your version slightly differs.

Thanks,
Mathias

>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  fs/buffer.c          | 2 +-
>  fs/dcache.c          | 3 ++-
>  include/linux/slab.h | 3 +++
>  kernel/fork.c        | 6 ++++--
>  mm/rmap.c            | 5 +++--
>  mm/slab.h            | 5 +++--
>  net/core/skbuff.c    | 6 ++++--
>  7 files changed, 20 insertions(+), 10 deletions(-)
>
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 0faa41fb4c88..04a85bd4cf2e 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -3457,7 +3457,7 @@ void __init buffer_init(void)
>         bh_cachep = kmem_cache_create("buffer_head",
>                         sizeof(struct buffer_head), 0,
>                                 (SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
> -                               SLAB_MEM_SPREAD),
> +                               SLAB_MEM_SPREAD|SLAB_NO_FREE_INIT),
>                                 NULL);
>
>         /*
> diff --git a/fs/dcache.c b/fs/dcache.c
> index 8136bda27a1f..323b039accba 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -3139,7 +3139,8 @@ void __init vfs_caches_init_early(void)
>  void __init vfs_caches_init(void)
>  {
>         names_cachep = kmem_cache_create_usercopy("names_cache", PATH_MAX, 0,
> -                       SLAB_HWCACHE_ALIGN|SLAB_PANIC, 0, PATH_MAX, NULL);
> +                       SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NO_FREE_INIT, 0,
> +                       PATH_MAX, NULL);
>
>         dcache_init();
>         inode_init();
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 9449b19c5f10..7eba9ad8830d 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -92,6 +92,9 @@
>  /* Avoid kmemleak tracing */
>  #define SLAB_NOLEAKTRACE       ((slab_flags_t __force)0x00800000U)
>
> +/* Exclude slab from zero-on-free when init_on_free is enabled */
> +#define SLAB_NO_FREE_INIT      ((slab_flags_t __force)0x01000000U)
> +
>  /* Fault injection mark */
>  #ifdef CONFIG_FAILSLAB
>  # define SLAB_FAILSLAB         ((slab_flags_t __force)0x02000000U)
> diff --git a/kernel/fork.c b/kernel/fork.c
> index b4cba953040a..9868585f5520 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -2550,11 +2550,13 @@ void __init proc_caches_init(void)
>
>         mm_cachep = kmem_cache_create_usercopy("mm_struct",
>                         mm_size, ARCH_MIN_MMSTRUCT_ALIGN,
> -                       SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT,
> +                       SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_ACCOUNT|
> +                       SLAB_NO_FREE_INIT,
>                         offsetof(struct mm_struct, saved_auxv),
>                         sizeof_field(struct mm_struct, saved_auxv),
>                         NULL);
> -       vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC|SLAB_ACCOUNT);
> +       vm_area_cachep = KMEM_CACHE(vm_area_struct, SLAB_PANIC|SLAB_ACCOUNT|
> +                                                   SLAB_NO_FREE_INIT);
>         mmap_init();
>         nsproxy_cache_init();
>  }
> diff --git a/mm/rmap.c b/mm/rmap.c
> index e5dfe2ae6b0d..b7b8013eeb0a 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -432,10 +432,11 @@ static void anon_vma_ctor(void *data)
>  void __init anon_vma_init(void)
>  {
>         anon_vma_cachep = kmem_cache_create("anon_vma", sizeof(struct anon_vma),
> -                       0, SLAB_TYPESAFE_BY_RCU|SLAB_PANIC|SLAB_ACCOUNT,
> +                       0, SLAB_TYPESAFE_BY_RCU|SLAB_PANIC|SLAB_ACCOUNT|
> +                       SLAB_NO_FREE_INIT,
>                         anon_vma_ctor);
>         anon_vma_chain_cachep = KMEM_CACHE(anon_vma_chain,
> -                       SLAB_PANIC|SLAB_ACCOUNT);
> +                       SLAB_PANIC|SLAB_ACCOUNT|SLAB_NO_FREE_INIT);
>  }
>
>  /*
> diff --git a/mm/slab.h b/mm/slab.h
> index 24ae887359b8..f95b4f03c57b 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -129,7 +129,8 @@ static inline slab_flags_t kmem_cache_flags(unsigned int object_size,
>  /* Legal flag mask for kmem_cache_create(), for various configurations */
>  #define SLAB_CORE_FLAGS (SLAB_HWCACHE_ALIGN | SLAB_CACHE_DMA | \
>                          SLAB_CACHE_DMA32 | SLAB_PANIC | \
> -                        SLAB_TYPESAFE_BY_RCU | SLAB_DEBUG_OBJECTS )
> +                        SLAB_TYPESAFE_BY_RCU | SLAB_DEBUG_OBJECTS | \
> +                        SLAB_NO_FREE_INIT)
>
>  #if defined(CONFIG_DEBUG_SLAB)
>  #define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
> @@ -535,7 +536,7 @@ static inline bool slab_want_init_on_alloc(gfp_t flags, struct kmem_cache *c)
>  static inline bool slab_want_init_on_free(struct kmem_cache *c)
>  {
>         if (static_branch_unlikely(&init_on_free))
> -               return !(c->ctor);
> +               return !(c->ctor) && ((c->flags & SLAB_NO_FREE_INIT) == 0);
>         else
>                 return false;
>  }
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index e89be6282693..b65902d2c042 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3981,14 +3981,16 @@ void __init skb_init(void)
>         skbuff_head_cache = kmem_cache_create_usercopy("skbuff_head_cache",
>                                               sizeof(struct sk_buff),
>                                               0,
> -                                             SLAB_HWCACHE_ALIGN|SLAB_PANIC,
> +                                             SLAB_HWCACHE_ALIGN|SLAB_PANIC|
> +                                             SLAB_NO_FREE_INIT,
>                                               offsetof(struct sk_buff, cb),
>                                               sizeof_field(struct sk_buff, cb),
>                                               NULL);
>         skbuff_fclone_cache = kmem_cache_create("skbuff_fclone_cache",
>                                                 sizeof(struct sk_buff_fclones),
>                                                 0,
> -                                               SLAB_HWCACHE_ALIGN|SLAB_PANIC,
> +                                               SLAB_HWCACHE_ALIGN|SLAB_PANIC|
> +                                               SLAB_NO_FREE_INIT,
>                                                 NULL);
>         skb_extensions_init();
>  }
> --
> 2.17.1
>
>
> --
> Kees Cook

