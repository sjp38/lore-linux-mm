Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3CFDE6B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 23:52:45 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so732285pdj.28
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 20:52:44 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id sw1si906481pab.131.2014.07.29.20.52.42
        for <linux-mm@kvack.org>;
        Tue, 29 Jul 2014 20:52:44 -0700 (PDT)
Date: Wed, 30 Jul 2014 11:52:31 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [vmstat] BUG: using smp_processor_id() in preemptible [00000000]
 code: kworker/0:1/36
Message-ID: <20140730035231.GC16537@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="XvKFcGCOAo53UbWW"
Content-Disposition: inline
In-Reply-To: <20140730035025.GA18672@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Jet Chen <jet.chen@intel.com>, Su Tao <tao.su@intel.com>, Yuanhan Liu <yuanhan.liu@intel.com>, LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--XvKFcGCOAo53UbWW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Christoph,

This is another BUG message for the same commit.

git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
commit 6e0a6b18b63e2c0a45ff47ab633dd6f3ad417453
Author:     Christoph Lameter <cl@gentwo.org>
AuthorDate: Wed Jul 23 09:11:43 2014 +1000
Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
CommitDate: Wed Jul 23 09:11:43 2014 +1000

    vmstat: On demand vmstat workers V8
   =20
    vmstat workers are used for folding counter differentials into the zone,
    per node and global counters at certain time intervals.  They currently
    run at defined intervals on all processors which will cause some holdoff
    for processors that need minimal intrusion by the OS.
   =20
    The current vmstat_update mechanism depends on a deferrable timer firing
    every other second by default which registers a work queue item that ru=
ns
    on the local CPU, with the result that we have 1 interrupt and one
    additional schedulable task on each CPU every 2 seconds If a workload
    indeed causes VM activity or multiple tasks are running on a CPU, then
    there are probably bigger issues to deal with.
   =20
    However, some workloads dedicate a CPU for a single CPU bound task.  Th=
is
    is done in high performance computing, in high frequency financial
    applications, in networking (Intel DPDK, EZchip NPS) and with the advent
    of systems with more and more CPUs over time, this may become more and
    more common to do since when one has enough CPUs one cares less about
    efficiently sharing a CPU with other tasks and more about efficiently
    monopolizing a CPU per task.
   =20
    The difference of having this timer firing and workqueue kernel thread
    scheduled per second can be enormous.  An artificial test measuring the
    worst case time to do a simple "i++" in an endless loop on a bare metal
    system and under Linux on an isolated CPU with dynticks and with and
    without this patch, have Linux match the bare metal performance (~700
    cycles) with this patch and loose by couple of orders of magnitude (~20=
0k
    cycles) without it[*].  The loss occurs for something that just calcula=
tes
    statistics.  For networking applications, for example, this could be the
    difference between dropping packets or sustaining line rate.
   =20
    Statistics are important and useful, but it would be great if there wou=
ld
    be a way to not cause statistics gathering produce a huge performance
    difference.  This patche does just that.
   =20
    This patch creates a vmstat shepherd worker that monitors the per cpu
    differentials on all processors.  If there are differentials on a
    processor then a vmstat worker local to the processors with the
    differentials is created.  That worker will then start folding the diffs
    in regular intervals.  Should the worker find that there is no work to =
be
    done then it will make the shepherd worker monitor the differentials
    again.
   =20
    With this patch it is possible then to have periods longer than
    2 seconds without any OS event on a "cpu" (hardware thread).
   =20
    The patch shows a very minor increased in system performance.
   =20
    hackbench -s 512 -l 2000 -g 15 -f 25 -P
   =20
    Results before the patch:
   =20
    Running in process mode with 15 groups using 50 file descriptors each (=
=3D=3D 750 tasks)
    Each sender will pass 2000 messages of 512 bytes
    Time: 4.992
    Running in process mode with 15 groups using 50 file descriptors each (=
=3D=3D 750 tasks)
    Each sender will pass 2000 messages of 512 bytes
    Time: 4.971
    Running in process mode with 15 groups using 50 file descriptors each (=
=3D=3D 750 tasks)
    Each sender will pass 2000 messages of 512 bytes
    Time: 5.063
   =20
    Hackbench after the patch:
   =20
    Running in process mode with 15 groups using 50 file descriptors each (=
=3D=3D 750 tasks)
    Each sender will pass 2000 messages of 512 bytes
    Time: 4.973
    Running in process mode with 15 groups using 50 file descriptors each (=
=3D=3D 750 tasks)
    Each sender will pass 2000 messages of 512 bytes
    Time: 4.990
    Running in process mode with 15 groups using 50 file descriptors each (=
=3D=3D 750 tasks)
    Each sender will pass 2000 messages of 512 bytes
    Time: 4.993
   =20
    Signed-off-by: Christoph Lameter <cl@linux.com>
    Reviewed-by: Gilad Ben-Yossef <gilad@benyossef.com>
    Cc: Frederic Weisbecker <fweisbec@gmail.com>
    Cc: Thomas Gleixner <tglx@linutronix.de>
    Cc: Tejun Heo <tj@kernel.org>
    Cc: John Stultz <johnstul@us.ibm.com>
    Cc: Mike Frysinger <vapier@gentoo.org>
    Cc: Minchan Kim <minchan.kim@gmail.com>
    Cc: Hakan Akkan <hakanakkan@gmail.com>
    Cc: Max Krasnyansky <maxk@qti.qualcomm.com>
    Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
    Cc: Hugh Dickins <hughd@google.com>
    Cc: Viresh Kumar <viresh.kumar@linaro.org>
    Cc: H. Peter Anvin <hpa@zytor.com>
    Cc: Ingo Molnar <mingo@kernel.org>
    Cc: Peter Zijlstra <peterz@infradead.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

+---------------------------------------------------------+------------+---=
---------+---------------+
|                                                         | 4020841d46 | 6e=
0a6b18b6 | next-20140725 |
+---------------------------------------------------------+------------+---=
---------+---------------+
| boot_successes                                          | 1012       | 24=
6        | 9             |
| boot_failures                                           | 188        | 54=
         | 2             |
| BUG:kernel_boot_hang                                    | 188        | 42=
         |               |
| BUG:using_smp_processor_id()in_preemptible_code:kworker | 0          | 12=
         | 2             |
| backtrace:vmstat_update                                 | 0          | 12=
         | 2             |
+---------------------------------------------------------+------------+---=
---------+---------------+

[   16.503488] hwclock (152) used greatest stack depth: 6364 bytes left
[   16.507349] plymouthd (151) used greatest stack depth: 6292 bytes left
[   16.697360] chmod (170) used greatest stack depth: 6036 bytes left
[   17.346850] BUG: using smp_processor_id() in preemptible [00000000] code=
: kworker/0:1/36
[   17.347917] caller is debug_smp_processor_id+0x12/0x20
[   17.348597] CPU: 1 PID: 36 Comm: kworker/0:1 Not tainted 3.16.0-rc6-0025=
1-g6e0a6b1 #7
[   17.349662] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   17.350603] Workqueue: events vmstat_update
[   17.351211]  00000001 914e9e4c 828277f8 00000000 00000001 8305dad3 914e9=
e7c 8176b314
[   17.352422]  8306afe0 83069fba 8305dad3 00000000 914e1924 00000024 83069=
fba 83a99220
[   17.353626]  00000129 914c47e0 914e9e84 8176b342 914e9e98 811aa410 00000=
000 9237d200
[   17.354767] Call Trace:
[   17.355104]  [<828277f8>] dump_stack+0x7f/0xf3
[   17.355734]  [<8176b314>] check_preemption_disabled+0x164/0x180
[   17.356555]  [<8176b342>] debug_smp_processor_id+0x12/0x20
[   17.357404]  [<811aa410>] vmstat_update+0x40/0x80
[   17.358065]  [<8109bad9>] process_one_work+0x3a9/0xa40
[   17.358766]  [<8109bf8c>] ? process_one_work+0x85c/0xa40
[   17.359454]  [<8109c19d>] ? worker_thread+0x2d/0xb40
[   17.360141]  [<8109c72c>] worker_thread+0x5bc/0xb40
[   17.360782]  [<8109c170>] ? process_one_work+0xa40/0xa40
[   17.361473]  [<810a8932>] kthread+0xe2/0xf0
[   17.362036]  [<8109c170>] ? process_one_work+0xa40/0xa40
[   17.362784]  [<810b0000>] ? SyS_setns+0x90/0x160
[   17.363492]  [<82853c01>] ret_from_kernel_thread+0x21/0x30
[   17.364254]  [<810a8850>] ? insert_kthread_work+0x100/0x100

Elapsed time: 25
qemu-system-x86_64 -enable-kvm -cpu Haswell,+smep,+smap -kernel /kernel/i38=
6-randconfig-ib0-07271715/6e0a6b18b63e2c0a45ff47ab633dd6f3ad417453/vmlinuz-=
3.16.0-rc6-00251-g6e0a6b1 -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,=
115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeo=
ut=3D100 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramdi=
sk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0=
 rw link=3D/kbuild-tests/run-queue/kvm/i386-randconfig-ib0-07271715/next:ma=
ster:6e0a6b18b63e2c0a45ff47ab633dd6f3ad417453:bisect-linux5/.vmlinuz-6e0a6b=
18b63e2c0a45ff47ab633dd6f3ad417453-20140728053554-192-kbuild branch=3Dnext/=
master BOOT_IMAGE=3D/kernel/i386-randconfig-ib0-07271715/6e0a6b18b63e2c0a45=
ff47ab633dd6f3ad417453/vmlinuz-3.16.0-rc6-00251-g6e0a6b1 drbd.minor_count=
=3D8'  -initrd /kernel-tests/initrd/quantal-core-i386.cgz -m 320 -smp 2 -ne=
t nic,vlan=3D1,model=3De1000 -net user,vlan=3D1 -boot order=3Dnc -no-reboot=
 -watchdog i6300esb -rtc base=3Dlocaltime -pidfile /dev/shm/kboot/pid-quant=
al-kbuild-1 -serial file:/dev/shm/kboot/serial-quantal-kbuild-1 -daemonize =
-display none -monitor null=20

git bisect start 5a7439efd1c5c416f768fc550048ca130cf4bf99 9a3c4145af32125c5=
ee39c0272662b47307a8323 --
git bisect good 38efad9af81d145f07f592f618c76c78cf141e5b  # 19:10    300+  =
    0  Merge remote-tracking branch 'libata/for-next'
git bisect good 7ed8accbe1d061e1dfe4ce7a8681495595ebe1da  # 19:19    300+  =
    6  next-20140724/tip
git bisect good 7d3ce0493347c0176b37d877be1bc2204c2314b4  # 19:26    300+  =
   20  Merge remote-tracking branch 'staging/staging-next'
git bisect good 550c5daec4f343ffaf1a1e069e1f47275e12b369  # 19:28    300+  =
   70  Merge remote-tracking branch 'ktest/for-next'
git bisect good dd7314beaded523afff8444fa8d471446fb27172  # 19:32    300+  =
   96  Merge branch 'rd-docs/master'
git bisect good 4d1954347c000af3ee37661dc3acfe0ae8f59348  # 19:53    300+  =
   46  PKCS#7: include linux-err.h for PTR_ERR and IS_ERR
git bisect  bad 590deb1467ccd5b89a40441542eed94a20fde9cd  # 19:54     30-  =
    1  Merge branch 'akpm-current/current'
git bisect  bad a85e2d130331aa9885cbba74ae1a604dce709482  # 20:00      8-  =
    2  include/linux/kernel.h:744:28: note: in expansion of macro 'min'
git bisect good 4ac25431a42651458ee8fe31358d714aa18ee9aa  # 20:45    300+  =
   25  mm: memcontrol: rearrange charging fast path
git bisect good 84334f9696fba65dac01b6896e728ed64f25b0bb  # 20:50    300+  =
   49  mm,hugetlb: simplify error handling in hugetlb_cow()
git bisect  bad de32ada9f1bb4fd7673ed245ba2b1a9103ec50ae  # 20:53     53-  =
   63  slub: remove kmemcg id from create_unique_id
git bisect good e28c951ff01a805eacae2f67a96e0f29e32cebd1  # 21:03    300+  =
   45  mm: pagemap: avoid unnecessary overhead when tracepoints are deactiv=
ated
git bisect good 5860f33b9ac1c224a399736358d83693fe78ce82  # 21:15    300+  =
   82  mm: describe mmap_sem rules for __lock_page_or_retry() and callers
git bisect  bad e7943023cfcac3c9a7fe5a23713aa5723386d83b  # 21:34     13-  =
    4  cpu_stat_off can be static
git bisect  bad 6e0a6b18b63e2c0a45ff47ab633dd6f3ad417453  # 21:36      5-  =
    6  vmstat: On demand vmstat workers V8
git bisect good 4020841d464d689c045ad77f091f6f7fa211663d  # 22:20    300+  =
   48  mm/shmem.c: remove the unused gfp arg to shmem_add_to_page_cache()
# first bad commit: [6e0a6b18b63e2c0a45ff47ab633dd6f3ad417453] vmstat: On d=
emand vmstat workers V8
git bisect good 4020841d464d689c045ad77f091f6f7fa211663d  # 22:34    900+  =
  188  mm/shmem.c: remove the unused gfp arg to shmem_add_to_page_cache()
git bisect  bad 5a7439efd1c5c416f768fc550048ca130cf4bf99  # 22:34      0-  =
    2  Add linux-next specific files for 20140725
git bisect good 2062afb4f804afef61cbe62a30cac9a46e58e067  # 22:47    900+  =
  167  Fix gcc-4.9.0 miscompilation of load_balance()  in scheduler
git bisect  bad 5a7439efd1c5c416f768fc550048ca130cf4bf99  # 22:47      0-  =
    2  Add linux-next specific files for 20140725


This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=3D$1
initrd=3Dquantal-core-i386.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/blob/ma=
ster/initrd/$initrd

kvm=3D(
	qemu-system-x86_64
	-enable-kvm
	-cpu Haswell,+smep,+smap
	-kernel $kernel
	-initrd $initrd
	-m 320
	-smp 2
	-net nic,vlan=3D1,model=3De1000
	-net user,vlan=3D1
	-boot order=3Dnc
	-no-reboot
	-watchdog i6300esb
	-rtc base=3Dlocaltime
	-serial stdio
	-display none
	-monitor null=20
)

append=3D(
	hung_task_panic=3D1
	earlyprintk=3DttyS0,115200
	debug
	apic=3Ddebug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=3D100
	panic=3D10
	softlockup_panic=3D1
	nmi_watchdog=3Dpanic
	prompt_ramdisk=3D0
	console=3DttyS0,115200
	console=3Dtty0
	vga=3Dnormal
	root=3D/dev/ram0
	rw
	drbd.minor_count=3D8
)

"${kvm[@]}" --append "${append[*]}"
----------------------------------------------------------------------------

Thanks,
Fengguang

--XvKFcGCOAo53UbWW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-quantal-kbuild-1:20140727214816:i386-randconfig-ib0-07271715:3.16.0-rc6-00251-g6e0a6b1:7"
Content-Transfer-Encoding: quoted-printable

early console in setup code
Probing EDD (edd=3Doff to disable)... ok
[    0.000000] Linux version 3.16.0-rc6-00251-g6e0a6b1 (kbuild@lkp-hsx01) (=
gcc version 4.8.2 (Debian 4.8.2-18) ) #7 SMP PREEMPT Mon Jul 28 05:35:19 CS=
T 2014
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013ffdfff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013ffe000-0x0000000013ffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: n=
on-PAE kernel!
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2011
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x13ffe max_arch_pfn =3D 0x100000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdae0-0x000fdaef] mapped at =
[800fdae0]
[    0.000000]   mpc: fdaf0-fdbe4
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] initial memory mapped: [mem 0x00000000-0x047fffff]
[    0.000000] Base memory trampoline at [8009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12000000-0x123fffff]
[    0.000000]  [mem 0x12000000-0x123fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x10000000-0x11ffffff]
[    0.000000]  [mem 0x10000000-0x11ffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x003fffff] page 4k
[    0.000000]  [mem 0x00400000-0x0fffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x12400000-0x13ffdfff]
[    0.000000]  [mem 0x12400000-0x13bfffff] page 2M
[    0.000000]  [mem 0x13c00000-0x13ffdfff] page 4k
[    0.000000] BRK [0x043d4000, 0x043d4fff] PGTABLE
[    0.000000] BRK [0x043d5000, 0x043d6fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x127ab000-0x13feffff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x000FD950 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x13FFE450 000034 (v01 BOCHS  BXPCRSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: FACP 0x13FFFF80 000074 (v01 BOCHS  BXPCFACP 00000001 B=
XPC 00000001)
[    0.000000] ACPI: DSDT 0x13FFE490 0011A9 (v01 BXPC   BXDSDT   00000001 I=
NTL 20100528)
[    0.000000] ACPI: FACS 0x13FFFF40 000040
[    0.000000] ACPI: SSDT 0x13FFF7A0 000796 (v01 BOCHS  BXPCSSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: APIC 0x13FFF680 000080 (v01 BOCHS  BXPCAPIC 00000001 B=
XPC 00000001)
[    0.000000] ACPI: HPET 0x13FFF640 000038 (v01 BOCHS  BXPCHPET 00000001 B=
XPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffc000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 319MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 13ffe000
[    0.000000]   low ram: 0 - 13ffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13ffd001, primary cpu clock
[    0.000000] BRK [0x043d7000, 0x043d7fff] PGTABLE
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x13ffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13ffdfff]
[    0.000000] Initmem setup node 0 [mem 0x00001000-0x13ffdfff]
[    0.000000] On node 0 totalpages: 81820
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 608 pages used for memmap
[    0.000000]   Normal zone: 77822 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffc000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffb000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:2 nr_=
node_ids:1
[    0.000000] PERCPU: Embedded 331 pages/cpu @92235000 s1342048 r0 d13728 =
u1355776
[    0.000000] pcpu-alloc: s1342048 r0 d13728 u1355776 alloc=3D331*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 12237580
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 81180
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramd=
isk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram=
0 rw link=3D/kbuild-tests/run-queue/kvm/i386-randconfig-ib0-07271715/next:m=
aster:6e0a6b18b63e2c0a45ff47ab633dd6f3ad417453:bisect-linux5/.vmlinuz-6e0a6=
b18b63e2c0a45ff47ab633dd6f3ad417453-20140728053554-192-kbuild branch=3Dnext=
/master BOOT_IMAGE=3D/kernel/i386-randconfig-ib0-07271715/6e0a6b18b63e2c0a4=
5ff47ab633dd6f3ad417453/vmlinuz-3.16.0-rc6-00251-g6e0a6b1 drbd.minor_count=
=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 byte=
s)
[    0.000000] Initializing CPU#0
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 243256K/327280K available (24916K kernel code, 6466K=
 rwdata, 9884K rodata, 2356K init, 9316K bss, 84024K reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffa96000 - 0xfffff000   (5540 kB)
[    0.000000]     pkmap   : 0xff400000 - 0xff800000   (4096 kB)
[    0.000000]     vmalloc : 0x947fe000 - 0xff3fe000   (1708 MB)
[    0.000000]     lowmem  : 0x80000000 - 0x93ffe000   ( 319 MB)
[    0.000000]       .init : 0x83850000 - 0x83a9d000   (2356 kB)
[    0.000000]       .data : 0x828555db - 0x8384eac0   (16357 kB)
[    0.000000]       .text : 0x81000000 - 0x828555db   (24917 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D2, N=
odes=3D1
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D2
[    0.000000] NR_IRQS:2304 nr_irqs:512 16
[    0.000000] CPU 0 irqstacks, hard=3D91c0a000 soft=3D91c0c000
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 5167 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] ODEBUG: selftest passed
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2693.332 MHz processor
[    0.006666] Calibrating delay loop (skipped) preset value.. 5388.10 Bogo=
MIPS (lpj=3D8977773)
[    0.006666] pid_max: default: 32768 minimum: 301
[    0.006666] ACPI: Core revision 20140424
[    0.011998] ACPI: All ACPI Tables successfully acquired
[    0.012624] Security Framework initialized
[    0.013030] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.013346] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 by=
tes)
[    0.014727] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.014727] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.014727] tlb_flushall_shift: 6
[    0.018461] Freeing SMP alternatives memory: 44K (83a9d000 - 83aa8000)
[    0.025154] Getting VERSION: 1050014
[    0.025466] Getting VERSION: 1050014
[    0.025785] Getting ID: 0
[    0.026038] Getting ID: f000000
[    0.026413] Getting LVT0: 8700
[    0.026681] Getting LVT1: 8400
[    0.026942] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.027438] enabled ExtINT on CPU#0
[    0.028583] ENABLING IO-APIC IRQs
[    0.028870] init IO_APIC IRQs
[    0.029116]  apic 0 pin 0 not connected
[    0.029549] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.030034] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.030706] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.031374] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.032040] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.032705] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.033363] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.034006] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.034665] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.035323] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.036075] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.036710] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.037906] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.038906] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.040045] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.041004]  apic 0 pin 16 not connected
[    0.041461]  apic 0 pin 17 not connected
[    0.041928]  apic 0 pin 18 not connected
[    0.042398]  apic 0 pin 19 not connected
[    0.043355]  apic 0 pin 20 not connected
[    0.043816]  apic 0 pin 21 not connected
[    0.044276]  apic 0 pin 22 not connected
[    0.044748]  apic 0 pin 23 not connected
[    0.045387] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.046360] smpboot: CPU0: Intel Core Processor (Haswell) (fam: 06, mode=
l: 3c, stepping: 01)
[    0.047760] TSC deadline timer enabled
[    0.048442] Performance Events: unsupported p6 CPU model 60 no PMU drive=
r, software events only.
[    0.063463]=20
[    0.063463] **********************************************************
[    0.064921] **   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   **
[    0.066032] **                                                      **
[    0.066682] ** trace_printk() being used. Allocating extra memory.  **
[    0.067791] **                                                      **
[    0.068895] ** This means that this is a DEBUG kernel and it is     **
[    0.070014] ** unsafe for produciton use.                           **
[    0.071067] **                                                      **
[    0.071844] ** If you see this message and you are not debugging    **
[    0.072573] ** the kernel, report this immediately to your vendor!  **
[    0.073191] **                                                      **
[    0.073343] **   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   **
[    0.073977] **********************************************************
[    0.083687] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.093270] CPU 1 irqstacks, hard=3D91ff4000 soft=3D91ff6000
[    0.093354] x86: Booting SMP configuration:
[    0.094068] .... node  #0, CPUs:      #1
[    0.003333] Initializing CPU#1
[    0.006666] kvm-clock: cpu 1, msr 0:13ffd021, secondary cpu clock
[    0.006666] masked ExtINT on CPU#1
[    0.106874] KVM setup async PF for cpu 1
[    0.106948] x86: Booted up 1 node, 2 CPUs
[    0.106954] smpboot: Total of 2 processors activated (10777.21 BogoMIPS)
[    0.108906] kvm-stealtime: cpu 1, msr 12382580
[    0.114269] xor: automatically using best checksumming function:
[    0.146708]    avx       :    96.000 MB/sec
[    0.147088] prandom: seed boundary self test passed
[    0.147923] prandom: 100 self tests passed
[    0.148926] regulator-dummy: no parameters
[    0.149680] NET: Registered protocol family 16
[    0.151594] EISA bus registered
[    0.151925] cpuidle: using governor ladder
[    0.152436] cpuidle: using governor menu
[    0.171166] ACPI: bus type PCI registered
[    0.172153] PCI: PCI BIOS revision 2.10 entry at 0xfc6d5, last bus=3D0
[    0.172656] PCI: Using configuration type 1 for base access
[    0.296709] raid6: mmxx1     4319 MB/s
[    0.353365] raid6: mmxx2     3939 MB/s
[    0.410042] raid6: sse1x1    3280 MB/s
[    0.466690] raid6: sse1x2    3817 MB/s
[    0.523354] raid6: sse2x1    5007 MB/s
[    0.580023] raid6: sse2x2    8340 MB/s
[    0.580498] raid6: using algorithm sse2x2 (8340 MB/s)
[    0.581316] raid6: using ssse3x1 recovery algorithm
[    0.583080] ACPI: Added _OSI(Module Device)
[    0.583352] ACPI: Added _OSI(Processor Device)
[    0.583914] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.584431] ACPI: Added _OSI(Processor Aggregator Device)
[    0.608669] ACPI: Interpreter enabled
[    0.609002] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S1_] (20140424/hwxface-580)
[    0.609770] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_] (20140424/hwxface-580)
[    0.610778] ACPI: (supports S0 S3 S5)
[    0.611270] ACPI: Using IOAPIC for interrupt routing
[    0.612013] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.637342] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.638061] acpi PNP0A03:00: _OSC: OS supports [Segments MSI]
[    0.638818] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.640930] acpi PNP0A03:00: fail to add MMCONFIG information, can't acc=
ess extended PCI configuration space under this bridge.
[    0.646059] PCI host bridge to bus 0000:00
[    0.646688] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.647478] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.648236] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.649046] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.649862] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.650101] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.652060] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.654487] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.658147] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.660052] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    0.660948] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.661796] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    0.662767] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.664616] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.666240] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.666707] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.668800] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.670753] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.673295] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.680799] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.683533] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.685497] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    0.687281] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.693253] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    0.694308] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.695544] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.701430] pci_bus 0000:00: on NUMA node 0
[    0.704874] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.706404] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.707391] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.708559] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.709495] ACPI: PCI Interrupt Link [LNKS] (IRQs *9)
[    0.712153] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.715029] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.715938] vgaarb: loaded
[    0.716247] vgaarb: bridge control possible 0000:00:02.0
[    0.718697] SCSI subsystem initialized
[    0.719357] libata version 3.00 loaded.
[    0.721058] pps_core: LinuxPPS API ver. 1 registered
[    0.721790] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.722958] PTP clock support registered
[    0.723495] EDAC MC: Ver: 3.0.0
[    0.724544] wmi: Mapper loaded
[    0.725034] PCI: Using ACPI for IRQ routing
[    0.726691] PCI: pci_cache_line_size set to 64 bytes
[    0.727484] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.728367] e820: reserve RAM buffer [mem 0x13ffe000-0x13ffffff]
[    0.730791] NET: Registered protocol family 23
[    0.731473] Bluetooth: Core ver 2.19
[    0.732007] NET: Registered protocol family 31
[    0.732546] Bluetooth: HCI device and connection manager initialized
[    0.733397] Bluetooth: HCI socket layer initialized
[    0.734122] Bluetooth: L2CAP socket layer initialized
[    0.734806] Bluetooth: SCO socket layer initialized
[    0.735416] NET: Registered protocol family 8
[    0.736181] NET: Registered protocol family 20
[    0.737087] nfc: nfc_init: NFC Core ver 0.1
[    0.737816] NET: Registered protocol family 39
[    0.740191] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    0.741236] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.741968] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    0.745114] Switched to clocksource kvm-clock
[    0.745776] Warning: could not register all branches stats
[    0.746529] Warning: could not register annotated branches stats
[    0.906397] FS-Cache: Loaded
[    0.907114] CacheFiles: Loaded
[    0.907680] pnp: PnP ACPI init
[    0.908155] ACPI: bus type PNP registered
[    0.908948] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    0.910254] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.911333] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    0.912597] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.913577] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    0.914913] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.915938] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    0.917022] pnp 00:03: [dma 2]
[    0.917624] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.918647] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    0.919830] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.921001] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    0.922284] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.923303] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:3)
[    0.924664] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.927083] pnp: PnP ACPI: found 7 devices
[    0.927777] ACPI: bus type PNP unregistered
[    0.928338] PnPBIOS: Disabled
[    0.965283] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.965998] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    0.966751] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    0.967574] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    0.968426] NET: Registered protocol family 1
[    0.969018] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.969790] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.970687] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.971535] pci 0000:00:02.0: Boot video device
[    0.972249] PCI: CLS 0 bytes, default 64
[    0.973828] Unpacking initramfs...
[    3.016072] Freeing initrd memory: 24852K (927ab000 - 93ff0000)
[    3.019525] apm: BIOS not found.
[    3.020075] Scanning for low memory corruption every 60 seconds
[    3.022595] cryptomgr_test (38) used greatest stack depth: 6984 bytes le=
ft
[    3.030310] cryptomgr_test (53) used greatest stack depth: 6840 bytes le=
ft
[    3.035107] NatSemi SCx200 Driver
[    3.037884] futex hash table entries: 512 (order: 3, 32768 bytes)
[    3.089831] VFS: Disk quotas dquot_6.5.2
[    3.092152] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    3.102055] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    3.117395] efs: 1.0a - http://aeschi.ch.eu.org/efs/
[    3.123646] ROMFS MTD (C) 2007 Red Hat, Inc.
[    3.126643] QNX6 filesystem 1.0.0 registered.
[    3.127746] fuse init (API version 7.23)
[    3.130347] JFS: nTxBlock =3D 2094, nTxLock =3D 16759
[    3.142380] NILFS version 2 loaded
[    3.142822] befs: version: 0.9.3
[    3.145866] msgmni has been set to 523
[    3.146464] Key type big_key registered
[    3.245969] NET: Registered protocol family 38
[    3.246832] Key type asymmetric registered
[    3.247730] bounce: pool size: 64 pages
[    3.249530] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 250)
[    3.250744] io scheduler noop registered
[    3.251515] io scheduler cfq registered (default)
[    3.252181] list_sort_test: start testing list_sort()
[    3.254847] test_string_helpers: Running tests...
[    3.256239] xz_dec_test: module loaded
[    3.256911] xz_dec_test: Create a device node with 'mknod xz_dec_test c =
249 0' and write .xz files to it.
[    3.272083] cr_bllcd: INTEL CARILLO RANCH LPC not found.
[    3.274283] cr_bllcd: Carillo Ranch Backlight Driver Initialized.
[    3.277549] nvidiafb_setup START
[    3.280130] vmlfb: initializing
[    3.280910] Could not find Carillo Ranch MCH device.
[    3.282309] no IO addresses supplied
[    3.285043] hv_vmbus: registering driver hyperv_fb
[    3.288578] kworker/u4:0 (115) used greatest stack depth: 6820 bytes left
[    3.289613] uvesafb: failed to execute /sbin/v86d
[    3.290370] uvesafb: make sure that the v86d helper is installed and exe=
cutable
[    3.291402] uvesafb: Getting VBE info block failed (eax=3D0x4f00, err=3D=
-2)
[    3.292315] uvesafb: vbe_init() failed with -22
[    3.293015] uvesafb: probe of uvesafb.0 failed with error -22
[    3.294704] ipmi message handler version 39.2
[    3.295584] IPMI System Interface driver.
[    3.300842] ipmi_si: Unable to find any System Interface(s)
[    3.301647] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via =
sys_reboot.
[    3.302703] IPMI poweroff: Unable to register powercycle sysctl
[    3.305532] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    3.306576] ACPI: Power Button [PWRF]
[    3.310731] isapnp: Scanning for PnP cards...
[    3.759921] isapnp: No Plug & Play device found
[    3.876775] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    4.020226] tsc: Refined TSC clocksource calibration: 2693.500 MHz
[    4.201917] serial: Freescale lpuart driver
[    4.202887] MOXA Intellio family driver version 6.0k
[    4.203795] MOXA Smartio/Industio family driver version 2.0.5
[    4.204658] RocketPort device driver module, version 2.09, 12-June-2003
[    4.205475] No rocketport ports found; unloading driver
[    4.206101] SyncLink GT
[    4.206438] SyncLink GT, tty major#244
[    4.207096] SyncLink GT no devices found
[    4.207575] SyncLink MultiPort driver $Revision: 4.38 $
[    4.231642] SyncLink MultiPort driver $Revision: 4.38 $, tty major#243
[    4.232526] lp: driver loaded but no devices found
[    4.233189] DoubleTalk PC - not found
[    4.233686] sonypi: Sony Programmable I/O Controller Driver v1.26.
[    4.234929] toshiba: not a supported Toshiba laptop
[    4.235939] ppdev: user-space parallel port driver
[    4.236867] platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver Initial=
izing
[    4.237706] platform pc8736x_gpio.0: no device found
[    4.238513] nsc_gpio initializing
[    4.238939] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    4.239540] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    4.240606] Hangcheck: Using getrawmonotonic().
[    4.241664] [drm] Initialized drm 1.1.0 20060810
[    4.247086] [TTM] Zone  kernel: Available graphics memory: 134076 kiB
[    4.247844] [TTM] Initializing pool allocator
[    4.250550] [drm] fb mappable at 0xFC000000
[    4.251046] [drm] vram aper at 0xFC000000
[    4.251519] [drm] size 4194304
[    4.251879] [drm] fb depth is 24
[    4.252256] [drm]    pitch is 3072
[    4.253554] cirrus 0000:00:02.0: fb0: cirrusdrmfb frame buffer device
[    4.254297] cirrus 0000:00:02.0: registered panic notifier
[    4.260218] [drm] Initialized cirrus 1.0.0 20110418 for 0000:00:02.0 on =
minor 0
[    4.263779] parport_pc 00:04: reported by Plug and Play ACPI
[    4.264613] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[    4.347505] lp0: using parport0 (interrupt-driven).
[    4.351521] ibmasm: IBM ASM Service Processor Driver version 1.0 loaded
[    4.352529] dummy-irq: no IRQ given.  Use irq=3DN
[    4.353295] lkdtm: No crash points registered, enable through debugfs
[    4.354516] Phantom Linux Driver, version n0.9.8, init OK
[    4.356594] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Gi=
ometti
[    4.357993] c2port c2port0: C2 port uc added
[    4.358506] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 by=
tes total)
[    4.360419] Guest personality initialized and is inactive
[    4.361286] VMCI host device registered (name=3Dvmci, major=3D10, minor=
=3D59)
[    4.362050] Initialized host personality
[    4.371410] Uniform Multi-Platform E-IDE driver
[    4.372624] piix 0000:00:01.1: IDE controller (0x8086:0x7010 rev 0x00)
[    4.373615] piix 0000:00:01.1: not 100% native mode: will probe irqs lat=
er
[    4.374974]     ide0: BM-DMA at 0xc040-0xc047
[    4.375524]     ide1: BM-DMA at 0xc048-0xc04f
[    4.376050] Probing IDE interface ide0...
[    4.927157] Probing IDE interface ide1...
[    5.660190] hdc: QEMU DVD-ROM, ATAPI CD/DVD-ROM drive
[    6.300454] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO0
[    6.301316] hdc: MWDMA2 mode selected
[    6.302067] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[    6.302741] ide1 at 0x170-0x177,0x376 on irq 15
[    6.308314] ide-gd driver 1.18
[    6.314021] Loading iSCSI transport class v2.0-870.
[    6.317247] rdac: device handler registered
[    6.320160] hp_sw: device handler registered
[    6.320687] emc: device handler registered
[    6.321182] alua: device handler registered
[    6.350506] fnic: Cisco FCoE HBA Driver, ver 1.6.0.10
[    6.351403] fnic: Successfully Initialized Trace Buffer
[    6.352391] fnic: Successfully Initialized FC_CTLR Trace Buffer
[    6.357367] Loading Adaptec I2O RAID: Version 2.4 Build 5go
[    6.358032] Detecting Adaptec I2O RAID controllers...
[    6.364753] Adaptec aacraid driver 1.2-0[30300]-ms
[    6.365829] isci: Intel(R) C600 SAS Controller Driver - version 1.2.0
[    6.367432] scsi: <fdomain> Detection failed (no card)
[    6.368280] NCR53c406a: no available ports found
[    6.368831] sym53c416.c: Version 1.0.0-ac
[    6.369926] iscsi: registered transport (qla4xxx)
[    6.370735] QLogic iSCSI HBA Driver
[    6.396775] Failed initialization of WD-7000 SCSI card!
[    7.394249] DC390: clustering now enabled by default. If you get problem=
s load
[    7.395203]        with "disable_clustering=3D1" and report to maintaine=
rs
[    7.396304] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 ES=
T 2006)
[    7.397475] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 20=
06)
[    7.398553] mpt2sas version 16.100.00.00 loaded
[    7.399511] mpt3sas version 02.100.00.00 loaded
[    7.401223] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[    7.402650] 3ware Storage Controller device driver for Linux v1.26.02.00=
3.
[    7.403769] 3ware 9000 Storage Controller device driver for Linux v2.26.=
02.014.
[    7.404858] imm: Version 2.05 (for Linux 2.4.0)
[    7.406154] nsp32: loading...
[    7.406763] RocketRAID 3xxx/4xxx Controller driver v1.8
[    7.407878] Broadcom NetXtreme II iSCSI Driver bnx2i v2.7.6.2 (Jun 06, 2=
013)
[    7.409042] iscsi: registered transport (bnx2i)
[    7.413751] iscsi: registered transport (be2iscsi)
[    7.414389] In beiscsi_module_init, tt=3D832b4440
[    7.415453] esas2r: driver will not be loaded because no ATTO esas2r dev=
ices were found
[    7.416817] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[    7.418489] SCSI Media Changer driver v0.25=20
[    7.426799] scsi_debug: host protection
[    7.427320] scsi2 : scsi_debug, version 1.82 [20100324], dev_size_mb=3D8=
, opts=3D0x0
[    7.430480] scsi 2:0:0:0: Direct-Access     Linux    scsi_debug       00=
04 PQ: 0 ANSI: 5
[    7.435640] sd 2:0:0:0: Attached scsi generic sg0 type 0
[    7.436913] sd 2:0:0:0: [sda] 16384 512-byte logical blocks: (8.38 MB/8.=
00 MiB)
[    7.440149] sd 2:0:0:0: [sda] Write Protect is off
[    7.440796] sd 2:0:0:0: [sda] Mode Sense: 73 00 10 08
[    7.442801] SSFDC read-only Flash Translation layer
[    7.443685] mtdoops: mtd device (mtddev=3Dname/number) must be supplied
[    7.444636] L440GX flash mapping: failed to find PIIX4 ISA bridge, canno=
t continue
[    7.445625] device id =3D 2440
[    7.446031] device id =3D 2480
[    7.446435] device id =3D 24c0
[    7.446939] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 supports DPO and FUA
[    7.448138] device id =3D 24d0
[    7.448542] device id =3D 25a1
[    7.448961] device id =3D 2670
[    7.449661] platform physmap-flash.0: failed to claim resource 0
[    7.454182] slram: not enough parameters.
[    7.455270] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    7.456442] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    7.457888] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    7.459084] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    7.460440] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    7.461664] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    7.462858] nand: device found, Manufacturer ID: 0x98, Chip ID: 0x39
[    7.464485] nand: Toshiba NAND 128MiB 1,8V 8-bit
[    7.465081] nand: 128MiB, SLC, page size: 512, OOB size: 16
[    7.465971] flash size: 128 MiB
[    7.466396] page size: 512 bytes
[    7.467191] OOB area size: 16 bytes
[    7.467661] sector size: 16 KiB
[    7.468078] pages number: 262144
[    7.468504] pages per sector: 32
[    7.468937] bus width: 8
[    7.469275] bits in sector size: 14
[    7.469736] bits in page size: 9
[    7.470309]  sda: unknown partition table
[    7.472975] bits in OOB size: 4
[    7.474212] flash size with OOB: 135168 KiB
[    7.474777] page address bytes: 4
[    7.475209] sector address bytes: 3
[    7.475665] options: 0x42
[    7.477752] Scanning device for bad blocks
[    7.483773] sd 2:0:0:0: [sda] Attached SCSI disk
[    7.771300] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[    7.772134] 0x000000000000-0x000008000000 : "NAND simulator partition 0"
[    7.777268] parport0: cannot grant exclusive access for device spi-lm70l=
lp
[    7.778172] spi-lm70llp: spi_lm70llp probe fail, status -12
[    7.779824] HSI/SSI char device loaded
[    7.788439] libphy: Fixed MDIO Bus: probed
[    7.790861] tun: Universal TUN/TAP device driver, 1.6
[    7.791522] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    7.792646] arcnet loaded.
[    7.793022] arcnet: RFC1201 "standard" (`a') encapsulation support loade=
d.
[    7.793988] arcnet: RFC1051 "simple standard" (`s') encapsulation suppor=
t loaded.
[    7.794965] arcnet: cap mode (`c') encapsulation support loaded.
[    7.795754] arcnet: COM90xx chipset support
[    8.098281] S3: No ARCnet cards found.
[    8.098865] arcnet: COM90xx IO-mapped mode support (by David Woodhouse e=
t el.)
[    8.099762] E-mail me if you actually test this driver, please!
[    8.100571]  arc%d: No autoprobe for IO mapped cards; you must specify t=
he base address!
[    8.101698] arcnet: RIM I (entirely mem-mapped) support
[    8.102375] E-mail me if you actually test the RIM I driver, please!
[    8.103214] Given: node 00h, shmem 0h, irq 0
[    8.103831] No autoprobe for RIM I; you must specify the shmem and irq!
[    8.104698] slcan: serial line CAN interface driver
[    8.105327] slcan: 10 dynamic interface channels.
[    8.148390] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.20 (March =
14, 2014)
[    8.149764] bnx2x: Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit Ether=
net Driver bnx2x 1.78.19-0 (2014/02/10)
[    8.154197] enic: Cisco VIC Ethernet NIC Driver, ver 2.1.1.50
[    8.156038] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[    8.156881] e100: Copyright(c) 1999-2006 Intel Corporation
[    8.157789] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-=
NAPI
[    8.158692] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    8.168802] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    8.169584] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:3)
[    8.532572] e1000 0000:00:03.0 eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:56
[    8.534392] e1000 0000:00:03.0 eth0: Intel(R) PRO/1000 Network Connection
[    8.535539] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - vers=
ion 3.19.1-k
[    8.536519] ixgbe: Copyright (c) 1999-2014 Intel Corporation.
[    8.537594] ixgbevf: Intel(R) 10 Gigabit PCI Express Virtual Function Ne=
twork Driver - version 2.12.1-k
[    8.538799] ixgbevf: Copyright (c) 2009 - 2012 Intel Corporation.
[    8.539940] i40e: Intel(R) Ethernet Connection XL710 Network Driver - ve=
rsion 0.4.10-k
[    8.541008] i40e: Copyright (c) 2013 - 2014 Intel Corporation.
[    8.541954] jme: JMicron JMC2XX ethernet driver version 1.0.8
[    8.543067] sky2: driver version 1.30
[    8.545681] Solarflare NET driver v4.0
[    8.563117] tlan: ThunderLAN driver v1.17
[    8.563943] tlan: 0 devices installed, PCI: 0  EISA: 0
[    8.565246] AX.25: Z8530 SCC driver version 3.0.dl1bke
[    8.567595] mkiss: AX.25 Multikiss, Hans Albas PE1AYX
[    8.568277] YAM driver version 0.8 by F1OAT/F6FBB
[    8.577934] baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    8.577934] baycom_ser_fdx: version 0.10
[    8.585605] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[    8.586349] hdlcdrv: version 0.8
[    8.586887] baycom_ser_hdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    8.586887] baycom_ser_hdx: version 0.10
[    8.596283] baycom_par: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    8.596283] baycom_par: version 0.9
[    8.603920] baycom_epp: (C) 1998-2000 Thomas Sailer, HB9JNX/AE4WA
[    8.603920] baycom_epp: version 0.7
[    8.616950] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=
=3D256).
[    8.617888] SLIP linefill/keepalive option.
[    8.618440] Loaded prism54 driver, version 1.2
[    8.625945] ieee802154hardmac ieee802154hardmac: Added ieee802154 HardMA=
C hardware
[    8.627114] hv_vmbus: registering driver hv_netvsc
[    8.628188] Madge ATM Horizon [Ultra] driver version 1.2.1
[    8.628907] hrz: debug bitmap is 0
[    8.629903] idt77252_init: at 838d314d
[    8.633615] Solos PCI Driver Version 1.04
[    8.637155] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    8.640389] serio: i8042 KBD port at 0x60,0x64 irq 1
[    8.641172] serio: i8042 AUX port at 0x60,0x64 irq 12
[    8.642830] hv_vmbus: registering driver hyperv_keyboard
[    8.719918] evbug: Connected device: input0 (Power Button at LNXPWRBN/bu=
tton/input0)
[    8.723687] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    8.724843] evbug: Connected device: input1 (AT Translated Set 2 keyboar=
d at isa0060/serio0/input0)
[    8.734193] rtc_cmos 00:00: RTC can wake from S4
[    8.735890] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[    8.737424] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpet =
irqs
[    8.744644] rtc (null): invalid alarm value: 1900-1-27 0:0:0
[    8.745633] rtc-test rtc-test.0: rtc core: registered test as rtc1
[    8.750509] rtc (null): invalid alarm value: 1900-1-27 0:0:0
[    8.751512] rtc-test rtc-test.1: rtc core: registered test as rtc2
[    8.752693] i2c /dev entries driver
[    8.755206] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0xb100, r=
evision 0
[    8.775201] i2c-parport: adapter type unspecified
[    8.775819] i2c-parport-light: adapter type unspecified
[    8.778220] saa7146: register extension 'budget dvb'
[    8.779004] saa7146: register extension 'budget_ci dvb'
[    8.780962] nGene PCIE bridge driver, Copyright (C) 2005-2007 Micronas
[    8.782037] smssdio: Siano SMS1xxx SDIO driver
[    8.782589] smssdio: Copyright Pierre Ossman
[    8.783669] pps pps0: new PPS source ktimer
[    8.784401] pps pps0: ktimer PPS source registered
[    8.785022] pps_ldisc: PPS line discipline registered
[    8.785699] pps_parport: parallel port PPS client
[    8.786291] parport0: cannot grant exclusive access for device pps_parpo=
rt
[    8.788709] pps_parport: couldn't register with parport0
[    8.789380] Driver for 1-wire Dallas network protocol.
[    8.792972] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    8.794202] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 20=
04-2005, Szabolcs Gyurko
[    8.933470] w83793: Detection failed at check vendor id
[    8.953463] w83793: Detection failed at check vendor id
[    8.973465] w83793: Detection failed at check vendor id
[    8.993465] w83793: Detection failed at check vendor id
[    9.020187] detect failed, chip not detected!
[    9.046804] detect failed, chip not detected!
[    9.073468] detect failed, chip not detected!
[    9.100158] detect failed, chip not detected!
[    9.126806] detect failed, chip not detected!
[    9.153462] detect failed, chip not detected!
[    9.180142] detect failed, chip not detected!
[    9.206816] detect failed, chip not detected!
[    9.233470] detect failed, chip not detected!
[    9.253471] i2c i2c-0: Detecting device at 0,0x2c with COMPANY: 0xff and=
 VERSTEP: 0xff
[    9.254551] i2c i2c-0: Autodetecting device at 0,0x2c...
[    9.255268] i2c i2c-0: Autodetection failed
[    9.273475] i2c i2c-0: Detecting device at 0,0x2d with COMPANY: 0xff and=
 VERSTEP: 0xff
[    9.274535] i2c i2c-0: Autodetecting device at 0,0x2d...
[    9.275261] i2c i2c-0: Autodetection failed
[    9.293468] i2c i2c-0: Detecting device at 0,0x2e with COMPANY: 0xff and=
 VERSTEP: 0xff
[    9.294558] i2c i2c-0: Autodetecting device at 0,0x2e...
[    9.295277] i2c i2c-0: Autodetection failed
[    9.366808] i2c i2c-0: detect fail: address match, 0x2c
[    9.380156] i2c i2c-0: detect fail: address match, 0x2d
[    9.393466] i2c i2c-0: detect fail: address match, 0x2e
[    9.406811] i2c i2c-0: detect fail: address match, 0x2f
[    9.420146]  (null): Wrong manufacturer ID. Got 255, expected 65
[    9.433478]  (null): Wrong manufacturer ID. Got 255, expected 65
[    9.446805]  (null): Wrong manufacturer ID. Got 255, expected 65
[    9.896880] f71882fg: Not a Fintek device
[    9.897544] f71882fg: Not a Fintek device
[   10.030116]  (null): Unknown chip type, skipping
[   10.043458]  (null): Unknown chip type, skipping
[   10.356804] i2c i2c-0: Unsupported chip (man_id=3D0xFF, chip_id=3D0xFF)
[   10.403486] i2c i2c-0: Unsupported chip (man_id=3D0xFF, chip_id=3D0xFF)
[   10.450106] i2c i2c-0: Unsupported chip (man_id=3D0xFF, chip_id=3D0xFF)
[   15.140186] i2c i2c-0: LM83 detection failed at 0x18
[   15.153546] i2c i2c-0: LM83 detection failed at 0x19
[   15.166899] i2c i2c-0: LM83 detection failed at 0x1a
[   15.180178] i2c i2c-0: LM83 detection failed at 0x29
[   15.193539] i2c i2c-0: LM83 detection failed at 0x2a
[   15.206910] i2c i2c-0: LM83 detection failed at 0x2b
[   15.220184] i2c i2c-0: LM83 detection failed at 0x4c
[   15.233557] i2c i2c-0: LM83 detection failed at 0x4d
[   15.246906] i2c i2c-0: LM83 detection failed at 0x4e
[   15.271014] i2c i2c-0: Detecting device at 0x2c with COMPANY: 0xff and V=
ERSTEP: 0xff
[   15.290227] i2c i2c-0: Detecting device at 0x2d with COMPANY: 0xff and V=
ERSTEP: 0xff
[   15.310315] i2c i2c-0: Detecting device at 0x2e with COMPANY: 0xff and V=
ERSTEP: 0xff
[   15.363494] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[   15.376854] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[   15.390203] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[   15.557384] sch56xx_common: Unsupported device id: 0xff
[   15.557980] sch56xx_common: Unsupported device id: 0xff
[   15.563497] i2c i2c-0: amc6821_detect called.
[   15.576852] i2c i2c-0: amc6821: detection failed at 0x18.
[   15.583485] i2c i2c-0: amc6821_detect called.
[   15.596853] i2c i2c-0: amc6821: detection failed at 0x19.
[   15.603487] i2c i2c-0: amc6821_detect called.
[   15.616854] i2c i2c-0: amc6821: detection failed at 0x1a.
[   15.623469] i2c i2c-0: amc6821_detect called.
[   15.636798] i2c i2c-0: amc6821: detection failed at 0x2c.
[   15.643450] i2c i2c-0: amc6821_detect called.
[   15.656829] i2c i2c-0: amc6821: detection failed at 0x2d.
[   15.663460] i2c i2c-0: amc6821_detect called.
[   15.676812] i2c i2c-0: amc6821: detection failed at 0x2e.
[   15.683459] i2c i2c-0: amc6821_detect called.
[   15.696811] i2c i2c-0: amc6821: detection failed at 0x4c.
[   15.703441] i2c i2c-0: amc6821_detect called.
[   15.716815] i2c i2c-0: amc6821: detection failed at 0x4d.
[   15.723450] i2c i2c-0: amc6821_detect called.
[   15.736805] i2c i2c-0: amc6821: detection failed at 0x4e.
[   15.743452] thmc50: Probing for THMC50 at 0x2C on bus 0
[   15.770119] thmc50: Probing for THMC50 at 0x2D on bus 0
[   15.796792] thmc50: Probing for THMC50 at 0x2E on bus 0
[   15.936813] i2c i2c-0: W83L786NG detection failed at 0x2e
[   15.950168] i2c i2c-0: W83L786NG detection failed at 0x2f
[   15.951544] pcwd: Port 0x0350 unavailable
[   15.952498] mixcomwd: No card detected, or port not available
[   15.953536] acquirewdt: WDT driver for Acquire single board computer ini=
tialising
[   15.954688] acquirewdt: I/O address 0x0043 already in use
[   15.955292] acquirewdt: probe of acquirewdt failed with error -5
[   15.956076] advantechwdt: WDT driver for Advantech single board computer=
 initialising
[   15.957420] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D0)
[   15.958109] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
[   15.958708] alim7101_wdt: ALi M7101 PMU not present - WDT not set
[   15.959723] geodewdt: No timers were available
[   15.960431] ib700wdt: WDT driver for IB700 single board computer initial=
ising
[   15.961507] ib700wdt: START method I/O 443 is not available
[   15.962125] ib700wdt: probe of ib700wdt failed with error -5
[   15.962881] wafer5823wdt: WDT driver for Wafer 5823 single board compute=
r initialising
[   15.969608] wafer5823wdt: I/O address 0x0443 already in use
[   15.970355] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[   15.971197] i6300esb: cannot register miscdev on minor=3D130 (err=3D-16)
[   15.971910] i6300ESB timer: probe of 0000:00:04.0 failed with error -16
[   15.972696] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
[   15.973442] iTCO_vendor_support: vendor-support=3D0
[   15.974183] sc1200wdt: build 20020303
[   15.974654] sc1200wdt: io parameter must be specified
[   15.975343] sbc60xxwdt: I/O address 0x0443 already in use
[   15.975937] sbc8360: failed to register misc device
[   15.976480] sbc7240_wdt: I/O address 0x0443 already in use
[   15.983822] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 in=
itialising...
[   15.985771] smsc37b787_wdt: Unable to register miscdev on minor 130
[   15.986650] w83877f_wdt: I/O address 0x0443 already in use
[   15.987281] w83977f_wdt: driver v1.00
[   15.987690] w83977f_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[   15.988402] machzwd: MachZ ZF-Logic Watchdog driver initializing
[   15.993506] machzwd: no ZF-Logic found
[   15.993926] sbc_epx_c3: cannot register miscdev on minor=3D130 (err=3D-1=
6)
[   15.994881] Bluetooth: Virtual HCI driver ver 1.4
[   15.995523] Bluetooth: HCI UART driver ver 2.2
[   15.996010] Bluetooth: HCI H4 protocol initialized
[   15.996537] Bluetooth: HCIATH3K protocol initialized
[   15.997101] Bluetooth: HCI Three-wire UART (H5) protocol initialized
[   15.997785] Bluetooth: Generic Bluetooth SDIO driver ver 0.1
[   15.998466] Modular ISDN core version 1.1.29
[   16.003690] NET: Registered protocol family 34
[   16.004192] DSP module 2.0
[   16.004499] mISDN_dsp: DSP clocks every 80 samples. This equals 3 jiffie=
s.
[   16.013944] mISDN: HFC-multi driver 2.03
[   16.014519] Sedlbauer Speedfax+ Driver Rev. 2.0
[   16.015104] Infineon ISDN Driver Rev. 1.0
[   16.015643] Winbond W6692 PCI driver Rev. 2.0
[   16.016230] mISDNipac module version 2.0
[   16.016668] mISDN: ISAR driver Rev. 2.1
[   16.017129] gigaset: Driver for Gigaset 307x (debug build)
[   16.017722] gigaset: no ISDN subsystem interface
[   16.025287] platform eisa.0: Probing EISA bus 0
[   16.025877] platform eisa.0: EISA: Cannot allocate resource for mainboard
[   16.027032] sdhci: Secure Digital Host Controller Interface driver
[   16.033885] sdhci: Copyright(c) Pierre Ossman
[   16.044782] leds_ss4200: no LED devices found
[   16.047203] Driver for HIFN 795x crypto accelerator chip has been succes=
sfully registered.
[   16.048255] cs5535-clockevt: Could not allocate MFGPT timer
[   16.049067] hidraw: raw HID events driver (C) Jiri Kosina
[   16.050584] hv_vmbus: registering driver hid_hyperv
[   16.055679] compal_laptop: Motherboard not recognized (You could try the=
 module's force-parameter)
[   16.056892] dell_wmi: No known WMI GUID found
[   16.057450] dell_wmi_aio: No known WMI GUID found
[   16.058201] acerhdf: Acer Aspire One Fan driver, v.0.5.26
[   16.058869] acerhdf: unknown (unsupported) BIOS version Bochs/Bochs/Boch=
s, please report, aborting!
[   16.060324] hdaps: supported laptop not found!
[   16.060951] hdaps: driver init failed (ret=3D-19)!
[   16.073544] FUJ02B1: call_fext_func: FUNC interface is not present
[   16.074435] fujitsu_laptop: driver 0.6.0 successfully loaded
[   16.075239] fujitsu_tablet: Unknown (using defaults)
[   16.076951] intel_oaktrail: Platform not recognized (You could try the m=
odule's force-parameter)
[   16.078505] hv_vmbus: registering driver hv_balloon
[   16.142739] intel_rapl: RAPL domain package detection failed
[   16.152910] intel_rapl: RAPL domain core detection failed
[   16.153639] intel_rapl: RAPL domain uncore detection failed
[   16.154296] intel_rapl: RAPL domain dram detection failed
[   16.154916] intel_rapl: no valid rapl domains found in package 0
[   16.155752] NET: Registered protocol family 17
[   16.156452] NET: Registered protocol family 15
[   16.157352] NET: Registered protocol family 4
[   16.157954] NET: Registered protocol family 9
[   16.158478] X25: Linux Version 0.2
[   16.158929] NET: Registered protocol family 3
[   16.159481] can: controller area network core (rev 20120528 abi 9)
[   16.162711] NET: Registered protocol family 29
[   16.163482] can: raw protocol (rev 20120528)
[   16.164104] can: broadcast manager protocol (rev 20120528 t)
[   16.164891] can: netlink gateway (rev 20130117) max_hops=3D1
[   16.167297] IrCOMM protocol (Dag Brattli)
[   16.183401] Bluetooth: RFCOMM TTY layer initialized
[   16.183967] Bluetooth: RFCOMM socket layer initialized
[   16.184563] Bluetooth: RFCOMM ver 1.11
[   16.185000] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   16.185587] Bluetooth: BNEP socket layer initialized
[   16.186176] lec:lane_module_init: lec.c: initialized
[   16.186759] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet=
 Project Team
[   16.188116] DECnet: Routing cache hash table of 256 buckets, 11Kbytes
[   16.188857] NET: Registered protocol family 12
[   16.189406] NET: Registered protocol family 35
[   16.189979] 8021q: 802.1Q VLAN Support v1.8
[   16.190761] 9pnet: Installing 9P2000 support
[   16.191392] NET: Registered protocol family 36
[   16.191924] openvswitch: Open vSwitch switching datapath
[   16.193038] NET: Registered protocol family 40
[   16.203650] mpls_gso: MPLS GSO support
[   16.205272]=20
[   16.205272] printing PIC contents
[   16.205834] ... PIC  IMR: ffff
[   16.206177] ... PIC  IRR: 1113
[   16.206517] ... PIC  ISR: 0000
[   16.206895] ... PIC ELCR: 0c00
[   16.207251] printing local APIC contents on CPU#0/0:
[   16.207777] ... APIC ID:      00000000 (0)
[   16.208224] ... APIC VERSION: 01050014
[   16.208622] ... APIC TASKPRI: 00000000 (00)
[   16.209064] ... APIC PROCPRI: 00000000
[   16.209471] ... APIC LDR: 01000000
[   16.209837] ... APIC DFR: ffffffff
[   16.210199] ... APIC SPIV: 000001ff
[   16.210199] ... APIC ISR field:
[   16.210199] 000000000000000000000000000000000000000000000000000000000000=
0000
[   16.210199] ... APIC TMR field:
[   16.210199] 000000000200000000000000000000000000000000000000000000000000=
0000
[   16.210199] ... APIC IRR field:
[   16.210199] 000000000000000000000000000000000000000000000000000000000000=
8000
[   16.210199] ... APIC ESR: 00000000
[   16.210199] ... APIC ICR: 000008fd
[   16.210199] ... APIC ICR2: 02000000
[   16.210199] ... APIC LVTT: 000400ef
[   16.210199] ... APIC LVTPC: 00010000
[   16.210199] ... APIC LVT0: 00010700
[   16.210199] ... APIC LVT1: 00000400
[   16.210199] ... APIC LVTERR: 000000fe
[   16.210199] ... APIC TMICT: 00000000
[   16.210199] ... APIC TMCCT: 00000000
[   16.210199] ... APIC TDCR: 00000000
[   16.210199]=20
[   16.228947] number of MP IRQ sources: 15.
[   16.229385] number of IO-APIC #0 registers: 24.
[   16.229862] testing the IO APIC.......................
[   16.230471] IO APIC #0......
[   16.230787] .... register #00: 00000000
[   16.231205] .......    : physical APIC id: 00
[   16.231665] .......    : Delivery Type: 0
[   16.232102] .......    : LTS          : 0
[   16.232550] .... register #01: 00170011
[   16.232963] .......     : max redirection entries: 17
[   16.243611] .......     : PRQ implemented: 0
[   16.244069] .......     : IO APIC version: 11
[   16.244540] .... register #02: 00000000
[   16.245016] .......     : arbitration: 00
[   16.245489] .... IRQ redirection table:
[   16.245918] 1    0    0   0   0    0    0    00
[   16.246417] 0    0    0   0   0    1    1    31
[   16.246940] 0    0    0   0   0    1    1    30
[   16.247442] 1    0    0   0   0    1    1    33
[   16.247932] 1    0    0   0   0    1    1    34
[   16.248428] 1    1    0   0   0    1    1    35
[   16.248916] 1    0    0   0   0    1    1    36
[   16.249412] 0    0    0   0   0    1    1    37
[   16.249899] 0    0    0   0   0    1    1    38
[   16.250439] 0    1    0   0   0    1    1    39
[   16.250930] 1    1    0   0   0    1    1    3A
[   16.251427] 1    1    0   0   0    1    1    3B
[   16.251917] 0    0    0   0   0    1    1    3C
[   16.252415] 1    0    0   0   0    1    1    3D
[   16.252929] 0    0    0   0   0    1    1    3E
[   16.263562] 0    0    0   0   0    1    1    3F
[   16.264062] 1    0    0   0   0    0    0    00
[   16.264562] 1    0    0   0   0    0    0    00
[   16.265076] 1    0    0   0   0    0    0    00
[   16.265576] 1    0    0   0   0    0    0    00
[   16.266066] 1    0    0   0   0    0    0    00
[   16.266568] 1    0    0   0   0    0    0    00
[   16.267096] 1    0    0   0   0    0    0    00
[   16.267599] 1    0    0   0   0    0    0    00
[   16.268076] IRQ to pin mappings:
[   16.268437] IRQ0 -> 0:2
[   16.268746] IRQ1 -> 0:1
[   16.269053] IRQ3 -> 0:3
[   16.269366] IRQ4 -> 0:4
[   16.269674] IRQ5 -> 0:5
[   16.269980] IRQ6 -> 0:6
[   16.270348] IRQ7 -> 0:7
[   16.270653] IRQ8 -> 0:8
[   16.270956] IRQ9 -> 0:9
[   16.271268] IRQ10 -> 0:10
[   16.271591] IRQ11 -> 0:11
[   16.271912] IRQ12 -> 0:12
[   16.272244] IRQ13 -> 0:13
[   16.272583] IRQ14 -> 0:14
[   16.273006] IRQ15 -> 0:15
[   16.282907] .................................... done.
[   16.284356] Using IPI No-Shortcut mode
[   16.285446] registered taskstats version 1
[   16.299229] Btrfs loaded, debug=3Don
[   16.305239] cryptomgr_probe (145) used greatest stack depth: 6652 bytes =
left
[   16.306097] Key type trusted registered
[   16.306582] ima: No TPM chip found, activating TPM-bypass!
[   16.314303] console [netcon0] enabled
[   16.314751] netconsole: network logging started
[   16.315403] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   16.316102] EDD information not available.
[   16.316788] Unregister pv shared memory for cpu 0
[   16.377762] CPU 0 offline: Remove Rx thread
[   16.378624] CPU 0 is now offline
[   16.384137] Freeing unused kernel memory: 2356K (83850000 - 83a9d000)
[   16.411394] random: init urandom read with 11 bits of entropy available
[   16.448782] hostname (150) used greatest stack depth: 6600 bytes left
[   16.503488] hwclock (152) used greatest stack depth: 6364 bytes left
[   16.507349] plymouthd (151) used greatest stack depth: 6292 bytes left
[   16.697360] chmod (170) used greatest stack depth: 6036 bytes left
[   17.346850] BUG: using smp_processor_id() in preemptible [00000000] code=
: kworker/0:1/36
[   17.347917] caller is debug_smp_processor_id+0x12/0x20
[   17.348597] CPU: 1 PID: 36 Comm: kworker/0:1 Not tainted 3.16.0-rc6-0025=
1-g6e0a6b1 #7
[   17.349662] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   17.350603] Workqueue: events vmstat_update
[   17.351211]  00000001 914e9e4c 828277f8 00000000 00000001 8305dad3 914e9=
e7c 8176b314
[   17.352422]  8306afe0 83069fba 8305dad3 00000000 914e1924 00000024 83069=
fba 83a99220
[   17.353626]  00000129 914c47e0 914e9e84 8176b342 914e9e98 811aa410 00000=
000 9237d200
[   17.354767] Call Trace:
[   17.355104]  [<828277f8>] dump_stack+0x7f/0xf3
[   17.355734]  [<8176b314>] check_preemption_disabled+0x164/0x180
[   17.356555]  [<8176b342>] debug_smp_processor_id+0x12/0x20
[   17.357404]  [<811aa410>] vmstat_update+0x40/0x80
[   17.358065]  [<8109bad9>] process_one_work+0x3a9/0xa40
[   17.358766]  [<8109bf8c>] ? process_one_work+0x85c/0xa40
[   17.359454]  [<8109c19d>] ? worker_thread+0x2d/0xb40
[   17.360141]  [<8109c72c>] worker_thread+0x5bc/0xb40
[   17.360782]  [<8109c170>] ? process_one_work+0xa40/0xa40
[   17.361473]  [<810a8932>] kthread+0xe2/0xf0
[   17.362036]  [<8109c170>] ? process_one_work+0xa40/0xa40
[   17.362784]  [<810b0000>] ? SyS_setns+0x90/0x160
[   17.363492]  [<82853c01>] ret_from_kernel_thread+0x21/0x30
[   17.364254]  [<810a8850>] ? insert_kthread_work+0x100/0x100

Elapsed time: 25
qemu-system-x86_64 -enable-kvm -cpu Haswell,+smep,+smap -kernel /kernel/i38=
6-randconfig-ib0-07271715/6e0a6b18b63e2c0a45ff47ab633dd6f3ad417453/vmlinuz-=
3.16.0-rc6-00251-g6e0a6b1 -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,=
115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeo=
ut=3D100 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramdi=
sk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0=
 rw link=3D/kbuild-tests/run-queue/kvm/i386-randconfig-ib0-07271715/next:ma=
ster:6e0a6b18b63e2c0a45ff47ab633dd6f3ad417453:bisect-linux5/.vmlinuz-6e0a6b=
18b63e2c0a45ff47ab633dd6f3ad417453-20140728053554-192-kbuild branch=3Dnext/=
master BOOT_IMAGE=3D/kernel/i386-randconfig-ib0-07271715/6e0a6b18b63e2c0a45=
ff47ab633dd6f3ad417453/vmlinuz-3.16.0-rc6-00251-g6e0a6b1 drbd.minor_count=
=3D8'  -initrd /kernel-tests/initrd/quantal-core-i386.cgz -m 320 -smp 2 -ne=
t nic,vlan=3D1,model=3De1000 -net user,vlan=3D1 -boot order=3Dnc -no-reboot=
 -watchdog i6300esb -rtc base=3Dlocaltime -pidfile /dev/shm/kboot/pid-quant=
al-kbuild-1 -serial file:/dev/shm/kboot/serial-quantal-kbuild-1 -daemonize =
-display none -monitor null=20

--XvKFcGCOAo53UbWW
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="i386-randconfig-ib0-07271715-5a7439efd1c5c416f768fc550048ca130cf4bf99-BUG:-using----in-preemptible----code:-110167.log"
Content-Transfer-Encoding: base64

SEVBRCBpcyBub3cgYXQgNWE3NDM5ZS4uLiBBZGQgbGludXgtbmV4dCBzcGVjaWZpYyBmaWxl
cyBmb3IgMjAxNDA3MjUKZ2l0IGNoZWNrb3V0IDlhM2M0MTQ1YWYzMjEyNWM1ZWUzOWMwMjcy
NjYyYjQ3MzA3YTgzMjMKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYt
cmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvbmV4dDptYXN0ZXI6OWEzYzQxNDVhZjMyMTI1YzVl
ZTM5YzAyNzI2NjJiNDczMDdhODMyMzpiaXNlY3QtbGludXg1CgoyMDE0LTA3LTI3LTE3OjMw
OjMzIDlhM2M0MTQ1YWYzMjEyNWM1ZWUzOWMwMjcyNjYyYjQ3MzA3YTgzMjMgY29tcGlsaW5n
ClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1y
YW5kY29uZmlnLWliMC0wNzI3MTcxNS05YTNjNDE0NWFmMzIxMjVjNWVlMzljMDI3MjY2MmI0
NzMwN2E4MzIzCkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIwLTA3MjcxNzE1LzlhM2M0MTQ1YWYzMjEyNWM1ZWUzOWMwMjcyNjYyYjQ3MzA3YTgzMjMK
d2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kz
ODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUtOWEzYzQxNDVhZjMyMTI1YzVlZTM5YzAyNzI2
NjJiNDczMDdhODMyMwp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMv
YnVpbGQtcXVldWUvbGtwLWhzeDAxLWNvbnN1bWVyL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcy
NzE3MTUtOWEzYzQxNDVhZjMyMTI1YzVlZTM5YzAyNzI2NjJiNDczMDdhODMyMwprZXJuZWw6
IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS85YTNjNDE0NWFmMzIxMjVj
NWVlMzljMDI3MjY2MmI0NzMwN2E4MzIzL3ZtbGludXotMy4xNi4wLXJjNgoKMjAxNC0wNy0y
Ny0xNzozMzozNiBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4JMjMJMzAgU1VDQ0VTUwoKYmlz
ZWN0OiBnb29kIGNvbW1pdCA5YTNjNDE0NWFmMzIxMjVjNWVlMzljMDI3MjY2MmI0NzMwN2E4
MzIzCmdpdCBiaXNlY3Qgc3RhcnQgNWE3NDM5ZWZkMWM1YzQxNmY3NjhmYzU1MDA0OGNhMTMw
Y2Y0YmY5OSA5YTNjNDE0NWFmMzIxMjVjNWVlMzljMDI3MjY2MmI0NzMwN2E4MzIzIC0tCi9j
L2tlcm5lbC10ZXN0cy9saW5lYXItYmlzZWN0OiBbIi1iIiwgIjVhNzQzOWVmZDFjNWM0MTZm
NzY4ZmM1NTAwNDhjYTEzMGNmNGJmOTkiLCAiLWciLCAiOWEzYzQxNDVhZjMyMTI1YzVlZTM5
YzAyNzI2NjJiNDczMDdhODMyMyIsICIvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9v
dC1mYWlsdXJlLnNoIiwgIi9jL2Jvb3QtYmlzZWN0L2xpbnV4NS9vYmotYmlzZWN0Il0KQmlz
ZWN0aW5nOiA4OTAzIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hs
eSAxNCBzdGVwcykKWzM4ZWZhZDlhZjgxZDE0NWYwN2Y1OTJmNjE4Yzc2Yzc4Y2YxNDFlNWJd
IE1lcmdlIHJlbW90ZS10cmFja2luZyBicmFuY2ggJ2xpYmF0YS9mb3ItbmV4dCcKcnVubmlu
ZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3Qt
YmlzZWN0L2xpbnV4NS9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVl
L2t2bS9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1L25leHQ6bWFzdGVyOjM4ZWZhZDlh
ZjgxZDE0NWYwN2Y1OTJmNjE4Yzc2Yzc4Y2YxNDFlNWI6YmlzZWN0LWxpbnV4NQoKMjAxNC0w
Ny0yNy0xNzozNjo1NiAzOGVmYWQ5YWY4MWQxNDVmMDdmNTkyZjYxOGM3NmM3OGNmMTQxZTVi
IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1
ZXVlL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUtMzhlZmFkOWFmODFkMTQ1ZjA3ZjU5
MmY2MThjNzZjNzhjZjE0MWU1YgpDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1y
YW5kY29uZmlnLWliMC0wNzI3MTcxNS8zOGVmYWQ5YWY4MWQxNDVmMDdmNTkyZjYxOGM3NmM3
OGNmMTQxZTViCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWls
ZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LTM4ZWZhZDlhZjgxZDE0NWYw
N2Y1OTJmNjE4Yzc2Yzc4Y2YxNDFlNWIKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZp
Zy1pYjAtMDcyNzE3MTUvMzhlZmFkOWFmODFkMTQ1ZjA3ZjU5MmY2MThjNzZjNzhjZjE0MWU1
Yi92bWxpbnV6LTMuMTYuMC1yYzYtMDIxNjQtZzM4ZWZhZDkKCjIwMTQtMDctMjctMTc6Mzg6
NTYgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLi4uCTE5CTMwIFNVQ0NFU1MKCkJpc2VjdGluZzog
NjczOCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMTMgc3Rl
cHMpCls3ZWQ4YWNjYmUxZDA2MWUxZGZlNGNlN2E4NjgxNDk1NTk1ZWJlMWRhXSBuZXh0LTIw
MTQwNzI0L3RpcApydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZh
aWx1cmUuc2ggL2MvYm9vdC1iaXNlY3QvbGludXg1L29iai1iaXNlY3QKbHMgLWEgL2tidWls
ZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvbmV4
dDptYXN0ZXI6N2VkOGFjY2JlMWQwNjFlMWRmZTRjZTdhODY4MTQ5NTU5NWViZTFkYTpiaXNl
Y3QtbGludXg1CgoyMDE0LTA3LTI3LTE3OjQzOjA1IDdlZDhhY2NiZTFkMDYxZTFkZmU0Y2U3
YTg2ODE0OTU1OTVlYmUxZGEgY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVp
bGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS03ZWQ4
YWNjYmUxZDA2MWUxZGZlNGNlN2E4NjgxNDk1NTk1ZWJlMWRhCkNoZWNrIGZvciBrZXJuZWwg
aW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LzdlZDhhY2NiZTFkMDYx
ZTFkZmU0Y2U3YTg2ODE0OTU1OTVlYmUxZGEKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAv
a2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUt
N2VkOGFjY2JlMWQwNjFlMWRmZTRjZTdhODY4MTQ5NTU5NWViZTFkYQprZXJuZWw6IC9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS83ZWQ4YWNjYmUxZDA2MWUxZGZlNGNl
N2E4NjgxNDk1NTk1ZWJlMWRhL3ZtbGludXotMy4xNi4wLXJjNi0wNTM3My1nN2VkOGFjYwoK
MjAxNC0wNy0yNy0xNzo0NTowNSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLgkyMQkzMCBTVUND
RVNTCgpCaXNlY3Rpbmc6IDM1MjkgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlz
IChyb3VnaGx5IDEyIHN0ZXBzKQpbN2QzY2UwNDkzMzQ3YzAxNzZiMzdkODc3YmUxYmMyMjA0
YzIzMTRiNF0gTWVyZ2UgcmVtb3RlLXRyYWNraW5nIGJyYW5jaCAnc3RhZ2luZy9zdGFnaW5n
LW5leHQnCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVy
ZS5zaCAvYy9ib290LWJpc2VjdC9saW51eDUvb2JqLWJpc2VjdApscyAtYSAva2J1aWxkLXRl
c3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9uZXh0Om1h
c3Rlcjo3ZDNjZTA0OTMzNDdjMDE3NmIzN2Q4NzdiZTFiYzIyMDRjMjMxNGI0OmJpc2VjdC1s
aW51eDUKCjIwMTQtMDctMjctMTc6NDc6MDcgN2QzY2UwNDkzMzQ3YzAxNzZiMzdkODc3YmUx
YmMyMjA0YzIzMTRiNCBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10
ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LTdkM2NlMDQ5
MzM0N2MwMTc2YjM3ZDg3N2JlMWJjMjIwNGMyMzE0YjQKQ2hlY2sgZm9yIGtlcm5lbCBpbiAv
a2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvN2QzY2UwNDkzMzQ3YzAxNzZi
MzdkODc3YmUxYmMyMjA0YzIzMTRiNAp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVp
bGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS03ZDNj
ZTA0OTMzNDdjMDE3NmIzN2Q4NzdiZTFiYzIyMDRjMjMxNGI0Cmtlcm5lbDogL2tlcm5lbC9p
Mzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LzdkM2NlMDQ5MzM0N2MwMTc2YjM3ZDg3N2Jl
MWJjMjIwNGMyMzE0YjQvdm1saW51ei0zLjE2LjAtcmM2LTA3OTE3LWc3ZDNjZTA0CgoyMDE0
LTA3LTI3LTE3OjQ5OjA3IGRldGVjdGluZyBib290IHN0YXRlIC4uLgkzMCBTVUNDRVNTCgpC
aXNlY3Rpbmc6IDk4NSByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdo
bHkgMTAgc3RlcHMpCls1NTBjNWRhZWM0ZjM0M2ZmYWYxYTFlMDY5ZTFmNDcyNzVlMTJiMzY5
XSBNZXJnZSByZW1vdGUtdHJhY2tpbmcgYnJhbmNoICdrdGVzdC9mb3ItbmV4dCcKcnVubmlu
ZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3Qt
YmlzZWN0L2xpbnV4NS9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVl
L2t2bS9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1L25leHQ6bWFzdGVyOjU1MGM1ZGFl
YzRmMzQzZmZhZjFhMWUwNjllMWY0NzI3NWUxMmIzNjk6YmlzZWN0LWxpbnV4NQoKMjAxNC0w
Ny0yNy0xNzo1MToyOSA1NTBjNWRhZWM0ZjM0M2ZmYWYxYTFlMDY5ZTFmNDcyNzVlMTJiMzY5
IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1
ZXVlL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUtNTUwYzVkYWVjNGYzNDNmZmFmMWEx
ZTA2OWUxZjQ3Mjc1ZTEyYjM2OQpDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1y
YW5kY29uZmlnLWliMC0wNzI3MTcxNS81NTBjNWRhZWM0ZjM0M2ZmYWYxYTFlMDY5ZTFmNDcy
NzVlMTJiMzY5CndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWls
ZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LTU1MGM1ZGFlYzRmMzQzZmZh
ZjFhMWUwNjllMWY0NzI3NWUxMmIzNjkKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1
aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1oc3gwMS1jb25zdW1lci9pMzg2LXJhbmRjb25m
aWctaWIwLTA3MjcxNzE1LTU1MGM1ZGFlYzRmMzQzZmZhZjFhMWUwNjllMWY0NzI3NWUxMmIz
NjkKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvNTUwYzVk
YWVjNGYzNDNmZmFmMWExZTA2OWUxZjQ3Mjc1ZTEyYjM2OS92bWxpbnV6LTMuMTYuMC1yYzYt
MDgyODItZzU1MGM1ZGFlCgoyMDE0LTA3LTI3LTE3OjU0OjI5IGRldGVjdGluZyBib290IHN0
YXRlIC4JMzAgU1VDQ0VTUwoKQmlzZWN0aW5nOiA2MjAgcmV2aXNpb25zIGxlZnQgdG8gdGVz
dCBhZnRlciB0aGlzIChyb3VnaGx5IDEwIHN0ZXBzKQpbZGQ3MzE0YmVhZGVkNTIzYWZmZjg0
NDRmYThkNDcxNDQ2ZmIyNzE3Ml0gTWVyZ2UgYnJhbmNoICdyZC1kb2NzL21hc3RlcicKcnVu
bmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jv
b3QtYmlzZWN0L2xpbnV4NS9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1
ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1L25leHQ6bWFzdGVyOmRkNzMx
NGJlYWRlZDUyM2FmZmY4NDQ0ZmE4ZDQ3MTQ0NmZiMjcxNzI6YmlzZWN0LWxpbnV4NQoKMjAx
NC0wNy0yNy0xNzo1NTozMSBkZDczMTRiZWFkZWQ1MjNhZmZmODQ0NGZhOGQ0NzE0NDZmYjI3
MTcyIGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxk
LXF1ZXVlL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUtZGQ3MzE0YmVhZGVkNTIzYWZm
Zjg0NDRmYThkNDcxNDQ2ZmIyNzE3MgpDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4
Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9kZDczMTRiZWFkZWQ1MjNhZmZmODQ0NGZhOGQ0
NzE0NDZmYjI3MTcyCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9i
dWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LWRkNzMxNGJlYWRlZDUy
M2FmZmY4NDQ0ZmE4ZDQ3MTQ0NmZiMjcxNzIKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAv
a2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2pha2V0b3duLWNvbnN1bWVyL2kzODYtcmFuZGNv
bmZpZy1pYjAtMDcyNzE3MTUtZGQ3MzE0YmVhZGVkNTIzYWZmZjg0NDRmYThkNDcxNDQ2ZmIy
NzE3MgprZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9kZDcz
MTRiZWFkZWQ1MjNhZmZmODQ0NGZhOGQ0NzE0NDZmYjI3MTcyL3ZtbGludXotMy4xNi4wLXJj
Ni0wODM0Mi1nZGQ3MzE0YgoKMjAxNC0wNy0yNy0xODowNjozMSBkZXRlY3RpbmcgYm9vdCBz
dGF0ZSAuLi4uLi4uCTEzCTIzCTMwIFNVQ0NFU1MKCkJpc2VjdGluZzogNTYxIHJldmlzaW9u
cyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAxMCBzdGVwcykKWzRkMTk1NDM0
N2MwMDBhZjNlZTM3NjYxZGMzYWNmZTBhZThmNTkzNDhdIFBLQ1MjNzogaW5jbHVkZSBsaW51
eC1lcnIuaCBmb3IgUFRSX0VSUiBhbmQgSVNfRVJSCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3Rz
L2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eDUvb2Jq
LWJpc2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29u
ZmlnLWliMC0wNzI3MTcxNS9uZXh0Om1hc3Rlcjo0ZDE5NTQzNDdjMDAwYWYzZWUzNzY2MWRj
M2FjZmUwYWU4ZjU5MzQ4OmJpc2VjdC1saW51eDUKCjIwMTQtMDctMjctMTg6MTE6MzggNGQx
OTU0MzQ3YzAwMGFmM2VlMzc2NjFkYzNhY2ZlMGFlOGY1OTM0OCBjb21waWxpbmcKUXVldWVk
IGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25m
aWctaWIwLTA3MjcxNzE1LTRkMTk1NDM0N2MwMDBhZjNlZTM3NjYxZGMzYWNmZTBhZThmNTkz
NDgKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcy
NzE3MTUvNGQxOTU0MzQ3YzAwMGFmM2VlMzc2NjFkYzNhY2ZlMGFlOGY1OTM0OAp3YWl0aW5n
IGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5k
Y29uZmlnLWliMC0wNzI3MTcxNS00ZDE5NTQzNDdjMDAwYWYzZWUzNzY2MWRjM2FjZmUwYWU4
ZjU5MzQ4Cmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LzRk
MTk1NDM0N2MwMDBhZjNlZTM3NjYxZGMzYWNmZTBhZThmNTkzNDgvdm1saW51ei0zLjE2LjAt
cmM2LTA4Mzg2LWc0ZDE5NTQzCgoyMDE0LTA3LTI3LTE4OjEzOjM4IGRldGVjdGluZyBib290
IHN0YXRlIC4uLgkzCTMwIFNVQ0NFU1MKCkJpc2VjdGluZzogNTE2IHJldmlzaW9ucyBsZWZ0
IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAxMCBzdGVwcykKWzU5MGRlYjE0NjdjY2Q1
Yjg5YTQwNDQxNTQyZWVkOTRhMjBmZGU5Y2RdIE1lcmdlIGJyYW5jaCAnYWtwbS1jdXJyZW50
L2N1cnJlbnQnCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFp
bHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eDUvb2JqLWJpc2VjdApscyAtYSAva2J1aWxk
LXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9uZXh0
Om1hc3Rlcjo1OTBkZWIxNDY3Y2NkNWI4OWE0MDQ0MTU0MmVlZDk0YTIwZmRlOWNkOmJpc2Vj
dC1saW51eDUKCjIwMTQtMDctMjctMTg6MTc6MTUgNTkwZGViMTQ2N2NjZDViODlhNDA0NDE1
NDJlZWQ5NGEyMGZkZTljZCBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWls
ZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LTU5MGRl
YjE0NjdjY2Q1Yjg5YTQwNDQxNTQyZWVkOTRhMjBmZGU5Y2QKQ2hlY2sgZm9yIGtlcm5lbCBp
biAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvNTkwZGViMTQ2N2NjZDVi
ODlhNDA0NDE1NDJlZWQ5NGEyMGZkZTljZAp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9r
YnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS01
OTBkZWIxNDY3Y2NkNWI4OWE0MDQ0MTU0MmVlZDk0YTIwZmRlOWNkCmtlcm5lbDogL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LzU5MGRlYjE0NjdjY2Q1Yjg5YTQwNDQx
NTQyZWVkOTRhMjBmZGU5Y2Qvdm1saW51ei0zLjE2LjAtcmM2LTA4ODA1LWc1OTBkZWIxCgoy
MDE0LTA3LTI3LTE4OjE5OjE1IGRldGVjdGluZyBib290IHN0YXRlIC4uCTIJMzAgU1VDQ0VT
UwoKQmlzZWN0aW5nOiA5NyByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJv
dWdobHkgNyBzdGVwcykKW2ExN2Y1ZWJjMWY2NjVmNzYzMDhkYmY4ZDJhMjk0YmRlY2EyODQ1
MTVdIE1lcmdlIGJyYW5jaCAnYWtwbS9tYXN0ZXInCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3Rz
L2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eDUvb2Jq
LWJpc2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29u
ZmlnLWliMC0wNzI3MTcxNS9uZXh0Om1hc3RlcjphMTdmNWViYzFmNjY1Zjc2MzA4ZGJmOGQy
YTI5NGJkZWNhMjg0NTE1OmJpc2VjdC1saW51eDUKCjIwMTQtMDctMjctMTg6MjM6MDEgYTE3
ZjVlYmMxZjY2NWY3NjMwOGRiZjhkMmEyOTRiZGVjYTI4NDUxNSBjb21waWxpbmcKUXVldWVk
IGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25m
aWctaWIwLTA3MjcxNzE1LWExN2Y1ZWJjMWY2NjVmNzYzMDhkYmY4ZDJhMjk0YmRlY2EyODQ1
MTUKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcy
NzE3MTUvYTE3ZjVlYmMxZjY2NWY3NjMwOGRiZjhkMmEyOTRiZGVjYTI4NDUxNQp3YWl0aW5n
IGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5k
Y29uZmlnLWliMC0wNzI3MTcxNS1hMTdmNWViYzFmNjY1Zjc2MzA4ZGJmOGQyYTI5NGJkZWNh
Mjg0NTE1CndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1x
dWV1ZS9sa3AtaHN4MDEtY29uc3VtZXIvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS1h
MTdmNWViYzFmNjY1Zjc2MzA4ZGJmOGQyYTI5NGJkZWNhMjg0NTE1Cmtlcm5lbDogL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1L2ExN2Y1ZWJjMWY2NjVmNzYzMDhkYmY4
ZDJhMjk0YmRlY2EyODQ1MTUvdm1saW51ei0zLjE2LjAtcmM2LTA4OTAxLWdhMTdmNWViCgoy
MDE0LTA3LTI3LTE4OjI2OjAxIGRldGVjdGluZyBib290IHN0YXRlIC4JMwk5CTMwIFNVQ0NF
U1MKCjVhNzQzOWVmZDFjNWM0MTZmNzY4ZmM1NTAwNDhjYTEzMGNmNGJmOTkgaXMgdGhlIGZp
cnN0IGJhZCBjb21taXQKY29tbWl0IDVhNzQzOWVmZDFjNWM0MTZmNzY4ZmM1NTAwNDhjYTEz
MGNmNGJmOTkKQXV0aG9yOiAgICAgU3RlcGhlbiBSb3Rod2VsbCA8c2ZyQGNhbmIuYXV1Zy5v
cmcuYXU+CkF1dGhvckRhdGU6IEZyaSBKdWwgMjUgMjA6MDg6MTMgMjAxNCArMTAwMApDb21t
aXQ6ICAgICBTdGVwaGVuIFJvdGh3ZWxsIDxzZnJAY2FuYi5hdXVnLm9yZy5hdT4KQ29tbWl0
RGF0ZTogRnJpIEp1bCAyNSAyMDowODoxMyAyMDE0ICsxMDAwCgogICAgQWRkIGxpbnV4LW5l
eHQgc3BlY2lmaWMgZmlsZXMgZm9yIDIwMTQwNzI1CiAgICAKICAgIFNpZ25lZC1vZmYtYnk6
IFN0ZXBoZW4gUm90aHdlbGwgPHNmckBjYW5iLmF1dWcub3JnLmF1PgoKIE5leHQvU0hBMXMg
ICAgICAgICAgICB8ICAgMjI3ICsKIE5leHQvVHJlZXMgICAgICAgICAgICB8ICAgMjI5ICsK
IE5leHQvbWVyZ2UubG9nICAgICAgICB8IDEyNzA3ICsrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKwogTmV4dC9xdWlsdC1pbXBvcnQubG9nIHwgICAg
IDQgKwogbG9jYWx2ZXJzaW9uLW5leHQgICAgIHwgICAgIDEgKwogNSBmaWxlcyBjaGFuZ2Vk
LCAxMzE2OCBpbnNlcnRpb25zKCspCkhFQUQgaXMgbm93IGF0IGExN2Y1ZWIuLi4gTWVyZ2Ug
YnJhbmNoICdha3BtL21hc3RlcicKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3Zt
L2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvbmV4dDptYXN0ZXI6YTE3ZjVlYmMxZjY2
NWY3NjMwOGRiZjhkMmEyOTRiZGVjYTI4NDUxNTpiaXNlY3QtbGludXg1CgoyMDE0LTA3LTI3
LTE4OjI4OjAyIGExN2Y1ZWJjMWY2NjVmNzYzMDhkYmY4ZDJhMjk0YmRlY2EyODQ1MTUgcmV1
c2UgL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1L2ExN2Y1ZWJjMWY2NjVm
NzYzMDhkYmY4ZDJhMjk0YmRlY2EyODQ1MTUvdm1saW51ei0zLjE2LjAtcmM2LTA4OTAxLWdh
MTdmNWViCgoyMDE0LTA3LTI3LTE4OjI4OjAyIGRldGVjdGluZyBib290IHN0YXRlIC4uLi4u
Li4uCTMzIFRFU1QgRkFJTFVSRQpbICAgMTYuMDg4Nzg1XSByYW5kb206IGluaXQgdXJhbmRv
bSByZWFkIHdpdGggMTAgYml0cyBvZiBlbnRyb3B5IGF2YWlsYWJsZQpbICAgMTYuMTU1MjUw
XSBod2Nsb2NrICgxNTUpIHVzZWQgZ3JlYXRlc3Qgc3RhY2sgZGVwdGg6IDU5ODggYnl0ZXMg
bGVmdAoKQlVHOiBrZXJuZWwgYm9vdCBoYW5nCkVsYXBzZWQgdGltZTogMzUKcWVtdS1zeXN0
ZW0teDg2XzY0IC1jcHUga3ZtNjQgLWVuYWJsZS1rdm0gLWtlcm5lbCAva2VybmVsL2kzODYt
cmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvYTE3ZjVlYmMxZjY2NWY3NjMwOGRiZjhkMmEyOTRi
ZGVjYTI4NDUxNS92bWxpbnV6LTMuMTYuMC1yYzYtMDg5MDEtZ2ExN2Y1ZWIgLWFwcGVuZCAn
aHVuZ190YXNrX3BhbmljPTEgZWFybHlwcmludGs9dHR5UzAsMTE1MjAwIGRlYnVnIGFwaWM9
ZGVidWcgc3lzcnFfYWx3YXlzX2VuYWJsZWQgcmN1cGRhdGUucmN1X2NwdV9zdGFsbF90aW1l
b3V0PTEwMCBwYW5pYz0xMCBzb2Z0bG9ja3VwX3BhbmljPTEgbm1pX3dhdGNoZG9nPXBhbmlj
ICBwcm9tcHRfcmFtZGlzaz0wIGNvbnNvbGU9dHR5UzAsMTE1MjAwIGNvbnNvbGU9dHR5MCB2
Z2E9bm9ybWFsICByb290PS9kZXYvcmFtMCBydyBsaW5rPS9rYnVpbGQtdGVzdHMvcnVuLXF1
ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1L25leHQ6bWFzdGVyOmExN2Y1
ZWJjMWY2NjVmNzYzMDhkYmY4ZDJhMjk0YmRlY2EyODQ1MTU6YmlzZWN0LWxpbnV4NS8udm1s
aW51ei1hMTdmNWViYzFmNjY1Zjc2MzA4ZGJmOGQyYTI5NGJkZWNhMjg0NTE1LTIwMTQwNzI3
MTgyODAyLTE4LWl2YjQzIGJyYW5jaD1uZXh0L21hc3RlciBCT09UX0lNQUdFPS9rZXJuZWwv
aTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9hMTdmNWViYzFmNjY1Zjc2MzA4ZGJmOGQy
YTI5NGJkZWNhMjg0NTE1L3ZtbGludXotMy4xNi4wLXJjNi0wODkwMS1nYTE3ZjVlYiBkcmJk
Lm1pbm9yX2NvdW50PTgnICAtaW5pdHJkIC9rZXJuZWwtdGVzdHMvaW5pdHJkL3F1YW50YWwt
Y29yZS1pMzg2LmNneiAtbSAzMjAgLXNtcCAyIC1uZXQgbmljLHZsYW49MSxtb2RlbD1lMTAw
MCAtbmV0IHVzZXIsdmxhbj0xIC1ib290IG9yZGVyPW5jIC1uby1yZWJvb3QgLXdhdGNoZG9n
IGk2MzAwZXNiIC1ydGMgYmFzZT1sb2NhbHRpbWUgLXBpZGZpbGUgL2Rldi9zaG0va2Jvb3Qv
cGlkLXF1YW50YWwtaXZiNDMtMzAgLXNlcmlhbCBmaWxlOi9kZXYvc2htL2tib290L3Nlcmlh
bC1xdWFudGFsLWl2YjQzLTMwIC1kYWVtb25pemUgLWRpc3BsYXkgbm9uZSAtbW9uaXRvciBu
dWxsIAova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvYTE3ZjVlYmMxZjY2
NWY3NjMwOGRiZjhkMmEyOTRiZGVjYTI4NDUxNS9kbWVzZy1xdWFudGFsLWtidWlsZC0yMjoy
MDE0MDcyNzE4MzAwOTppMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1OjMuMTYuMC1yYzYt
MDg5MDEtZ2ExN2Y1ZWI6OAozMDoxOjQgYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKG1sx
OzM1bTIwMTQtMDctMjcgMTg6MzI6MzMgUkVQRUFUIENPVU5UOiAzMDAgICMgL2MvYm9vdC1i
aXNlY3QvbGludXg1L29iai1iaXNlY3QvLnJlcGVhdBtbMG0KChtbMTszNW0yMDE0LTA3LTI3
IDE4OjMyOjMzIGJhZCBiaXNlY3QsIHJldHJ5IHdpdGggaW5jcmVhc2VkIHJlcGVhdCBjb3Vu
dCA5MBtbMG0KUHJldmlvdXMgSEVBRCBwb3NpdGlvbiB3YXMgYTE3ZjVlYi4uLiBNZXJnZSBi
cmFuY2ggJ2FrcG0vbWFzdGVyJwpIRUFEIGlzIG5vdyBhdCA1YTc0MzllLi4uIEFkZCBsaW51
eC1uZXh0IHNwZWNpZmljIGZpbGVzIGZvciAyMDE0MDcyNQpnaXQgY2hlY2tvdXQgOWEzYzQx
NDVhZjMyMTI1YzVlZTM5YzAyNzI2NjJiNDczMDdhODMyMwpscyAtYSAva2J1aWxkLXRlc3Rz
L3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9uZXh0Om1hc3Rl
cjo5YTNjNDE0NWFmMzIxMjVjNWVlMzljMDI3MjY2MmI0NzMwN2E4MzIzOmJpc2VjdC1saW51
eDUKCjIwMTQtMDctMjctMTg6MzU6MzQgOWEzYzQxNDVhZjMyMTI1YzVlZTM5YzAyNzI2NjJi
NDczMDdhODMyMyByZXVzZSAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUv
OWEzYzQxNDVhZjMyMTI1YzVlZTM5YzAyNzI2NjJiNDczMDdhODMyMy92bWxpbnV6LTMuMTYu
MC1yYzYKCjIwMTQtMDctMjctMTg6MzU6MzQgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLi4uLi4u
Li4JNDIJNTUJNTgJNjgJNzUJNzgJODkJOTEJOTYJMTExCTExNgkxMTcuLi4JMTIxCTEzMgkx
NDgJMTcwCTE3MwkxOTcJMjA0CTIwNwkyMjgJMjQxCTI0Mi4JMjQzCTI0NC4JMjU5CTI2MC4u
LgkyODEJMjkxLgkzMDAgU1VDQ0VTUwoKYmlzZWN0OiBnb29kIGNvbW1pdCA5YTNjNDE0NWFm
MzIxMjVjNWVlMzljMDI3MjY2MmI0NzMwN2E4MzIzCmdpdCBiaXNlY3Qgc3RhcnQgNWE3NDM5
ZWZkMWM1YzQxNmY3NjhmYzU1MDA0OGNhMTMwY2Y0YmY5OSA5YTNjNDE0NWFmMzIxMjVjNWVl
MzljMDI3MjY2MmI0NzMwN2E4MzIzIC0tCi9jL2tlcm5lbC10ZXN0cy9saW5lYXItYmlzZWN0
OiBbIi1iIiwgIjVhNzQzOWVmZDFjNWM0MTZmNzY4ZmM1NTAwNDhjYTEzMGNmNGJmOTkiLCAi
LWciLCAiOWEzYzQxNDVhZjMyMTI1YzVlZTM5YzAyNzI2NjJiNDczMDdhODMyMyIsICIvYy9r
ZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIiwgIi9jL2Jvb3QtYmlz
ZWN0L2xpbnV4NS9vYmotYmlzZWN0Il0KQmlzZWN0aW5nOiA4OTAzIHJldmlzaW9ucyBsZWZ0
IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAxNCBzdGVwcykKWzM4ZWZhZDlhZjgxZDE0
NWYwN2Y1OTJmNjE4Yzc2Yzc4Y2YxNDFlNWJdIE1lcmdlIHJlbW90ZS10cmFja2luZyBicmFu
Y2ggJ2xpYmF0YS9mb3ItbmV4dCcKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRl
c3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0L2xpbnV4NS9vYmotYmlzZWN0Cmxz
IC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaWIwLTA3
MjcxNzE1L25leHQ6bWFzdGVyOjM4ZWZhZDlhZjgxZDE0NWYwN2Y1OTJmNjE4Yzc2Yzc4Y2Yx
NDFlNWI6YmlzZWN0LWxpbnV4NQoKMjAxNC0wNy0yNy0xOTowMDoyNSAzOGVmYWQ5YWY4MWQx
NDVmMDdmNTkyZjYxOGM3NmM3OGNmMTQxZTViIHJldXNlIC9rZXJuZWwvaTM4Ni1yYW5kY29u
ZmlnLWliMC0wNzI3MTcxNS8zOGVmYWQ5YWY4MWQxNDVmMDdmNTkyZjYxOGM3NmM3OGNmMTQx
ZTViL3ZtbGludXotMy4xNi4wLXJjNi0wMjE2NC1nMzhlZmFkOQoKMjAxNC0wNy0yNy0xOTow
MDoyNSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4uLgkzMQk2OQk5NAk5NgkxMjIJMTI5CTE0
OQkxOTgJMjA3CTI1MAkyNTYJMjg1CTMwMCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDY3MzggcmV2
aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDEzIHN0ZXBzKQpbN2Vk
OGFjY2JlMWQwNjFlMWRmZTRjZTdhODY4MTQ5NTU5NWViZTFkYV0gbmV4dC0yMDE0MDcyNC90
aXAKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNo
IC9jL2Jvb3QtYmlzZWN0L2xpbnV4NS9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMv
cnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1L25leHQ6bWFzdGVy
OjdlZDhhY2NiZTFkMDYxZTFkZmU0Y2U3YTg2ODE0OTU1OTVlYmUxZGE6YmlzZWN0LWxpbnV4
NQoKMjAxNC0wNy0yNy0xOToxMjo0NCA3ZWQ4YWNjYmUxZDA2MWUxZGZlNGNlN2E4NjgxNDk1
NTk1ZWJlMWRhIHJldXNlIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS83
ZWQ4YWNjYmUxZDA2MWUxZGZlNGNlN2E4NjgxNDk1NTk1ZWJlMWRhL3ZtbGludXotMy4xNi4w
LXJjNi0wNTM3My1nN2VkOGFjYwoKMjAxNC0wNy0yNy0xOToxMjo0NCBkZXRlY3RpbmcgYm9v
dCBzdGF0ZSAuLi4JMzYJNDkJNzMJODYJMTA4CTE3NQkyMDkJMjMxCTI5NQkzMDAgU1VDQ0VT
UwoKQmlzZWN0aW5nOiAzNTI5IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAo
cm91Z2hseSAxMiBzdGVwcykKWzdkM2NlMDQ5MzM0N2MwMTc2YjM3ZDg3N2JlMWJjMjIwNGMy
MzE0YjRdIE1lcmdlIHJlbW90ZS10cmFja2luZyBicmFuY2ggJ3N0YWdpbmcvc3RhZ2luZy1u
ZXh0JwpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUu
c2ggL2MvYm9vdC1iaXNlY3QvbGludXg1L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0
cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvbmV4dDptYXN0
ZXI6N2QzY2UwNDkzMzQ3YzAxNzZiMzdkODc3YmUxYmMyMjA0YzIzMTRiNDpiaXNlY3QtbGlu
dXg1CgoyMDE0LTA3LTI3LTE5OjIyOjE1IDdkM2NlMDQ5MzM0N2MwMTc2YjM3ZDg3N2JlMWJj
MjIwNGMyMzE0YjQgcmV1c2UgL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1
LzdkM2NlMDQ5MzM0N2MwMTc2YjM3ZDg3N2JlMWJjMjIwNGMyMzE0YjQvdm1saW51ei0zLjE2
LjAtcmM2LTA3OTE3LWc3ZDNjZTA0CgoyMDE0LTA3LTI3LTE5OjIyOjI5IGRldGVjdGluZyBi
b290IHN0YXRlIC4uCTQzCTEzNAkyMTAJMjUwCTMwMCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDk4
NSByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMTAgc3RlcHMp
Cls1NTBjNWRhZWM0ZjM0M2ZmYWYxYTFlMDY5ZTFmNDcyNzVlMTJiMzY5XSBNZXJnZSByZW1v
dGUtdHJhY2tpbmcgYnJhbmNoICdrdGVzdC9mb3ItbmV4dCcKcnVubmluZyAvYy9rZXJuZWwt
dGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0L2xpbnV4
NS9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJh
bmRjb25maWctaWIwLTA3MjcxNzE1L25leHQ6bWFzdGVyOjU1MGM1ZGFlYzRmMzQzZmZhZjFh
MWUwNjllMWY0NzI3NWUxMmIzNjk6YmlzZWN0LWxpbnV4NQoKMjAxNC0wNy0yNy0xOToyNjow
MiA1NTBjNWRhZWM0ZjM0M2ZmYWYxYTFlMDY5ZTFmNDcyNzVlMTJiMzY5IHJldXNlIC9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS81NTBjNWRhZWM0ZjM0M2ZmYWYxYTFl
MDY5ZTFmNDcyNzVlMTJiMzY5L3ZtbGludXotMy4xNi4wLXJjNi0wODI4Mi1nNTUwYzVkYWUK
CjIwMTQtMDctMjctMTk6MjY6MDIgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLi4JMTYzCTI5Nwkz
MDAgU1VDQ0VTUwoKQmlzZWN0aW5nOiA2MjAgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRl
ciB0aGlzIChyb3VnaGx5IDEwIHN0ZXBzKQpbZGQ3MzE0YmVhZGVkNTIzYWZmZjg0NDRmYThk
NDcxNDQ2ZmIyNzE3Ml0gTWVyZ2UgYnJhbmNoICdyZC1kb2NzL21hc3RlcicKcnVubmluZyAv
Yy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlz
ZWN0L2xpbnV4NS9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2
bS9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1L25leHQ6bWFzdGVyOmRkNzMxNGJlYWRl
ZDUyM2FmZmY4NDQ0ZmE4ZDQ3MTQ0NmZiMjcxNzI6YmlzZWN0LWxpbnV4NQoKMjAxNC0wNy0y
Ny0xOToyODo0NyBkZDczMTRiZWFkZWQ1MjNhZmZmODQ0NGZhOGQ0NzE0NDZmYjI3MTcyIHJl
dXNlIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9kZDczMTRiZWFkZWQ1
MjNhZmZmODQ0NGZhOGQ0NzE0NDZmYjI3MTcyL3ZtbGludXotMy4xNi4wLXJjNi0wODM0Mi1n
ZGQ3MzE0YgoKMjAxNC0wNy0yNy0xOToyODo0NyBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuCTU5
CTEwMAkxOTgJMjc4CTMwMCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDU2MSByZXZpc2lvbnMgbGVm
dCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMTAgc3RlcHMpCls0ZDE5NTQzNDdjMDAw
YWYzZWUzNzY2MWRjM2FjZmUwYWU4ZjU5MzQ4XSBQS0NTIzc6IGluY2x1ZGUgbGludXgtZXJy
LmggZm9yIFBUUl9FUlIgYW5kIElTX0VSUgpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNl
Y3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2MvYm9vdC1iaXNlY3QvbGludXg1L29iai1iaXNl
Y3QKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1p
YjAtMDcyNzE3MTUvbmV4dDptYXN0ZXI6NGQxOTU0MzQ3YzAwMGFmM2VlMzc2NjFkYzNhY2Zl
MGFlOGY1OTM0ODpiaXNlY3QtbGludXg1CgoyMDE0LTA3LTI3LTE5OjMzOjMyIDRkMTk1NDM0
N2MwMDBhZjNlZTM3NjYxZGMzYWNmZTBhZThmNTkzNDggcmV1c2UgL2tlcm5lbC9pMzg2LXJh
bmRjb25maWctaWIwLTA3MjcxNzE1LzRkMTk1NDM0N2MwMDBhZjNlZTM3NjYxZGMzYWNmZTBh
ZThmNTkzNDgvdm1saW51ei0zLjE2LjAtcmM2LTA4Mzg2LWc0ZDE5NTQzCgoyMDE0LTA3LTI3
LTE5OjMzOjUyIGRldGVjdGluZyBib290IHN0YXRlIC4uCTM0CTYzCTgwCTg1CTkzCTk4CTEw
MgkxMDYJMTE2CTExOQkxMjYJMTMzCTE1MgkxNjAJMTY3CTE3MQkxODQJMTkyCTIwMgkyMDgJ
MjE1CTIxOAkyMzMJMjM1CTIzOQkyNDUJMjUwCTI2MAkyNjMJMjY2CTI3NwkyODQJMjkxCTI5
NgkyOTgJMzAwIFNVQ0NFU1MKCkJpc2VjdGluZzogNTE2IHJldmlzaW9ucyBsZWZ0IHRvIHRl
c3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAxMCBzdGVwcykKWzU5MGRlYjE0NjdjY2Q1Yjg5YTQw
NDQxNTQyZWVkOTRhMjBmZGU5Y2RdIE1lcmdlIGJyYW5jaCAnYWtwbS1jdXJyZW50L2N1cnJl
bnQnCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5z
aCAvYy9ib290LWJpc2VjdC9saW51eDUvb2JqLWJpc2VjdApscyAtYSAva2J1aWxkLXRlc3Rz
L3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9uZXh0Om1hc3Rl
cjo1OTBkZWIxNDY3Y2NkNWI4OWE0MDQ0MTU0MmVlZDk0YTIwZmRlOWNkOmJpc2VjdC1saW51
eDUKCjIwMTQtMDctMjctMTk6NTM6MjggNTkwZGViMTQ2N2NjZDViODlhNDA0NDE1NDJlZWQ5
NGEyMGZkZTljZCByZXVzZSAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUv
NTkwZGViMTQ2N2NjZDViODlhNDA0NDE1NDJlZWQ5NGEyMGZkZTljZC92bWxpbnV6LTMuMTYu
MC1yYzYtMDg4MDUtZzU5MGRlYjEKCjIwMTQtMDctMjctMTk6NTM6MjggZGV0ZWN0aW5nIGJv
b3Qgc3RhdGUgLi4gVEVTVCBGQUlMVVJFClsgICAxNS4zODM5NDVdIHJhbmRvbTogaW5pdCB1
cmFuZG9tIHJlYWQgd2l0aCAxMSBiaXRzIG9mIGVudHJvcHkgYXZhaWxhYmxlClsgICAxNS40
MzQ3NjddIGh3Y2xvY2sgKDE2OCkgdXNlZCBncmVhdGVzdCBzdGFjayBkZXB0aDogNjM2NCBi
eXRlcyBsZWZ0ClsgICAxNS40NDAxMjNdIHBseW1vdXRoZCAoMTY2KSB1c2VkIGdyZWF0ZXN0
IHN0YWNrIGRlcHRoOiA2MjkyIGJ5dGVzIGxlZnQKWyAgIDE2LjM0MzQ0OF0gQlVHOiB1c2lu
ZyBzbXBfcHJvY2Vzc29yX2lkKCkgaW4gcHJlZW1wdGlibGUgWzAwMDAwMDAwXSBjb2RlOiBr
d29ya2VyLzA6MS8zNgpbICAgMTYuMzQ0MzQ5XSBjYWxsZXIgaXMgZGVidWdfc21wX3Byb2Nl
c3Nvcl9pZCsweDEyLzB4MjAKWyAgIDE2LjM0NDkyNl0gQ1BVOiAxIFBJRDogMzYgQ29tbTog
a3dvcmtlci8wOjEgTm90IHRhaW50ZWQgMy4xNi4wLXJjNi0wODgwNS1nNTkwZGViMSAjNwpb
ICAgMTYuMzQ1NzY3XSBIYXJkd2FyZSBuYW1lOiBCb2NocyBCb2NocywgQklPUyBCb2NocyAw
MS8wMS8yMDExClsgICAxNi4zNDYzOTNdIFdvcmtxdWV1ZTogZXZlbnRzIHZtc3RhdF91cGRh
dGUKWyAgIDE2LjM0NjkxNl0gIDAwMDAwMDAxIDkxNGZkZTQ0IDgyOTE5NjQ2IDAwMDAwMDAw
IDAwMDAwMDAxIDgzMTlkYzc5IDkxNGZkZTc0IDgxNzZjNTY0ClsgICAxNi4zNDc4OTldICA4
MzFhYjc0YyA4MzFhYTdhNyA4MzE5ZGM3OSAwMDAwMDAwMCA5MTRmMTkyNCAwMDAwMDAyNCA4
MzFhYTdhNyA4M2M0NDMyMApbICAgMTYuMzQ4ODc0XSAgMDAwMDAxMjkgOTE0ZGQ4YTAgOTE0
ZmRlN2MgODE3NmM1OTIgOTE0ZmRlOTAgODExYTkyMzAgMDAwMDAwMDAgOTIzNzkzMjAKWyAg
IDE2LjM0OTg0NF0gQ2FsbCBUcmFjZToKWyAgIDE2LjM1MDE3MF0gIFs8ODI5MTk2NDY+XSBk
dW1wX3N0YWNrKzB4N2YvMHhmMwpbICAgMTYuMzUwNjY4XSAgWzw4MTc2YzU2ND5dIGNoZWNr
X3ByZWVtcHRpb25fZGlzYWJsZWQrMHgxNjQvMHgxODAKWyAgIDE2LjM1MTMwNV0gIFs8ODE3
NmM1OTI+XSBkZWJ1Z19zbXBfcHJvY2Vzc29yX2lkKzB4MTIvMHgyMApbICAgMTYuMzUxOTAz
XSAgWzw4MTFhOTIzMD5dIHZtc3RhdF91cGRhdGUrMHg0MC8weDgwClsgICAxNi4zNTI0MzBd
ICBbPDgxMDk0YWZjPl0gcHJvY2Vzc19vbmVfd29yaysweDM2Yy8weDllMApbICAgMTYuMzUy
OTg0XSAgWzw4MTA5NGY3Zj5dID8gcHJvY2Vzc19vbmVfd29yaysweDdlZi8weDllMApbICAg
MTYuMzUzNjA1XSAgWzw4MTA5NTE5Yz5dID8gd29ya2VyX3RocmVhZCsweDJjLzB4OWQwClsg
ICAxNi4zNTQxNDldICBbPDgxMDk1NjQyPl0gd29ya2VyX3RocmVhZCsweDRkMi8weDlkMApb
ICAgMTYuMzU0Njg4XSAgWzw4MTA5NTE3MD5dID8gcHJvY2Vzc19vbmVfd29yaysweDllMC8w
eDllMApbICAgMTYuMzU1MjY0XSAgWzw4MTA5ZWExMj5dIGt0aHJlYWQrMHhlMi8weGYwClsg
ICAxNi4zNTU3MzJdICBbPDgxMDk1MTcwPl0gPyBwcm9jZXNzX29uZV93b3JrKzB4OWUwLzB4
OWUwClsgICAxNi4zNTYzMTFdICBbPDgxMGEwMDAwPl0gPyBjb3B5X25hbWVzcGFjZXMrMHgx
NTAvMHgyZjAKWyAgIDE2LjM1NjkzNF0gIFs8ODI5NDY3NjE+XSByZXRfZnJvbV9rZXJuZWxf
dGhyZWFkKzB4MjEvMHgzMApbICAgMTYuMzU3NTU0XSAgWzw4MTA5ZTkzMD5dID8gaW5zZXJ0
X2t0aHJlYWRfd29yaysweDEwMC8weDEwMAoKRWxhcHNlZCB0aW1lOiAyNQpxZW11LXN5c3Rl
bS14ODZfNjQgLWVuYWJsZS1rdm0gLWNwdSBIYXN3ZWxsLCtzbWVwLCtzbWFwIC1rZXJuZWwg
L2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LzU5MGRlYjE0NjdjY2Q1Yjg5
YTQwNDQxNTQyZWVkOTRhMjBmZGU5Y2Qvdm1saW51ei0zLjE2LjAtcmM2LTA4ODA1LWc1OTBk
ZWIxIC1hcHBlbmQgJ2h1bmdfdGFza19wYW5pYz0xIGVhcmx5cHJpbnRrPXR0eVMwLDExNTIw
MCBkZWJ1ZyBhcGljPWRlYnVnIHN5c3JxX2Fsd2F5c19lbmFibGVkIHJjdXBkYXRlLnJjdV9j
cHVfc3RhbGxfdGltZW91dD0xMDAgcGFuaWM9MTAgc29mdGxvY2t1cF9wYW5pYz0xIG5taV93
YXRjaGRvZz1wYW5pYyAgcHJvbXB0X3JhbWRpc2s9MCBjb25zb2xlPXR0eVMwLDExNTIwMCBj
b25zb2xlPXR0eTAgdmdhPW5vcm1hbCAgcm9vdD0vZGV2L3JhbTAgcncgbGluaz0va2J1aWxk
LXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9uZXh0
Om1hc3Rlcjo1OTBkZWIxNDY3Y2NkNWI4OWE0MDQ0MTU0MmVlZDk0YTIwZmRlOWNkOmJpc2Vj
dC1saW51eDUvLnZtbGludXotNTkwZGViMTQ2N2NjZDViODlhNDA0NDE1NDJlZWQ5NGEyMGZk
ZTljZC0yMDE0MDcyNzE5NTMyOC0xMC1rYnVpbGQgYnJhbmNoPW5leHQvbWFzdGVyIEJPT1Rf
SU1BR0U9L2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LzU5MGRlYjE0Njdj
Y2Q1Yjg5YTQwNDQxNTQyZWVkOTRhMjBmZGU5Y2Qvdm1saW51ei0zLjE2LjAtcmM2LTA4ODA1
LWc1OTBkZWIxIGRyYmQubWlub3JfY291bnQ9OCcgIC1pbml0cmQgL2tlcm5lbC10ZXN0cy9p
bml0cmQvcXVhbnRhbC1jb3JlLWkzODYuY2d6IC1tIDMyMCAtc21wIDIgLW5ldCBuaWMsdmxh
bj0xLG1vZGVsPWUxMDAwIC1uZXQgdXNlcix2bGFuPTEgLWJvb3Qgb3JkZXI9bmMgLW5vLXJl
Ym9vdCAtd2F0Y2hkb2cgaTYzMDBlc2IgLXJ0YyBiYXNlPWxvY2FsdGltZSAtcGlkZmlsZSAv
ZGV2L3NobS9rYm9vdC9waWQtcXVhbnRhbC1rYnVpbGQtMzAgLXNlcmlhbCBmaWxlOi9kZXYv
c2htL2tib290L3NlcmlhbC1xdWFudGFsLWtidWlsZC0zMCAtZGFlbW9uaXplIC1kaXNwbGF5
IG5vbmUgLW1vbml0b3IgbnVsbCAKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIwLTA3Mjcx
NzE1LzU5MGRlYjE0NjdjY2Q1Yjg5YTQwNDQxNTQyZWVkOTRhMjBmZGU5Y2QvZG1lc2ctcXVh
bnRhbC1rYnVpbGQtMzA6MjAxNDA3MjcxOTUyMDY6aTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3
MTcxNTozLjE2LjAtcmM2LTA4ODA1LWc1OTBkZWIxOjcKMzA6MToxIGFsbF9nb29kOmJhZDph
bGxfYmFkIGJvb3RzChtbMTszNW0yMDE0LTA3LTI3IDE5OjU0OjI5IFJFUEVBVCBDT1VOVDog
MzAwICAjIC9jL2Jvb3QtYmlzZWN0L2xpbnV4NS9vYmotYmlzZWN0Ly5yZXBlYXQbWzBtCgps
aW5lYXItYmlzZWN0OiBiYWQgYnJhbmNoIG1heSBiZSBicmFuY2ggJ2FrcG0tY3VycmVudC9j
dXJyZW50JwpsaW5lYXItYmlzZWN0OiBoYW5kbGUgb3ZlciB0byBnaXQgYmlzZWN0CmxpbmVh
ci1iaXNlY3Q6IGdpdCBiaXNlY3Qgc3RhcnQgNTkwZGViMTQ2N2NjZDViODlhNDA0NDE1NDJl
ZWQ5NGEyMGZkZTljZCA0ZDE5NTQzNDdjMDAwYWYzZWUzNzY2MWRjM2FjZmUwYWU4ZjU5MzQ4
IC0tClByZXZpb3VzIEhFQUQgcG9zaXRpb24gd2FzIDU5MGRlYjEuLi4gTWVyZ2UgYnJhbmNo
ICdha3BtLWN1cnJlbnQvY3VycmVudCcKSEVBRCBpcyBub3cgYXQgNTRhZjYxZC4uLiBNZXJn
ZSBicmFuY2ggJ2FrcG0tY3VycmVudC9jdXJyZW50JwpCaXNlY3Rpbmc6IDIwOSByZXZpc2lv
bnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgOCBzdGVwcykKW2E4NWUyZDEz
MDMzMWFhOTg4NWNiYmE3NGFlMWE2MDRkY2U3MDk0ODJdIGluY2x1ZGUvbGludXgva2VybmVs
Lmg6NzQ0OjI4OiBub3RlOiBpbiBleHBhbnNpb24gb2YgbWFjcm8gJ21pbicKbGluZWFyLWJp
c2VjdDogZ2l0IGJpc2VjdCBydW4gL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3Qt
ZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eDUvb2JqLWJpc2VjdApydW5uaW5nIC9j
L2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2MvYm9vdC1iaXNl
Y3QvbGludXg1L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3Zt
L2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvbmV4dDptYXN0ZXI6YTg1ZTJkMTMwMzMx
YWE5ODg1Y2JiYTc0YWUxYTYwNGRjZTcwOTQ4MjpiaXNlY3QtbGludXg1CgoyMDE0LTA3LTI3
LTE5OjU1OjEzIGE4NWUyZDEzMDMzMWFhOTg4NWNiYmE3NGFlMWE2MDRkY2U3MDk0ODIgY29t
cGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUv
aTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS1hODVlMmQxMzAzMzFhYTk4ODVjYmJhNzRh
ZTFhNjA0ZGNlNzA5NDgyCkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRj
b25maWctaWIwLTA3MjcxNzE1L2E4NWUyZDEzMDMzMWFhOTg4NWNiYmE3NGFlMWE2MDRkY2U3
MDk0ODIKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1
ZXVlL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUtYTg1ZTJkMTMwMzMxYWE5ODg1Y2Ji
YTc0YWUxYTYwNGRjZTcwOTQ4Mgp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQt
dGVzdHMvYnVpbGQtcXVldWUvbGtwLWhzeDAxLWNvbnN1bWVyL2kzODYtcmFuZGNvbmZpZy1p
YjAtMDcyNzE3MTUtYTg1ZTJkMTMwMzMxYWE5ODg1Y2JiYTc0YWUxYTYwNGRjZTcwOTQ4Mgpr
ZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9hODVlMmQxMzAz
MzFhYTk4ODVjYmJhNzRhZTFhNjA0ZGNlNzA5NDgyL3ZtbGludXotMy4xNi4wLXJjNi0wMDI4
My1nYTg1ZTJkMQoKMjAxNC0wNy0yNy0xOTo1ODoxMyBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAu
CTIJMwk2CTggVEVTVCBGQUlMVVJFClsgICAxNy41ODIwMjRdIHBseW1vdXRoZCAoMTUyKSB1
c2VkIGdyZWF0ZXN0IHN0YWNrIGRlcHRoOiA2MjkyIGJ5dGVzIGxlZnQKWyAgIDIwLjIyMzc5
MF0gY2hvd24gKDY2OSkgdXNlZCBncmVhdGVzdCBzdGFjayBkZXB0aDogNjEwNCBieXRlcyBs
ZWZ0CgpCVUc6IGtlcm5lbCBib290IGhhbmcKRWxhcHNlZCB0aW1lOiAzNQpxZW11LXN5c3Rl
bS14ODZfNjQgLWVuYWJsZS1rdm0gLWNwdSBIYXN3ZWxsLCtzbWVwLCtzbWFwIC1rZXJuZWwg
L2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1L2E4NWUyZDEzMDMzMWFhOTg4
NWNiYmE3NGFlMWE2MDRkY2U3MDk0ODIvdm1saW51ei0zLjE2LjAtcmM2LTAwMjgzLWdhODVl
MmQxIC1hcHBlbmQgJ2h1bmdfdGFza19wYW5pYz0xIGVhcmx5cHJpbnRrPXR0eVMwLDExNTIw
MCBkZWJ1ZyBhcGljPWRlYnVnIHN5c3JxX2Fsd2F5c19lbmFibGVkIHJjdXBkYXRlLnJjdV9j
cHVfc3RhbGxfdGltZW91dD0xMDAgcGFuaWM9MTAgc29mdGxvY2t1cF9wYW5pYz0xIG5taV93
YXRjaGRvZz1wYW5pYyAgcHJvbXB0X3JhbWRpc2s9MCBjb25zb2xlPXR0eVMwLDExNTIwMCBj
b25zb2xlPXR0eTAgdmdhPW5vcm1hbCAgcm9vdD0vZGV2L3JhbTAgcncgbGluaz0va2J1aWxk
LXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9uZXh0
Om1hc3RlcjphODVlMmQxMzAzMzFhYTk4ODVjYmJhNzRhZTFhNjA0ZGNlNzA5NDgyOmJpc2Vj
dC1saW51eDUvLnZtbGludXotYTg1ZTJkMTMwMzMxYWE5ODg1Y2JiYTc0YWUxYTYwNGRjZTcw
OTQ4Mi0yMDE0MDcyODAzNTgwNy0xMDIta2J1aWxkIGJyYW5jaD1uZXh0L21hc3RlciBCT09U
X0lNQUdFPS9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9hODVlMmQxMzAz
MzFhYTk4ODVjYmJhNzRhZTFhNjA0ZGNlNzA5NDgyL3ZtbGludXotMy4xNi4wLXJjNi0wMDI4
My1nYTg1ZTJkMSBkcmJkLm1pbm9yX2NvdW50PTgnICAtaW5pdHJkIC9rZXJuZWwtdGVzdHMv
aW5pdHJkL3F1YW50YWwtY29yZS1pMzg2LmNneiAtbSAzMjAgLXNtcCAyIC1uZXQgbmljLHZs
YW49MSxtb2RlbD1lMTAwMCAtbmV0IHVzZXIsdmxhbj0xIC1ib290IG9yZGVyPW5jIC1uby1y
ZWJvb3QgLXdhdGNoZG9nIGk2MzAwZXNiIC1ydGMgYmFzZT1sb2NhbHRpbWUgLXBpZGZpbGUg
L2Rldi9zaG0va2Jvb3QvcGlkLXF1YW50YWwta2J1aWxkLTI2IC1zZXJpYWwgZmlsZTovZGV2
L3NobS9rYm9vdC9zZXJpYWwtcXVhbnRhbC1rYnVpbGQtMjYgLWRhZW1vbml6ZSAtZGlzcGxh
eSBub25lIC1tb25pdG9yIG51bGwgCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3
MTcxNS9hODVlMmQxMzAzMzFhYTk4ODVjYmJhNzRhZTFhNjA0ZGNlNzA5NDgyL2RtZXNnLXF1
YW50YWwta2J1aWxkLTI4OjIwMTQwNzI3MTk1ODAzOmkzODYtcmFuZGNvbmZpZy1pYjAtMDcy
NzE3MTU6My4xNi4wLXJjNi0wMDI4My1nYTg1ZTJkMToxCjc6MToyIGFsbF9nb29kOmJhZDph
bGxfYmFkIGJvb3RzCgpCaXNlY3Rpbmc6IDEwNCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFm
dGVyIHRoaXMgKHJvdWdobHkgNyBzdGVwcykKWzRhYzI1NDMxYTQyNjUxNDU4ZWU4ZmUzMTM1
OGQ3MTRhYTE4ZWU5YWFdIG1tOiBtZW1jb250cm9sOiByZWFycmFuZ2UgY2hhcmdpbmcgZmFz
dCBwYXRoCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVy
ZS5zaCAvYy9ib290LWJpc2VjdC9saW51eDUvb2JqLWJpc2VjdApscyAtYSAva2J1aWxkLXRl
c3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9uZXh0Om1h
c3Rlcjo0YWMyNTQzMWE0MjY1MTQ1OGVlOGZlMzEzNThkNzE0YWExOGVlOWFhOmJpc2VjdC1s
aW51eDUKCjIwMTQtMDctMjctMjA6MDA6NDYgNGFjMjU0MzFhNDI2NTE0NThlZThmZTMxMzU4
ZDcxNGFhMThlZTlhYSBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10
ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LTRhYzI1NDMx
YTQyNjUxNDU4ZWU4ZmUzMTM1OGQ3MTRhYTE4ZWU5YWEKQ2hlY2sgZm9yIGtlcm5lbCBpbiAv
a2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvNGFjMjU0MzFhNDI2NTE0NThl
ZThmZTMxMzU4ZDcxNGFhMThlZTlhYQp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVp
bGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS00YWMy
NTQzMWE0MjY1MTQ1OGVlOGZlMzEzNThkNzE0YWExOGVlOWFhCmtlcm5lbDogL2tlcm5lbC9p
Mzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LzRhYzI1NDMxYTQyNjUxNDU4ZWU4ZmUzMTM1
OGQ3MTRhYTE4ZWU5YWEvdm1saW51ei0zLjE2LjAtcmM2LTAwMTc4LWc0YWMyNTQzCgoyMDE0
LTA3LTI3LTIwOjAyOjQ2IGRldGVjdGluZyBib290IHN0YXRlIC4uLi4JMwk0CTUuCTgJOS4u
CTEwLgkxMy4uCTE1CTE2CTE3CTIyCTIzCTI1LgkyNwkyOS4JMzAJMzIJMzUJMzcuCTQxCTQz
CTQ2Lgk0Nwk0OAk1MAk1My4uCTU1CTU3CTYxCTY0CTY4CTc0CTgwCTgyCTgzCTg3CTkxLgk5
Mwk5NQkxMDAJMTA2LgkxMDcuLgkxMTAJMTEzCTExNQkxMTYJMTE4CTExOQkxMjIJMTIzCTEy
NgkxMjgJMTMwCTEzMQkxMzIJMTM1CTE1MwkxNjMJMTc4CTIwNwkyMjYJMjUyCTI4OAkzMDAg
U1VDQ0VTUwoKQmlzZWN0aW5nOiA1MiByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRo
aXMgKHJvdWdobHkgNiBzdGVwcykKWzg0MzM0Zjk2OTZmYmE2NWRhYzAxYjY4OTZlNzI4ZWQ2
NGYyNWIwYmJdIG1tLGh1Z2V0bGI6IHNpbXBsaWZ5IGVycm9yIGhhbmRsaW5nIGluIGh1Z2V0
bGJfY293KCkKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWls
dXJlLnNoIC9jL2Jvb3QtYmlzZWN0L2xpbnV4NS9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQt
dGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1L25leHQ6
bWFzdGVyOjg0MzM0Zjk2OTZmYmE2NWRhYzAxYjY4OTZlNzI4ZWQ2NGYyNWIwYmI6YmlzZWN0
LWxpbnV4NQoKMjAxNC0wNy0yNy0yMDo0NTowNyA4NDMzNGY5Njk2ZmJhNjVkYWMwMWI2ODk2
ZTcyOGVkNjRmMjViMGJiIGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxk
LXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUtODQzMzRm
OTY5NmZiYTY1ZGFjMDFiNjg5NmU3MjhlZDY0ZjI1YjBiYgpDaGVjayBmb3Iga2VybmVsIGlu
IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS84NDMzNGY5Njk2ZmJhNjVk
YWMwMWI2ODk2ZTcyOGVkNjRmMjViMGJiCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2ti
dWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LTg0
MzM0Zjk2OTZmYmE2NWRhYzAxYjY4OTZlNzI4ZWQ2NGYyNWIwYmIKd2FpdGluZyBmb3IgY29t
cGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1oc3gwMS1jb25zdW1l
ci9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LTg0MzM0Zjk2OTZmYmE2NWRhYzAxYjY4
OTZlNzI4ZWQ2NGYyNWIwYmIKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjAt
MDcyNzE3MTUvODQzMzRmOTY5NmZiYTY1ZGFjMDFiNjg5NmU3MjhlZDY0ZjI1YjBiYi92bWxp
bnV6LTMuMTYuMC1yYzYtMDAyMzAtZzg0MzM0ZjkKCjIwMTQtMDctMjctMjA6NDg6MDcgZGV0
ZWN0aW5nIGJvb3Qgc3RhdGUgCTUJNzAJMjc1CTMwMCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDI2
IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA1IHN0ZXBzKQpb
ZGUzMmFkYTlmMWJiNGZkNzY3M2VkMjQ1YmEyYjFhOTEwM2VjNTBhZV0gc2x1YjogcmVtb3Zl
IGttZW1jZyBpZCBmcm9tIGNyZWF0ZV91bmlxdWVfaWQKcnVubmluZyAvYy9rZXJuZWwtdGVz
dHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0L2xpbnV4NS9v
YmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRj
b25maWctaWIwLTA3MjcxNzE1L25leHQ6bWFzdGVyOmRlMzJhZGE5ZjFiYjRmZDc2NzNlZDI0
NWJhMmIxYTkxMDNlYzUwYWU6YmlzZWN0LWxpbnV4NQoKMjAxNC0wNy0yNy0yMDo1MDowOSBk
ZTMyYWRhOWYxYmI0ZmQ3NjczZWQyNDViYTJiMWE5MTAzZWM1MGFlIGNvbXBpbGluZwpRdWV1
ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNv
bmZpZy1pYjAtMDcyNzE3MTUtZGUzMmFkYTlmMWJiNGZkNzY3M2VkMjQ1YmEyYjFhOTEwM2Vj
NTBhZQpDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0w
NzI3MTcxNS9kZTMyYWRhOWYxYmI0ZmQ3NjczZWQyNDViYTJiMWE5MTAzZWM1MGFlCndhaXRp
bmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJh
bmRjb25maWctaWIwLTA3MjcxNzE1LWRlMzJhZGE5ZjFiYjRmZDc2NzNlZDI0NWJhMmIxYTkx
MDNlYzUwYWUKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUv
ZGUzMmFkYTlmMWJiNGZkNzY3M2VkMjQ1YmEyYjFhOTEwM2VjNTBhZS92bWxpbnV6LTMuMTYu
MC1yYzYtMDAyNTYtZ2RlMzJhZGEKCjIwMTQtMDctMjctMjA6NTI6MDkgZGV0ZWN0aW5nIGJv
b3Qgc3RhdGUgLgk1MyBURVNUIEZBSUxVUkUKWyAgIDIxLjQzODkxN10gcmFuZG9tOiBpbml0
IHVyYW5kb20gcmVhZCB3aXRoIDExIGJpdHMgb2YgZW50cm9weSBhdmFpbGFibGUKWyAgIDIx
LjU2NjA5Nl0gaHdjbG9jayAoMTQwKSB1c2VkIGdyZWF0ZXN0IHN0YWNrIGRlcHRoOiA2MzY0
IGJ5dGVzIGxlZnQKWyAgIDIxLjYxNDYwNV0gc2ggKDE0NCkgdXNlZCBncmVhdGVzdCBzdGFj
ayBkZXB0aDogNjA1MiBieXRlcyBsZWZ0ClsgICAyMi4zNDg1NjldIEJVRzogdXNpbmcgc21w
X3Byb2Nlc3Nvcl9pZCgpIGluIHByZWVtcHRpYmxlIFswMDAwMDAwMF0gY29kZToga3dvcmtl
ci8wOjEvMzYKWyAgIDIyLjM0OTY3M10gY2FsbGVyIGlzIGRlYnVnX3NtcF9wcm9jZXNzb3Jf
aWQrMHgxMi8weDIwClsgICAyMi4zNTA0MzhdIENQVTogMSBQSUQ6IDM2IENvbW06IGt3b3Jr
ZXIvMDoxIE5vdCB0YWludGVkIDMuMTYuMC1yYzYtMDAyNTYtZ2RlMzJhZGEgIzQKWyAgIDIy
LjM1MTQ4N10gSGFyZHdhcmUgbmFtZTogUUVNVSBTdGFuZGFyZCBQQyAoaTQ0MEZYICsgUElJ
WCwgMTk5NiksIEJJT1MgQm9jaHMgMDEvMDEvMjAxMQpbICAgMjIuMzUyNTU4XSBXb3JrcXVl
dWU6IGV2ZW50cyB2bXN0YXRfdXBkYXRlClsgICAyMi4zNTMxNjRdICAwMDAwMDAwMSA5MTRm
MWU0YyA4MjgyNzdiOCAwMDAwMDAwMCAwMDAwMDAwMSA4MzA1ZGM1YiA5MTRmMWU3YyA4MTc2
YjJkNApbICAgMjIuMzU0NDIzXSAgODMwNmIxNjggODMwNmExNDIgODMwNWRjNWIgMDAwMDAw
MDAgOTE0ZTk5MjQgMDAwMDAwMjQgODMwNmExNDIgOTIzN2QyMDAKWyAgIDIyLjM1NTY0M10g
IDAwMDAwMDA0IDkxNGNjMmEwIDkxNGYxZTg0IDgxNzZiMzAyIDkxNGYxZTk4IDgxMWFhM2Q1
IDAwMDAwMDAwIDkyMzdkMjAwClsgICAyMi4zNTY5MDNdIENhbGwgVHJhY2U6ClsgICAyMi4z
NTcyNjddICBbPDgyODI3N2I4Pl0gZHVtcF9zdGFjaysweDdmLzB4ZjMKWyAgIDIyLjM1Nzg2
M10gIFs8ODE3NmIyZDQ+XSBjaGVja19wcmVlbXB0aW9uX2Rpc2FibGVkKzB4MTY0LzB4MTgw
ClsgICAyMi4zNTg2NDNdICBbPDgxNzZiMzAyPl0gZGVidWdfc21wX3Byb2Nlc3Nvcl9pZCsw
eDEyLzB4MjAKWyAgIDIyLjM1OTM5MF0gIFs8ODExYWEzZDU+XSB2bXN0YXRfdXBkYXRlKzB4
NjUvMHg4MApbICAgMjIuMzYwMDc3XSAgWzw4MTA5YmFkOT5dIHByb2Nlc3Nfb25lX3dvcmsr
MHgzYTkvMHhhNDAKWyAgIDIyLjM2MDc3MV0gIFs8ODEwOWJmOGM+XSA/IHByb2Nlc3Nfb25l
X3dvcmsrMHg4NWMvMHhhNDAKWyAgIDIyLjM3NDY0MV0gIFs8ODEwOWMxOWQ+XSA/IHdvcmtl
cl90aHJlYWQrMHgyZC8weGI0MApbICAgMjIuMzc1MzIyXSAgWzw4MTA5YzcyYz5dIHdvcmtl
cl90aHJlYWQrMHg1YmMvMHhiNDAKWyAgIDIyLjM3NTk2Nl0gIFs8ODEwOWMxNzA+XSA/IHBy
b2Nlc3Nfb25lX3dvcmsrMHhhNDAvMHhhNDAKWyAgIDIyLjM3NjcxM10gIFs8ODEwYTg5MzI+
XSBrdGhyZWFkKzB4ZTIvMHhmMApbICAgMjIuMzc3MjkxXSAgWzw4MTA5YzE3MD5dID8gcHJv
Y2Vzc19vbmVfd29yaysweGE0MC8weGE0MApbICAgMjIuMzc3OTk2XSAgWzw4MTBiMDAwMD5d
ID8gU3lTX3NldG5zKzB4OTAvMHgxNjAKWyAgIDIyLjM3ODY1Ml0gIFs8ODI4NTNiYzE+XSBy
ZXRfZnJvbV9rZXJuZWxfdGhyZWFkKzB4MjEvMHgzMApbICAgMjIuMzc5Mzg0XSAgWzw4MTBh
ODg1MD5dID8gaW5zZXJ0X2t0aHJlYWRfd29yaysweDEwMC8weDEwMAoKRWxhcHNlZCB0aW1l
OiAzMApxZW11LXN5c3RlbS14ODZfNjQgLWNwdSBrdm02NCAtZW5hYmxlLWt2bSAta2VybmVs
IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9kZTMyYWRhOWYxYmI0ZmQ3
NjczZWQyNDViYTJiMWE5MTAzZWM1MGFlL3ZtbGludXotMy4xNi4wLXJjNi0wMDI1Ni1nZGUz
MmFkYSAtYXBwZW5kICdodW5nX3Rhc2tfcGFuaWM9MSBlYXJseXByaW50az10dHlTMCwxMTUy
MDAgZGVidWcgYXBpYz1kZWJ1ZyBzeXNycV9hbHdheXNfZW5hYmxlZCByY3VwZGF0ZS5yY3Vf
Y3B1X3N0YWxsX3RpbWVvdXQ9MTAwIHBhbmljPTEwIHNvZnRsb2NrdXBfcGFuaWM9MSBubWlf
d2F0Y2hkb2c9cGFuaWMgIHByb21wdF9yYW1kaXNrPTAgY29uc29sZT10dHlTMCwxMTUyMDAg
Y29uc29sZT10dHkwIHZnYT1ub3JtYWwgIHJvb3Q9L2Rldi9yYW0wIHJ3IGxpbms9L2tidWls
ZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvbmV4
dDptYXN0ZXI6ZGUzMmFkYTlmMWJiNGZkNzY3M2VkMjQ1YmEyYjFhOTEwM2VjNTBhZTpiaXNl
Y3QtbGludXg1Ly52bWxpbnV6LWRlMzJhZGE5ZjFiYjRmZDc2NzNlZDI0NWJhMmIxYTkxMDNl
YzUwYWUtMjAxNDA3MjgwNDUyMzktMjI0LWl2YjQxIGJyYW5jaD1uZXh0L21hc3RlciBCT09U
X0lNQUdFPS9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9kZTMyYWRhOWYx
YmI0ZmQ3NjczZWQyNDViYTJiMWE5MTAzZWM1MGFlL3ZtbGludXotMy4xNi4wLXJjNi0wMDI1
Ni1nZGUzMmFkYSBkcmJkLm1pbm9yX2NvdW50PTgnICAtaW5pdHJkIC9rZXJuZWwtdGVzdHMv
aW5pdHJkL3F1YW50YWwtY29yZS1pMzg2LmNneiAtbSAzMjAgLXNtcCAyIC1uZXQgbmljLHZs
YW49MSxtb2RlbD1lMTAwMCAtbmV0IHVzZXIsdmxhbj0xIC1ib290IG9yZGVyPW5jIC1uby1y
ZWJvb3QgLXdhdGNoZG9nIGk2MzAwZXNiIC1ydGMgYmFzZT1sb2NhbHRpbWUgLXBpZGZpbGUg
L2Rldi9zaG0va2Jvb3QvcGlkLXF1YW50YWwtaXZiNDEtMTAyIC1zZXJpYWwgZmlsZTovZGV2
L3NobS9rYm9vdC9zZXJpYWwtcXVhbnRhbC1pdmI0MS0xMDIgLWRhZW1vbml6ZSAtZGlzcGxh
eSBub25lIC1tb25pdG9yIG51bGwgCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3
MTcxNS9kZTMyYWRhOWYxYmI0ZmQ3NjczZWQyNDViYTJiMWE5MTAzZWM1MGFlL2RtZXNnLXF1
YW50YWwtaXZiNDEtMjk6MjAxNDA3MjcyMDUxNTk6aTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3
MTcxNTo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9kZTMyYWRhOWYx
YmI0ZmQ3NjczZWQyNDViYTJiMWE5MTAzZWM1MGFlL2RtZXNnLXF1YW50YWwtaXZiNDEtNDoy
MDE0MDcyNzIwNTIwNTppMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1OjoKL2tlcm5lbC9p
Mzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1L2RlMzJhZGE5ZjFiYjRmZDc2NzNlZDI0NWJh
MmIxYTkxMDNlYzUwYWUvZG1lc2ctcXVhbnRhbC1pdmI0My0xNzoyMDE0MDcyNzIxMDAwODpp
Mzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1OjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
aWIwLTA3MjcxNzE1L2RlMzJhZGE5ZjFiYjRmZDc2NzNlZDI0NWJhMmIxYTkxMDNlYzUwYWUv
ZG1lc2ctcXVhbnRhbC1pdmI0My0yMDoyMDE0MDcyNzIxMDAwOTppMzg2LXJhbmRjb25maWct
aWIwLTA3MjcxNzE1OjoKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1L2Rl
MzJhZGE5ZjFiYjRmZDc2NzNlZDI0NWJhMmIxYTkxMDNlYzUwYWUvZG1lc2ctcXVhbnRhbC1p
dmI0My02MjoyMDE0MDcyNzIxMDAwOTppMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1OjoK
L2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1L2RlMzJhZGE5ZjFiYjRmZDc2
NzNlZDI0NWJhMmIxYTkxMDNlYzUwYWUvZG1lc2ctcXVhbnRhbC1pdmI0My05MjoyMDE0MDcy
NzIxMDAwMzppMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1OjoKL2tlcm5lbC9pMzg2LXJh
bmRjb25maWctaWIwLTA3MjcxNzE1L2RlMzJhZGE5ZjFiYjRmZDc2NzNlZDI0NWJhMmIxYTkx
MDNlYzUwYWUvZG1lc2ctcXVhbnRhbC1pdmI0MS0xMDI6MjAxNDA3MjcyMDUyMDc6aTM4Ni1y
YW5kY29uZmlnLWliMC0wNzI3MTcxNTo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0w
NzI3MTcxNS9kZTMyYWRhOWYxYmI0ZmQ3NjczZWQyNDViYTJiMWE5MTAzZWM1MGFlL2RtZXNn
LXF1YW50YWwtaXZiNDMtMTA6MjAxNDA3MjcyMTAwMTU6aTM4Ni1yYW5kY29uZmlnLWliMC0w
NzI3MTcxNTo6Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9kZTMyYWRh
OWYxYmI0ZmQ3NjczZWQyNDViYTJiMWE5MTAzZWM1MGFlL2RtZXNnLXF1YW50YWwtaXZiNDMt
NDI6MjAxNDA3MjcyMTAwMTA6aTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNTo6Ci9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9kZTMyYWRhOWYxYmI0ZmQ3NjczZWQy
NDViYTJiMWE5MTAzZWM1MGFlL2RtZXNnLXF1YW50YWwtaXZiNDEtNDA6MjAxNDA3MjcyMDUy
MTk6aTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNTo6CjA6MTA6NjMgYWxsX2dvb2Q6YmFk
OmFsbF9iYWQgYm9vdHMKCkJpc2VjdGluZzogMTIgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBh
ZnRlciB0aGlzIChyb3VnaGx5IDQgc3RlcHMpCltlMjhjOTUxZmYwMWE4MDVlYWNhZTJmNjdh
OTZlMGYyOWUzMmNlYmQxXSBtbTogcGFnZW1hcDogYXZvaWQgdW5uZWNlc3Nhcnkgb3Zlcmhl
YWQgd2hlbiB0cmFjZXBvaW50cyBhcmUgZGVhY3RpdmF0ZWQKcnVubmluZyAvYy9rZXJuZWwt
dGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0L2xpbnV4
NS9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJh
bmRjb25maWctaWIwLTA3MjcxNzE1L25leHQ6bWFzdGVyOmUyOGM5NTFmZjAxYTgwNWVhY2Fl
MmY2N2E5NmUwZjI5ZTMyY2ViZDE6YmlzZWN0LWxpbnV4NQoKMjAxNC0wNy0yNy0yMDo1Mzoy
MiBlMjhjOTUxZmYwMWE4MDVlYWNhZTJmNjdhOTZlMGYyOWUzMmNlYmQxIGNvbXBpbGluZwpR
dWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFu
ZGNvbmZpZy1pYjAtMDcyNzE3MTUtZTI4Yzk1MWZmMDFhODA1ZWFjYWUyZjY3YTk2ZTBmMjll
MzJjZWJkMQpDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWli
MC0wNzI3MTcxNS9lMjhjOTUxZmYwMWE4MDVlYWNhZTJmNjdhOTZlMGYyOWUzMmNlYmQxCndh
aXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2
LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LWUyOGM5NTFmZjAxYTgwNWVhY2FlMmY2N2E5NmUw
ZjI5ZTMyY2ViZDEKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1
aWxkLXF1ZXVlL2pha2V0b3duLWNvbnN1bWVyL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3
MTUtZTI4Yzk1MWZmMDFhODA1ZWFjYWUyZjY3YTk2ZTBmMjllMzJjZWJkMQprZXJuZWw6IC9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9lMjhjOTUxZmYwMWE4MDVlYWNh
ZTJmNjdhOTZlMGYyOWUzMmNlYmQxL3ZtbGludXotMy4xNi4wLXJjNi0wMDI0NC1nZTI4Yzk1
MQoKMjAxNC0wNy0yNy0yMTowMToyMiBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuCTE3CTI3Nwkz
MDAgU1VDQ0VTUwoKQmlzZWN0aW5nOiA2IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIg
dGhpcyAocm91Z2hseSAzIHN0ZXBzKQpbNTg2MGYzM2I5YWMxYzIyNGEzOTk3MzYzNThkODM2
OTNmZTc4Y2U4Ml0gbW06IGRlc2NyaWJlIG1tYXBfc2VtIHJ1bGVzIGZvciBfX2xvY2tfcGFn
ZV9vcl9yZXRyeSgpIGFuZCBjYWxsZXJzCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2Vj
dC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eDUvb2JqLWJpc2Vj
dApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWli
MC0wNzI3MTcxNS9uZXh0Om1hc3Rlcjo1ODYwZjMzYjlhYzFjMjI0YTM5OTczNjM1OGQ4MzY5
M2ZlNzhjZTgyOmJpc2VjdC1saW51eDUKCjIwMTQtMDctMjctMjE6MDM6MjIgNTg2MGYzM2I5
YWMxYzIyNGEzOTk3MzYzNThkODM2OTNmZTc4Y2U4MiBjb21waWxpbmcKUXVldWVkIGJ1aWxk
IHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctaWIw
LTA3MjcxNzE1LTU4NjBmMzNiOWFjMWMyMjRhMzk5NzM2MzU4ZDgzNjkzZmU3OGNlODIKQ2hl
Y2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUv
NTg2MGYzM2I5YWMxYzIyNGEzOTk3MzYzNThkODM2OTNmZTc4Y2U4Mgp3YWl0aW5nIGZvciBj
b21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmln
LWliMC0wNzI3MTcxNS01ODYwZjMzYjlhYzFjMjI0YTM5OTczNjM1OGQ4MzY5M2ZlNzhjZTgy
CndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9s
a3AtaHN4MDEtY29uc3VtZXIvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS01ODYwZjMz
YjlhYzFjMjI0YTM5OTczNjM1OGQ4MzY5M2ZlNzhjZTgyCmtlcm5lbDogL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LzU4NjBmMzNiOWFjMWMyMjRhMzk5NzM2MzU4ZDgz
NjkzZmU3OGNlODIvdm1saW51ei0zLjE2LjAtcmM2LTAwMjQ5LWc1ODYwZjMzCgoyMDE0LTA3
LTI3LTIxOjA3OjIzIGRldGVjdGluZyBib290IHN0YXRlIC4uCTIuCTQ1CTc5CTEyNgkxNDAJ
MTU3CTE4MQkxOTkJMjIzCTIzMwkyNzQJMjk3CTI5OAkzMDAgU1VDQ0VTUwoKQmlzZWN0aW5n
OiAzIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAyIHN0ZXBz
KQpbZTc5NDMwMjNjZmNhYzNjOWE3ZmU1YTIzNzEzYWE1NzIzMzg2ZDgzYl0gY3B1X3N0YXRf
b2ZmIGNhbiBiZSBzdGF0aWMKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3Qt
Ym9vdC1mYWlsdXJlLnNoIC9jL2Jvb3QtYmlzZWN0L2xpbnV4NS9vYmotYmlzZWN0CmxzIC1h
IC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaWIwLTA3Mjcx
NzE1L25leHQ6bWFzdGVyOmU3OTQzMDIzY2ZjYWMzYzlhN2ZlNWEyMzcxM2FhNTcyMzM4NmQ4
M2I6YmlzZWN0LWxpbnV4NQoKMjAxNC0wNy0yNy0yMToxNTo1MyBlNzk0MzAyM2NmY2FjM2M5
YTdmZTVhMjM3MTNhYTU3MjMzODZkODNiIGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0
byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3
MTUtZTc5NDMwMjNjZmNhYzNjOWE3ZmU1YTIzNzEzYWE1NzIzMzg2ZDgzYgpDaGVjayBmb3Ig
a2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9lNzk0MzAy
M2NmY2FjM2M5YTdmZTVhMjM3MTNhYTU3MjMzODZkODNiCndhaXRpbmcgZm9yIGNvbXBsZXRp
b24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctaWIwLTA3
MjcxNzE1LWU3OTQzMDIzY2ZjYWMzYzlhN2ZlNWEyMzcxM2FhNTcyMzM4NmQ4M2IKd2FpdGlu
ZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2xrcC1oc3gw
MS1jb25zdW1lci9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LWU3OTQzMDIzY2ZjYWMz
YzlhN2ZlNWEyMzcxM2FhNTcyMzM4NmQ4M2IKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNv
bmZpZy1pYjAtMDcyNzE3MTUvZTc5NDMwMjNjZmNhYzNjOWE3ZmU1YTIzNzEzYWE1NzIzMzg2
ZDgzYi92bWxpbnV6LTMuMTYuMC1yYzYtMDAyNTItZ2U3OTQzMDIKCjIwMTQtMDctMjctMjE6
MzE6NTMgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgCTEuCTUJNgkxMyBURVNUIEZBSUxVUkUKWyAg
IDE4LjAxNDI1Ml0gcmFuZG9tOiBpbml0IHVyYW5kb20gcmVhZCB3aXRoIDExIGJpdHMgb2Yg
ZW50cm9weSBhdmFpbGFibGUKWyAgIDE4LjEwNTk0NF0gaHdjbG9jayAoMTUyKSB1c2VkIGdy
ZWF0ZXN0IHN0YWNrIGRlcHRoOiA2MjkyIGJ5dGVzIGxlZnQKCkJVRzoga2VybmVsIGJvb3Qg
aGFuZwpFbGFwc2VkIHRpbWU6IDM1CnFlbXUtc3lzdGVtLXg4Nl82NCAtZW5hYmxlLWt2bSAt
Y3B1IEhhc3dlbGwsK3NtZXAsK3NtYXAgLWtlcm5lbCAva2VybmVsL2kzODYtcmFuZGNvbmZp
Zy1pYjAtMDcyNzE3MTUvZTc5NDMwMjNjZmNhYzNjOWE3ZmU1YTIzNzEzYWE1NzIzMzg2ZDgz
Yi92bWxpbnV6LTMuMTYuMC1yYzYtMDAyNTItZ2U3OTQzMDIgLWFwcGVuZCAnaHVuZ190YXNr
X3BhbmljPTEgZWFybHlwcmludGs9dHR5UzAsMTE1MjAwIGRlYnVnIGFwaWM9ZGVidWcgc3lz
cnFfYWx3YXlzX2VuYWJsZWQgcmN1cGRhdGUucmN1X2NwdV9zdGFsbF90aW1lb3V0PTEwMCBw
YW5pYz0xMCBzb2Z0bG9ja3VwX3BhbmljPTEgbm1pX3dhdGNoZG9nPXBhbmljICBwcm9tcHRf
cmFtZGlzaz0wIGNvbnNvbGU9dHR5UzAsMTE1MjAwIGNvbnNvbGU9dHR5MCB2Z2E9bm9ybWFs
ICByb290PS9kZXYvcmFtMCBydyBsaW5rPS9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9p
Mzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1L25leHQ6bWFzdGVyOmU3OTQzMDIzY2ZjYWMz
YzlhN2ZlNWEyMzcxM2FhNTcyMzM4NmQ4M2I6YmlzZWN0LWxpbnV4NS8udm1saW51ei1lNzk0
MzAyM2NmY2FjM2M5YTdmZTVhMjM3MTNhYTU3MjMzODZkODNiLTIwMTQwNzI4MDUzMTU2LTEx
NC1rYnVpbGQgYnJhbmNoPW5leHQvbWFzdGVyIEJPT1RfSU1BR0U9L2tlcm5lbC9pMzg2LXJh
bmRjb25maWctaWIwLTA3MjcxNzE1L2U3OTQzMDIzY2ZjYWMzYzlhN2ZlNWEyMzcxM2FhNTcy
MzM4NmQ4M2Ivdm1saW51ei0zLjE2LjAtcmM2LTAwMjUyLWdlNzk0MzAyIGRyYmQubWlub3Jf
Y291bnQ9OCcgIC1pbml0cmQgL2tlcm5lbC10ZXN0cy9pbml0cmQvcXVhbnRhbC1jb3JlLWkz
ODYuY2d6IC1tIDMyMCAtc21wIDIgLW5ldCBuaWMsdmxhbj0xLG1vZGVsPWUxMDAwIC1uZXQg
dXNlcix2bGFuPTEgLWJvb3Qgb3JkZXI9bmMgLW5vLXJlYm9vdCAtd2F0Y2hkb2cgaTYzMDBl
c2IgLXJ0YyBiYXNlPWxvY2FsdGltZSAtcGlkZmlsZSAvZGV2L3NobS9rYm9vdC9waWQtcXVh
bnRhbC1rYnVpbGQtMTAgLXNlcmlhbCBmaWxlOi9kZXYvc2htL2tib290L3NlcmlhbC1xdWFu
dGFsLWtidWlsZC0xMCAtZGFlbW9uaXplIC1kaXNwbGF5IG5vbmUgLW1vbml0b3IgbnVsbCAK
L2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1L2U3OTQzMDIzY2ZjYWMzYzlh
N2ZlNWEyMzcxM2FhNTcyMzM4NmQ4M2IvZG1lc2ctcXVhbnRhbC1rYnVpbGQtMTI6MjAxNDA3
MjcyMTMyMDY6aTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNTozLjE2LjAtcmM2LTAwMjUy
LWdlNzk0MzAyOjYKMTA6MTo0IGFsbF9nb29kOmJhZDphbGxfYmFkIGJvb3RzCgpCaXNlY3Rp
bmc6IDAgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDEgc3Rl
cCkKWzZlMGE2YjE4YjYzZTJjMGE0NWZmNDdhYjYzM2RkNmYzYWQ0MTc0NTNdIHZtc3RhdDog
T24gZGVtYW5kIHZtc3RhdCB3b3JrZXJzIFY4CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jp
c2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eDUvb2JqLWJp
c2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmln
LWliMC0wNzI3MTcxNS9uZXh0Om1hc3Rlcjo2ZTBhNmIxOGI2M2UyYzBhNDVmZjQ3YWI2MzNk
ZDZmM2FkNDE3NDUzOmJpc2VjdC1saW51eDUKCjIwMTQtMDctMjctMjE6MzQ6MjUgNmUwYTZi
MThiNjNlMmMwYTQ1ZmY0N2FiNjMzZGQ2ZjNhZDQxNzQ1MyBjb21waWxpbmcKUXVldWVkIGJ1
aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWct
aWIwLTA3MjcxNzE1LTZlMGE2YjE4YjYzZTJjMGE0NWZmNDdhYjYzM2RkNmYzYWQ0MTc0NTMK
Q2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3
MTUvNmUwYTZiMThiNjNlMmMwYTQ1ZmY0N2FiNjMzZGQ2ZjNhZDQxNzQ1Mwp3YWl0aW5nIGZv
ciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29u
ZmlnLWliMC0wNzI3MTcxNS02ZTBhNmIxOGI2M2UyYzBhNDVmZjQ3YWI2MzNkZDZmM2FkNDE3
NDUzCmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LzZlMGE2
YjE4YjYzZTJjMGE0NWZmNDdhYjYzM2RkNmYzYWQ0MTc0NTMvdm1saW51ei0zLjE2LjAtcmM2
LTAwMjUxLWc2ZTBhNmIxCgoyMDE0LTA3LTI3LTIxOjM2OjI1IGRldGVjdGluZyBib290IHN0
YXRlIAk1IFRFU1QgRkFJTFVSRQpbICAgMTkuNDc1MzExXSBjaG93biAoNjgxKSB1c2VkIGdy
ZWF0ZXN0IHN0YWNrIGRlcHRoOiA2MjQ0IGJ5dGVzIGxlZnQKWyAgIDIxLjAyMDIxMl0gY2hv
d24gKDEyMzQpIHVzZWQgZ3JlYXRlc3Qgc3RhY2sgZGVwdGg6IDU5ODggYnl0ZXMgbGVmdAoK
QlVHOiBrZXJuZWwgYm9vdCBoYW5nCkVsYXBzZWQgdGltZTogMzUKcWVtdS1zeXN0ZW0teDg2
XzY0IC1lbmFibGUta3ZtIC1jcHUgSGFzd2VsbCwrc21lcCwrc21hcCAta2VybmVsIC9rZXJu
ZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS82ZTBhNmIxOGI2M2UyYzBhNDVmZjQ3
YWI2MzNkZDZmM2FkNDE3NDUzL3ZtbGludXotMy4xNi4wLXJjNi0wMDI1MS1nNmUwYTZiMSAt
YXBwZW5kICdodW5nX3Rhc2tfcGFuaWM9MSBlYXJseXByaW50az10dHlTMCwxMTUyMDAgZGVi
dWcgYXBpYz1kZWJ1ZyBzeXNycV9hbHdheXNfZW5hYmxlZCByY3VwZGF0ZS5yY3VfY3B1X3N0
YWxsX3RpbWVvdXQ9MTAwIHBhbmljPTEwIHNvZnRsb2NrdXBfcGFuaWM9MSBubWlfd2F0Y2hk
b2c9cGFuaWMgIHByb21wdF9yYW1kaXNrPTAgY29uc29sZT10dHlTMCwxMTUyMDAgY29uc29s
ZT10dHkwIHZnYT1ub3JtYWwgIHJvb3Q9L2Rldi9yYW0wIHJ3IGxpbms9L2tidWlsZC10ZXN0
cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvbmV4dDptYXN0
ZXI6NmUwYTZiMThiNjNlMmMwYTQ1ZmY0N2FiNjMzZGQ2ZjNhZDQxNzQ1MzpiaXNlY3QtbGlu
dXg1Ly52bWxpbnV6LTZlMGE2YjE4YjYzZTJjMGE0NWZmNDdhYjYzM2RkNmYzYWQ0MTc0NTMt
MjAxNDA3MjgwNTM1NTQtMTAzLWtidWlsZCBicmFuY2g9bmV4dC9tYXN0ZXIgQk9PVF9JTUFH
RT0va2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvNmUwYTZiMThiNjNlMmMw
YTQ1ZmY0N2FiNjMzZGQ2ZjNhZDQxNzQ1My92bWxpbnV6LTMuMTYuMC1yYzYtMDAyNTEtZzZl
MGE2YjEgZHJiZC5taW5vcl9jb3VudD04JyAgLWluaXRyZCAva2VybmVsLXRlc3RzL2luaXRy
ZC9xdWFudGFsLWNvcmUtaTM4Ni5jZ3ogLW0gMzIwIC1zbXAgMiAtbmV0IG5pYyx2bGFuPTEs
bW9kZWw9ZTEwMDAgLW5ldCB1c2VyLHZsYW49MSAtYm9vdCBvcmRlcj1uYyAtbm8tcmVib290
IC13YXRjaGRvZyBpNjMwMGVzYiAtcnRjIGJhc2U9bG9jYWx0aW1lIC1waWRmaWxlIC9kZXYv
c2htL2tib290L3BpZC1xdWFudGFsLWtidWlsZC0xMiAtc2VyaWFsIGZpbGU6L2Rldi9zaG0v
a2Jvb3Qvc2VyaWFsLXF1YW50YWwta2J1aWxkLTEyIC1kYWVtb25pemUgLWRpc3BsYXkgbm9u
ZSAtbW9uaXRvciBudWxsIAova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUv
NmUwYTZiMThiNjNlMmMwYTQ1ZmY0N2FiNjMzZGQ2ZjNhZDQxNzQ1My9kbWVzZy1xdWFudGFs
LWtidWlsZC0zMToyMDE0MDcyNzIxMzQzNjppMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1
OjMuMTYuMC1yYzYtMDAyNTEtZzZlMGE2YjE6NwowOjE6NiBhbGxfZ29vZDpiYWQ6YWxsX2Jh
ZCBib290cwoKQmlzZWN0aW5nOiAwIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhp
cyAocm91Z2hseSAwIHN0ZXBzKQpbNDAyMDg0MWQ0NjRkNjg5YzA0NWFkNzdmMDkxZjZmN2Zh
MjExNjYzZF0gbW0vc2htZW0uYzogcmVtb3ZlIHRoZSB1bnVzZWQgZ2ZwIGFyZyB0byBzaG1l
bV9hZGRfdG9fcGFnZV9jYWNoZSgpCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10
ZXN0LWJvb3QtZmFpbHVyZS5zaCAvYy9ib290LWJpc2VjdC9saW51eDUvb2JqLWJpc2VjdAps
cyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWliMC0w
NzI3MTcxNS9uZXh0Om1hc3Rlcjo0MDIwODQxZDQ2NGQ2ODljMDQ1YWQ3N2YwOTFmNmY3ZmEy
MTE2NjNkOmJpc2VjdC1saW51eDUKCjIwMTQtMDctMjctMjE6MzY6NTcgNDAyMDg0MWQ0NjRk
Njg5YzA0NWFkNzdmMDkxZjZmN2ZhMjExNjYzZCBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRh
c2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctaWIwLTA3
MjcxNzE1LTQwMjA4NDFkNDY0ZDY4OWMwNDVhZDc3ZjA5MWY2ZjdmYTIxMTY2M2QKQ2hlY2sg
Zm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvNDAy
MDg0MWQ0NjRkNjg5YzA0NWFkNzdmMDkxZjZmN2ZhMjExNjYzZAp3YWl0aW5nIGZvciBjb21w
bGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLWli
MC0wNzI3MTcxNS00MDIwODQxZDQ2NGQ2ODljMDQ1YWQ3N2YwOTFmNmY3ZmEyMTE2NjNkCmtl
cm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LzQwMjA4NDFkNDY0
ZDY4OWMwNDVhZDc3ZjA5MWY2ZjdmYTIxMTY2M2Qvdm1saW51ei0zLjE2LjAtcmM2LTAwMjUw
LWc0MDIwODQxCgoyMDE0LTA3LTI3LTIxOjM4OjU3IGRldGVjdGluZyBib290IHN0YXRlIC4u
CTMJNgk4CTE0CTE2CTIxCTI0CTI3CTMzCTM3CTM5CTQxCTQ1CTQ4CTQ5CTUzCTU3CTYyCTY1
CTY4CTcxCTc3CTgwCTgyCTgzCTg5CTkyCTk1CTk5CTEwNAkxMDcJMTA5CTExMAkxMTgJMTI1
CTEyNwkxMzMJMTQwCTE0MgkxNDMJMTQ1CTE1MAkxNTQuCTE1NgkxNTgJMTYwCTE2NAkxNjkJ
MTc0CTE3OAkxODMJMTg2CTE4OAkxOTYJMjAxLgkyMDIJMjAzCTIwNQkyMDcuCTIxMAkyMTYJ
MjE4CTIyMgkyMjUJMjI5CTIzNQkyMzkJMjQyCTI0NAkyNDgJMjUzCTI1OQkyNjQJMjY4CTI3
OAkyODQJMzAwIFNVQ0NFU1MKCjZlMGE2YjE4YjYzZTJjMGE0NWZmNDdhYjYzM2RkNmYzYWQ0
MTc0NTMgaXMgdGhlIGZpcnN0IGJhZCBjb21taXQKY29tbWl0IDZlMGE2YjE4YjYzZTJjMGE0
NWZmNDdhYjYzM2RkNmYzYWQ0MTc0NTMKQXV0aG9yOiBDaHJpc3RvcGggTGFtZXRlciA8Y2xA
Z2VudHdvLm9yZz4KRGF0ZTogICBXZWQgSnVsIDIzIDA5OjExOjQzIDIwMTQgKzEwMDAKCiAg
ICB2bXN0YXQ6IE9uIGRlbWFuZCB2bXN0YXQgd29ya2VycyBWOAogICAgCiAgICB2bXN0YXQg
d29ya2VycyBhcmUgdXNlZCBmb3IgZm9sZGluZyBjb3VudGVyIGRpZmZlcmVudGlhbHMgaW50
byB0aGUgem9uZSwKICAgIHBlciBub2RlIGFuZCBnbG9iYWwgY291bnRlcnMgYXQgY2VydGFp
biB0aW1lIGludGVydmFscy4gIFRoZXkgY3VycmVudGx5CiAgICBydW4gYXQgZGVmaW5lZCBp
bnRlcnZhbHMgb24gYWxsIHByb2Nlc3NvcnMgd2hpY2ggd2lsbCBjYXVzZSBzb21lIGhvbGRv
ZmYKICAgIGZvciBwcm9jZXNzb3JzIHRoYXQgbmVlZCBtaW5pbWFsIGludHJ1c2lvbiBieSB0
aGUgT1MuCiAgICAKICAgIFRoZSBjdXJyZW50IHZtc3RhdF91cGRhdGUgbWVjaGFuaXNtIGRl
cGVuZHMgb24gYSBkZWZlcnJhYmxlIHRpbWVyIGZpcmluZwogICAgZXZlcnkgb3RoZXIgc2Vj
b25kIGJ5IGRlZmF1bHQgd2hpY2ggcmVnaXN0ZXJzIGEgd29yayBxdWV1ZSBpdGVtIHRoYXQg
cnVucwogICAgb24gdGhlIGxvY2FsIENQVSwgd2l0aCB0aGUgcmVzdWx0IHRoYXQgd2UgaGF2
ZSAxIGludGVycnVwdCBhbmQgb25lCiAgICBhZGRpdGlvbmFsIHNjaGVkdWxhYmxlIHRhc2sg
b24gZWFjaCBDUFUgZXZlcnkgMiBzZWNvbmRzIElmIGEgd29ya2xvYWQKICAgIGluZGVlZCBj
YXVzZXMgVk0gYWN0aXZpdHkgb3IgbXVsdGlwbGUgdGFza3MgYXJlIHJ1bm5pbmcgb24gYSBD
UFUsIHRoZW4KICAgIHRoZXJlIGFyZSBwcm9iYWJseSBiaWdnZXIgaXNzdWVzIHRvIGRlYWwg
d2l0aC4KICAgIAogICAgSG93ZXZlciwgc29tZSB3b3JrbG9hZHMgZGVkaWNhdGUgYSBDUFUg
Zm9yIGEgc2luZ2xlIENQVSBib3VuZCB0YXNrLiAgVGhpcwogICAgaXMgZG9uZSBpbiBoaWdo
IHBlcmZvcm1hbmNlIGNvbXB1dGluZywgaW4gaGlnaCBmcmVxdWVuY3kgZmluYW5jaWFsCiAg
ICBhcHBsaWNhdGlvbnMsIGluIG5ldHdvcmtpbmcgKEludGVsIERQREssIEVaY2hpcCBOUFMp
IGFuZCB3aXRoIHRoZSBhZHZlbnQKICAgIG9mIHN5c3RlbXMgd2l0aCBtb3JlIGFuZCBtb3Jl
IENQVXMgb3ZlciB0aW1lLCB0aGlzIG1heSBiZWNvbWUgbW9yZSBhbmQKICAgIG1vcmUgY29t
bW9uIHRvIGRvIHNpbmNlIHdoZW4gb25lIGhhcyBlbm91Z2ggQ1BVcyBvbmUgY2FyZXMgbGVz
cyBhYm91dAogICAgZWZmaWNpZW50bHkgc2hhcmluZyBhIENQVSB3aXRoIG90aGVyIHRhc2tz
IGFuZCBtb3JlIGFib3V0IGVmZmljaWVudGx5CiAgICBtb25vcG9saXppbmcgYSBDUFUgcGVy
IHRhc2suCiAgICAKICAgIFRoZSBkaWZmZXJlbmNlIG9mIGhhdmluZyB0aGlzIHRpbWVyIGZp
cmluZyBhbmQgd29ya3F1ZXVlIGtlcm5lbCB0aHJlYWQKICAgIHNjaGVkdWxlZCBwZXIgc2Vj
b25kIGNhbiBiZSBlbm9ybW91cy4gIEFuIGFydGlmaWNpYWwgdGVzdCBtZWFzdXJpbmcgdGhl
CiAgICB3b3JzdCBjYXNlIHRpbWUgdG8gZG8gYSBzaW1wbGUgImkrKyIgaW4gYW4gZW5kbGVz
cyBsb29wIG9uIGEgYmFyZSBtZXRhbAogICAgc3lzdGVtIGFuZCB1bmRlciBMaW51eCBvbiBh
biBpc29sYXRlZCBDUFUgd2l0aCBkeW50aWNrcyBhbmQgd2l0aCBhbmQKICAgIHdpdGhvdXQg
dGhpcyBwYXRjaCwgaGF2ZSBMaW51eCBtYXRjaCB0aGUgYmFyZSBtZXRhbCBwZXJmb3JtYW5j
ZSAofjcwMAogICAgY3ljbGVzKSB3aXRoIHRoaXMgcGF0Y2ggYW5kIGxvb3NlIGJ5IGNvdXBs
ZSBvZiBvcmRlcnMgb2YgbWFnbml0dWRlICh+MjAwawogICAgY3ljbGVzKSB3aXRob3V0IGl0
WypdLiAgVGhlIGxvc3Mgb2NjdXJzIGZvciBzb21ldGhpbmcgdGhhdCBqdXN0IGNhbGN1bGF0
ZXMKICAgIHN0YXRpc3RpY3MuICBGb3IgbmV0d29ya2luZyBhcHBsaWNhdGlvbnMsIGZvciBl
eGFtcGxlLCB0aGlzIGNvdWxkIGJlIHRoZQogICAgZGlmZmVyZW5jZSBiZXR3ZWVuIGRyb3Bw
aW5nIHBhY2tldHMgb3Igc3VzdGFpbmluZyBsaW5lIHJhdGUuCiAgICAKICAgIFN0YXRpc3Rp
Y3MgYXJlIGltcG9ydGFudCBhbmQgdXNlZnVsLCBidXQgaXQgd291bGQgYmUgZ3JlYXQgaWYg
dGhlcmUgd291bGQKICAgIGJlIGEgd2F5IHRvIG5vdCBjYXVzZSBzdGF0aXN0aWNzIGdhdGhl
cmluZyBwcm9kdWNlIGEgaHVnZSBwZXJmb3JtYW5jZQogICAgZGlmZmVyZW5jZS4gIFRoaXMg
cGF0Y2hlIGRvZXMganVzdCB0aGF0LgogICAgCiAgICBUaGlzIHBhdGNoIGNyZWF0ZXMgYSB2
bXN0YXQgc2hlcGhlcmQgd29ya2VyIHRoYXQgbW9uaXRvcnMgdGhlIHBlciBjcHUKICAgIGRp
ZmZlcmVudGlhbHMgb24gYWxsIHByb2Nlc3NvcnMuICBJZiB0aGVyZSBhcmUgZGlmZmVyZW50
aWFscyBvbiBhCiAgICBwcm9jZXNzb3IgdGhlbiBhIHZtc3RhdCB3b3JrZXIgbG9jYWwgdG8g
dGhlIHByb2Nlc3NvcnMgd2l0aCB0aGUKICAgIGRpZmZlcmVudGlhbHMgaXMgY3JlYXRlZC4g
IFRoYXQgd29ya2VyIHdpbGwgdGhlbiBzdGFydCBmb2xkaW5nIHRoZSBkaWZmcwogICAgaW4g
cmVndWxhciBpbnRlcnZhbHMuICBTaG91bGQgdGhlIHdvcmtlciBmaW5kIHRoYXQgdGhlcmUg
aXMgbm8gd29yayB0byBiZQogICAgZG9uZSB0aGVuIGl0IHdpbGwgbWFrZSB0aGUgc2hlcGhl
cmQgd29ya2VyIG1vbml0b3IgdGhlIGRpZmZlcmVudGlhbHMKICAgIGFnYWluLgogICAgCiAg
ICBXaXRoIHRoaXMgcGF0Y2ggaXQgaXMgcG9zc2libGUgdGhlbiB0byBoYXZlIHBlcmlvZHMg
bG9uZ2VyIHRoYW4KICAgIDIgc2Vjb25kcyB3aXRob3V0IGFueSBPUyBldmVudCBvbiBhICJj
cHUiIChoYXJkd2FyZSB0aHJlYWQpLgogICAgCiAgICBUaGUgcGF0Y2ggc2hvd3MgYSB2ZXJ5
IG1pbm9yIGluY3JlYXNlZCBpbiBzeXN0ZW0gcGVyZm9ybWFuY2UuCiAgICAKICAgIGhhY2ti
ZW5jaCAtcyA1MTIgLWwgMjAwMCAtZyAxNSAtZiAyNSAtUAogICAgCiAgICBSZXN1bHRzIGJl
Zm9yZSB0aGUgcGF0Y2g6CiAgICAKICAgIFJ1bm5pbmcgaW4gcHJvY2VzcyBtb2RlIHdpdGgg
MTUgZ3JvdXBzIHVzaW5nIDUwIGZpbGUgZGVzY3JpcHRvcnMgZWFjaCAoPT0gNzUwIHRhc2tz
KQogICAgRWFjaCBzZW5kZXIgd2lsbCBwYXNzIDIwMDAgbWVzc2FnZXMgb2YgNTEyIGJ5dGVz
CiAgICBUaW1lOiA0Ljk5MgogICAgUnVubmluZyBpbiBwcm9jZXNzIG1vZGUgd2l0aCAxNSBn
cm91cHMgdXNpbmcgNTAgZmlsZSBkZXNjcmlwdG9ycyBlYWNoICg9PSA3NTAgdGFza3MpCiAg
ICBFYWNoIHNlbmRlciB3aWxsIHBhc3MgMjAwMCBtZXNzYWdlcyBvZiA1MTIgYnl0ZXMKICAg
IFRpbWU6IDQuOTcxCiAgICBSdW5uaW5nIGluIHByb2Nlc3MgbW9kZSB3aXRoIDE1IGdyb3Vw
cyB1c2luZyA1MCBmaWxlIGRlc2NyaXB0b3JzIGVhY2ggKD09IDc1MCB0YXNrcykKICAgIEVh
Y2ggc2VuZGVyIHdpbGwgcGFzcyAyMDAwIG1lc3NhZ2VzIG9mIDUxMiBieXRlcwogICAgVGlt
ZTogNS4wNjMKICAgIAogICAgSGFja2JlbmNoIGFmdGVyIHRoZSBwYXRjaDoKICAgIAogICAg
UnVubmluZyBpbiBwcm9jZXNzIG1vZGUgd2l0aCAxNSBncm91cHMgdXNpbmcgNTAgZmlsZSBk
ZXNjcmlwdG9ycyBlYWNoICg9PSA3NTAgdGFza3MpCiAgICBFYWNoIHNlbmRlciB3aWxsIHBh
c3MgMjAwMCBtZXNzYWdlcyBvZiA1MTIgYnl0ZXMKICAgIFRpbWU6IDQuOTczCiAgICBSdW5u
aW5nIGluIHByb2Nlc3MgbW9kZSB3aXRoIDE1IGdyb3VwcyB1c2luZyA1MCBmaWxlIGRlc2Ny
aXB0b3JzIGVhY2ggKD09IDc1MCB0YXNrcykKICAgIEVhY2ggc2VuZGVyIHdpbGwgcGFzcyAy
MDAwIG1lc3NhZ2VzIG9mIDUxMiBieXRlcwogICAgVGltZTogNC45OTAKICAgIFJ1bm5pbmcg
aW4gcHJvY2VzcyBtb2RlIHdpdGggMTUgZ3JvdXBzIHVzaW5nIDUwIGZpbGUgZGVzY3JpcHRv
cnMgZWFjaCAoPT0gNzUwIHRhc2tzKQogICAgRWFjaCBzZW5kZXIgd2lsbCBwYXNzIDIwMDAg
bWVzc2FnZXMgb2YgNTEyIGJ5dGVzCiAgICBUaW1lOiA0Ljk5MwogICAgCiAgICBTaWduZWQt
b2ZmLWJ5OiBDaHJpc3RvcGggTGFtZXRlciA8Y2xAbGludXguY29tPgogICAgUmV2aWV3ZWQt
Ynk6IEdpbGFkIEJlbi1Zb3NzZWYgPGdpbGFkQGJlbnlvc3NlZi5jb20+CiAgICBDYzogRnJl
ZGVyaWMgV2Vpc2JlY2tlciA8ZndlaXNiZWNAZ21haWwuY29tPgogICAgQ2M6IFRob21hcyBH
bGVpeG5lciA8dGdseEBsaW51dHJvbml4LmRlPgogICAgQ2M6IFRlanVuIEhlbyA8dGpAa2Vy
bmVsLm9yZz4KICAgIENjOiBKb2huIFN0dWx0eiA8am9obnN0dWxAdXMuaWJtLmNvbT4KICAg
IENjOiBNaWtlIEZyeXNpbmdlciA8dmFwaWVyQGdlbnRvby5vcmc+CiAgICBDYzogTWluY2hh
biBLaW0gPG1pbmNoYW4ua2ltQGdtYWlsLmNvbT4KICAgIENjOiBIYWthbiBBa2thbiA8aGFr
YW5ha2thbkBnbWFpbC5jb20+CiAgICBDYzogTWF4IEtyYXNueWFuc2t5IDxtYXhrQHF0aS5x
dWFsY29tbS5jb20+CiAgICBDYzogIlBhdWwgRS4gTWNLZW5uZXkiIDxwYXVsbWNrQGxpbnV4
LnZuZXQuaWJtLmNvbT4KICAgIENjOiBIdWdoIERpY2tpbnMgPGh1Z2hkQGdvb2dsZS5jb20+
CiAgICBDYzogVmlyZXNoIEt1bWFyIDx2aXJlc2gua3VtYXJAbGluYXJvLm9yZz4KICAgIENj
OiBILiBQZXRlciBBbnZpbiA8aHBhQHp5dG9yLmNvbT4KICAgIENjOiBJbmdvIE1vbG5hciA8
bWluZ29Aa2VybmVsLm9yZz4KICAgIENjOiBQZXRlciBaaWpsc3RyYSA8cGV0ZXJ6QGluZnJh
ZGVhZC5vcmc+CiAgICBTaWduZWQtb2ZmLWJ5OiBBbmRyZXcgTW9ydG9uIDxha3BtQGxpbnV4
LWZvdW5kYXRpb24ub3JnPgoKOjA0MDAwMCAwNDAwMDAgMzMxNGJmODViMjUyNDkxMTJkOTUy
NTliMjk2NTkxMWFiM2I4MDMyZiBmYjNmYjhhMGU1M2ZhOTNmMTdiYmYwOTIzZDI0NjAwNDA1
NWU5NzQ3IE0JbW0KYmlzZWN0IHJ1biBzdWNjZXNzCkhFQUQgaXMgbm93IGF0IDQwMjA4NDEu
Li4gbW0vc2htZW0uYzogcmVtb3ZlIHRoZSB1bnVzZWQgZ2ZwIGFyZyB0byBzaG1lbV9hZGRf
dG9fcGFnZV9jYWNoZSgpCmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2
LXJhbmRjb25maWctaWIwLTA3MjcxNzE1L25leHQ6bWFzdGVyOjQwMjA4NDFkNDY0ZDY4OWMw
NDVhZDc3ZjA5MWY2ZjdmYTIxMTY2M2Q6YmlzZWN0LWxpbnV4NQoKMjAxNC0wNy0yNy0yMjoy
MDoxNCA0MDIwODQxZDQ2NGQ2ODljMDQ1YWQ3N2YwOTFmNmY3ZmEyMTE2NjNkIHJldXNlIC9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS80MDIwODQxZDQ2NGQ2ODljMDQ1
YWQ3N2YwOTFmNmY3ZmEyMTE2NjNkL3ZtbGludXotMy4xNi4wLXJjNi0wMDI1MC1nNDAyMDg0
MQoKMjAxNC0wNy0yNy0yMjoyMDoxNSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4JMjgJNDEJ
NzIJMTAxCTExNwkxMzkJMTcwCTIwMgkyMTAJMjU3CTI4OQkzMjcJMzU2CTQxNAk0NTkJNTcx
CTYxMQk3MDIJNzQ4CTc2Nwk4MjgJODY2CTg5OC4JOTAwIFNVQ0NFU1MKClByZXZpb3VzIEhF
QUQgcG9zaXRpb24gd2FzIDQwMjA4NDEuLi4gbW0vc2htZW0uYzogcmVtb3ZlIHRoZSB1bnVz
ZWQgZ2ZwIGFyZyB0byBzaG1lbV9hZGRfdG9fcGFnZV9jYWNoZSgpCkhFQUQgaXMgbm93IGF0
IDVhNzQzOWUuLi4gQWRkIGxpbnV4LW5leHQgc3BlY2lmaWMgZmlsZXMgZm9yIDIwMTQwNzI1
CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaWIw
LTA3MjcxNzE1L25leHQ6bWFzdGVyOjVhNzQzOWVmZDFjNWM0MTZmNzY4ZmM1NTAwNDhjYTEz
MGNmNGJmOTk6YmlzZWN0LWxpbnV4NQogVEVTVCBGQUlMVVJFClsgICAxNS40ODc5NjFdIGhv
c3RuYW1lICgxNjUpIHVzZWQgZ3JlYXRlc3Qgc3RhY2sgZGVwdGg6IDY2ODggYnl0ZXMgbGVm
dApbICAgMTUuNTMxNTk4XSBod2Nsb2NrICgxNjkpIHVzZWQgZ3JlYXRlc3Qgc3RhY2sgZGVw
dGg6IDYzMDggYnl0ZXMgbGVmdApbICAgMTUuNTM0MzcwXSBwbHltb3V0aGQgKDE2NikgdXNl
ZCBncmVhdGVzdCBzdGFjayBkZXB0aDogNjI5MiBieXRlcyBsZWZ0ClsgICAxNi4zNDY4MTNd
IEJVRzogdXNpbmcgc21wX3Byb2Nlc3Nvcl9pZCgpIGluIHByZWVtcHRpYmxlIFswMDAwMDAw
MF0gY29kZToga3dvcmtlci8wOjEvMzYKWyAgIDE2LjM0Nzg0MF0gY2FsbGVyIGlzIGRlYnVn
X3NtcF9wcm9jZXNzb3JfaWQrMHgxMi8weDIwClsgICAxNi4zNDg1NzFdIENQVTogMSBQSUQ6
IDM2IENvbW06IGt3b3JrZXIvMDoxIE5vdCB0YWludGVkIDMuMTYuMC1yYzYtbmV4dC0yMDE0
MDcyNSAjNDA0ClsgICAxNi4zNDk1MTddIEhhcmR3YXJlIG5hbWU6IEJvY2hzIEJvY2hzLCBC
SU9TIEJvY2hzIDAxLzAxLzIwMTEKWyAgIDE2LjM1MDQ0OV0gV29ya3F1ZXVlOiBldmVudHMg
dm1zdGF0X3VwZGF0ZQpbICAgMTYuMzUwOTcwXSAgMDAwMDAwMDEgOTE0ZmRlNDQgODI5MWI0
MjYgMDAwMDAwMDAgMDAwMDAwMDEgODMxNjUzYzUgOTE0ZmRlNzQgODE3NmViMDQKWyAgIDE2
LjM1MjEwOF0gIDgzMWFiYjQwIDgzMWFhY2JiIDgzMTY1M2M1IDAwMDAwMDAwIDkxNGYxOTI0
IDAwMDAwMDI0IDgzMWFhY2JiIDgzYzQzMzIwClsgICAxNi4zNTMyMzZdICAwMDAwMDEyOSA5
MTRkZDkwMCA5MTRmZGU3YyA4MTc2ZWIzMiA5MTRmZGU5MCA4MTFhYjZiMCAwMDAwMDAwMCA5
MjM3OTMyMApbICAgMTYuMzU0Mzc3XSBDYWxsIFRyYWNlOgpbICAgMTYuMzU0Njg2XSAgWzw4
MjkxYjQyNj5dIGR1bXBfc3RhY2srMHg3Zi8weGYzClsgICAxNi4zNTUzMDddICBbPDgxNzZl
YjA0Pl0gY2hlY2tfcHJlZW1wdGlvbl9kaXNhYmxlZCsweDE2NC8weDE4MApbICAgMTYuMzU2
MDAyXSAgWzw4MTc2ZWIzMj5dIGRlYnVnX3NtcF9wcm9jZXNzb3JfaWQrMHgxMi8weDIwClsg
ICAxNi4zNTY5MTVdICBbPDgxMWFiNmIwPl0gdm1zdGF0X3VwZGF0ZSsweDQwLzB4ODAKWyAg
IDE2LjM1NzUxOF0gIFs8ODEwOTRiZWM+XSBwcm9jZXNzX29uZV93b3JrKzB4MzZjLzB4OWUw
ClsgICAxNi4zNTgyMDRdICBbPDgxMDk1MDZmPl0gPyBwcm9jZXNzX29uZV93b3JrKzB4N2Vm
LzB4OWUwClsgICAxNi4zNTg4NzVdICBbPDgxMDk1MjhjPl0gPyB3b3JrZXJfdGhyZWFkKzB4
MmMvMHg5ZDAKWyAgIDE2LjM1OTQ5M10gIFs8ODEwOTU3MzI+XSB3b3JrZXJfdGhyZWFkKzB4
NGQyLzB4OWQwClsgICAxNi4zNjAyMjFdICBbPDgxMDk1MjYwPl0gPyBwcm9jZXNzX29uZV93
b3JrKzB4OWUwLzB4OWUwClsgICAxNi4zNjA4NTRdICBbPDgxMDllYjAyPl0ga3RocmVhZCsw
eGUyLzB4ZjAKWyAgIDE2LjM2MTM4OF0gIFs8ODEwOTUyNjA+XSA/IHByb2Nlc3Nfb25lX3dv
cmsrMHg5ZTAvMHg5ZTAKWyAgIDE2LjM2MjA1N10gIFs8ODEwYTAwMDA+XSA/IGNvcHlfbmFt
ZXNwYWNlcysweDYwLzB4MmYwClsgICAxNi4zNjI3MDBdICBbPDgyOTQ4NTgxPl0gcmV0X2Zy
b21fa2VybmVsX3RocmVhZCsweDIxLzB4MzAKWyAgIDE2LjM2MzU4Nl0gIFs8ODEwOWVhMjA+
XSA/IGluc2VydF9rdGhyZWFkX3dvcmsrMHgxMDAvMHgxMDAKCkVsYXBzZWQgdGltZTogNQpx
ZW11LXN5c3RlbS14ODZfNjQgLWVuYWJsZS1rdm0gLWNwdSBIYXN3ZWxsLCtzbWVwLCtzbWFw
IC1rZXJuZWwgL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LzVhNzQzOWVm
ZDFjNWM0MTZmNzY4ZmM1NTAwNDhjYTEzMGNmNGJmOTkvdm1saW51ei0zLjE2LjAtcmM2LW5l
eHQtMjAxNDA3MjUgLWFwcGVuZCAnaHVuZ190YXNrX3BhbmljPTEgZWFybHlwcmludGs9dHR5
UzAsMTE1MjAwIGRlYnVnIGFwaWM9ZGVidWcgc3lzcnFfYWx3YXlzX2VuYWJsZWQgcmN1cGRh
dGUucmN1X2NwdV9zdGFsbF90aW1lb3V0PTEwMCBwYW5pYz0xMCBzb2Z0bG9ja3VwX3Bhbmlj
PTEgbm1pX3dhdGNoZG9nPXBhbmljICBwcm9tcHRfcmFtZGlzaz0wIGNvbnNvbGU9dHR5UzAs
MTE1MjAwIGNvbnNvbGU9dHR5MCB2Z2E9bm9ybWFsICByb290PS9kZXYvcmFtMCBydyBsaW5r
PS9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctaWIwLTA3Mjcx
NzE1L25leHQ6bWFzdGVyOjVhNzQzOWVmZDFjNWM0MTZmNzY4ZmM1NTAwNDhjYTEzMGNmNGJm
OTk6YmlzZWN0LWxpbnV4NS8udm1saW51ei01YTc0MzllZmQxYzVjNDE2Zjc2OGZjNTUwMDQ4
Y2ExMzBjZjRiZjk5LTIwMTQwNzI3MTcyMTU2LTIta2J1aWxkIGJyYW5jaD1uZXh0L21hc3Rl
ciBCT09UX0lNQUdFPS9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS81YTc0
MzllZmQxYzVjNDE2Zjc2OGZjNTUwMDQ4Y2ExMzBjZjRiZjk5L3ZtbGludXotMy4xNi4wLXJj
Ni1uZXh0LTIwMTQwNzI1IGRyYmQubWlub3JfY291bnQ9OCcgIC1pbml0cmQgL2tlcm5lbC10
ZXN0cy9pbml0cmQvcXVhbnRhbC1jb3JlLWkzODYuY2d6IC1tIDMyMCAtc21wIDIgLW5ldCBu
aWMsdmxhbj0xLG1vZGVsPWUxMDAwIC1uZXQgdXNlcix2bGFuPTEgLWJvb3Qgb3JkZXI9bmMg
LW5vLXJlYm9vdCAtd2F0Y2hkb2cgaTYzMDBlc2IgLXJ0YyBiYXNlPWxvY2FsdGltZSAtcGlk
ZmlsZSAvZGV2L3NobS9rYm9vdC9waWQtcXVhbnRhbC1rYnVpbGQtMTUgLXNlcmlhbCBmaWxl
Oi9kZXYvc2htL2tib290L3NlcmlhbC1xdWFudGFsLWtidWlsZC0xNSAtZGFlbW9uaXplIC1k
aXNwbGF5IG5vbmUgLW1vbml0b3IgbnVsbCAKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIw
LTA3MjcxNzE1LzVhNzQzOWVmZDFjNWM0MTZmNzY4ZmM1NTAwNDhjYTEzMGNmNGJmOTkvZG1l
c2ctcXVhbnRhbC1rYnVpbGQtMTU6MjAxNDA3MjcxNzI3MjE6aTM4Ni1yYW5kY29uZmlnLWli
MC0wNzI3MTcxNTozLjE2LjAtcmM2LW5leHQtMjAxNDA3MjU6NDA0Ci9rZXJuZWwvaTM4Ni1y
YW5kY29uZmlnLWliMC0wNzI3MTcxNS81YTc0MzllZmQxYzVjNDE2Zjc2OGZjNTUwMDQ4Y2Ex
MzBjZjRiZjk5L2RtZXNnLXF1YW50YWwtdnAtOToyMDE0MDcyNzE3MTkwMDppMzg2LXJhbmRj
b25maWctaWIwLTA3MjcxNzE1OjMuMTYuMC1yYzYtbmV4dC0yMDE0MDcyNTo0MDQKOToyOjIg
YWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKCkhFQUQgaXMgbm93IGF0IDVhNzQzOWUgQWRk
IGxpbnV4LW5leHQgc3BlY2lmaWMgZmlsZXMgZm9yIDIwMTQwNzI1Cgo9PT09PT09PT0gbGlu
dXMvbWFzdGVyID09PT09PT09PQpQcmV2aW91cyBIRUFEIHBvc2l0aW9uIHdhcyA1YTc0Mzll
Li4uIEFkZCBsaW51eC1uZXh0IHNwZWNpZmljIGZpbGVzIGZvciAyMDE0MDcyNQpIRUFEIGlz
IG5vdyBhdCAyMDYyYWZiLi4uIEZpeCBnY2MtNC45LjAgbWlzY29tcGlsYXRpb24gb2YgbG9h
ZF9iYWxhbmNlKCkgIGluIHNjaGVkdWxlcgpscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1
ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS9saW51czptYXN0ZXI6MjA2MmFm
YjRmODA0YWZlZjYxY2JlNjJhMzBjYWM5YTQ2ZTU4ZTA2NzpiaXNlY3QtbGludXg1CgoyMDE0
LTA3LTI3LTIyOjM1OjAwIDIwNjJhZmI0ZjgwNGFmZWY2MWNiZTYyYTMwY2FjOWE0NmU1OGUw
NjcgY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQt
cXVldWUvaTM4Ni1yYW5kY29uZmlnLWliMC0wNzI3MTcxNS0yMDYyYWZiNGY4MDRhZmVmNjFj
YmU2MmEzMGNhYzlhNDZlNThlMDY3CkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LzIwNjJhZmI0ZjgwNGFmZWY2MWNiZTYyYTMwY2Fj
OWE0NmU1OGUwNjcKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1
aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUtMjA2MmFmYjRmODA0YWZl
ZjYxY2JlNjJhMzBjYWM5YTQ2ZTU4ZTA2NwprZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29u
ZmlnLWliMC0wNzI3MTcxNS8yMDYyYWZiNGY4MDRhZmVmNjFjYmU2MmEzMGNhYzlhNDZlNThl
MDY3L3ZtbGludXotMy4xNi4wLXJjNi0wMDE0OS1nMjA2MmFmYgoKMjAxNC0wNy0yNy0yMjoz
NzowMCBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLgkyNQkyOAkxMDAJMTQzCTE4MwkxODgJMzAy
CTM0Nwk0MzgJNDk5CTU0MQk2MzAJNjk5CTc5Nwk4MjAJODU2Lgk5MDAgU1VDQ0VTUwoKCj09
PT09PT09PSBuZXh0L21hc3RlciA9PT09PT09PT0KUHJldmlvdXMgSEVBRCBwb3NpdGlvbiB3
YXMgMjA2MmFmYi4uLiBGaXggZ2NjLTQuOS4wIG1pc2NvbXBpbGF0aW9uIG9mIGxvYWRfYmFs
YW5jZSgpICBpbiBzY2hlZHVsZXIKSEVBRCBpcyBub3cgYXQgNWE3NDM5ZS4uLiBBZGQgbGlu
dXgtbmV4dCBzcGVjaWZpYyBmaWxlcyBmb3IgMjAxNDA3MjUKbHMgLWEgL2tidWlsZC10ZXN0
cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvbmV4dDptYXN0
ZXI6NWE3NDM5ZWZkMWM1YzQxNmY3NjhmYzU1MDA0OGNhMTMwY2Y0YmY5OTpiaXNlY3QtbGlu
dXg1CiBURVNUIEZBSUxVUkUKWyAgIDE1LjQ4Nzk2MV0gaG9zdG5hbWUgKDE2NSkgdXNlZCBn
cmVhdGVzdCBzdGFjayBkZXB0aDogNjY4OCBieXRlcyBsZWZ0ClsgICAxNS41MzE1OThdIGh3
Y2xvY2sgKDE2OSkgdXNlZCBncmVhdGVzdCBzdGFjayBkZXB0aDogNjMwOCBieXRlcyBsZWZ0
ClsgICAxNS41MzQzNzBdIHBseW1vdXRoZCAoMTY2KSB1c2VkIGdyZWF0ZXN0IHN0YWNrIGRl
cHRoOiA2MjkyIGJ5dGVzIGxlZnQKWyAgIDE2LjM0NjgxM10gQlVHOiB1c2luZyBzbXBfcHJv
Y2Vzc29yX2lkKCkgaW4gcHJlZW1wdGlibGUgWzAwMDAwMDAwXSBjb2RlOiBrd29ya2VyLzA6
MS8zNgpbICAgMTYuMzQ3ODQwXSBjYWxsZXIgaXMgZGVidWdfc21wX3Byb2Nlc3Nvcl9pZCsw
eDEyLzB4MjAKWyAgIDE2LjM0ODU3MV0gQ1BVOiAxIFBJRDogMzYgQ29tbToga3dvcmtlci8w
OjEgTm90IHRhaW50ZWQgMy4xNi4wLXJjNi1uZXh0LTIwMTQwNzI1ICM0MDQKWyAgIDE2LjM0
OTUxN10gSGFyZHdhcmUgbmFtZTogQm9jaHMgQm9jaHMsIEJJT1MgQm9jaHMgMDEvMDEvMjAx
MQpbICAgMTYuMzUwNDQ5XSBXb3JrcXVldWU6IGV2ZW50cyB2bXN0YXRfdXBkYXRlClsgICAx
Ni4zNTA5NzBdICAwMDAwMDAwMSA5MTRmZGU0NCA4MjkxYjQyNiAwMDAwMDAwMCAwMDAwMDAw
MSA4MzE2NTNjNSA5MTRmZGU3NCA4MTc2ZWIwNApbICAgMTYuMzUyMTA4XSAgODMxYWJiNDAg
ODMxYWFjYmIgODMxNjUzYzUgMDAwMDAwMDAgOTE0ZjE5MjQgMDAwMDAwMjQgODMxYWFjYmIg
ODNjNDMzMjAKWyAgIDE2LjM1MzIzNl0gIDAwMDAwMTI5IDkxNGRkOTAwIDkxNGZkZTdjIDgx
NzZlYjMyIDkxNGZkZTkwIDgxMWFiNmIwIDAwMDAwMDAwIDkyMzc5MzIwClsgICAxNi4zNTQz
NzddIENhbGwgVHJhY2U6ClsgICAxNi4zNTQ2ODZdICBbPDgyOTFiNDI2Pl0gZHVtcF9zdGFj
aysweDdmLzB4ZjMKWyAgIDE2LjM1NTMwN10gIFs8ODE3NmViMDQ+XSBjaGVja19wcmVlbXB0
aW9uX2Rpc2FibGVkKzB4MTY0LzB4MTgwClsgICAxNi4zNTYwMDJdICBbPDgxNzZlYjMyPl0g
ZGVidWdfc21wX3Byb2Nlc3Nvcl9pZCsweDEyLzB4MjAKWyAgIDE2LjM1NjkxNV0gIFs8ODEx
YWI2YjA+XSB2bXN0YXRfdXBkYXRlKzB4NDAvMHg4MApbICAgMTYuMzU3NTE4XSAgWzw4MTA5
NGJlYz5dIHByb2Nlc3Nfb25lX3dvcmsrMHgzNmMvMHg5ZTAKWyAgIDE2LjM1ODIwNF0gIFs8
ODEwOTUwNmY+XSA/IHByb2Nlc3Nfb25lX3dvcmsrMHg3ZWYvMHg5ZTAKWyAgIDE2LjM1ODg3
NV0gIFs8ODEwOTUyOGM+XSA/IHdvcmtlcl90aHJlYWQrMHgyYy8weDlkMApbICAgMTYuMzU5
NDkzXSAgWzw4MTA5NTczMj5dIHdvcmtlcl90aHJlYWQrMHg0ZDIvMHg5ZDAKWyAgIDE2LjM2
MDIyMV0gIFs8ODEwOTUyNjA+XSA/IHByb2Nlc3Nfb25lX3dvcmsrMHg5ZTAvMHg5ZTAKWyAg
IDE2LjM2MDg1NF0gIFs8ODEwOWViMDI+XSBrdGhyZWFkKzB4ZTIvMHhmMApbICAgMTYuMzYx
Mzg4XSAgWzw4MTA5NTI2MD5dID8gcHJvY2Vzc19vbmVfd29yaysweDllMC8weDllMApbICAg
MTYuMzYyMDU3XSAgWzw4MTBhMDAwMD5dID8gY29weV9uYW1lc3BhY2VzKzB4NjAvMHgyZjAK
WyAgIDE2LjM2MjcwMF0gIFs8ODI5NDg1ODE+XSByZXRfZnJvbV9rZXJuZWxfdGhyZWFkKzB4
MjEvMHgzMApbICAgMTYuMzYzNTg2XSAgWzw4MTA5ZWEyMD5dID8gaW5zZXJ0X2t0aHJlYWRf
d29yaysweDEwMC8weDEwMAoKRWxhcHNlZCB0aW1lOiA1CnFlbXUtc3lzdGVtLXg4Nl82NCAt
ZW5hYmxlLWt2bSAtY3B1IEhhc3dlbGwsK3NtZXAsK3NtYXAgLWtlcm5lbCAva2VybmVsL2kz
ODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvNWE3NDM5ZWZkMWM1YzQxNmY3NjhmYzU1MDA0
OGNhMTMwY2Y0YmY5OS92bWxpbnV6LTMuMTYuMC1yYzYtbmV4dC0yMDE0MDcyNSAtYXBwZW5k
ICdodW5nX3Rhc2tfcGFuaWM9MSBlYXJseXByaW50az10dHlTMCwxMTUyMDAgZGVidWcgYXBp
Yz1kZWJ1ZyBzeXNycV9hbHdheXNfZW5hYmxlZCByY3VwZGF0ZS5yY3VfY3B1X3N0YWxsX3Rp
bWVvdXQ9MTAwIHBhbmljPTEwIHNvZnRsb2NrdXBfcGFuaWM9MSBubWlfd2F0Y2hkb2c9cGFu
aWMgIHByb21wdF9yYW1kaXNrPTAgY29uc29sZT10dHlTMCwxMTUyMDAgY29uc29sZT10dHkw
IHZnYT1ub3JtYWwgIHJvb3Q9L2Rldi9yYW0wIHJ3IGxpbms9L2tidWlsZC10ZXN0cy9ydW4t
cXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvbmV4dDptYXN0ZXI6NWE3
NDM5ZWZkMWM1YzQxNmY3NjhmYzU1MDA0OGNhMTMwY2Y0YmY5OTpiaXNlY3QtbGludXg1Ly52
bWxpbnV6LTVhNzQzOWVmZDFjNWM0MTZmNzY4ZmM1NTAwNDhjYTEzMGNmNGJmOTktMjAxNDA3
MjcxNzIxNTYtMi1rYnVpbGQgYnJhbmNoPW5leHQvbWFzdGVyIEJPT1RfSU1BR0U9L2tlcm5l
bC9pMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1LzVhNzQzOWVmZDFjNWM0MTZmNzY4ZmM1
NTAwNDhjYTEzMGNmNGJmOTkvdm1saW51ei0zLjE2LjAtcmM2LW5leHQtMjAxNDA3MjUgZHJi
ZC5taW5vcl9jb3VudD04JyAgLWluaXRyZCAva2VybmVsLXRlc3RzL2luaXRyZC9xdWFudGFs
LWNvcmUtaTM4Ni5jZ3ogLW0gMzIwIC1zbXAgMiAtbmV0IG5pYyx2bGFuPTEsbW9kZWw9ZTEw
MDAgLW5ldCB1c2VyLHZsYW49MSAtYm9vdCBvcmRlcj1uYyAtbm8tcmVib290IC13YXRjaGRv
ZyBpNjMwMGVzYiAtcnRjIGJhc2U9bG9jYWx0aW1lIC1waWRmaWxlIC9kZXYvc2htL2tib290
L3BpZC1xdWFudGFsLWtidWlsZC0xNSAtc2VyaWFsIGZpbGU6L2Rldi9zaG0va2Jvb3Qvc2Vy
aWFsLXF1YW50YWwta2J1aWxkLTE1IC1kYWVtb25pemUgLWRpc3BsYXkgbm9uZSAtbW9uaXRv
ciBudWxsIAova2VybmVsL2kzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTUvNWE3NDM5ZWZk
MWM1YzQxNmY3NjhmYzU1MDA0OGNhMTMwY2Y0YmY5OS9kbWVzZy1xdWFudGFsLWtidWlsZC0x
NToyMDE0MDcyNzE3MjcyMTppMzg2LXJhbmRjb25maWctaWIwLTA3MjcxNzE1OjMuMTYuMC1y
YzYtbmV4dC0yMDE0MDcyNTo0MDQKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctaWIwLTA3Mjcx
NzE1LzVhNzQzOWVmZDFjNWM0MTZmNzY4ZmM1NTAwNDhjYTEzMGNmNGJmOTkvZG1lc2ctcXVh
bnRhbC12cC05OjIwMTQwNzI3MTcxOTAwOmkzODYtcmFuZGNvbmZpZy1pYjAtMDcyNzE3MTU6
My4xNi4wLXJjNi1uZXh0LTIwMTQwNzI1OjQwNAo5OjI6MiBhbGxfZ29vZDpiYWQ6YWxsX2Jh
ZCBib290cwoK

--XvKFcGCOAo53UbWW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.16.0-rc6-00251-g6e0a6b1"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 3.16.0-rc6 Kernel Configuration
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf32-i386"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
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
# CONFIG_ZONE_DMA32 is not set
# CONFIG_AUDIT_ARCH is not set
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_32_SMP=y
CONFIG_X86_HT=y
CONFIG_X86_32_LAZY_GS=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-ecx -fcall-saved-edx"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

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
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
CONFIG_KERNEL_XZ=y
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
# CONFIG_POSIX_MQUEUE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_FHANDLE is not set
CONFIG_USELIB=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_LEGACY_ALLOC_HWIRQ=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_DEBUG=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_KTIME_SCALAR=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
CONFIG_NO_HZ=y
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_BSD_PROCESS_ACCT is not set
CONFIG_TASKSTATS=y
# CONFIG_TASK_DELAY_ACCT is not set
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y

#
# RCU Subsystem
#
CONFIG_TREE_PREEMPT_RCU=y
CONFIG_PREEMPT_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_FANOUT=32
CONFIG_RCU_FANOUT_LEAF=16
CONFIG_RCU_FANOUT_EXACT=y
CONFIG_RCU_FAST_NO_HZ=y
CONFIG_TREE_RCU_TRACE=y
CONFIG_RCU_BOOST=y
CONFIG_RCU_BOOST_PRIO=1
CONFIG_RCU_BOOST_DELAY=500
CONFIG_RCU_NOCB_CPU=y
# CONFIG_RCU_NOCB_CPU_NONE is not set
# CONFIG_RCU_NOCB_CPU_ZERO is not set
CONFIG_RCU_NOCB_CPU_ALL=y
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
# CONFIG_CGROUPS is not set
# CONFIG_CHECKPOINT_RESTORE is not set
# CONFIG_NAMESPACES is not set
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
CONFIG_RD_LZMA=y
# CONFIG_RD_XZ is not set
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
# CONFIG_ELF_CORE is not set
# CONFIG_PCSPKR_PLATFORM is not set
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
# CONFIG_SIGNALFD is not set
# CONFIG_TIMERFD is not set
# CONFIG_EVENTFD is not set
CONFIG_SHMEM=y
# CONFIG_AIO is not set
CONFIG_PCI_QUIRKS=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y

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
# CONFIG_SLOB is not set
# CONFIG_SLUB_CPU_PARTIAL is not set
# CONFIG_SYSTEM_TRUSTED_KEYRING is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
CONFIG_UPROBES=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
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
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
# CONFIG_LBDAF is not set
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
CONFIG_BLK_CMDLINE_PARSER=y

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_AMIGA_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_EFI_PARTITION=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
# CONFIG_IOSCHED_DEADLINE is not set
CONFIG_IOSCHED_CFQ=y
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_PADATA=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUE_RWLOCK=y
CONFIG_QUEUE_RWLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_BIGSMP=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_MID is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_RDC321X=y
# CONFIG_X86_32_NON_STANDARD is not set
# CONFIG_X86_32_IRIS is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_LGUEST_GUEST is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
CONFIG_MWINCHIP3D=y
# CONFIG_MELAN is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
# CONFIG_X86_GENERIC is not set
CONFIG_X86_INTERNODE_CACHE_SHIFT=5
CONFIG_X86_L1_CACHE_SHIFT=5
CONFIG_X86_ALIGNMENT_16=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_MINIMUM_CPU_FAMILY=4
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_CYRIX_32=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_TRANSMETA_32=y
CONFIG_CPU_SUP_UMC_32=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_NR_CPUS=32
# CONFIG_SCHED_SMT is not set
# CONFIG_SCHED_MC is not set
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
# CONFIG_X86_MCE is not set
# CONFIG_VM86 is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX32=y
CONFIG_TOSHIBA=y
CONFIG_I8K=y
CONFIG_X86_REBOOTFIXUPS=y
# CONFIG_MICROCODE is not set
# CONFIG_MICROCODE_INTEL_EARLY is not set
# CONFIG_MICROCODE_AMD_EARLY is not set
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
# CONFIG_NOHIGHMEM is not set
CONFIG_HIGHMEM4G=y
# CONFIG_HIGHMEM64G is not set
# CONFIG_VMSPLIT_3G is not set
# CONFIG_VMSPLIT_3G_OPT is not set
CONFIG_VMSPLIT_2G=y
# CONFIG_VMSPLIT_2G_OPT is not set
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0x80000000
CONFIG_HIGHMEM=y
CONFIG_NEED_NODE_MEMMAP_SIZE=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
# CONFIG_FLATMEM_MANUAL is not set
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
# CONFIG_PHYS_ADDR_T_64BIT is not set
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
CONFIG_CLEANCACHE=y
CONFIG_FRONTSWAP=y
# CONFIG_CMA is not set
# CONFIG_ZBUD is not set
# CONFIG_ZSWAP is not set
CONFIG_ZSMALLOC=y
CONFIG_PGTABLE_MAPPING=y
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_HIGHPTE=y
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
CONFIG_MATH_EMULATION=y
# CONFIG_MTRR is not set
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_EFI=y
CONFIG_EFI_STUB=y
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
# CONFIG_SCHED_HRTICK is not set
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
CONFIG_BOOTPARAM_HOTPLUG_CPU0=y
CONFIG_DEBUG_HOTPLUG_CPU0=y
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_HIBERNATION is not set
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
# CONFIG_PM_WAKELOCKS_GC is not set
# CONFIG_PM_RUNTIME is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
# CONFIG_ACPI_BATTERY is not set
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
# CONFIG_ACPI_THERMAL is not set
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_PCI_SLOT=y
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
CONFIG_ACPI_CUSTOM_METHOD=y
# CONFIG_ACPI_BGRT is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_ACPI_APEI=y
# CONFIG_ACPI_APEI_GHES is not set
CONFIG_ACPI_APEI_EINJ=y
# CONFIG_ACPI_APEI_ERST_DEBUG is not set
# CONFIG_SFI is not set
CONFIG_X86_APM_BOOT=y
CONFIG_APM=y
CONFIG_APM_IGNORE_USER_SUSPEND=y
# CONFIG_APM_DO_ENABLE is not set
# CONFIG_APM_CPU_IDLE is not set
# CONFIG_APM_DISPLAY_BLANK is not set
CONFIG_APM_ALLOW_INTS=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_MULTIPLE_DRIVERS=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
# CONFIG_PCI_GOOLPC is not set
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_OLPC=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCI_CNB20LE_QUIRK=y
# CONFIG_PCIEPORTBUS is not set
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_REALLOC_ENABLE_AUTO=y
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_IOAPIC=y
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
CONFIG_ISA=y
CONFIG_EISA=y
# CONFIG_EISA_VLB_PRIMING is not set
# CONFIG_EISA_PCI_EISA is not set
CONFIG_EISA_VIRTUAL_ROOT=y
# CONFIG_EISA_NAMES is not set
CONFIG_SCx200=y
CONFIG_SCx200HR_TIMER=y
CONFIG_OLPC=y
# CONFIG_OLPC_XO1_PM is not set
CONFIG_OLPC_XO15_SCI=y
# CONFIG_ALIX is not set
# CONFIG_NET5501 is not set
# CONFIG_GEOS is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
# CONFIG_PCMCIA is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=y
CONFIG_YENTA_O2=y
# CONFIG_YENTA_RICOH is not set
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
CONFIG_PCMCIA_PROBE=y
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=y
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_IOSF_MBI=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=y
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
# CONFIG_XFRM_SUB_POLICY is not set
CONFIG_XFRM_MIGRATE=y
CONFIG_NET_KEY=y
CONFIG_NET_KEY_MIGRATE=y
# CONFIG_INET is not set
CONFIG_NETWORK_SECMARK=y
CONFIG_NET_PTP_CLASSIFY=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
CONFIG_ATM=y
CONFIG_ATM_LANE=y
CONFIG_STP=y
CONFIG_GARP=y
CONFIG_MRP=y
CONFIG_BRIDGE=y
# CONFIG_BRIDGE_VLAN_FILTERING is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_NET_DSA=y
CONFIG_NET_DSA_TAG_DSA=y
CONFIG_VLAN_8021Q=y
CONFIG_VLAN_8021Q_GVRP=y
CONFIG_VLAN_8021Q_MVRP=y
CONFIG_DECNET=y
# CONFIG_DECNET_ROUTER is not set
CONFIG_LLC=y
# CONFIG_LLC2 is not set
CONFIG_IPX=y
# CONFIG_IPX_INTERN is not set
# CONFIG_ATALK is not set
CONFIG_X25=y
CONFIG_LAPB=y
CONFIG_PHONET=y
CONFIG_IEEE802154=y
# CONFIG_MAC802154 is not set
# CONFIG_NET_SCHED is not set
CONFIG_DCB=y
# CONFIG_DNS_RESOLVER is not set
# CONFIG_BATMAN_ADV is not set
CONFIG_OPENVSWITCH=y
CONFIG_VSOCKETS=y
CONFIG_VMWARE_VMCI_VSOCKETS=y
# CONFIG_NETLINK_MMAP is not set
# CONFIG_NETLINK_DIAG is not set
CONFIG_NET_MPLS_GSO=y
# CONFIG_HSR is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
CONFIG_AX25=y
# CONFIG_AX25_DAMA_SLAVE is not set
# CONFIG_NETROM is not set
# CONFIG_ROSE is not set

#
# AX.25 network device drivers
#
CONFIG_MKISS=y
# CONFIG_6PACK is not set
# CONFIG_BPQETHER is not set
CONFIG_SCC=y
# CONFIG_SCC_DELAY is not set
CONFIG_SCC_TRXECHO=y
CONFIG_BAYCOM_SER_FDX=y
CONFIG_BAYCOM_SER_HDX=y
CONFIG_BAYCOM_PAR=y
CONFIG_BAYCOM_EPP=y
CONFIG_YAM=y
CONFIG_CAN=y
CONFIG_CAN_RAW=y
CONFIG_CAN_BCM=y
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
# CONFIG_CAN_VCAN is not set
CONFIG_CAN_SLCAN=y
# CONFIG_CAN_DEV is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=y

#
# IrDA protocols
#
CONFIG_IRLAN=y
CONFIG_IRCOMM=y
# CONFIG_IRDA_ULTRA is not set

#
# IrDA options
#
# CONFIG_IRDA_CACHE_LAST_LSAP is not set
CONFIG_IRDA_FAST_RR=y
# CONFIG_IRDA_DEBUG is not set

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
CONFIG_IRTTY_SIR=y

#
# Dongle support
#
CONFIG_DONGLE=y
CONFIG_ESI_DONGLE=y
CONFIG_ACTISYS_DONGLE=y
CONFIG_TEKRAM_DONGLE=y
# CONFIG_TOIM3232_DONGLE is not set
# CONFIG_LITELINK_DONGLE is not set
CONFIG_MA600_DONGLE=y
# CONFIG_GIRBIL_DONGLE is not set
# CONFIG_MCP2120_DONGLE is not set
# CONFIG_OLD_BELKIN_DONGLE is not set
CONFIG_ACT200L_DONGLE=y

#
# FIR device drivers
#
CONFIG_NSC_FIR=y
CONFIG_WINBOND_FIR=y
# CONFIG_TOSHIBA_FIR is not set
CONFIG_SMC_IRCC_FIR=y
# CONFIG_ALI_FIR is not set
CONFIG_VLSI_FIR=y
# CONFIG_VIA_FIR is not set
CONFIG_BT=y
CONFIG_BT_RFCOMM=y
CONFIG_BT_RFCOMM_TTY=y
CONFIG_BT_BNEP=y
# CONFIG_BT_BNEP_MC_FILTER is not set
# CONFIG_BT_BNEP_PROTO_FILTER is not set
# CONFIG_BT_HIDP is not set

#
# Bluetooth device drivers
#
CONFIG_BT_HCIBTSDIO=y
CONFIG_BT_HCIUART=y
CONFIG_BT_HCIUART_H4=y
# CONFIG_BT_HCIUART_BCSP is not set
CONFIG_BT_HCIUART_ATH3K=y
# CONFIG_BT_HCIUART_LL is not set
CONFIG_BT_HCIUART_3WIRE=y
CONFIG_BT_HCIVHCI=y
# CONFIG_BT_MRVL is not set
# CONFIG_BT_WILINK is not set
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
CONFIG_RFKILL_REGULATOR=y
CONFIG_RFKILL_GPIO=y
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
CONFIG_NFC=y
# CONFIG_NFC_DIGITAL is not set
# CONFIG_NFC_NCI is not set
CONFIG_NFC_HCI=y
CONFIG_NFC_SHDLC=y

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_MEI_PHY=y
CONFIG_NFC_SIM=y
CONFIG_NFC_PN544=y
CONFIG_NFC_PN544_I2C=y
CONFIG_NFC_PN544_MEI=y
# CONFIG_NFC_MICROREAD is not set
CONFIG_NFC_ST21NFCA=y
CONFIG_NFC_ST21NFCA_I2C=y

#
# Device Drivers
#

#
# Generic Driver Options
#
# CONFIG_UEVENT_HELPER is not set
# CONFIG_DEVTMPFS is not set
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y

#
# Bus devices
#
CONFIG_CONNECTOR=y
# CONFIG_PROC_EVENTS is not set
CONFIG_MTD=y
# CONFIG_MTD_REDBOOT_PARTS is not set
CONFIG_MTD_CMDLINE_PARTS=y
CONFIG_MTD_OF_PARTS=y
# CONFIG_MTD_AR7_PARTS is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
# CONFIG_FTL is not set
CONFIG_NFTL=y
# CONFIG_NFTL_RW is not set
CONFIG_INFTL=y
# CONFIG_RFD_FTL is not set
CONFIG_SSFDC=y
# CONFIG_SM_FTL is not set
CONFIG_MTD_OOPS=y
CONFIG_MTD_SWAP=y

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_CFI_INTELEXT=y
# CONFIG_MTD_CFI_AMDSTD is not set
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
# CONFIG_MTD_ROM is not set
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
CONFIG_MTD_PHYSMAP=y
CONFIG_MTD_PHYSMAP_COMPAT=y
CONFIG_MTD_PHYSMAP_START=0x8000000
CONFIG_MTD_PHYSMAP_LEN=0
CONFIG_MTD_PHYSMAP_BANKWIDTH=2
CONFIG_MTD_PHYSMAP_OF=y
# CONFIG_MTD_AMD76XROM is not set
CONFIG_MTD_ICHXROM=y
CONFIG_MTD_ESB2ROM=y
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
CONFIG_MTD_INTEL_VR_NOR=y
# CONFIG_MTD_PLATRAM is not set

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_DATAFLASH is not set
CONFIG_MTD_M25P80=y
CONFIG_MTD_SST25L=y
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
# CONFIG_MTD_MTDRAM is not set
# CONFIG_MTD_BLOCK2MTD is not set

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=y
CONFIG_MTD_NAND_BCH=y
CONFIG_MTD_NAND_ECC_BCH=y
CONFIG_MTD_SM_COMMON=y
CONFIG_MTD_NAND_DENALI=y
# CONFIG_MTD_NAND_DENALI_PCI is not set
# CONFIG_MTD_NAND_GPIO is not set
CONFIG_MTD_NAND_IDS=y
CONFIG_MTD_NAND_RICOH=y
# CONFIG_MTD_NAND_DISKONCHIP is not set
# CONFIG_MTD_NAND_DOCG4 is not set
CONFIG_MTD_NAND_CAFE=y
CONFIG_MTD_NAND_CS553X=y
CONFIG_MTD_NAND_NANDSIM=y
CONFIG_MTD_NAND_PLATFORM=y
CONFIG_MTD_ONENAND=y
# CONFIG_MTD_ONENAND_VERIFY_WRITE is not set
CONFIG_MTD_ONENAND_GENERIC=y
CONFIG_MTD_ONENAND_OTP=y
# CONFIG_MTD_ONENAND_2X_PROGRAM is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
# CONFIG_MTD_LPDDR is not set
CONFIG_MTD_SPI_NOR=y
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
CONFIG_MTD_UBI_GLUEBI=y
# CONFIG_MTD_UBI_BLOCK is not set
CONFIG_OF=y

#
# Device Tree and Open Firmware support
#
# CONFIG_OF_SELFTEST is not set
CONFIG_OF_PROMTREE=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_ADDRESS_PCI=y
CONFIG_OF_IRQ=y
CONFIG_OF_NET=y
CONFIG_OF_MDIO=y
CONFIG_OF_PCI=y
CONFIG_OF_PCI_IRQ=y
CONFIG_OF_MTD=y
CONFIG_PARPORT=y
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT_PC=y
# CONFIG_PARPORT_PC_FIFO is not set
CONFIG_PARPORT_PC_SUPERIO=y
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=y
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_ISAPNP=y
CONFIG_PNPBIOS=y
CONFIG_PNPBIOS_PROC_FS=y
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
# CONFIG_BLK_DEV_FD is not set
# CONFIG_PARIDE is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_ZRAM is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set

#
# DRBD disabled because PROC_FS or INET not selected
#
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
# CONFIG_AD525X_DPOT_SPI is not set
CONFIG_DUMMY_IRQ=y
CONFIG_IBM_ASM=y
CONFIG_PHANTOM=y
CONFIG_SGI_IOC4=y
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_CS5535_MFGPT=y
CONFIG_CS5535_MFGPT_DEFAULT_IRQ=7
CONFIG_CS5535_CLOCK_EVENT_SRC=y
CONFIG_HP_ILO=y
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1780=y
# CONFIG_SENSORS_BH1770 is not set
CONFIG_SENSORS_APDS990X=y
# CONFIG_HMC6352 is not set
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
# CONFIG_VMWARE_BALLOON is not set
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
# CONFIG_BMP085_SPI is not set
# CONFIG_PCH_PHUB is not set
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_LATTICE_ECP3_CONFIG=y
# CONFIG_SRAM is not set
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_AT25 is not set
# CONFIG_EEPROM_LEGACY is not set
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
# CONFIG_EEPROM_93XX46 is not set
CONFIG_CB710_CORE=y
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
CONFIG_TI_ST=y
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
CONFIG_INTEL_MEI=y
# CONFIG_INTEL_MEI_ME is not set
CONFIG_INTEL_MEI_TXE=y
CONFIG_VMWARE_VMCI=y

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#
# CONFIG_ECHO is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
CONFIG_IDE_LEGACY=y
CONFIG_BLK_DEV_IDE_SATA=y
CONFIG_IDE_GD=y
# CONFIG_IDE_GD_ATA is not set
CONFIG_IDE_GD_ATAPI=y
CONFIG_BLK_DEV_DELKIN=y
# CONFIG_BLK_DEV_IDECD is not set
CONFIG_BLK_DEV_IDETAPE=y
# CONFIG_BLK_DEV_IDEACPI is not set
# CONFIG_IDE_TASK_IOCTL is not set
# CONFIG_IDE_PROC_FS is not set

#
# IDE chipset support/bugfixes
#
# CONFIG_IDE_GENERIC is not set
CONFIG_BLK_DEV_PLATFORM=y
CONFIG_BLK_DEV_CMD640=y
CONFIG_BLK_DEV_CMD640_ENHANCED=y
CONFIG_BLK_DEV_IDEPNP=y
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
# CONFIG_BLK_DEV_OFFBOARD is not set
# CONFIG_BLK_DEV_GENERIC is not set
CONFIG_BLK_DEV_OPTI621=y
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
CONFIG_BLK_DEV_AMD74XX=y
CONFIG_BLK_DEV_ATIIXP=y
CONFIG_BLK_DEV_CMD64X=y
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CS5520 is not set
CONFIG_BLK_DEV_CS5530=y
CONFIG_BLK_DEV_CS5535=y
CONFIG_BLK_DEV_CS5536=y
# CONFIG_BLK_DEV_HPT366 is not set
CONFIG_BLK_DEV_JMICRON=y
CONFIG_BLK_DEV_SC1200=y
CONFIG_BLK_DEV_PIIX=y
CONFIG_BLK_DEV_IT8172=y
CONFIG_BLK_DEV_IT8213=y
CONFIG_BLK_DEV_IT821X=y
CONFIG_BLK_DEV_NS87415=y
CONFIG_BLK_DEV_PDC202XX_OLD=y
CONFIG_BLK_DEV_PDC202XX_NEW=y
# CONFIG_BLK_DEV_SVWKS is not set
CONFIG_BLK_DEV_SIIMAGE=y
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
CONFIG_BLK_DEV_TRM290=y
# CONFIG_BLK_DEV_VIA82CXXX is not set
CONFIG_BLK_DEV_TC86C001=y

#
# Other IDE chipsets support
#

#
# Note: most of these also require special kernel boot parameters
#
CONFIG_BLK_DEV_4DRIVES=y
# CONFIG_BLK_DEV_ALI14XX is not set
CONFIG_BLK_DEV_DTC2278=y
CONFIG_BLK_DEV_HT6560B=y
CONFIG_BLK_DEV_QD65XX=y
# CONFIG_BLK_DEV_UMC8672 is not set
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=y
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=y
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=y
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=y
CONFIG_CHR_DEV_SCH=y
CONFIG_SCSI_ENCLOSURE=y
# CONFIG_SCSI_MULTI_LUN is not set
CONFIG_SCSI_CONSTANTS=y
# CONFIG_SCSI_LOGGING is not set
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_FC_TGT_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
CONFIG_SCSI_SAS_ATA=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=y
# CONFIG_SCSI_SRP_TGT_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_BOOT_SYSFS=y
CONFIG_SCSI_BNX2_ISCSI=y
# CONFIG_SCSI_BNX2X_FCOE is not set
CONFIG_BE2ISCSI=y
CONFIG_BLK_DEV_3W_XXXX_RAID=y
# CONFIG_SCSI_HPSA is not set
CONFIG_SCSI_3W_9XXX=y
# CONFIG_SCSI_3W_SAS is not set
CONFIG_SCSI_7000FASST=y
CONFIG_SCSI_ACARD=y
CONFIG_SCSI_AHA152X=y
CONFIG_SCSI_AHA1542=y
CONFIG_SCSI_AHA1740=y
CONFIG_SCSI_AACRAID=y
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE=32
CONFIG_AIC7XXX_RESET_DELAY_MS=5000
# CONFIG_AIC7XXX_BUILD_FIRMWARE is not set
# CONFIG_AIC7XXX_DEBUG_ENABLE is not set
CONFIG_AIC7XXX_DEBUG_MASK=0
# CONFIG_AIC7XXX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC79XX=y
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=5000
# CONFIG_AIC79XX_BUILD_FIRMWARE is not set
CONFIG_AIC79XX_DEBUG_ENABLE=y
CONFIG_AIC79XX_DEBUG_MASK=0
CONFIG_AIC79XX_REG_PRETTY_PRINT=y
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_MVSAS is not set
CONFIG_SCSI_MVUMI=y
CONFIG_SCSI_DPT_I2O=y
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_IN2000 is not set
# CONFIG_SCSI_ARCMSR is not set
CONFIG_SCSI_ESAS2R=y
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=y
CONFIG_MEGARAID_MAILBOX=y
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
CONFIG_SCSI_MPT2SAS=y
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
CONFIG_SCSI_MPT2SAS_LOGGING=y
CONFIG_SCSI_MPT3SAS=y
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
CONFIG_SCSI_MPT3SAS_LOGGING=y
CONFIG_SCSI_UFSHCD=y
CONFIG_SCSI_UFSHCD_PCI=y
CONFIG_SCSI_UFSHCD_PLATFORM=y
CONFIG_SCSI_HPTIOP=y
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_VMWARE_PVSCSI is not set
# CONFIG_HYPERV_STORAGE is not set
CONFIG_LIBFC=y
CONFIG_LIBFCOE=y
CONFIG_FCOE=y
CONFIG_FCOE_FNIC=y
# CONFIG_SCSI_DMX3191D is not set
CONFIG_SCSI_DTC3280=y
CONFIG_SCSI_EATA=y
# CONFIG_SCSI_EATA_TAGGED_QUEUE is not set
CONFIG_SCSI_EATA_LINKED_COMMANDS=y
CONFIG_SCSI_EATA_MAX_TAGS=16
CONFIG_SCSI_FUTURE_DOMAIN=y
CONFIG_SCSI_GDTH=y
CONFIG_SCSI_ISCI=y
CONFIG_SCSI_GENERIC_NCR5380=y
CONFIG_SCSI_GENERIC_NCR5380_MMIO=y
# CONFIG_SCSI_GENERIC_NCR53C400 is not set
CONFIG_SCSI_IPS=y
CONFIG_SCSI_INITIO=y
CONFIG_SCSI_INIA100=y
# CONFIG_SCSI_PPA is not set
CONFIG_SCSI_IMM=y
CONFIG_SCSI_IZIP_EPP16=y
CONFIG_SCSI_IZIP_SLOW_CTR=y
CONFIG_SCSI_NCR53C406A=y
# CONFIG_SCSI_STEX is not set
CONFIG_SCSI_SYM53C8XX_2=y
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
# CONFIG_SCSI_SYM53C8XX_MMIO is not set
# CONFIG_SCSI_IPR is not set
# CONFIG_SCSI_PAS16 is not set
# CONFIG_SCSI_QLOGIC_FAS is not set
CONFIG_SCSI_QLOGIC_1280=y
# CONFIG_SCSI_QLA_FC is not set
CONFIG_SCSI_QLA_ISCSI=y
# CONFIG_SCSI_LPFC is not set
CONFIG_SCSI_SIM710=y
CONFIG_SCSI_SYM53C416=y
# CONFIG_SCSI_DC395x is not set
CONFIG_SCSI_DC390T=y
CONFIG_SCSI_T128=y
CONFIG_SCSI_U14_34F=y
CONFIG_SCSI_U14_34F_TAGGED_QUEUE=y
# CONFIG_SCSI_U14_34F_LINKED_COMMANDS is not set
CONFIG_SCSI_U14_34F_MAX_TAGS=8
CONFIG_SCSI_ULTRASTOR=y
CONFIG_SCSI_NSP32=y
CONFIG_SCSI_DEBUG=y
# CONFIG_SCSI_PMCRAID is not set
CONFIG_SCSI_PM8001=y
# CONFIG_SCSI_SRP is not set
# CONFIG_SCSI_BFA_FC is not set
CONFIG_SCSI_VIRTIO=y
# CONFIG_SCSI_CHELSIO_FCOE is not set
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=y
CONFIG_SCSI_DH_ALUA=y
# CONFIG_SCSI_OSD_INITIATOR is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_PMP is not set

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
# CONFIG_SATA_AHCI_PLATFORM is not set
CONFIG_SATA_INIC162X=y
CONFIG_SATA_ACARD_AHCI=y
# CONFIG_SATA_SIL24 is not set
# CONFIG_ATA_SFF is not set
CONFIG_MD=y
# CONFIG_BLK_DEV_MD is not set
# CONFIG_BCACHE is not set
# CONFIG_BLK_DEV_DM is not set
# CONFIG_TARGET_CORE is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
# CONFIG_FIREWIRE_OHCI is not set
# CONFIG_FIREWIRE_SBP2 is not set
CONFIG_FIREWIRE_NOSY=y
# CONFIG_I2O is not set
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
CONFIG_DUMMY=y
# CONFIG_EQUALIZER is not set
# CONFIG_NET_FC is not set
# CONFIG_NET_TEAM is not set
# CONFIG_MACVLAN is not set
CONFIG_NETCONSOLE=y
# CONFIG_NETCONSOLE_DYNAMIC is not set
CONFIG_NETPOLL=y
CONFIG_NET_POLL_CONTROLLER=y
# CONFIG_NTB_NETDEV is not set
CONFIG_TUN=y
# CONFIG_VETH is not set
CONFIG_VIRTIO_NET=y
# CONFIG_NLMON is not set
CONFIG_ARCNET=y
CONFIG_ARCNET_1201=y
CONFIG_ARCNET_1051=y
# CONFIG_ARCNET_RAW is not set
CONFIG_ARCNET_CAP=y
CONFIG_ARCNET_COM90xx=y
CONFIG_ARCNET_COM90xxIO=y
CONFIG_ARCNET_RIM_I=y
# CONFIG_ARCNET_COM20020 is not set
CONFIG_ATM_DRIVERS=y
# CONFIG_ATM_DUMMY is not set
CONFIG_ATM_LANAI=y
# CONFIG_ATM_ENI is not set
# CONFIG_ATM_FIRESTREAM is not set
CONFIG_ATM_ZATM=y
CONFIG_ATM_ZATM_DEBUG=y
CONFIG_ATM_NICSTAR=y
# CONFIG_ATM_NICSTAR_USE_SUNI is not set
CONFIG_ATM_NICSTAR_USE_IDT77105=y
CONFIG_ATM_IDT77252=y
# CONFIG_ATM_IDT77252_DEBUG is not set
CONFIG_ATM_IDT77252_RCV_ALL=y
CONFIG_ATM_IDT77252_USE_SUNI=y
# CONFIG_ATM_AMBASSADOR is not set
CONFIG_ATM_HORIZON=y
CONFIG_ATM_HORIZON_DEBUG=y
CONFIG_ATM_IA=y
# CONFIG_ATM_IA_DEBUG is not set
# CONFIG_ATM_FORE200E is not set
# CONFIG_ATM_HE is not set
CONFIG_ATM_SOLOS=y

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
CONFIG_NET_DSA_MV88E6XXX=y
# CONFIG_NET_DSA_MV88E6060 is not set
CONFIG_NET_DSA_MV88E6XXX_NEED_PPU=y
CONFIG_NET_DSA_MV88E6131=y
# CONFIG_NET_DSA_MV88E6123_61_65 is not set
CONFIG_ETHERNET=y
CONFIG_MDIO=y
CONFIG_NET_VENDOR_3COM=y
CONFIG_EL3=y
# CONFIG_3C515 is not set
# CONFIG_VORTEX is not set
CONFIG_TYPHOON=y
# CONFIG_NET_VENDOR_ADAPTEC is not set
# CONFIG_NET_VENDOR_ALTEON is not set
CONFIG_ALTERA_TSE=y
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
CONFIG_LANCE=y
# CONFIG_PCNET32 is not set
CONFIG_NI65=y
CONFIG_AMD_XGBE=y
# CONFIG_NET_VENDOR_ARC is not set
# CONFIG_NET_VENDOR_ATHEROS is not set
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_B44=y
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
CONFIG_BCMGENET=y
CONFIG_BNX2=y
CONFIG_CNIC=y
CONFIG_TIGON3=y
CONFIG_BNX2X=y
# CONFIG_BNX2X_SRIOV is not set
# CONFIG_SYSTEMPORT is not set
# CONFIG_NET_VENDOR_BROCADE is not set
# CONFIG_NET_CALXEDA_XGMAC is not set
# CONFIG_NET_VENDOR_CHELSIO is not set
# CONFIG_NET_VENDOR_CIRRUS is not set
CONFIG_NET_VENDOR_CISCO=y
CONFIG_ENIC=y
CONFIG_CX_ECAT=y
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
CONFIG_DL2K=y
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=y
# CONFIG_NET_VENDOR_EXAR is not set
CONFIG_NET_VENDOR_HP=y
CONFIG_HP100=y
CONFIG_NET_VENDOR_INTEL=y
CONFIG_E100=y
CONFIG_E1000=y
# CONFIG_E1000E is not set
# CONFIG_IGB is not set
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
CONFIG_IXGBE_DCB=y
CONFIG_IXGBEVF=y
CONFIG_I40E=y
# CONFIG_I40E_DCB is not set
# CONFIG_I40EVF is not set
# CONFIG_NET_VENDOR_I825XX is not set
# CONFIG_IP1000 is not set
CONFIG_JME=y
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_MVMDIO=y
# CONFIG_SKGE is not set
CONFIG_SKY2=y
CONFIG_SKY2_DEBUG=y
# CONFIG_NET_VENDOR_MELLANOX is not set
CONFIG_NET_VENDOR_MICREL=y
CONFIG_KS8851=y
CONFIG_KS8851_MLL=y
CONFIG_KSZ884X_PCI=y
CONFIG_NET_VENDOR_MICROCHIP=y
CONFIG_ENC28J60=y
CONFIG_ENC28J60_WRITEVERIFY=y
CONFIG_FEALNX=y
# CONFIG_NET_VENDOR_NATSEMI is not set
# CONFIG_NET_VENDOR_NVIDIA is not set
# CONFIG_NET_VENDOR_OKI is not set
CONFIG_ETHOC=y
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
CONFIG_YELLOWFIN=y
# CONFIG_NET_VENDOR_QLOGIC is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
CONFIG_R8169=y
CONFIG_SH_ETH=y
CONFIG_NET_VENDOR_RDC=y
CONFIG_R6040=y
CONFIG_NET_VENDOR_SAMSUNG=y
CONFIG_SXGBE_ETH=y
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
# CONFIG_NET_VENDOR_SIS is not set
CONFIG_SFC=y
# CONFIG_SFC_MTD is not set
# CONFIG_SFC_MCDI_MON is not set
CONFIG_SFC_SRIOV=y
# CONFIG_NET_VENDOR_SMSC is not set
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
# CONFIG_NET_VENDOR_SUN is not set
# CONFIG_NET_VENDOR_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
CONFIG_TLAN=y
# CONFIG_NET_VENDOR_VIA is not set
CONFIG_NET_VENDOR_WIZNET=y
CONFIG_WIZNET_W5100=y
CONFIG_WIZNET_W5300=y
CONFIG_WIZNET_BUS_DIRECT=y
# CONFIG_WIZNET_BUS_INDIRECT is not set
# CONFIG_WIZNET_BUS_ANY is not set
CONFIG_FDDI=y
# CONFIG_DEFXX is not set
CONFIG_SKFP=y
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_AT803X_PHY is not set
# CONFIG_AMD_PHY is not set
CONFIG_AMD_XGBE_PHY=y
CONFIG_MARVELL_PHY=y
CONFIG_DAVICOM_PHY=y
CONFIG_QSEMI_PHY=y
# CONFIG_LXT_PHY is not set
CONFIG_CICADA_PHY=y
# CONFIG_VITESSE_PHY is not set
CONFIG_SMSC_PHY=y
CONFIG_BROADCOM_PHY=y
CONFIG_BCM7XXX_PHY=y
CONFIG_BCM87XX_PHY=y
CONFIG_ICPLUS_PHY=y
CONFIG_REALTEK_PHY=y
CONFIG_NATIONAL_PHY=y
CONFIG_STE10XP=y
CONFIG_LSI_ET1011C_PHY=y
CONFIG_MICREL_PHY=y
CONFIG_FIXED_PHY=y
CONFIG_MDIO_BITBANG=y
CONFIG_MDIO_GPIO=y
CONFIG_MDIO_BUS_MUX=y
# CONFIG_MDIO_BUS_MUX_GPIO is not set
CONFIG_MDIO_BUS_MUX_MMIOREG=y
# CONFIG_MICREL_KS8995MA is not set
# CONFIG_PLIP is not set
# CONFIG_PPP is not set
CONFIG_SLIP=y
# CONFIG_SLIP_COMPRESSED is not set
CONFIG_SLIP_SMART=y
# CONFIG_SLIP_MODE_SLIP6 is not set
CONFIG_WLAN=y
CONFIG_PRISM54=y
# CONFIG_HOSTAP is not set
# CONFIG_WL_TI is not set

#
# WiMAX Wireless Broadband devices
#

#
# Enable USB support to see WiMAX USB drivers
#
# CONFIG_WAN is not set
CONFIG_IEEE802154_DRIVERS=y
CONFIG_IEEE802154_FAKEHARD=y
CONFIG_HYPERV_NET=y
CONFIG_ISDN=y
# CONFIG_ISDN_I4L is not set
# CONFIG_ISDN_CAPI is not set
CONFIG_ISDN_DRV_GIGASET=y
CONFIG_GIGASET_DUMMYLL=y
CONFIG_GIGASET_M101=y
CONFIG_GIGASET_DEBUG=y
CONFIG_MISDN=y
CONFIG_MISDN_DSP=y
# CONFIG_MISDN_L1OIP is not set

#
# mISDN hardware drivers
#
# CONFIG_MISDN_HFCPCI is not set
CONFIG_MISDN_HFCMULTI=y
# CONFIG_MISDN_AVMFRITZ is not set
CONFIG_MISDN_SPEEDFAX=y
CONFIG_MISDN_INFINEON=y
CONFIG_MISDN_W6692=y
# CONFIG_MISDN_NETJET is not set
CONFIG_MISDN_IPAC=y
CONFIG_MISDN_ISAR=y

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_EVDEV is not set
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
CONFIG_KEYBOARD_QT2160=y
CONFIG_KEYBOARD_LKKBD=y
# CONFIG_KEYBOARD_GPIO is not set
CONFIG_KEYBOARD_GPIO_POLLED=y
CONFIG_KEYBOARD_TCA6416=y
CONFIG_KEYBOARD_TCA8418=y
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
CONFIG_KEYBOARD_LM8333=y
# CONFIG_KEYBOARD_MAX7359 is not set
CONFIG_KEYBOARD_MCS=y
# CONFIG_KEYBOARD_MPR121 is not set
CONFIG_KEYBOARD_NEWTON=y
CONFIG_KEYBOARD_OPENCORES=y
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_KEYBOARD_SUNKBD=y
# CONFIG_KEYBOARD_OMAP4 is not set
CONFIG_KEYBOARD_TC3589X=y
CONFIG_KEYBOARD_TWL4030=y
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_KEYBOARD_CROS_EC=y
# CONFIG_INPUT_LEDS is not set
# CONFIG_INPUT_MOUSE is not set
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=y
CONFIG_JOYSTICK_A3D=y
CONFIG_JOYSTICK_ADI=y
CONFIG_JOYSTICK_COBRA=y
CONFIG_JOYSTICK_GF2K=y
# CONFIG_JOYSTICK_GRIP is not set
# CONFIG_JOYSTICK_GRIP_MP is not set
# CONFIG_JOYSTICK_GUILLEMOT is not set
CONFIG_JOYSTICK_INTERACT=y
CONFIG_JOYSTICK_SIDEWINDER=y
# CONFIG_JOYSTICK_TMDC is not set
CONFIG_JOYSTICK_IFORCE=y
CONFIG_JOYSTICK_IFORCE_232=y
# CONFIG_JOYSTICK_WARRIOR is not set
CONFIG_JOYSTICK_MAGELLAN=y
CONFIG_JOYSTICK_SPACEORB=y
# CONFIG_JOYSTICK_SPACEBALL is not set
# CONFIG_JOYSTICK_STINGER is not set
# CONFIG_JOYSTICK_TWIDJOY is not set
CONFIG_JOYSTICK_ZHENHUA=y
CONFIG_JOYSTICK_DB9=y
# CONFIG_JOYSTICK_GAMECON is not set
# CONFIG_JOYSTICK_TURBOGRAFX is not set
# CONFIG_JOYSTICK_AS5011 is not set
CONFIG_JOYSTICK_JOYDUMP=y
# CONFIG_JOYSTICK_XPAD is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
# CONFIG_SERIO_PARKBD is not set
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
# CONFIG_SERIO_ARC_PS2 is not set
# CONFIG_SERIO_APBPS2 is not set
CONFIG_SERIO_OLPC_APSP=y
CONFIG_HYPERV_KEYBOARD=y
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
CONFIG_GAMEPORT_EMU10K1=y
CONFIG_GAMEPORT_FM801=y

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
# CONFIG_UNIX98_PTYS is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_ROCKETPORT=y
# CONFIG_CYCLADES is not set
CONFIG_MOXA_INTELLIO=y
CONFIG_MOXA_SMARTIO=y
# CONFIG_SYNCLINK is not set
CONFIG_SYNCLINKMP=y
CONFIG_SYNCLINK_GT=y
# CONFIG_NOZOMI is not set
CONFIG_ISI=y
# CONFIG_N_HDLC is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_ROUTER is not set
CONFIG_TRACE_SINK=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
# CONFIG_SERIAL_8250_PNP is not set
CONFIG_SERIAL_8250_CONSOLE=y
# CONFIG_SERIAL_8250_PCI is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
# CONFIG_SERIAL_8250_FOURPORT is not set
CONFIG_SERIAL_8250_ACCENT=y
# CONFIG_SERIAL_8250_BOCA is not set
# CONFIG_SERIAL_8250_EXAR_ST16C554 is not set
# CONFIG_SERIAL_8250_HUB6 is not set
# CONFIG_SERIAL_8250_SHARE_IRQ is not set
CONFIG_SERIAL_8250_DETECT_IRQ=y
# CONFIG_SERIAL_8250_RSA is not set
CONFIG_SERIAL_8250_DW=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
CONFIG_SERIAL_MAX310X=y
CONFIG_SERIAL_MFD_HSU=y
# CONFIG_SERIAL_MFD_HSU_CONSOLE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_OF_PLATFORM=y
# CONFIG_SERIAL_SCCNXP is not set
CONFIG_SERIAL_SC16IS7XX=y
CONFIG_SERIAL_TIMBERDALE=y
CONFIG_SERIAL_ALTERA_JTAGUART=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
# CONFIG_SERIAL_ALTERA_UART_CONSOLE is not set
# CONFIG_SERIAL_IFX6X60 is not set
# CONFIG_SERIAL_PCH_UART is not set
CONFIG_SERIAL_XILINX_PS_UART=y
CONFIG_SERIAL_XILINX_PS_UART_CONSOLE=y
CONFIG_SERIAL_ARC=y
# CONFIG_SERIAL_ARC_CONSOLE is not set
CONFIG_SERIAL_ARC_NR_PORTS=1
CONFIG_SERIAL_RP2=y
CONFIG_SERIAL_RP2_NR_UARTS=32
CONFIG_SERIAL_FSL_LPUART=y
# CONFIG_SERIAL_FSL_LPUART_CONSOLE is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=y
# CONFIG_VIRTIO_CONSOLE is not set
CONFIG_IPMI_HANDLER=y
CONFIG_IPMI_PANIC_EVENT=y
CONFIG_IPMI_PANIC_STRING=y
# CONFIG_IPMI_DEVICE_INTERFACE is not set
CONFIG_IPMI_SI=y
# CONFIG_IPMI_SI_PROBE_DEFAULTS is not set
# CONFIG_IPMI_WATCHDOG is not set
CONFIG_IPMI_POWEROFF=y
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
# CONFIG_HW_RANDOM_INTEL is not set
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_GEODE=y
CONFIG_HW_RANDOM_VIA=y
# CONFIG_HW_RANDOM_VIRTIO is not set
CONFIG_HW_RANDOM_TPM=y
# CONFIG_NVRAM is not set
CONFIG_DTLK=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
CONFIG_SONYPI=y
# CONFIG_MWAVE is not set
# CONFIG_SCx200_GPIO is not set
CONFIG_PC8736x_GPIO=y
CONFIG_NSC_GPIO=y
# CONFIG_RAW_DRIVER is not set
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
# CONFIG_HPET_MMAP_DEFAULT is not set
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
CONFIG_TCG_TIS_I2C_ATMEL=y
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_TIS_I2C_NUVOTON=y
# CONFIG_TCG_NSC is not set
# CONFIG_TCG_ATMEL is not set
CONFIG_TCG_INFINEON=y
# CONFIG_TCG_ST33_I2C is not set
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_ARB_GPIO_CHALLENGE=y
CONFIG_I2C_MUX_GPIO=y
# CONFIG_I2C_MUX_PCA9541 is not set
CONFIG_I2C_MUX_PCA954x=y
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
CONFIG_I2C_ALI1563=y
CONFIG_I2C_ALI15X3=y
# CONFIG_I2C_AMD756 is not set
CONFIG_I2C_AMD8111=y
# CONFIG_I2C_I801 is not set
CONFIG_I2C_ISCH=y
CONFIG_I2C_ISMT=y
CONFIG_I2C_PIIX4=y
CONFIG_I2C_NFORCE2=y
CONFIG_I2C_NFORCE2_S4985=y
CONFIG_I2C_SIS5595=y
CONFIG_I2C_SIS630=y
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
CONFIG_I2C_SCMI=y

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
CONFIG_I2C_DESIGNWARE_CORE=y
# CONFIG_I2C_DESIGNWARE_PLATFORM is not set
CONFIG_I2C_DESIGNWARE_PCI=y
CONFIG_I2C_EG20T=y
CONFIG_I2C_GPIO=y
# CONFIG_I2C_KEMPLD is not set
CONFIG_I2C_OCORES=y
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA is not set
# CONFIG_I2C_PXA_PCI is not set
# CONFIG_I2C_RK3X is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_PARPORT=y
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_TAOS_EVM is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_PCA_ISA is not set
CONFIG_I2C_CROS_EC_TUNNEL=y
CONFIG_SCx200_ACB=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
CONFIG_SPI_BITBANG=y
# CONFIG_SPI_BUTTERFLY is not set
CONFIG_SPI_GPIO=y
CONFIG_SPI_LM70_LLP=y
# CONFIG_SPI_FSL_SPI is not set
# CONFIG_SPI_OC_TINY is not set
CONFIG_SPI_PXA2XX_DMA=y
CONFIG_SPI_PXA2XX=y
CONFIG_SPI_PXA2XX_PCI=y
# CONFIG_SPI_SC18IS602 is not set
CONFIG_SPI_TOPCLIFF_PCH=y
# CONFIG_SPI_XCOMM is not set
CONFIG_SPI_XILINX=y
CONFIG_SPI_DESIGNWARE=y
# CONFIG_SPI_DW_PCI is not set
CONFIG_SPI_DW_MMIO=y

#
# SPI Protocol Masters
#
CONFIG_SPI_SPIDEV=y
CONFIG_SPI_TLE62X0=y
CONFIG_SPMI=y
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
CONFIG_HSI_CHAR=y

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
CONFIG_PPS_CLIENT_LDISC=y
CONFIG_PPS_CLIENT_PARPORT=y
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# CONFIG_PTP_1588_CLOCK_PCH is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_DA9052=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers:
#
CONFIG_GPIO_GENERIC_PLATFORM=y
# CONFIG_GPIO_DWAPB is not set
CONFIG_GPIO_IT8761E=y
# CONFIG_GPIO_F7188X is not set
# CONFIG_GPIO_SCH311X is not set
CONFIG_GPIO_SCH=y
CONFIG_GPIO_ICH=y
# CONFIG_GPIO_VX855 is not set
CONFIG_GPIO_LYNXPOINT=y
CONFIG_GPIO_GRGPIO=y

#
# I2C GPIO expanders:
#
CONFIG_GPIO_LP3943=y
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
# CONFIG_GPIO_MAX732X_IRQ is not set
# CONFIG_GPIO_PCA953X is not set
CONFIG_GPIO_PCF857X=y
# CONFIG_GPIO_RC5T583 is not set
# CONFIG_GPIO_SX150X is not set
# CONFIG_GPIO_TC3589X is not set
# CONFIG_GPIO_TPS65912 is not set
# CONFIG_GPIO_TWL4030 is not set
CONFIG_GPIO_WM8994=y
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set
CONFIG_GPIO_ADNP=y

#
# PCI GPIO expanders:
#
CONFIG_GPIO_CS5535=y
CONFIG_GPIO_BT8XX=y
CONFIG_GPIO_AMD8111=y
# CONFIG_GPIO_INTEL_MID is not set
CONFIG_GPIO_PCH=y
CONFIG_GPIO_ML_IOH=y
CONFIG_GPIO_SODAVILLE=y
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
CONFIG_GPIO_MAX7301=y
# CONFIG_GPIO_MCP23S08 is not set
CONFIG_GPIO_MC33880=y
# CONFIG_GPIO_74X164 is not set

#
# AC97 GPIO expanders:
#

#
# LPC GPIO expanders:
#
# CONFIG_GPIO_KEMPLD is not set

#
# MODULbus GPIO expanders:
#
CONFIG_GPIO_JANZ_TTL=y
# CONFIG_GPIO_BCM_KONA is not set

#
# USB GPIO expanders:
#
CONFIG_W1=y
# CONFIG_W1_CON is not set

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
# CONFIG_W1_SLAVE_THERM is not set
# CONFIG_W1_SLAVE_SMEM is not set
CONFIG_W1_SLAVE_DS2408=y
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
# CONFIG_W1_SLAVE_DS2413 is not set
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2431=y
CONFIG_W1_SLAVE_DS2433=y
CONFIG_W1_SLAVE_DS2433_CRC=y
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
# CONFIG_PDA_POWER is not set
# CONFIG_MAX8925_POWER is not set
# CONFIG_TEST_POWER is not set
CONFIG_BATTERY_88PM860X=y
# CONFIG_BATTERY_DS2760 is not set
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=y
# CONFIG_BATTERY_OLPC is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27x00 is not set
CONFIG_BATTERY_DA9052=y
# CONFIG_BATTERY_MAX17040 is not set
CONFIG_BATTERY_MAX17042=y
CONFIG_CHARGER_88PM860X=y
CONFIG_CHARGER_PCF50633=y
# CONFIG_CHARGER_MAX8903 is not set
CONFIG_CHARGER_TWL4030=y
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_GPIO=y
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_MAX14577=y
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_BQ24190=y
CONFIG_CHARGER_BQ24735=y
CONFIG_CHARGER_SMB347=y
CONFIG_CHARGER_TPS65090=y
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
CONFIG_SENSORS_AD7314=y
CONFIG_SENSORS_AD7414=y
# CONFIG_SENSORS_AD7418 is not set
CONFIG_SENSORS_ADM1021=y
# CONFIG_SENSORS_ADM1025 is not set
CONFIG_SENSORS_ADM1026=y
# CONFIG_SENSORS_ADM1029 is not set
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7310=y
CONFIG_SENSORS_ADT7410=y
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_K10TEMP=y
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=y
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DA9052_ADC=y
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_MC13783_ADC=y
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
# CONFIG_SENSORS_G762 is not set
# CONFIG_SENSORS_GPIO_FAN is not set
CONFIG_SENSORS_HIH6130=y
# CONFIG_SENSORS_IBMAEM is not set
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_LINEAGE=y
# CONFIG_SENSORS_LTC2945 is not set
# CONFIG_SENSORS_LTC4151 is not set
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=y
# CONFIG_SENSORS_LTC4245 is not set
CONFIG_SENSORS_LTC4260=y
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_MAX1111 is not set
CONFIG_SENSORS_MAX16065=y
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX1668 is not set
CONFIG_SENSORS_MAX197=y
CONFIG_SENSORS_MAX6639=y
# CONFIG_SENSORS_MAX6642 is not set
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_HTU21=y
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_ADCXX=y
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM70=y
CONFIG_SENSORS_LM73=y
# CONFIG_SENSORS_LM75 is not set
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
# CONFIG_SENSORS_LM80 is not set
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
# CONFIG_SENSORS_LM90 is not set
# CONFIG_SENSORS_LM92 is not set
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LM95234=y
# CONFIG_SENSORS_LM95241 is not set
CONFIG_SENSORS_LM95245=y
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
CONFIG_SENSORS_NTC_THERMISTOR=y
# CONFIG_SENSORS_NCT6683 is not set
# CONFIG_SENSORS_NCT6775 is not set
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
# CONFIG_SENSORS_ADM1275 is not set
CONFIG_SENSORS_LM25066=y
CONFIG_SENSORS_LTC2978=y
# CONFIG_SENSORS_MAX16064 is not set
CONFIG_SENSORS_MAX34440=y
CONFIG_SENSORS_MAX8688=y
# CONFIG_SENSORS_UCD9000 is not set
# CONFIG_SENSORS_UCD9200 is not set
CONFIG_SENSORS_ZL6100=y
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=y
# CONFIG_SENSORS_SHTC1 is not set
CONFIG_SENSORS_SIS5595=y
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
# CONFIG_SENSORS_SMSC47M192 is not set
CONFIG_SENSORS_SMSC47B397=y
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
CONFIG_SENSORS_SCH5636=y
CONFIG_SENSORS_SMM665=y
# CONFIG_SENSORS_ADC128D818 is not set
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
# CONFIG_SENSORS_ADS7871 is not set
CONFIG_SENSORS_AMC6821=y
CONFIG_SENSORS_INA209=y
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
CONFIG_SENSORS_VIA686A=y
CONFIG_SENSORS_VT1211=y
CONFIG_SENSORS_VT8231=y
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
# CONFIG_SENSORS_W83795 is not set
# CONFIG_SENSORS_W83L785TS is not set
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_HWMON is not set
# CONFIG_THERMAL_OF is not set
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE=y
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_GOV_STEP_WISE is not set
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_EMULATION is not set
CONFIG_INTEL_POWERCLAMP=y
# CONFIG_ACPI_INT3403_THERMAL is not set
CONFIG_INTEL_SOC_DTS_THERMAL=y

#
# Texas Instruments thermal drivers
#
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
# CONFIG_SOFT_WATCHDOG is not set
# CONFIG_DA9052_WATCHDOG is not set
CONFIG_GPIO_WATCHDOG=y
CONFIG_XILINX_WATCHDOG=y
CONFIG_DW_WATCHDOG=y
# CONFIG_TWL4030_WATCHDOG is not set
CONFIG_RETU_WATCHDOG=y
CONFIG_ACQUIRE_WDT=y
CONFIG_ADVANTECH_WDT=y
# CONFIG_ALIM1535_WDT is not set
CONFIG_ALIM7101_WDT=y
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
CONFIG_GEODE_WDT=y
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
# CONFIG_IBMASR is not set
CONFIG_WAFER_WDT=y
CONFIG_I6300ESB_WDT=y
CONFIG_IE6XX_WDT=y
CONFIG_ITCO_WDT=y
CONFIG_ITCO_VENDOR_SUPPORT=y
CONFIG_IT8712F_WDT=y
# CONFIG_IT87_WDT is not set
CONFIG_HP_WATCHDOG=y
CONFIG_KEMPLD_WDT=y
CONFIG_HPWDT_NMI_DECODING=y
CONFIG_SC1200_WDT=y
CONFIG_SCx200_WDT=y
# CONFIG_PC87413_WDT is not set
# CONFIG_NV_TCO is not set
CONFIG_RDC321X_WDT=y
CONFIG_60XX_WDT=y
CONFIG_SBC8360_WDT=y
CONFIG_SBC7240_WDT=y
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC_SCH311X_WDT is not set
CONFIG_SMSC37B787_WDT=y
CONFIG_VIA_WDT=y
CONFIG_W83627HF_WDT=y
CONFIG_W83877F_WDT=y
CONFIG_W83977F_WDT=y
CONFIG_MACHZ_WDT=y
CONFIG_SBC_EPX_C3_WATCHDOG=y
CONFIG_MEN_A21_WDT=y

#
# ISA-based Watchdog Cards
#
CONFIG_PCWATCHDOG=y
CONFIG_MIXCOMWD=y
# CONFIG_WDT is not set

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=y
CONFIG_WDTPCI=y
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
# CONFIG_SSB_B43_PCI_BRIDGE is not set
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
CONFIG_SSB_SILENT=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
# CONFIG_BCMA_HOST_PCI is not set
# CONFIG_BCMA_HOST_SOC is not set
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
# CONFIG_BCMA_DRIVER_GPIO is not set
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_CS5535=y
CONFIG_MFD_AS3711=y
CONFIG_MFD_AS3722=y
# CONFIG_PMIC_ADP5520 is not set
CONFIG_MFD_AAT2870_CORE=y
CONFIG_MFD_BCM590XX=y
CONFIG_MFD_AXP20X=y
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
CONFIG_MFD_CROS_EC_SPI=y
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
# CONFIG_MFD_DA9052_SPI is not set
CONFIG_MFD_DA9052_I2C=y
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9063 is not set
CONFIG_MFD_MC13XXX=y
# CONFIG_MFD_MC13XXX_SPI is not set
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
CONFIG_HTC_I2CPLD=y
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
CONFIG_MFD_JANZ_CMODIO=y
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX14577=y
# CONFIG_MFD_MAX77686 is not set
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX8907=y
CONFIG_MFD_MAX8925=y
CONFIG_MFD_MAX8997=y
# CONFIG_MFD_MAX8998 is not set
# CONFIG_EZX_PCAP is not set
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
CONFIG_MFD_RDC321X=y
CONFIG_MFD_RTSX_PCI=y
CONFIG_MFD_RC5T583=y
CONFIG_MFD_SEC_CORE=y
# CONFIG_MFD_SI476X_CORE is not set
CONFIG_MFD_SM501=y
# CONFIG_MFD_SM501_GPIO is not set
CONFIG_MFD_SMSC=y
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_SYSCON is not set
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=y
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
CONFIG_MFD_TPS65090=y
CONFIG_MFD_TPS65217=y
CONFIG_MFD_TPS65218=y
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
# CONFIG_MFD_TPS65912_I2C is not set
CONFIG_MFD_TPS65912_SPI=y
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
# CONFIG_MFD_TWL4030_AUDIO is not set
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=y
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TIMBERDALE is not set
CONFIG_MFD_TC3589X=y
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_ARIZONA_SPI is not set
CONFIG_MFD_WM8400=y
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM831X_SPI is not set
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_88PM800=y
# CONFIG_REGULATOR_88PM8607 is not set
CONFIG_REGULATOR_ACT8865=y
CONFIG_REGULATOR_AD5398=y
# CONFIG_REGULATOR_AAT2870 is not set
# CONFIG_REGULATOR_AS3711 is not set
CONFIG_REGULATOR_AS3722=y
# CONFIG_REGULATOR_AXP20X is not set
# CONFIG_REGULATOR_BCM590XX is not set
CONFIG_REGULATOR_DA9052=y
# CONFIG_REGULATOR_DA9210 is not set
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_GPIO=y
CONFIG_REGULATOR_ISL6271A=y
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_LTC3589=y
CONFIG_REGULATOR_MAX14577=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
# CONFIG_REGULATOR_MAX8660 is not set
# CONFIG_REGULATOR_MAX8907 is not set
# CONFIG_REGULATOR_MAX8925 is not set
# CONFIG_REGULATOR_MAX8952 is not set
CONFIG_REGULATOR_MAX8973=y
# CONFIG_REGULATOR_MAX8997 is not set
# CONFIG_REGULATOR_MAX77693 is not set
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
# CONFIG_REGULATOR_MC13892 is not set
# CONFIG_REGULATOR_PCF50633 is not set
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_RC5T583=y
CONFIG_REGULATOR_S2MPA01=y
CONFIG_REGULATOR_S2MPS11=y
CONFIG_REGULATOR_S5M8767=y
# CONFIG_REGULATOR_TPS51632 is not set
# CONFIG_REGULATOR_TPS6105X is not set
# CONFIG_REGULATOR_TPS62360 is not set
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65090=y
CONFIG_REGULATOR_TPS65217=y
CONFIG_REGULATOR_TPS65218=y
CONFIG_REGULATOR_TPS6524X=y
CONFIG_REGULATOR_TPS65912=y
CONFIG_REGULATOR_TWL4030=y
CONFIG_REGULATOR_WM8400=y
CONFIG_REGULATOR_WM8994=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
# CONFIG_MEDIA_RADIO_SUPPORT is not set
CONFIG_MEDIA_RC_SUPPORT=y
# CONFIG_VIDEO_ADV_DEBUG is not set
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
CONFIG_DVB_CORE=y
CONFIG_TTPCI_EEPROM=y
CONFIG_DVB_MAX_ADAPTERS=8
# CONFIG_DVB_DYNAMIC_MINORS is not set

#
# Media drivers
#
CONFIG_RC_CORE=y
CONFIG_RC_MAP=y
# CONFIG_RC_DECODERS is not set
CONFIG_RC_DEVICES=y
# CONFIG_RC_ATI_REMOTE is not set
CONFIG_IR_ENE=y
# CONFIG_IR_IMON is not set
# CONFIG_IR_MCEUSB is not set
CONFIG_IR_ITE_CIR=y
CONFIG_IR_FINTEK=y
# CONFIG_IR_NUVOTON is not set
# CONFIG_IR_REDRAT3 is not set
# CONFIG_IR_STREAMZAP is not set
# CONFIG_IR_WINBOND_CIR is not set
# CONFIG_IR_IGUANA is not set
# CONFIG_IR_TTUSBIR is not set
# CONFIG_IR_IMG is not set
# CONFIG_RC_LOOPBACK is not set
# CONFIG_IR_GPIO_CIR is not set
CONFIG_MEDIA_PCI_SUPPORT=y

#
# Media capture/analog/hybrid TV support
#

#
# Media digital TV PCI Adapters
#
CONFIG_DVB_BUDGET_CORE=y
CONFIG_DVB_BUDGET=y
CONFIG_DVB_BUDGET_CI=y
# CONFIG_DVB_B2C2_FLEXCOP_PCI is not set
CONFIG_DVB_PLUTO2=y
CONFIG_DVB_DM1105=y
# CONFIG_DVB_PT1 is not set
CONFIG_MANTIS_CORE=y
CONFIG_DVB_MANTIS=y
CONFIG_DVB_HOPPER=y
CONFIG_DVB_NGENE=y
# CONFIG_DVB_DDBRIDGE is not set

#
# Supported MMC/SDIO adapters
#
CONFIG_SMS_SDIO_DRV=y

#
# Supported FireWire (IEEE 1394) Adapters
#
# CONFIG_DVB_FIREDTV is not set
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
CONFIG_VIDEO_SAA7146=y
CONFIG_SMS_SIANO_MDTV=y
CONFIG_SMS_SIANO_RC=y

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_MT2131=y

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=y
CONFIG_DVB_STB6100=y
CONFIG_DVB_STV090x=y
CONFIG_DVB_STV6110x=y

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=y
CONFIG_DVB_TDA18271C2DD=y

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_S5H1420=y
CONFIG_DVB_STV0288=y
CONFIG_DVB_STB6000=y
CONFIG_DVB_STV0299=y
CONFIG_DVB_TDA8083=y
CONFIG_DVB_TDA10086=y
CONFIG_DVB_VES1X93=y
CONFIG_DVB_TDA826X=y
CONFIG_DVB_CX24116=y
CONFIG_DVB_SI21XX=y
CONFIG_DVB_TS2020=y
CONFIG_DVB_DS3000=y
CONFIG_DVB_MB86A16=y

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_L64781=y
CONFIG_DVB_TDA1004X=y
CONFIG_DVB_ZL10353=y

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=y
CONFIG_DVB_TDA10021=y
CONFIG_DVB_TDA10023=y
CONFIG_DVB_STV0297=y

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_LGDT330X=y

#
# ISDB-T (terrestrial) frontends
#

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=y

#
# SEC control devices for DVB-S
#
CONFIG_DVB_LNBP21=y
CONFIG_DVB_ISL6423=y
CONFIG_DVB_TDA665x=y

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_INTEL_GTT=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
CONFIG_VGA_SWITCHEROO=y

#
# Direct Rendering Manager
#
CONFIG_DRM=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_LOAD_EDID_FIRMWARE=y
CONFIG_DRM_TTM=y

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
# CONFIG_DRM_I2C_SIL164 is not set
# CONFIG_DRM_I2C_NXP_TDA998X is not set
CONFIG_DRM_PTN3460=y
# CONFIG_DRM_TDFX is not set
CONFIG_DRM_R128=y
# CONFIG_DRM_RADEON is not set
CONFIG_DRM_NOUVEAU=y
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
# CONFIG_DRM_NOUVEAU_BACKLIGHT is not set
CONFIG_DRM_I915=y
# CONFIG_DRM_I915_KMS is not set
CONFIG_DRM_I915_FBDEV=y
# CONFIG_DRM_I915_PRELIMINARY_HW_SUPPORT is not set
# CONFIG_DRM_MGA is not set
# CONFIG_DRM_VIA is not set
CONFIG_DRM_SAVAGE=y
CONFIG_DRM_VMWGFX=y
CONFIG_DRM_VMWGFX_FBCON=y
CONFIG_DRM_GMA500=y
CONFIG_DRM_GMA600=y
# CONFIG_DRM_GMA3600 is not set
# CONFIG_DRM_UDL is not set
CONFIG_DRM_AST=y
# CONFIG_DRM_MGAG200 is not set
CONFIG_DRM_CIRRUS_QEMU=y
CONFIG_DRM_QXL=y
CONFIG_DRM_BOCHS=y

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_DDC=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
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
CONFIG_FB_UVESA=y
CONFIG_FB_VESA=y
# CONFIG_FB_EFI is not set
CONFIG_FB_N411=y
# CONFIG_FB_HGA is not set
# CONFIG_FB_OPENCORES is not set
CONFIG_FB_S1D13XXX=y
CONFIG_FB_NVIDIA=y
# CONFIG_FB_NVIDIA_I2C is not set
CONFIG_FB_NVIDIA_DEBUG=y
# CONFIG_FB_NVIDIA_BACKLIGHT is not set
# CONFIG_FB_RIVA is not set
CONFIG_FB_I740=y
CONFIG_FB_LE80578=y
CONFIG_FB_CARILLO_RANCH=y
# CONFIG_FB_MATROX is not set
CONFIG_FB_RADEON=y
# CONFIG_FB_RADEON_I2C is not set
# CONFIG_FB_RADEON_BACKLIGHT is not set
# CONFIG_FB_RADEON_DEBUG is not set
CONFIG_FB_ATY128=y
CONFIG_FB_ATY128_BACKLIGHT=y
# CONFIG_FB_ATY is not set
CONFIG_FB_S3=y
# CONFIG_FB_S3_DDC is not set
# CONFIG_FB_SAVAGE is not set
CONFIG_FB_SIS=y
CONFIG_FB_SIS_300=y
CONFIG_FB_SIS_315=y
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
CONFIG_FB_KYRO=y
CONFIG_FB_3DFX=y
CONFIG_FB_3DFX_ACCEL=y
# CONFIG_FB_3DFX_I2C is not set
CONFIG_FB_VOODOO1=y
CONFIG_FB_VT8623=y
# CONFIG_FB_TRIDENT is not set
CONFIG_FB_ARK=y
# CONFIG_FB_PM3 is not set
CONFIG_FB_CARMINE=y
CONFIG_FB_CARMINE_DRAM_EVAL=y
# CONFIG_CARMINE_DRAM_CUSTOM is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_SM501 is not set
# CONFIG_FB_VIRTUAL is not set
CONFIG_FB_METRONOME=y
CONFIG_FB_MB862XX=y
CONFIG_FB_MB862XX_PCI_GDC=y
# CONFIG_FB_MB862XX_I2C is not set
CONFIG_FB_BROADSHEET=y
CONFIG_FB_AUO_K190X=y
CONFIG_FB_AUO_K1900=y
# CONFIG_FB_AUO_K1901 is not set
CONFIG_FB_HYPERV=y
CONFIG_FB_SIMPLE=y
CONFIG_FB_SSD1307=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_L4F00242T03 is not set
# CONFIG_LCD_LMS283GF05 is not set
CONFIG_LCD_LTV350QV=y
# CONFIG_LCD_ILI922X is not set
CONFIG_LCD_ILI9320=y
CONFIG_LCD_TDO24M=y
CONFIG_LCD_VGG2432A4=y
CONFIG_LCD_PLATFORM=y
CONFIG_LCD_S6E63M0=y
# CONFIG_LCD_LD9040 is not set
CONFIG_LCD_AMS369FG06=y
# CONFIG_LCD_LMS501KF03 is not set
# CONFIG_LCD_HX8357 is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_BACKLIGHT_CARILLO_RANCH=y
# CONFIG_BACKLIGHT_PWM is not set
CONFIG_BACKLIGHT_DA9052=y
CONFIG_BACKLIGHT_MAX8925=y
CONFIG_BACKLIGHT_APPLE=y
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
# CONFIG_BACKLIGHT_88PM860X is not set
# CONFIG_BACKLIGHT_PCF50633 is not set
CONFIG_BACKLIGHT_AAT2870=y
CONFIG_BACKLIGHT_LM3630A=y
# CONFIG_BACKLIGHT_LM3639 is not set
# CONFIG_BACKLIGHT_LP855X is not set
CONFIG_BACKLIGHT_OT200=y
CONFIG_BACKLIGHT_PANDORA=y
CONFIG_BACKLIGHT_TPS65217=y
CONFIG_BACKLIGHT_AS3711=y
# CONFIG_BACKLIGHT_GPIO is not set
CONFIG_BACKLIGHT_LV5207LP=y
CONFIG_BACKLIGHT_BD6107=y
CONFIG_VGASTATE=y
CONFIG_HDMI=y
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
# CONFIG_LOGO_LINUX_VGA16 is not set
CONFIG_LOGO_LINUX_CLUT224=y
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
CONFIG_HID_AUREAL=y
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
CONFIG_HID_EMS_FF=y
CONFIG_HID_ELECOM=y
CONFIG_HID_EZKEY=y
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_UCLOGIC is not set
CONFIG_HID_WALTOP=y
# CONFIG_HID_GYRATION is not set
# CONFIG_HID_ICADE is not set
# CONFIG_HID_TWINHAN is not set
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
# CONFIG_HID_LENOVO_TPKBD is not set
# CONFIG_HID_LOGITECH is not set
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MICROSOFT=y
# CONFIG_HID_MONTEREY is not set
CONFIG_HID_MULTITOUCH=y
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=y
CONFIG_PANTHERLORD_FF=y
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_FB=y
# CONFIG_HID_PICOLCD_BACKLIGHT is not set
# CONFIG_HID_PICOLCD_LCD is not set
# CONFIG_HID_PICOLCD_LEDS is not set
CONFIG_HID_PICOLCD_CIR=y
# CONFIG_HID_PRIMAX is not set
CONFIG_HID_SAITEK=y
# CONFIG_HID_SAMSUNG is not set
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEELSERIES=y
# CONFIG_HID_SUNPLUS is not set
CONFIG_HID_RMI=y
CONFIG_HID_GREENASIA=y
CONFIG_GREENASIA_FF=y
CONFIG_HID_HYPERV_MOUSE=y
CONFIG_HID_SMARTJOYPLUS=y
CONFIG_SMARTJOYPLUS_FF=y
CONFIG_HID_TIVO=y
# CONFIG_HID_TOPSEED is not set
CONFIG_HID_THINGM=y
CONFIG_HID_THRUSTMASTER=y
# CONFIG_THRUSTMASTER_FF is not set
CONFIG_HID_WACOM=y
CONFIG_HID_WIIMOTE=y
CONFIG_HID_XINMO=y
# CONFIG_HID_ZEROPLUS is not set
CONFIG_HID_ZYDACRON=y
# CONFIG_HID_SENSOR_HUB is not set

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set

#
# USB port drivers
#

#
# USB Physical Layer drivers
#
# CONFIG_USB_PHY is not set
# CONFIG_NOP_USB_XCEIV is not set
# CONFIG_SAMSUNG_USB2PHY is not set
# CONFIG_SAMSUNG_USB3PHY is not set
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_TAHVO_USB is not set
# CONFIG_USB_GADGET is not set
CONFIG_UWB=y
# CONFIG_UWB_WHCI is not set
CONFIG_MMC=y
# CONFIG_MMC_DEBUG is not set
# CONFIG_MMC_CLKGATE is not set

#
# MMC/SD/SDIO Card Drivers
#
# CONFIG_MMC_BLOCK is not set
CONFIG_SDIO_UART=y
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
# CONFIG_MMC_SDHCI_PCI is not set
CONFIG_MMC_SDHCI_ACPI=y
# CONFIG_MMC_SDHCI_PLTFM is not set
# CONFIG_MMC_WBSD is not set
CONFIG_MMC_TIFM_SD=y
CONFIG_MMC_CB710=y
CONFIG_MMC_VIA_SDMMC=y
# CONFIG_MMC_USDHI6ROL0 is not set
CONFIG_MMC_REALTEK_PCI=y
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
CONFIG_MEMSTICK_UNSAFE_RESUME=y
CONFIG_MSPRO_BLOCK=y
CONFIG_MS_BLOCK=y

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=y
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_MEMSTICK_REALTEK_PCI=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_PCA9532=y
CONFIG_LEDS_PCA9532_GPIO=y
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
CONFIG_LEDS_LP5562=y
# CONFIG_LEDS_LP8501 is not set
# CONFIG_LEDS_CLEVO_MAIL is not set
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_PWM=y
CONFIG_LEDS_REGULATOR=y
# CONFIG_LEDS_BD2802 is not set
CONFIG_LEDS_INTEL_SS4200=y
CONFIG_LEDS_LT3593=y
# CONFIG_LEDS_DELL_NETBOOKS is not set
# CONFIG_LEDS_MC13783 is not set
# CONFIG_LEDS_TCA6507 is not set
CONFIG_LEDS_MAX8997=y
# CONFIG_LEDS_LM355x is not set
CONFIG_LEDS_OT200=y

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
# CONFIG_LEDS_BLINKM is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=y
# CONFIG_LEDS_TRIGGER_HEARTBEAT is not set
# CONFIG_LEDS_TRIGGER_BACKLIGHT is not set
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=y
# CONFIG_LEDS_TRIGGER_CAMERA is not set
# CONFIG_ACCESSIBILITY is not set
CONFIG_EDAC=y
# CONFIG_EDAC_LEGACY_SYSFS is not set
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_MM_EDAC=y
CONFIG_EDAC_AMD76X=y
# CONFIG_EDAC_E7XXX is not set
CONFIG_EDAC_E752X=y
# CONFIG_EDAC_I82875P is not set
CONFIG_EDAC_I82975X=y
CONFIG_EDAC_I3000=y
CONFIG_EDAC_I3200=y
CONFIG_EDAC_X38=y
CONFIG_EDAC_I5400=y
# CONFIG_EDAC_I82860 is not set
# CONFIG_EDAC_R82600 is not set
CONFIG_EDAC_I5000=y
# CONFIG_EDAC_I5100 is not set
# CONFIG_EDAC_I7300 is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
CONFIG_RTC_INTF_DEV_UIE_EMUL=y
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM860X=y
CONFIG_RTC_DRV_88PM80X=y
CONFIG_RTC_DRV_AS3722=y
CONFIG_RTC_DRV_DS1307=y
# CONFIG_RTC_DRV_DS1374 is not set
# CONFIG_RTC_DRV_DS1672 is not set
# CONFIG_RTC_DRV_DS3232 is not set
CONFIG_RTC_DRV_HYM8563=y
# CONFIG_RTC_DRV_MAX6900 is not set
# CONFIG_RTC_DRV_MAX8907 is not set
CONFIG_RTC_DRV_MAX8925=y
# CONFIG_RTC_DRV_MAX8997 is not set
CONFIG_RTC_DRV_RS5C372=y
CONFIG_RTC_DRV_ISL1208=y
# CONFIG_RTC_DRV_ISL12022 is not set
CONFIG_RTC_DRV_ISL12057=y
CONFIG_RTC_DRV_X1205=y
CONFIG_RTC_DRV_PCF2127=y
CONFIG_RTC_DRV_PCF8523=y
CONFIG_RTC_DRV_PCF8563=y
CONFIG_RTC_DRV_PCF8583=y
CONFIG_RTC_DRV_M41T80=y
CONFIG_RTC_DRV_M41T80_WDT=y
# CONFIG_RTC_DRV_BQ32K is not set
# CONFIG_RTC_DRV_TWL4030 is not set
# CONFIG_RTC_DRV_RC5T583 is not set
# CONFIG_RTC_DRV_S35390A is not set
CONFIG_RTC_DRV_FM3130=y
# CONFIG_RTC_DRV_RX8581 is not set
# CONFIG_RTC_DRV_RX8025 is not set
# CONFIG_RTC_DRV_EM3027 is not set
# CONFIG_RTC_DRV_RV3029C2 is not set
# CONFIG_RTC_DRV_S5M is not set

#
# SPI RTC drivers
#
CONFIG_RTC_DRV_M41T93=y
CONFIG_RTC_DRV_M41T94=y
# CONFIG_RTC_DRV_DS1305 is not set
# CONFIG_RTC_DRV_DS1343 is not set
# CONFIG_RTC_DRV_DS1347 is not set
CONFIG_RTC_DRV_DS1390=y
CONFIG_RTC_DRV_MAX6902=y
CONFIG_RTC_DRV_R9701=y
CONFIG_RTC_DRV_RS5C348=y
CONFIG_RTC_DRV_DS3234=y
# CONFIG_RTC_DRV_PCF2123 is not set
CONFIG_RTC_DRV_RX4581=y
CONFIG_RTC_DRV_MCP795=y

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
# CONFIG_RTC_DRV_DS1286 is not set
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1742=y
CONFIG_RTC_DRV_DA9052=y
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_MSM6242 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
CONFIG_RTC_DRV_RP5C01=y
# CONFIG_RTC_DRV_V3020 is not set
CONFIG_RTC_DRV_DS2404=y
CONFIG_RTC_DRV_PCF50633=y

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_MC13XXX=y
CONFIG_RTC_DRV_SNVS=y
# CONFIG_RTC_DRV_MOXART is not set
CONFIG_RTC_DRV_XGENE=y

#
# HID Sensor RTC drivers
#
# CONFIG_DMADEVICES is not set
CONFIG_AUXDISPLAY=y
# CONFIG_KS0108 is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
# CONFIG_UIO_PDRV_GENIRQ is not set
CONFIG_UIO_DMEM_GENIRQ=y
# CONFIG_UIO_AEC is not set
CONFIG_UIO_SERCOS3=y
# CONFIG_UIO_PCI_GENERIC is not set
CONFIG_UIO_NETX=y
CONFIG_UIO_MF624=y
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_BALLOON is not set
CONFIG_VIRTIO_MMIO=y
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=y
# CONFIG_HYPERV_UTILS is not set
CONFIG_HYPERV_BALLOON=y
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACER_WMI is not set
CONFIG_ACERHDF=y
# CONFIG_ALIENWARE_WMI is not set
# CONFIG_ASUS_LAPTOP is not set
CONFIG_DELL_WMI=y
CONFIG_DELL_WMI_AIO=y
CONFIG_DELL_SMO8800=y
CONFIG_FUJITSU_LAPTOP=y
CONFIG_FUJITSU_LAPTOP_DEBUG=y
CONFIG_FUJITSU_TABLET=y
# CONFIG_AMILO_RFKILL is not set
CONFIG_TC1100_WMI=y
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
CONFIG_HP_WMI=y
# CONFIG_MSI_LAPTOP is not set
CONFIG_PANASONIC_LAPTOP=y
CONFIG_COMPAL_LAPTOP=y
CONFIG_SONY_LAPTOP=y
# CONFIG_SONYPI_COMPAT is not set
# CONFIG_IDEAPAD_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
CONFIG_SENSORS_HDAPS=y
CONFIG_ACPI_WMI=y
# CONFIG_MSI_WMI is not set
CONFIG_TOPSTAR_LAPTOP=y
CONFIG_ACPI_TOSHIBA=y
# CONFIG_TOSHIBA_BT_RFKILL is not set
CONFIG_ACPI_CMPC=y
CONFIG_INTEL_IPS=y
CONFIG_IBM_RTL=y
CONFIG_XO1_RFKILL=y
# CONFIG_XO15_EBOOK is not set
# CONFIG_SAMSUNG_LAPTOP is not set
CONFIG_MXM_WMI=y
CONFIG_INTEL_OAKTRAIL=y
CONFIG_SAMSUNG_Q10=y
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
CONFIG_PVPANIC=y
# CONFIG_CHROME_PLATFORMS is not set

#
# SOC (System On Chip) specific Drivers
#

#
# Hardware Spinlock drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
# CONFIG_MAILBOX is not set
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
# CONFIG_DEVFREQ_GOV_USERSPACE is not set

#
# DEVFREQ Drivers
#
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_EXTCON_GPIO=y
# CONFIG_EXTCON_MAX14577 is not set
# CONFIG_EXTCON_MAX77693 is not set
# CONFIG_EXTCON_MAX8997 is not set
CONFIG_MEMORY=y
# CONFIG_IIO is not set
CONFIG_NTB=y
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
CONFIG_VME_CA91CX42=y
# CONFIG_VME_TSI148 is not set

#
# VME Board Drivers
#
CONFIG_VMIVME_7805=y

#
# VME Device Drivers
#
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
# CONFIG_PWM_FSL_FTM is not set
CONFIG_PWM_LP3943=y
CONFIG_PWM_LPSS=y
CONFIG_PWM_PCA9685=y
CONFIG_PWM_TWL=y
# CONFIG_PWM_TWL_LED is not set
CONFIG_IRQCHIP=y
# CONFIG_IPACK_BUS is not set
CONFIG_RESET_CONTROLLER=y
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_BCM_KONA_USB2_PHY=y
# CONFIG_PHY_SAMSUNG_USB2 is not set
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=y
# CONFIG_MCB is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_DELL_RBU=y
# CONFIG_DCDBAS is not set
CONFIG_DMIID=y
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# EFI (Extensible Firmware Interface) Support
#
CONFIG_EFI_VARS=y
# CONFIG_EFI_VARS_PSTORE is not set
# CONFIG_EFI_RUNTIME_MAP is not set
CONFIG_UEFI_CPER=y

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
# CONFIG_EXT2_FS_XATTR is not set
# CONFIG_EXT2_FS_XIP is not set
# CONFIG_EXT3_FS is not set
CONFIG_EXT4_FS=y
# CONFIG_EXT4_USE_FOR_EXT23 is not set
CONFIG_EXT4_FS_POSIX_ACL=y
# CONFIG_EXT4_FS_SECURITY is not set
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
CONFIG_REISERFS_CHECK=y
# CONFIG_REISERFS_PROC_INFO is not set
# CONFIG_REISERFS_FS_XATTR is not set
CONFIG_JFS_FS=y
# CONFIG_JFS_POSIX_ACL is not set
CONFIG_JFS_SECURITY=y
# CONFIG_JFS_DEBUG is not set
CONFIG_JFS_STATISTICS=y
# CONFIG_XFS_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
CONFIG_BTRFS_DEBUG=y
# CONFIG_BTRFS_ASSERT is not set
CONFIG_NILFS2_FS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
# CONFIG_INOTIFY_USER is not set
CONFIG_FANOTIFY=y
CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
# CONFIG_PRINT_QUOTA_WARNING is not set
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
# CONFIG_CUSE is not set

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
CONFIG_FSCACHE_DEBUG=y
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=y
# CONFIG_CACHEFILES_DEBUG is not set
CONFIG_CACHEFILES_HISTOGRAM=y

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
# CONFIG_JOLIET is not set
CONFIG_ZISOFS=y
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
# CONFIG_PROC_VMCORE is not set
# CONFIG_PROC_SYSCTL is not set
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
CONFIG_TMPFS_XATTR=y
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ADFS_FS=y
CONFIG_ADFS_FS_RW=y
CONFIG_AFFS_FS=y
CONFIG_ECRYPT_FS=y
CONFIG_ECRYPT_FS_MESSAGING=y
CONFIG_HFS_FS=y
CONFIG_HFSPLUS_FS=y
# CONFIG_HFSPLUS_FS_POSIX_ACL is not set
CONFIG_BEFS_FS=y
# CONFIG_BEFS_DEBUG is not set
CONFIG_BFS_FS=y
CONFIG_EFS_FS=y
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
# CONFIG_JFFS2_FS_WRITEBUFFER is not set
# CONFIG_JFFS2_SUMMARY is not set
# CONFIG_JFFS2_FS_XATTR is not set
# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
CONFIG_JFFS2_ZLIB=y
# CONFIG_JFFS2_LZO is not set
CONFIG_JFFS2_RTIME=y
# CONFIG_JFFS2_RUBIN is not set
CONFIG_UBIFS_FS=y
# CONFIG_UBIFS_FS_ADVANCED_COMPR is not set
CONFIG_UBIFS_FS_LZO=y
CONFIG_UBIFS_FS_ZLIB=y
# CONFIG_LOGFS is not set
CONFIG_CRAMFS=y
CONFIG_SQUASHFS=y
CONFIG_SQUASHFS_FILE_CACHE=y
# CONFIG_SQUASHFS_FILE_DIRECT is not set
# CONFIG_SQUASHFS_DECOMP_SINGLE is not set
# CONFIG_SQUASHFS_DECOMP_MULTI is not set
CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU=y
# CONFIG_SQUASHFS_XATTR is not set
# CONFIG_SQUASHFS_ZLIB is not set
CONFIG_SQUASHFS_LZO=y
CONFIG_SQUASHFS_XZ=y
CONFIG_SQUASHFS_4K_DEVBLK_SIZE=y
CONFIG_SQUASHFS_EMBEDDED=y
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
CONFIG_VXFS_FS=y
# CONFIG_MINIX_FS is not set
CONFIG_OMFS_FS=y
CONFIG_HPFS_FS=y
# CONFIG_QNX4FS_FS is not set
CONFIG_QNX6FS_FS=y
CONFIG_QNX6FS_DEBUG=y
CONFIG_ROMFS_FS=y
# CONFIG_ROMFS_BACKED_BY_BLOCK is not set
CONFIG_ROMFS_BACKED_BY_MTD=y
# CONFIG_ROMFS_BACKED_BY_BOTH is not set
CONFIG_ROMFS_ON_MTD=y
CONFIG_PSTORE=y
# CONFIG_PSTORE_CONSOLE is not set
CONFIG_PSTORE_RAM=y
# CONFIG_SYSV_FS is not set
CONFIG_UFS_FS=y
CONFIG_UFS_FS_WRITE=y
CONFIG_UFS_DEBUG=y
CONFIG_F2FS_FS=y
# CONFIG_F2FS_STAT_FS is not set
CONFIG_F2FS_FS_XATTR=y
# CONFIG_F2FS_FS_POSIX_ACL is not set
# CONFIG_F2FS_FS_SECURITY is not set
# CONFIG_F2FS_CHECK_FS is not set
CONFIG_EFIVAR_FS=y
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NCP_FS=y
# CONFIG_NCPFS_PACKET_SIGNING is not set
CONFIG_NCPFS_IOCTL_LOCKING=y
# CONFIG_NCPFS_STRONG is not set
CONFIG_NCPFS_NFS_NS=y
# CONFIG_NCPFS_OS2_NS is not set
CONFIG_NCPFS_SMALLDOS=y
CONFIG_NCPFS_NLS=y
CONFIG_NCPFS_EXTRAS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
# CONFIG_NLS_CODEPAGE_950 is not set
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
# CONFIG_NLS_ISO8859_4 is not set
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=y
# CONFIG_NLS_ISO8859_15 is not set
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
CONFIG_NLS_MAC_CELTIC=y
# CONFIG_NLS_MAC_CENTEURO is not set
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_DEBUG_INFO is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=1024
CONFIG_STRIP_ASM_SYMS=y
CONFIG_READABLE_ASM=y
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_DEBUG_OBJECTS=y
CONFIG_DEBUG_OBJECTS_SELFTEST=y
# CONFIG_DEBUG_OBJECTS_FREE is not set
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
CONFIG_DEBUG_OBJECTS_WORK=y
CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER=y
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=y
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_DEBUG_HIGHMEM=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_KMEMCHECK is not set
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
# CONFIG_TIMER_STATS is not set
CONFIG_DEBUG_PREEMPT=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_PI_LIST is not set
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y

#
# RCU Debugging
#
CONFIG_PROVE_RCU=y
# CONFIG_PROVE_RCU_REPEATEDLY is not set
# CONFIG_PROVE_RCU_DELAY is not set
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_TORTURE_TEST is not set
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
CONFIG_RCU_CPU_STALL_VERBOSE=y
CONFIG_RCU_CPU_STALL_INFO=y
CONFIG_RCU_TRACE=y
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_CPU_NOTIFIER_ERROR_INJECT=y
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
# CONFIG_FAULT_INJECTION is not set
CONFIG_LATENCYTOP=y
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
# CONFIG_FUNCTION_TRACER is not set
CONFIG_IRQSOFF_TRACER=y
# CONFIG_PREEMPT_TRACER is not set
# CONFIG_SCHED_TRACER is not set
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP=y
CONFIG_TRACE_BRANCH_PROFILING=y
# CONFIG_BRANCH_PROFILE_NONE is not set
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
CONFIG_PROFILE_ALL_BRANCHES=y
CONFIG_TRACING_BRANCHES=y
CONFIG_BRANCH_TRACER=y
# CONFIG_STACK_TRACER is not set
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_UPROBE_EVENT=y
CONFIG_PROBE_EVENTS=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
# CONFIG_TRACEPOINT_BENCHMARK is not set
CONFIG_RING_BUFFER_BENCHMARK=y
# CONFIG_RING_BUFFER_STARTUP_TEST is not set

#
# Runtime Testing
#
CONFIG_LKDTM=y
CONFIG_TEST_LIST_SORT=y
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_ATOMIC64_SELFTEST is not set
CONFIG_TEST_STRING_HELPERS=y
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_BUILD_DOCSRC is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
# CONFIG_EARLY_PRINTK is not set
CONFIG_X86_PTDUMP=y
CONFIG_EFI_PGT_DUMP=y
# CONFIG_DEBUG_RODATA is not set
CONFIG_DOUBLEFAULT=y
CONFIG_DEBUG_TLBFLUSH=y
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_NMI_SELFTEST is not set
# CONFIG_X86_DEBUG_STATIC_CPU_HAS is not set

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
CONFIG_BIG_KEYS=y
CONFIG_TRUSTED_KEYS=y
# CONFIG_ENCRYPTED_KEYS is not set
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_NETWORK_XFRM=y
# CONFIG_SECURITY_PATH is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_YAMA is not set
CONFIG_INTEGRITY=y
CONFIG_INTEGRITY_SIGNATURE=y
# CONFIG_INTEGRITY_ASYMMETRIC_KEYS is not set
CONFIG_IMA=y
CONFIG_IMA_MEASURE_PCR_IDX=10
CONFIG_IMA_TEMPLATE=y
# CONFIG_IMA_NG_TEMPLATE is not set
# CONFIG_IMA_SIG_TEMPLATE is not set
CONFIG_IMA_DEFAULT_TEMPLATE="ima"
CONFIG_IMA_DEFAULT_HASH_SHA1=y
CONFIG_IMA_DEFAULT_HASH="sha1"
# CONFIG_IMA_APPRAISE is not set
# CONFIG_EVM is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
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
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
# CONFIG_CRYPTO_CTS is not set
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
# CONFIG_CRYPTO_WP512 is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_586=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
# CONFIG_CRYPTO_FCRYPT is not set
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_586=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_586=y
# CONFIG_CRYPTO_TEA is not set
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_586=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_ZLIB is not set
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_LZ4 is not set
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
# CONFIG_CRYPTO_DEV_PADLOCK_AES is not set
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
CONFIG_CRYPTO_DEV_GEODE=y
CONFIG_CRYPTO_DEV_HIFN_795X=y
CONFIG_CRYPTO_DEV_HIFN_795X_RNG=y
CONFIG_CRYPTO_DEV_CCP=y
# CONFIG_CRYPTO_DEV_CCP_DD is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
# CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE is not set
# CONFIG_PUBLIC_KEY_ALGO_RSA is not set
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_PERCPU_RWSEM=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
CONFIG_CRC32_BIT=y
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
CONFIG_RANDOM32_SELFTEST=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
# CONFIG_XZ_DEC_POWERPC is not set
CONFIG_XZ_DEC_IA64=y
# CONFIG_XZ_DEC_ARM is not set
CONFIG_XZ_DEC_ARMTHUMB=y
# CONFIG_XZ_DEC_SPARC is not set
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_INTERVAL_TREE=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_AVERAGE=y
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
CONFIG_DDR=y
CONFIG_MPILIB=y
CONFIG_SIGNATURE=y
CONFIG_UCS2_STRING=y

--XvKFcGCOAo53UbWW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

_______________________________________________
LKP mailing list
LKP@linux.intel.com

--XvKFcGCOAo53UbWW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
