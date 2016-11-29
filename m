Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6D3296B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 14:39:47 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id c21so298961935ioj.5
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 11:39:47 -0800 (PST)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id h200si45116648ioe.75.2016.11.29.11.39.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 11:39:46 -0800 (PST)
Received: by mail-io0-x233.google.com with SMTP id j65so308996708iof.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 11:39:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1480445729-27130-10-git-send-email-labbott@redhat.com>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com> <1480445729-27130-10-git-send-email-labbott@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 29 Nov 2016 11:39:44 -0800
Message-ID: <CAGXu5jKrBc6R9JYay1L6pd958Vm5-6p=37tiUYgg6uPeZb1HtQ@mail.gmail.com>
Subject: Re: [PATCHv4 09/10] mm/usercopy: Switch to using lm_alias
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Tue, Nov 29, 2016 at 10:55 AM, Laura Abbott <labbott@redhat.com> wrote:
>
> The usercopy checking code currently calls __va(__pa(...)) to check for
> aliases on symbols. Switch to using lm_alias instead.
>
> Signed-off-by: Laura Abbott <labbott@redhat.com>

Acked-by: Kees Cook <keescook@chromium.org>

I should probably add a corresponding alias test to lkdtm...

-Kees

> ---
> Found when reviewing the kernel. Tested.
> ---
>  mm/usercopy.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/usercopy.c b/mm/usercopy.c
> index 3c8da0a..8345299 100644
> --- a/mm/usercopy.c
> +++ b/mm/usercopy.c
> @@ -108,13 +108,13 @@ static inline const char *check_kernel_text_object(const void *ptr,
>          * __pa() is not just the reverse of __va(). This can be detected
>          * and checked:
>          */
> -       textlow_linear = (unsigned long)__va(__pa(textlow));
> +       textlow_linear = (unsigned long)lm_alias(textlow);
>         /* No different mapping: we're done. */
>         if (textlow_linear == textlow)
>                 return NULL;
>
>         /* Check the secondary mapping... */
> -       texthigh_linear = (unsigned long)__va(__pa(texthigh));
> +       texthigh_linear = (unsigned long)lm_alias(texthigh);
>         if (overlaps(ptr, n, textlow_linear, texthigh_linear))
>                 return "<linear kernel text>";
>
> --
> 2.7.4
>



-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
