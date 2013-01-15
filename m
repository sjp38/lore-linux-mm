Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 08AD48D0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 05:55:42 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [BUG Fix Patch 4/6] Bug fix: Do not free page split from hugepage one by one.
Date: Tue, 15 Jan 2013 18:54:25 +0800
Message-Id: <1358247267-18089-5-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1358247267-18089-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1358247267-18089-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, jiang.liu@huawei.com
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

When we split a larger page into smaller ones, we should not free them
one by one because only the _count of the first page struct makes sense.
Otherwise, the kernel will panic.

So fulfill the unused small pages with 0xFD, and when the whole larger
page is fulfilled with 0xFD, free the whole larger page.

The call trace is like the following:

[ 1052.819430] ------------[ cut here ]------------
[ 1052.874575] kernel BUG at include/linux/mm.h:278!
[ 1052.930754] invalid opcode: 0000 [#1] SMP
[ 1052.979888] Modules linked in: ip6table_filter ip6_tables ebtable_nat ebtables nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_CHECKSUM iptable_mangle iptable_filter ip_tables bridge stp llc sunrpc binfmt_misc dm_mirror dm_region_hash dm_log dm_mod vhost_net macvtap macvlan tun uinput iTCO_wdt iTCO_vendor_support coretemp kvm_intel kvm crc32c_intel microcode pcspkr sg i2c_i801 i2c_core lpc_ich mfd_core ioatdma e1000e i7core_edac edac_core igb dca ptp pps_core sd_mod crc_t10dif megaraid_sas mptsas mptscsih mptbase scsi_transport_sas scsi_mod
[ 1053.580111] CPU 0
[ 1053.602026] Pid: 4, comm: kworker/0:0 Tainted: G        W    3.8.0-rc2-memory-hotremove+ #3 FUJITSU-SV PRIMEQUEST 1800E/SB
[ 1053.736188] RIP: 0010:[<ffffffff81175bd7>]  [<ffffffff81175bd7>] __free_pages+0x37/0x50
[ 1053.831952] RSP: 0018:ffff8807bdcb37f8  EFLAGS: 00010246
[ 1053.895403] RAX: 0000000000000000 RBX: ffff88077c401000 RCX: 000000000000002c
[ 1053.980660] RDX: ffff8807fffd7000 RSI: 0000000000000000 RDI: ffffea001df10040
[ 1054.065917] RBP: ffff8807bdcb37f8 R08: 0000000000000000 R09: 0000000000000000
[ 1054.151178] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
[ 1054.236433] R13: ffffea0040008000 R14: ffffea0040002000 R15: 00003ffffffff000
[ 1054.321691] FS:  0000000000000000(0000) GS:ffff8807c1a00000(0000) knlGS:0000000000000000
[ 1054.418372] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1054.487015] CR2: 00007fbc137ad000 CR3: 0000000001c0c000 CR4: 00000000000007f0
[ 1054.572272] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1054.657533] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1054.742797] Process kworker/0:0 (pid: 4, threadinfo ffff8807bdcb2000, task ffff8807bde18000)
[ 1054.843628] Stack:
[ 1054.867622]  ffff8807bdcb3818 ffffffff81175ccf 000000077c401000 ffff880796349008
[ 1054.956421]  ffff8807bdcb3848 ffffffff816a16e2 ffffea0040001000 ffff880796349008
[ 1055.045227]  ffffea0040008000 ffffea0040002000 ffff8807bdcb38b8 ffffffff816a181c
[ 1055.134033] Call Trace:
[ 1055.163230]  [<ffffffff81175ccf>] free_pages+0x5f/0x70
[ 1055.224611]  [<ffffffff816a16e2>] free_pagetable+0x7f/0xee
[ 1055.290147]  [<ffffffff816a181c>] remove_pte_table+0xcb/0x1cd
[ 1055.358806]  [<ffffffff81055bd0>] ? leave_mm+0x50/0x50
[ 1055.420187]  [<ffffffff810df55d>] ? trace_hardirqs_on+0xd/0x10
[ 1055.489882]  [<ffffffff816a1f8b>] remove_pmd_table+0x191/0x253
[ 1055.559576]  [<ffffffff816a261e>] remove_pud_table+0x194/0x24d
[ 1055.629270]  [<ffffffff811bbc3f>] ? sparse_remove_one_section+0x2f/0x150
[ 1055.709348]  [<ffffffff816a278c>] remove_pagetable+0xb5/0x17c
[ 1055.778002]  [<ffffffff81692f28>] vmemmap_free+0x18/0x20
[ 1055.841465]  [<ffffffff811bbd15>] sparse_remove_one_section+0x105/0x150
[ 1055.920508]  [<ffffffff811c953c>] __remove_pages+0xec/0x110
[ 1055.987087]  [<ffffffff81692fa7>] arch_remove_memory+0x77/0xc0
[ 1056.056781]  [<ffffffff81694138>] remove_memory+0xb8/0xf0
[ 1056.121284]  [<ffffffff814040aa>] acpi_memory_device_remove+0x76/0xbc
[ 1056.198244]  [<ffffffff813c1e50>] acpi_device_remove+0x90/0xb2
[ 1056.267941]  [<ffffffff8146bf3c>] __device_release_driver+0x7c/0xf0
[ 1056.342824]  [<ffffffff8146c0bf>] device_release_driver+0x2f/0x50
[ 1056.415635]  [<ffffffff813c3142>] acpi_bus_remove+0x32/0x6d
[ 1056.482215]  [<ffffffff813c320e>] acpi_bus_trim+0x91/0x102
[ 1056.547755]  [<ffffffff813c3307>] acpi_bus_hot_remove_device+0x88/0x180
[ 1056.626794]  [<ffffffff813be152>] acpi_os_execute_deferred+0x27/0x34
[ 1056.702717]  [<ffffffff81091c5e>] process_one_work+0x20e/0x5c0
[ 1056.772411]  [<ffffffff81091bef>] ? process_one_work+0x19f/0x5c0
[ 1056.844184]  [<ffffffff813be12b>] ? acpi_os_wait_events_complete+0x23/0x23
[ 1056.926337]  [<ffffffff81093cfe>] worker_thread+0x12e/0x370
[ 1056.992908]  [<ffffffff81093bd0>] ? manage_workers+0x180/0x180
[ 1057.062602]  [<ffffffff81099e3e>] kthread+0xee/0x100
[ 1057.121913]  [<ffffffff810e10b9>] ? __lock_release+0x129/0x190
[ 1057.191609]  [<ffffffff81099d50>] ? __init_kthread_worker+0x70/0x70
[ 1057.266494]  [<ffffffff816b33ac>] ret_from_fork+0x7c/0xb0
[ 1057.330992]  [<ffffffff81099d50>] ? __init_kthread_worker+0x70/0x70
[ 1057.405863] Code: 85 c0 74 27 f0 ff 4f 1c 0f 94 c0 84 c0 74 0a 85 f6 74 11 90 e8 bb e3 ff ff c9 c3 66 0f 1f 84 00 00 00 00 00 e8 1b fe ff ff c9 c3 <0f> 0b 0f 1f 80 00 00 00 00 eb f7 66 66 66 66 66 2e 0f 1f 84 00
[ 1057.638271] RIP  [<ffffffff81175bd7>] __free_pages+0x37/0x50
[ 1057.705994]  RSP <ffff8807bdcb37f8>
[ 1057.747882] ---[ end trace 0f90e1e054d174f9 ]---
[ 1057.803158] Kernel panic - not syncing: Fatal exception

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 arch/x86/mm/init_64.c |   80 +++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 71 insertions(+), 9 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index e77d312..ff0206b 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -777,7 +777,7 @@ static bool __meminit free_pud_table(pud_t *pud_start, pgd_t *pgd)
 
 static void __meminit
 remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
-		 bool direct)
+		 bool direct, bool split)
 {
 	unsigned long next, pages = 0;
 	pte_t *pte;
@@ -806,14 +806,30 @@ remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 		    IS_ALIGNED(next, PAGE_SIZE)) {
 			/*
 			 * Do not free direct mapping pages since they were
-			 * freed when offlining.
+			 * freed when offlining, or simplely not in use.
+			 *
+			 * Do not free pages split from larger page since only
+			 * the _count of the 1st page struct is available.
+			 * Free the larger page when it is fulfilled with 0xFD.
 			 */
-			if (!direct)
-				free_pagetable(pte_page(*pte), 0);
+			if (!direct) {
+				if (split) {
+					/*
+					 * Fill the split 4KB page with 0xFD.
+					 * When the whole 2MB page is fulfilled
+					 * with 0xFD, it could be freed.
+					 */
+					memset((void *)addr, PAGE_INUSE,
+						PAGE_SIZE);
+				} else
+					free_pagetable(pte_page(*pte), 0);
+			}
 
 			spin_lock(&init_mm.page_table_lock);
 			pte_clear(&init_mm, addr, pte);
 			spin_unlock(&init_mm.page_table_lock);
+
+			/* For non-direct mapping, pages means nothing. */
 			pages++;
 		} else {
 			/*
@@ -824,6 +840,10 @@ remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 			 */
 			memset((void *)addr, PAGE_INUSE, next - addr);
 
+			/*
+			 * If the range is not aligned to PAGE_SIZE, then the
+			 * page is definitely not split from larger page.
+			 */
 			page_addr = page_address(pte_page(*pte));
 			if (!memchr_inv(page_addr, PAGE_INUSE, PAGE_SIZE)) {
 				if (!direct)
@@ -845,11 +865,13 @@ remove_pte_table(pte_t *pte_start, unsigned long addr, unsigned long end,
 
 static void __meminit
 remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
-		 bool direct)
+		 bool direct, bool split)
 {
 	unsigned long pte_phys, next, pages = 0;
 	pte_t *pte_base;
 	pmd_t *pmd;
+	void *page_addr;
+	bool split_pmd = split, split_pte = false;
 
 	pmd = pmd_start + pmd_index(addr);
 	for (; addr < end; addr = next, pmd++) {
@@ -861,14 +883,32 @@ remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
 		if (pmd_large(*pmd)) {
 			if (IS_ALIGNED(addr, PMD_SIZE) &&
 			    IS_ALIGNED(next, PMD_SIZE)) {
-				if (!direct)
-					free_pagetable(pmd_page(*pmd),
+				if (!direct) {
+					if (split_pmd) {
+						/*
+						 * Fill the split 2MB page with
+						 * 0xFD. When the whole 1GB page
+						 * is fulfilled with 0xFD, it
+						 * could be freed.
+						 */
+						memset((void *)addr, PAGE_INUSE,
+							PMD_SIZE);
+					} else {
+						free_pagetable(pmd_page(*pmd),
 						       get_order(PMD_SIZE));
+					}
+				}
 
 				spin_lock(&init_mm.page_table_lock);
 				pmd_clear(pmd);
 				spin_unlock(&init_mm.page_table_lock);
+
+				/*
+				 * For non-direct mapping, pages means
+				 * nothing.
+				 */
 				pages++;
+
 				continue;
 			}
 
@@ -880,6 +920,7 @@ remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
 			BUG_ON(!pte_base);
 			__split_large_page((pte_t *)pmd, addr,
 					   (pte_t *)pte_base);
+			split_pte = true;
 
 			spin_lock(&init_mm.page_table_lock);
 			pmd_populate_kernel(&init_mm, pmd, __va(pte_phys));
@@ -889,7 +930,16 @@ remove_pmd_table(pmd_t *pmd_start, unsigned long addr, unsigned long end,
 		}
 
 		pte_base = (pte_t *)map_low_page((pte_t *)pmd_page_vaddr(*pmd));
-		remove_pte_table(pte_base, addr, next, direct);
+		remove_pte_table(pte_base, addr, next, direct, split_pte);
+
+		if (!direct && split_pte) {
+			page_addr = page_address(pmd_page(*pmd));
+			if (!memchr_inv(page_addr, PAGE_INUSE, PMD_SIZE)) {
+				free_pagetable(pmd_page(*pmd),
+					       get_order(PMD_SIZE));
+			}
+		}
+
 		free_pte_table(pte_base, pmd);
 		unmap_low_page(pte_base);
 	}
@@ -906,6 +956,8 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 	unsigned long pmd_phys, next, pages = 0;
 	pmd_t *pmd_base;
 	pud_t *pud;
+	void *page_addr;
+	bool split_pmd = false;
 
 	pud = pud_start + pud_index(addr);
 	for (; addr < end; addr = next, pud++) {
@@ -936,6 +988,7 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 			BUG_ON(!pmd_base);
 			__split_large_page((pte_t *)pud, addr,
 					   (pte_t *)pmd_base);
+			split_pmd = true;
 
 			spin_lock(&init_mm.page_table_lock);
 			pud_populate(&init_mm, pud, __va(pmd_phys));
@@ -945,7 +998,16 @@ remove_pud_table(pud_t *pud_start, unsigned long addr, unsigned long end,
 		}
 
 		pmd_base = (pmd_t *)map_low_page((pmd_t *)pud_page_vaddr(*pud));
-		remove_pmd_table(pmd_base, addr, next, direct);
+		remove_pmd_table(pmd_base, addr, next, direct, split_pmd);
+
+		if (!direct && split_pmd) {
+			page_addr = page_address(pud_page(*pud));
+			if (!memchr_inv(page_addr, PAGE_INUSE, PUD_SIZE)) {
+				free_pagetable(pud_page(*pud),
+					       get_order(PUD_SIZE));
+			}
+		}
+
 		free_pmd_table(pmd_base, pud);
 		unmap_low_page(pmd_base);
 	}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
