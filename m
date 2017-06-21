Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id C89FC6B0419
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 12:23:35 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id p187so107005929oif.6
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 09:23:35 -0700 (PDT)
Received: from omzsmtpe02.verizonbusiness.com (omzsmtpe02.verizonbusiness.com. [199.249.25.209])
        by mx.google.com with ESMTPS id d4si5783063oib.386.2017.06.21.09.23.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 09:23:33 -0700 (PDT)
From: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>
Subject: Re: [PATCH 4/4] percpu: add tracepoint support for percpu memory
Date: Wed, 21 Jun 2017 16:18:37 +0000
Message-ID: <20170621161836.tv67op4hokja35bc@sasha-lappy>
References: <20170619232832.27116-1-dennisz@fb.com>
 <20170619232832.27116-5-dennisz@fb.com>
In-Reply-To: <20170619232832.27116-5-dennisz@fb.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6358A74F2432DE489C93D7CA6F5C14B9@vzwcorp.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kernel-team@fb.com" <kernel-team@fb.com>

On Mon, Jun 19, 2017 at 07:28:32PM -0400, Dennis Zhou wrote:
>Add support for tracepoints to the following events: chunk allocation,
>chunk free, area allocation, area free, and area allocation failure.
>This should let us replay percpu memory requests and evaluate
>corresponding decisions.

This patch breaks boot for me:

[    0.000000] DEBUG_LOCKS_WARN_ON(unlikely(early_boot_irqs_disabled))
[    0.000000] ------------[ cut here ]------------
[    0.000000] WARNING: CPU: 0 PID: 0 at kernel/locking/lockdep.c:2741 trac=
e_hardirqs_on_caller.cold.58+0x47/0x4e
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 4.12.0-rc6-next-2017=
0621+ #155
[    0.000000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.10.1-1ubuntu1 04/01/2014
[    0.000000] task: ffffffffb7831180 task.stack: ffffffffb7800000
[    0.000000] RIP: 0010:trace_hardirqs_on_caller.cold.58+0x47/0x4e
[    0.000000] RSP: 0000:ffffffffb78079d0 EFLAGS: 00010086 ORIG_RAX: 000000=
0000000000
[    0.000000] RAX: 0000000000000037 RBX: 0000000000000003 RCX: 00000000000=
00000
[    0.000000] RDX: 0000000000000000 RSI: 0000000000000001 RDI: 1ffffffff6f=
00ef6
[    0.000000] RBP: ffffffffb78079e0 R08: 0000000000000000 R09: ffffffffb78=
31180
[    0.000000] R10: 0000000000000000 R11: ffffffffb24e96ce R12: ffffffffb6b=
39b87
[    0.000000] R13: 00000000001f0001 R14: ffffffffb85603a0 R15: 00000000000=
02000
[    0.000000] FS:  0000000000000000(0000) GS:ffffffffb81be000(0000) knlGS:=
0000000000000000
[    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    0.000000] CR2: ffff88007fbff000 CR3: 000000006b828000 CR4: 00000000000=
406b0
[    0.000000] Call Trace:
[    0.000000]  trace_hardirqs_on+0xd/0x10
[    0.000000]  _raw_spin_unlock_irq+0x27/0x50
[    0.000000]  pcpu_setup_first_chunk+0x19c2/0x1c27
[    0.000000]  ? pcpu_free_alloc_info+0x4b/0x4b
[    0.000000]  ? vprintk_emit+0x403/0x480
[    0.000000]  ? __down_trylock_console_sem+0xb7/0xc0
[    0.000000]  ? __down_trylock_console_sem+0x6e/0xc0
[    0.000000]  ? vprintk_emit+0x362/0x480
[    0.000000]  ? vprintk_default+0x28/0x30
[    0.000000]  ? printk+0xb2/0xdd
[    0.000000]  ? snapshot_ioctl.cold.1+0x19/0x19
[    0.000000]  ? __alloc_bootmem_node_nopanic+0x88/0x96
[    0.000000]  pcpu_embed_first_chunk+0x7b0/0x8ef
[    0.000000]  ? pcpup_populate_pte+0xb/0xb
[    0.000000]  setup_per_cpu_areas+0x105/0x6d9
[    0.000000]  ? find_last_bit+0xa6/0xd0
[    0.000000]  start_kernel+0x25e/0x78f
[    0.000000]  ? thread_stack_cache_init+0xb/0xb
[    0.000000]  ? early_idt_handler_common+0x3b/0x52
[    0.000000]  ? early_idt_handler_array+0x120/0x120
[    0.000000]  ? early_idt_handler_array+0x120/0x120
[    0.000000]  x86_64_start_reservations+0x24/0x26
[    0.000000]  x86_64_start_kernel+0x143/0x166
[    0.000000]  secondary_startup_64+0x9f/0x9f
[    0.000000] Code: c6 a0 49 c6 b6 48 c7 c7 e0 49 c6 b6 e8 43 34 00 00 0f =
ff e9 ed 71 ce ff 48 c7 c6 c0 79 c6 b6 48 c7 c7 e0 49 c6 b6 e8 29 34 00 00 =
<0f> ff e9 d3 71 ce ff 48 c7 c6 20 7c c6 b6 48 c7 c7 e0 49 c6 b6=20
[    0.000000] random: print_oops_end_marker+0x30/0x50 get_random_bytes cal=
led with crng_init=3D0
[    0.000000] ---[ end trace f68728a0d3053b52 ]---
[    0.000000] BUG: unable to handle kernel paging request at 00000000fffff=
fff
[    0.000000] IP: native_write_msr+0x6/0x30
[    0.000000] PGD 0=20
[    0.000000] P4D 0=20
[    0.000000]=20
[    0.000000] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC KASAN
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Tainted: G        W       4.12.0=
-rc6-next-20170621+ #155
[    0.000000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS =
1.10.1-1ubuntu1 04/01/2014
[    0.000000] task: ffffffffb7831180 task.stack: ffffffffb7800000
[    0.000000] RIP: 0010:native_write_msr+0x6/0x30
[    0.000000] RSP: 0000:ffffffffb7807dc8 EFLAGS: 00010202
[    0.000000] RAX: 000000003ea15d43 RBX: ffff88003ea15d40 RCX: 000000004b5=
64d02
[    0.000000] RDX: 0000000000000000 RSI: 000000003ea15d43 RDI: 000000004b5=
64d02
[    0.000000] RBP: ffffffffb7807df0 R08: 0000000000000040 R09: 00000000000=
00000
[    0.000000] R10: 0000000000007100 R11: 000000007ffd6f00 R12: 00000000000=
00000
[    0.000000] R13: 1ffffffff6f00fc3 R14: ffffffffb7807eb8 R15: dffffc00000=
00000
[    0.000000] FS:  0000000000000000(0000) GS:ffff88003ea00000(0000) knlGS:=
0000000000000000
[    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    0.000000] CR2: 00000000ffffffff CR3: 000000006b828000 CR4: 00000000000=
406b0
[    0.000000] Call Trace:
[    0.000000]  ? kvm_guest_cpu_init+0x155/0x220
[    0.000000]  kvm_smp_prepare_boot_cpu+0x9/0x10
[    0.000000]  start_kernel+0x28c/0x78f
[    0.000000]  ? thread_stack_cache_init+0xb/0xb
[    0.000000]  ? early_idt_handler_common+0x3b/0x52
[    0.000000]  ? early_idt_handler_array+0x120/0x120
[    0.000000]  ? early_idt_handler_array+0x120/0x120
[    0.000000]  x86_64_start_reservations+0x24/0x26
[    0.000000]  x86_64_start_kernel+0x143/0x166
[    0.000000]  secondary_startup_64+0x9f/0x9f
[    0.000000] Code: c3 0f 21 c8 5d c3 0f 21 d0 5d c3 0f 21 d8 5d c3 0f 21 =
f0 5d c3 0f 0b 0f 1f 40 00 66 2e 0f 1f 84 00 00 00 00 00 89 f9 89 f0 0f 30 =
<0f> 1f 44 00 00 c3 48 89 d6 55 89 c2 48 c1 e6 20 48 89 e5 48 09=20
[    0.000000] RIP: native_write_msr+0x6/0x30 RSP: ffffffffb7807dc8
[    0.000000] CR2: 00000000ffffffff
[    0.000000] ---[ end trace f68728a0d3053b53 ]---
[    0.000000] Kernel panic - not syncing: Fatal exception
[    0.000000] ---[ end Kernel panic - not syncing: Fatal exception

--=20

Thanks,
Sasha=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
