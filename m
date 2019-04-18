Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63C76C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:28:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1332221850
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 05:28:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="ZOmVLE2k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1332221850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 621076B0008; Thu, 18 Apr 2019 01:28:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D13B6B000A; Thu, 18 Apr 2019 01:28:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 49BA66B000C; Thu, 18 Apr 2019 01:28:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 234EE6B0008
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 01:28:52 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id r132so424584vke.21
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:28:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=IcA/uYI8DV5Uk3TdhA5fHXy0czTBgFSx6RCoxfz+//4=;
        b=BsUhSTw5l3Rvxx9bBKmqUgYemUP5dl7ZDyhtbyRDsztdVL3LDfDnAmco8b5vZt8Byh
         4YekSjHIo0wz70o78wanhgEcdVcRtCWBpzmMt5QGDNHhU61JLsNZOhIUZY5wkfym4OpK
         QeYMysUVC1wXwnUTqFNBu4NKSG3b03N9DzaMEGuJPXiar2LPFiG5gHpwY8kS1jm/USob
         MYJYMJ4KOf/x+8tcKhg8V/4IAMxxf7mOq8cDDDmsTjuXbo4HV8zQrH9CCA0/aQUQ19Dr
         W+PAdYkhOXBLmRJqZ0dWfXIU4qJVPdNHFiY3Wh0DmlPjhffD2KuFhT+KfVgIWhHx4tGr
         ueUg==
X-Gm-Message-State: APjAAAW9MvNbkzB2u65uVeo8r1VsJ9ksPfEUSFqsanil9PooeEo5nvWW
	4UhpM/194Pnq0SUI+1bVyeP8FVZxuOMehkDHTsNc6M5OD/4ovKaSqNaUmtQe1yz6hnuqSWhRFPT
	5aWf8Dlb9AFm3BPSE1jsBpIXwqv4nuzC2VJ4WIgH2OIGItRYu0VgrcKdKAo/4Shuc5A==
X-Received: by 2002:a1f:97ce:: with SMTP id z197mr39449840vkd.58.1555565331891;
        Wed, 17 Apr 2019 22:28:51 -0700 (PDT)
X-Received: by 2002:a1f:97ce:: with SMTP id z197mr39449827vkd.58.1555565331239;
        Wed, 17 Apr 2019 22:28:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555565331; cv=none;
        d=google.com; s=arc-20160816;
        b=e0IHSxpop5HEj/Q+BuinlhdXYZkwJCYbUpmd8Ew5ZWyeklq444CTFE+u/TIrpjR4+y
         dE60uiRohyyiGCH1m6mfu7kFuiE4TdDGf53AcysxqxvvsSXWvFIk13ajV45By6AUT82x
         /1FVNiIqHNPoyR/b3oIuFMVCb21qbKavPuzSKQEQ2JsS3qoaNVdrWmGBP/yO6sICw6Oc
         +biO016Kx3o658LsiHvJYjaxlThLoy3ExXxMfQQqNkqpD6FohGg62uby+ZLlJxcPb2rj
         Ne9jW14HjIAVObV9DXv5CaJZ7suonLxfu0zQpoy7mfimfsqdcKFjGV9dWpAOWJGufJ3s
         EiCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IcA/uYI8DV5Uk3TdhA5fHXy0czTBgFSx6RCoxfz+//4=;
        b=OGbFhno+zNqL6Psxl3kONAuGi1E5VftS5aqrykpGFFbF//G851G+r2a9Fp++9GNUoO
         v6WN1jqKKX6XjNNuRTiguHJPQBl9F7xReL3ZRvl+rEnt8tIvUlohP52H3aJoZEYD9+1x
         ndt1kOWZSXQSKp3cPu79ohq9xPKQCO9yl3DTcv2mfMB+Odqvw7Ky8fv+1wKuYej76Bzn
         5eFEnNlthiQWZZGcLplUqT5DkzIMOfrD13Agrced/XH3RqRc7/l188nD0aWoQDIktNHt
         KUpy75jzRX60rN3ARus0a8+5S26M6X7aK3diUnS+0u3htAigZ9YirsJCvIM/8CacBcsr
         4Lzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=ZOmVLE2k;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k19sor385060vsq.17.2019.04.17.22.28.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 22:28:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=ZOmVLE2k;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IcA/uYI8DV5Uk3TdhA5fHXy0czTBgFSx6RCoxfz+//4=;
        b=ZOmVLE2kWQEfxAwJtqNT7fptm5m89yjN9pJ4hwhI4Z8f49vkIG1SsNzihNlPHXzko1
         XXEV3xLUvXrMTYVGVNWYLrrCC0hIAZCueqmowWDl/0KTMFCsqx1U+m/G2nteU8eiooyN
         6sDfWAdWlsvCPZQuCGxF8OqTfh2ZEPtoetyBA=
X-Google-Smtp-Source: APXvYqzyc2psRVJF7YGPd3/2RhnXCD/0vo70xlO9iLXiWrYBRX4zryhsx3LPdbKLbljT4/ihly9F2g==
X-Received: by 2002:a67:eeda:: with SMTP id o26mr52897586vsp.209.1555565330674;
        Wed, 17 Apr 2019 22:28:50 -0700 (PDT)
Received: from mail-ua1-f45.google.com (mail-ua1-f45.google.com. [209.85.222.45])
        by smtp.gmail.com with ESMTPSA id j93sm252317uad.6.2019.04.17.22.28.49
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 22:28:50 -0700 (PDT)
Received: by mail-ua1-f45.google.com with SMTP id h4so374546uaj.9
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 22:28:49 -0700 (PDT)
X-Received: by 2002:a9f:3fce:: with SMTP id m14mr49582984uaj.96.1555564855818;
 Wed, 17 Apr 2019 22:20:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190417052247.17809-1-alex@ghiti.fr> <20190417052247.17809-2-alex@ghiti.fr>
In-Reply-To: <20190417052247.17809-2-alex@ghiti.fr>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 18 Apr 2019 00:20:44 -0500
X-Gmail-Original-Message-ID: <CAGXu5jKuOaGtb0S++_xpS=sxPLFwFqSgaecWae5iJ8f8eaQzDA@mail.gmail.com>
Message-ID: <CAGXu5jKuOaGtb0S++_xpS=sxPLFwFqSgaecWae5iJ8f8eaQzDA@mail.gmail.com>
Subject: Re: [PATCH v3 01/11] mm, fs: Move randomize_stack_top from fs to mm
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

On Wed, Apr 17, 2019 at 12:24 AM Alexandre Ghiti <alex@ghiti.fr> wrote:
>
> This preparatory commit moves this function so that further introduction
> of generic topdown mmap layout is contained only in mm/util.c.
>
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/binfmt_elf.c    | 20 --------------------
>  include/linux/mm.h |  2 ++
>  mm/util.c          | 22 ++++++++++++++++++++++
>  3 files changed, 24 insertions(+), 20 deletions(-)
>
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index 7d09d125f148..045f3b29d264 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -662,26 +662,6 @@ static unsigned long load_elf_interp(struct elfhdr *interp_elf_ex,
>   * libraries.  There is no binary dependent code anywhere else.
>   */
>
> -#ifndef STACK_RND_MASK
> -#define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))    /* 8MB of VA */
> -#endif
> -
> -static unsigned long randomize_stack_top(unsigned long stack_top)
> -{
> -       unsigned long random_variable = 0;
> -
> -       if (current->flags & PF_RANDOMIZE) {
> -               random_variable = get_random_long();
> -               random_variable &= STACK_RND_MASK;
> -               random_variable <<= PAGE_SHIFT;
> -       }
> -#ifdef CONFIG_STACK_GROWSUP
> -       return PAGE_ALIGN(stack_top) + random_variable;
> -#else
> -       return PAGE_ALIGN(stack_top) - random_variable;
> -#endif
> -}
> -
>  static int load_elf_binary(struct linux_binprm *bprm)
>  {
>         struct file *interpreter = NULL; /* to shut gcc up */
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 76769749b5a5..087824a5059f 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2312,6 +2312,8 @@ extern int install_special_mapping(struct mm_struct *mm,
>                                    unsigned long addr, unsigned long len,
>                                    unsigned long flags, struct page **pages);
>
> +unsigned long randomize_stack_top(unsigned long stack_top);
> +
>  extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
>
>  extern unsigned long mmap_region(struct file *file, unsigned long addr,
> diff --git a/mm/util.c b/mm/util.c
> index d559bde497a9..a54afb9b4faa 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -14,6 +14,8 @@
>  #include <linux/hugetlb.h>
>  #include <linux/vmalloc.h>
>  #include <linux/userfaultfd_k.h>
> +#include <linux/elf.h>
> +#include <linux/random.h>
>
>  #include <linux/uaccess.h>
>
> @@ -291,6 +293,26 @@ int vma_is_stack_for_current(struct vm_area_struct *vma)
>         return (vma->vm_start <= KSTK_ESP(t) && vma->vm_end >= KSTK_ESP(t));
>  }
>
> +#ifndef STACK_RND_MASK
> +#define STACK_RND_MASK (0x7ff >> (PAGE_SHIFT - 12))     /* 8MB of VA */
> +#endif

Oh right, here's the generic one... this should probably just copy
arm64's version instead. Then x86 can be tweaked (it uses
mmap_is_ia32() instead of is_compat_task() by default, but has a weird
override..)

Regardless, yes, this is a direct code move:

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

> +
> +unsigned long randomize_stack_top(unsigned long stack_top)
> +{
> +       unsigned long random_variable = 0;
> +
> +       if (current->flags & PF_RANDOMIZE) {
> +               random_variable = get_random_long();
> +               random_variable &= STACK_RND_MASK;
> +               random_variable <<= PAGE_SHIFT;
> +       }
> +#ifdef CONFIG_STACK_GROWSUP
> +       return PAGE_ALIGN(stack_top) + random_variable;
> +#else
> +       return PAGE_ALIGN(stack_top) - random_variable;
> +#endif
> +}
> +
>  #if defined(CONFIG_MMU) && !defined(HAVE_ARCH_PICK_MMAP_LAYOUT)
>  void arch_pick_mmap_layout(struct mm_struct *mm, struct rlimit *rlim_stack)
>  {
> --
> 2.20.1
>


-- 
Kees Cook

