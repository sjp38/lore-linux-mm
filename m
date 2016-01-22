Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id ACF6E6B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 00:39:16 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id vt7so54452203obb.1
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 21:39:16 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0071.outbound.protection.outlook.com. [104.47.2.71])
        by mx.google.com with ESMTPS id j5si4214937obz.28.2016.01.21.21.39.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 21 Jan 2016 21:39:15 -0800 (PST)
Subject: Re: [PATCH, REGRESSION v3] mm: make apply_to_page_range more robust
References: <56A06EC7.9060106@nextfour.com>
 <alpine.DEB.2.10.1601211511230.9813@chino.kir.corp.google.com>
From: =?UTF-8?Q?Mika_Penttil=c3=a4?= <mika.penttila@nextfour.com>
Message-ID: <56A1C074.6040602@nextfour.com>
Date: Fri, 22 Jan 2016 07:39:00 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1601211511230.9813@chino.kir.corp.google.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>

On 01/22/2016 01:12 AM, David Rientjes wrote:
> On Thu, 21 Jan 2016, Mika PenttilA? wrote:
> 
>> Recent changes (4.4.0+) in module loader triggered oops on ARM : 
>>
>> The module in question is in-tree module :
>> drivers/misc/ti-st/st_drv.ko
>>
>> The BUG is here :
>>
>> [ 53.638335] ------------[ cut here ]------------
>> [ 53.642967] kernel BUG at mm/memory.c:1878!
>> [ 53.647153] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
>> [ 53.652987] Modules linked in:
>> [ 53.656061] CPU: 0 PID: 483 Comm: insmod Not tainted 4.4.0 #3
>> [ 53.661808] Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
>> [ 53.668338] task: a989d400 ti: 9e6a2000 task.ti: 9e6a2000
>> [ 53.673751] PC is at apply_to_page_range+0x204/0x224
>> [ 53.678723] LR is at change_memory_common+0x90/0xdc
>> [ 53.683604] pc : [<800ca0ec>] lr : [<8001d668>] psr: 600b0013
>> [ 53.683604] sp : 9e6a3e38 ip : 8001d6b4 fp : 7f0042fc
>> [ 53.695082] r10: 00000000 r9 : 9e6a3e90 r8 : 00000080
>> [ 53.700309] r7 : 00000000 r6 : 7f008000 r5 : 7f008000 r4 : 7f008000
>> [ 53.706837] r3 : 8001d5a4 r2 : 7f008000 r1 : 7f008000 r0 : 80b8d3c0
>> [ 53.713368] Flags: nZCv IRQs on FIQs on Mode SVC_32 ISA ARM Segment user
>> [ 53.720504] Control: 10c5387d Table: 2e6b804a DAC: 00000055
>> [ 53.726252] Process insmod (pid: 483, stack limit = 0x9e6a2210)
>> [ 53.732173] Stack: (0x9e6a3e38 to 0x9e6a4000)
>> [ 53.736532] 3e20: 7f007fff 7f008000
>> [ 53.744714] 3e40: 80b8d3c0 80b8d3c0 00000000 7f007000 7f00426c 7f008000 00000000 7f008000
>> [ 53.752895] 3e60: 7f004140 7f008000 00000000 00000080 00000000 00000000 7f0042fc 8001d668
>> [ 53.761076] 3e80: 9e6a3e90 00000000 8001d6b4 7f00426c 00000080 00000000 9e6a3f58 7f004140
>> [ 53.769257] 3ea0: 7f004240 7f00414c 00000000 8008bbe0 00000000 7f000000 00000000 00000000
>> [ 53.777438] 3ec0: a8b12f00 0001cfd4 7f004250 7f004240 80b8159c 00000000 000000e0 7f0042fc
>> [ 53.785619] 3ee0: c183d000 000074f8 000018fd 00000000 0b30000c 00000000 00000000 7f002024
>> [ 53.793800] 3f00: 00000002 00000000 00000000 00000000 00000000 00000000 00000000 00000000
>> [ 53.801980] 3f20: 00000000 00000000 00000000 00000000 00000040 00000000 00000003 0001cfd4
>> [ 53.810161] 3f40: 0000017b 8000f7e4 9e6a2000 00000000 00000002 8008c498 c183d000 000074f8
>> [ 53.818342] 3f60: c1841588 c1841409 c1842950 00005000 000052a0 00000000 00000000 00000000
>> [ 53.826523] 3f80: 00000023 00000024 0000001a 0000001e 00000016 00000000 00000000 00000000
>> [ 53.834703] 3fa0: 003e3d60 8000f640 00000000 00000000 00000003 0001cfd4 00000000 003e3d60
>> [ 53.842884] 3fc0: 00000000 00000000 003e3d60 0000017b 003e3d20 7eabc9d4 76f2c000 00000002
>> [ 53.851065] 3fe0: 7eabc990 7eabc980 00016320 76e81d00 600b0010 00000003 00000000 00000000
>> [ 53.859256] [<800ca0ec>] (apply_to_page_range) from [<8001d668>] (change_memory_common+0x90/0xdc)
>> [ 53.868139] [<8001d668>] (change_memory_common) from [<8008bbe0>] (load_module+0x194c/0x2068)
>> [ 53.876671] [<8008bbe0>] (load_module) from [<8008c498>] (SyS_finit_module+0x64/0x74)
>> [ 53.884512] [<8008c498>] (SyS_finit_module) from [<8000f640>] (ret_fast_syscall+0x0/0x34)
>> [ 53.892694] Code: e0834104 eaffffbc e51a1008 eaffffac (e7f001f2)
>> [ 53.898792] ---[ end trace fe43fc78ebde29a3 ]---
>>
> 
> NACK to your patch as it is just covering up buggy code silently.  The 
> problem needs to be addressed in change_memory_common() to return if there 
> is no size to change (numpages == 0).  It's a two line fix to that 
> function.
> 

That surely would make this particular problem disappear on ARM. But, we probably get similar behavior on other arches too (arm64 at least).

Also, you are suggesting it is ok to call set_memory_xx() with numpages==0, but bug to call apply_to_page_range() with size==0 ? 
I think these are similar apis with a size type of argument. Functions taking a range [start, end) are a different story and should be illegal to call start==end.

Also, taking a fast look at all call sites of apply_to_page_range not all are checking for !size (some Xen code for instance) and could trigger a kernel BUG (potentially triggerable from user code). So something that was meant to help finding buggy code could be turned into an easy way to DOS. 

Thanks,
--Mika




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
