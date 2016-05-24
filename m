Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id BCEBE6B0264
	for <linux-mm@kvack.org>; Tue, 24 May 2016 13:16:26 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id ne4so11611056lbc.1
        for <linux-mm@kvack.org>; Tue, 24 May 2016 10:16:26 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id t81si24783448wme.40.2016.05.24.10.16.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 10:16:11 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id n129so141617004wmn.1
        for <linux-mm@kvack.org>; Tue, 24 May 2016 10:16:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160524001629.7a9f0c5ce8427d0ad5e951fd@gmail.com>
References: <20160524001405.3e6abd1d5a63a871cc366cff@gmail.com> <20160524001629.7a9f0c5ce8427d0ad5e951fd@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 24 May 2016 10:16:09 -0700
Message-ID: <CAGXu5j+RQnSu2GgiRFP7UhDpLiuP=becZ-GXPoVRfXk6_wh3Gg@mail.gmail.com>
Subject: Re: [PATCH v1 2/3] Mark functions with the latent_entropy attribute
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Emese Revfy <re.emese@gmail.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, bart.vanassche@sandisk.com, "David S. Miller" <davem@davemloft.net>

On Mon, May 23, 2016 at 3:16 PM, Emese Revfy <re.emese@gmail.com> wrote:
> These functions have been selected because they are init functions or
> are called at random times or they have variable loops.
>
> Based on work created by the PaX Team.
>
> Signed-off-by: Emese Revfy <re.emese@gmail.com>
> [...]
> --- a/include/linux/compiler-gcc.h
> +++ b/include/linux/compiler-gcc.h
> @@ -188,6 +188,11 @@
>  #endif /* GCC_VERSION >= 40300 */
>
>  #if GCC_VERSION >= 40500
> +
> +#ifdef LATENT_ENTROPY_PLUGIN
> +#define __latent_entropy __attribute__((latent_entropy))
> +#endif

This deserves a full comment above it to describe its purpose and use
for when people go trying to figure out what it is and where to use
it. The commit message is a bit terse, so I'd try to expand both to
describe what function characteristics a developer should look for to
mark something with __latent_entropy.

> +
>  /*
>   * Mark a position in code as unreachable.  This can be used to
>   * suppress control flow warnings after asm blocks that transfer
> [...]
> diff --git a/include/linux/init.h b/include/linux/init.h
> index aedb254..68df2c3 100644
> --- a/include/linux/init.h
> +++ b/include/linux/init.h
> @@ -37,9 +37,15 @@
>   * section.
>   */
>
> +#ifdef CONFIG_MEMORY_HOTPLUG
> +#define add_meminit_latent_entropy
> +#else
> +#define add_meminit_latent_entropy __latent_entropy
> +#endif
> +
>  /* These are for everybody (although not all archs will actually
>     discard it in modules) */
> -#define __init         __section(.init.text) __cold notrace
> +#define __init         __section(.init.text) __cold notrace __latent_entropy
>  #define __initdata     __section(.init.data)
>  #define __initconst    __constsection(.init.rodata)
>  #define __exitdata     __section(.exit.data)
> @@ -92,7 +98,7 @@
>  #define __exit          __section(.exit.text) __exitused __cold notrace
>
>  /* Used for MEMORY_HOTPLUG */
> -#define __meminit        __section(.meminit.text) __cold notrace
> +#define __meminit        __section(.meminit.text) __cold notrace add_meminit_latent_entropy
>  #define __meminitdata    __section(.meminit.data)
>  #define __meminitconst   __constsection(.meminit.rodata)
>  #define __memexit        __section(.memexit.text) __exitused __cold notrace

I was confused by these defines. :) Maybe "add_meminit_latent_entropy"
should be named "__memory_hotplug_only_latent_entropy" or something
like that?

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
