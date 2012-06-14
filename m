Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 3EF1E6B005C
	for <linux-mm@kvack.org>; Wed, 13 Jun 2012 23:49:00 -0400 (EDT)
From: Jiang Liu <jiang.liu@huawei.com>
Subject: [PATCH] memory hotplug: fix invalid memory access caused by stale kswapd pointer
Date: Thu, 14 Jun 2012 11:44:51 +0800
Message-ID: <1339645491-5656-1-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Keping Chen <chenkeping@huawei.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Xishi Qiu <qiuxishi@huawei.com>, Jiang Liu <liuj97@gmail.com>

Function kswapd_stop() will be called to destroy the kswapd work thread
when all memory of a NUMA node has been offlined. But kswapd_stop() only
terminates the work thread without resetting NODE_DATA(nid)->kswapd to NULL.
The stale pointer will prevent kswapd_run() from creating a new work thread
when adding memory to the memory-less NUMA node again. Eventually the stale
pointer may cause invalid memory access.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
Signed-off-by: Jiang Liu <liuj97@gmail.com>

---

An example stack dump as below. It's reproduced with 2.6.32, but latest
kernel has the same issue.

BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<ffffffff81051a94>] exit_creds+0x12/0x78
PGD 0
Oops: 0000 [#1] SMP
last sysfs file: /sys/devices/system/memory/memory391/state
CPU 11
Modules linked in: cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq microcode fuse loop dm_mod tpm_tis rtc_cmos i2c_i801 rtc_core tpm serio_raw pcspkr sg tpm_bios igb i2c_core iTCO_wdt rtc_lib mptctl iTCO_vendor_support button dca bnx2 usbhid hid uhci_hcd ehci_hcd usbcore sd_mod crc_t10dif edd ext3 mbcache jbd fan ide_pci_generic ide_core ata_generic ata_piix libata thermal processor thermal_sys hwmon mptsas mptscsih mptbase scsi_transport_sas scsi_mod
Pid: 7949, comm: sh Not tainted 2.6.32.12-qiuxishi-5-default #92 Tecal RH2285
RIP: 0010:[<ffffffff81051a94>]  [<ffffffff81051a94>] exit_creds+0x12/0x78
RSP: 0018:ffff8806044f1d78  EFLAGS: 00010202
RAX: 0000000000000000 RBX: ffff880604f22140 RCX: 0000000000019502
RDX: 0000000000000000 RSI: 0000000000000202 RDI: 0000000000000000
RBP: ffff880604f22150 R08: 0000000000000000 R09: ffffffff81a4dc10
R10: 00000000000032a0 R11: ffff880006202500 R12: 0000000000000000
R13: 0000000000c40000 R14: 0000000000008000 R15: 0000000000000001
FS:  00007fbc03d066f0(0000) GS:ffff8800282e0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 000000060f029000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process sh (pid: 7949, threadinfo ffff8806044f0000, task ffff880603d7c600)
Stack:
 ffff880604f22140 ffffffff8103aac5 ffff880604f22140 ffffffff8104d21e
<0> ffff880006202500 0000000000008000 0000000000c38000 ffffffff810bd5b1
<0> 0000000000000000 ffff880603d7c600 00000000ffffdd29 0000000000000003
Call Trace:
 [<ffffffff8103aac5>] __put_task_struct+0x5d/0x97
 [<ffffffff8104d21e>] kthread_stop+0x50/0x58
 [<ffffffff810bd5b1>] offline_pages+0x324/0x3da
 [<ffffffff8121111f>] memory_block_change_state+0x179/0x1db
 [<ffffffff8121121f>] store_mem_state+0x9e/0xbb
 [<ffffffff8111a1f1>] sysfs_write_file+0xd0/0x107
 [<ffffffff810c7fe0>] vfs_write+0xad/0x169
 [<ffffffff810c8158>] sys_write+0x45/0x6e
 [<ffffffff8100296b>] system_call_fastpath+0x16/0x1b
 [<00007fbc0344df60>] 0x7fbc0344df60
Code: ff 4d 00 0f 94 c0 84 c0 74 08 48 89 ef e8 1f fd ff ff 5b 5d 31 c0 41 5c c3 53 48 8b 87 20 06 00 00 48 89 fb 48 8b bf 18 06 00 00 <8b> 00 48 c7 83 18 06 00 00 00 00 00 00 f0 ff 0f 0f 94 c0 84 c0
RIP  [<ffffffff81051a94>] exit_creds+0x12/0x78
 RSP <ffff8806044f1d78>
CR2: 0000000000000000
---[ end trace 75959287252338a5 ]---
---
 mm/vmscan.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index eeb3bc9..7585101 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2961,8 +2961,10 @@ void kswapd_stop(int nid)
 {
 	struct task_struct *kswapd = NODE_DATA(nid)->kswapd;
 
-	if (kswapd)
+	if (kswapd) {
 		kthread_stop(kswapd);
+		NODE_DATA(nid)->kswapd = NULL;
+	}
 }
 
 static int __init kswapd_init(void)
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
