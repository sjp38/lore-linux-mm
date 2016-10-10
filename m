Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A923D6B0069
	for <linux-mm@kvack.org>; Mon, 10 Oct 2016 06:48:06 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p80so36181157lfp.6
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 03:48:06 -0700 (PDT)
Received: from mail-lf0-x22b.google.com (mail-lf0-x22b.google.com. [2a00:1450:4010:c07::22b])
        by mx.google.com with ESMTPS id o4si16902777lfa.280.2016.10.10.03.48.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Oct 2016 03:48:04 -0700 (PDT)
Received: by mail-lf0-x22b.google.com with SMTP id b75so118595532lfg.3
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 03:48:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=Vgv3Mr=KftNyu21Zjpam8wN9TFvwy2KHLy9cKi_XsQfA@mail.gmail.com>
References: <57f9c82e.wswaLjJd7sV05RiZ%fengguang.wu@intel.com> <CAG_fn=Vgv3Mr=KftNyu21Zjpam8wN9TFvwy2KHLy9cKi_XsQfA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 10 Oct 2016 12:47:43 +0200
Message-ID: <CACT4Y+ZTRwbJy+a7vhEGt06GeFjMNOEL7tE-0dN1cH-EGNX98w@mail.gmail.com>
Subject: Re: [mm, kasan] 80a9201a59: INFO: rcu_sched stall on CPU (84741 ticks
 this GP) idle=140000000000000 (t=100000 jiffies q=1)
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: kernel test robot <fengguang.wu@intel.com>, LKP <lkp@01.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, wfg@linux.intel.com, Andrey Ryabinin <ryabinin.a.a@gmail.com>

+Andrey

mark_rodata_ro becomes extremely slow with KASAN. Frequently that
causes the rcu stall message, but then kernel boots fine.
It probably has something to do with large number of pgd? I had to
disable CONFIG_DEBUG_RODATA with KASAN.


On Mon, Oct 10, 2016 at 11:16 AM, 'Alexander Potapenko' via kasan-dev
<kasan-dev@googlegroups.com> wrote:
> The stack trace looks unrelated to KASAN.
>
> On Sun, Oct 9, 2016 at 6:31 AM, kernel test robot
> <fengguang.wu@intel.com> wrote:
>> Greetings,
>>
>> 0day kernel testing robot got the below dmesg and the first bad commit i=
s
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git maste=
r
>>
>> commit 80a9201a5965f4715d5c09790862e0df84ce0614
>> Author:     Alexander Potapenko <glider@google.com>
>> AuthorDate: Thu Jul 28 15:49:07 2016 -0700
>> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
>> CommitDate: Thu Jul 28 16:07:41 2016 -0700
>>
>>     mm, kasan: switch SLUB to stackdepot, enable memory quarantine for S=
LUB
>>
>>     For KASAN builds:
>>      - switch SLUB allocator to using stackdepot instead of storing the
>>        allocation/deallocation stacks in the objects;
>>      - change the freelist hook so that parts of the freelist can be put
>>        into the quarantine.
>>
>>     [aryabinin@virtuozzo.com: fixes]
>>       Link: http://lkml.kernel.org/r/1468601423-28676-1-git-send-email-a=
ryabinin@virtuozzo.com
>>     Link: http://lkml.kernel.org/r/1468347165-41906-3-git-send-email-gli=
der@google.com
>>     Signed-off-by: Alexander Potapenko <glider@google.com>
>>     Cc: Andrey Konovalov <adech.fo@gmail.com>
>>     Cc: Christoph Lameter <cl@linux.com>
>>     Cc: Dmitry Vyukov <dvyukov@google.com>
>>     Cc: Steven Rostedt (Red Hat) <rostedt@goodmis.org>
>>     Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>     Cc: Kostya Serebryany <kcc@google.com>
>>     Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
>>     Cc: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
>>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>>
>> +-----------------------------------------------------------------------=
-----+------------+------------+------------+
>> |                                                                       =
     | c146a2b98e | 80a9201a59 | a61bc9c9af |
>> +-----------------------------------------------------------------------=
-----+------------+------------+------------+
>> | boot_successes                                                        =
     | 655        | 86         | 9          |
>> | boot_failures                                                         =
     | 0          | 139        | 16         |
>> | INFO:rcu_sched_stall_on_CPU(#ticks_this_GP)idle=3D#(t=3D#jiffies_q=3D#=
)          | 0          | 139        | 10         |
>> | calltrace:mark_rodata_ro                                              =
     | 0          | 139        | 14         |
>> | Kernel_panic-not_syncing:VFS:Unable_to_mount_root_fs_on_unknown-block(=
#,#) | 0          | 0          | 2          |
>> | calltrace:prepare_namespace                                           =
     | 0          | 0          | 2          |
>> | WARNING:at_arch/x86/mm/dump_pagetables.c:#note_page                   =
     | 0          | 0          | 6          |
>> +-----------------------------------------------------------------------=
-----+------------+------------+------------+
>>
>> [   14.024541] Write protecting the kernel read-only data: 18432k
>> [   14.030857] Freeing unused kernel memory: 1936K (ffff88000e81c000 - f=
fff88000ea00000)
>> [   14.043192] Freeing unused kernel memory: 248K (ffff88000efc2000 - ff=
ff88000f000000)
>> [  114.005845] INFO: rcu_sched stall on CPU (84741 ticks this GP) idle=
=3D140000000000000 (t=3D100000 jiffies q=3D1)
>> [  114.009928] CPU: 0 PID: 1 Comm: swapper Not tainted 4.7.0-05999-g80a9=
201 #1
>> [  114.011362] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BI=
OS Debian-1.8.2-1 04/01/2014
>> [  114.013154]  0000000000000000 ffffffffacc40db8 ffffffffabfc7274 fffff=
fffacc40df8
>> [  114.014763]  ffffffffabae00ec 0000000000000001 0000000000000000 00000=
00000000000
>> [  114.016378]  00000019dcf1a68b ffffffffacc40f18 fffffffface7e488 fffff=
fffacc40e18
>> [  114.017988] Call Trace:
>> [  114.018504]  <IRQ>  [<ffffffffabfc7274>] dump_stack+0x19/0x1b
>> [  114.019739]  [<ffffffffabae00ec>] check_cpu_stall+0xc0/0x124
>> [  114.021041]  [<ffffffffabae0283>] rcu_check_callbacks+0x50/0xa0
>> [  114.022263]  [<ffffffffabae62fe>] update_process_times+0x2e/0x52
>> [  114.023503]  [<ffffffffabaf8f5f>] tick_sched_handle+0x66/0x6d
>> [  114.024813]  [<ffffffffabaf8fa3>] tick_sched_timer+0x3d/0x78
>> [  114.025977]  [<ffffffffabae733d>] __hrtimer_run_queues+0x252/0x45b
>> [  114.027461]  [<ffffffffabaf8f66>] ? tick_sched_handle+0x6d/0x6d
>> [  114.028793]  [<ffffffffabae70eb>] ? hrtimer_start_range_ns+0x315/0x31=
5
>> [  114.030130]  [<ffffffffaba29b24>] ? kvm_clock_get_cycles+0x9/0xb
>> [  114.031367]  [<ffffffffabaf1120>] ? ktime_get_update_offsets_now+0xf1=
/0x184
>> [  114.032784]  [<ffffffffabae76d4>] hrtimer_interrupt+0x8c/0x189
>> [  114.033983]  [<ffffffffaba1f190>] local_apic_timer_interrupt+0x42/0x4=
4
>> [  114.035337]  [<ffffffffac417ba8>] smp_apic_timer_interrupt+0x55/0x66
>> [  114.036636]  [<ffffffffac416b6d>] apic_timer_interrupt+0x7d/0x90
>> [  114.037864]  <EOI>  [<ffffffffaba37538>] ? note_page+0x2b/0x7af
>> [  114.039125]  [<ffffffffaba375db>] ? note_page+0xce/0x7af
>> [  114.040219]  [<ffffffffaba37fff>] ptdump_walk_pgd_level_core+0x343/0x=
483
>> [  114.041583]  [<ffffffffaba37cbc>] ? note_page+0x7af/0x7af
>> [  114.042577]  [<ffffffffaba38168>] ptdump_walk_pgd_level_checkwx+0x17/=
0x2f
>> [  114.043639]  [<ffffffffaba2dc93>] mark_rodata_ro+0x14b/0x152
>> [  114.044545]  [<ffffffffac40ce10>] kernel_init+0x29/0x100
>> [  114.045393]  [<ffffffffac4162df>] ret_from_fork+0x1f/0x40
>> [  114.046252]  [<ffffffffac40cde7>] ? rest_init+0xce/0xce
>> [  118.107577] x86/mm: Checked W+X mappings: passed, no W+X pages found.
>> [  118.113902] rcu-torture: rtc: ffffffffaddea720 ver: 1 tfle: 0 rta: 1 =
rtaf: 0 rtf: 0 rtmbe: 0 rtbke: 0 rtbre: 0 rtbf: 0 rtb: 0 nt: 1 barrier: 0/0=
:0 cbflood: 1
>>
>> git bisect start v4.8 v4.7 --
>> git bisect  bad e6e7214fbbdab1f90254af68e0927bdb24708d22  # 07:46      9=
-      9  Merge branch 'sched-urgent-for-linus' of git://git.kernel.org/pub=
/scm/linux/kernel/git/tip/tip
>> git bisect  bad ba929b6646c5b87c7bb15cd8d3e51617725c983b  # 08:00     14=
-      7  Merge branch 'for-linus-4.8' of git://git.kernel.org/pub/scm/linu=
x/kernel/git/mason/linux-btrfs
>> git bisect good 468fc7ed5537615efe671d94248446ac24679773  # 08:21    219=
+      2  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-nex=
t
>> git bisect  bad e55884d2c6ac3ae50e49a1f6fe38601a91181719  # 08:34     17=
-      7  Merge tag 'vfio-v4.8-rc1' of git://github.com/awilliam/linux-vfio
>> git bisect good 554828ee0db41618d101d9549db8808af9fd9d65  # 08:47    220=
+      0  Merge branch 'salted-string-hash'
>> git bisect good ce8c891c3496d3ea4a72ec40beac9a7b7f6649bf  # 09:07    225=
+      0  Merge tag 'rproc-v4.8' of git://github.com/andersson/remoteproc
>> git bisect  bad 1c88e19b0f6a8471ee50d5062721ba30b8fd4ba9  # 09:20      2=
-      3  Merge branch 'akpm' (patches from Andrew)
>> git bisect good c9b011a87dd49bac1632311811c974bb7cd33c25  # 09:39    225=
+      1  Merge tag 'hwlock-v4.8' of git://github.com/andersson/remoteproc
>> git bisect good 6039b80eb50a893476fea7d56e86ed2d19290054  # 10:02    216=
+      1  Merge tag 'dmaengine-4.8-rc1' of git://git.infradead.org/users/vk=
oul/slave-dma
>> git bisect good bca6759258dbef378bcf5b872177bcd2259ceb68  # 10:20    224=
+      0  mm, vmstat: remove zone and node double accounting by approximati=
ng retries
>> git bisect good efdc94907977d2db84b4b00cb9bd98ca011f6819  # 10:33    225=
+      0  mm: fix memcg stack accounting for sub-page stacks
>> git bisect good fb399b4854d2159a4d23fbfbd7daaed914fd54fa  # 10:46    225=
+      1  mm/memblock.c: fix index adjustment error in __next_mem_range_rev=
()
>> git bisect  bad 31a6c1909f51dbe9bf08eb40dc64e3db90cf6f79  # 11:00      6=
-      6  mm, page_alloc: set alloc_flags only once in slowpath
>> git bisect good c146a2b98eb5898eb0fab15a332257a4102ecae9  # 11:14    215=
+      0  mm, kasan: account for object redzone in SLUB's nearest_obj()
>> git bisect  bad 87cc271d5e4320d705cfdf59f68d4d037b3511b2  # 11:24     14=
-      5  lib/stackdepot.c: use __GFP_NOWARN for stack allocations
>> git bisect  bad 80a9201a5965f4715d5c09790862e0df84ce0614  # 11:36      1=
-      1  mm, kasan: switch SLUB to stackdepot, enable memory quarantine fo=
r SLUB
>> # first bad commit: [80a9201a5965f4715d5c09790862e0df84ce0614] mm, kasan=
: switch SLUB to stackdepot, enable memory quarantine for SLUB
>> git bisect good c146a2b98eb5898eb0fab15a332257a4102ecae9  # 11:52    655=
+      0  mm, kasan: account for object redzone in SLUB's nearest_obj()
>> # extra tests with CONFIG_DEBUG_INFO_REDUCED
>> git bisect  bad 80a9201a5965f4715d5c09790862e0df84ce0614  # 12:11      8=
-      5  mm, kasan: switch SLUB to stackdepot, enable memory quarantine fo=
r SLUB
>> # extra tests on HEAD of linux-devel/devel-spot-201610090613
>> git bisect  bad a61bc9c9af01517642ddecff8d6f2425baf33e61  # 12:12      0=
-     16  0day head guard for 'devel-spot-201610090613'
>> # extra tests on tree/branch linus/master
>> git bisect  bad b66484cd74706fa8681d051840fe4b18a3da40ff  # 12:29      6=
-      2  Merge branch 'akpm' (patches from Andrew)
>> # extra tests on tree/branch linus/master
>> git bisect  bad b66484cd74706fa8681d051840fe4b18a3da40ff  # 12:30      0=
-      2  Merge branch 'akpm' (patches from Andrew)
>> # extra tests on tree/branch linux-next/master
>> git bisect  bad c802e87fbe2d4dd58982d01b3c39bc5a781223aa  # 12:31      0=
-      1  Add linux-next specific files for 20161006
>>
>>
>> ---
>> 0-DAY kernel test infrastructure                Open Source Technology C=
enter
>> https://lists.01.org/pipermail/lkp                          Intel Corpor=
ation
>
>
>
> --
> Alexander Potapenko
> Software Engineer
>
> Google Germany GmbH
> Erika-Mann-Stra=C3=9Fe, 33
> 80636 M=C3=BCnchen
>
> Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
> Registergericht und -nummer: Hamburg, HRB 86891
> Sitz der Gesellschaft: Hamburg
>
> --
> You received this message because you are subscribed to the Google Groups=
 "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an=
 email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgi=
d/kasan-dev/CAG_fn%3DVgv3Mr%3DKftNyu21Zjpam8wN9TFvwy2KHLy9cKi_XsQfA%40mail.=
gmail.com.
> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
