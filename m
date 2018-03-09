Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0906B0007
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 10:03:17 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id 100so5105755oti.19
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 07:03:17 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d203si338466oih.397.2018.03.09.07.03.15
        for <linux-mm@kvack.org>;
        Fri, 09 Mar 2018 07:03:15 -0800 (PST)
Date: Fri, 9 Mar 2018 15:03:09 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [RFC PATCH 2/6] arm64: untag user addresses in copy_from_user
 and others
Message-ID: <20180309150309.4sue2zj6teehx6e3@lakrids.cambridge.arm.com>
References: <cover.1520600533.git.andreyknvl@google.com>
 <d681c0dee907ee5cc55d313e2f843237c6087bf0.1520600533.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d681c0dee907ee5cc55d313e2f843237c6087bf0.1520600533.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>

On Fri, Mar 09, 2018 at 03:02:00PM +0100, Andrey Konovalov wrote:
> copy_from_user (and a few other similar functions) are used to copy data
> from user memory into the kernel memory or vice versa. Since a user can
> provided a tagged pointer to one of the syscalls that use copy_from_user,
> we need to correctly handle such pointers.

I don't think it makes sense to do this in the low-level uaccess
primitives, given we're going to have to untag pointers before common
code can use them, e.g. for comparisons against TASK_SIZE or
user_addr_max().

I think we'll end up with subtle bugs unless we consistently untag
pointers before we get to uaccess primitives. If core code does untag
pointers, then it's redundant to do so here.

Thanks,
Mark.

> 
> Do this by untagging user pointers in access_ok and in __uaccess_mask_ptr.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  arch/arm64/include/asm/uaccess.h | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
> index 2d6451cbaa86..24a221678fe3 100644
> --- a/arch/arm64/include/asm/uaccess.h
> +++ b/arch/arm64/include/asm/uaccess.h
> @@ -105,7 +105,8 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
>  #define untagged_addr(addr)		\
>  	((__typeof__(addr))sign_extend64((__u64)(addr), 55))
>  
> -#define access_ok(type, addr, size)	__range_ok(addr, size)
> +#define access_ok(type, addr, size)	\
> +	__range_ok(untagged_addr(addr), size)
>  #define user_addr_max			get_fs
>  
>  #define _ASM_EXTABLE(from, to)						\
> @@ -238,12 +239,15 @@ static inline void uaccess_enable_not_uao(void)
>  /*
>   * Sanitise a uaccess pointer such that it becomes NULL if above the
>   * current addr_limit.
> + * Also untag user pointers that have the top byte tag set.
>   */
>  #define uaccess_mask_ptr(ptr) (__typeof__(ptr))__uaccess_mask_ptr(ptr)
>  static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
>  {
>  	void __user *safe_ptr;
>  
> +	ptr = untagged_addr(ptr);
> +
>  	asm volatile(
>  	"	bics	xzr, %1, %2\n"
>  	"	csel	%0, %1, xzr, eq\n"
> -- 
> 2.16.2.395.g2e18187dfd-goog
> 
