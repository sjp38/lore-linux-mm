Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 445356B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 16:47:01 -0500 (EST)
Received: by mail-oi0-f41.google.com with SMTP id z81so3657970oif.0
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 13:47:01 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id qt1si11583488oeb.67.2015.01.22.13.47.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 22 Jan 2015 13:47:00 -0800 (PST)
Message-ID: <54C16F99.2000006@oracle.com>
Date: Thu, 22 Jan 2015 16:46:01 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9 00/17] Kernel address sanitizer - runtime memory debugger.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>	<1421859105-25253-1-git-send-email-a.ryabinin@samsung.com>	<54C042D2.4040809@oracle.com>	<CAPAsAGyXo=AMCU-2TbrrY=MPorg+Nd+WYS5nCAcjELZs91r4AQ@mail.gmail.com> <CAPAsAGyMyq_anQjErLa=L-0K3KmghMjoqzi0AdZOADTAECn1HA@mail.gmail.com>
In-Reply-To: <CAPAsAGyMyq_anQjErLa=L-0K3KmghMjoqzi0AdZOADTAECn1HA@mail.gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Marek <mmarek@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Linus Torvalds <torvalds@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>

On 01/22/2015 12:53 AM, Andrey Ryabinin wrote:
> 2015-01-22 8:34 GMT+03:00 Andrey Ryabinin <ryabinin.a.a@gmail.com>:
>> 2015-01-22 3:22 GMT+03:00 Sasha Levin <sasha.levin@oracle.com>:
>>> On 01/21/2015 11:51 AM, Andrey Ryabinin wrote:
>>>> Changes since v8:
>>>>       - Fixed unpoisoned redzones for not-allocated-yet object
>>>>           in newly allocated slab page. (from Dmitry C.)
>>>>
>>>>       - Some minor non-function cleanups in kasan internals.
>>>>
>>>>       - Added ack from Catalin
>>>>
>>>>       - Added stack instrumentation. With this we could detect
>>>>           out of bounds accesses in stack variables. (patch 12)
>>>>
>>>>       - Added globals instrumentation - catching out of bounds in
>>>>           global varibles. (patches 13-17)
>>>>
>>>>       - Shadow moved out from vmalloc into hole between vmemmap
>>>>           and %esp fixup stacks. For globals instrumentation
>>>>           we will need shadow backing modules addresses.
>>>>           So we need some sort of a shadow memory allocator
>>>>           (something like vmmemap_populate() function, except
>>>>           that it should be available after boot).
>>>>
>>>>           __vmalloc_node_range() suits that purpose, except that
>>>>           it can't be used for allocating for shadow in vmalloc
>>>>           area because shadow in vmalloc is already 'allocated'
>>>>           to protect us from other vmalloc users. So we need
>>>>           16TB of unused addresses. And we have big enough hole
>>>>           between vmemmap and %esp fixup stacks. So I moved shadow
>>>>           there.
>>>
>>> I'm not sure which new addition caused it, but I'm getting tons of
>>> false positives from platform drivers trying to access memory they
>>> don't "own" - because they expect to find hardware there.
>>>
>>
>> To be sure, that this is really false positives, could you try with
>> patches in attachment?
> 
> Attaching properly formed patches
> 

Yup, you're right - that did the trick.

Just to keep it going, here's a funny trace where kasan is catching issues
in ubsan: :)

[ 2652.320296] BUG: AddressSanitizer: out of bounds access in strnlen+0xa7/0xb0 at addr ffffffff97b5c9e4
[ 2652.320296] Read of size 1 by task trinity-c37/36198
[ 2652.320296] Address belongs to variable types__truncate+0xd884/0xde80
[ 2652.320296] CPU: 17 PID: 36198 Comm: trinity-c37 Not tainted 3.19.0-rc5-next-20150121-sasha-00064-g3c37e35-dirty #1809
[ 2652.320296]  0000000000000000 0000000000000000 ffff88011069f9f0 ffff88011069f938
[ 2652.320296]  ffffffff92e9e917 0000000000000039 0000000000000000 ffff88011069f9d8
[ 2652.320296]  ffffffff81b4a802 ffffffff843cd580 ffff880a70f24457 ffff00066c0a0100
[ 2652.320296] Call Trace:
[ 2652.320296]  [<ffffffff92e9e917>] dump_stack+0x4f/0x7b
[ 2652.320296]  [<ffffffff81b4a802>] kasan_report_error+0x642/0x9d0
[ 2652.320296]  [<ffffffff843cd580>] ? pointer.isra.16+0xe20/0xe20
[ 2652.320296]  [<ffffffff843bc882>] ? put_dec+0x72/0x90
[ 2652.320296]  [<ffffffff81b4abf1>] __asan_report_load1_noabort+0x61/0x80
[ 2652.320296]  [<ffffffff843b9a97>] ? strnlen+0xa7/0xb0
[ 2652.363888]  [<ffffffff843b9a97>] strnlen+0xa7/0xb0
[ 2652.363888]  [<ffffffff843c605f>] string.isra.0+0x3f/0x2f0
[ 2652.363888]  [<ffffffff843cd912>] vsnprintf+0x392/0x23b0
[ 2652.363888]  [<ffffffff843cd580>] ? pointer.isra.16+0xe20/0xe20
[ 2652.363888]  [<ffffffff81547101>] ? get_parent_ip+0x11/0x50
[ 2652.363888]  [<ffffffff843cf951>] vscnprintf+0x21/0x70
[ 2652.363888]  [<ffffffff81629ee0>] ? vprintk_emit+0xe0/0x960
[ 2652.363888]  [<ffffffff81629f14>] vprintk_emit+0x114/0x960
[ 2652.363888]  [<ffffffff843cf951>] ? vscnprintf+0x21/0x70
[ 2652.363888]  [<ffffffff8162aa1f>] vprintk_default+0x1f/0x30
[ 2652.363888]  [<ffffffff92e71c7c>] printk+0x97/0xb1
[ 2652.363888]  [<ffffffff92e71be5>] ? bitmap_weight+0xb/0xb
[ 2652.363888]  [<ffffffff92ea10f5>] ? val_to_string.constprop.3+0x191/0x1e4
[ 2652.363888]  [<ffffffff92ea1c4c>] __ubsan_handle_negate_overflow+0x13e/0x184
[ 2652.363888]  [<ffffffff92ea1b0e>] ? __ubsan_handle_divrem_overflow+0x284/0x284
[ 2652.363888]  [<ffffffff81612c20>] ? do_raw_spin_trylock+0x200/0x200
[ 2652.363888]  [<ffffffff81bba468>] rw_verify_area+0x318/0x440
[ 2652.363888]  [<ffffffff81bbe816>] vfs_read+0x106/0x490
[ 2652.363888]  [<ffffffff81c4db19>] ? __fget_light+0x249/0x370
[ 2652.363888]  [<ffffffff81bbecb2>] SyS_read+0x112/0x280
[ 2652.363888]  [<ffffffff81bbeba0>] ? vfs_read+0x490/0x490
[ 2652.363888]  [<ffffffff815fb1f9>] ? trace_hardirqs_on_caller+0x519/0x850
[ 2652.363888]  [<ffffffff92f64b42>] tracesys_phase2+0xdc/0xe1
[ 2652.363888] Memory state around the buggy address:
[ 2652.363888]  ffffffff97b5c880: fa fa fa fa 04 fa fa fa fa fa fa fa 00 00 00 00
[ 2652.363888]  ffffffff97b5c900: 00 00 00 00 00 fa fa fa fa fa fa fa 00 00 00 fa
[ 2652.363888] >ffffffff97b5c980: fa fa fa fa 00 00 00 fa fa fa fa fa 04 fa fa fa
[ 2652.363888]                                                        ^
[ 2652.363888]  ffffffff97b5ca00: fa fa fa fa 00 00 00 00 00 00 00 00 00 fa fa fa
[ 2652.363888]  ffffffff97b5ca80: fa fa fa fa 00 00 00 00 00 fa fa fa fa fa fa fa


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
