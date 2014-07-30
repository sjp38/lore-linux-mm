Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 325D86B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 23:50:36 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so725730pdb.17
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 20:50:35 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id do1si437131pdb.498.2014.07.29.20.50.34
        for <linux-mm@kvack.org>;
        Tue, 29 Jul 2014 20:50:35 -0700 (PDT)
Date: Wed, 30 Jul 2014 11:50:25 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [vmstat] kernel BUG at mm/vmstat.c:1278!
Message-ID: <20140730035025.GA18672@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Jet Chen <jet.chen@intel.com>, Su Tao <tao.su@intel.com>, Yuanhan Liu <yuanhan.liu@intel.com>, LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
commit 6e0a6b18b63e2c0a45ff47ab633dd6f3ad417453
Author:     Christoph Lameter <cl@gentwo.org>
AuthorDate: Wed Jul 23 09:11:43 2014 +1000
Commit:     Stephen Rothwell <sfr@canb.auug.org.au>
CommitDate: Wed Jul 23 09:11:43 2014 +1000

    vmstat: On demand vmstat workers V8
    
    vmstat workers are used for folding counter differentials into the zone,
    per node and global counters at certain time intervals.  They currently
    run at defined intervals on all processors which will cause some holdoff
    for processors that need minimal intrusion by the OS.
    
    The current vmstat_update mechanism depends on a deferrable timer firing
    every other second by default which registers a work queue item that runs
    on the local CPU, with the result that we have 1 interrupt and one
    additional schedulable task on each CPU every 2 seconds If a workload
    indeed causes VM activity or multiple tasks are running on a CPU, then
    there are probably bigger issues to deal with.
    
    However, some workloads dedicate a CPU for a single CPU bound task.  This
    is done in high performance computing, in high frequency financial
    applications, in networking (Intel DPDK, EZchip NPS) and with the advent
    of systems with more and more CPUs over time, this may become more and
    more common to do since when one has enough CPUs one cares less about
    efficiently sharing a CPU with other tasks and more about efficiently
    monopolizing a CPU per task.
    
    The difference of having this timer firing and workqueue kernel thread
    scheduled per second can be enormous.  An artificial test measuring the
    worst case time to do a simple "i++" in an endless loop on a bare metal
    system and under Linux on an isolated CPU with dynticks and with and
    without this patch, have Linux match the bare metal performance (~700
    cycles) with this patch and loose by couple of orders of magnitude (~200k
    cycles) without it[*].  The loss occurs for something that just calculates
    statistics.  For networking applications, for example, this could be the
    difference between dropping packets or sustaining line rate.
    
    Statistics are important and useful, but it would be great if there would
    be a way to not cause statistics gathering produce a huge performance
    difference.  This patche does just that.
    
    This patch creates a vmstat shepherd worker that monitors the per cpu
    differentials on all processors.  If there are differentials on a
    processor then a vmstat worker local to the processors with the
    differentials is created.  That worker will then start folding the diffs
    in regular intervals.  Should the worker find that there is no work to be
    done then it will make the shepherd worker monitor the differentials
    again.
    
    With this patch it is possible then to have periods longer than
    2 seconds without any OS event on a "cpu" (hardware thread).
    
    The patch shows a very minor increased in system performance.
    
    hackbench -s 512 -l 2000 -g 15 -f 25 -P
    
    Results before the patch:
    
    Running in process mode with 15 groups using 50 file descriptors each (== 750 tasks)
    Each sender will pass 2000 messages of 512 bytes
    Time: 4.992
    Running in process mode with 15 groups using 50 file descriptors each (== 750 tasks)
    Each sender will pass 2000 messages of 512 bytes
    Time: 4.971
    Running in process mode with 15 groups using 50 file descriptors each (== 750 tasks)
    Each sender will pass 2000 messages of 512 bytes
    Time: 5.063
    
    Hackbench after the patch:
    
    Running in process mode with 15 groups using 50 file descriptors each (== 750 tasks)
    Each sender will pass 2000 messages of 512 bytes
    Time: 4.973
    Running in process mode with 15 groups using 50 file descriptors each (== 750 tasks)
    Each sender will pass 2000 messages of 512 bytes
    Time: 4.990
    Running in process mode with 15 groups using 50 file descriptors each (== 750 tasks)
    Each sender will pass 2000 messages of 512 bytes
    Time: 4.993
    
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

+--------------------------------------------+------------+------------+---------------+
|                                            | 4020841d46 | 6e0a6b18b6 | next-20140725 |
+--------------------------------------------+------------+------------+---------------+
| boot_successes                             | 1114       | 389        | 26            |
| boot_failures                              | 786        | 511        | 5             |
| BUG:kernel_boot_hang                       | 786        | 471        | 3             |
| kernel_BUG_at_mm/vmstat.c                  | 0          | 40         | 2             |
| invalid_opcode                             | 0          | 40         | 2             |
| RIP:vmstat_update                          | 0          | 40         | 2             |
| BUG:unable_to_handle_kernel_paging_request | 0          | 40         | 2             |
| Oops                                       | 0          | 40         | 2             |
| RIP:kthread_data                           | 0          | 40         | 2             |
| BUG:scheduling_while_atomic                | 0          | 40         | 2             |
| INFO:lockdep_is_turned_off                 | 0          | 40         | 2             |
| backtrace:invalid_op                       | 0          | 40         | 2             |
+--------------------------------------------+------------+------------+---------------+

/bin/sh: /proc/self/fd/9: No such file or directory
/bin/sh: /proc/self/fd/9: No such file or directory
[    8.010173] ------------[ cut here ]------------
[    8.011183] kernel BUG at mm/vmstat.c:1278!
[    8.012437] invalid opcode: 0000 [#1] SMP 
[    8.013820] Modules linked in:
[    8.014564] CPU: 1 PID: 30 Comm: kworker/1:1 Not tainted 3.16.0-rc6-00252-g6e0a6b1 #6
[    8.016120] Workqueue: events vmstat_update
[    8.017248] task: ffff8800116ae790 ti: ffff8800116b0000 task.ti: ffff8800116b0000
[    8.018897] RIP: 0010:[<ffffffff810eb5f6>]  [<ffffffff810eb5f6>] vmstat_update+0x5f/0x64
[    8.020061] RSP: 0018:ffff8800116b3d88  EFLAGS: 00010297
[    8.020061] RAX: 0000000000000001 RBX: ffff88000c143800 RCX: ffffffff819e9600
[    8.020061] RDX: ffffffff819e9c40 RSI: ffffffff81907ec0 RDI: 0000000000000001
[    8.020061] RBP: ffff8800116b3d90 R08: 0000000000000002 R09: 00000000001aa236
[    8.020061] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88001270ddb0
[    8.020061] R13: ffff880012715100 R14: 0000000000000000 R15: ffff88001166ff40
[    8.020061] FS:  0000000000000000(0000) GS:ffff880012700000(0000) knlGS:0000000000000000
[    8.020061] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    8.020061] CR2: 00007f8afb799000 CR3: 0000000013be4000 CR4: 00000000000006e0
[    8.020061] Stack:
[    8.020061]  ffff880012711500 ffff8800116b3df8 ffffffff8107d0b0 ffffffff8107d045
[    8.020061]  0000000000000000 ffffffff8281fb30 ffffffff822c4d60 0000000000000000
[    8.020061]  ffffffff8181760b ffff88001166ff40 ffff880012711500 ffff880012711500
[    8.020061] Call Trace:
[    8.020061]  [<ffffffff8107d0b0>] process_one_work+0x1cb/0x2fc
[    8.020061]  [<ffffffff8107d045>] ? process_one_work+0x160/0x2fc
[    8.020061]  [<ffffffff8107da89>] worker_thread+0x270/0x34d
[    8.020061]  [<ffffffff8107d819>] ? cpumask_next+0x37/0x37
[    8.020061]  [<ffffffff81082ca0>] kthread+0xbe/0xc6
[    8.020061]  [<ffffffff81082be2>] ? __kthread_parkme+0x5c/0x5c
[    8.020061]  [<ffffffff815bf57c>] ret_from_fork+0x7c/0xb0
[    8.020061]  [<ffffffff81082be2>] ? __kthread_parkme+0x5c/0x5c
[    8.020061] Code: bf 00 20 00 00 e8 cb 15 f9 ff eb 21 65 8b 3c 25 2c b0 00 00 48 8b 1d 3a 45 73 01 e8 c5 fe ff ff 89 c0 f0 48 0f ab 03 72 02 eb 02 <0f> 0b 5b 5d c3 55 48 63 d2 48 89 e5 41 55 41 54 41 89 f4 53 4c 
[    8.020061] RIP  [<ffffffff810eb5f6>] vmstat_update+0x5f/0x64
[    8.020061]  RSP <ffff8800116b3d88>
[    8.108300] ---[ end trace 38299ecee249ebce ]---
[    8.109419] kworker/1:1 (30) used greatest stack depth: 13496 bytes left

git bisect start 5a7439efd1c5c416f768fc550048ca130cf4bf99 9a3c4145af32125c5ee39c0272662b47307a8323 --
git bisect good 38efad9af81d145f07f592f618c76c78cf141e5b  # 05:41    900+    370  Merge remote-tracking branch 'libata/for-next'
git bisect good 7ed8accbe1d061e1dfe4ce7a8681495595ebe1da  # 05:46    900+    365  next-20140724/tip
git bisect good 7d3ce0493347c0176b37d877be1bc2204c2314b4  # 05:49    900+    376  Merge remote-tracking branch 'staging/staging-next'
git bisect good 550c5daec4f343ffaf1a1e069e1f47275e12b369  # 06:02    900+    234  Merge remote-tracking branch 'ktest/for-next'
git bisect good dd7314beaded523afff8444fa8d471446fb27172  # 06:09    900+    368  Merge branch 'rd-docs/master'
git bisect good 4d1954347c000af3ee37661dc3acfe0ae8f59348  # 06:13    900+    256  PKCS#7: include linux-err.h for PTR_ERR and IS_ERR
git bisect  bad 590deb1467ccd5b89a40441542eed94a20fde9cd  # 06:13      0-      4  Merge branch 'akpm-current/current'
git bisect  bad a85e2d130331aa9885cbba74ae1a604dce709482  # 06:15    195-     34  include/linux/kernel.h:744:28: note: in expansion of macro 'min'
git bisect good 4ac25431a42651458ee8fe31358d714aa18ee9aa  # 06:23    900+    402  mm: memcontrol: rearrange charging fast path
git bisect good 84334f9696fba65dac01b6896e728ed64f25b0bb  # 06:29    900+    360  mm,hugetlb: simplify error handling in hugetlb_cow()
git bisect  bad de32ada9f1bb4fd7673ed245ba2b1a9103ec50ae  # 06:44    192-      1  slub: remove kmemcg id from create_unique_id
git bisect good e28c951ff01a805eacae2f67a96e0f29e32cebd1  # 07:20    900+    100  mm: pagemap: avoid unnecessary overhead when tracepoints are deactivated
git bisect good 5860f33b9ac1c224a399736358d83693fe78ce82  # 07:42    900+     99  mm: describe mmap_sem rules for __lock_page_or_retry() and callers
git bisect  bad e7943023cfcac3c9a7fe5a23713aa5723386d83b  # 07:44     26-     28  cpu_stat_off can be static
git bisect  bad 6e0a6b18b63e2c0a45ff47ab633dd6f3ad417453  # 07:51     84-     77  vmstat: On demand vmstat workers V8
git bisect good 4020841d464d689c045ad77f091f6f7fa211663d  # 07:59    900+    368  mm/shmem.c: remove the unused gfp arg to shmem_add_to_page_cache()
# first bad commit: [6e0a6b18b63e2c0a45ff47ab633dd6f3ad417453] vmstat: On demand vmstat workers V8
git bisect good 4020841d464d689c045ad77f091f6f7fa211663d  # 08:05   1000+    786  mm/shmem.c: remove the unused gfp arg to shmem_add_to_page_cache()
git bisect  bad 5a7439efd1c5c416f768fc550048ca130cf4bf99  # 08:07      0-      5  Add linux-next specific files for 20140725
git bisect good 64aa90f26c06e1cb2aacfb98a7d0eccfbd6c1a91  # 08:16   1000+    347  Linux 3.16-rc7
git bisect  bad 5a7439efd1c5c416f768fc550048ca130cf4bf99  # 08:17      0-      5  Add linux-next specific files for 20140725


This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=$1

kvm=(
	qemu-system-x86_64
	-cpu kvm64
	-enable-kvm
	-kernel $kernel
	-m 320
	-smp 2
	-net nic,vlan=1,model=e1000
	-net user,vlan=1
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null 
)

append=(
	hung_task_panic=1
	earlyprintk=ttyS0,115200
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	panic=10
	softlockup_panic=1
	nmi_watchdog=panic
	prompt_ramdisk=0
	console=ttyS0,115200
	console=tty0
	vga=normal
	root=/dev/ram0
	rw
	drbd.minor_count=8
)

"${kvm[@]}" --append "${append[*]}"
----------------------------------------------------------------------------

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
