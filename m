Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id E8DF96B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 09:00:18 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l68so29961229wml.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 06:00:18 -0800 (PST)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id k188si4867151wmd.53.2016.03.10.06.00.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 06:00:17 -0800 (PST)
Received: by mail-wm0-x232.google.com with SMTP id l68so29889059wml.1
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 06:00:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160309120912.83a82c79fd2bf6d21ab2c16a@linux-foundation.org>
References: <cover.1457519440.git.glider@google.com>
	<dcbbfeb740af239902695557999b45e70e93a877.1457519440.git.glider@google.com>
	<20160309120912.83a82c79fd2bf6d21ab2c16a@linux-foundation.org>
Date: Thu, 10 Mar 2016 15:00:17 +0100
Message-ID: <CAG_fn=VJU4p4Xk0vggWpwSrFnZ7iNTWn8LaY8sbBoxTMT7YdQw@mail.gmail.com>
Subject: Re: [PATCH v5 5/7] mm, kasan: Stackdepot implementation. Enable
 stackdepot for SLAB
From: Alexander Potapenko <glider@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <adech.fo@gmail.com>, Christoph Lameter <cl@linux.com>, Dmitriy Vyukov <dvyukov@google.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, JoonSoo Kim <js1304@gmail.com>, Kostya Serebryany <kcc@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Mar 9, 2016 at 9:09 PM, Andrew Morton <akpm@linux-foundation.org> w=
rote:
> On Wed,  9 Mar 2016 12:05:46 +0100 Alexander Potapenko <glider@google.com=
> wrote:
>
>> Implement the stack depot and provide CONFIG_STACKDEPOT.
>> Stack depot will allow KASAN store allocation/deallocation stack traces
>> for memory chunks. The stack traces are stored in a hash table and
>> referenced by handles which reside in the kasan_alloc_meta and
>> kasan_free_meta structures in the allocated memory chunks.
>>
>> IRQ stack traces are cut below the IRQ entry point to avoid unnecessary
>> duplication.
>>
>> Right now stackdepot support is only enabled in SLAB allocator.
>> Once KASAN features in SLAB are on par with those in SLUB we can switch
>> SLUB to stackdepot as well, thus removing the dependency on SLUB stack
>> bookkeeping, which wastes a lot of memory.
>>
>> This patch is based on the "mm: kasan: stack depots" patch originally
>> prepared by Dmitry Chernenkov.
>>
>
> Have you identified other potential clients for the stackdepot code?
Joonsoo Kim said he is planning to use stackdepot for the page owner.
>> --- /dev/null
>> +++ b/include/linux/stackdepot.h
>> @@ -0,0 +1,32 @@
>> +/*
>> + * A generic stack depot implementation
>> + *
>> + * Author: Alexander Potapenko <glider@google.com>
>> + * Copyright (C) 2016 Google, Inc.
>> + *
>> + * Based on code by Dmitry Chernenkov.
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> + * it under the terms of the GNU General Public License as published by
>> + * the Free Software Foundation; either version 2 of the License, or
>> + * (at your option) any later version.
>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>> + * GNU General Public License for more details.
>> + *
>> + */
>> +
>> +#ifndef _LINUX_STACKDEPOT_H
>> +#define _LINUX_STACKDEPOT_H
>> +
>> +typedef u32 depot_stack_handle;
>
> I'll rename this to depot_stack_handle_t, which is a pretty strong
> kernel convention.
Ok, thank you!
>> +struct stack_trace;
>> +
>> +depot_stack_handle depot_save_stack(struct stack_trace *trace, gfp_t fl=
ags);
>> +
>> +void depot_fetch_stack(depot_stack_handle handle, struct stack_trace *t=
race);
>> +
>> +#endif
>> diff --git a/lib/Kconfig b/lib/Kconfig
>> index ee38a3f..8a60a53 100644
>> --- a/lib/Kconfig
>> +++ b/lib/Kconfig
>> @@ -543,4 +543,7 @@ config ARCH_HAS_PMEM_API
>>  config ARCH_HAS_MMIO_FLUSH
>>       bool
>>
>> +config STACKDEPOT
>> +  bool
>> +
>>  endmenu
>> diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
>> index 0e4d2b3..468316d 100644
>> --- a/lib/Kconfig.kasan
>> +++ b/lib/Kconfig.kasan
>> @@ -7,6 +7,7 @@ config KASAN
>>       bool "KASan: runtime memory debugger"
>>       depends on SLUB_DEBUG || (SLAB && !DEBUG_SLAB)
>>       select CONSTRUCTORS
>> +  select STACKDEPOT if SLAB
>>       help
>>         Enables kernel address sanitizer - runtime memory debugger,
>>         designed to find out-of-bounds accesses and use-after-free bugs.
>
> Something weird happened to the Kconfig whitespace.  I'll fix that.
Thanks!
>



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
