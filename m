Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id EEAED6B7252
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 05:09:02 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id c5-v6so3490998plo.2
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 02:09:02 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id cb14-v6si1422769plb.178.2018.09.05.02.09.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 02:09:00 -0700 (PDT)
Date: Wed, 5 Sep 2018 17:05:53 +0800
From: kernel test robot <rong.a.chen@intel.com>
Subject: [LKP] 3f906ba236 [   71.192813] WARNING: possible circular locking
 dependency detected
Message-ID: <20180905090553.GA6655@shao2-debian>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="3V7upXqbjpZ4EhLz"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, LKP <lkp@01.org>


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master

commit 3f906ba23689a3f824424c50f3ae937c2c70f676
Author:     Thomas Gleixner <tglx@linutronix.de>
AuthorDate: Mon Jul 10 15:50:09 2017 -0700
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Mon Jul 10 16:32:33 2017 -0700

    mm/memory-hotplug: switch locking to a percpu rwsem
   =20
    Andrey reported a potential deadlock with the memory hotplug lock and
    the cpu hotplug lock.
   =20
    The reason is that memory hotplug takes the memory hotplug lock and then
    calls stop_machine() which calls get_online_cpus().  That's the reverse
    lock order to get_online_cpus(); get_online_mems(); in mm/slub_common.c
   =20
    The problem has been there forever.  The reason why this was never
    reported is that the cpu hotplug locking had this homebrewn recursive
    reader writer semaphore construct which due to the recursion evaded the
    full lock dep coverage.  The memory hotplug code copied that construct
    verbatim and therefor has similar issues.
   =20
    Three steps to fix this:
   =20
    1) Convert the memory hotplug locking to a per cpu rwsem so the
       potential issues get reported proper by lockdep.
   =20
    2) Lock the online cpus in mem_hotplug_begin() before taking the memory
       hotplug rwsem and use stop_machine_cpuslocked() in the page_alloc
       code to avoid recursive locking.
   =20
    3) The cpu hotpluck locking in #2 causes a recursive locking of the cpu
       hotplug lock via __offline_pages() -> lru_add_drain_all(). Solve this
       by invoking lru_add_drain_all_cpuslocked() instead.
   =20
    Link: http://lkml.kernel.org/r/20170704093421.506836322@linutronix.de
    Reported-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
    Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
    Acked-by: Michal Hocko <mhocko@suse.com>
    Acked-by: Vlastimil Babka <vbabka@suse.cz>
    Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
    Cc: Peter Zijlstra <peterz@infradead.org>
    Cc: Davidlohr Bueso <dave@stgolabs.net>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

a47fed5b5b  mm: swap: provide lru_add_drain_all_cpuslocked()
3f906ba236  mm/memory-hotplug: switch locking to a percpu rwsem
28619527b8  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
f2b6e66e98  Add linux-next specific files for 20180904
+------------------------------------------------------------------+-------=
-----+------------+------------+---------------+
|                                                                  | a47fed=
5b5b | 3f906ba236 | 28619527b8 | next-20180904 |
+------------------------------------------------------------------+-------=
-----+------------+------------+---------------+
| boot_successes                                                   | 132   =
     | 17         | 13         | 15            |
| boot_failures                                                    | 14    =
     | 29         | 39         | 35            |
| BUG_kmalloc-#(Not_tainted):Redzone_overwritten                   | 12    =
     | 4          |            |               |
| INFO:#-#.First_byte#instead_of                                   | 12    =
     | 4          |            |               |
| INFO:Freed_in_skb_free_head_age=3D#cpu=3D#pid=3D                       | =
1          | 1          |            |               |
| INFO:Slab#objects=3D#used=3D#fp=3D#flags=3D                              =
| 12         | 4          |            |               |
| INFO:Object#@offset=3D#fp=3D0x(null)                                 | 12=
         | 4          |            |               |
| INFO:Freed_in_rcu_process_callbacks_age=3D#cpu=3D#pid=3D               | =
2          |            |            |               |
| INFO:Freed_in_free_ctx_age=3D#cpu=3D#pid=3D                            | =
3          | 1          |            |               |
| BUG:unable_to_handle_kernel                                      | 1     =
     | 1          |            |               |
| Oops:#[##]                                                       | 1     =
     | 1          |            |               |
| Kernel_panic-not_syncing:Fatal_exception                         | 1     =
     | 1          |            |               |
| BUG_fasync_cache(Not_tainted):Freelist_Pointer_check_fails       | 1     =
     |            |            |               |
| INFO:Slab#objects=3D#used=3D#fp=3D0x(null)flags=3D                       =
| 1          |            |            |               |
| INFO:Object#@offset=3D#fp=3D                                         | 1 =
         |            |            |               |
| INFO:Freed_in_free_pipe_info_age=3D#cpu=3D#pid=3D                      | =
2          |            |            |               |
| INFO:Freed_in_load_elf_binary_age=3D#cpu=3D#pid=3D                     | =
1          |            |            |               |
| WARNING:possible_circular_locking_dependency_detected            | 0     =
     | 26         | 35         | 31            |
| Mem-Info                                                         | 0     =
     | 2          | 6          | 5             |
| INFO:Freed_in_kvfree_age=3D#cpu=3D#pid=3D                              | =
0          | 1          |            |               |
| invoked_oom-killer:gfp_mask=3D0x                                   | 0   =
       | 0          | 4          | 4             |
| Kernel_panic-not_syncing:Out_of_memory_and_no_killable_processes | 0     =
     | 0          | 4          |               |
| Out_of_memory_and_no_killable_processes                          | 0     =
     | 0          | 0          | 4             |
| Kernel_panic-not_syncing:System_is_deadlocked_on_memory          | 0     =
     | 0          | 0          | 4             |
+------------------------------------------------------------------+-------=
-----+------------+------------+---------------+

vm86 returned ENOSYS, marking as inactive. 20044 iterations. [F:14867 S:503=
2 HI:3700] [ 57.651003] synth uevent: /module/pcmcia_core: unknown uevent a=
ction string [ 71.189062] [ 71.191953] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D [ 71.192813] WARNING: p=
ossible circular locking dependency detected [ 71.193664] 4.12.0-10480-g3f9=
06ba #1 Not tainted [ 71.194355] ------------------------------------------=
------------ [ 71.195211] trinity-c0/1666 is trying to acquire lock: [ 71.1=
95958] (mem_hotplug_lock.rw_sem){.+.+.+}, at: show_slab_objects+0x14b/0x440=
 [ 71.197284] [ 71.197284] but task is already holding lock: [ 71.198241] (=
s_active#39){++++.+}, at: kernfs_seq_start+0x44/0xa0 [ 71.199433] [ 71.1994=
33] which lock already depends on the new lock. [ 71.199433] [ 71.200774] [=
 71.200774] the existing dependency chain (in reverse order) is: [ 71.20190=
0] [ 71.201900] -> #2 (s_active#39){++++.+}: [ 71.202814] lock_acquire+0xcf=
/0x2a0 [ 71.203447] __kernfs_remove+0x337/0x410 [ 71.204121] kernfs_remove_=
by_name_ns+0x49/0xd0 [ 71.204858] sysfs_remove_link+0x19/0x30 [ 71.205528] =
sysfs_slab_add+0xa6/0x290 [ 71.206182] __kmem_cache_create+0x52a/0x5b0 [ 71=
=2E206889] kmem_cache_create+0x239/0x3a0 [ 71.207578] snic_init_module+0x11=
1/0x203 [ 71.208263] do_one_initcall+0x41/0x19c [ 71.208928] kernel_init_fr=
eeable+0x1f4/0x27d [ 71.209647] kernel_init+0xe/0x100 [ 71.210268] ret_from=
_fork+0x2a/0x40 [ 71.210904] [ 71.210904] -> #1 (slab_mutex){+.+.+.}: [ 71.=
211806] lock_acquire+0xcf/0x2a0 [ 71.212440] __mutex_lock+0x6f/0xda0 [ 71.2=
13075] mutex_lock_nested+0x1b/0x20 [ 71.213745] kmem_cache_create+0x3e/0x3a=
0 [ 71.214427] ptlock_cache_init+0x24/0x2d [ 71.215102] start_kernel+0x240/=
0x4a5 [ 71.215747] x86_64_start_reservations+0x2a/0x2c [ 71.216488] x86_64_=
start_kernel+0x127/0x136 [ 71.217197] verify_cpu+0x0/0xf1 [ 71.217796] [ 71=
=2E217796] -> #0 (mem_hotplug_lock.rw_sem){.+.+.+}: [ 71.218816] __lock_acq=
uire+0x120b/0x1240 [ 71.219496] lock_acquire+0xcf/0x2a0 [ 71.220135] get_on=
line_mems+0x47/0xb0 [ 71.220789] show_slab_objects+0x14b/0x440 [ 71.221476]=
 slabs_show+0x13/0x20 [ 71.222089] slab_attr_show+0x1b/0x30 [ 71.222735] sy=
sfs_kf_seq_show+0x109/0x190 [ 71.223421] kernfs_seq_show+0x27/0x30 [ 71.224=
076] traverse+0xa8/0x230 [ 71.224674] seq_read+0x1c6/0x530 [ 71.225284] ker=
nfs_fop_read+0x18a/0x1e0 [ 71.225956] do_iter_read+0x164/0x1a0 [ 71.226596]=
 vfs_readv+0x67/0x90 [ 71.227197] do_preadv+0x9e/0xb0 [ 71.227795] SyS_prea=
dv+0x11/0x20 [ 71.228400] entry_SYSCALL_64_fastpath+0x23/0xc2 [ 71.229145] =
[ 71.229145] other info that might help us debug this: [ 71.229145] [ 71.23=
0462] Chain exists of: [ 71.230462] mem_hotplug_lock.rw_sem --> slab_mutex =
--> s_active#39 [ 71.230462] [ 71.232069] Possible unsafe locking scenario:=
 [ 71.232069] [ 71.233031] CPU0 CPU1 [ 71.233711] ---- ---- [ 71.234390] lo=
ck(s_active#39); [ 71.234938] lock(slab_mutex); [ 71.235737] lock(s_active#=
39); [ 71.236543] lock(mem_hotplug_lock.rw_sem); [ 71.237200] [ 71.237200] =
COPYING CREDITS Documentation Kbuild Kconfig LICENSES MAINTAINERS Makefile =
Next README arch block certs crypto drivers firmware fs include init ipc ke=
rnel lib localversion-next mm net obj-bisect samples scripts security sound=
 tools usr virt DEADLOCK COPYING CREDITS Documentation Kbuild Kconfig LICEN=
SES MAINTAINERS Makefile Next README arch block certs crypto drivers firmwa=
re fs include init ipc kernel lib localversion-next mm net obj-bisect sampl=
es scripts security sound tools usr virt [ 71.237200] [ 71.238303] 3 locks =
held by trinity-c0/1666: [ 71.238956] #0: (&p->lock){+.+.+.}, at: seq_read+=
0x41/0x530 [ 71.240100] #1: (&of->mutex){+.+.+.}, at: kernfs_seq_start+0x3c=
/0xa0 [ 71.241327] #2: (s_active#39){++++.+}, at: kernfs_seq_start+0x44/0xa=
0 [ 71.242558] [ 71.242558] stack backtrace: [ 71.243360] CPU: 0 PID: 1666 =
Comm: trinity-c0 Not tainted 4.12.0-10480-g3f906ba #1 [ 71.244500] Hardware=
 name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014 [ 7=
1.245724] Call Trace: [ 71.246187] dump_stack+0x8e/0xd7 [ 71.246744] print_=
circular_bug+0x1c4/0x220 [ 71.247385] __lock_acquire+0x120b/0x1240 [ 71.248=
015] lock_acquire+0xcf/0x2a0 [ 71.248594] show_slab_objects+0x14b/0x440 [ 7=
1.249250] get_online_mems+0x47/0xb0 [ 71.249853] show_slab_objects+0x14b/0x=
440 [ 71.250505] show_slab_objects+0x14b/0x440 [ 71.251140] __lock_is_held+=
0x64/0xb0 [ 71.251751] slabs_show+0x13/0x20 [ 71.252303] slab_attr_show+0x1=
b/0x30 [ 71.252896] sysfs_kf_seq_show+0x109/0x190 [ 71.253528] kernfs_seq_s=
how+0x27/0x30 [ 71.254130] traverse+0xa8/0x230 [ 71.254673] seq_read+0x1c6/=
0x530 [ 71.255229] kernfs_fop_read+0x18a/0x1e0 [ 71.255850] do_iter_read+0x=
164/0x1a0 [ 71.256438] vfs_readv+0x67/0x90 [ 71.256984] trace_hardirqs_on_c=
aller+0xf7/0x190 [ 71.257688] trace_hardirqs_on+0xd/0x10 [ 71.258316] _raw_=
spin_unlock_irq+0x2c/0x40 [ 71.258980] __fget_light+0x62/0x90 [ 71.259566] =
do_preadv+0x9e/0xb0 [ 71.260112] SyS_preadv+0x11/0x20 [ 71.260664] entry_SY=
SCALL_64_fastpath+0x23/0xc2 [ 71.261356] RIP: 0033:0x457389 [ 71.261881] RS=
P: 002b:00007ffec728b8e8 EFLAGS: 00000246 ORIG_RAX: 0000000000000127 [ 71.2=
63024] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000457389 [ =
71.263979] RDX: 000000000000008c RSI: 0000000002b95250 RDI: 000000000000009=
4 [ 71.264936] RBP: 00007ff6b84d5000 R08: 0000000000000006 R09: 00000000000=
0fffa [ 71.265891] R10: 0000000000400000 R11: 0000000000000246 R12: 0000000=
000000000 [ 71.266845] R13: 0000000000000127 R14: 00000000006fe4c0 R15: 000=
00000cccccccd BusyBox v1.19.4 (2012-04-22 08:49:11 PDT) multi-call binary. =
Usage: rmmod

                                                          # HH:MM RESULT GO=
OD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start v4.13 v4.12 --
git bisect  bad 63a86362130f4c17eaa57f3ef5171ec43111a54e  # 04:59  B      2=
     2    1   1  Merge tag 'pm-4.13-rc2' of git://git.kernel.org/pub/scm/li=
nux/kernel/git/rafael/linux-pm
git bisect good 090a81d8766e21d33ab3e4d24e6c8e5eedf086dd  # 05:19  G     45=
     0    5   5  Merge branch 'for-spi' of git://git.kernel.org/pub/scm/lin=
ux/kernel/git/viro/vfs
git bisect  bad ad51271afc21a72479974713abb40ca4b96d1f6b  # 05:38  B      1=
     2    1   1  Merge branch 'akpm' (patches from Andrew)
git bisect good 7cee9384cb3e25de33d75ecdbf08bb15b4ea9fa5  # 06:08  G     49=
     0    4   4  Fix up over-eager 'wait_queue_t' renaming
git bisect  bad fb4e3beeffa47619985f190663c6ef424f063a22  # 06:48  B      8=
    10    6   7  Merge tag 'iommu-updates-v4.13' of git://git.kernel.org/pu=
b/scm/linux/kernel/git/joro/iommu
git bisect  bad a3ddacbae5abc0a5aabb1e75b655e8cd6dc83888  # 07:12  B      3=
     2    1   1  Merge tag 'chrome-platform-for-linus-4.13' of git://git.ke=
rnel.org/pub/scm/linux/kernel/git/bleung/chrome-platform
git bisect good 322618684353315e14f586b33d8a016286ffa700  # 07:37  G     46=
     0    8   8  Merge tag 'acpi-extra-4.13-rc1' of git://git.kernel.org/pu=
b/scm/linux/kernel/git/rafael/linux-pm
git bisect  bad 9967468c0a109644e4a1f5b39b39bf86fe7507a7  # 08:21  B      6=
     5    3   3  Merge branch 'akpm' (patches from Andrew)
git bisect good 548aa0e3c516d906dae5edb1fc9a1ad2e490120a  # 08:41  G     49=
     0   12  12  Merge tag 'devprop-4.13-rc1' of git://git.kernel.org/pub/s=
cm/linux/kernel/git/rafael/linux-pm
git bisect good a47fed5b5b014f5a13878b90ef2c3a7dc294189f  # 09:25  G     49=
     0    6   6  mm: swap: provide lru_add_drain_all_cpuslocked()
git bisect  bad 2c6deb01525ac11cc03c44fe31e3f45ce2cadaf9  # 09:41  B      6=
     6    4   4  bitmap: use memcmp optimisation in more situations
git bisect  bad b6d0f14abb7c1d9d522c064633c820aaeb9bbfbf  # 10:06  B      3=
     1    0   0  frv: cmpxchg: implement cmpxchg64()
git bisect  bad 4d461333f144456b80d9eabd7cee7ac02fa5d0ee  # 10:22  B      2=
     3    1   1  x86/kasan: don't allocate extra shadow memory
git bisect  bad bc1bb362334ebc4c65dd4301f10fb70902b3db7d  # 10:38  B      7=
     6    0   0  zram: constify attribute_group structures.
git bisect  bad 9d1f4b3f5b29bea431525e528a3ff2dc806ad904  # 11:05  B      1=
     1    1   1  mm: disallow early_pfn_to_nid on configurations which do n=
ot implement it
git bisect  bad 3f906ba23689a3f824424c50f3ae937c2c70f676  # 11:22  B      2=
     6    2   2  mm/memory-hotplug: switch locking to a percpu rwsem
# first bad commit: [3f906ba23689a3f824424c50f3ae937c2c70f676] mm/memory-ho=
tplug: switch locking to a percpu rwsem
git bisect good a47fed5b5b014f5a13878b90ef2c3a7dc294189f  # 11:27  G    144=
     0   12  18  mm: swap: provide lru_add_drain_all_cpuslocked()
# extra tests with debug options
git bisect  bad 3f906ba23689a3f824424c50f3ae937c2c70f676  # 11:44  B      1=
     6    1   2  mm/memory-hotplug: switch locking to a percpu rwsem
# extra tests on HEAD of linux-devel/devel-catchup-201809041401
git bisect  bad 6859ff565807876b3ad6f5d7cccedc214bfc51d1  # 11:45  B      5=
     8    0   0  0day head guard for 'devel-catchup-201809041401'
# extra tests on tree/branch linus/master
git bisect  bad 28619527b8a712590c93d0a9e24b4425b9376a8c  # 11:59  B      3=
     2    1   1  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/=
net
# extra tests on tree/branch linux-next/master
git bisect  bad f2b6e66e9885a2eae12efd73cc6f859213f64c23  # 12:14  B      4=
     6    1   5  Add linux-next specific files for 20180904

---
0-DAY kernel test infrastructure                Open Source Technology Cent=
er
https://lists.01.org/pipermail/lkp                          Intel Corporati=
on

--3V7upXqbjpZ4EhLz
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-yocto-lkp-hsw01-3:20180905112330:x86_64-randconfig-s3-09041417:4.12.0-10480-g3f906ba:1.gz"
Content-Transfer-Encoding: base64

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

--3V7upXqbjpZ4EhLz
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-yocto-lkp-hsw01-103:20180905112632:x86_64-randconfig-s3-09041417:4.12.0-10479-ga47fed5:1.gz"
Content-Transfer-Encoding: base64

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

--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="reproduce-yocto-lkp-hsw01-3:20180905112330:x86_64-randconfig-s3-09041417:4.12.0-10480-g3f906ba:1"

#!/bin/bash

kernel=$1
initrd=yocto-trinity-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/yocto/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu Haswell,+smep,+smap
	-kernel $kernel
	-initrd $initrd
	-m 512
	-smp 1
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-watchdog-action debug
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null
)

append=(
	root=/dev/ram0
	hung_task_panic=1
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	net.ifnames=0
	printk.devkmsg=on
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	drbd.minor_count=8
	systemd.log_level=err
	ignore_loglevel
	console=tty0
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	vga=normal
	rw
	drbd.minor_count=8
	rcuperf.shutdown=0
)

"${kvm[@]}" -append "${append[*]}"

--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-4.12.0-10480-g3f906ba"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.12.0 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=28
CONFIG_ARCH_MMAP_RND_BITS_MAX=32
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_64_SMP=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
# CONFIG_SYSVIPC is not set
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_FHANDLE=y
CONFIG_USELIB=y
CONFIG_AUDIT=y
CONFIG_HAVE_ARCH_AUDITSYSCALL=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_EFFECTIVE_AFF_MASK=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_MIGRATION=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_MSI_IRQ=y
CONFIG_GENERIC_MSI_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
# CONFIG_GENERIC_IRQ_DEBUGFS is not set
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
# CONFIG_NO_HZ_IDLE is not set
CONFIG_NO_HZ_FULL=y
# CONFIG_NO_HZ_FULL_ALL is not set
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
CONFIG_RCU_EXPERT=y
CONFIG_SRCU=y
CONFIG_TREE_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_NEED_SEGCBLIST=y
CONFIG_CONTEXT_TRACKING=y
# CONFIG_CONTEXT_TRACKING_FORCE is not set
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FAST_NO_HZ is not set
CONFIG_RCU_NOCB_CPU=y
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_NUMA_BALANCING=y
# CONFIG_NUMA_BALANCING_DEFAULT_ENABLED is not set
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
# CONFIG_MEMCG is not set
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
CONFIG_RT_GROUP_SCHED=y
CONFIG_CGROUP_PIDS=y
# CONFIG_CGROUP_RDMA is not set
# CONFIG_CGROUP_FREEZER is not set
CONFIG_CGROUP_HUGETLB=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
CONFIG_CGROUP_DEVICE=y
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_PERF is not set
# CONFIG_CGROUP_BPF is not set
# CONFIG_CGROUP_DEBUG is not set
CONFIG_SOCK_CGROUP_DATA=y
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
# CONFIG_USER_NS is not set
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
# CONFIG_RD_LZMA is not set
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
# CONFIG_EXPERT is not set
CONFIG_UID16=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_POSIX_TIMERS=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_ABSOLUTE_PERCPU=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_BPF_SYSCALL=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_ADVISE_SYSCALLS=y
CONFIG_USERFAULTFD=y
CONFIG_PCI_QUIRKS=y
CONFIG_MEMBARRIER=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y
# CONFIG_PC104 is not set

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLAB_MERGE_DEFAULT is not set
CONFIG_SLAB_FREELIST_RANDOM=y
CONFIG_SLUB_CPU_PARTIAL=y
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_CRASH_CORE=y
CONFIG_KEXEC_CORE=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
# CONFIG_JUMP_LABEL is not set
CONFIG_OPTPROBES=y
CONFIG_KPROBES_ON_FTRACE=y
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_KRETPROBES=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_GCC_PLUGINS=y
CONFIG_GCC_PLUGINS=y
CONFIG_GCC_PLUGIN_SANCOV=y
# CONFIG_GCC_PLUGIN_LATENT_ENTROPY is not set
CONFIG_GCC_PLUGIN_STRUCTLEAK=y
# CONFIG_GCC_PLUGIN_STRUCTLEAK_VERBOSE is not set
# CONFIG_GCC_PLUGIN_RANDSTRUCT is not set
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_THIN_ARCHIVES=y
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES=y
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
CONFIG_HAVE_RELIABLE_STACKTRACE=y
# CONFIG_HAVE_ARCH_HASH is not set
# CONFIG_ISA_BUS_API is not set
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y
# CONFIG_CPU_NO_EFFICIENT_FFS is not set
CONFIG_HAVE_ARCH_VMAP_STACK=y
CONFIG_VMAP_STACK=y
# CONFIG_ARCH_OPTIONAL_KERNEL_RWX is not set
# CONFIG_ARCH_OPTIONAL_KERNEL_RWX_DEFAULT is not set
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_STRICT_MODULE_RWX=y
# CONFIG_REFCOUNT_FULL is not set

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
# CONFIG_MODULE_FORCE_LOAD is not set
# CONFIG_MODULE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
# CONFIG_MODULE_COMPRESS is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLK_DEV_ZONED=y
# CONFIG_BLK_DEV_THROTTLING is not set
CONFIG_BLK_CMDLINE_PARSER=y
# CONFIG_BLK_WBT is not set
CONFIG_BLK_DEBUG_FS=y
# CONFIG_BLK_SED_OPAL is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
CONFIG_AIX_PARTITION=y
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
CONFIG_ATARI_PARTITION=y
CONFIG_MAC_PARTITION=y
# CONFIG_MSDOS_PARTITION is not set
# CONFIG_LDM_PARTITION is not set
# CONFIG_SGI_PARTITION is not set
# CONFIG_ULTRIX_PARTITION is not set
CONFIG_SUN_PARTITION=y
# CONFIG_KARMA_PARTITION is not set
# CONFIG_EFI_PARTITION is not set
# CONFIG_SYSV68_PARTITION is not set
CONFIG_CMDLINE_PARTITION=y
CONFIG_BLOCK_COMPAT=y
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
# CONFIG_IOSCHED_DEADLINE is not set
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
# CONFIG_MQ_IOSCHED_DEADLINE is not set
# CONFIG_MQ_IOSCHED_KYBER is not set
CONFIG_IOSCHED_BFQ=y
CONFIG_BFQ_GROUP_IOSCHED=y
CONFIG_PADATA=y
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_QUEUED_RWLOCKS=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_FAST_FEATURE_TESTS=y
CONFIG_X86_X2APIC=y
CONFIG_X86_MPPARSE=y
# CONFIG_GOLDFISH is not set
# CONFIG_INTEL_RDT_A is not set
CONFIG_X86_EXTENDED_PLATFORM=y
CONFIG_X86_NUMACHIP=y
# CONFIG_X86_VSMP is not set
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_MID is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_AMD_PLATFORM_DEVICE=y
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
CONFIG_MK8=y
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
CONFIG_CALGARY_IOMMU=y
# CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_MAXSMP=y
CONFIG_NR_CPUS=8192
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_SCHED_MC_PRIO is not set
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
# CONFIG_X86_MCE is not set

#
# Performance monitoring
#
# CONFIG_PERF_EVENTS_INTEL_UNCORE is not set
CONFIG_PERF_EVENTS_INTEL_RAPL=m
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
CONFIG_PERF_EVENTS_AMD_POWER=y
# CONFIG_VM86 is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=y
# CONFIG_MICROCODE is not set
# CONFIG_X86_MSR is not set
CONFIG_X86_CPUID=m
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_X86_DIRECT_GBPAGES=y
CONFIG_NUMA=y
# CONFIG_AMD_NUMA is not set
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
CONFIG_NUMA_EMU=y
CONFIG_NODES_SHIFT=10
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_HAVE_GENERIC_GUP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE=y
# CONFIG_MEMORY_HOTREMOVE is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
# CONFIG_COMPACTION is not set
CONFIG_MIGRATION=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
# CONFIG_BOUNCE is not set
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_ARCH_WANTS_THP_SWAP=y
CONFIG_CLEANCACHE=y
CONFIG_CMA=y
CONFIG_CMA_DEBUG=y
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=7
# CONFIG_ZPOOL is not set
CONFIG_ZBUD=m
# CONFIG_ZSMALLOC is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
# CONFIG_DEFERRED_STRUCT_PAGE_INIT is not set
CONFIG_IDLE_PAGE_TRACKING=y
CONFIG_ARCH_HAS_ZONE_DEVICE=y
CONFIG_FRAME_VECTOR=y
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
CONFIG_ARCH_HAS_PKEYS=y
# CONFIG_PERCPU_STATS is not set
CONFIG_X86_PMEM_LEGACY_DEVICE=y
CONFIG_X86_PMEM_LEGACY=m
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
# CONFIG_MTRR_SANITIZER is not set
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_X86_INTEL_MPX=y
CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_KEXEC_FILE=y
CONFIG_KEXEC_VERIFY_SIG=y
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
CONFIG_DEBUG_HOTPLUG_CPU0=y
CONFIG_COMPAT_VDSO=y
# CONFIG_LEGACY_VSYSCALL_NATIVE is not set
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
CONFIG_LIVEPATCH=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
CONFIG_PM_WAKELOCKS_GC=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
# CONFIG_PM_ADVANCED_DEBUG is not set
CONFIG_PM_SLEEP_DEBUG=y
CONFIG_PM_TRACE=y
CONFIG_PM_TRACE_RTC=y
CONFIG_PM_CLK=y
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
CONFIG_ACPI_DEBUGGER=y
# CONFIG_ACPI_DEBUGGER_USER is not set
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_PROCFS_POWER=y
# CONFIG_ACPI_REV_OVERRIDE_POSSIBLE is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=m
# CONFIG_ACPI_BATTERY is not set
CONFIG_ACPI_BUTTON=m
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR_CSTATE=y
# CONFIG_ACPI_PROCESSOR is not set
CONFIG_ACPI_NUMA=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
# CONFIG_ACPI_TABLE_UPGRADE is not set
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_PCI_SLOT=y
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
CONFIG_ACPI_SBS=y
# CONFIG_ACPI_HED is not set
CONFIG_ACPI_CUSTOM_METHOD=m
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_ACPI_NFIT=m
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
CONFIG_DPTF_POWER=m
# CONFIG_PMIC_OPREGION is not set
CONFIG_ACPI_CONFIGFS=y
CONFIG_SFI=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
# CONFIG_CPU_IDLE is not set
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCIEPORTBUS is not set
CONFIG_PCI_BUS_ADDR_T_64BIT=y
CONFIG_PCI_MSI=y
CONFIG_PCI_MSI_IRQ_DOMAIN=y
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_REALLOC_ENABLE_AUTO=y
CONFIG_PCI_STUB=y
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_LOCKLESS_CONFIG=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
# CONFIG_HOTPLUG_PCI is not set

#
# DesignWare PCI Core Support
#
CONFIG_PCIE_DW=y
CONFIG_PCIE_DW_HOST=y
CONFIG_PCIE_DW_PLAT=y

#
# PCI host controller drivers
#
CONFIG_VMD=m

#
# PCI Endpoint
#
CONFIG_PCI_ENDPOINT=y
CONFIG_PCI_ENDPOINT_CONFIGFS=y
CONFIG_PCI_EPF_TEST=y

#
# PCI switch controller drivers
#
CONFIG_PCI_SW_SWITCHTEC=m
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=m
# CONFIG_PCMCIA_LOAD_CIS is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=y
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
# CONFIG_PD6729 is not set
CONFIG_I82092=m
CONFIG_PCCARD_NONSTATIC=y
CONFIG_RAPIDIO=m
CONFIG_RAPIDIO_DISC_TIMEOUT=30
# CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS is not set
CONFIG_RAPIDIO_DMA_ENGINE=y
CONFIG_RAPIDIO_DEBUG=y
# CONFIG_RAPIDIO_ENUM_BASIC is not set
CONFIG_RAPIDIO_CHMAN=m
CONFIG_RAPIDIO_MPORT_CDEV=m

#
# RapidIO Switch drivers
#
CONFIG_RAPIDIO_TSI57X=m
CONFIG_RAPIDIO_CPS_XX=m
CONFIG_RAPIDIO_TSI568=m
CONFIG_RAPIDIO_CPS_GEN2=m
# CONFIG_RAPIDIO_RXS_GEN3 is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ELFCORE=y
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=m
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
CONFIG_X86_X32=y
CONFIG_COMPAT_32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y
CONFIG_NET_INGRESS=y

#
# Networking options
#
CONFIG_PACKET=m
# CONFIG_PACKET_DIAG is not set
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=m
CONFIG_TLS=y
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
# CONFIG_XFRM_USER is not set
CONFIG_XFRM_SUB_POLICY=y
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
CONFIG_NET_KEY=y
# CONFIG_NET_KEY_MIGRATE is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_FIB_TRIE_STATS=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
# CONFIG_IP_ROUTE_VERBOSE is not set
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
# CONFIG_NET_IPIP is not set
CONFIG_NET_IPGRE_DEMUX=m
CONFIG_NET_IP_TUNNEL=m
CONFIG_NET_IPGRE=m
CONFIG_NET_IPGRE_BROADCAST=y
CONFIG_IP_MROUTE=y
CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
CONFIG_IP_PIMSM_V1=y
# CONFIG_IP_PIMSM_V2 is not set
# CONFIG_SYN_COOKIES is not set
CONFIG_NET_IPVTI=m
CONFIG_NET_UDP_TUNNEL=m
CONFIG_NET_FOU=m
CONFIG_NET_FOU_IP_TUNNELS=y
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
CONFIG_INET_TUNNEL=m
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
CONFIG_INET_XFRM_MODE_TUNNEL=m
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_INET_UDP_DIAG=m
# CONFIG_INET_RAW_DIAG is not set
# CONFIG_INET_DIAG_DESTROY is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
# CONFIG_IPV6 is not set
CONFIG_NETLABEL=y
CONFIG_NETWORK_SECMARK=y
CONFIG_NET_PTP_CLASSIFY=y
CONFIG_NETWORK_PHY_TIMESTAMPING=y
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
# CONFIG_NETFILTER_ADVANCED is not set

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_INGRESS=y
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_NETLINK_LOG=y
# CONFIG_NF_CONNTRACK is not set
CONFIG_NF_LOG_COMMON=y
CONFIG_NF_LOG_NETDEV=y
# CONFIG_NF_TABLES is not set
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
# CONFIG_NETFILTER_XT_MARK is not set

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_LOG=m
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
CONFIG_NETFILTER_XT_TARGET_SECMARK=y
CONFIG_NETFILTER_XT_TARGET_TCPMSS=y

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
# CONFIG_NETFILTER_XT_MATCH_POLICY is not set
# CONFIG_IP_SET is not set
CONFIG_IP_VS=m
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
# CONFIG_IP_VS_PROTO_UDP is not set
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
# CONFIG_IP_VS_RR is not set
# CONFIG_IP_VS_WRR is not set
CONFIG_IP_VS_LC=m
CONFIG_IP_VS_WLC=m
CONFIG_IP_VS_FO=m
CONFIG_IP_VS_OVF=m
# CONFIG_IP_VS_LBLC is not set
# CONFIG_IP_VS_LBLCR is not set
CONFIG_IP_VS_DH=m
CONFIG_IP_VS_SH=m
CONFIG_IP_VS_SED=m
# CONFIG_IP_VS_NQ is not set

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS application helper
#

#
# IP: Netfilter Configuration
#
# CONFIG_NF_DEFRAG_IPV4 is not set
CONFIG_NF_SOCKET_IPV4=m
CONFIG_NF_DUP_IPV4=m
CONFIG_NF_LOG_ARP=m
CONFIG_NF_LOG_IPV4=m
CONFIG_NF_REJECT_IPV4=m
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=m
CONFIG_IP_NF_MANGLE=m
CONFIG_IP_NF_RAW=m
# CONFIG_IP_DCCP is not set
CONFIG_IP_SCTP=m
# CONFIG_NET_SCTPPROBE is not set
CONFIG_SCTP_DBG_OBJCNT=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE=y
CONFIG_SCTP_COOKIE_HMAC_MD5=y
CONFIG_SCTP_COOKIE_HMAC_SHA1=y
CONFIG_INET_SCTP_DIAG=m
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
CONFIG_X25=y
CONFIG_LAPB=m
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
CONFIG_NET_SCH_HTB=m
# CONFIG_NET_SCH_HFSC is not set
CONFIG_NET_SCH_PRIO=y
CONFIG_NET_SCH_MULTIQ=m
# CONFIG_NET_SCH_RED is not set
CONFIG_NET_SCH_SFB=y
CONFIG_NET_SCH_SFQ=m
# CONFIG_NET_SCH_TEQL is not set
# CONFIG_NET_SCH_TBF is not set
# CONFIG_NET_SCH_GRED is not set
CONFIG_NET_SCH_DSMARK=m
# CONFIG_NET_SCH_NETEM is not set
# CONFIG_NET_SCH_DRR is not set
CONFIG_NET_SCH_MQPRIO=y
CONFIG_NET_SCH_CHOKE=m
CONFIG_NET_SCH_QFQ=m
CONFIG_NET_SCH_CODEL=y
CONFIG_NET_SCH_FQ_CODEL=y
# CONFIG_NET_SCH_FQ is not set
CONFIG_NET_SCH_HHF=y
CONFIG_NET_SCH_PIE=y
# CONFIG_NET_SCH_INGRESS is not set
CONFIG_NET_SCH_PLUG=m
CONFIG_NET_SCH_DEFAULT=y
# CONFIG_DEFAULT_CODEL is not set
# CONFIG_DEFAULT_FQ_CODEL is not set
CONFIG_DEFAULT_SFQ=y
# CONFIG_DEFAULT_PFIFO_FAST is not set
CONFIG_DEFAULT_NET_SCH="sfq"

#
# Classification
#
CONFIG_NET_CLS=y
# CONFIG_NET_CLS_BASIC is not set
CONFIG_NET_CLS_TCINDEX=m
CONFIG_NET_CLS_ROUTE4=y
CONFIG_NET_CLS_FW=m
CONFIG_NET_CLS_U32=y
CONFIG_CLS_U32_PERF=y
# CONFIG_CLS_U32_MARK is not set
CONFIG_NET_CLS_RSVP=y
CONFIG_NET_CLS_RSVP6=m
CONFIG_NET_CLS_FLOW=y
CONFIG_NET_CLS_CGROUP=m
CONFIG_NET_CLS_BPF=m
CONFIG_NET_CLS_FLOWER=y
# CONFIG_NET_CLS_MATCHALL is not set
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
# CONFIG_NET_EMATCH_CMP is not set
CONFIG_NET_EMATCH_NBYTE=m
CONFIG_NET_EMATCH_U32=y
CONFIG_NET_EMATCH_META=m
CONFIG_NET_EMATCH_TEXT=m
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=y
# CONFIG_NET_ACT_GACT is not set
CONFIG_NET_ACT_MIRRED=y
# CONFIG_NET_ACT_SAMPLE is not set
# CONFIG_NET_ACT_IPT is not set
CONFIG_NET_ACT_NAT=m
CONFIG_NET_ACT_PEDIT=m
# CONFIG_NET_ACT_SIMP is not set
CONFIG_NET_ACT_SKBEDIT=m
# CONFIG_NET_ACT_CSUM is not set
# CONFIG_NET_ACT_VLAN is not set
CONFIG_NET_ACT_BPF=m
# CONFIG_NET_ACT_SKBMOD is not set
CONFIG_NET_ACT_IFE=m
# CONFIG_NET_ACT_TUNNEL_KEY is not set
# CONFIG_NET_IFE_SKBMARK is not set
CONFIG_NET_IFE_SKBPRIO=m
CONFIG_NET_IFE_SKBTCINDEX=m
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
CONFIG_VSOCKETS=y
# CONFIG_VMWARE_VMCI_VSOCKETS is not set
CONFIG_VIRTIO_VSOCKETS=m
CONFIG_VIRTIO_VSOCKETS_COMMON=m
# CONFIG_NETLINK_DIAG is not set
CONFIG_MPLS=y
CONFIG_NET_MPLS_GSO=m
# CONFIG_MPLS_ROUTING is not set
CONFIG_HSR=m
# CONFIG_NET_SWITCHDEV is not set
CONFIG_NET_L3_MASTER_DEV=y
CONFIG_NET_NCSI=y
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_CGROUP_NET_PRIO is not set
CONFIG_CGROUP_NET_CLASSID=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_BPF_JIT=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
CONFIG_NET_PKTGEN=m
# CONFIG_NET_TCPPROBE is not set
CONFIG_NET_DROP_MONITOR=m
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
CONFIG_AF_KCM=m
CONFIG_STREAM_PARSER=m
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=m
# CONFIG_NL80211_TESTMODE is not set
CONFIG_CFG80211_DEVELOPER_WARNINGS=y
# CONFIG_CFG80211_DEFAULT_PS is not set
CONFIG_CFG80211_DEBUGFS=y
# CONFIG_CFG80211_INTERNAL_REGDB is not set
CONFIG_CFG80211_CRDA_SUPPORT=y
CONFIG_CFG80211_WEXT=y
CONFIG_LIB80211=m
CONFIG_LIB80211_CRYPT_WEP=m
CONFIG_LIB80211_CRYPT_CCMP=m
CONFIG_LIB80211_CRYPT_TKIP=m
# CONFIG_LIB80211_DEBUG is not set
CONFIG_MAC80211=m
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_MINSTREL_HT=y
# CONFIG_MAC80211_RC_MINSTREL_VHT is not set
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
# CONFIG_MAC80211_MESH is not set
CONFIG_MAC80211_LEDS=y
# CONFIG_MAC80211_DEBUGFS is not set
CONFIG_MAC80211_MESSAGE_TRACING=y
# CONFIG_MAC80211_DEBUG_MENU is not set
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
CONFIG_WIMAX=m
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=m
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
# CONFIG_RFKILL_GPIO is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=m
# CONFIG_NET_9P_DEBUG is not set
CONFIG_CAIF=m
# CONFIG_CAIF_DEBUG is not set
# CONFIG_CAIF_NETDEV is not set
CONFIG_CAIF_USB=m
CONFIG_CEPH_LIB=m
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
# CONFIG_CEPH_LIB_USE_DNS_RESOLVER is not set
CONFIG_NFC=m
CONFIG_NFC_DIGITAL=m
CONFIG_NFC_NCI=m
CONFIG_NFC_NCI_UART=m
CONFIG_NFC_HCI=m
# CONFIG_NFC_SHDLC is not set

#
# Near Field Communication (NFC) devices
#
# CONFIG_NFC_MEI_PHY is not set
CONFIG_NFC_SIM=m
CONFIG_NFC_FDP=m
CONFIG_NFC_FDP_I2C=m
CONFIG_NFC_PN533=m
CONFIG_NFC_PN533_I2C=m
# CONFIG_NFC_MRVL_UART is not set
# CONFIG_NFC_ST_NCI_I2C is not set
CONFIG_NFC_NXP_NCI=m
# CONFIG_NFC_NXP_NCI_I2C is not set
# CONFIG_NFC_S3FWRN5_I2C is not set
# CONFIG_PSAMPLE is not set
CONFIG_NET_IFE=m
CONFIG_LWTUNNEL=y
CONFIG_LWTUNNEL_BPF=y
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
CONFIG_NET_DEVLINK=y
CONFIG_MAY_USE_DEVLINK=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
# CONFIG_STANDALONE is not set
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
CONFIG_WANT_DEV_COREDUMP=y
CONFIG_ALLOW_DEV_COREDUMP=y
CONFIG_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
CONFIG_TEST_ASYNC_DRIVER_PROBE=m
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
CONFIG_DMA_FENCE_TRACE=y
# CONFIG_DMA_CMA is not set

#
# Bus devices
#
CONFIG_CONNECTOR=y
# CONFIG_PROC_EVENTS is not set
CONFIG_MTD=m
CONFIG_MTD_TESTS=m
# CONFIG_MTD_REDBOOT_PARTS is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_AR7_PARTS=m

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=m
CONFIG_MTD_BLOCK=m
CONFIG_MTD_BLOCK_RO=m
CONFIG_FTL=m
CONFIG_NFTL=m
CONFIG_NFTL_RW=y
CONFIG_INFTL=m
# CONFIG_RFD_FTL is not set
# CONFIG_SSFDC is not set
CONFIG_SM_FTL=m
# CONFIG_MTD_OOPS is not set
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=m
# CONFIG_MTD_JEDECPROBE is not set
CONFIG_MTD_GEN_PROBE=m
CONFIG_MTD_CFI_ADV_OPTIONS=y
# CONFIG_MTD_CFI_NOSWAP is not set
# CONFIG_MTD_CFI_BE_BYTE_SWAP is not set
CONFIG_MTD_CFI_LE_BYTE_SWAP=y
CONFIG_MTD_CFI_GEOMETRY=y
CONFIG_MTD_MAP_BANK_WIDTH_1=y
# CONFIG_MTD_MAP_BANK_WIDTH_2 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_4 is not set
CONFIG_MTD_MAP_BANK_WIDTH_8=y
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
CONFIG_MTD_MAP_BANK_WIDTH_32=y
CONFIG_MTD_CFI_I1=y
# CONFIG_MTD_CFI_I2 is not set
# CONFIG_MTD_CFI_I4 is not set
CONFIG_MTD_CFI_I8=y
# CONFIG_MTD_OTP is not set
CONFIG_MTD_CFI_INTELEXT=m
CONFIG_MTD_CFI_AMDSTD=m
CONFIG_MTD_CFI_STAA=m
CONFIG_MTD_CFI_UTIL=m
CONFIG_MTD_RAM=m
CONFIG_MTD_ROM=m
CONFIG_MTD_ABSENT=m

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
CONFIG_MTD_PHYSMAP=m
# CONFIG_MTD_PHYSMAP_COMPAT is not set
CONFIG_MTD_SBC_GXX=m
# CONFIG_MTD_PCI is not set
CONFIG_MTD_PCMCIA=m
CONFIG_MTD_PCMCIA_ANONYMOUS=y
CONFIG_MTD_GPIO_ADDR=m
# CONFIG_MTD_INTEL_VR_NOR is not set
CONFIG_MTD_PLATRAM=m
CONFIG_MTD_LATCH_ADDR=m

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_SLRAM=m
CONFIG_MTD_PHRAM=m
CONFIG_MTD_MTDRAM=m
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTD_BLOCK2MTD=m

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=m
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
CONFIG_MTD_NAND_ECC=m
CONFIG_MTD_NAND_ECC_SMC=y
CONFIG_MTD_NAND=m
CONFIG_MTD_NAND_BCH=m
CONFIG_MTD_NAND_ECC_BCH=y
CONFIG_MTD_SM_COMMON=m
CONFIG_MTD_NAND_DENALI=m
CONFIG_MTD_NAND_DENALI_PCI=m
# CONFIG_MTD_NAND_GPIO is not set
# CONFIG_MTD_NAND_OMAP_BCH_BUILD is not set
CONFIG_MTD_NAND_RICOH=m
CONFIG_MTD_NAND_DISKONCHIP=m
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED=y
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
CONFIG_MTD_NAND_DISKONCHIP_PROBE_HIGH=y
# CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE is not set
CONFIG_MTD_NAND_DOCG4=m
CONFIG_MTD_NAND_CAFE=m
CONFIG_MTD_NAND_NANDSIM=m
CONFIG_MTD_NAND_PLATFORM=m
# CONFIG_MTD_NAND_HISI504 is not set
# CONFIG_MTD_NAND_MTK is not set
CONFIG_MTD_ONENAND=m
CONFIG_MTD_ONENAND_VERIFY_WRITE=y
CONFIG_MTD_ONENAND_GENERIC=m
# CONFIG_MTD_ONENAND_OTP is not set
# CONFIG_MTD_ONENAND_2X_PROGRAM is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=m
CONFIG_MTD_QINFO_PROBE=m
CONFIG_MTD_SPI_NOR=m
CONFIG_MTD_MT81xx_NOR=m
CONFIG_MTD_SPI_NOR_USE_4K_SECTORS=y
CONFIG_MTD_UBI=m
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
CONFIG_MTD_UBI_FASTMAP=y
# CONFIG_MTD_UBI_GLUEBI is not set
# CONFIG_MTD_UBI_BLOCK is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
# CONFIG_PARPORT is not set
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_NULL_BLK=m
CONFIG_BLK_DEV_FD=y
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=y
# CONFIG_BLK_CPQ_CISS_DA is not set
CONFIG_BLK_DEV_DAC960=y
CONFIG_BLK_DEV_UMEM=y
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
CONFIG_BLK_DEV_CRYPTOLOOP=m
CONFIG_BLK_DEV_DRBD=m
CONFIG_DRBD_FAULT_INJECTION=y
CONFIG_BLK_DEV_NBD=y
CONFIG_BLK_DEV_SKD=m
CONFIG_BLK_DEV_SX8=m
CONFIG_BLK_DEV_RAM=m
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=4096
# CONFIG_CDROM_PKTCDVD is not set
CONFIG_ATA_OVER_ETH=m
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_RBD is not set
CONFIG_BLK_DEV_RSXX=y
CONFIG_NVME_CORE=y
CONFIG_BLK_DEV_NVME=y
CONFIG_NVME_FABRICS=y
CONFIG_NVME_FC=y
CONFIG_NVME_TARGET=m
CONFIG_NVME_TARGET_LOOP=m
# CONFIG_NVME_TARGET_FC is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_AD525X_DPOT is not set
CONFIG_DUMMY_IRQ=y
CONFIG_IBM_ASM=m
CONFIG_PHANTOM=y
# CONFIG_SGI_IOC4 is not set
CONFIG_TIFM_CORE=m
# CONFIG_TIFM_7XX1 is not set
CONFIG_ICS932S401=m
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_HP_ILO=m
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1770 is not set
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=m
CONFIG_DS1682=y
# CONFIG_VMWARE_BALLOON is not set
CONFIG_USB_SWITCH_FSA9480=m
# CONFIG_SRAM is not set
# CONFIG_PCI_ENDPOINT_TEST is not set
CONFIG_C2PORT=m
# CONFIG_C2PORT_DURAMAR_2150 is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
# CONFIG_EEPROM_LEGACY is not set
CONFIG_EEPROM_MAX6875=m
CONFIG_EEPROM_93CX6=y
CONFIG_EEPROM_IDT_89HPESX=m
CONFIG_CB710_CORE=y
CONFIG_CB710_DEBUG=y
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
CONFIG_TI_ST=y
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
CONFIG_INTEL_MEI=y
# CONFIG_INTEL_MEI_ME is not set
CONFIG_INTEL_MEI_TXE=y
CONFIG_VMWARE_VMCI=y

#
# Intel MIC Bus Driver
#
CONFIG_INTEL_MIC_BUS=m

#
# SCIF Bus Driver
#
CONFIG_SCIF_BUS=m

#
# VOP Bus Driver
#
# CONFIG_VOP_BUS is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#
CONFIG_SCIF=m

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#
CONFIG_MIC_COSM=m

#
# VOP Driver
#
CONFIG_GENWQE=m
CONFIG_GENWQE_PLATFORM_ERROR_RECOVERY=0
# CONFIG_ECHO is not set
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_AFU_DRIVER_OPS is not set
# CONFIG_CXL_LIB is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
# CONFIG_BLK_DEV_SD is not set
CONFIG_CHR_DEV_ST=y
CONFIG_CHR_DEV_OSST=m
CONFIG_BLK_DEV_SR=m
CONFIG_BLK_DEV_SR_VENDOR=y
# CONFIG_CHR_DEV_SG is not set
CONFIG_CHR_DEV_SCH=m
CONFIG_SCSI_ENCLOSURE=m
CONFIG_SCSI_CONSTANTS=y
# CONFIG_SCSI_LOGGING is not set
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=m
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=m
CONFIG_SCSI_SAS_ATA=y
# CONFIG_SCSI_SAS_HOST_SMP is not set
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
CONFIG_ISCSI_BOOT_SYSFS=m
CONFIG_SCSI_CXGB3_ISCSI=m
# CONFIG_SCSI_CXGB4_ISCSI is not set
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_SCSI_BNX2X_FCOE is not set
# CONFIG_BE2ISCSI is not set
CONFIG_BLK_DEV_3W_XXXX_RAID=m
# CONFIG_SCSI_HPSA is not set
CONFIG_SCSI_3W_9XXX=y
CONFIG_SCSI_3W_SAS=m
CONFIG_SCSI_ACARD=m
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC79XX is not set
CONFIG_SCSI_AIC94XX=m
CONFIG_AIC94XX_DEBUG=y
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_MVUMI is not set
CONFIG_SCSI_DPT_I2O=m
CONFIG_SCSI_ADVANSYS=m
CONFIG_SCSI_ARCMSR=y
# CONFIG_SCSI_ESAS2R is not set
# CONFIG_MEGARAID_NEWGEN is not set
CONFIG_MEGARAID_LEGACY=y
CONFIG_MEGARAID_SAS=y
CONFIG_SCSI_MPT3SAS=y
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
CONFIG_SCSI_MPT2SAS=y
# CONFIG_SCSI_SMARTPQI is not set
CONFIG_SCSI_UFSHCD=y
# CONFIG_SCSI_UFSHCD_PCI is not set
# CONFIG_SCSI_UFSHCD_PLATFORM is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
CONFIG_VMWARE_PVSCSI=m
CONFIG_LIBFC=m
CONFIG_LIBFCOE=m
CONFIG_FCOE=m
CONFIG_FCOE_FNIC=m
CONFIG_SCSI_SNIC=y
# CONFIG_SCSI_SNIC_DEBUG_FS is not set
CONFIG_SCSI_DMX3191D=y
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
CONFIG_SCSI_GDTH=y
# CONFIG_SCSI_ISCI is not set
CONFIG_SCSI_IPS=m
CONFIG_SCSI_INITIO=y
# CONFIG_SCSI_INIA100 is not set
CONFIG_SCSI_STEX=m
CONFIG_SCSI_SYM53C8XX_2=m
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
CONFIG_SCSI_SYM53C8XX_MMIO=y
CONFIG_SCSI_IPR=m
# CONFIG_SCSI_IPR_TRACE is not set
# CONFIG_SCSI_IPR_DUMP is not set
CONFIG_SCSI_QLOGIC_1280=y
CONFIG_SCSI_QLA_FC=m
# CONFIG_TCM_QLA2XXX is not set
CONFIG_SCSI_QLA_ISCSI=m
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
CONFIG_SCSI_AM53C974=y
CONFIG_SCSI_WD719X=y
CONFIG_SCSI_DEBUG=m
# CONFIG_SCSI_PMCRAID is not set
# CONFIG_SCSI_PM8001 is not set
# CONFIG_SCSI_BFA_FC is not set
CONFIG_SCSI_VIRTIO=m
CONFIG_SCSI_CHELSIO_FCOE=m
CONFIG_SCSI_LOWLEVEL_PCMCIA=y
CONFIG_PCMCIA_AHA152X=m
# CONFIG_PCMCIA_FDOMAIN is not set
# CONFIG_PCMCIA_QLOGIC is not set
CONFIG_PCMCIA_SYM53C500=m
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=m
CONFIG_SCSI_DH_HP_SW=y
# CONFIG_SCSI_DH_EMC is not set
CONFIG_SCSI_DH_ALUA=m
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
# CONFIG_ATA_ACPI is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
# CONFIG_SATA_AHCI is not set
CONFIG_SATA_AHCI_PLATFORM=y
CONFIG_SATA_INIC162X=y
CONFIG_SATA_ACARD_AHCI=y
CONFIG_SATA_SIL24=m
# CONFIG_ATA_SFF is not set
# CONFIG_MD is not set
CONFIG_TARGET_CORE=y
CONFIG_TCM_IBLOCK=m
CONFIG_TCM_FILEIO=y
CONFIG_TCM_PSCSI=m
CONFIG_TCM_USER2=m
CONFIG_LOOPBACK_TARGET=m
CONFIG_TCM_FC=m
CONFIG_ISCSI_TARGET=m
# CONFIG_ISCSI_TARGET_CXGB4 is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
CONFIG_FIREWIRE_NOSY=m
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_MII=y
# CONFIG_NET_CORE is not set
CONFIG_ARCNET=m
# CONFIG_ARCNET_1201 is not set
CONFIG_ARCNET_1051=m
# CONFIG_ARCNET_RAW is not set
CONFIG_ARCNET_CAP=m
# CONFIG_ARCNET_COM90xx is not set
CONFIG_ARCNET_COM90xxIO=m
CONFIG_ARCNET_RIM_I=m
CONFIG_ARCNET_COM20020=m
CONFIG_ARCNET_COM20020_PCI=m
CONFIG_ARCNET_COM20020_CS=m

#
# CAIF transport drivers
#
# CONFIG_CAIF_TTY is not set
# CONFIG_CAIF_SPI_SLAVE is not set
# CONFIG_CAIF_HSI is not set
# CONFIG_CAIF_VIRTIO is not set

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=y
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_NET_VENDOR_ADAPTEC is not set
# CONFIG_NET_VENDOR_AGERE is not set
CONFIG_NET_VENDOR_ALACRITECH=y
CONFIG_SLICOSS=m
# CONFIG_NET_VENDOR_ALTEON is not set
# CONFIG_ALTERA_TSE is not set
# CONFIG_NET_VENDOR_AMAZON is not set
CONFIG_NET_VENDOR_AMD=y
CONFIG_AMD8111_ETH=y
CONFIG_PCNET32=y
CONFIG_PCMCIA_NMCLAN=m
CONFIG_AMD_XGBE=m
# CONFIG_AMD_XGBE_DCB is not set
CONFIG_AMD_XGBE_HAVE_ECC=y
# CONFIG_NET_VENDOR_AQUANTIA is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
CONFIG_ATL2=m
CONFIG_ATL1=m
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
CONFIG_ALX=m
# CONFIG_NET_VENDOR_AURORA is not set
CONFIG_NET_CADENCE=y
CONFIG_MACB=m
CONFIG_MACB_USE_HWSTAMP=y
CONFIG_MACB_PCI=m
# CONFIG_NET_VENDOR_BROADCOM is not set
CONFIG_NET_VENDOR_BROCADE=y
CONFIG_BNA=y
# CONFIG_NET_VENDOR_CAVIUM is not set
CONFIG_NET_VENDOR_CHELSIO=y
CONFIG_CHELSIO_T1=m
CONFIG_CHELSIO_T1_1G=y
CONFIG_CHELSIO_T3=y
CONFIG_CHELSIO_T4=y
# CONFIG_CHELSIO_T4_DCB is not set
CONFIG_CHELSIO_T4VF=m
CONFIG_CHELSIO_LIB=m
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
CONFIG_CX_ECAT=m
CONFIG_DNET=y
# CONFIG_NET_VENDOR_DEC is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
CONFIG_SUNDANCE=m
CONFIG_SUNDANCE_MMIO=y
# CONFIG_NET_VENDOR_EMULEX is not set
CONFIG_NET_VENDOR_EZCHIP=y
CONFIG_NET_VENDOR_EXAR=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
# CONFIG_NET_VENDOR_FUJITSU is not set
CONFIG_NET_VENDOR_HP=y
CONFIG_HP100=y
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=m
CONFIG_E1000E_HWTS=y
CONFIG_IGB=m
CONFIG_IGB_HWMON=y
CONFIG_IGB_DCA=y
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
CONFIG_IXGBE=m
CONFIG_IXGBE_HWMON=y
CONFIG_IXGBE_DCA=y
# CONFIG_IXGBE_DCB is not set
# CONFIG_IXGBEVF is not set
# CONFIG_I40E is not set
# CONFIG_I40EVF is not set
# CONFIG_FM10K is not set
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_MVMDIO=m
CONFIG_SKGE=y
# CONFIG_SKGE_DEBUG is not set
CONFIG_SKGE_GENESIS=y
CONFIG_SKY2=m
# CONFIG_SKY2_DEBUG is not set
# CONFIG_NET_VENDOR_MELLANOX is not set
# CONFIG_NET_VENDOR_MICREL is not set
# CONFIG_NET_VENDOR_MYRI is not set
CONFIG_FEALNX=y
# CONFIG_NET_VENDOR_NATSEMI is not set
# CONFIG_NET_VENDOR_NETRONOME is not set
# CONFIG_NET_VENDOR_NVIDIA is not set
# CONFIG_NET_VENDOR_OKI is not set
# CONFIG_ETHOC is not set
CONFIG_NET_PACKET_ENGINE=y
CONFIG_HAMACHI=y
CONFIG_YELLOWFIN=m
# CONFIG_NET_VENDOR_QLOGIC is not set
CONFIG_NET_VENDOR_QUALCOMM=y
CONFIG_QCOM_EMAC=y
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_8139CP is not set
CONFIG_8139TOO=y
CONFIG_8139TOO_PIO=y
# CONFIG_8139TOO_TUNE_TWISTER is not set
CONFIG_8139TOO_8129=y
# CONFIG_8139_OLD_RX_RESET is not set
# CONFIG_R8169 is not set
CONFIG_NET_VENDOR_RENESAS=y
# CONFIG_NET_VENDOR_RDC is not set
CONFIG_NET_VENDOR_ROCKER=y
CONFIG_NET_VENDOR_SAMSUNG=y
CONFIG_SXGBE_ETH=m
# CONFIG_NET_VENDOR_SEEQ is not set
# CONFIG_NET_VENDOR_SILAN is not set
# CONFIG_NET_VENDOR_SIS is not set
CONFIG_NET_VENDOR_SOLARFLARE=y
# CONFIG_SFC is not set
# CONFIG_SFC_FALCON is not set
# CONFIG_NET_VENDOR_SMSC is not set
# CONFIG_NET_VENDOR_STMICRO is not set
# CONFIG_NET_VENDOR_SUN is not set
# CONFIG_NET_VENDOR_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
CONFIG_TI_CPSW_ALE=y
CONFIG_TLAN=m
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_VELOCITY is not set
# CONFIG_NET_VENDOR_WIZNET is not set
# CONFIG_NET_VENDOR_XIRCOM is not set
# CONFIG_NET_VENDOR_SYNOPSYS is not set
CONFIG_FDDI=m
CONFIG_DEFXX=m
# CONFIG_DEFXX_MMIO is not set
CONFIG_SKFP=m
# CONFIG_HIPPI is not set
CONFIG_NET_SB1000=m
CONFIG_MDIO_DEVICE=y
CONFIG_MDIO_BITBANG=m
CONFIG_MDIO_CAVIUM=m
CONFIG_MDIO_GPIO=m
CONFIG_MDIO_THUNDER=m
CONFIG_PHYLIB=y
CONFIG_SWPHY=y
# CONFIG_LED_TRIGGER_PHY is not set

#
# MII PHY device drivers
#
CONFIG_AMD_PHY=m
CONFIG_AQUANTIA_PHY=m
CONFIG_AT803X_PHY=y
CONFIG_BCM7XXX_PHY=m
# CONFIG_BCM87XX_PHY is not set
CONFIG_BCM_NET_PHYLIB=m
CONFIG_BROADCOM_PHY=m
CONFIG_CICADA_PHY=y
CONFIG_CORTINA_PHY=y
CONFIG_DAVICOM_PHY=m
# CONFIG_DP83848_PHY is not set
# CONFIG_DP83867_PHY is not set
CONFIG_FIXED_PHY=y
# CONFIG_ICPLUS_PHY is not set
CONFIG_INTEL_XWAY_PHY=y
CONFIG_LSI_ET1011C_PHY=m
# CONFIG_LXT_PHY is not set
CONFIG_MARVELL_PHY=m
CONFIG_MARVELL_10G_PHY=m
CONFIG_MICREL_PHY=m
# CONFIG_MICROCHIP_PHY is not set
# CONFIG_MICROSEMI_PHY is not set
# CONFIG_NATIONAL_PHY is not set
CONFIG_QSEMI_PHY=m
# CONFIG_REALTEK_PHY is not set
CONFIG_SMSC_PHY=m
# CONFIG_STE10XP is not set
CONFIG_TERANETICS_PHY=m
CONFIG_VITESSE_PHY=m
# CONFIG_XILINX_GMII2RGMII is not set
CONFIG_PPP=m
CONFIG_PPP_BSDCOMP=m
CONFIG_PPP_DEFLATE=m
CONFIG_PPP_FILTER=y
CONFIG_PPP_MPPE=m
CONFIG_PPP_MULTILINK=y
CONFIG_PPPOE=m
CONFIG_PPTP=m
CONFIG_PPP_ASYNC=m
CONFIG_PPP_SYNC_TTY=m
CONFIG_SLIP=m
CONFIG_SLHC=m
CONFIG_SLIP_COMPRESSED=y
# CONFIG_SLIP_SMART is not set
CONFIG_SLIP_MODE_SLIP6=y

#
# Host-side USB support is needed for USB Network Adapter support
#
CONFIG_WLAN=y
# CONFIG_WLAN_VENDOR_ADMTEK is not set
CONFIG_ATH_COMMON=m
CONFIG_WLAN_VENDOR_ATH=y
CONFIG_ATH_DEBUG=y
# CONFIG_ATH_TRACEPOINTS is not set
CONFIG_ATH5K=m
# CONFIG_ATH5K_DEBUG is not set
# CONFIG_ATH5K_TRACER is not set
CONFIG_ATH5K_PCI=y
CONFIG_ATH9K_HW=m
CONFIG_ATH9K_COMMON=m
CONFIG_ATH9K_BTCOEX_SUPPORT=y
CONFIG_ATH9K=m
CONFIG_ATH9K_PCI=y
CONFIG_ATH9K_AHB=y
# CONFIG_ATH9K_DEBUGFS is not set
# CONFIG_ATH9K_DYNACK is not set
CONFIG_ATH9K_WOW=y
CONFIG_ATH9K_RFKILL=y
# CONFIG_ATH9K_CHANNEL_CONTEXT is not set
CONFIG_ATH9K_PCOEM=y
# CONFIG_ATH9K_HWRNG is not set
# CONFIG_ATH6KL is not set
CONFIG_WIL6210=m
# CONFIG_WIL6210_ISR_COR is not set
CONFIG_WIL6210_TRACING=y
CONFIG_ATH10K=m
CONFIG_ATH10K_PCI=m
# CONFIG_ATH10K_SDIO is not set
# CONFIG_ATH10K_DEBUG is not set
CONFIG_ATH10K_DEBUGFS=y
CONFIG_ATH10K_TRACING=y
# CONFIG_WCN36XX is not set
CONFIG_WLAN_VENDOR_ATMEL=y
CONFIG_ATMEL=m
# CONFIG_PCI_ATMEL is not set
CONFIG_PCMCIA_ATMEL=m
# CONFIG_WLAN_VENDOR_BROADCOM is not set
# CONFIG_WLAN_VENDOR_CISCO is not set
CONFIG_WLAN_VENDOR_INTEL=y
CONFIG_IPW2100=m
CONFIG_IPW2100_MONITOR=y
CONFIG_IPW2100_DEBUG=y
# CONFIG_IPW2200 is not set
CONFIG_LIBIPW=m
CONFIG_LIBIPW_DEBUG=y
CONFIG_IWLEGACY=m
# CONFIG_IWL4965 is not set
CONFIG_IWL3945=m

#
# iwl3945 / iwl4965 Debugging Options
#
# CONFIG_IWLEGACY_DEBUG is not set
CONFIG_IWLWIFI=m
CONFIG_IWLWIFI_LEDS=y
# CONFIG_IWLDVM is not set
CONFIG_IWLMVM=m
CONFIG_IWLWIFI_OPMODE_MODULAR=y
# CONFIG_IWLWIFI_BCAST_FILTERING is not set

#
# Debugging Options
#
CONFIG_IWLWIFI_DEBUG=y
CONFIG_IWLWIFI_DEVICE_TRACING=y
# CONFIG_WLAN_VENDOR_INTERSIL is not set
CONFIG_WLAN_VENDOR_MARVELL=y
# CONFIG_LIBERTAS is not set
# CONFIG_LIBERTAS_THINFIRM is not set
CONFIG_MWIFIEX=m
# CONFIG_MWIFIEX_SDIO is not set
CONFIG_MWIFIEX_PCIE=m
CONFIG_MWL8K=m
# CONFIG_WLAN_VENDOR_MEDIATEK is not set
CONFIG_WLAN_VENDOR_RALINK=y
# CONFIG_RT2X00 is not set
CONFIG_WLAN_VENDOR_REALTEK=y
CONFIG_RTL8180=m
# CONFIG_RTL_CARDS is not set
CONFIG_WLAN_VENDOR_RSI=y
CONFIG_RSI_91X=m
# CONFIG_RSI_DEBUGFS is not set
CONFIG_RSI_SDIO=m
# CONFIG_WLAN_VENDOR_ST is not set
CONFIG_WLAN_VENDOR_TI=y
CONFIG_WL1251=m
CONFIG_WL1251_SDIO=m
# CONFIG_WL12XX is not set
CONFIG_WL18XX=m
CONFIG_WLCORE=m
CONFIG_WLCORE_SDIO=m
CONFIG_WILINK_PLATFORM_DATA=y
CONFIG_WLAN_VENDOR_ZYDAS=y
# CONFIG_WLAN_VENDOR_QUANTENNA is not set
CONFIG_PCMCIA_RAYCS=m
CONFIG_PCMCIA_WL3501=m
# CONFIG_MAC80211_HWSIM is not set

#
# WiMAX Wireless Broadband devices
#

#
# Enable USB support to see WiMAX USB drivers
#
# CONFIG_WAN is not set
CONFIG_VMXNET3=y
CONFIG_FUJITSU_ES=m
CONFIG_ISDN=y
# CONFIG_ISDN_I4L is not set
CONFIG_ISDN_CAPI=y
# CONFIG_CAPI_TRACE is not set
CONFIG_ISDN_CAPI_CAPI20=m
CONFIG_ISDN_CAPI_MIDDLEWARE=y

#
# CAPI hardware drivers
#
# CONFIG_CAPI_AVM is not set
# CONFIG_CAPI_EICON is not set
# CONFIG_ISDN_DRV_GIGASET is not set
CONFIG_HYSDN=m
CONFIG_HYSDN_CAPI=y
CONFIG_MISDN=m
CONFIG_MISDN_DSP=m
CONFIG_MISDN_L1OIP=m

#
# mISDN hardware drivers
#
# CONFIG_MISDN_HFCPCI is not set
CONFIG_MISDN_HFCMULTI=m
CONFIG_MISDN_AVMFRITZ=m
# CONFIG_MISDN_SPEEDFAX is not set
CONFIG_MISDN_INFINEON=m
CONFIG_MISDN_W6692=m
# CONFIG_MISDN_NETJET is not set
CONFIG_MISDN_IPAC=m
CONFIG_NVM=y
# CONFIG_NVM_DEBUG is not set
# CONFIG_NVM_RRPC is not set
CONFIG_NVM_PBLK=m

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_LEDS is not set
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=m
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5520 is not set
CONFIG_KEYBOARD_ADP5588=m
CONFIG_KEYBOARD_ADP5589=m
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=m
# CONFIG_KEYBOARD_QT2160 is not set
CONFIG_KEYBOARD_DLINK_DIR685=m
CONFIG_KEYBOARD_LKKBD=m
CONFIG_KEYBOARD_GPIO=y
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
CONFIG_KEYBOARD_TCA8418=m
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
CONFIG_KEYBOARD_LM8333=y
CONFIG_KEYBOARD_MAX7359=y
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_SAMSUNG is not set
CONFIG_KEYBOARD_STOWAWAY=m
# CONFIG_KEYBOARD_SUNKBD is not set
CONFIG_KEYBOARD_TM2_TOUCHKEY=y
CONFIG_KEYBOARD_TWL4030=y
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=m
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_BYD=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_SYNAPTICS_SMBUS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
CONFIG_MOUSE_PS2_ELANTECH=y
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_PS2_FOCALTECH=y
# CONFIG_MOUSE_PS2_VMMOUSE is not set
CONFIG_MOUSE_PS2_SMBUS=y
CONFIG_MOUSE_SERIAL=m
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
CONFIG_MOUSE_CYAPA=m
CONFIG_MOUSE_ELAN_I2C=y
CONFIG_MOUSE_ELAN_I2C_I2C=y
CONFIG_MOUSE_ELAN_I2C_SMBUS=y
# CONFIG_MOUSE_VSXXXAA is not set
CONFIG_MOUSE_GPIO=y
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
CONFIG_TOUCHSCREEN_88PM860X=m
CONFIG_TOUCHSCREEN_AD7879=y
CONFIG_TOUCHSCREEN_AD7879_I2C=y
CONFIG_TOUCHSCREEN_ATMEL_MXT=m
CONFIG_TOUCHSCREEN_ATMEL_MXT_T37=y
CONFIG_TOUCHSCREEN_AUO_PIXCIR=m
CONFIG_TOUCHSCREEN_BU21013=y
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
# CONFIG_TOUCHSCREEN_CYTTSP4_CORE is not set
CONFIG_TOUCHSCREEN_DA9052=m
CONFIG_TOUCHSCREEN_DYNAPRO=y
CONFIG_TOUCHSCREEN_HAMPSHIRE=m
CONFIG_TOUCHSCREEN_EETI=y
CONFIG_TOUCHSCREEN_EGALAX_SERIAL=y
# CONFIG_TOUCHSCREEN_FUJITSU is not set
CONFIG_TOUCHSCREEN_GOODIX=m
CONFIG_TOUCHSCREEN_ILI210X=m
# CONFIG_TOUCHSCREEN_GUNZE is not set
CONFIG_TOUCHSCREEN_EKTF2127=y
CONFIG_TOUCHSCREEN_ELAN=y
# CONFIG_TOUCHSCREEN_ELO is not set
# CONFIG_TOUCHSCREEN_WACOM_W8001 is not set
CONFIG_TOUCHSCREEN_WACOM_I2C=y
CONFIG_TOUCHSCREEN_MAX11801=y
CONFIG_TOUCHSCREEN_MCS5000=y
CONFIG_TOUCHSCREEN_MMS114=y
CONFIG_TOUCHSCREEN_MELFAS_MIP4=y
# CONFIG_TOUCHSCREEN_MTOUCH is not set
CONFIG_TOUCHSCREEN_INEXIO=y
CONFIG_TOUCHSCREEN_MK712=y
CONFIG_TOUCHSCREEN_PENMOUNT=y
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
# CONFIG_TOUCHSCREEN_TOUCHWIN is not set
CONFIG_TOUCHSCREEN_TI_AM335X_TSC=m
CONFIG_TOUCHSCREEN_PIXCIR=m
CONFIG_TOUCHSCREEN_WDT87XX_I2C=m
CONFIG_TOUCHSCREEN_WM831X=y
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_TOUCHSCREEN_TOUCHIT213=m
CONFIG_TOUCHSCREEN_TSC_SERIO=y
CONFIG_TOUCHSCREEN_TSC200X_CORE=y
CONFIG_TOUCHSCREEN_TSC2004=y
CONFIG_TOUCHSCREEN_TSC2007=y
CONFIG_TOUCHSCREEN_RM_TS=m
CONFIG_TOUCHSCREEN_SILEAD=m
CONFIG_TOUCHSCREEN_SIS_I2C=y
CONFIG_TOUCHSCREEN_ST1232=m
CONFIG_TOUCHSCREEN_STMFTS=y
# CONFIG_TOUCHSCREEN_SX8654 is not set
CONFIG_TOUCHSCREEN_TPS6507X=m
# CONFIG_TOUCHSCREEN_ZET6223 is not set
CONFIG_TOUCHSCREEN_ZFORCE=y
CONFIG_TOUCHSCREEN_ROHM_BU21023=y
CONFIG_INPUT_MISC=y
CONFIG_INPUT_88PM860X_ONKEY=m
# CONFIG_INPUT_88PM80X_ONKEY is not set
CONFIG_INPUT_AD714X=m
CONFIG_INPUT_AD714X_I2C=m
CONFIG_INPUT_BMA150=y
# CONFIG_INPUT_E3X0_BUTTON is not set
# CONFIG_INPUT_PCSPKR is not set
# CONFIG_INPUT_MMA8450 is not set
# CONFIG_INPUT_APANEL is not set
CONFIG_INPUT_GP2A=m
CONFIG_INPUT_GPIO_BEEPER=y
# CONFIG_INPUT_GPIO_TILT_POLLED is not set
CONFIG_INPUT_GPIO_DECODER=y
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
CONFIG_INPUT_KXTJ9=m
# CONFIG_INPUT_KXTJ9_POLLED_MODE is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_REGULATOR_HAPTIC=m
CONFIG_INPUT_TWL4030_PWRBUTTON=m
CONFIG_INPUT_TWL4030_VIBRA=m
CONFIG_INPUT_TWL6040_VIBRA=m
CONFIG_INPUT_UINPUT=m
CONFIG_INPUT_PALMAS_PWRBUTTON=y
# CONFIG_INPUT_PCF50633_PMU is not set
CONFIG_INPUT_PCF8574=m
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
# CONFIG_INPUT_DA9052_ONKEY is not set
# CONFIG_INPUT_DA9063_ONKEY is not set
# CONFIG_INPUT_WM831X_ON is not set
CONFIG_INPUT_ADXL34X=y
CONFIG_INPUT_ADXL34X_I2C=m
CONFIG_INPUT_CMA3000=m
# CONFIG_INPUT_CMA3000_I2C is not set
CONFIG_INPUT_IDEAPAD_SLIDEBAR=m
# CONFIG_INPUT_SOC_BUTTON_ARRAY is not set
CONFIG_INPUT_DRV260X_HAPTICS=y
CONFIG_INPUT_DRV2665_HAPTICS=m
CONFIG_INPUT_DRV2667_HAPTICS=y
# CONFIG_RMI4_CORE is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=m
CONFIG_SERIO_CT82C710=m
CONFIG_SERIO_PCIPS2=m
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
# CONFIG_SERIO_ALTERA_PS2 is not set
# CONFIG_SERIO_PS2MULT is not set
CONFIG_SERIO_ARC_PS2=y
CONFIG_USERIO=y
CONFIG_GAMEPORT=m
CONFIG_GAMEPORT_NS558=m
CONFIG_GAMEPORT_L4=m
# CONFIG_GAMEPORT_EMU10K1 is not set
CONFIG_GAMEPORT_FM801=m

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
CONFIG_CYCLADES=m
CONFIG_CYZ_INTR=y
CONFIG_MOXA_INTELLIO=y
# CONFIG_MOXA_SMARTIO is not set
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
CONFIG_SYNCLINK_GT=m
# CONFIG_NOZOMI is not set
CONFIG_ISI=m
# CONFIG_N_HDLC is not set
CONFIG_N_GSM=m
CONFIG_TRACE_ROUTER=m
CONFIG_TRACE_SINK=m
# CONFIG_DEVMEM is not set
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=m
CONFIG_SERIAL_8250_EXAR=m
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
# CONFIG_SERIAL_8250_MANY_PORTS is not set
CONFIG_SERIAL_8250_SHARE_IRQ=y
CONFIG_SERIAL_8250_DETECT_IRQ=y
# CONFIG_SERIAL_8250_RSA is not set
# CONFIG_SERIAL_8250_FSL is not set
CONFIG_SERIAL_8250_DW=m
# CONFIG_SERIAL_8250_RT288X is not set
# CONFIG_SERIAL_8250_LPSS is not set
# CONFIG_SERIAL_8250_MID is not set
# CONFIG_SERIAL_8250_MOXA is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SCCNXP=m
# CONFIG_SERIAL_SC16IS7XX is not set
CONFIG_SERIAL_ALTERA_JTAGUART=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE=y
CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE_BYPASS=y
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_ARC is not set
CONFIG_SERIAL_RP2=y
CONFIG_SERIAL_RP2_NR_UARTS=32
CONFIG_SERIAL_FSL_LPUART=y
# CONFIG_SERIAL_FSL_LPUART_CONSOLE is not set
# CONFIG_SERIAL_MEN_Z135 is not set
CONFIG_SERIAL_DEV_BUS=m
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=m
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=m
CONFIG_HW_RANDOM_INTEL=m
# CONFIG_HW_RANDOM_AMD is not set
# CONFIG_HW_RANDOM_VIA is not set
CONFIG_HW_RANDOM_VIRTIO=m
CONFIG_HW_RANDOM_TPM=y
CONFIG_NVRAM=m
# CONFIG_R3964 is not set
CONFIG_APPLICOM=m

#
# PCMCIA character devices
#
CONFIG_SYNCLINK_CS=m
CONFIG_CARDMAN_4000=m
CONFIG_CARDMAN_4040=m
# CONFIG_SCR24X is not set
CONFIG_IPWIRELESS=m
CONFIG_MWAVE=m
CONFIG_RAW_DRIVER=m
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_I2C_ATMEL=y
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_TIS_I2C_NUVOTON=m
CONFIG_TCG_NSC=m
CONFIG_TCG_ATMEL=m
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_CRB is not set
# CONFIG_TCG_VTPM_PROXY is not set
CONFIG_TCG_TIS_ST33ZP24=m
CONFIG_TCG_TIS_ST33ZP24_I2C=m
# CONFIG_TELCLOCK is not set
# CONFIG_DEVPORT is not set
CONFIG_XILLYBUS=m
CONFIG_XILLYBUS_PCIE=m

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
# CONFIG_I2C_CHARDEV is not set
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=y
# CONFIG_I2C_MUX_LTC4306 is not set
# CONFIG_I2C_MUX_PCA9541 is not set
CONFIG_I2C_MUX_PCA954x=y
# CONFIG_I2C_MUX_PINCTRL is not set
# CONFIG_I2C_MUX_REG is not set
CONFIG_I2C_MUX_MLXCPLD=y
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=m

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
CONFIG_I2C_ALI1563=m
CONFIG_I2C_ALI15X3=m
# CONFIG_I2C_AMD756 is not set
CONFIG_I2C_AMD8111=m
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
CONFIG_I2C_ISMT=y
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
CONFIG_I2C_SIS96X=y
# CONFIG_I2C_VIA is not set
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
CONFIG_I2C_DESIGNWARE_BAYTRAIL=y
# CONFIG_I2C_EMEV2 is not set
CONFIG_I2C_GPIO=m
CONFIG_I2C_OCORES=m
CONFIG_I2C_PCA_PLATFORM=m
# CONFIG_I2C_PXA_PCI is not set
# CONFIG_I2C_SIMTEC is not set
CONFIG_I2C_XILINX=m

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_TAOS_EVM is not set

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_MLXCPLD=y
# CONFIG_I2C_STUB is not set
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
CONFIG_SPMI=m
# CONFIG_HSI is not set
CONFIG_PPS=m
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=m
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_GPIO=m

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=m
# CONFIG_DP83640_PHY is not set
CONFIG_PTP_1588_CLOCK_KVM=m
CONFIG_PINCTRL=y

#
# Pin controllers
#
CONFIG_PINMUX=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
CONFIG_DEBUG_PINCTRL=y
CONFIG_PINCTRL_AMD=m
CONFIG_PINCTRL_MCP23S08=y
# CONFIG_PINCTRL_SX150X is not set
# CONFIG_PINCTRL_BAYTRAIL is not set
CONFIG_PINCTRL_CHERRYVIEW=m
CONFIG_PINCTRL_INTEL=y
CONFIG_PINCTRL_BROXTON=m
# CONFIG_PINCTRL_CANNONLAKE is not set
CONFIG_PINCTRL_GEMINILAKE=m
CONFIG_PINCTRL_SUNRISEPOINT=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
CONFIG_DEBUG_GPIO=y
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_AMDPT=m
CONFIG_GPIO_DWAPB=y
CONFIG_GPIO_EXAR=m
CONFIG_GPIO_GENERIC_PLATFORM=y
CONFIG_GPIO_ICH=m
CONFIG_GPIO_LYNXPOINT=y
CONFIG_GPIO_MENZ127=m
CONFIG_GPIO_MOCKUP=y
CONFIG_GPIO_VX855=y

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_IT87=y
CONFIG_GPIO_SCH=m
CONFIG_GPIO_SCH311X=m

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set
# CONFIG_GPIO_MAX7300 is not set
# CONFIG_GPIO_MAX732X is not set
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
CONFIG_GPIO_PCF857X=m
# CONFIG_GPIO_SX150X is not set
CONFIG_GPIO_TPIC2810=y

#
# MFD GPIO expanders
#
# CONFIG_GPIO_ADP5520 is not set
# CONFIG_GPIO_DA9052 is not set
CONFIG_GPIO_JANZ_TTL=m
# CONFIG_GPIO_PALMAS is not set
CONFIG_GPIO_TPS65910=y
CONFIG_GPIO_TPS65912=m
CONFIG_GPIO_TWL4030=y
CONFIG_GPIO_TWL6040=y
CONFIG_GPIO_WM831X=y
# CONFIG_GPIO_WM8350 is not set
CONFIG_GPIO_WM8994=m

#
# PCI GPIO expanders
#
CONFIG_GPIO_AMD8111=m
CONFIG_GPIO_BT8XX=y
CONFIG_GPIO_ML_IOH=y
# CONFIG_GPIO_PCI_IDIO_16 is not set
CONFIG_GPIO_RDC321X=y
CONFIG_W1=m
# CONFIG_W1_CON is not set

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=m
CONFIG_W1_MASTER_DS2482=m
CONFIG_W1_MASTER_DS1WM=m
CONFIG_W1_MASTER_GPIO=m

#
# 1-wire Slaves
#
# CONFIG_W1_SLAVE_THERM is not set
CONFIG_W1_SLAVE_SMEM=m
# CONFIG_W1_SLAVE_DS2405 is not set
CONFIG_W1_SLAVE_DS2408=m
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
CONFIG_W1_SLAVE_DS2413=m
# CONFIG_W1_SLAVE_DS2406 is not set
CONFIG_W1_SLAVE_DS2423=m
CONFIG_W1_SLAVE_DS2431=m
CONFIG_W1_SLAVE_DS2433=m
CONFIG_W1_SLAVE_DS2433_CRC=y
CONFIG_W1_SLAVE_DS2438=m
# CONFIG_W1_SLAVE_DS2760 is not set
CONFIG_W1_SLAVE_DS2780=m
CONFIG_W1_SLAVE_DS2781=m
CONFIG_W1_SLAVE_DS28E04=m
# CONFIG_W1_SLAVE_BQ27000 is not set
# CONFIG_POWER_AVS is not set
# CONFIG_POWER_RESET is not set
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
CONFIG_PDA_POWER=y
CONFIG_WM831X_BACKUP=y
CONFIG_WM831X_POWER=m
CONFIG_WM8350_POWER=m
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_88PM860X is not set
# CONFIG_BATTERY_DS2780 is not set
CONFIG_BATTERY_DS2781=m
CONFIG_BATTERY_DS2782=m
# CONFIG_BATTERY_SBS is not set
CONFIG_CHARGER_SBS=m
CONFIG_BATTERY_BQ27XXX=y
CONFIG_BATTERY_BQ27XXX_I2C=m
CONFIG_BATTERY_BQ27XXX_DT_UPDATES_NVM=y
# CONFIG_BATTERY_DA9052 is not set
# CONFIG_BATTERY_DA9150 is not set
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=m
CONFIG_CHARGER_PCF50633=m
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_LP8727=m
CONFIG_CHARGER_GPIO=y
CONFIG_CHARGER_MANAGER=y
# CONFIG_CHARGER_LTC3651 is not set
CONFIG_CHARGER_MAX77693=m
CONFIG_CHARGER_MAX8997=m
CONFIG_CHARGER_MAX8998=y
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_BQ24190=y
# CONFIG_CHARGER_BQ24257 is not set
# CONFIG_CHARGER_BQ24735 is not set
CONFIG_CHARGER_BQ25890=m
CONFIG_CHARGER_SMB347=y
CONFIG_BATTERY_GAUGE_LTC2941=m
CONFIG_BATTERY_RT5033=m
# CONFIG_CHARGER_RT9455 is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=y
# CONFIG_SENSORS_ABITUGURU3 is not set
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
CONFIG_SENSORS_ADM1029=m
CONFIG_SENSORS_ADM1031=m
CONFIG_SENSORS_ADM9240=y
# CONFIG_SENSORS_ADT7410 is not set
CONFIG_SENSORS_ADT7411=m
CONFIG_SENSORS_ADT7462=m
# CONFIG_SENSORS_ADT7470 is not set
CONFIG_SENSORS_ADT7475=m
CONFIG_SENSORS_ASC7621=m
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_K10TEMP=y
CONFIG_SENSORS_FAM15H_POWER=y
CONFIG_SENSORS_APPLESMC=y
CONFIG_SENSORS_ASB100=m
CONFIG_SENSORS_ASPEED=m
# CONFIG_SENSORS_ATXP1 is not set
CONFIG_SENSORS_DS620=m
CONFIG_SENSORS_DS1621=m
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_DA9052_ADC=y
CONFIG_SENSORS_I5K_AMB=m
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHMD is not set
CONFIG_SENSORS_GL518SM=m
CONFIG_SENSORS_GL520SM=y
# CONFIG_SENSORS_G760A is not set
CONFIG_SENSORS_G762=m
# CONFIG_SENSORS_GPIO_FAN is not set
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_I5500=m
# CONFIG_SENSORS_CORETEMP is not set
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_POWR1220=m
CONFIG_SENSORS_LINEAGE=m
CONFIG_SENSORS_LTC2945=y
# CONFIG_SENSORS_LTC2990 is not set
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=m
# CONFIG_SENSORS_LTC4222 is not set
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4260=y
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=m
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=y
# CONFIG_SENSORS_MAX6639 is not set
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=m
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_MAX31790 is not set
CONFIG_SENSORS_MCP3021=m
CONFIG_SENSORS_TC654=m
CONFIG_SENSORS_LM63=m
CONFIG_SENSORS_LM73=y
# CONFIG_SENSORS_LM75 is not set
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
# CONFIG_SENSORS_LM80 is not set
CONFIG_SENSORS_LM83=m
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
# CONFIG_SENSORS_LM90 is not set
CONFIG_SENSORS_LM92=m
# CONFIG_SENSORS_LM93 is not set
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=m
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_PC87360=m
# CONFIG_SENSORS_PC87427 is not set
CONFIG_SENSORS_NTC_THERMISTOR=m
CONFIG_SENSORS_NCT6683=m
CONFIG_SENSORS_NCT6775=y
CONFIG_SENSORS_NCT7802=m
# CONFIG_SENSORS_NCT7904 is not set
CONFIG_SENSORS_PCF8591=m
CONFIG_PMBUS=m
CONFIG_SENSORS_PMBUS=m
CONFIG_SENSORS_ADM1275=m
# CONFIG_SENSORS_IR35221 is not set
# CONFIG_SENSORS_LM25066 is not set
CONFIG_SENSORS_LTC2978=m
CONFIG_SENSORS_LTC2978_REGULATOR=y
# CONFIG_SENSORS_LTC3815 is not set
# CONFIG_SENSORS_MAX16064 is not set
CONFIG_SENSORS_MAX20751=m
# CONFIG_SENSORS_MAX34440 is not set
# CONFIG_SENSORS_MAX8688 is not set
CONFIG_SENSORS_TPS40422=m
# CONFIG_SENSORS_UCD9000 is not set
# CONFIG_SENSORS_UCD9200 is not set
CONFIG_SENSORS_ZL6100=m
CONFIG_SENSORS_SHT15=m
CONFIG_SENSORS_SHT21=y
# CONFIG_SENSORS_SHT3x is not set
# CONFIG_SENSORS_SHTC1 is not set
CONFIG_SENSORS_SIS5595=m
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=m
CONFIG_SENSORS_EMC2103=m
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=m
# CONFIG_SENSORS_SMSC47M192 is not set
CONFIG_SENSORS_SMSC47B397=m
# CONFIG_SENSORS_SCH56XX_COMMON is not set
CONFIG_SENSORS_STTS751=y
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_ADC128D818=y
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=m
CONFIG_SENSORS_AMC6821=y
# CONFIG_SENSORS_INA209 is not set
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_INA3221=y
CONFIG_SENSORS_TC74=m
CONFIG_SENSORS_THMC50=m
CONFIG_SENSORS_TMP102=y
# CONFIG_SENSORS_TMP103 is not set
CONFIG_SENSORS_TMP108=m
CONFIG_SENSORS_TMP401=m
CONFIG_SENSORS_TMP421=m
CONFIG_SENSORS_VIA_CPUTEMP=m
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=m
CONFIG_SENSORS_VT8231=m
CONFIG_SENSORS_W83781D=m
CONFIG_SENSORS_W83791D=y
# CONFIG_SENSORS_W83792D is not set
CONFIG_SENSORS_W83793=y
# CONFIG_SENSORS_W83795 is not set
# CONFIG_SENSORS_W83L785TS is not set
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=m
CONFIG_SENSORS_W83627EHF=m
CONFIG_SENSORS_WM831X=m
CONFIG_SENSORS_WM8350=y

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=m
CONFIG_SENSORS_ATK0110=m
CONFIG_THERMAL=y
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_WRITABLE_TRIPS=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_BANG_BANG is not set
# CONFIG_THERMAL_GOV_USER_SPACE is not set
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=y
# CONFIG_THERMAL_EMULATION is not set
CONFIG_INTEL_POWERCLAMP=y
CONFIG_INTEL_SOC_DTS_IOSF_CORE=y
CONFIG_INTEL_SOC_DTS_THERMAL=y

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
CONFIG_INTEL_PCH_THERMAL=y
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
# CONFIG_SSB_PCIHOST is not set
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_GPIO=y
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_AS3711=y
CONFIG_PMIC_ADP5520=y
# CONFIG_MFD_AAT2870_CORE is not set
# CONFIG_MFD_BCM590XX is not set
# CONFIG_MFD_AXP20X_I2C is not set
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
# CONFIG_MFD_DA9055 is not set
CONFIG_MFD_DA9062=m
CONFIG_MFD_DA9063=m
CONFIG_MFD_DA9150=m
# CONFIG_MFD_MC13XXX_I2C is not set
CONFIG_HTC_PASIC3=m
# CONFIG_HTC_I2CPLD is not set
# CONFIG_MFD_INTEL_QUARK_I2C_GPIO is not set
CONFIG_LPC_ICH=m
CONFIG_LPC_SCH=y
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_INTEL_SOC_PMIC_BXTWC is not set
CONFIG_INTEL_SOC_PMIC_CHTWC=y
CONFIG_MFD_INTEL_LPSS=y
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
CONFIG_MFD_INTEL_LPSS_PCI=y
CONFIG_MFD_JANZ_CMODIO=y
# CONFIG_MFD_KEMPLD is not set
CONFIG_MFD_88PM800=m
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
# CONFIG_MFD_MAX14577 is not set
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX77843=y
CONFIG_MFD_MAX8907=y
# CONFIG_MFD_MAX8925 is not set
CONFIG_MFD_MAX8997=y
CONFIG_MFD_MAX8998=y
CONFIG_MFD_MT6397=m
# CONFIG_MFD_MENF21BMC is not set
# CONFIG_MFD_RETU is not set
CONFIG_MFD_PCF50633=m
CONFIG_PCF50633_ADC=m
CONFIG_PCF50633_GPIO=m
CONFIG_MFD_RDC321X=y
# CONFIG_MFD_RTSX_PCI is not set
CONFIG_MFD_RT5033=m
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
CONFIG_MFD_SM501=m
# CONFIG_MFD_SM501_GPIO is not set
CONFIG_MFD_SKY81452=y
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=m
# CONFIG_MFD_LP3943 is not set
# CONFIG_MFD_LP8788 is not set
CONFIG_MFD_TI_LMU=m
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=m
# CONFIG_MFD_TPS65086 is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TI_LP873X is not set
# CONFIG_MFD_TPS65218 is not set
# CONFIG_MFD_TPS6586X is not set
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=m
CONFIG_MFD_TPS65912_I2C=m
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
CONFIG_MFD_TWL4030_AUDIO=y
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=y
# CONFIG_MFD_ARIZONA_I2C is not set
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=m
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
# CONFIG_REGULATOR_88PM800 is not set
CONFIG_REGULATOR_88PM8607=m
CONFIG_REGULATOR_ACT8865=m
CONFIG_REGULATOR_AD5398=y
# CONFIG_REGULATOR_ANATOP is not set
# CONFIG_REGULATOR_AS3711 is not set
CONFIG_REGULATOR_DA9052=y
# CONFIG_REGULATOR_DA9062 is not set
CONFIG_REGULATOR_DA9063=m
# CONFIG_REGULATOR_DA9210 is not set
CONFIG_REGULATOR_DA9211=m
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_GPIO=m
CONFIG_REGULATOR_ISL9305=y
# CONFIG_REGULATOR_ISL6271A is not set
# CONFIG_REGULATOR_LM363X is not set
# CONFIG_REGULATOR_LP3971 is not set
CONFIG_REGULATOR_LP3972=m
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP8755 is not set
# CONFIG_REGULATOR_LTC3589 is not set
# CONFIG_REGULATOR_LTC3676 is not set
CONFIG_REGULATOR_MAX1586=y
# CONFIG_REGULATOR_MAX8649 is not set
CONFIG_REGULATOR_MAX8660=m
CONFIG_REGULATOR_MAX8907=m
CONFIG_REGULATOR_MAX8952=m
CONFIG_REGULATOR_MAX8997=m
CONFIG_REGULATOR_MAX8998=y
# CONFIG_REGULATOR_MAX77693 is not set
CONFIG_REGULATOR_MT6311=m
# CONFIG_REGULATOR_MT6323 is not set
CONFIG_REGULATOR_MT6397=m
CONFIG_REGULATOR_PALMAS=m
# CONFIG_REGULATOR_PCF50633 is not set
# CONFIG_REGULATOR_PFUZE100 is not set
CONFIG_REGULATOR_PV88060=m
# CONFIG_REGULATOR_PV88080 is not set
CONFIG_REGULATOR_PV88090=m
# CONFIG_REGULATOR_QCOM_SPMI is not set
CONFIG_REGULATOR_RT5033=m
CONFIG_REGULATOR_SKY81452=y
CONFIG_REGULATOR_TPS51632=m
CONFIG_REGULATOR_TPS6105X=y
CONFIG_REGULATOR_TPS62360=m
CONFIG_REGULATOR_TPS65023=m
CONFIG_REGULATOR_TPS6507X=y
# CONFIG_REGULATOR_TPS65132 is not set
CONFIG_REGULATOR_TPS65910=m
# CONFIG_REGULATOR_TPS65912 is not set
CONFIG_REGULATOR_TWL4030=m
CONFIG_REGULATOR_WM831X=m
CONFIG_REGULATOR_WM8350=y
CONFIG_REGULATOR_WM8400=m
# CONFIG_REGULATOR_WM8994 is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_SDR_SUPPORT is not set
# CONFIG_MEDIA_RC_SUPPORT is not set
# CONFIG_MEDIA_CEC_SUPPORT is not set
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
CONFIG_VIDEO_PCI_SKELETON=m
CONFIG_V4L2_MEM2MEM_DEV=y
CONFIG_VIDEOBUF_GEN=m
CONFIG_VIDEOBUF_DMA_SG=m
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_DMA_CONTIG=m
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_VIDEOBUF2_DMA_SG=y
# CONFIG_TTPCI_EEPROM is not set

#
# Media drivers
#
CONFIG_MEDIA_PCI_SUPPORT=y

#
# Media capture support
#
# CONFIG_VIDEO_MEYE is not set
# CONFIG_VIDEO_TW5864 is not set
CONFIG_VIDEO_TW68=y
# CONFIG_VIDEO_ZORAN is not set
CONFIG_V4L_PLATFORM_DRIVERS=y
CONFIG_VIDEO_CAFE_CCIC=m
CONFIG_VIDEO_VIA_CAMERA=m
# CONFIG_SOC_CAMERA is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
CONFIG_V4L_TEST_DRIVERS=y
CONFIG_VIDEO_VIVID=m
# CONFIG_VIDEO_VIVID_CEC is not set
CONFIG_VIDEO_VIVID_MAX_DEVS=64
CONFIG_VIDEO_VIM2M=y

#
# Supported MMC/SDIO adapters
#
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_TEA575X=m
# CONFIG_RADIO_SI470X is not set
CONFIG_RADIO_SI4713=y
# CONFIG_PLATFORM_SI4713 is not set
CONFIG_I2C_SI4713=m
CONFIG_RADIO_MAXIRADIO=m
CONFIG_RADIO_TEA5764=m
CONFIG_RADIO_SAA7706H=m
CONFIG_RADIO_TEF6862=y
CONFIG_RADIO_WL1273=y

#
# Texas Instruments WL128x FM driver (ST based)
#
CONFIG_RADIO_WL128X=m
CONFIG_VIDEO_V4L2_TPG=m

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_MEDIA_ATTACH=y

#
# Audio decoders, processors and mixers
#

#
# RDS decoders
#

#
# Video decoders
#

#
# Video and audio decoders
#

#
# Video encoders
#

#
# Camera sensor devices
#
CONFIG_VIDEO_OV7670=m

#
# Flash devices
#

#
# Video improvement chips
#

#
# Audio/Video compression chips
#

#
# SDR tuner chips
#

#
# Miscellaneous helper chips
#

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MC44S803=y

#
# Tools to develop new frontends
#

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_INTEL_GTT=m
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
CONFIG_VGA_SWITCHEROO=y
CONFIG_DRM=m
CONFIG_DRM_MIPI_DSI=y
# CONFIG_DRM_DP_AUX_CHARDEV is not set
# CONFIG_DRM_DEBUG_MM_SELFTEST is not set
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_KMS_FB_HELPER=y
# CONFIG_DRM_FBDEV_EMULATION is not set
CONFIG_DRM_LOAD_EDID_FIRMWARE=y
CONFIG_DRM_TTM=m
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_KMS_CMA_HELPER=y
CONFIG_DRM_VM=y

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
# CONFIG_DRM_I2C_SIL164 is not set
CONFIG_DRM_I2C_NXP_TDA998X=m
CONFIG_DRM_RADEON=m
CONFIG_DRM_RADEON_USERPTR=y
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#
CONFIG_DRM_NOUVEAU=m
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
# CONFIG_DRM_NOUVEAU_BACKLIGHT is not set
CONFIG_DRM_I915=m
CONFIG_DRM_I915_ALPHA_SUPPORT=y
CONFIG_DRM_I915_CAPTURE_ERROR=y
# CONFIG_DRM_I915_COMPRESS_ERROR is not set
CONFIG_DRM_I915_USERPTR=y
CONFIG_DRM_I915_GVT=y
# CONFIG_DRM_VGEM is not set
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
CONFIG_DRM_AST=m
CONFIG_DRM_MGAG200=m
CONFIG_DRM_CIRRUS_QEMU=m
CONFIG_DRM_QXL=m
CONFIG_DRM_BOCHS=m
CONFIG_DRM_VIRTIO_GPU=m
CONFIG_DRM_PANEL=y

#
# Display Panels
#
CONFIG_DRM_BRIDGE=y
CONFIG_DRM_PANEL_BRIDGE=y

#
# Display Interface Bridges
#
# CONFIG_DRM_ANALOGIX_ANX78XX is not set
# CONFIG_HSA_AMD is not set
CONFIG_DRM_HISI_HIBMC=m
CONFIG_DRM_TINYDRM=m
# CONFIG_DRM_LEGACY is not set
# CONFIG_DRM_LIB_RANDOM is not set

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB_DDC=y
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_PROVIDE_GET_FB_UNMAPPED_AREA is not set
CONFIG_FB_FOREIGN_ENDIAN=y
CONFIG_FB_BOTH_ENDIAN=y
# CONFIG_FB_BIG_ENDIAN is not set
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_SVGALIB=y
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
CONFIG_FB_PM2=y
CONFIG_FB_PM2_FIFO_DISCONNECT=y
CONFIG_FB_CYBER2000=y
# CONFIG_FB_CYBER2000_DDC is not set
CONFIG_FB_ARC=y
CONFIG_FB_ASILIANT=y
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
# CONFIG_FB_VESA is not set
# CONFIG_FB_N411 is not set
CONFIG_FB_HGA=m
CONFIG_FB_OPENCORES=m
CONFIG_FB_S1D13XXX=m
CONFIG_FB_NVIDIA=y
# CONFIG_FB_NVIDIA_I2C is not set
# CONFIG_FB_NVIDIA_DEBUG is not set
CONFIG_FB_NVIDIA_BACKLIGHT=y
CONFIG_FB_RIVA=y
CONFIG_FB_RIVA_I2C=y
# CONFIG_FB_RIVA_DEBUG is not set
CONFIG_FB_RIVA_BACKLIGHT=y
CONFIG_FB_I740=m
CONFIG_FB_LE80578=m
# CONFIG_FB_CARILLO_RANCH is not set
CONFIG_FB_MATROX=m
# CONFIG_FB_MATROX_MILLENIUM is not set
CONFIG_FB_MATROX_MYSTIQUE=y
# CONFIG_FB_MATROX_G is not set
CONFIG_FB_MATROX_I2C=m
CONFIG_FB_RADEON=m
# CONFIG_FB_RADEON_I2C is not set
# CONFIG_FB_RADEON_BACKLIGHT is not set
CONFIG_FB_RADEON_DEBUG=y
CONFIG_FB_ATY128=m
CONFIG_FB_ATY128_BACKLIGHT=y
CONFIG_FB_ATY=y
CONFIG_FB_ATY_CT=y
# CONFIG_FB_ATY_GENERIC_LCD is not set
CONFIG_FB_ATY_GX=y
CONFIG_FB_ATY_BACKLIGHT=y
# CONFIG_FB_S3 is not set
CONFIG_FB_SAVAGE=y
CONFIG_FB_SAVAGE_I2C=y
CONFIG_FB_SAVAGE_ACCEL=y
# CONFIG_FB_SIS is not set
CONFIG_FB_VIA=m
# CONFIG_FB_VIA_DIRECT_PROCFS is not set
# CONFIG_FB_VIA_X_COMPATIBILITY is not set
# CONFIG_FB_NEOMAGIC is not set
CONFIG_FB_KYRO=y
# CONFIG_FB_3DFX is not set
CONFIG_FB_VOODOO1=m
CONFIG_FB_VT8623=y
CONFIG_FB_TRIDENT=y
# CONFIG_FB_ARK is not set
CONFIG_FB_PM3=m
CONFIG_FB_CARMINE=m
CONFIG_FB_CARMINE_DRAM_EVAL=y
# CONFIG_CARMINE_DRAM_CUSTOM is not set
# CONFIG_FB_SM501 is not set
# CONFIG_FB_IBM_GXT4500 is not set
CONFIG_FB_VIRTUAL=y
CONFIG_FB_METRONOME=m
CONFIG_FB_MB862XX=m
CONFIG_FB_MB862XX_PCI_GDC=y
CONFIG_FB_MB862XX_I2C=y
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_AUO_K190X is not set
CONFIG_FB_SIMPLE=y
CONFIG_FB_SM712=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_PLATFORM=m
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_BACKLIGHT_LM3533=m
CONFIG_BACKLIGHT_CARILLO_RANCH=m
CONFIG_BACKLIGHT_DA9052=y
CONFIG_BACKLIGHT_APPLE=y
CONFIG_BACKLIGHT_PM8941_WLED=y
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=y
CONFIG_BACKLIGHT_ADP5520=y
CONFIG_BACKLIGHT_ADP8860=m
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_88PM860X is not set
# CONFIG_BACKLIGHT_PCF50633 is not set
# CONFIG_BACKLIGHT_LM3639 is not set
# CONFIG_BACKLIGHT_PANDORA is not set
CONFIG_BACKLIGHT_SKY81452=m
CONFIG_BACKLIGHT_AS3711=m
CONFIG_BACKLIGHT_GPIO=m
CONFIG_BACKLIGHT_LV5207LP=y
CONFIG_BACKLIGHT_BD6107=y
# CONFIG_BACKLIGHT_ARCXCNN is not set
CONFIG_VGASTATE=y
CONFIG_HDMI=y

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_DUMMY_CONSOLE_COLUMNS=80
CONFIG_DUMMY_CONSOLE_ROWS=25
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
# CONFIG_LOGO_LINUX_VGA16 is not set
CONFIG_LOGO_LINUX_CLUT224=y
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
CONFIG_HIDRAW=y
CONFIG_UHID=y
CONFIG_HID_GENERIC=m

#
# Special HID drivers
#
CONFIG_HID_A4TECH=m
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
CONFIG_HID_ASUS=m
CONFIG_HID_AUREAL=m
CONFIG_HID_BELKIN=m
CONFIG_HID_CHERRY=m
# CONFIG_HID_CHICONY is not set
CONFIG_HID_CMEDIA=y
CONFIG_HID_CYPRESS=y
# CONFIG_HID_DRAGONRISE is not set
CONFIG_HID_EMS_FF=y
# CONFIG_HID_ELECOM is not set
CONFIG_HID_EZKEY=y
CONFIG_HID_GEMBIRD=m
# CONFIG_HID_GFRM is not set
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=m
# CONFIG_HID_ICADE is not set
# CONFIG_HID_ITE is not set
# CONFIG_HID_TWINHAN is not set
# CONFIG_HID_KENSINGTON is not set
CONFIG_HID_LCPOWER=y
CONFIG_HID_LED=y
CONFIG_HID_LENOVO=m
CONFIG_HID_LOGITECH=y
# CONFIG_HID_LOGITECH_DJ is not set
CONFIG_HID_LOGITECH_HIDPP=m
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
CONFIG_LOGIWHEELS_FF=y
# CONFIG_HID_MAGICMOUSE is not set
CONFIG_HID_MAYFLASH=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
# CONFIG_HID_MULTITOUCH is not set
CONFIG_HID_NTI=m
CONFIG_HID_ORTEK=m
CONFIG_HID_PANTHERLORD=m
# CONFIG_PANTHERLORD_FF is not set
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=m
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LCD=y
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=y
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=m
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEELSERIES=y
CONFIG_HID_SUNPLUS=m
# CONFIG_HID_RMI is not set
CONFIG_HID_GREENASIA=m
CONFIG_GREENASIA_FF=y
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=m
CONFIG_HID_THINGM=m
CONFIG_HID_THRUSTMASTER=m
CONFIG_THRUSTMASTER_FF=y
CONFIG_HID_UDRAW_PS3=y
# CONFIG_HID_WACOM is not set
# CONFIG_HID_WIIMOTE is not set
CONFIG_HID_XINMO=m
CONFIG_HID_ZEROPLUS=y
CONFIG_ZEROPLUS_FF=y
CONFIG_HID_ZYDACRON=m
# CONFIG_HID_SENSOR_HUB is not set
CONFIG_HID_ALPS=m

#
# I2C HID support
#
CONFIG_I2C_HID=y

#
# Intel ISH HID support
#
CONFIG_INTEL_ISH_HID=m
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set
CONFIG_USB_PCI=y

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_USB_PHY is not set
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_USB_GADGET is not set

#
# USB Power Delivery and Type-C drivers
#
# CONFIG_TYPEC_UCSI is not set
# CONFIG_USB_LED_TRIG is not set
# CONFIG_USB_ULPI_BUS is not set
CONFIG_UWB=y
# CONFIG_UWB_WHCI is not set
CONFIG_MMC=m
CONFIG_MMC_DEBUG=y
CONFIG_MMC_BLOCK=m
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_SDIO_UART=m
CONFIG_MMC_TEST=m

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=m
# CONFIG_MMC_SDHCI_PCI is not set
CONFIG_MMC_SDHCI_ACPI=m
# CONFIG_MMC_SDHCI_PLTFM is not set
CONFIG_MMC_WBSD=m
CONFIG_MMC_TIFM_SD=m
# CONFIG_MMC_SDRICOH_CS is not set
CONFIG_MMC_CB710=m
CONFIG_MMC_VIA_SDMMC=m
CONFIG_MMC_USDHI6ROL0=m
# CONFIG_MMC_TOSHIBA_PCI is not set
CONFIG_MMC_MTK=m
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y
CONFIG_MSPRO_BLOCK=m
CONFIG_MS_BLOCK=m

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=m
CONFIG_MEMSTICK_JMICRON_38X=y
CONFIG_MEMSTICK_R592=m
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3533=m
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_MT6323=m
CONFIG_LEDS_PCA9532=m
CONFIG_LEDS_PCA9532_GPIO=y
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=m
CONFIG_LEDS_LP3952=m
CONFIG_LEDS_LP55XX_COMMON=y
CONFIG_LEDS_LP5521=y
# CONFIG_LEDS_LP5523 is not set
CONFIG_LEDS_LP5562=y
# CONFIG_LEDS_LP8501 is not set
# CONFIG_LEDS_LP8860 is not set
CONFIG_LEDS_CLEVO_MAIL=m
# CONFIG_LEDS_PCA955X is not set
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_WM831X_STATUS=m
CONFIG_LEDS_WM8350=m
# CONFIG_LEDS_DA9052 is not set
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_INTEL_SS4200 is not set
CONFIG_LEDS_LT3593=y
# CONFIG_LEDS_ADP5520 is not set
CONFIG_LEDS_TCA6507=m
# CONFIG_LEDS_TLC591XX is not set
CONFIG_LEDS_MAX8997=y
CONFIG_LEDS_LM355x=m

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=y
CONFIG_LEDS_MLXCPLD=m
CONFIG_LEDS_USER=m
CONFIG_LEDS_NIC78BX=m

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
# CONFIG_LEDS_TRIGGER_TIMER is not set
CONFIG_LEDS_TRIGGER_ONESHOT=m
CONFIG_LEDS_TRIGGER_DISK=y
# CONFIG_LEDS_TRIGGER_MTD is not set
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
CONFIG_LEDS_TRIGGER_BACKLIGHT=m
# CONFIG_LEDS_TRIGGER_CPU is not set
CONFIG_LEDS_TRIGGER_GPIO=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=m
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_LEDS_TRIGGER_PANIC is not set
CONFIG_ACCESSIBILITY=y
CONFIG_A11Y_BRAILLE_CONSOLE=y
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=m
CONFIG_DMA_ACPI=y
CONFIG_INTEL_IDMA64=m
CONFIG_INTEL_IOATDMA=m
CONFIG_INTEL_MIC_X100_DMA=m
CONFIG_QCOM_HIDMA_MGMT=m
# CONFIG_QCOM_HIDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
# CONFIG_DW_DMAC_PCI is not set

#
# DMA Clients
#
# CONFIG_ASYNC_TX_DMA is not set
CONFIG_DMATEST=m
CONFIG_DMA_ENGINE_RAID=y

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
# CONFIG_SW_SYNC is not set
CONFIG_DCA=m
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=m
CONFIG_UIO_CIF=m
# CONFIG_UIO_PDRV_GENIRQ is not set
CONFIG_UIO_DMEM_GENIRQ=m
CONFIG_UIO_AEC=m
CONFIG_UIO_SERCOS3=m
CONFIG_UIO_PCI_GENERIC=m
# CONFIG_UIO_NETX is not set
CONFIG_UIO_PRUSS=m
CONFIG_UIO_MF624=m
CONFIG_VFIO_IOMMU_TYPE1=m
# CONFIG_VFIO_VIRQFD is not set
CONFIG_VFIO=m
# CONFIG_VFIO_NOIOMMU is not set
# CONFIG_VFIO_PCI is not set
# CONFIG_VFIO_MDEV is not set
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=m

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_BALLOON is not set
# CONFIG_VIRTIO_INPUT is not set
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_HYPERV_TSCPAGE is not set
CONFIG_STAGING=y
CONFIG_COMEDI=m
CONFIG_COMEDI_DEBUG=y
CONFIG_COMEDI_DEFAULT_BUF_SIZE_KB=2048
CONFIG_COMEDI_DEFAULT_BUF_MAXSIZE_KB=20480
CONFIG_COMEDI_MISC_DRIVERS=y
CONFIG_COMEDI_BOND=m
# CONFIG_COMEDI_TEST is not set
CONFIG_COMEDI_PARPORT=m
# CONFIG_COMEDI_SERIAL2002 is not set
CONFIG_COMEDI_ISA_DRIVERS=y
CONFIG_COMEDI_PCL711=m
CONFIG_COMEDI_PCL724=m
# CONFIG_COMEDI_PCL726 is not set
CONFIG_COMEDI_PCL730=m
CONFIG_COMEDI_PCL812=m
# CONFIG_COMEDI_PCL816 is not set
# CONFIG_COMEDI_PCL818 is not set
CONFIG_COMEDI_PCM3724=m
CONFIG_COMEDI_AMPLC_DIO200_ISA=m
CONFIG_COMEDI_AMPLC_PC236_ISA=m
# CONFIG_COMEDI_AMPLC_PC263_ISA is not set
CONFIG_COMEDI_RTI800=m
CONFIG_COMEDI_RTI802=m
CONFIG_COMEDI_DAC02=m
CONFIG_COMEDI_DAS16M1=m
CONFIG_COMEDI_DAS08_ISA=m
CONFIG_COMEDI_DAS16=m
# CONFIG_COMEDI_DAS800 is not set
CONFIG_COMEDI_DAS1800=m
CONFIG_COMEDI_DAS6402=m
CONFIG_COMEDI_DT2801=m
CONFIG_COMEDI_DT2811=m
# CONFIG_COMEDI_DT2814 is not set
CONFIG_COMEDI_DT2815=m
CONFIG_COMEDI_DT2817=m
# CONFIG_COMEDI_DT282X is not set
CONFIG_COMEDI_DMM32AT=m
# CONFIG_COMEDI_FL512 is not set
CONFIG_COMEDI_AIO_AIO12_8=m
CONFIG_COMEDI_AIO_IIRO_16=m
# CONFIG_COMEDI_II_PCI20KC is not set
# CONFIG_COMEDI_C6XDIGIO is not set
# CONFIG_COMEDI_MPC624 is not set
CONFIG_COMEDI_ADQ12B=m
# CONFIG_COMEDI_NI_AT_A2150 is not set
# CONFIG_COMEDI_NI_AT_AO is not set
# CONFIG_COMEDI_NI_ATMIO is not set
CONFIG_COMEDI_NI_ATMIO16D=m
CONFIG_COMEDI_NI_LABPC_ISA=m
CONFIG_COMEDI_PCMAD=m
CONFIG_COMEDI_PCMDA12=m
CONFIG_COMEDI_PCMMIO=m
CONFIG_COMEDI_PCMUIO=m
CONFIG_COMEDI_MULTIQ3=m
# CONFIG_COMEDI_S526 is not set
# CONFIG_COMEDI_PCI_DRIVERS is not set
CONFIG_COMEDI_PCMCIA_DRIVERS=m
CONFIG_COMEDI_CB_DAS16_CS=m
# CONFIG_COMEDI_DAS08_CS is not set
CONFIG_COMEDI_NI_DAQ_700_CS=m
CONFIG_COMEDI_NI_DAQ_DIO24_CS=m
# CONFIG_COMEDI_NI_LABPC_CS is not set
# CONFIG_COMEDI_NI_MIO_CS is not set
# CONFIG_COMEDI_QUATECH_DAQP_CS is not set
CONFIG_COMEDI_8254=m
CONFIG_COMEDI_8255=m
CONFIG_COMEDI_8255_SA=m
CONFIG_COMEDI_KCOMEDILIB=m
CONFIG_COMEDI_AMPLC_DIO200=m
CONFIG_COMEDI_AMPLC_PC236=m
CONFIG_COMEDI_DAS08=m
CONFIG_COMEDI_ISADMA=m
CONFIG_COMEDI_NI_LABPC=m
CONFIG_COMEDI_NI_LABPC_ISADMA=m
# CONFIG_RTLLIB is not set
CONFIG_RTL8723BS=m
# CONFIG_RTS5208 is not set
# CONFIG_VT6655 is not set
CONFIG_FB_SM750=m
CONFIG_FB_XGI=m

#
# Speakup console speech
#
CONFIG_SPEAKUP=y
# CONFIG_SPEAKUP_SYNTH_ACNTSA is not set
# CONFIG_SPEAKUP_SYNTH_APOLLO is not set
# CONFIG_SPEAKUP_SYNTH_AUDPTR is not set
CONFIG_SPEAKUP_SYNTH_BNS=m
CONFIG_SPEAKUP_SYNTH_DECTLK=m
# CONFIG_SPEAKUP_SYNTH_DECEXT is not set
CONFIG_SPEAKUP_SYNTH_LTLK=y
CONFIG_SPEAKUP_SYNTH_SOFT=m
CONFIG_SPEAKUP_SYNTH_SPKOUT=m
CONFIG_SPEAKUP_SYNTH_TXPRT=y
# CONFIG_SPEAKUP_SYNTH_DUMMY is not set
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
CONFIG_ASHMEM=y
# CONFIG_ION is not set
# CONFIG_LNET is not set
# CONFIG_DGNC is not set
CONFIG_GS_FPGABOOT=y
# CONFIG_CRYPTO_SKEIN is not set
# CONFIG_UNISYSSPAR is not set
CONFIG_WILC1000=m
CONFIG_WILC1000_SDIO=m
# CONFIG_WILC1000_HW_OOB_INTR is not set
CONFIG_MOST=m
CONFIG_MOSTCORE=m
# CONFIG_AIM_CDEV is not set
# CONFIG_AIM_NETWORK is not set
# CONFIG_AIM_V4L2 is not set
# CONFIG_HDM_DIM2 is not set
# CONFIG_HDM_I2C is not set
# CONFIG_KS7010 is not set
CONFIG_GREYBUS=m
CONFIG_GREYBUS_BOOTROM=m
# CONFIG_GREYBUS_HID is not set
CONFIG_GREYBUS_LIGHT=m
# CONFIG_GREYBUS_LOG is not set
# CONFIG_GREYBUS_LOOPBACK is not set
# CONFIG_GREYBUS_POWER is not set
CONFIG_GREYBUS_RAW=m
CONFIG_GREYBUS_VIBRATOR=m
# CONFIG_GREYBUS_BRIDGED_PHY is not set

#
# USB Power Delivery and Type-C drivers
#
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=m
# CONFIG_ACERHDF is not set
# CONFIG_ALIENWARE_WMI is not set
CONFIG_ASUS_LAPTOP=m
# CONFIG_DELL_LAPTOP is not set
# CONFIG_DELL_WMI is not set
CONFIG_DELL_WMI_AIO=m
# CONFIG_DELL_WMI_LED is not set
CONFIG_DELL_SMO8800=y
CONFIG_DELL_RBTN=m
CONFIG_FUJITSU_LAPTOP=m
# CONFIG_FUJITSU_TABLET is not set
CONFIG_AMILO_RFKILL=m
# CONFIG_HP_ACCEL is not set
CONFIG_HP_WIRELESS=y
CONFIG_HP_WMI=m
CONFIG_MSI_LAPTOP=m
# CONFIG_PANASONIC_LAPTOP is not set
CONFIG_COMPAL_LAPTOP=m
CONFIG_SONY_LAPTOP=m
# CONFIG_SONYPI_COMPAT is not set
CONFIG_IDEAPAD_LAPTOP=m
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_SENSORS_HDAPS is not set
CONFIG_ASUS_WIRELESS=m
CONFIG_ACPI_WMI=y
CONFIG_WMI_BMOF=y
CONFIG_MSI_WMI=m
CONFIG_PEAQ_WMI=y
CONFIG_TOPSTAR_LAPTOP=y
CONFIG_TOSHIBA_BT_RFKILL=m
# CONFIG_TOSHIBA_HAPS is not set
CONFIG_TOSHIBA_WMI=y
# CONFIG_ACPI_CMPC is not set
CONFIG_INTEL_CHT_INT33FE=y
# CONFIG_INTEL_INT0002_VGPIO is not set
CONFIG_INTEL_HID_EVENT=m
CONFIG_INTEL_VBTN=y
CONFIG_INTEL_IPS=y
# CONFIG_INTEL_PMC_CORE is not set
CONFIG_IBM_RTL=y
CONFIG_SAMSUNG_LAPTOP=m
CONFIG_MXM_WMI=y
CONFIG_INTEL_OAKTRAIL=m
CONFIG_SAMSUNG_Q10=y
# CONFIG_APPLE_GMUX is not set
CONFIG_INTEL_RST=m
CONFIG_INTEL_SMARTCONNECT=y
# CONFIG_PVPANIC is not set
CONFIG_INTEL_PMC_IPC=y
CONFIG_SURFACE_PRO3_BUTTON=m
# CONFIG_SURFACE_3_BUTTON is not set
CONFIG_INTEL_PUNIT_IPC=y
CONFIG_INTEL_TELEMETRY=y
# CONFIG_MLX_PLATFORM is not set
# CONFIG_MLX_CPLD_PLATFORM is not set
# CONFIG_SILEAD_DMI is not set
CONFIG_PMC_ATOM=y
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_LAPTOP=m
CONFIG_CHROMEOS_PSTORE=m
# CONFIG_CROS_KBD_LED_BACKLIGHT is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
CONFIG_COMMON_CLK_WM831X=m
CONFIG_COMMON_CLK_SI5351=y
CONFIG_COMMON_CLK_CDCE706=y
# CONFIG_COMMON_CLK_CS2000_CP is not set
CONFIG_CLK_TWL6040=y
# CONFIG_COMMON_CLK_NXP is not set
CONFIG_COMMON_CLK_PALMAS=m
# CONFIG_COMMON_CLK_PXA is not set
# CONFIG_COMMON_CLK_PIC32 is not set
# CONFIG_HWSPINLOCK is not set

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
CONFIG_IOMMU_IOVA=y
CONFIG_AMD_IOMMU=y
CONFIG_AMD_IOMMU_V2=y
CONFIG_DMAR_TABLE=y
CONFIG_INTEL_IOMMU=y
# CONFIG_INTEL_IOMMU_SVM is not set
# CONFIG_INTEL_IOMMU_DEFAULT_ON is not set
CONFIG_INTEL_IOMMU_FLOPPY_WA=y
CONFIG_IRQ_REMAP=y

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=m

#
# Rpmsg drivers
#

#
# SOC (System On Chip) specific Drivers
#

#
# Broadcom SoC drivers
#

#
# i.MX SoC drivers
#
# CONFIG_SUNXI_SRAM is not set
CONFIG_SOC_TI=y
# CONFIG_SOC_ZTE is not set
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=m
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=m
CONFIG_DEVFREQ_GOV_PASSIVE=y

#
# DEVFREQ Drivers
#
CONFIG_PM_DEVFREQ_EVENT=y
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_GPIO=y
CONFIG_EXTCON_INTEL_INT3496=m
CONFIG_EXTCON_INTEL_CHT_WC=m
CONFIG_EXTCON_MAX3355=y
CONFIG_EXTCON_MAX77693=y
CONFIG_EXTCON_MAX77843=m
# CONFIG_EXTCON_MAX8997 is not set
# CONFIG_EXTCON_PALMAS is not set
CONFIG_EXTCON_RT8973A=y
CONFIG_EXTCON_SM5502=m
CONFIG_EXTCON_USB_GPIO=m
CONFIG_MEMORY=y
# CONFIG_IIO is not set
CONFIG_NTB=m
CONFIG_NTB_AMD=m
# CONFIG_NTB_INTEL is not set
CONFIG_NTB_PINGPONG=m
# CONFIG_NTB_TOOL is not set
# CONFIG_NTB_PERF is not set
CONFIG_NTB_TRANSPORT=m
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
CONFIG_VME_CA91CX42=y
CONFIG_VME_TSI148=m
CONFIG_VME_FAKE=m

#
# VME Board Drivers
#
CONFIG_VMIVME_7805=m

#
# VME Device Drivers
#
CONFIG_VME_USER=m
# CONFIG_VME_PIO2 is not set
# CONFIG_PWM is not set
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=m
# CONFIG_BOARD_TPCI200 is not set
CONFIG_SERIAL_IPOCTAL=m
CONFIG_RESET_CONTROLLER=y
# CONFIG_RESET_ATH79 is not set
# CONFIG_RESET_BERLIN is not set
# CONFIG_RESET_GEMINI is not set
# CONFIG_RESET_IMX7 is not set
# CONFIG_RESET_LPC18XX is not set
# CONFIG_RESET_MESON is not set
# CONFIG_RESET_PISTACHIO is not set
# CONFIG_RESET_SOCFPGA is not set
# CONFIG_RESET_STM32 is not set
# CONFIG_RESET_SUNXI is not set
CONFIG_RESET_TI_SYSCON=y
# CONFIG_RESET_ZYNQ is not set
# CONFIG_RESET_TEGRA_BPMP is not set
CONFIG_FMC=y
CONFIG_FMC_FAKEDEV=y
CONFIG_FMC_TRIVIAL=y
# CONFIG_FMC_WRITE_EEPROM is not set
# CONFIG_FMC_CHARDEV is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_BCM_KONA_USB2_PHY=m
CONFIG_PHY_PXA_28NM_HSIC=m
CONFIG_PHY_PXA_28NM_USB2=m
# CONFIG_POWERCAP is not set
CONFIG_MCB=m
# CONFIG_MCB_PCI is not set
CONFIG_MCB_LPC=m

#
# Performance monitor support
#
CONFIG_RAS=y
CONFIG_THUNDERBOLT=m

#
# Android
#
CONFIG_ANDROID=y
CONFIG_ANDROID_BINDER_IPC=y
CONFIG_ANDROID_BINDER_DEVICES="binder,hwbinder,vndbinder"
CONFIG_LIBNVDIMM=m
CONFIG_BLK_DEV_PMEM=m
CONFIG_ND_BLK=m
# CONFIG_BTT is not set
CONFIG_DAX=y
CONFIG_NVMEM=y
CONFIG_STM=y
# CONFIG_STM_DUMMY is not set
# CONFIG_STM_SOURCE_CONSOLE is not set
CONFIG_STM_SOURCE_HEARTBEAT=m
# CONFIG_STM_SOURCE_FTRACE is not set
# CONFIG_INTEL_TH is not set

#
# FPGA Configuration Support
#
CONFIG_FPGA=m
CONFIG_ALTERA_PR_IP_CORE=m

#
# FSI support
#
# CONFIG_FSI is not set
# CONFIG_MULTIPLEXER is not set

#
# Firmware Drivers
#
CONFIG_EDD=m
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=y
# CONFIG_DCDBAS is not set
CONFIG_DMIID=y
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_FW_CFG_SYSFS=m
CONFIG_FW_CFG_SYSFS_CMDLINE=y
# CONFIG_GOOGLE_FIRMWARE is not set
# CONFIG_EFI_DEV_PATH_PARSER is not set

#
# Tegra firmware driver
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_EXT2_FS is not set
CONFIG_EXT3_FS=m
# CONFIG_EXT3_FS_POSIX_ACL is not set
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=m
# CONFIG_EXT4_USE_FOR_EXT2 is not set
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_EXT4_ENCRYPTION=y
CONFIG_EXT4_FS_ENCRYPTION=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=m
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=m
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
CONFIG_REISERFS_FS_XATTR=y
# CONFIG_REISERFS_FS_POSIX_ACL is not set
# CONFIG_REISERFS_FS_SECURITY is not set
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
CONFIG_GFS2_FS=y
CONFIG_OCFS2_FS=m
# CONFIG_OCFS2_FS_O2CB is not set
CONFIG_OCFS2_FS_USERSPACE_CLUSTER=m
CONFIG_OCFS2_FS_STATS=y
# CONFIG_OCFS2_DEBUG_MASKLOG is not set
# CONFIG_OCFS2_DEBUG_FS is not set
# CONFIG_BTRFS_FS is not set
CONFIG_NILFS2_FS=m
# CONFIG_F2FS_FS is not set
# CONFIG_FS_DAX is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_EXPORTFS_BLOCK_OPS=y
CONFIG_FILE_LOCKING=y
# CONFIG_MANDATORY_FILE_LOCKING is not set
CONFIG_FS_ENCRYPTION=m
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
# CONFIG_FANOTIFY_ACCESS_PERMISSIONS is not set
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
# CONFIG_PRINT_QUOTA_WARNING is not set
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=m
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=m
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
# CONFIG_AUTOFS4_FS is not set
# CONFIG_FUSE_FS is not set
CONFIG_OVERLAY_FS=y
# CONFIG_OVERLAY_FS_REDIRECT_DIR is not set

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
CONFIG_FSCACHE_DEBUG=y
CONFIG_FSCACHE_OBJECT_LIST=y
CONFIG_CACHEFILES=y
CONFIG_CACHEFILES_DEBUG=y
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=m
# CONFIG_JOLIET is not set
CONFIG_ZISOFS=y
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
# CONFIG_MSDOS_FS is not set
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_FAT_DEFAULT_UTF8 is not set
CONFIG_NTFS_FS=m
CONFIG_NTFS_DEBUG=y
# CONFIG_NTFS_RW is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
CONFIG_CONFIGFS_FS=y
# CONFIG_MISC_FILESYSTEMS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=m
CONFIG_NLS_CODEPAGE_860=m
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=y
# CONFIG_NLS_CODEPAGE_863 is not set
CONFIG_NLS_CODEPAGE_864=m
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=y
# CONFIG_NLS_CODEPAGE_932 is not set
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=m
CONFIG_NLS_ASCII=m
# CONFIG_NLS_ISO8859_1 is not set
CONFIG_NLS_ISO8859_2=m
CONFIG_NLS_ISO8859_3=y
# CONFIG_NLS_ISO8859_4 is not set
CONFIG_NLS_ISO8859_5=y
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=m
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=m
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_MAC_ROMAN=m
# CONFIG_NLS_MAC_CELTIC is not set
CONFIG_NLS_MAC_CENTEURO=m
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=m
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=m
CONFIG_NLS_MAC_ROMANIAN=m
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=m
CONFIG_DLM=m
# CONFIG_DLM_DEBUG is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
CONFIG_DYNAMIC_DEBUG=y

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_GDB_SCRIPTS is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_STACK_VALIDATION=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_PAGE_POISONING=y
CONFIG_PAGE_POISONING_NO_SANITY=y
CONFIG_PAGE_POISONING_ZERO=y
CONFIG_DEBUG_PAGE_REF=y
# CONFIG_DEBUG_RODATA_TEST is not set
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_SLUB_DEBUG_ON=y
CONFIG_SLUB_STATS=y
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_VMACACHE=y
CONFIG_DEBUG_VM_RB=y
CONFIG_DEBUG_VM_PGFLAGS=y
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=y
CONFIG_DEBUG_PER_CPU_MAPS=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_HAVE_ARCH_KASAN=y
# CONFIG_KASAN is not set
CONFIG_ARCH_HAS_KCOV=y
CONFIG_KCOV=y
# CONFIG_KCOV_INSTRUMENT_ALL is not set
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
CONFIG_WQ_WATCHDOG=y
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
CONFIG_SCHEDSTATS=y
CONFIG_SCHED_STACK_END_CHECK=y
# CONFIG_DEBUG_TIMEKEEPING is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_WW_MUTEX_SELFTEST=y
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_PI_LIST=y
# CONFIG_DEBUG_SG is not set
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
CONFIG_TORTURE_TEST=m
# CONFIG_RCU_PERF_TEST is not set
CONFIG_RCU_TORTURE_TEST=m
CONFIG_RCU_CPU_STALL_TIMEOUT=21
# CONFIG_RCU_TRACE is not set
CONFIG_RCU_EQS_DEBUG=y
CONFIG_DEBUG_WQ_FORCE_RR_CPU=y
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
CONFIG_CPU_HOTPLUG_STATE_CONTROL=y
CONFIG_NOTIFIER_ERROR_INJECTION=y
# CONFIG_PM_NOTIFIER_ERROR_INJECT is not set
# CONFIG_NETDEV_NOTIFIER_ERROR_INJECT is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
CONFIG_FAIL_PAGE_ALLOC=y
# CONFIG_FAIL_MAKE_REQUEST is not set
# CONFIG_FAIL_IO_TIMEOUT is not set
# CONFIG_FAIL_MMC_REQUEST is not set
# CONFIG_FAIL_FUTEX is not set
CONFIG_FAULT_INJECTION_DEBUG_FS=y
CONFIG_LATENCYTOP=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
# CONFIG_FUNCTION_GRAPH_TRACER is not set
# CONFIG_IRQSOFF_TRACER is not set
# CONFIG_SCHED_TRACER is not set
# CONFIG_HWLAT_TRACER is not set
# CONFIG_FTRACE_SYSCALLS is not set
# CONFIG_TRACER_SNAPSHOT is not set
CONFIG_TRACE_BRANCH_PROFILING=y
# CONFIG_BRANCH_PROFILE_NONE is not set
CONFIG_PROFILE_ANNOTATED_BRANCHES=y
# CONFIG_PROFILE_ALL_BRANCHES is not set
CONFIG_TRACING_BRANCHES=y
CONFIG_BRANCH_TRACER=y
CONFIG_STACK_TRACER=y
# CONFIG_BLK_DEV_IO_TRACE is not set
# CONFIG_KPROBE_EVENTS is not set
# CONFIG_UPROBE_EVENTS is not set
# CONFIG_PROBE_EVENTS is not set
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
# CONFIG_FUNCTION_PROFILER is not set
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
# CONFIG_HIST_TRIGGERS is not set
# CONFIG_TRACEPOINT_BENCHMARK is not set
CONFIG_RING_BUFFER_BENCHMARK=y
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
# CONFIG_TRACE_EVAL_MAP_FILE is not set
CONFIG_TRACING_EVENTS_GPIO=y

#
# Runtime Testing
#
# CONFIG_LKDTM is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_TEST_SORT is not set
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_INTERVAL_TREE_TEST is not set
# CONFIG_PERCPU_TEST is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_TEST_HEXDUMP is not set
# CONFIG_TEST_STRING_HELPERS is not set
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_TEST_PRINTF is not set
# CONFIG_TEST_BITMAP is not set
# CONFIG_TEST_UUID is not set
# CONFIG_TEST_RHASHTABLE is not set
# CONFIG_TEST_HASH is not set
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_TEST_LKM is not set
# CONFIG_TEST_USER_COPY is not set
# CONFIG_TEST_BPF is not set
# CONFIG_TEST_FIRMWARE is not set
# CONFIG_TEST_UDELAY is not set
CONFIG_MEMTEST=y
# CONFIG_TEST_STATIC_KEYS is not set
CONFIG_BUG_ON_DATA_CORRUPTION=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_ARCH_WANTS_UBSAN_NO_NULL is not set
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_EARLY_PRINTK_USB=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
# CONFIG_EARLY_PRINTK_USB_XDBC is not set
CONFIG_X86_PTDUMP_CORE=y
# CONFIG_X86_PTDUMP is not set
CONFIG_DEBUG_WX=y
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_DEBUG=y
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_X86_DECODER_SELFTEST=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_ENTRY is not set
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_X86_DEBUG_FPU is not set
CONFIG_PUNIT_ATOM_DEBUG=m

#
# Security options
#
CONFIG_KEYS=y
CONFIG_KEYS_COMPAT=y
# CONFIG_PERSISTENT_KEYRINGS is not set
# CONFIG_BIG_KEYS is not set
CONFIG_TRUSTED_KEYS=m
CONFIG_ENCRYPTED_KEYS=y
CONFIG_KEY_DH_OPERATIONS=y
CONFIG_SECURITY_DMESG_RESTRICT=y
CONFIG_SECURITY=y
# CONFIG_SECURITY_WRITABLE_HOOKS is not set
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
# CONFIG_SECURITY_NETWORK_XFRM is not set
CONFIG_SECURITY_PATH=y
# CONFIG_INTEL_TXT is not set
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
CONFIG_HARDENED_USERCOPY=y
# CONFIG_STATIC_USERMODEHELPER is not set
# CONFIG_SECURITY_SELINUX is not set
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_LOADPIN is not set
CONFIG_SECURITY_YAMA=y
# CONFIG_INTEGRITY is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_KPP=y
CONFIG_CRYPTO_ACOMP2=y
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_DH=y
# CONFIG_CRYPTO_ECDH is not set
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_MCRYPTD=y
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_CHACHA20POLY1305=y
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=m
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=m
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=m
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=m
CONFIG_CRYPTO_CRC32_PCLMUL=m
CONFIG_CRYPTO_CRCT10DIF=y
# CONFIG_CRYPTO_CRCT10DIF_PCLMUL is not set
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_POLY1305_X86_64=m
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=m
CONFIG_CRYPTO_RMD160=m
CONFIG_CRYPTO_RMD256=m
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256_SSSE3=y
# CONFIG_CRYPTO_SHA512_SSSE3 is not set
CONFIG_CRYPTO_SHA1_MB=y
CONFIG_CRYPTO_SHA256_MB=y
CONFIG_CRYPTO_SHA512_MB=m
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=m
CONFIG_CRYPTO_SHA3=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=m

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_TI=m
CONFIG_CRYPTO_AES_X86_64=m
# CONFIG_CRYPTO_AES_NI_INTEL is not set
CONFIG_CRYPTO_ANUBIS=m
CONFIG_CRYPTO_ARC4=m
# CONFIG_CRYPTO_BLOWFISH is not set
# CONFIG_CRYPTO_BLOWFISH_X86_64 is not set
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=m
CONFIG_CRYPTO_CAST_COMMON=y
# CONFIG_CRYPTO_CAST5 is not set
# CONFIG_CRYPTO_CAST5_AVX_X86_64 is not set
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_DES3_EDE_X86_64=y
# CONFIG_CRYPTO_FCRYPT is not set
CONFIG_CRYPTO_KHAZAD=y
# CONFIG_CRYPTO_SALSA20 is not set
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_X86_64=m
CONFIG_CRYPTO_SEED=m
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=m
# CONFIG_CRYPTO_TEA is not set
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
# CONFIG_CRYPTO_TWOFISH_X86_64_3WAY is not set
# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set

#
# Compression
#
# CONFIG_CRYPTO_DEFLATE is not set
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_842 is not set
# CONFIG_CRYPTO_LZ4 is not set
CONFIG_CRYPTO_LZ4HC=m

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=m
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
CONFIG_CRYPTO_DRBG_HASH=y
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_USER_API=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
CONFIG_CRYPTO_USER_API_AEAD=y
CONFIG_CRYPTO_HASH_INFO=y
# CONFIG_CRYPTO_HW is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_PKCS7_MESSAGE_PARSER=y

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
CONFIG_SYSTEM_EXTRA_CERTIFICATE=y
CONFIG_SYSTEM_EXTRA_CERTIFICATE_SIZE=4096
# CONFIG_SECONDARY_TRUSTED_KEYRING is not set
CONFIG_SYSTEM_BLACKLIST_KEYRING=y
CONFIG_SYSTEM_BLACKLIST_HASH_LIST=""
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_BITREVERSE=y
# CONFIG_HAVE_ARCH_BITREVERSE is not set
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=m
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
CONFIG_CRC32_SLICEBY4=y
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC4 is not set
CONFIG_CRC7=m
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=m
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4HC_COMPRESS=m
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=m
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_BCH=m
CONFIG_BCH_CONST_PARAMS=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=m
CONFIG_TEXTSEARCH_BM=m
CONFIG_TEXTSEARCH_FSM=m
CONFIG_BTREE=y
CONFIG_INTERVAL_TREE=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
# CONFIG_DMA_NOOP_OPS is not set
# CONFIG_DMA_VIRT_OPS is not set
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_GLOB=y
# CONFIG_GLOB_SELFTEST is not set
CONFIG_NLATTR=y
CONFIG_LRU_CACHE=m
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=m
CONFIG_DDR=y
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y
CONFIG_FONT_SUPPORT=y
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
# CONFIG_SG_SPLIT is not set
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
CONFIG_ARCH_HAS_MMIO_FLUSH=y
CONFIG_SBITMAP=y

--3V7upXqbjpZ4EhLz--
