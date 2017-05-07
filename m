Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 387CA6B03B1
	for <linux-mm@kvack.org>; Sun,  7 May 2017 10:51:41 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 194so44083386iof.0
        for <linux-mm@kvack.org>; Sun, 07 May 2017 07:51:41 -0700 (PDT)
Received: from mail-it0-x233.google.com (mail-it0-x233.google.com. [2607:f8b0:4001:c0b::233])
        by mx.google.com with ESMTPS id p131si10220392itb.34.2017.05.07.07.51.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 May 2017 07:51:40 -0700 (PDT)
Received: by mail-it0-x233.google.com with SMTP id x188so27578000itb.0
        for <linux-mm@kvack.org>; Sun, 07 May 2017 07:51:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <590ee3ad.UQCaUFBHvkklRvGC%fengguang.wu@intel.com>
References: <590ee3ad.UQCaUFBHvkklRvGC%fengguang.wu@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Sun, 7 May 2017 07:51:38 -0700
Message-ID: <CAGXu5jKwONoDb=LdAYEk99QKSV=TUqfyiQkMZK2AVxGwhyp0uw@mail.gmail.com>
Subject: Re: [mm/usercopy] 517e1fbeb6: kernel BUG at arch/x86/mm/physaddr.c:78!
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: LKP <lkp@01.org>, kernel test robot <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, wfg@linux.intel.com

On Sun, May 7, 2017 at 2:06 AM, kernel test robot
<fengguang.wu@intel.com> wrote:
> Greetings,
>
> 0day kernel testing robot got the below dmesg and the first bad commit is
>
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
>
> commit 517e1fbeb65f5eade8d14f46ac365db6c75aea9b
> Author:     Laura Abbott <labbott@redhat.com>
> AuthorDate: Tue Apr 4 14:09:00 2017 -0700
> Commit:     Kees Cook <keescook@chromium.org>
> CommitDate: Wed Apr 5 12:30:18 2017 -0700
>
>     mm/usercopy: Drop extra is_vmalloc_or_module() check
>
>     Previously virt_addr_valid() was insufficient to validate if virt_to_page()
>     could be called on an address on arm64. This has since been fixed up so
>     there is no need for the extra check. Drop it.
>
>     Signed-off-by: Laura Abbott <labbott@redhat.com>
>     Acked-by: Mark Rutland <mark.rutland@arm.com>
>     Signed-off-by: Kees Cook <keescook@chromium.org>

This appears to be from CONFIG_DEBUG_VIRTUAL on __phys_addr, used by
hardened usercopy, probably during virt_addr_valid(). I'll take a
closer look on Monday...

-Kees

>
> 96dc4f9fb6  usercopy: Move enum for arch_within_stack_frames()
> 517e1fbeb6  mm/usercopy: Drop extra is_vmalloc_or_module() check
> 13e0988140  docs: complete bumping minimal GNU Make version to 3.81
> 9e597e815f  Add linux-next specific files for 20170505
> +------------------------------------------------------+------------+------------+------------+---------------+
> |                                                      | 96dc4f9fb6 | 517e1fbeb6 | 13e0988140 | next-20170505 |
> +------------------------------------------------------+------------+------------+------------+---------------+
> | boot_successes                                       | 35         | 3          | 6          | 0             |
> | boot_failures                                        | 0          | 12         | 13         | 18            |
> | kernel_BUG_at_arch/x86/mm/physaddr.c                 | 0          | 12         | 13         | 13            |
> | invalid_opcode:#[##]                                 | 0          | 12         | 13         | 13            |
> | EIP:__phys_addr                                      | 0          | 12         | 13         | 13            |
> | Kernel_panic-not_syncing:Fatal_exception             | 0          | 12         | 13         | 13            |
> | WARNING:at_kernel/cpu.c:#lockdep_assert_hotplug_held | 0          | 0          | 0          | 18            |
> | EIP:lockdep_assert_hotplug_held                      | 0          | 0          | 0          | 18            |
> +------------------------------------------------------+------------+------------+------------+---------------+
>
> [main] Setsockopt(1 22 80d3000 4) on fd 47 [1:5:1]
> [   18.665929] sock: process `trinity-main' is using obsolete setsockopt SO_BSDCOMPAT
> [main] Setsockopt(1 e 80d3000 90) on fd 49 [1:2:1]
> [main] Setsockopt(10e 5 80d3000 4) on fd 52 [16:3:16]
> [   18.668412] ------------[ cut here ]------------
> [   18.668824] kernel BUG at arch/x86/mm/physaddr.c:78!
> [   18.669424] invalid opcode: 0000 [#1] SMP
> [   18.669776] CPU: 0 PID: 754 Comm: trinity-main Not tainted 4.11.0-rc2-00002-g517e1fb #1
> [   18.670469] task: 4ca52e80 task.stack: 4c572000
> [   18.670860] EIP: __phys_addr+0x120/0x130
> [   18.671189] EFLAGS: 00010202 CPU: 0
> [   18.671482] EAX: 0000ff01 EBX: 50851020 ECX: 00000000 EDX: 00000001
> [   18.672025] ESI: 0000ff01 EDI: 10851020 EBP: 4c573e70 ESP: 4c573e60
> [   18.672557]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> [   18.673025] CR0: 80050033 CR2: 084da000 CR3: 0c65c4a0 CR4: 001406f0
> [   18.673560] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> [   18.674100] DR6: fffe0ff0 DR7: 00000400
> [   18.674420] Call Trace:
> [   18.674632]  __check_object_size+0xff/0x42f
> [   18.674988]  ? __might_sleep+0x8e/0x130
> [   18.675310]  __get_filter+0xaa/0x130
> [   18.675612]  sk_attach_filter+0x15/0x90
> [   18.675937]  sock_setsockopt+0x6b3/0x960
> [   18.676263]  SyS_socketcall+0x773/0x810
> [   18.676585]  ? __do_page_fault+0x36c/0x730
> [   18.676932]  do_int80_syscall_32+0x8a/0x230
> [   18.677307]  ? prepare_exit_to_usermode+0x38/0x60
> [   18.677712]  entry_INT80_32+0x2f/0x2f
> [   18.678034] EIP: 0x37688a42
> [   18.678278] EFLAGS: 00000202 CPU: 0
> [   18.678580] EAX: ffffffda EBX: 0000000e ECX: 3fc2da40 EDX: 3fc2dac0
> [   18.679099] ESI: 00000004 EDI: 00000035 EBP: 3753f1ac ESP: 3fc2da3c
> [   18.679618]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
> [   18.680069] Code: 00 00 e0 ff 2d 00 20 00 00 39 c3 0f 83 47 ff ff ff c7 04 24 00 00 00 00 31 c9 ba 01 00 00 00 b8 98 e7 1a 42 e8 22 3e 0d 00 0f 0b <0f> 0b 8d b4 26 00 00 00 00 8d bc 27 00 00 00 00 55 89 e5 53 3e
> [   18.681652] EIP: __phys_addr+0x120/0x130 SS:ESP: 0068:4c573e60
> [   18.682174] ---[ end trace bbf34582d6d63d7a ]---
> [   18.682636] Kernel panic - not syncing: Fatal exception
>
>                                                           # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
> git bisect start 773f7f5cf2d18eb40343d1e4e9a49062739e0425 a351e9b9fc24e982ec2f0e76379a49826036da12 --
> git bisect  bad 39af3d3d90897d17d79bc655068cf09a717a0e68  # 12:26  B      0     4   15   0  Merge 'mellanox/queue-next' into devel-spot-201705070851
> git bisect  bad 32f465722603afc8d3d90ad9fb999095afe11205  # 12:42  B      0    11   22   0  Merge 'linux-review/David-Ahern/net-reducing-memory-footprint-of-network-devices/20170507-031536' into devel-spot-201705070851
> git bisect  bad 1cbccce1b4565d60c4d9a5bc3aaf8d63b5b9224f  # 12:53  B      0    11   22   0  Merge 'linux-review/Geliang-Tang/yam-use-memdup_user/20170507-045454' into devel-spot-201705070851
> git bisect  bad 408133c058c5492c03ff9f3827ccdb65b42cb842  # 13:06  B      0    11   22   0  Merge 'linux-review/Christophe-JAILLET/firmware-Google-VPD-Fix-memory-allocation-error-handling/20170507-064549' into devel-spot-201705070851
> git bisect  bad d5f6ce59cba315fc39f8bdd594d9a6ec7633be45  # 13:14  B      0     1   12   0  Merge 'linux-review/Geert-Uytterhoeven/signal-Export-signal_wake_up_state-to-modules/20170507-082935' into devel-spot-201705070851
> git bisect good 163f34fcdf2791ac0e609d59440a9ef90d2bf3d2  # 13:34  G     11     0    0   0  0day base guard for 'devel-spot-201705070851'
> git bisect good ddd92361062a7eb9708eb6c633346c35d0d67d2f  # 13:45  G     11     0    0   0  Merge 'linux-review/Geliang-Tang/platform-x86-toshiba_acpi-use-memdup_user_nul/20170507-083752' into devel-spot-201705070851
> git bisect  bad a3719f34fdb664ffcfaec2160ef20fca7becf2ee  # 13:57  B      0    11   22   0  Merge branch 'generic' of git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-fs
> git bisect good 5d15af6778b8e4ed1fd41b040283af278e7a9a72  # 14:11  G     11     0    0   0  Merge branch 'tipc-refactor-socket-receive-functions'
> git bisect good 7c8c03bfc7b9f5211d8a69eab7fee99c9fb4f449  # 14:21  G     11     0    0   0  Merge branch 'perf-core-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
> git bisect  bad 8d65b08debc7e62b2c6032d7fe7389d895b92cbc  # 14:30  B      0    11   22   0  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
> git bisect good b68e7e952f24527de62f4768b1cead91f92f5f6e  # 14:40  G     11     0    0   0  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/s390/linux
> git bisect  bad 5b13475a5e12c49c24422ba1bd9998521dec1d4e  # 14:51  B      0    11   22   0  Merge branch 'work.iov_iter' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs
> git bisect good 0cb300623e3bb460fd9853bbde2fd1973e3bbcd8  # 15:01  G     11     0    0   0  usb: gadget.h: be consistent at kernel doc macros
> git bisect good 3a7d2fd16c57a1ef47dc2891171514231c9c7c6e  # 15:21  G     11     0    0   0  pstore: Solve lockdep warning by moving inode locks
> git bisect good c58d4055c054fc6dc72f1be8bc71bd6fff209e48  # 15:35  G     11     0    0   0  Merge tag 'docs-4.12' of git://git.lwn.net/linux
> git bisect  bad 6fd4e7f7744bd7859ca3cae19c4613252ebb6bff  # 15:43  B      0    11   22   0  Merge branch 'for-next' of git://git.samba.org/sfrench/cifs-2.6
> git bisect  bad 5958cc49ed2961a059d92ae55afeeaba64a783a0  # 15:51  B      0     1   12   0  Merge tag 'usercopy-v4.12-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/kees/linux
> git bisect  bad 517e1fbeb65f5eade8d14f46ac365db6c75aea9b  # 16:05  B      0    11   22   0  mm/usercopy: Drop extra is_vmalloc_or_module() check
> git bisect good 96dc4f9fb64690fc34410415fd1fc609cf803f61  # 16:14  G     11     0    0   0  usercopy: Move enum for arch_within_stack_frames()
> # first bad commit: [517e1fbeb65f5eade8d14f46ac365db6c75aea9b] mm/usercopy: Drop extra is_vmalloc_or_module() check
> git bisect good 96dc4f9fb64690fc34410415fd1fc609cf803f61  # 16:17  G     31     0    0   0  usercopy: Move enum for arch_within_stack_frames()
> # extra tests with CONFIG_DEBUG_INFO_REDUCED
> git bisect  bad 517e1fbeb65f5eade8d14f46ac365db6c75aea9b  # 16:31  B      0    11   22   0  mm/usercopy: Drop extra is_vmalloc_or_module() check
> # extra tests on HEAD of linux-devel/devel-spot-201705070851
> git bisect  bad 773f7f5cf2d18eb40343d1e4e9a49062739e0425  # 16:32  B      0    22   37   0  0day head guard for 'devel-spot-201705070851'
> # extra tests on tree/branch linus/master
> git bisect  bad 13e0988140374123bead1dd27c287354cb95108e  # 16:43  B      0    11   22   0  docs: complete bumping minimal GNU Make version to 3.81
> # extra tests with first bad commit reverted
> git bisect good 688e95d3e3571e6b1c08da62fc402f1c1c3d5542  # 16:53  G     10     0    0   0  Revert "mm/usercopy: Drop extra is_vmalloc_or_module() check"
> # extra tests on tree/branch linux-next/master
> git bisect  bad 9e597e815f68867c70d1b70cb2b037b92a8ec12b  # 17:06  B      0     9   27   7  Add linux-next specific files for 20170505
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/lkp                          Intel Corporation



-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
