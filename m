Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id F313A8E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 04:35:05 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id s5so19299078iom.22
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 01:35:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z4sor47489318iol.132.2019.01.14.01.35.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 01:35:04 -0800 (PST)
MIME-Version: 1.0
References: <cover.1547289808.git.christophe.leroy@c-s.fr> <0c854dd6b110ac2b81ef1681f6e097f59f84af8b.1547289808.git.christophe.leroy@c-s.fr>
In-Reply-To: <0c854dd6b110ac2b81ef1681f6e097f59f84af8b.1547289808.git.christophe.leroy@c-s.fr>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 14 Jan 2019 10:34:52 +0100
Message-ID: <CACT4Y+aEsLWqhJmXETNsGtKdbfHDFL1NF8ofv3KwvQPraXdFyw@mail.gmail.com>
Subject: Re: [PATCH v3 1/3] powerpc/mm: prepare kernel for KAsan on PPC32
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, LKML <linux-kernel@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>

On Sat, Jan 12, 2019 at 12:16 PM Christophe Leroy
<christophe.leroy@c-s.fr> wrote:
&gt;
&gt; In kernel/cputable.c, explicitly use memcpy() in order
&gt; to allow GCC to replace it with __memcpy() when KASAN is
&gt; selected.
&gt;
&gt; Since commit 400c47d81ca38 ("powerpc32: memset: only use dcbz once cache is
&gt; enabled"), memset() can be used before activation of the cache,
&gt; so no need to use memset_io() for zeroing the BSS.
&gt;
&gt; Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
&gt; ---
&gt;  arch/powerpc/kernel/cputable.c | 4 ++--
&gt;  arch/powerpc/kernel/setup_32.c | 6 ++----
&gt;  2 files changed, 4 insertions(+), 6 deletions(-)
&gt;
&gt; diff --git a/arch/powerpc/kernel/cputable.c
b/arch/powerpc/kernel/cputable.c
&gt; index 1eab54bc6ee9..84814c8d1bcb 100644
&gt; --- a/arch/powerpc/kernel/cputable.c
&gt; +++ b/arch/powerpc/kernel/cputable.c
&gt; @@ -2147,7 +2147,7 @@ void __init set_cur_cpu_spec(struct cpu_spec *s)
&gt;         struct cpu_spec *t = &amp;the_cpu_spec;
&gt;
&gt;         t = PTRRELOC(t);
&gt; -       *t = *s;
&gt; +       memcpy(t, s, sizeof(*t));

Hi Christophe,

I understand why you are doing this, but this looks a bit fragile and
non-scalable. This may not work with the next version of compiler,
just different than yours version of compiler, clang, etc.

Does using -ffreestanding and/or -fno-builtin-memcpy (-memset) help?
If it helps, perhaps it makes sense to add these flags to
KASAN_SANITIZE := n files.


>         *PTRRELOC(&cur_cpu_spec) = &the_cpu_spec;
>  }
> @@ -2162,7 +2162,7 @@ static struct cpu_spec * __init setup_cpu_spec(unsigned long offset,
>         old = *t;
>
>         /* Copy everything, then do fixups */
> -       *t = *s;
> +       memcpy(t, s, sizeof(*t));
>
>         /*
>          * If we are overriding a previous value derived from the real
> diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
> index 947f904688b0..5e761eb16a6d 100644
> --- a/arch/powerpc/kernel/setup_32.c
> +++ b/arch/powerpc/kernel/setup_32.c
> @@ -73,10 +73,8 @@ notrace unsigned long __init early_init(unsigned long dt_ptr)
>  {
>         unsigned long offset = reloc_offset();
>
> -       /* First zero the BSS -- use memset_io, some platforms don't have
> -        * caches on yet */
> -       memset_io((void __iomem *)PTRRELOC(&__bss_start), 0,
> -                       __bss_stop - __bss_start);
> +       /* First zero the BSS */
> +       memset(PTRRELOC(&__bss_start), 0, __bss_stop - __bss_start);
>
>         /*
>          * Identify the CPU type and fix up code sections
> --
> 2.13.3
>
