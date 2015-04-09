Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7FB6B0032
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 00:35:38 -0400 (EDT)
Received: by lagv1 with SMTP id v1so80905183lag.3
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 21:35:37 -0700 (PDT)
Received: from mail-la0-x22e.google.com (mail-la0-x22e.google.com. [2a00:1450:4010:c03::22e])
        by mx.google.com with ESMTPS id cs3si10444116lbb.138.2015.04.08.21.35.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Apr 2015 21:35:36 -0700 (PDT)
Received: by layy10 with SMTP id y10so80892627lay.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 21:35:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGRGNgUseiLaKz+iPoe7U73HEu22durZjxROu-NE0EZcThhysA@mail.gmail.com>
References: <20150408165920.25007.6869.stgit@buzz>
	<55255F84.6060608@yandex-team.ru>
	<CAGRGNgUseiLaKz+iPoe7U73HEu22durZjxROu-NE0EZcThhysA@mail.gmail.com>
Date: Thu, 9 Apr 2015 07:35:35 +0300
Message-ID: <CALYGNiPLJpMq3fjrjNbd0MotYLpq0Vo_Y+aAZUFx6ebG90vTsw@mail.gmail.com>
Subject: Re: [PATCH] of: return NUMA_NO_NODE from fallback of_node_to_nid()
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julian Calaby <julian.calaby@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Grant Likely <grant.likely@linaro.org>, devicetree <devicetree@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

On Thu, Apr 9, 2015 at 2:12 AM, Julian Calaby <julian.calaby@gmail.com> wrote:
> Hi Konstantin,
>
> On Thu, Apr 9, 2015 at 3:04 AM, Konstantin Khlebnikov
> <khlebnikov@yandex-team.ru> wrote:
>> On 08.04.2015 19:59, Konstantin Khlebnikov wrote:
>>>
>>> Node 0 might be offline as well as any other numa node,
>>> in this case kernel cannot handle memory allocation and crashes.
>>
>>
>> Example:
>>
>> [    0.027133] ------------[ cut here ]------------
>> [    0.027938] kernel BUG at include/linux/gfp.h:322!
>> [    0.028000] invalid opcode: 0000 [#1] SMP
>> [    0.028000] Modules linked in:
>> [    0.028000] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.0.0-rc7 #12
>> [    0.028000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
>> rel-1.7.5.1-0-g8936dbb-20141113_115728-nilsson.home.kraxel.org 04/01/2014
>> [    0.028000] task: ffff88007d3f8000 ti: ffff88007d3dc000 task.ti:
>> ffff88007d3dc000
>> [    0.028000] RIP: 0010:[<ffffffff8118574c>]  [<ffffffff8118574c>]
>> new_slab+0x30c/0x3c0
>> [    0.028000] RSP: 0000:ffff88007d3dfc28  EFLAGS: 00010246
>> [    0.028000] RAX: 0000000000000000 RBX: ffff88007d001800 RCX:
>> 0000000000000001
>> [    0.028000] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
>> 00000000002012d0
>> [    0.028000] RBP: ffff88007d3dfc58 R08: 0000000000000000 R09:
>> 0000000000000000
>> [    0.028000] R10: 0000000000000001 R11: ffff88007d02fe40 R12:
>> 00000000000000d0
>> [    0.028000] R13: 00000000000000c0 R14: 0000000000000015 R15:
>> 0000000000000000
>> [    0.028000] FS:  0000000000000000(0000) GS:ffff88007fc00000(0000)
>> knlGS:0000000000000000
>> [    0.028000] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> [    0.028000] CR2: 00000000ffffffff CR3: 0000000001e0e000 CR4:
>> 00000000000006f0
>> [    0.028000] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
>> 0000000000000000
>> [    0.028000] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
>> 0000000000000400
>> [    0.028000] Stack:
>> [    0.028000]  0000000000000000 ffff88007fc175d0 ffffea0001f40bc0
>> 00000000000000c0
>> [    0.028000]  ffff88007d001800 00000000000080d0 ffff88007d3dfd48
>> ffffffff8192da27
>> [    0.028000]  000000000000000d ffffffff81e27038 0000000000000000
>> 0000000000000000
>> [    0.028000] Call Trace:
>> [    0.028000]  [<ffffffff8192da27>] __slab_alloc+0x3df/0x55d
>> [    0.028000]  [<ffffffff8109a92b>] ? __lock_acquire+0xc1b/0x1f40
>> [    0.028000]  [<ffffffff810b1f2c>] ? __irq_domain_add+0x3c/0xe0
>> [    0.028000]  [<ffffffff810998f5>] ? trace_hardirqs_on_caller+0x105/0x1d0
>> [    0.028000]  [<ffffffff813631ab>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>> [    0.028000]  [<ffffffff811890ab>] __kmalloc_node+0xab/0x210
>> [    0.028000]  [<ffffffff810394df>] ? ioapic_read_entry+0x1f/0x50
>> [    0.028000]  [<ffffffff810b1f2c>] ? __irq_domain_add+0x3c/0xe0
>> [    0.028000]  [<ffffffff810b1f2c>] __irq_domain_add+0x3c/0xe0
>> [    0.028000]  [<ffffffff81039e0e>] mp_irqdomain_create+0x9e/0x120
>> [    0.028000]  [<ffffffff81f22d49>] setup_IO_APIC+0x6b/0x798
>> [    0.028000]  [<ffffffff810398a5>] ? clear_IO_APIC+0x45/0x70
>> [    0.028000]  [<ffffffff81f21f01>] apic_bsp_setup+0x87/0x96
>> [    0.028000]  [<ffffffff81f1fdb4>] native_smp_prepare_cpus+0x237/0x275
>> [    0.028000]  [<ffffffff81f131b7>] kernel_init_freeable+0x120/0x265
>> [    0.028000]  [<ffffffff819271f9>] ? kernel_init+0x9/0xf0
>> [    0.028000]  [<ffffffff819271f0>] ? rest_init+0x130/0x130
>> [    0.028000]  [<ffffffff819271f9>] kernel_init+0x9/0xf0
>> [    0.028000]  [<ffffffff8193b958>] ret_from_fork+0x58/0x90
>> [    0.028000]  [<ffffffff819271f0>] ? rest_init+0x130/0x130
>> [    0.028000] Code: 6b b6 ff ff 49 89 c5 e9 ce fd ff ff 31 c0 90 e9 74 ff
>> ff ff 49 c7 04 04 00 00 00 00 e9 05 ff ff ff 4c 89 e7 ff d0 e9 d9 fe ff ff
>> <0f> 0b 4c 8b 73 38 44 89 e7 81 cf 00 00 20 00 4c 89 f6 48 c1 ee
>> [    0.028000] RIP  [<ffffffff8118574c>] new_slab+0x30c/0x3c0
>> [    0.028000]  RSP <ffff88007d3dfc28>
>> [    0.028039] ---[ end trace f03690e70d7e4be6 ]---
>
> Shouldn't this be in the commit message?

I don't think that this will help somebody, kernel crashes here
only on rare hardware setup. This stack came from especially
patched qemu (because normal cannot configure memory-less nore 0)

>
> Thanks,
>
> --
> Julian Calaby
>
> Email: julian.calaby@gmail.com
> Profile: http://www.google.com/profiles/julian.calaby/
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
