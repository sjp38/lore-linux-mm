Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0F76B0254
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 07:53:12 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id p65so69329855wmp.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 04:53:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hz10si18918850wjb.190.2016.03.07.04.53.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Mar 2016 04:53:11 -0800 (PST)
Subject: Re: 4.5.0-rc6: kernel BUG at ../mm/memory.c:1879
References: <nbjnq6$fim$1@ger.gmane.org> <56DD795C.9020903@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56DD79B6.6030704@suse.cz>
Date: Mon, 7 Mar 2016 13:53:10 +0100
MIME-Version: 1.0
In-Reply-To: <56DD795C.9020903@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Matwey V. Kornilov" <matwey.kornilov@gmail.com>, linux-mm@kvack.org
Cc: Rusty Russell <rusty@rustcorp.com.au>, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>

On 03/07/2016 01:51 PM, Vlastimil Babka wrote:
> [+CC ARM, module maintainers/lists]
>
> On 03/07/2016 12:14 PM, Matwey V. Kornilov wrote:
>>
>> Hello,
>>
>> I see the following when try to boot 4.5.0-rc6 on ARM TI AM33xx based board.
>>
>>       [   13.907631] ------------[ cut here ]------------
>>       [   13.912323] kernel BUG at ../mm/memory.c:1879!
>
> That's:
> BUG_ON(addr >= end);
>
> where:
> end = addr + size;
>
> All these variables are unsigned long, so they overflown?
>
> I don't know ARM much, and there's no code for decodecode, but if I get
> the calling convention correctly, and the registers didn't change, both
> addr is r1 and size is r2, i.e. both bf006000. Weird.

OK, wrong, according to followup mail from Matwey which I'm pasting here 
to include the CC list:

===
I believe the following kgdb backtrace is relevant.

size = 0 for some reason in apply_to_page_range
This means that end == addr.

(gdb) bt
#0  apply_to_page_range (mm=0xc11d3190 <init_mm>, addr=3204472832,
size=0, fn=0xc0231cec <change_page_range>, data=0xdb5c3de8)
     at ../mm/memory.c:1876
#1  0xc0231dc4 in change_memory_common (addr=3204472832,
numpages=<optimized out>, set_mask=<optimized out>, clear_mask=0)
     at ../arch/arm/mm/pageattr.c:61
#2  0xc0231e30 in set_memory_ro (addr=<optimized out>,
numpages=<optimized out>) at ../arch/arm/mm/pageattr.c:70
#3  0xc02fd5b4 in frob_rodata (layout=<optimized out>,
set_memory=0xbf006000) at ../kernel/module.c:1983
#4  0xc02ff4f8 in module_enable_ro (mod=<optimized out>) at
../kernel/module.c:2011
#5  0xc0301c80 in complete_formation (info=<optimized out>,
mod=<optimized out>) at ../kernel/module.c:3494
#6  load_module (info=0xdb5c3f40, uargs=<optimized out>,
flags=<optimized out>) at ../kernel/module.c:3622
#7  0xc0302120 in SYSC_finit_module (flags=<optimized out>,
uargs=<optimized out>, fd=<optimized out>) at ../kernel/module.c:3741
#8  SyS_finit_module (fd=6, uargs=-1226082716, flags=0) at
../kernel/module.c:3722
#9  0xc021c140 in arm_elf_read_implies_exec (x=<optimized out>,
executable_stack=-1090494464) at ../arch/arm/kernel/elf.c:90
#10 0x00000006 in __vectors_start ()
Backtrace stopped: previous frame inner to this frame (corrupt stack?)

>
>>       [   13.916795] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
>>       [   13.922663] Modules linked in:
>>       [   13.925761] CPU: 0 PID: 242 Comm: systemd-udevd Not tainted 4.5.0-rc6-3.ga55dde2-default #1
>>       [   13.934153] Hardware name: Generic AM33XX (Flattened Device Tree)
>>       [   13.940281] task: c2da2040 ti: c2db4000 task.ti: c2db4000
>>       [   13.945738] PC is at apply_to_page_range+0x23c/0x240
>>       [   13.950741] LR is at change_memory_common+0x94/0xe0
>>       [   13.955648] pc : [<c03b333c>]    lr : [<c0231dc4>]    psr: 60010013
>>       [   13.955648] sp : c2db5d88  ip : c2db5dd8  fp : c2db5dd4
>>       [   13.967182] r10: bf002080  r9 : c2db5de8  r8 : c0231cec
>>       [   13.972434] r7 : bf002180  r6 : bf006000  r5 : bf006000  r4 : bf006000
>>       [   13.978995] r3 : c0231cec  r2 : bf006000  r1 : bf006000  r0 : c11d3190
>>       [   13.985559] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
>>       [   13.992732] Control: 10c5387d  Table: 82dc0019  DAC: 00000055
>>       [   13.998509] Process systemd-udevd (pid: 242, stack limit = 0xc2db4220)
>>       [   14.005070] Stack: (0xc2db5d88 to 0xc2db6000)
>>       [   14.009457] 5d80:                   bf005fff c11d3190 c11d3190 00000001 c1187dc4 c136c540
>>       [   14.017682] 5da0: bf006000 c11d3190 c2db5dd4 bf006000 00000000 bf006000 bf002180 00000000
>>       [   14.025907] 5dc0: c118350c bf002080 c2db5e14 c2db5dd8 c0231dc4 c03b310c c2db5de8 0000000c
>>       [   14.034130] 5de0: c2db5dfc c2db5df0 00000080 00000000 c2db5e4c c0231e10 bf0021ac bf002180
>>       [   14.042355] 5e00: bf002180 bf0021ac c2db5e24 c2db5e18 c0231e30 c0231d3c c2db5e3c c2db5e28
>>       [   14.050579] 5e20: c02fd5b4 c0231e1c c0231e10 bf0021ac c2db5e5c c2db5e40 c02ff4f8 c02fd568
>>       [   14.058802] 5e40: 00000001 bf00208c c2db5f40 bf002180 c2db5f34 c2db5e60 c0301c80 c02ff4ac
>>       [   14.067025] 5e60: bf002080 c042d74c 00000000 00000000 bf000000 c118350c c0b359cc 00000000
>>       [   14.075250] 5e80: bf00208c c118350c bf003000 c2db5ea0 bf002190 bf00208c 000014e4 00000000
>>       [   14.083473] 5ea0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
>>       [   14.091695] 5ec0: 00000000 00000000 6e72656b 00006c65 00000000 00000000 00000000 00000000
>>       [   14.099918] 5ee0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
>>       [   14.108143] 5f00: 00000000 dc8ba700 00000010 00000000 00000006 b6e73664 0000017b c021c308
>>       [   14.116367] 5f20: c2db4000 00000000 c2db5fa4 c2db5f38 c0302120 c03009ac 00000002 00000000
>>       [   14.124590] 5f40: d0851000 000014e4 d0851f0c d085180b d0851ca4 00003000 00003110 00000000
>>       [   14.132814] 5f60: 00000000 00000000 00001538 0000001b 0000001c 00000014 00000011 0000000d
>>       [   14.141036] 5f80: 00000000 00000000 00000000 7f611780 00000000 00000000 00000000 c2db5fa8
>>       [   14.149259] 5fa0: c021c140 c0302090 7f611780 00000000 00000006 b6e73664 00000000 7f611830
>>       [   14.157484] 5fc0: 7f611780 00000000 00000000 0000017b 00000000 00000000 00020000 80a76238
>>       [   14.165707] 5fe0: be8c8058 be8c8048 b6e69de0 b6d8db40 60010010 00000006 45145044 91104437
>>       [   14.173957] [<c03b333c>] (apply_to_page_range) from [<c0231dc4>] (change_memory_common+0x94/0xe0)
>>       [   14.182888] [<c0231dc4>] (change_memory_common) from [<c0231e30>] (set_memory_ro+0x20/0x28)
>>       [   14.191307] [<c0231e30>] (set_memory_ro) from [<c02fd5b4>] (frob_rodata+0x58/0x6c)
>>       [   14.198930] [<c02fd5b4>] (frob_rodata) from [<c02ff4f8>] (module_enable_ro+0x58/0x60)
>
> These just seem to pass on whatever module loader told them.
>
>>       [   14.206811] [<c02ff4f8>] (module_enable_ro) from [<c0301c80>] (load_module+0x12e0/0x1548)
>
> This uses mod->core_layout to get the range, so maybe that's what's wrong?
>
>>       [   14.215039] [<c0301c80>] (load_module) from [<c0302120>] (SyS_finit_module+0x9c/0xd8)
>>       [   14.222920] [<c0302120>] (SyS_finit_module) from [<c021c140>] (ret_fast_syscall+0x0/0x34)
>>       [   14.231148] Code: e3500000 1afffff4 e51a3008 eaffffe5 (e7f001f2)
>>       [   14.237282] ---[ end trace e25b4430ecf4fcdd ]---
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
