Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5219B6B03A4
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 06:10:14 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id p64so49083550oif.0
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 03:10:14 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0090.outbound.protection.outlook.com. [104.47.2.90])
        by mx.google.com with ESMTPS id a15si2207024otd.125.2017.04.07.03.10.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 07 Apr 2017 03:10:13 -0700 (PDT)
Subject: Re: [PATCH 8/8] x86/mm: Allow to have userspace mappings above
 47-bits
References: <20170406140106.78087-1-kirill.shutemov@linux.intel.com>
 <20170406140106.78087-9-kirill.shutemov@linux.intel.com>
 <3cb79f4b-76f5-6e31-6973-e9281b2e4553@virtuozzo.com>
 <eaf4c954-e6c0-a9b4-50f1-49889dbd0f4b@virtuozzo.com>
 <20170406232137.uk7y2knbkcsru4pi@black.fi.intel.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <27affbe2-0150-526e-d47b-d5c1292e9187@virtuozzo.com>
Date: Fri, 7 Apr 2017 13:06:35 +0300
MIME-Version: 1.0
In-Reply-To: <20170406232137.uk7y2knbkcsru4pi@black.fi.intel.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/07/2017 02:21 AM, Kirill A. Shutemov wrote:
> On Thu, Apr 06, 2017 at 10:15:47PM +0300, Dmitry Safonov wrote:
>> On 04/06/2017 09:43 PM, Dmitry Safonov wrote:
>>> Hi Kirill,
>>>
>>> On 04/06/2017 05:01 PM, Kirill A. Shutemov wrote:
>>>> On x86, 5-level paging enables 56-bit userspace virtual address space.
>>>> Not all user space is ready to handle wide addresses. It's known that
>>>> at least some JIT compilers use higher bits in pointers to encode their
>>>> information. It collides with valid pointers with 5-level paging and
>>>> leads to crashes.
>>>>
>>>> To mitigate this, we are not going to allocate virtual address space
>>>> above 47-bit by default.
>>>>
>>>> But userspace can ask for allocation from full address space by
>>>> specifying hint address (with or without MAP_FIXED) above 47-bits.
>>>>
>>>> If hint address set above 47-bit, but MAP_FIXED is not specified, we try
>>>> to look for unmapped area by specified address. If it's already
>>>> occupied, we look for unmapped area in *full* address space, rather than
>>>> from 47-bit window.
>>>
>>> Do you wish after the first over-47-bit mapping the following mmap()
>>> calls return also over-47-bits if there is free space?
>>> It so, you could simplify all this code by changing only mm->mmap_base
>>> on the first over-47-bit mmap() call.
>>> This will do simple trick.
>
> No.
>
> I want every allocation to explicitely opt-in large address space. It's
> additional fail-safe: if a library can't handle large addresses it has
> better chance to survive if its own allocation will stay within 47-bits.

Ok

>
>> I just tried to define it like this:
>> -#define DEFAULT_MAP_WINDOW     ((1UL << 47) - PAGE_SIZE)
>> +#define DEFAULT_MAP_WINDOW     (test_thread_flag(TIF_ADDR32) ?         \
>> +                               IA32_PAGE_OFFSET : ((1UL << 47) -
>> PAGE_SIZE))
>>
>> And it looks working better.
>
> Okay, thanks. I'll send v2.
>
>>>> +    if (addr > DEFAULT_MAP_WINDOW && !in_compat_syscall())
>>>> +        info.high_limit += TASK_SIZE - DEFAULT_MAP_WINDOW;
>>>
>>> Hmm, TASK_SIZE depends now on TIF_ADDR32, which is set during exec().
>>> That means for ia32/x32 ELF which has TASK_SIZE < 4Gb as TIF_ADDR32
>>> is set, which can do 64-bit syscalls - the subtraction will be
>>> a negative..
>
> With your proposed change to DEFAULT_MAP_WINDOW difinition it should be
> okay, right?

I'll comment to v2 to keep all in one place.


-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
