Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E198C6B01EE
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 23:06:14 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3N35i1x012636
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 23 Apr 2010 12:05:44 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 79C4145DE55
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 12:05:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5660F45DE4F
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 12:05:44 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 34FCE1DB8038
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 12:05:44 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DA3931DB803C
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 12:05:43 +0900 (JST)
Date: Fri, 23 Apr 2010 12:01:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][mm][PATCH] fix migration race in rmap_walk
Message-Id: <20100423120148.9ffa5881.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Mel Gorman <mel@csn.ul.ie>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


This patch itself is for -mm ..but may need to go -stable tree for memory
hotplug. (but we've got no report to hit this race...)

This one is the simplest, I think and works well on my test set.
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

In rmap.c, at checking rmap in vma chain in page->mapping, anon_vma->lock
or mapping->i_mmap_lock is held and enter following loop.

	for_each_vma_in_this_rmap_link(list from page->mapping) {
		unsigned long address = vma_address(page, vma);
		if (address == -EFAULT)
			continue;
		....
	}

vma_address is checking [start, end, pgoff] v.s. page->index.

But vma's [start, end, pgoff] is updated without locks. vma_address()
can hit a race and may return wrong result.

This bahavior is no problem in usual routine as try_to_unmap() etc...
But for page migration, rmap_walk() has to find all migration_ptes
which migration code overwritten valid ptes. This race is critical and cause
BUG that a migration_pte is sometimes not removed.

pr 21 17:27:47 localhost kernel: ------------[ cut here ]------------
Apr 21 17:27:47 localhost kernel: kernel BUG at include/linux/swapops.h:105!
Apr 21 17:27:47 localhost kernel: invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
Apr 21 17:27:47 localhost kernel: last sysfs file: /sys/devices/virtual/net/br0/statistics/collisions
Apr 21 17:27:47 localhost kernel: CPU 3
Apr 21 17:27:47 localhost kernel: Modules linked in: fuse sit tunnel4 ipt_MASQUERADE iptable_nat nf_nat bridge stp llc sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf xt_physdev ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 dm_multipath uinput ioatdma ppdev parport_pc i5000_edac bnx2 iTCO_wdt edac_core iTCO_vendor_support shpchp parport e1000e kvm_intel dca kvm i2c_i801 i2c_core i5k_amb pcspkr megaraid_sas [last unloaded: microcode]
Apr 21 17:27:47 localhost kernel:
Apr 21 17:27:47 localhost kernel: Pid: 27892, comm: cc1 Tainted: G        W   2.6.34-rc4-mm1+ #4 D2519/PRIMERGY          
Apr 21 17:27:47 localhost kernel: RIP: 0010:[<ffffffff8114e9cf>]  [<ffffffff8114e9cf>] migration_entry_wait+0x16f/0x180
Apr 21 17:27:47 localhost kernel: RSP: 0000:ffff88008d9efe08  EFLAGS: 00010246
Apr 21 17:27:47 localhost kernel: RAX: ffffea0000000000 RBX: ffffea0000241100 RCX: 0000000000000001
Apr 21 17:27:47 localhost kernel: RDX: 000000000000a4e0 RSI: ffff880621a4ab00 RDI: 000000000149c03e
Apr 21 17:27:47 localhost kernel: RBP: ffff88008d9efe38 R08: 0000000000000000 R09: 0000000000000000
Apr 21 17:27:47 localhost kernel: R10: 0000000000000000 R11: 0000000000000001 R12: ffff880621a4aae8
Apr 21 17:27:47 localhost kernel: R13: 00000000bf811000 R14: 000000000149c03e R15: 0000000000000000
Apr 21 17:27:47 localhost kernel: FS:  00007fe6abc90700(0000) GS:ffff880005a00000(0000) knlGS:0000000000000000
Apr 21 17:27:47 localhost kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
Apr 21 17:27:47 localhost kernel: CR2: 00007fe6a37279a0 CR3: 000000008d942000 CR4: 00000000000006e0
Apr 21 17:27:47 localhost kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Apr 21 17:27:47 localhost kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Apr 21 17:27:47 localhost kernel: Process cc1 (pid: 27892, threadinfo ffff88008d9ee000, task ffff8800b23ec820)
Apr 21 17:27:47 localhost kernel: Stack:
Apr 21 17:27:47 localhost kernel: ffffea000101aee8 ffff880621a4aae8 ffff88008d9efe38 00007fe6a37279a0
Apr 21 17:27:47 localhost kernel: <0> ffff8805d9706d90 ffff880621a4aa00 ffff88008d9efef8 ffffffff81126d05
Apr 21 17:27:47 localhost kernel: <0> ffff88008d9efec8 0000000000000246 0000000000000000 ffffffff81586533
Apr 21 17:27:47 localhost kernel: Call Trace:
Apr 21 17:27:47 localhost kernel: [<ffffffff81126d05>] handle_mm_fault+0x995/0x9b0
Apr 21 17:27:47 localhost kernel: [<ffffffff81586533>] ? do_page_fault+0x103/0x330
Apr 21 17:27:47 localhost kernel: [<ffffffff8104bf40>] ? finish_task_switch+0x0/0xf0
Apr 21 17:27:47 localhost kernel: [<ffffffff8158659e>] do_page_fault+0x16e/0x330
Apr 21 17:27:47 localhost kernel: [<ffffffff81582f35>] page_fault+0x25/0x30
Apr 21 17:27:47 localhost kernel: Code: 53 08 85 c9 0f 84 32 ff ff ff 8d 41 01 89 4d d8 89 45 d4 8b 75 d4 8b 45 d8 f0 0f b1 32 89 45 dc 8b 45 dc 39 c8 74 aa 89 c1 eb d7 <0f> 0b eb fe 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5
Apr 21 17:27:47 localhost kernel: RIP  [<ffffffff8114e9cf>] migration_entry_wait+0x16f/0x180
Apr 21 17:27:47 localhost kernel: RSP <ffff88008d9efe08>
Apr 21 17:27:47 localhost kernel: ---[ end trace 4860ab585c1fcddb ]---



This patch adds vma_address_safe(). And update [start, end, pgoff]
under seq counter. 

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mm_types.h |    2 ++
 mm/mmap.c                |   15 ++++++++++++++-
 mm/rmap.c                |   25 ++++++++++++++++++++++++-
 3 files changed, 40 insertions(+), 2 deletions(-)

Index: linux-2.6.34-rc5-mm1/include/linux/mm_types.h
===================================================================
--- linux-2.6.34-rc5-mm1.orig/include/linux/mm_types.h
+++ linux-2.6.34-rc5-mm1/include/linux/mm_types.h
@@ -12,6 +12,7 @@
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/page-debug-flags.h>
+#include <linux/seqlock.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -183,6 +184,7 @@ struct vm_area_struct {
 #ifdef CONFIG_NUMA
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
+	seqcount_t updating;	/* works like seqlock for updating vma info. */
 };
 
 struct core_thread {
Index: linux-2.6.34-rc5-mm1/mm/mmap.c
===================================================================
--- linux-2.6.34-rc5-mm1.orig/mm/mmap.c
+++ linux-2.6.34-rc5-mm1/mm/mmap.c
@@ -491,6 +491,16 @@ __vma_unlink(struct mm_struct *mm, struc
 		mm->mmap_cache = prev;
 }
 
+static void adjust_start_vma(struct vm_area_struct *vma)
+{
+	write_seqcount_begin(&vma->updating);
+}
+
+static void adjust_end_vma(struct vm_area_struct *vma)
+{
+	write_seqcount_end(&vma->updating);
+}
+
 /*
  * We cannot adjust vm_start, vm_end, vm_pgoff fields of a vma that
  * is already present in an i_mmap tree without adjusting the tree.
@@ -584,13 +594,16 @@ again:			remove_next = 1 + (end > next->
 		if (adjust_next)
 			vma_prio_tree_remove(next, root);
 	}
-
+	adjust_start_vma(vma);
 	vma->vm_start = start;
 	vma->vm_end = end;
 	vma->vm_pgoff = pgoff;
+	adjust_end_vma(vma);
 	if (adjust_next) {
+		adjust_start_vma(next);
 		next->vm_start += adjust_next << PAGE_SHIFT;
 		next->vm_pgoff += adjust_next;
+		adjust_end_vma(next);
 	}
 
 	if (root) {
Index: linux-2.6.34-rc5-mm1/mm/rmap.c
===================================================================
--- linux-2.6.34-rc5-mm1.orig/mm/rmap.c
+++ linux-2.6.34-rc5-mm1/mm/rmap.c
@@ -342,6 +342,23 @@ vma_address(struct page *page, struct vm
 }
 
 /*
+ * vma's address check is racy if we don't hold mmap_sem. This function
+ * gives a safe way for accessing the [start, end, pgoff] tuple of vma.
+ */
+
+static inline unsigned long vma_address_safe(struct page *page,
+		struct vm_area_struct *vma)
+{
+	unsigned long ret, safety;
+
+	do {
+		safety = read_seqcount_begin(&vma->updating);
+		ret = vma_address(page, vma);
+	} while (read_seqcount_retry(&vma->updating, safety));
+	return ret;
+}
+
+/*
  * At what user virtual address is page expected in vma?
  * checking that the page matches the vma.
  */
@@ -1372,7 +1389,13 @@ static int rmap_walk_anon(struct page *p
 	spin_lock(&anon_vma->lock);
 	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
 		struct vm_area_struct *vma = avc->vma;
-		unsigned long address = vma_address(page, vma);
+		unsigned long address;
+
+		/*
+		 * In page migration, this race is critical. So, use
+		 * safe version.
+		 */
+		address = vma_address_safe(page, vma);
 		if (address == -EFAULT)
 			continue;
 		ret = rmap_one(page, vma, address, arg);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
