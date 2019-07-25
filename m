Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD66EC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 07:49:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 874CB2081B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 07:49:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="me1VA4L7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 874CB2081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 358148E0049; Thu, 25 Jul 2019 03:49:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 308408E0031; Thu, 25 Jul 2019 03:49:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21E3D8E0049; Thu, 25 Jul 2019 03:49:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 031738E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 03:49:19 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id h3so54032323iob.20
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 00:49:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Qp7FSL4EbzUxBEDwMYPtrsBZkkKZuOBCnuu+iYXPJvI=;
        b=VwUFajInpJcnyj7DC8+92gAHhCom5ESW8Xoo7OT+eYkNkf7I+CBOgowRHQd3XU5USm
         zZ+bCT/7u5EgGu+COdYA8ouYsgjZMCDOjZeldsacPpKA1gyAm2Pzm1rg770CO7aJzq04
         s3igpt9BKBVQyPS8mYVwzYq5oon+r/Qt8hvQl2X+PvXx2eNqZGavkPBs8OT/slYFt0Wx
         7YibXdVEJn0MuBZ/wux+sZPf6jMPkphug1ZuUj2XULjhkWITjvUV9BtjMMzMcUbnqGYc
         Z/9QbcezcISBHyCvJ4vOzmKjlrR18mcWf7mz+cGfjmrjfgjrkbTpAG32gFYUZPHBT3Cc
         gBFQ==
X-Gm-Message-State: APjAAAWAccLx81PFwer6GFBZq2IH6dZzJ5ZunkGXvOW2njw5JAAArJob
	YRra5tbUWQhDIe5YLt6jl5TBmbvyGomxq9jQBwozYTeqR3i7wLiLSqCT/KZiCwYizacvp7Lp6z6
	9SnHhnmN8YCq7MYnv73B4FqX0r+qdRMmVxkTzO6QTUYSQvTKNUCW/+iKWOiiYSnKzZQ==
X-Received: by 2002:a02:b883:: with SMTP id p3mr16910912jam.79.1564040958755;
        Thu, 25 Jul 2019 00:49:18 -0700 (PDT)
X-Received: by 2002:a02:b883:: with SMTP id p3mr16910885jam.79.1564040958073;
        Thu, 25 Jul 2019 00:49:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564040958; cv=none;
        d=google.com; s=arc-20160816;
        b=0hr9xoNWgnTEP32UTFN4eZuFXeqM+2bo32gkNuHHWxAVC1f+IBIf+UOha2xrLF1n+i
         CplzHsAeedqNXWX+3ystOqGPSt+gP3YYbAeBAZf9822b0UF6CODiP0qfin8OdiOy+7oR
         KVf1xHQ9MXgROHEVzJkh7V00Knj57GgRgmy0sM2v3s82hhjUIDozE8y7rYRJ8/dVUs/M
         xNxfvKypJV8CH2HHSHmIMIRhFy6zaxvZCmJoEV49pGxwEHSf8TpE6/7JAfCCVQzeyxkg
         s9U5z/MHbFr/JMywkQtpZbHlj9/hip6/joByUxwEeRZmtR500/mkTNt+uxrX8dGXxbaO
         1jMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Qp7FSL4EbzUxBEDwMYPtrsBZkkKZuOBCnuu+iYXPJvI=;
        b=p+Y8jkRqaoKaCmogTKCZvzSgGKGcm0j3J4/tJYE/bmjSVjFEqNupVOudgeO3VD83vr
         gsrLVY9ka+2yXZmsI9vo5+FMoCdEPflZSerKhOqdEm+pNryJDl/ffAly4FcUn4pyU7na
         n10w6MbIwPWsZhJ6h45nPMS9lR6tM+DUcUi+IwQRbWrQ6LLVdiQ422CXQpJzFe+cFHVx
         DyAuGqq10iW1JOA1ykWypkX4o9kidLJxN/o4kkJXmOZswxTr6fRw5cVWMFZx4O621CDx
         kF0tqZgwrtr9uXU2l8JmhtuW6c/7ry9p5WTpNJwQfighSL1W+1yth6hcrTE8javLMhl4
         aIGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=me1VA4L7;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c65sor33452601iof.59.2019.07.25.00.49.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 00:49:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=me1VA4L7;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Qp7FSL4EbzUxBEDwMYPtrsBZkkKZuOBCnuu+iYXPJvI=;
        b=me1VA4L71NRifRQeDLVn3K7fUPWCvBqCZsmA6QX3/n5VlFu114JQqtk5p+lLdvLY2i
         mqYvCoxji76M1Xb6wUJR04Oh0CxcE/wovWbWeycOrpECSGnKwe52wCGGkTV0GGvXNZX8
         FM8A7/cn4kYCXNYFDRuX29eFsfeJot+XCH54GtazGYKYcQyNjmOEFIis9N7nNojvf/mP
         AV4O624Jnl11LyAbnszk2TGuxN3OIcH7LVVZH5EGocVhD9cBMbx1B+6uJIYy0zUPER5p
         QVEzBxp4Cnz0R8GHJazd6GMDUZjKdH3BGpydp+uY+61dL3rd/6rWi+bhxmQwaP/uiBJQ
         DmFw==
X-Google-Smtp-Source: APXvYqzRLVNm6HB1+JXJjoQP/Y8DI03/H8ikz+chkn66ADv29410NgDoruB8lGT2kC83dblKjEhrfF64bQrTHC1gXMo=
X-Received: by 2002:a6b:641a:: with SMTP id t26mr35303516iog.3.1564040957221;
 Thu, 25 Jul 2019 00:49:17 -0700 (PDT)
MIME-Version: 1.0
References: <20190725055503.19507-1-dja@axtens.net> <20190725055503.19507-4-dja@axtens.net>
In-Reply-To: <20190725055503.19507-4-dja@axtens.net>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 25 Jul 2019 09:49:06 +0200
Message-ID: <CACT4Y+aOvGqJEE5Mzqxusd2+hyX1OUEAFjJTvVED6ujgsASYrQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] x86/kasan: support KASAN_VMALLOC
To: Daniel Axtens <dja@axtens.net>
Cc: kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 7:55 AM Daniel Axtens <dja@axtens.net> wrote:
>
> In the case where KASAN directly allocates memory to back vmalloc
> space, don't map the early shadow page over it.
>
> Not mapping the early shadow page over the whole shadow space means
> that there are some pgds that are not populated on boot. Allow the
> vmalloc fault handler to also fault in vmalloc shadow as needed.
>
> Signed-off-by: Daniel Axtens <dja@axtens.net>


Would it make things simpler if we pre-populate the top level page
tables for the whole vmalloc region? That would be
(16<<40)/4096/512/512*8 = 131072 bytes?
The check in vmalloc_fault in not really a big burden, so I am not
sure. Just brining as an option.

Acked-by: Dmitry Vyukov <dvyukov@google.com>

> ---
>  arch/x86/Kconfig            |  1 +
>  arch/x86/mm/fault.c         | 13 +++++++++++++
>  arch/x86/mm/kasan_init_64.c | 10 ++++++++++
>  3 files changed, 24 insertions(+)
>
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 222855cc0158..40562cc3771f 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -134,6 +134,7 @@ config X86
>         select HAVE_ARCH_JUMP_LABEL
>         select HAVE_ARCH_JUMP_LABEL_RELATIVE
>         select HAVE_ARCH_KASAN                  if X86_64
> +       select HAVE_ARCH_KASAN_VMALLOC          if X86_64
>         select HAVE_ARCH_KGDB
>         select HAVE_ARCH_MMAP_RND_BITS          if MMU
>         select HAVE_ARCH_MMAP_RND_COMPAT_BITS   if MMU && COMPAT
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 6c46095cd0d9..d722230121c3 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -340,8 +340,21 @@ static noinline int vmalloc_fault(unsigned long address)
>         pte_t *pte;
>
>         /* Make sure we are in vmalloc area: */
> +#ifndef CONFIG_KASAN_VMALLOC
>         if (!(address >= VMALLOC_START && address < VMALLOC_END))
>                 return -1;
> +#else
> +       /*
> +        * Some of the shadow mapping for the vmalloc area lives outside the
> +        * pgds populated by kasan init. They are created dynamically and so
> +        * we may need to fault them in.
> +        *
> +        * You can observe this with test_vmalloc's align_shift_alloc_test
> +        */
> +       if (!((address >= VMALLOC_START && address < VMALLOC_END) ||
> +             (address >= KASAN_SHADOW_START && address < KASAN_SHADOW_END)))
> +               return -1;
> +#endif
>
>         /*
>          * Copy kernel mappings over when needed. This can also
> diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
> index 296da58f3013..e2fe1c1b805c 100644
> --- a/arch/x86/mm/kasan_init_64.c
> +++ b/arch/x86/mm/kasan_init_64.c
> @@ -352,9 +352,19 @@ void __init kasan_init(void)
>         shadow_cpu_entry_end = (void *)round_up(
>                         (unsigned long)shadow_cpu_entry_end, PAGE_SIZE);
>
> +       /*
> +        * If we're in full vmalloc mode, don't back vmalloc space with early
> +        * shadow pages.
> +        */
> +#ifdef CONFIG_KASAN_VMALLOC
> +       kasan_populate_early_shadow(
> +               kasan_mem_to_shadow((void *)VMALLOC_END+1),
> +               shadow_cpu_entry_begin);
> +#else
>         kasan_populate_early_shadow(
>                 kasan_mem_to_shadow((void *)PAGE_OFFSET + MAXMEM),
>                 shadow_cpu_entry_begin);
> +#endif
>
>         kasan_populate_shadow((unsigned long)shadow_cpu_entry_begin,
>                               (unsigned long)shadow_cpu_entry_end, 0);
> --
> 2.20.1
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20190725055503.19507-4-dja%40axtens.net.

