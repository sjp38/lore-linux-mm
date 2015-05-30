Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 75DD86B0032
	for <linux-mm@kvack.org>; Sat, 30 May 2015 05:18:28 -0400 (EDT)
Received: by obbnx5 with SMTP id nx5so73385057obb.0
        for <linux-mm@kvack.org>; Sat, 30 May 2015 02:18:28 -0700 (PDT)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com. [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id y10si5128814obw.9.2015.05.30.02.18.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 May 2015 02:18:26 -0700 (PDT)
Received: by obbea2 with SMTP id ea2so73591271obb.3
        for <linux-mm@kvack.org>; Sat, 30 May 2015 02:18:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1432940350-1802-7-git-send-email-toshi.kani@hp.com>
References: <1432940350-1802-1-git-send-email-toshi.kani@hp.com>
	<1432940350-1802-7-git-send-email-toshi.kani@hp.com>
Date: Sat, 30 May 2015 11:18:26 +0200
Message-ID: <CAMuHMdWLMUr9ggkhbOiDSsc_eq04En3L5oX5pL=9gHuR6JDb+w@mail.gmail.com>
Subject: Re: [PATCH v11 6/12] x86, mm, asm-gen: Add ioremap_wt() for WT
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, Andy Lutomirski <luto@amacapital.net>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, yigal@plexistor.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Elliott@hp.com, "Luis R. Rodriguez" <mcgrof@suse.com>, Christoph Hellwig <hch@lst.de>

On Sat, May 30, 2015 at 12:59 AM, Toshi Kani <toshi.kani@hp.com> wrote:
> --- a/include/asm-generic/io.h
> +++ b/include/asm-generic/io.h
> @@ -785,8 +785,17 @@ static inline void __iomem *ioremap_wc(phys_addr_t offset, size_t size)
>  }
>  #endif
>
> +#ifndef ioremap_wt
> +#define ioremap_wt ioremap_wt
> +static inline void __iomem *ioremap_wt(phys_addr_t offset, size_t size)
> +{
> +       return ioremap_nocache(offset, size);
> +}
> +#endif
> +
>  #ifndef iounmap
>  #define iounmap iounmap
> +
>  static inline void iounmap(void __iomem *addr)
>  {
>  }
> diff --git a/include/asm-generic/iomap.h b/include/asm-generic/iomap.h
> index 1b41011..d8f8622 100644
> --- a/include/asm-generic/iomap.h
> +++ b/include/asm-generic/iomap.h
> @@ -66,6 +66,10 @@ extern void ioport_unmap(void __iomem *);
>  #define ioremap_wc ioremap_nocache
>  #endif
>
> +#ifndef ARCH_HAS_IOREMAP_WT
> +#define ioremap_wt ioremap_nocache
> +#endif

Defining ioremap_wt in two different places in asm-generic looks fishy to me.

If <asm/io.h> already provides it (either through asm-generic/io.h or
arch/<arch>/include/asm/io.h), why does asm-generic/iomap.h need to define
its own version?

I see this pattern already exists for ioremap_wc...

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
