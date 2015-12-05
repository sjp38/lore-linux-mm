Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2286B0257
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 19:56:20 -0500 (EST)
Received: by qgeb1 with SMTP id b1so103707692qge.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 16:56:20 -0800 (PST)
Received: from mail-qk0-x22c.google.com (mail-qk0-x22c.google.com. [2607:f8b0:400d:c09::22c])
        by mx.google.com with ESMTPS id v72si8883598qka.96.2015.12.04.16.56.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 16:56:19 -0800 (PST)
Received: by qkcb135 with SMTP id b135so2362642qkc.3
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 16:56:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151204151913.166e5cb795359ff1a53d26ac@linux-foundation.org>
References: <201512050045.l2G9WhTi%fengguang.wu@intel.com>
	<20151204151424.e73641da44c61f20f10d93e9@linux-foundation.org>
	<20151204151913.166e5cb795359ff1a53d26ac@linux-foundation.org>
Date: Fri, 4 Dec 2015 16:56:19 -0800
Message-ID: <CAJQetW4L6Zuzd9GENK6XMg+OVtFUjyE4jOzoG+VB3HtwmoUmiA@mail.gmail.com>
Subject: Re: [linux-next:master 4174/4356] kernel/built-in.o:undefined
 reference to `mmap_rnd_bits'
From: Daniel Cashman <dcashman@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Mark Brown <broonie@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Yes, patch-set v5 addressed the MMU case.  As for
HAVE_ARCH_MMAP_RND_BITS=n, I deliberately made it such that once an
arch implements the feature it selects it in its Kconfig, so we
shouldn't have the situation where an arch relies on an mmap_rnd_bits*
in its mmap.c, but doesn't find one defined.

At present, I am planning to change the arm64/Kconfing to get rid of
the "if MMU" portion, per Will Deacon's request, adjust the min bit
value, and add a comment.  I've left the question of whether or not
the value should be the number of randomized bits (current situation)
or the size of the address space chunk affected up to akpm@.  Please
let me know what else should be done in v6 to keep these in.

Thank You,
Dan

On Fri, Dec 4, 2015 at 3:19 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Fri, 4 Dec 2015 15:14:24 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> There's also the matter of CONFIG_MMU=n.
>
> ah, Arnd already fixed this one.  I guess I'll retain the patches
> for now.
>
>
>
> From: Arnd Bergmann <arnd@arndb.de>
> Subject: ARM: avoid ARCH_MMAP_RND_BITS for NOMMU
>
> ARM kernels with MMU disabled fail to build because of CONFIG_ARCH_MMAP_RND_BITS:
>
> kernel/built-in.o:(.data+0x754): undefined reference to `mmap_rnd_bits'
> kernel/built-in.o:(.data+0x76c): undefined reference to `mmap_rnd_bits_min'
> kernel/built-in.o:(.data+0x770): undefined reference to `mmap_rnd_bits_max'
>
> This changes the newly added line to only select this allow for
> MMU-enabled kernels.
>
> Fixes: 14570b3fd31a ("arm: mm: support ARCH_MMAP_RND_BITS")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Cc: Daniel Cashman <dcashman@google.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  arch/arm/Kconfig |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff -puN arch/arm/Kconfig~arm-mm-support-arch_mmap_rnd_bits-fix arch/arm/Kconfig
> --- a/arch/arm/Kconfig~arm-mm-support-arch_mmap_rnd_bits-fix
> +++ a/arch/arm/Kconfig
> @@ -35,7 +35,7 @@ config ARM
>         select HAVE_ARCH_BITREVERSE if (CPU_32v7M || CPU_32v7) && !CPU_32v6
>         select HAVE_ARCH_JUMP_LABEL if !XIP_KERNEL && !CPU_ENDIAN_BE32
>         select HAVE_ARCH_KGDB if !CPU_ENDIAN_BE32
> -       select HAVE_ARCH_MMAP_RND_BITS
> +       select HAVE_ARCH_MMAP_RND_BITS if MMU
>         select HAVE_ARCH_SECCOMP_FILTER if (AEABI && !OABI_COMPAT)
>         select HAVE_ARCH_TRACEHOOK
>         select HAVE_BPF_JIT
> _
>



-- 
Dan Cashman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
