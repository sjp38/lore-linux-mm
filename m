Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16FCDC282E1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 19:11:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A183421773
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 19:11:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="JwagZLYu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A183421773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24F576B0003; Tue, 23 Apr 2019 15:11:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FF0F6B0005; Tue, 23 Apr 2019 15:11:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F1146B0007; Tue, 23 Apr 2019 15:11:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id D94B76B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 15:11:25 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id v4so7407614vka.10
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:11:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qHtt5m+l+HCxm2/aQ3CiCdm/qRf6FDQPPHURcC67FHo=;
        b=GMJ4qMxglh34BAwrYXFMgmaiN1TyRIDTerccFweerxCfl5RiuxSjkyz7kr/lovT/Y4
         1vbSL1VpcxCIuUUr4g+SA0xWQf7eyq1IpbwX3VqrSb2nCeLewr3mLLm3kRkxoNQVdWA2
         RRlojvhehRWB4a+xaxqCYmGgHz9dJErKuKQIn+CSsvpXLMDVLomVVDN647ie7ls6rjBr
         uA7qbgER1iLTKBKKarnOyo+ehyVjHebqoO6jWTILskLwwRWX9A4llUl0nMzU9RHYgZpO
         Q+y4w9OUxBqQoq1dQ2zIWQLX1LpDhFe8QQa8qFzRaZyG2FsRwLo5Yj6jv3l25vhWwRoW
         0+qA==
X-Gm-Message-State: APjAAAW3hy1a8ib3inS5plrPtdNIKNqTHySPgLn0O9aky818GdSmJnEQ
	EiEqr0HRHL7408A9IheWWO28eCddPSbQZlys7cCRSoMhd0tASaIX2kXRNRspLjw+H5FWRO34bVS
	hcQUxYvRoWvbvnQuGT3hWS2EoePTm6MLnIpEy1ehB0xTkWYvxMMsMmx+YoHCVONILlA==
X-Received: by 2002:a1f:2fc7:: with SMTP id v190mr14224427vkv.84.1556046685464;
        Tue, 23 Apr 2019 12:11:25 -0700 (PDT)
X-Received: by 2002:a1f:2fc7:: with SMTP id v190mr14224381vkv.84.1556046684693;
        Tue, 23 Apr 2019 12:11:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556046684; cv=none;
        d=google.com; s=arc-20160816;
        b=07BdlauIAzp9swekeKz/5vTSACAvl1cMH+i8tCf+Hykimub9ae6aoKauwohGHG82jS
         F/FpKB2pZd1qaXxMQCQvLX6mg29TdLmFfveyV2Pxmnp+1X3fVybQEZ3Hmy1gzopCDCaj
         FQogjYHpBkl3kDWm6IwyyV4qyW8JUIdm6/gWf6uJICxfzhkOh5oAsZAGTfGVpVY4simo
         uTvNq8v9ZxP+6SuCAfcEDkZNthOPvynCECGNtWnLoMyEve7VLzrfZRPcxa6fXFAx4OpO
         6imNNnYrrswOgAC+F2zAvv1FQeorfsyTGeUm5S++27ibDjx4zh2syh/scCmTxPm0hQR6
         egOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qHtt5m+l+HCxm2/aQ3CiCdm/qRf6FDQPPHURcC67FHo=;
        b=iIXmDbPh1OpU7AD0SgnKuHCxoa/Ef49TxgsnxXxxD7ghkttX1mGNj8SHMOqFsAoTeC
         DKCwhRMfkd80IZyOhi5H04ohNTfMMToqOsFdt6QAsxt4dYaE0CG5b5r7RaXNmBc92ipi
         6yrWck/6DHvYSzrgIxY3WSgLMIJnOTsfRntV/vFvUipFniayarSRrZy5flyINxCSZogU
         RbHhYDGJSGGQHcLr9bu7/AK1Rk6QDmVIO+L/Wnwj1JWE1jF/A74ewZVk8ySOfNI2Px1w
         K9UPo9m08lw3uE7RcpdUgceZmOch5iDA3FgSUzGBaWeYjIOqosqwae6KQyU6sXsXESHN
         TGmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=JwagZLYu;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p8sor8850092vsc.101.2019.04.23.12.11.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 12:11:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=JwagZLYu;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qHtt5m+l+HCxm2/aQ3CiCdm/qRf6FDQPPHURcC67FHo=;
        b=JwagZLYuUJZLwQj169iGPTDtVDfEsTyhf4LGF838jLBuKkjd4b/5k6dh6osH1hBA/G
         KXBt4JKuqlV4PmpQLbsBbCB8IU0jaQ3Fu9nZ5iLMnzb4Jjk5yiMotnrtn4zJWcERR4co
         AiNIc4sN9Pv+o/DIENIkK3b+C56hA5e9QydZg=
X-Google-Smtp-Source: APXvYqxGbaAQEvsI1L48ZOkTU43btKS7tdMX13/MIptveLaFvITCVvelQpnF8LRezWVrwOKMS+trww==
X-Received: by 2002:a67:f753:: with SMTP id w19mr14880182vso.27.1556046683734;
        Tue, 23 Apr 2019 12:11:23 -0700 (PDT)
Received: from mail-vs1-f47.google.com (mail-vs1-f47.google.com. [209.85.217.47])
        by smtp.gmail.com with ESMTPSA id y1sm8343936uai.0.2019.04.23.12.11.22
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 12:11:22 -0700 (PDT)
Received: by mail-vs1-f47.google.com with SMTP id n17so641210vsr.1
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:11:22 -0700 (PDT)
X-Received: by 2002:a67:f849:: with SMTP id b9mr14352168vsp.188.1556046682180;
 Tue, 23 Apr 2019 12:11:22 -0700 (PDT)
MIME-Version: 1.0
References: <20190418154208.131118-1-glider@google.com> <20190418154208.131118-3-glider@google.com>
In-Reply-To: <20190418154208.131118-3-glider@google.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 23 Apr 2019 12:11:09 -0700
X-Gmail-Original-Message-ID: <CAGXu5jJ0EKVjKHFJETP+YnRPuT_Gr=ozXYU6sgak26BBCAEp7A@mail.gmail.com>
Message-ID: <CAGXu5jJ0EKVjKHFJETP+YnRPuT_Gr=ozXYU6sgak26BBCAEp7A@mail.gmail.com>
Subject: Re: [PATCH 2/3] gfp: mm: introduce __GFP_NOINIT
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 8:42 AM Alexander Potapenko <glider@google.com> wrote:
>
> When passed to an allocator (either pagealloc or SL[AOU]B), __GFP_NOINIT
> tells it to not initialize the requested memory if the init_allocations
> boot option is enabled. This can be useful in the cases the newly
> allocated memory is going to be initialized by the caller right away.

Maybe add "... as seen when the slab allocator needs to allocate new
pages from the page allocator." just to help clarify it here (instead
of from the end of the commit log where you mention it offhand).

>
> __GFP_NOINIT basically defeats the hardening against information leaks
> provided by the init_allocations feature, so one should use it with
> caution.
>
> This patch also adds __GFP_NOINIT to alloc_pages() calls in SL[AOU]B.
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
> Cc: Qian Cai <cai@lca.pw>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: linux-mm@kvack.org
> Cc: linux-security-module@vger.kernel.org
> Cc: kernel-hardening@lists.openwall.com
> ---
>  include/linux/gfp.h | 6 +++++-
>  include/linux/mm.h  | 2 +-
>  kernel/kexec_core.c | 2 +-
>  mm/slab.c           | 2 +-
>  mm/slob.c           | 1 +
>  mm/slub.c           | 1 +
>  6 files changed, 10 insertions(+), 4 deletions(-)
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
>  /* If the above are modified, __GFP_BITS_SHIFT may need updating */

I think you want to add NOINIT below GFP_ACCOUNT, update NOLOCKDEP and
then adjust GFP_BITS_SHIFT differently, noted below.

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

This should just be 24 + ...   with the bit field added above NOLOCKDEP.

>  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
>
>  /**
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index b38b71a5efaa..8f03334a9033 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2601,7 +2601,7 @@ DECLARE_STATIC_KEY_FALSE(init_allocations);
>  static inline bool want_init_memory(gfp_t flags)
>  {
>         if (static_branch_unlikely(&init_allocations))
> -               return true;
> +               return !(flags & __GFP_NOINIT);
>         return flags & __GFP_ZERO;
>  }

You need to test for GFP_ZERO here too: return ((flags & __GFP_NOINIT
| __GFP_ZERO) == 0)

Also, I wonder, for the sake of readability, if this should be named
__GFP_NO_AUTOINIT ?

I'd also like to see each use of __GFP_NOINIT include a comment above
its use where the logic is explained for _why_ it's safe (or
reasonable) to use __GFP_NOINIT in each place.

>
> diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> index be84f5f95c97..f9d1f1236cd0 100644
> --- a/kernel/kexec_core.c
> +++ b/kernel/kexec_core.c
> @@ -302,7 +302,7 @@ static struct page *kimage_alloc_pages(gfp_t gfp_mask, unsigned int order)
>  {
>         struct page *pages;
>
> -       pages = alloc_pages(gfp_mask & ~__GFP_ZERO, order);
> +       pages = alloc_pages((gfp_mask & ~__GFP_ZERO) | __GFP_NOINIT, order);
>         if (pages) {
>                 unsigned int count, i;
>
> diff --git a/mm/slab.c b/mm/slab.c
> index dcc5b73cf767..762cb0e7bcc1 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1393,7 +1393,7 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
>         struct page *page;
>         int nr_pages;
>
> -       flags |= cachep->allocflags;
> +       flags |= (cachep->allocflags | __GFP_NOINIT);
>
>         page = __alloc_pages_node(nodeid, flags, cachep->gfporder);
>         if (!page) {
> diff --git a/mm/slob.c b/mm/slob.c
> index 18981a71e962..867d2d68a693 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -192,6 +192,7 @@ static void *slob_new_pages(gfp_t gfp, int order, int node)
>  {
>         void *page;
>
> +       gfp |= __GFP_NOINIT;
>  #ifdef CONFIG_NUMA
>         if (node != NUMA_NO_NODE)
>                 page = __alloc_pages_node(node, gfp, order);
> diff --git a/mm/slub.c b/mm/slub.c
> index e4efb6575510..a79b4cb768a2 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1493,6 +1493,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,

What about kmalloc_large_node()?

>         struct page *page;
>         unsigned int order = oo_order(oo);
>
> +       flags |= __GFP_NOINIT;
>         if (node == NUMA_NO_NODE)
>                 page = alloc_pages(flags, order);
>         else

And just so I make sure I'm understanding this correctly: __GFP_NOINIT
is passed to the page allocator because we know each allocation from
the slab will get initialized at "sub allocation" time.

Looks good!

-- 
Kees Cook

