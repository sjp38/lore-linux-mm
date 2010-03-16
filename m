Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 753EF6B00E1
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 13:12:54 -0400 (EDT)
Date: Tue, 16 Mar 2010 19:08:08 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] exit: fix oops in sync_mm_rss
Message-ID: <20100316170808.GA29400@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: cl@linux-foundation.org, lee.schermerhorn@hp.com, rientjes@google.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, "David S. Miller" <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

In 2.6.34-rc1, removing vhost_net module causes an oops in sync_mm_rss
(called from do_exit) when workqueue is destroyed. This does not happen on
net-next, or with vhost on top of to 2.6.33.

The issue seems to be introduced by
34e55232e59f7b19050267a05ff1226e5cd122a5: that commit added function
sync_mm_rss that is passed task->mm, and dereferences it without
checking. If task is a kernel thread, mm might be NULL.
I think this might also happen e.g. with aio.

This patch fixes the oops by calling sync_mm_rss when task->mm
is set to NULL. I also added BUG_ON to detect any other cases
where counters get incremented while mm is NULL.

The oops I observed looks like this:

BUG: unable to handle kernel NULL pointer dereference at 00000000000002a8
IP: [<ffffffff810b436d>] sync_mm_rss+0x33/0x6f
PGD 0
Oops: 0002 [#1] SMP
last sysfs file: /sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
CPU 2
Modules linked in: vhost_net(-) tun bridge stp sunrpc ipv6 cpufreq_ondemand acpi_cpufreq freq_table kvm_intel kvm i5000_edac edac_core rtc_cmos bnx2 button i2c_i801 i2c_core rtc_core e1000e sg joydev ide_cd_mod serio_raw pcspkr rtc_lib cdrom virtio_net virtio_blk virtio_pci virtio_ring virtio af_packet e1000 shpchp aacraid uhci_hcd ohci_hcd ehci_hcd [last unloaded: microcode]

Pid: 2046, comm: vhost Not tainted 2.6.34-rc1-vhost #25 System Planar/IBM System x3550 -[7978B3G]-
RIP: 0010:[<ffffffff810b436d>]  [<ffffffff810b436d>] sync_mm_rss+0x33/0x6f
RSP: 0018:ffff8802379b7e60  EFLAGS: 00010202
RAX: 0000000000000008 RBX: ffff88023f2390c0 RCX: 0000000000000000
RDX: ffff88023f2396b0 RSI: 0000000000000000 RDI: ffff88023f2390c0
RBP: ffff8802379b7e60 R08: 0000000000000000 R09: 0000000000000000
R10: ffff88023aecfbc0 R11: 0000000000013240 R12: 0000000000000000
R13: ffffffff81051a6c R14: ffffe8ffffc0f540 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff880001e80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00000000000002a8 CR3: 000000023af23000 CR4: 00000000000406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process vhost (pid: 2046, threadinfo ffff8802379b6000, task ffff88023f2390c0)
Stack:
 ffff8802379b7ee0 ffffffff81040687 ffffe8ffffc0f558 ffffffffa00a3e2d
<0> 0000000000000000 ffff88023f2390c0 ffffffff81055817 ffff8802379b7e98
<0> ffff8802379b7e98 0000000100000286 ffff8802379b7ee0 ffff88023ad47d78
Call Trace:
 [<ffffffff81040687>] do_exit+0x147/0x6c4
 [<ffffffffa00a3e2d>] ? handle_rx_net+0x0/0x17 [vhost_net]
 [<ffffffff81055817>] ? autoremove_wake_function+0x0/0x39
 [<ffffffff81051a6c>] ? worker_thread+0x0/0x229
 [<ffffffff810553c9>] kthreadd+0x0/0xf2
 [<ffffffff810038d4>] kernel_thread_helper+0x4/0x10
 [<ffffffff81055342>] ? kthread+0x0/0x87
 [<ffffffff810038d0>] ? kernel_thread_helper+0x0/0x10
Code: 00 8b 87 6c 02 00 00 85 c0 74 14 48 98 f0 48 01 86 a0 02 00 00 c7 87 6c 02 00 00 00 00 00 00 8b 87 70 02 00 00 85 c0 74 14 48 98 <f0> 48 01 86 a8 02 00 00 c7 87 70 02 00 00 00 00 00 00 8b 87 74
RIP  [<ffffffff810b436d>] sync_mm_rss+0x33/0x6f
 RSP <ffff8802379b7e60>
CR2: 00000000000002a8
---[ end trace 41603ba922beddd2 ]---
Fixing recursive fault but reboot is needed!

(note: handle_rx_net is a work item using workqueue in question).
sync_mm_rss+0x33/0x6f gave me a hint. I also tried reverting
34e55232e59f7b19050267a05ff1226e5cd122a5 and the oops goes away.

The module in question calls use_mm and later unuse_mm from a kernel
thread.  It is when this kernel thread is destroyed that the crash
happens.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 mm/memory.c      |    1 +
 mm/mmu_context.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index d1153e3..27022b3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -130,6 +130,7 @@ void __sync_task_rss_stat(struct task_struct *task, struct mm_struct *mm)
 
 	for (i = 0; i < NR_MM_COUNTERS; i++) {
 		if (task->rss_stat.count[i]) {
+			BUG_ON(!mm);
 			add_mm_counter(mm, i, task->rss_stat.count[i]);
 			task->rss_stat.count[i] = 0;
 		}
diff --git a/mm/mmu_context.c b/mm/mmu_context.c
index 0777654..9e82e93 100644
--- a/mm/mmu_context.c
+++ b/mm/mmu_context.c
@@ -53,6 +53,7 @@ void unuse_mm(struct mm_struct *mm)
 	struct task_struct *tsk = current;
 
 	task_lock(tsk);
+	sync_mm_rss(tsk, mm);
 	tsk->mm = NULL;
 	/* active_mm is still 'mm' */
 	enter_lazy_tlb(mm, tsk);
-- 
1.7.0.18.g0d53a5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
