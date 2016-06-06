Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id A0C846B0269
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 12:37:36 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id l5so21603475ioa.0
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 09:37:36 -0700 (PDT)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id rd13si15346248pac.120.2016.06.06.09.37.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 09:37:35 -0700 (PDT)
Received: by mail-pf0-x22c.google.com with SMTP id z187so14410337pfz.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 09:37:34 -0700 (PDT)
Subject: Re: [v2 PATCH] arm64: kasan: instrument user memory access API
References: <1464382863-11879-1-git-send-email-yang.shi@linaro.org>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <37a456bf-6976-e100-e3a2-3c64a6227fa8@linaro.org>
Date: Mon, 6 Jun 2016 09:37:31 -0700
MIME-Version: 1.0
In-Reply-To: <1464382863-11879-1-git-send-email-yang.shi@linaro.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, will.deacon@arm.com, catalin.marinas@arm.com, mark.rutland@arm.com
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

Hi Will & Catalin,

Any comment for this patch?

Thanks,
Yang


On 5/27/2016 2:01 PM, Yang Shi wrote:
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
>
>  #include <asm/alternative.h>
>  #include <asm/cpufeature.h>
> @@ -269,15 +270,29 @@ do {									\
>  		-EFAULT;						\
>  })
>
> -extern unsigned long __must_check __copy_from_user(void *to, const void __user *from, unsigned long n);
> -extern unsigned long __must_check __copy_to_user(void __user *to, const void *from, unsigned long n);
> +extern unsigned long __must_check __arch_copy_from_user(void *to, const void __user *from, unsigned long n);
> +extern unsigned long __must_check __arch_copy_to_user(void __user *to, const void *from, unsigned long n);
>  extern unsigned long __must_check __copy_in_user(void __user *to, const void __user *from, unsigned long n);
>  extern unsigned long __must_check __clear_user(void __user *addr, unsigned long n);
>
> +static inline unsigned long __must_check __copy_from_user(void *to, const void __user *from, unsigned long n)
> +{
> +	kasan_check_write(to, n);
> +	return  __arch_copy_from_user(to, from, n);
> +}
> +
> +static inline unsigned long __must_check __copy_to_user(void __user *to, const void *from, unsigned long n)
> +{
> +	kasan_check_read(from, n);
> +	return  __arch_copy_to_user(to, from, n);
> +}
> +
>  static inline unsigned long __must_check copy_from_user(void *to, const void __user *from, unsigned long n)
>  {
> +	kasan_check_write(to, n);
> +
>  	if (access_ok(VERIFY_READ, from, n))
> -		n = __copy_from_user(to, from, n);
> +		n = __arch_copy_from_user(to, from, n);
>  	else /* security hole - plug it */
>  		memset(to, 0, n);
>  	return n;
> @@ -285,8 +300,10 @@ static inline unsigned long __must_check copy_from_user(void *to, const void __u
>
>  static inline unsigned long __must_check copy_to_user(void __user *to, const void *from, unsigned long n)
>  {
> +	kasan_check_read(from, n);
> +
>  	if (access_ok(VERIFY_WRITE, to, n))
> -		n = __copy_to_user(to, from, n);
> +		n = __arch_copy_to_user(to, from, n);
>  	return n;
>  }
>
> diff --git a/arch/arm64/kernel/arm64ksyms.c b/arch/arm64/kernel/arm64ksyms.c
> index 678f30b0..2dc4440 100644
> --- a/arch/arm64/kernel/arm64ksyms.c
> +++ b/arch/arm64/kernel/arm64ksyms.c
> @@ -34,8 +34,8 @@ EXPORT_SYMBOL(copy_page);
>  EXPORT_SYMBOL(clear_page);
>
>  	/* user mem (segment) */
> -EXPORT_SYMBOL(__copy_from_user);
> -EXPORT_SYMBOL(__copy_to_user);
> +EXPORT_SYMBOL(__arch_copy_from_user);
> +EXPORT_SYMBOL(__arch_copy_to_user);
>  EXPORT_SYMBOL(__clear_user);
>  EXPORT_SYMBOL(__copy_in_user);
>
> diff --git a/arch/arm64/lib/copy_from_user.S b/arch/arm64/lib/copy_from_user.S
> index 17e8306..0b90497 100644
> --- a/arch/arm64/lib/copy_from_user.S
> +++ b/arch/arm64/lib/copy_from_user.S
> @@ -66,7 +66,7 @@
>  	.endm
>
>  end	.req	x5
> -ENTRY(__copy_from_user)
> +ENTRY(__arch_copy_from_user)
>  ALTERNATIVE("nop", __stringify(SET_PSTATE_PAN(0)), ARM64_ALT_PAN_NOT_UAO, \
>  	    CONFIG_ARM64_PAN)
>  	add	end, x0, x2
> @@ -75,7 +75,7 @@ ALTERNATIVE("nop", __stringify(SET_PSTATE_PAN(1)), ARM64_ALT_PAN_NOT_UAO, \
>  	    CONFIG_ARM64_PAN)
>  	mov	x0, #0				// Nothing to copy
>  	ret
> -ENDPROC(__copy_from_user)
> +ENDPROC(__arch_copy_from_user)
>
>  	.section .fixup,"ax"
>  	.align	2
> diff --git a/arch/arm64/lib/copy_to_user.S b/arch/arm64/lib/copy_to_user.S
> index 21faae6..7a7efe2 100644
> --- a/arch/arm64/lib/copy_to_user.S
> +++ b/arch/arm64/lib/copy_to_user.S
> @@ -65,7 +65,7 @@
>  	.endm
>
>  end	.req	x5
> -ENTRY(__copy_to_user)
> +ENTRY(__arch_copy_to_user)
>  ALTERNATIVE("nop", __stringify(SET_PSTATE_PAN(0)), ARM64_ALT_PAN_NOT_UAO, \
>  	    CONFIG_ARM64_PAN)
>  	add	end, x0, x2
> @@ -74,7 +74,7 @@ ALTERNATIVE("nop", __stringify(SET_PSTATE_PAN(1)), ARM64_ALT_PAN_NOT_UAO, \
>  	    CONFIG_ARM64_PAN)
>  	mov	x0, #0
>  	ret
> -ENDPROC(__copy_to_user)
> +ENDPROC(__arch_copy_to_user)
>
>  	.section .fixup,"ax"
>  	.align	2
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
