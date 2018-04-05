Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2C4086B000C
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 15:23:02 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t27so17500456qki.11
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 12:23:02 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0114.outbound.protection.outlook.com. [104.47.38.114])
        by mx.google.com with ESMTPS id t3si4228744qtd.368.2018.04.05.12.23.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 12:23:00 -0700 (PDT)
From: Sasha Levin <Alexander.Levin@microsoft.com>
Subject: Re: [PATCH v2 1/2] mm: uninitialized struct page poisoning sanity
 checking
Date: Thu, 5 Apr 2018 19:22:58 +0000
Message-ID: <20180405192256.GQ7561@sasha-vm>
References: <20180131210300.22963-1-pasha.tatashin@oracle.com>
 <20180131210300.22963-2-pasha.tatashin@oracle.com>
 <20180313234333.j3i43yxeawx5d67x@sasha-lappy>
 <CAGM2reaPK=ZcLBOnmBiC2-u86DZC6ukOhL1xxZofB2OTW3ozoA@mail.gmail.com>
 <20180314005350.6xdda2uqzuy4n3o6@sasha-lappy>
 <20180315190430.o3vs7uxlafzdwgzd@xakep.localdomain>
 <20180315204312.n7p4zzrftgg6m7zw@sasha-lappy>
 <20180404021746.m77czxidkaumkses@xakep.localdomain>
 <20180405134940.2yzx4p7hjed7lfdk@xakep.localdomain>
In-Reply-To: <20180405134940.2yzx4p7hjed7lfdk@xakep.localdomain>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <A6BAACC377512341912E3366B4DA7D4A@namprd21.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "daniel.m.jordan@oracle.com" <daniel.m.jordan@oracle.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "mhocko@suse.com" <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "bharata@linux.vnet.ibm.com" <bharata@linux.vnet.ibm.com>

On Thu, Apr 05, 2018 at 09:49:40AM -0400, Pavel Tatashin wrote:
>> Hi Sasha,
>>
>> I have registered on Azure's portal, and created a VM with 4 CPUs and 16=
G
>> of RAM. However, I still was not able to reproduce the boot bug you foun=
d.
>
>I have also tried to reproduce this issue on Windows 10 + Hyper-V, still
>unsuccessful.

I'm not sure why you can't reproduce it. I built a 4.16 kernel + your 6
patches on top, and booting on a D64s_v3 instance gives me this:

[    1.205726] page:ffffea0084000000 is uninitialized and poisoned
[    1.205737] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffff=
ffffffffffff
[    1.207016] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffff=
ffffffffffff
[    1.208014] page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
[    1.209087] ------------[ cut here ]------------
[    1.210000] kernel BUG at ./include/linux/mm.h:901!
[    1.210015] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
[    1.211000] Modules linked in:
[    1.211000] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.16.0+ #10
[    1.211000] Hardware name: Microsoft Corporation Virtual Machine/Virtual=
 Machine, BIOS 090007  06/02/2017
[    1.211000] RIP: 0010:get_nid_for_pfn+0x6e/0xa0
[    1.211000] RSP: 0000:ffff881c63cbfc28 EFLAGS: 00010246
[    1.211000] RAX: 0000000000000000 RBX: ffffea0084000000 RCX: 00000000000=
00000
[    1.211000] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffffed038c7=
97f78
[    1.211000] RBP: ffff881c63cbfc30 R08: ffff88401174a480 R09: 00000000000=
00000
[    1.211000] R10: ffff8840e00d6040 R11: 0000000000000000 R12: 00000000021=
07fff
[    1.211000] R13: fffffbfff4648234 R14: 0000000000000001 R15: 00000000000=
00001
[    1.211000] FS:  0000000000000000(0000) GS:ffff881c6aa00000(0000) knlGS:=
0000000000000000
[    1.211000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    1.211000] CR2: 0000000000000000 CR3: 0000002814216000 CR4: 00000000003=
406f0
[    1.211000] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[    1.211000] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 00000000000=
00400
[    1.211000] Call Trace:
[    1.211000]  register_mem_sect_under_node+0x1a2/0x530
[    1.211000]  link_mem_sections+0x12d/0x200
[    1.211000]  topology_init+0xe6/0x178
[    1.211000]  ? enable_cpu0_hotplug+0x1a/0x1a
[    1.211000]  do_one_initcall+0xb0/0x31f
[    1.211000]  ? initcall_blacklisted+0x220/0x220
[    1.211000]  ? up_write+0x78/0x140
[    1.211000]  ? up_read+0x40/0x40
[    1.211000]  ? __asan_register_globals+0x30/0xa0
[    1.211000]  ? kasan_unpoison_shadow+0x35/0x50
[    1.211000]  kernel_init_freeable+0x69d/0x764
[    1.211000]  ? start_kernel+0x8fd/0x8fd
[    1.211000]  ? finish_task_switch+0x1b6/0x9c0
[    1.211000]  ? rest_init+0x120/0x120
[    1.211000]  kernel_init+0x13/0x150
[    1.211000]  ? rest_init+0x120/0x120
[    1.211000]  ret_from_fork+0x3a/0x50
[    1.211000] Code: ff df 48 c1 ea 03 80 3c 02 00 75 34 48 8b 03 48 83 f8 =
ff 74 07 48 c1 e8 36 5b 5d c3 48 c7 c6 00 ca f5 9e 48 89 df e8 82 13 d5 fd =
<0f> 0b 48 c7 c7 00 24 2e a1 e8 05 36 c1 fe e8 af 07 ea fd eb ac
[    1.211000] RIP: get_nid_for_pfn+0x6e/0xa0 RSP: ffff881c63cbfc28
[    1.211017] ---[ end trace d86a03841f7ef229 ]---
[    1.212020] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[    1.213000] BUG: KASAN: stack-out-of-bounds in update_stack_state+0x64c/=
0x810
[    1.213000] Read of size 8 at addr ffff881c63cbfaf8 by task swapper/0/1
[    1.213000]
[    1.213000] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G      D          4.1=
6.0+ #10
[    1.213000] Hardware name: Microsoft Corporation Virtual Machine/Virtual=
 Machine, BIOS 090007  06/02/2017
[    1.213000] Call Trace:
[    1.213000]  dump_stack+0xe3/0x196
[    1.213000]  ? _atomic_dec_and_lock+0x31a/0x31a
[    1.213000]  ? vprintk_func+0x27/0x60
[    1.213000]  ? printk+0x9c/0xc3
[    1.213000]  ? show_regs_print_info+0x10/0x10
[    1.213000]  ? lock_acquire+0x760/0x760
[    1.213000]  ? update_stack_state+0x64c/0x810
[    1.213000]  print_address_description+0xe4/0x480
[    1.213000]  ? update_stack_state+0x64c/0x810
[    1.213000]  kasan_report+0x1d7/0x460
[    1.213000]  ? console_unlock+0x652/0xe90
[    1.213000]  ? update_stack_state+0x64c/0x810
[    1.213000]  __asan_report_load8_noabort+0x19/0x20
[    1.213000]  update_stack_state+0x64c/0x810
[    1.213000]  ? __read_once_size_nocheck.constprop.2+0x50/0x50
[    1.213000]  ? put_files_struct+0x2a4/0x390
[    1.213000]  ? unwind_next_frame+0x202/0x1230
[    1.213000]  unwind_next_frame+0x202/0x1230
[    1.213000]  ? unwind_dump+0x590/0x590
[    1.213000]  ? get_stack_info+0x42/0x3b0
[    1.213000]  ? debug_check_no_locks_freed+0x300/0x300
[    1.213000]  ? __unwind_start+0x170/0x380
[    1.213000]  __save_stack_trace+0x82/0x140
[    1.213000]  ? put_files_struct+0x2a4/0x390
[    1.213000]  save_stack_trace+0x39/0x70
[    1.213000]  save_stack+0x43/0xd0
[    1.213000]  ? save_stack+0x43/0xd0
[    1.213000]  ? __kasan_slab_free+0x11f/0x170
[    1.213000]  ? kasan_slab_free+0xe/0x10
[    1.213000]  ? kmem_cache_free+0xe6/0x560
[    1.213000]  ? put_files_struct+0x2a4/0x390
[    1.213000]  ? _get_random_bytes+0x162/0x5a0
[    1.213000]  ? trace_hardirqs_off+0xd/0x10
[    1.213000]  ? lock_acquire+0x212/0x760
[    1.213000]  ? rcuwait_wake_up+0x15e/0x2c0
[    1.213000]  ? lock_acquire+0x212/0x760
[    1.213000]  ? free_obj_work+0x8a0/0x8a0
[    1.213000]  ? lock_acquire+0x212/0x760
[    1.213000]  ? acct_collect+0x776/0xe80
[    1.213000]  ? acct_collect+0x2e4/0xe80
[    1.213000]  ? acct_collect+0x2e4/0xe80
[    1.213000]  ? lock_acquire+0x760/0x760
[    1.213000]  ? lock_downgrade+0x910/0x910
[    1.213000]  __kasan_slab_free+0x11f/0x170
[    1.213000]  ? put_files_struct+0x2a4/0x390
[    1.213000]  kasan_slab_free+0xe/0x10
[    1.213000]  kmem_cache_free+0xe6/0x560
[    1.213000]  put_files_struct+0x2a4/0x390
[    1.213000]  ? get_files_struct+0x80/0x80
[    1.213000]  ? do_raw_spin_trylock+0x1f0/0x1f0
[    1.213000]  exit_files+0x83/0xc0
[    1.213000]  do_exit+0x9be/0x2190
[    1.213000]  ? do_invalid_op+0x20/0x30
[    1.213000]  ? mm_update_next_owner+0x1200/0x1200
[    1.213000]  ? get_nid_for_pfn+0x6e/0xa0
[    1.213000]  ? get_nid_for_pfn+0x6e/0xa0
[    1.213000]  ? register_mem_sect_under_node+0x1a2/0x530
[    1.213000]  ? link_mem_sections+0x12d/0x200
[    1.213000]  ? topology_init+0xe6/0x178
[    1.213000]  ? enable_cpu0_hotplug+0x1a/0x1a
[    1.213000]  ? do_one_initcall+0xb0/0x31f
[    1.213000]  ? initcall_blacklisted+0x220/0x220
[    1.213000]  ? up_write+0x78/0x140
[    1.213000]  ? up_read+0x40/0x40
[    1.213000]  ? __asan_register_globals+0x30/0xa0
[    1.213000]  ? kasan_unpoison_shadow+0x35/0x50
[    1.213000]  ? kernel_init_freeable+0x69d/0x764
[    1.213000]  ? start_kernel+0x8fd/0x8fd
[    1.213000]  ? finish_task_switch+0x1b6/0x9c0
[    1.213000]  ? rest_init+0x120/0x120
[    1.213000]  rewind_stack_do_exit+0x17/0x20
[    1.213000]
[    1.213000] The buggy address belongs to the page:
[    1.213000] page:ffffea00718f2fc0 count:0 mapcount:0 mapping:00000000000=
00000 index:0x0
[    1.213000] flags: 0x17ffffc0000000()
[    1.213000] raw: 0017ffffc0000000 0000000000000000 0000000000000000 0000=
0000ffffffff
[    1.213000] raw: ffffea00718f2fe0 ffffea00718f2fe0 0000000000000000 0000=
000000000000
[    1.213000] page dumped because: kasan: bad access detected
[    1.213000]
[    1.213000] Memory state around the buggy address:
[    1.213000]  ffff881c63cbf980: 00 00 00 00 00 00 00 00 00 00 00 00 00 00=
 00 00
[    1.213000]  ffff881c63cbfa00: 00 00 00 00 00 00 00 00 00 00 00 00 00 f1=
 f1 f1
[    1.213000] >ffff881c63cbfa80: f1 f8 f2 f2 f2 00 00 00 00 00 00 00 00 00=
 f3 f3
[    1.213000]                                                             =
    ^
[    1.213000]  ffff881c63cbfb00: f3 f3 00 00 00 00 00 00 00 00 00 00 00 00=
 00 00
[    1.213000]  ffff881c63cbfb80: f1 f1 f1 f1 00 f2 f2 f2 f2 f2 f2 f2 00 f2=
 f2 f2
[    1.213000] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[    1.213033] Kernel panic - not syncing: Attempted to kill init! exitcode=
=3D0x0000000b
[    1.213033]
[    1.214000] ---[ end Kernel panic - not syncing: Attempted to kill init!=
 exitcode=3D0x0000000b=
