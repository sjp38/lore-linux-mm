Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1EF3B6B0253
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 13:21:17 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 83so565846733pfx.1
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 10:21:17 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b31si20412658pli.65.2016.12.06.10.21.16
        for <linux-mm@kvack.org>;
        Tue, 06 Dec 2016 10:21:16 -0800 (PST)
Date: Tue, 6 Dec 2016 18:20:28 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCHv4 09/10] mm/usercopy: Switch to using lm_alias
Message-ID: <20161206182028.GI24177@leverpostej>
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
 <1480445729-27130-10-git-send-email-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1480445729-27130-10-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Kees Cook <keescook@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

On Tue, Nov 29, 2016 at 10:55:28AM -0800, Laura Abbott wrote:
> 
> The usercopy checking code currently calls __va(__pa(...)) to check for
> aliases on symbols. Switch to using lm_alias instead.
> 
> Signed-off-by: Laura Abbott <labbott@redhat.com>

I've given this a go on Juno, which boots happily. LKDTM triggers as
expected when copying from the kernel text and its alias.

Reviewed-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>

Thanks,
Mark.

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
>  	 * __pa() is not just the reverse of __va(). This can be detected
>  	 * and checked:
>  	 */
> -	textlow_linear = (unsigned long)__va(__pa(textlow));
> +	textlow_linear = (unsigned long)lm_alias(textlow);
>  	/* No different mapping: we're done. */
>  	if (textlow_linear == textlow)
>  		return NULL;
>  
>  	/* Check the secondary mapping... */
> -	texthigh_linear = (unsigned long)__va(__pa(texthigh));
> +	texthigh_linear = (unsigned long)lm_alias(texthigh);
>  	if (overlaps(ptr, n, textlow_linear, texthigh_linear))
>  		return "<linear kernel text>";
>  
> -- 
> 2.7.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
