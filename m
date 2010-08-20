Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 137E66B02F8
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 05:50:19 -0400 (EDT)
Message-ID: <4C6E4FD8.6080100@linux.intel.com>
Date: Fri, 20 Aug 2010 17:50:16 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: [BUGFIX][PATCH 2/2] x86, mem: update all PGDs for direct mapping
 and vmemmap mapping changes on 64bit.
References: <4C6E4ECD.1090607@linux.intel.com>
In-Reply-To: <4C6E4ECD.1090607@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Haicheng Li <haicheng.li@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "ak@linux.intel.com" <ak@linux.intel.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

x86, mem-hotplug: update all PGDs for direct mapping and vmemmap mapping changes on 64bit.

When memory hotplug-adding happens for a large enough area
that a new PGD entry is needed for the direct mapping, the PGDs
of other processes would not get updated. This leads to some CPUs
oopsing like below when they have to access the unmapped areas.

[ 1139.243192] BUG: soft lockup - CPU#0 stuck for 61s! [bash:6534]
[ 1139.243195] Modules linked in: ipv6 autofs4 rfcomm l2cap crc16 bluetooth rfkill binfmt_misc
dm_mirror dm_region_hash dm_log dm_multipath dm_mod video output sbs sbshc fan battery ac parport_pc
lp parport joydev usbhid processor thermal thermal_sys container button rtc_cmos rtc_core rtc_lib
i2c_i801 i2c_core pcspkr uhci_hcd ohci_hcd ehci_hcd usbcore
[ 1139.243229] irq event stamp: 8538759
[ 1139.243230] hardirqs last  enabled at (8538759): [<ffffffff8100c3fc>] restore_args+0x0/0x30
[ 1139.243236] hardirqs last disabled at (8538757): [<ffffffff810422df>] __do_softirq+0x106/0x146
[ 1139.243240] softirqs last  enabled at (8538758): [<ffffffff81042310>] __do_softirq+0x137/0x146
[ 1139.243245] softirqs last disabled at (8538743): [<ffffffff8100cb5c>] call_softirq+0x1c/0x34
[ 1139.243249] CPU 0:
[ 1139.243250] Modules linked in: ipv6 autofs4 rfcomm l2cap crc16 bluetooth rfkill binfmt_misc
dm_mirror dm_region_hash dm_log dm_multipath dm_mod video output sbs sbshc fan battery ac parport_pc
lp parport joydev usbhid processor thermal thermal_sys container button rtc_cmos rtc_core rtc_lib
i2c_i801 i2c_core pcspkr uhci_hcd ohci_hcd ehci_hcd usbcore
[ 1139.243284] Pid: 6534, comm: bash Tainted: G   M       2.6.32-haicheng-cpuhp #7 QSSC-S4R
[ 1139.243287] RIP: 0010:[<ffffffff810ace35>]  [<ffffffff810ace35>] alloc_arraycache+0x35/0x69
[ 1139.243292] RSP: 0018:ffff8802799f9d78  EFLAGS: 00010286
[ 1139.243295] RAX: ffff8884ffc00000 RBX: ffff8802799f9d98 RCX: 0000000000000000
[ 1139.243297] RDX: 0000000000190018 RSI: 0000000000000001 RDI: ffff8884ffc00010
[ 1139.243300] RBP: ffffffff8100c34e R08: 0000000000000002 R09: 0000000000000000
[ 1139.243303] R10: ffffffff8246dda0 R11: 000000d08246dda0 R12: ffff8802599bfff0
[ 1139.243305] R13: ffff88027904c040 R14: ffff8802799f8000 R15: 0000000000000001
[ 1139.243308] FS:  00007fe81bfe86e0(0000) GS:ffff88000d800000(0000) knlGS:0000000000000000
[ 1139.243311] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1139.243313] CR2: ffff8884ffc00000 CR3: 000000026cf2d000 CR4: 00000000000006f0
[ 1139.243316] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1139.243318] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1139.243321] Call Trace:
[ 1139.243324]  [<ffffffff810ace29>] ? alloc_arraycache+0x29/0x69
[ 1139.243328]  [<ffffffff8135004e>] ? cpuup_callback+0x1b0/0x32a
[ 1139.243333]  [<ffffffff8105385d>] ? notifier_call_chain+0x33/0x5b
[ 1139.243337]  [<ffffffff810538a4>] ? __raw_notifier_call_chain+0x9/0xb
[ 1139.243340]  [<ffffffff8134ecfc>] ? cpu_up+0xb3/0x152
[ 1139.243344]  [<ffffffff813388ce>] ? store_online+0x4d/0x75
[ 1139.243348]  [<ffffffff811e53f3>] ? sysdev_store+0x1b/0x1d
[ 1139.243351]  [<ffffffff8110589f>] ? sysfs_write_file+0xe5/0x121
[ 1139.243355]  [<ffffffff810b539d>] ? vfs_write+0xae/0x14a
[ 1139.243358]  [<ffffffff810b587f>] ? sys_write+0x47/0x6f
[ 1139.243362]  [<ffffffff8100b9ab>] ? system_call_fastpath+0x16/0x1b

This patch makes sure to always replicate new direct mapping PGD entries
to the PGDs of all processes, as well as ensures corresponding vmemmap
mapping gets synced.

V1: initial code by Andi Kleen.
V2: fix several issues found in testing.
V3: as suggested by Wu Fengguang, reuse common code of vmalloc_sync_all().

Signed-off-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
---
  arch/x86/mm/init_64.c |    8 +++++++-
  1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index b0c3df0..fa72b4b 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -564,11 +564,13 @@ kernel_physical_mapping_init(unsigned long start,
  			     unsigned long end,
  			     unsigned long page_size_mask)
  {
-
+	int pgd_changed = 0;
  	unsigned long next, last_map_addr = end;
+	unsigned long addr;

  	start = (unsigned long)__va(start);
  	end = (unsigned long)__va(end);
+	addr = start;

  	for (; start < end; start = next) {
  		pgd_t *pgd = pgd_offset_k(start);
@@ -593,7 +595,10 @@ kernel_physical_mapping_init(unsigned long start,
  		spin_lock(&init_mm.page_table_lock);
  		pgd_populate(&init_mm, pgd, __va(pud_phys));
  		spin_unlock(&init_mm.page_table_lock);
+		pgd_changed = 1;
  	}
+	if (pgd_changed)
+		sync_global_pgds(addr, end);
  	__flush_tlb_all();

  	return last_map_addr;
@@ -1033,6 +1038,7 @@ vmemmap_populate(struct page *start_page, unsigned long size, int node)
  		}

  	}
+	sync_global_pgds((unsigned long)start_page, end);
  	return 0;
  }

-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
