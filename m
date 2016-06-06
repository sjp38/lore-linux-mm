Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6BA1F6B025E
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 13:07:59 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ug1so38333319pab.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 10:07:59 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m64si29325538pfb.124.2016.06.06.10.07.58
        for <linux-mm@kvack.org>;
        Mon, 06 Jun 2016 10:07:58 -0700 (PDT)
Date: Mon, 6 Jun 2016 18:07:39 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [v2 PATCH] arm64: kasan: instrument user memory access API
Message-ID: <20160606170738.GD23505@leverpostej>
References: <1464382863-11879-1-git-send-email-yang.shi@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464382863-11879-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>
Cc: aryabinin@virtuozzo.com, will.deacon@arm.com, catalin.marinas@arm.com, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Fri, May 27, 2016 at 02:01:03PM -0700, Yang Shi wrote:
> The upstream commit 1771c6e1a567ea0ba2cccc0a4ffe68a1419fd8ef
> ("x86/kasan: instrument user memory access API") added KASAN instrument to
> x86 user memory access API, so added such instrument to ARM64 too.
> 
> Define __copy_to/from_user in C in order to add kasan_check_read/write call,
> rename assembly implementation to __arch_copy_to/from_user.
> 
> Tested by test_kasan module.
> 
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> ---
> v2:
>  Adopted the comment from Andrey and Mark to add kasan_check_read/write into
>  __copy_to/from_user.
> 
>  arch/arm64/include/asm/uaccess.h | 25 +++++++++++++++++++++----
>  arch/arm64/kernel/arm64ksyms.c   |  4 ++--
>  arch/arm64/lib/copy_from_user.S  |  4 ++--
>  arch/arm64/lib/copy_to_user.S    |  4 ++--
>  4 files changed, 27 insertions(+), 10 deletions(-)
> 
> diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
> index 0685d74..4dc9a8f 100644
> --- a/arch/arm64/include/asm/uaccess.h
> +++ b/arch/arm64/include/asm/uaccess.h
> @@ -23,6 +23,7 @@
>   */
>  #include <linux/string.h>
>  #include <linux/thread_info.h>
> +#include <linux/kasan-checks.h>

Nit: please move this before the other includes, to keep these ordered
alphabetically.

Other than that, this looks correct to me, and seems to have addressed
the issue from v1. I've given this a spin on v4.7-rc2, with and without
CONFIG_UBSAN enabled. So FWIW, with the minor fix above:

Reviewed-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>

As this isn't a fix, I assume that this is for Catalin to pick for v4.8.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
