Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id B36DC6B000A
	for <linux-mm@kvack.org>; Wed,  2 May 2018 11:29:06 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g5-v6so9494661ioc.4
        for <linux-mm@kvack.org>; Wed, 02 May 2018 08:29:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k19-v6sor623644ioj.207.2018.05.02.08.29.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 May 2018 08:29:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180426154725.74a33tnevvbtqx63@armageddon.cambridge.arm.com>
References: <cover.1524077494.git.andreyknvl@google.com> <949c343a4b02b41b80f324c2b7cd56b75e6a04f3.1524077494.git.andreyknvl@google.com>
 <20180426154725.74a33tnevvbtqx63@armageddon.cambridge.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 2 May 2018 17:29:04 +0200
Message-ID: <CAAeHK+xWV2RNuoOrgkLrQ973eV2r8xFOcrzHWVrQZz7XA2WGYA@mail.gmail.com>
Subject: Re: [PATCH 3/6] arm64: untag user addresses in copy_from_user and others
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Jonathan Corbet <corbet@lwn.net>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, James Morse <james.morse@arm.com>, Kees Cook <keescook@chromium.org>, Bart Van Assche <bart.vanassche@wdc.com>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>

On Thu, Apr 26, 2018 at 5:47 PM, Catalin Marinas
<catalin.marinas@arm.com> wrote:
> On Wed, Apr 18, 2018 at 08:53:12PM +0200, Andrey Konovalov wrote:
>> @@ -238,12 +239,15 @@ static inline void uaccess_enable_not_uao(void)
>>  /*
>>   * Sanitise a uaccess pointer such that it becomes NULL if above the
>>   * current addr_limit.
>> + * Also untag user pointers that have the top byte tag set.
>>   */
>>  #define uaccess_mask_ptr(ptr) (__typeof__(ptr))__uaccess_mask_ptr(ptr)
>>  static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
>>  {
>>       void __user *safe_ptr;
>>
>> +     ptr = untagged_addr(ptr);
>> +
>>       asm volatile(
>>       "       bics    xzr, %1, %2\n"
>>       "       csel    %0, %1, xzr, eq\n"
>
> First of all, passing a tagged user pointer throughout the kernel is
> safe with uaccess routines but not suitable for find_vma() etc.
>
> With this change, we may have an inconsistent behaviour on the tag
> masking, depending on whether the entry code uses __uaccess_mask_ptr()
> or not. We could preserve the tag with something like:
>
> diff --git a/arch/arm64/include/asm/uaccess.h b/arch/arm64/include/asm/uaccess.h
> index e66b0fca99c2..ed15bfcbd797 100644
> --- a/arch/arm64/include/asm/uaccess.h
> +++ b/arch/arm64/include/asm/uaccess.h
> @@ -244,10 +244,11 @@ static inline void __user *__uaccess_mask_ptr(const void __user *ptr)
>         void __user *safe_ptr;
>
>         asm volatile(
> -       "       bics    xzr, %1, %2\n"
> +       "       bics    xzr, %3, %2\n"
>         "       csel    %0, %1, xzr, eq\n"
>         : "=&r" (safe_ptr)
> -       : "r" (ptr), "r" (current_thread_info()->addr_limit)
> +       : "r" (ptr), "r" (current_thread_info()->addr_limit),
> +         "r" (untagged_addr(ptr))
>         : "cc");
>
>         csdb();

Just to make sure I understood this assembly snippet correctly, this
change will result in checking untagged address against addr_limit,
and returning the original tagged address if the check passes. Sure,
sounds good, I'll do that.
