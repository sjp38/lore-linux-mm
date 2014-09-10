Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1808E6B0093
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 16:30:12 -0400 (EDT)
Received: by mail-vc0-f181.google.com with SMTP id ij19so5385703vcb.26
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:30:11 -0700 (PDT)
Received: from mail-vc0-x232.google.com (mail-vc0-x232.google.com [2607:f8b0:400c:c03::232])
        by mx.google.com with ESMTPS id rk7si6795524vcb.45.2014.09.10.13.30.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 13:30:11 -0700 (PDT)
Received: by mail-vc0-f178.google.com with SMTP id hy4so4460959vcb.23
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:30:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5410724B.8000803@intel.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1410359487-31938-1-git-send-email-a.ryabinin@samsung.com>
	<1410359487-31938-3-git-send-email-a.ryabinin@samsung.com>
	<5410724B.8000803@intel.com>
Date: Thu, 11 Sep 2014 00:30:10 +0400
Message-ID: <CAPAsAGzm29VWz8ZvOu+fVGn4Vbj7bQZAnB11M5ZZXRTQTchj0w@mail.gmail.com>
Subject: Re: [RFC/PATCH v2 02/10] x86_64: add KASan support
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

2014-09-10 19:46 GMT+04:00 Dave Hansen <dave.hansen@intel.com>:
> Overall, the approach here looks pretty sane.  As you noted, it would be
> nice to keep PAGE_OFFSET in one place, but it's not a deal breaker for
> me.  The use of the vmemmap code looks to be a nice fit.
>
> Few nits below.
>
> On 09/10/2014 07:31 AM, Andrey Ryabinin wrote:
>> 16TB of virtual addressed used for shadow memory.
>> It's located in range [0xffff800000000000 - 0xffff900000000000]
>> Therefore PAGE_OFFSET has to be changed from 0xffff880000000000
>> to 0xffff900000000000.
> ...
>> It would be nice to not have different PAGE_OFFSET with and without CONFIG_KASAN.
>> We have big enough hole between vmemmap and esp fixup stacks.
>> So how about moving all direct mapping, vmalloc and vmemmap 8TB up without
>> hiding it under CONFIG_KASAN?
>
> Is there a reason this has to be _below_ the linear map?  Couldn't we
> just carve some space out of the vmalloc() area for the kasan area?
>

Yes, there is a reason for this. For inline instrumentation we need to
catch access to userspace without any additional check.
This means that we need shadow of 1 << 61 bytes and we don't have so
many addresses available. However, we could use
hole between userspace and kernelspace for that. For any address
between [0 - 0xffff800000000000], shadow address will be
in this hole, so checking shadow value will produce general protection
fault (GPF). We may even try handle GPF in a special way
and print more user-friendly report (this will be under CONFIG_KASAN of course).

But now I realized that we even if we put shadow in vmalloc, shadow
addresses  corresponding to userspace addresses
still will be in between userspace - kernelspace, so we also will get GPF.
There is the only problem I see now in such approach. Lets consider
that because of some bug in kernel we are trying to access
memory slightly bellow 0xffff800000000000. In this case kasan will try
to check some shadow which in fact is not a shadow byte at all.
It's not a big deal though, kernel will crash anyway. In only means
that debugging of such problems could be a little more complex
than without kasan.



>
>>  arch/x86/Kconfig                     |  1 +
>>  arch/x86/boot/Makefile               |  2 ++
>>  arch/x86/boot/compressed/Makefile    |  2 ++
>>  arch/x86/include/asm/kasan.h         | 20 ++++++++++++
>>  arch/x86/include/asm/page_64_types.h |  4 +++
>>  arch/x86/include/asm/pgtable.h       |  7 ++++-
>>  arch/x86/kernel/Makefile             |  2 ++
>>  arch/x86/kernel/dumpstack.c          |  5 ++-
>>  arch/x86/kernel/head64.c             |  6 ++++
>>  arch/x86/kernel/head_64.S            | 16 ++++++++++
>>  arch/x86/mm/Makefile                 |  3 ++
>>  arch/x86/mm/init.c                   |  3 ++
>>  arch/x86/mm/kasan_init_64.c          | 59 ++++++++++++++++++++++++++++++++++++
>>  arch/x86/realmode/Makefile           |  2 +-
>>  arch/x86/realmode/rm/Makefile        |  1 +
>>  arch/x86/vdso/Makefile               |  1 +
>>  include/linux/kasan.h                |  3 ++
>>  lib/Kconfig.kasan                    |  1 +
>>  18 files changed, 135 insertions(+), 3 deletions(-)
>>  create mode 100644 arch/x86/include/asm/kasan.h
>>  create mode 100644 arch/x86/mm/kasan_init_64.c
>
> This probably deserves an update of Documentation/x86/x86_64/mm.txt, too.
>

Sure, I didn't bother to do it now in case if memory layout changes in
this patch not final.

>> +void __init kasan_map_shadow(void)
>> +{
>> +     int i;
>> +
>> +     memcpy(early_level4_pgt, init_level4_pgt, 4096);
>> +     load_cr3(early_level4_pgt);
>> +
>> +     clear_zero_shadow_mapping(kasan_mem_to_shadow(PAGE_OFFSET),
>> +                             kasan_mem_to_shadow(0xffffc80000000000UL));
>
> This 0xffffc80000000000UL could be PAGE_OFFSET+MAXMEM.
>
>
>

-- 
Best regards,
Andrey Ryabinin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
