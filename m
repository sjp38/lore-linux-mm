Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 522136B0254
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 05:49:34 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so24000052pab.2
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 02:49:34 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ym8si1323214pac.23.2015.10.09.02.49.33
        for <linux-mm@kvack.org>;
        Fri, 09 Oct 2015 02:49:33 -0700 (PDT)
Date: Fri, 9 Oct 2015 10:48:51 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v6 0/6] KASAN for arm64
Message-ID: <20151009094851.GA20507@leverpostej>
References: <1442482692-6416-1-git-send-email-ryabinin.a.a@gmail.com>
 <20151007100411.GG3069@e104818-lin.cambridge.arm.com>
 <CAPAsAGxR-yqtmFeo65Xw_0RQyEy=mN1uG=GKtqoMLr_x_N0u5w@mail.gmail.com>
 <20151008111144.GC7275@leverpostej>
 <56165228.8060201@gmail.com>
 <CAKv+Gu_v7J1BA+xFcowBrW05bRFs=_WFf_HCeCmWgdZVRo0eQw@mail.gmail.com>
 <20151008151144.GM17192@e104818-lin.cambridge.arm.com>
 <CAPAsAGxhcRtks40u3O29t=KMKkuLy4Pf8u8TeeBy2f2-MuSf+A@mail.gmail.com>
 <561789A2.5050601@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <561789A2.5050601@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Yury <yury.norov@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Walleij <linus.walleij@linaro.org>, Mark Salter <msalter@redhat.com>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, Alexey Klimov <klimov.linux@gmail.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <andreyknvl@google.com>, David Keitel <dkeitel@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Matt Fleming <matt.fleming@intel.com>

On Fri, Oct 09, 2015 at 12:32:18PM +0300, Andrey Ryabinin wrote:
[...]

> I thought the EFI stub isolation patches create a copy of mem*() functions in the stub,
> but they are just create aliases with __efistub_ prefix.
> 
> We only need to create some more aliases for KASAN.
> The following patch on top of the EFI stub isolation series works for me.
> 
> 
> Signed-off-by: Andrey Ryabinin <ryabinin.a.a@gmail.com>
> ---
>  arch/arm64/kernel/image.h | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/arch/arm64/kernel/image.h b/arch/arm64/kernel/image.h
> index e083af0..6eb8fee 100644
> --- a/arch/arm64/kernel/image.h
> +++ b/arch/arm64/kernel/image.h
> @@ -80,6 +80,12 @@ __efistub_strcmp		= __pi_strcmp;
>  __efistub_strncmp		= __pi_strncmp;
>  __efistub___flush_dcache_area	= __pi___flush_dcache_area;
>  
> +#ifdef CONFIG_KASAN
> +__efistub___memcpy		= __pi_memcpy;
> +__efistub___memmove		= __pi_memmove;
> +__efistub___memset		= __pi_memset;
> +#endif

Ard's v4 stub isolation series has these aliases [1], as the stub
requires these aliases regardless of KASAN in order to link.

Thanks,
Mark.

[1] http://lists.infradead.org/pipermail/linux-arm-kernel/2015-October/375708.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
