Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 58CF56B0273
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 03:17:03 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id z187so3333423ioz.14
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 00:17:03 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g103sor5929471ioj.268.2017.10.12.00.17.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Oct 2017 00:17:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171011162345.f601c29d12c81af85bf38565@linux-foundation.org>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-7-liuwenliang@huawei.com> <20171011162345.f601c29d12c81af85bf38565@linux-foundation.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 12 Oct 2017 09:16:39 +0200
Message-ID: <CACT4Y+Ym3kq5RZ-4F=f97bvT2pNpzDf0kerf6tebzLOY_crR8Q@mail.gmail.com>
Subject: Re: [PATCH 06/11] change memory_is_poisoned_16 for aligned error
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Abbott Liu <liuwenliang@huawei.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, afzal.mohd.ma@gmail.com, f.fainelli@gmail.com, Laura Abbott <labbott@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, cdall@linaro.org, marc.zyngier@arm.com, Catalin Marinas <catalin.marinas@arm.com>, Matthew Wilcox <mawilcox@microsoft.com>, Thomas Gleixner <tglx@linutronix.de>, Thomas Garnier <thgarnie@google.com>, Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>, Vladimir Murzin <vladimir.murzin@arm.com>, tixy@linaro.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, robin.murphy@arm.com, Ingo Molnar <mingo@kernel.org>, grygorii.strashko@linaro.org, Alexander Potapenko <glider@google.com>, opendmb@gmail.com, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, jiazhenghua@huawei.com, dylix.dailei@huawei.com, zengweilin@huawei.com, heshaoliang@huawei.com

On Thu, Oct 12, 2017 at 1:23 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 11 Oct 2017 16:22:22 +0800 Abbott Liu <liuwenliang@huawei.com> wrote:
>
>>  Because arm instruction set don't support access the address which is
>>  not aligned, so must change memory_is_poisoned_16 for arm.
>>
>> ...
>>
>> --- a/mm/kasan/kasan.c
>> +++ b/mm/kasan/kasan.c
>> @@ -149,6 +149,25 @@ static __always_inline bool memory_is_poisoned_2_4_8(unsigned long addr,
>>       return memory_is_poisoned_1(addr + size - 1);
>>  }
>>
>> +#ifdef CONFIG_ARM
>> +static __always_inline bool memory_is_poisoned_16(unsigned long addr)
>> +{
>> +     u8 *shadow_addr = (u8 *)kasan_mem_to_shadow((void *)addr);
>> +
>> +     if (unlikely(shadow_addr[0] || shadow_addr[1])) return true;
>
> Coding-style is messed up.  Please use scripts/checkpatch.pl.
>
>> +     else {
>> +             /*
>> +              * If two shadow bytes covers 16-byte access, we don't
>> +              * need to do anything more. Otherwise, test the last
>> +              * shadow byte.
>> +              */
>> +             if (likely(IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
>> +                     return false;
>> +             return memory_is_poisoned_1(addr + 15);
>> +     }
>> +}
>> +
>> +#else
>>  static __always_inline bool memory_is_poisoned_16(unsigned long addr)
>>  {
>>       u16 *shadow_addr = (u16 *)kasan_mem_to_shadow((void *)addr);
>> @@ -159,6 +178,7 @@ static __always_inline bool memory_is_poisoned_16(unsigned long addr)
>>
>>       return *shadow_addr;
>>  }
>> +#endif
>
> - I don't understand why this is necessary.  memory_is_poisoned_16()
>   already handles unaligned addresses?
>
> - If it's needed on ARM then presumably it will be needed on other
>   architectures, so CONFIG_ARM is insufficiently general.
>
> - If the present memory_is_poisoned_16() indeed doesn't work on ARM,
>   it would be better to generalize/fix it in some fashion rather than
>   creating a new variant of the function.


Yes, I think it will be better to fix the current function rather then
have 2 slightly different copies with ifdef's.
Will something along these lines work for arm? 16-byte accesses are
not too common, so it should not be a performance problem. And
probably modern compilers can turn 2 1-byte checks into a 2-byte check
where safe (x86).

static __always_inline bool memory_is_poisoned_16(unsigned long addr)
{
        u8 *shadow_addr = (u8 *)kasan_mem_to_shadow((void *)addr);

        if (shadow_addr[0] || shadow_addr[1])
                return true;
        /* Unaligned 16-bytes access maps into 3 shadow bytes. */
        if (unlikely(!IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
                return memory_is_poisoned_1(addr + 15);
        return false;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
