Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC2386B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 19:23:50 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id q124so1680567wmb.23
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 16:23:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j88si1503137edd.495.2017.10.11.16.23.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 16:23:49 -0700 (PDT)
Date: Wed, 11 Oct 2017 16:23:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 06/11] change memory_is_poisoned_16 for aligned error
Message-Id: <20171011162345.f601c29d12c81af85bf38565@linux-foundation.org>
In-Reply-To: <20171011082227.20546-7-liuwenliang@huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
	<20171011082227.20546-7-liuwenliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Abbott Liu <liuwenliang@huawei.com>
Cc: linux@armlinux.org.uk, aryabinin@virtuozzo.com, afzal.mohd.ma@gmail.com, f.fainelli@gmail.com, labbott@redhat.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, cdall@linaro.org, marc.zyngier@arm.com, catalin.marinas@arm.com, mawilcox@microsoft.com, tglx@linutronix.de, thgarnie@google.com, keescook@chromium.org, arnd@arndb.de, vladimir.murzin@arm.com, tixy@linaro.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, mingo@kernel.org, grygorii.strashko@linaro.org, glider@google.com, dvyukov@google.com, opendmb@gmail.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, jiazhenghua@huawei.com, dylix.dailei@huawei.com, zengweilin@huawei.com, heshaoliang@huawei.com

On Wed, 11 Oct 2017 16:22:22 +0800 Abbott Liu <liuwenliang@huawei.com> wrote:

>  Because arm instruction set don't support access the address which is
>  not aligned, so must change memory_is_poisoned_16 for arm.
> 
> ...
>
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -149,6 +149,25 @@ static __always_inline bool memory_is_poisoned_2_4_8(unsigned long addr,
>  	return memory_is_poisoned_1(addr + size - 1);
>  }
>  
> +#ifdef CONFIG_ARM
> +static __always_inline bool memory_is_poisoned_16(unsigned long addr)
> +{
> +	u8 *shadow_addr = (u8 *)kasan_mem_to_shadow((void *)addr);
> +
> +	if (unlikely(shadow_addr[0] || shadow_addr[1])) return true;

Coding-style is messed up.  Please use scripts/checkpatch.pl.

> +	else {
> +		/*
> +		 * If two shadow bytes covers 16-byte access, we don't
> +		 * need to do anything more. Otherwise, test the last
> +		 * shadow byte.
> +		 */
> +		if (likely(IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
> +			return false;
> +		return memory_is_poisoned_1(addr + 15);
> +	}
> +}
> +
> +#else
>  static __always_inline bool memory_is_poisoned_16(unsigned long addr)
>  {
>  	u16 *shadow_addr = (u16 *)kasan_mem_to_shadow((void *)addr);
> @@ -159,6 +178,7 @@ static __always_inline bool memory_is_poisoned_16(unsigned long addr)
>  
>  	return *shadow_addr;
>  }
> +#endif

- I don't understand why this is necessary.  memory_is_poisoned_16()
  already handles unaligned addresses?

- If it's needed on ARM then presumably it will be needed on other
  architectures, so CONFIG_ARM is insufficiently general.

- If the present memory_is_poisoned_16() indeed doesn't work on ARM,
  it would be better to generalize/fix it in some fashion rather than
  creating a new variant of the function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
