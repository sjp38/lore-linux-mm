Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 247E96B0253
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 13:19:36 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so13058847pab.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 10:19:35 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id q62si12815114pfq.5.2015.12.01.10.19.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 10:19:35 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so13058423pab.0
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 10:19:35 -0800 (PST)
Subject: Re: [PATCH v4 4/4] x86: mm: support ARCH_MMAP_RND_BITS.
References: <1448578785-17656-1-git-send-email-dcashman@android.com>
 <1448578785-17656-2-git-send-email-dcashman@android.com>
 <1448578785-17656-3-git-send-email-dcashman@android.com>
 <1448578785-17656-4-git-send-email-dcashman@android.com>
 <1448578785-17656-5-git-send-email-dcashman@android.com>
 <CAGXu5j+Wj_=27gsYStV5OuwNSznux7MtDcMuYe5wM2ORrna_TQ@mail.gmail.com>
From: Daniel Cashman <dcashman@android.com>
Message-ID: <565DE4B4.5050305@android.com>
Date: Tue, 1 Dec 2015 10:19:32 -0800
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+Wj_=27gsYStV5OuwNSznux7MtDcMuYe5wM2ORrna_TQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Jonathan Corbet <corbet@lwn.net>, Don Zickus <dzickus@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Heinrich Schuchardt <xypron.glpk@gmx.de>, jpoimboe@redhat.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Linux-MM <linux-mm@kvack.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Mark Salyzyn <salyzyn@android.com>, Jeffrey Vander Stoep <jeffv@google.com>, Nick Kralevich <nnk@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Hector Marco <hecmargi@upv.es>, Borislav Petkov <bp@suse.de>, Daniel Cashman <dcashman@google.com>

On 11/30/2015 04:03 PM, Kees Cook wrote:
> On Thu, Nov 26, 2015 at 2:59 PM, Daniel Cashman <dcashman@android.com> wrote:
>> diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
>> index 844b06d..647fecf 100644
>> --- a/arch/x86/mm/mmap.c
>> +++ b/arch/x86/mm/mmap.c
>> @@ -69,14 +69,14 @@ unsigned long arch_mmap_rnd(void)
>>  {
>>         unsigned long rnd;
>>
>> -       /*
>> -        *  8 bits of randomness in 32bit mmaps, 20 address space bits
>> -        * 28 bits of randomness in 64bit mmaps, 40 address space bits
>> -        */
>>         if (mmap_is_ia32())
>> -               rnd = (unsigned long)get_random_int() % (1<<8);
>> +#ifdef CONFIG_COMPAT
>> +               rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_compat_bits);
>> +#else
>> +               rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_bits);
>> +#endif
>>         else
>> -               rnd = (unsigned long)get_random_int() % (1<<28);
>> +               rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_bits);
>>
>>         return rnd << PAGE_SHIFT;
>>  }
>> --
>> 2.6.0.rc2.230.g3dd15c0
>>
> 
> Can you rework this logic to look more like the arm64 one? I think
> it's more readable as:
> 
> #ifdef CONFIG_COMPAT
>     if (mmap_is_ia32())
>             rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_compat_bits);
>     else
> #endif
>             rnd = (unsigned long)get_random_int() % (1 << mmap_rnd_bits);
> 
> -Kees
> 

There is a subtle difference between the two that requires this
difference. the x86 code was written to be used by both 32-bit and
64-bit kernels, whereas the arm64 code runs only for 64-bit.  The
assumption I've made with arm64 is that TIF_32BIT should never be set if
CONFIG_COMPAT is not set, but with x86 we could encounter a 32-bit
application without CONFIG_COMPAT, in which case it should use the
default mmap_rnd_bits, not compat, since there is no compat.

-Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
