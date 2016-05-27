Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E90F76B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 08:38:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c84so91101152pfc.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 05:38:27 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r74si14198028pfb.45.2016.05.27.05.38.26
        for <linux-mm@kvack.org>;
        Fri, 27 May 2016 05:38:26 -0700 (PDT)
Date: Fri, 27 May 2016 13:38:10 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] arm64: kasan: instrument user memory access API
Message-ID: <20160527123809.GD24469@leverpostej>
References: <1464288231-11304-1-git-send-email-yang.shi@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464288231-11304-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linaro.org>
Cc: aryabinin@virtuozzo.com, will.deacon@arm.com, catalin.marinas@arm.com, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

Hi,

On Thu, May 26, 2016 at 11:43:51AM -0700, Yang Shi wrote:
> The upstream commit 1771c6e1a567ea0ba2cccc0a4ffe68a1419fd8ef
> ("x86/kasan: instrument user memory access API") added KASAN instrument to
> x86 user memory access API, so added such instrument to ARM64 too.
> 
> Tested by test_kasan module.

I just gave this a go atop of the current HEAD (dc03c0f9d12d8528) on a
Juno R1 board. I hit the expected exceptions when using the test_kasan
module (once I remembered to rebuild it), and things seem to run
smoothly otherwise.

I don't see any built issues when !CONFIG_KASAN, and the patch itself
looks right to me.

So FWIW:

Acked-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>

As an aside, it's a shame that each architecture has to duplicate this
logic, rather than having something in the generic code like:

static inline unsigned long __must_check
copy_from_user(void *to, const void __user *from, unsigned long n)
{
	kasan_check_read(from, n);
	arch_copy_from_user(to, from, n);
}

Thanks,
Mark.

> 
> Signed-off-by: Yang Shi <yang.shi@linaro.org>
> ---
>  arch/arm64/include/asm/uaccess.h | 18 ++++++++++++++++--
>  1 file changed, 16 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
> index 0685d74..ec352fa 100644
> --- a/arch/arm64/include/asm/uaccess.h
> +++ b/arch/arm64/include/asm/uaccess.h
> @@ -23,6 +23,7 @@
>   */
>  #include <linux/string.h>
>  #include <linux/thread_info.h>
> +#include <linux/kasan-checks.h>
>  
>  #include <asm/alternative.h>
>  #include <asm/cpufeature.h>
> @@ -276,6 +277,8 @@ extern unsigned long __must_check __clear_user(void __user *addr, unsigned long
>  
>  static inline unsigned long __must_check copy_from_user(void *to, const void __user *from, unsigned long n)
>  {
> +	kasan_check_write(to, n);
> +
>  	if (access_ok(VERIFY_READ, from, n))
>  		n = __copy_from_user(to, from, n);
>  	else /* security hole - plug it */
> @@ -285,6 +288,8 @@ static inline unsigned long __must_check copy_from_user(void *to, const void __u
>  
>  static inline unsigned long __must_check copy_to_user(void __user *to, const void *from, unsigned long n)
>  {
> +	kasan_check_read(from, n);
> +
>  	if (access_ok(VERIFY_WRITE, to, n))
>  		n = __copy_to_user(to, from, n);
>  	return n;
> @@ -297,8 +302,17 @@ static inline unsigned long __must_check copy_in_user(void __user *to, const voi
>  	return n;
>  }
>  
> -#define __copy_to_user_inatomic __copy_to_user
> -#define __copy_from_user_inatomic __copy_from_user
> +static inline unsigned long __copy_to_user_inatomic(void __user *to, const void *from, unsigned long n)
> +{
> +	kasan_check_read(from, n);
> +	return __copy_to_user(to, from, n);
> +}
> +
> +static inline unsigned long __copy_from_user_inatomic(void *to, const void __user *from, unsigned long n)
> +{
> +	kasan_check_write(to, n);
> +	return __copy_from_user(to, from, n);
> +}
>  
>  static inline unsigned long __must_check clear_user(void __user *to, unsigned long n)
>  {
> -- 
> 2.0.2
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
