Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 023166B48DA
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 11:04:27 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id x82so27384779ita.9
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 08:04:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l14sor8000739jac.7.2018.11.27.08.04.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 08:04:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20181123173739.osgvnnhmptdgtlnl@lakrids.cambridge.arm.com>
References: <cover.1542648335.git.andreyknvl@google.com> <0288334225edc99d98d70c896494e19c3bd9361a.1542648335.git.andreyknvl@google.com>
 <20181123173739.osgvnnhmptdgtlnl@lakrids.cambridge.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 27 Nov 2018 17:04:24 +0100
Message-ID: <CAAeHK+xgmM9Fs2Yw8Cv8zGhz_hg6G31uhHabudibj7wszmCVAw@mail.gmail.com>
Subject: Re: [PATCH v11 09/24] arm64: move untagged_addr macro from uaccess.h
 to memory.h
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>

On Fri, Nov 23, 2018 at 6:37 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Mon, Nov 19, 2018 at 06:26:25PM +0100, Andrey Konovalov wrote:
>> Move the untagged_addr() macro from arch/arm64/include/asm/uaccess.h
>> to arch/arm64/include/asm/memory.h to be later reused by KASAN.
>>
>> Also make the untagged_addr() macro accept all kinds of address types
>> (void *, unsigned long, etc.). This allows not to specify type casts in
>> each place where the macro is used. This is done by using __typeof__.
>>
>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>> ---
>>  arch/arm64/include/asm/memory.h  | 8 ++++++++
>>  arch/arm64/include/asm/uaccess.h | 7 -------
>>  2 files changed, 8 insertions(+), 7 deletions(-)
>>
>> diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
>> index 05fbc7ffcd31..deb95be44392 100644
>> --- a/arch/arm64/include/asm/memory.h
>> +++ b/arch/arm64/include/asm/memory.h
>> @@ -73,6 +73,14 @@
>>  #define KERNEL_START      _text
>>  #define KERNEL_END        _end
>>
>> +/*
>> + * When dealing with data aborts, watchpoints, or instruction traps we may end
>> + * up with a tagged userland pointer. Clear the tag to get a sane pointer to
>> + * pass on to access_ok(), for instance.
>> + */
>> +#define untagged_addr(addr)  \
>> +     (__typeof__(addr))sign_extend64((__u64)(addr), 55)
>
> Minor nits:
>
> * s/__u64/u64/ (or s/__u64/unsigned long/), since this isn't a UAPI
>   header.
>
> * Please move this down into the #ifndef __ASSEMBLY__ block, after we
>   include <linux/bitops.h>, which is necessary for sign_extend64().
>
> With those fixed up, this patch looks sound to me:
>
> Acked-by: Mark Rutland <mark.rutland@arm.com>
>
> Thanks,
> Mark.

Will do in v12, thanks!

>
>> +
>>  /*
>>   * Generic and tag-based KASAN require 1/8th and 1/16th of the kernel virtual
>>   * address space for the shadow region respectively. They can bloat the stack
>> diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
>> index 07c34087bd5e..281a1e47263d 100644
>> --- a/arch/arm64/include/asm/uaccess.h
>> +++ b/arch/arm64/include/asm/uaccess.h
>> @@ -96,13 +96,6 @@ static inline unsigned long __range_ok(const void __user *addr, unsigned long si
>>       return ret;
>>  }
>>
>> -/*
>> - * When dealing with data aborts, watchpoints, or instruction traps we may end
>> - * up with a tagged userland pointer. Clear the tag to get a sane pointer to
>> - * pass on to access_ok(), for instance.
>> - */
>> -#define untagged_addr(addr)          sign_extend64(addr, 55)
>> -
>>  #define access_ok(type, addr, size)  __range_ok(addr, size)
>>  #define user_addr_max                        get_fs
>>
>> --
>> 2.19.1.1215.g8438c0b245-goog
>>
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20181123173739.osgvnnhmptdgtlnl%40lakrids.cambridge.arm.com.
> For more options, visit https://groups.google.com/d/optout.
