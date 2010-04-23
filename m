Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE586B01FC
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 11:58:52 -0400 (EDT)
Date: Fri, 23 Apr 2010 16:58:01 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [BUGFIX][mm][PATCH] fix migration race in rmap_walk
Message-ID: <20100423155801.GA14351@csn.ul.ie>
References: <20100423120148.9ffa5881.kamezawa.hiroyu@jp.fujitsu.com> <20100423095922.GJ30306@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100423095922.GJ30306@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 23, 2010 at 10:59:22AM +0100, Mel Gorman wrote:
> On Fri, Apr 23, 2010 at 12:01:48PM +0900, KAMEZAWA Hiroyuki wrote:
> > This patch itself is for -mm ..but may need to go -stable tree for memory
> > hotplug. (but we've got no report to hit this race...)
> > 
> 
> Only because it's very difficult to hit. Even when running compaction
> constantly, it can take anywhere between 10 minutes and 2 hours for me
> to reproduce it.
> 
> > This one is the simplest, I think and works well on my test set.
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > In rmap.c, at checking rmap in vma chain in page->mapping, anon_vma->lock
> > or mapping->i_mmap_lock is held and enter following loop.
> > 
> > 	for_each_vma_in_this_rmap_link(list from page->mapping) {
> > 		unsigned long address = vma_address(page, vma);
> > 		if (address == -EFAULT)
> > 			continue;
> > 		....
> > 	}
> > 
> > vma_address is checking [start, end, pgoff] v.s. page->index.
> > 
> > But vma's [start, end, pgoff] is updated without locks. vma_address()
> > can hit a race and may return wrong result.
> > 
> > This bahavior is no problem in usual routine as try_to_unmap() etc...
> > But for page migration, rmap_walk() has to find all migration_ptes
> > which migration code overwritten valid ptes. This race is critical and cause
> > BUG that a migration_pte is sometimes not removed.
> > 
> > pr 21 17:27:47 localhost kernel: ------------[ cut here ]------------
> > Apr 21 17:27:47 localhost kernel: kernel BUG at include/linux/swapops.h:105!
> > Apr 21 17:27:47 localhost kernel: invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
> > Apr 21 17:27:47 localhost kernel: last sysfs file: /sys/devices/virtual/net/br0/statistics/collisions
> > Apr 21 17:27:47 localhost kernel: CPU 3
> > Apr 21 17:27:47 localhost kernel: Modules linked in: fuse sit tunnel4 ipt_MASQUERADE iptable_nat nf_nat bridge stp llc sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf xt_physdev ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 dm_multipath uinput ioatdma ppdev parport_pc i5000_edac bnx2 iTCO_wdt edac_core iTCO_vendor_support shpchp parport e1000e kvm_intel dca kvm i2c_i801 i2c_core i5k_amb pcspkr megaraid_sas [last unloaded: microcode]
> > Apr 21 17:27:47 localhost kernel:
> > Apr 21 17:27:47 localhost kernel: Pid: 27892, comm: cc1 Tainted: G        W   2.6.34-rc4-mm1+ #4 D2519/PRIMERGY          
> > Apr 21 17:27:47 localhost kernel: RIP: 0010:[<ffffffff8114e9cf>]  [<ffffffff8114e9cf>] migration_entry_wait+0x16f/0x180
> > Apr 21 17:27:47 localhost kernel: RSP: 0000:ffff88008d9efe08  EFLAGS: 00010246
> > Apr 21 17:27:47 localhost kernel: RAX: ffffea0000000000 RBX: ffffea0000241100 RCX: 0000000000000001
> > Apr 21 17:27:47 localhost kernel: RDX: 000000000000a4e0 RSI: ffff880621a4ab00 RDI: 000000000149c03e
> > Apr 21 17:27:47 localhost kernel: RBP: ffff88008d9efe38 R08: 0000000000000000 R09: 0000000000000000
> > Apr 21 17:27:47 localhost kernel: R10: 0000000000000000 R11: 0000000000000001 R12: ffff880621a4aae8
> > Apr 21 17:27:47 localhost kernel: R13: 00000000bf811000 R14: 000000000149c03e R15: 0000000000000000
> > Apr 21 17:27:47 localhost kernel: FS:  00007fe6abc90700(0000) GS:ffff880005a00000(0000) knlGS:0000000000000000
> > Apr 21 17:27:47 localhost kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > Apr 21 17:27:47 localhost kernel: CR2: 00007fe6a37279a0 CR3: 000000008d942000 CR4: 00000000000006e0
> > Apr 21 17:27:47 localhost kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > Apr 21 17:27:47 localhost kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > Apr 21 17:27:47 localhost kernel: Process cc1 (pid: 27892, threadinfo ffff88008d9ee000, task ffff8800b23ec820)
> > Apr 21 17:27:47 localhost kernel: Stack:
> > Apr 21 17:27:47 localhost kernel: ffffea000101aee8 ffff880621a4aae8 ffff88008d9efe38 00007fe6a37279a0
> > Apr 21 17:27:47 localhost kernel: <0> ffff8805d9706d90 ffff880621a4aa00 ffff88008d9efef8 ffffffff81126d05
> > Apr 21 17:27:47 localhost kernel: <0> ffff88008d9efec8 0000000000000246 0000000000000000 ffffffff81586533
> > Apr 21 17:27:47 localhost kernel: Call Trace:
> > Apr 21 17:27:47 localhost kernel: [<ffffffff81126d05>] handle_mm_fault+0x995/0x9b0
> > Apr 21 17:27:47 localhost kernel: [<ffffffff81586533>] ? do_page_fault+0x103/0x330
> > Apr 21 17:27:47 localhost kernel: [<ffffffff8104bf40>] ? finish_task_switch+0x0/0xf0
> > Apr 21 17:27:47 localhost kernel: [<ffffffff8158659e>] do_page_fault+0x16e/0x330
> > Apr 21 17:27:47 localhost kernel: [<ffffffff81582f35>] page_fault+0x25/0x30
> > Apr 21 17:27:47 localhost kernel: Code: 53 08 85 c9 0f 84 32 ff ff ff 8d 41 01 89 4d d8 89 45 d4 8b 75 d4 8b 45 d8 f0 0f b1 32 89 45 dc 8b 45 dc 39 c8 74 aa 89 c1 eb d7 <0f> 0b eb fe 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5
> > Apr 21 17:27:47 localhost kernel: RIP  [<ffffffff8114e9cf>] migration_entry_wait+0x16f/0x180
> > Apr 21 17:27:47 localhost kernel: RSP <ffff88008d9efe08>
> > Apr 21 17:27:47 localhost kernel: ---[ end trace 4860ab585c1fcddb ]---
> > 
> > This patch adds vma_address_safe(). And update [start, end, pgoff]
> > under seq counter. 
> > 
> 
> I had considered this idea as well as it is vaguely similar to how zones get
> resized with a seqlock. I was hoping that the existing locking on anon_vma
> would be usable by backing off until uncontended but maybe not so lets
> check out this approach.
> 

A possible combination of the two approaches is as follows. It uses the
anon_vma lock mostly except where the anon_vma differs between the page
and the VMAs being walked in which case it uses the seq counter. I've
had it running a few hours now without problems but I'll leave it
running at least 24 hours.

==== CUT HERE ====
 mm,migration: Prevent rmap_walk_[anon|ksm] seeing the wrong VMA information by protecting against vma_adjust with a combination of locks and seq counter

vma_adjust() is updating anon VMA information without any locks taken.
In constract, file-backed mappings use the i_mmap_lock. This lack of
locking can result in races with page migration. During rmap_walk(),
vma_address() can return -EFAULT for an address that will soon be valid.
This leaves a dangling migration PTE behind which can later cause a
BUG_ON to trigger when the page is faulted in.

With the recent anon_vma changes, there is no single anon_vma->lock that
can be taken that is safe for rmap_walk() to guard against changes by
vma_adjust(). Instead, a lock can be taken on one VMA while changes
happen to another.

What this patch does is protect against updates with a combination of
locks and seq counters. First, the vma->anon_vma lock is taken by
vma_adjust() and the sequence counter starts. The lock is released and
the sequence ended when the VMA updates are complete.

The lock serialses rmap_walk_anon when the page and VMA share the same
anon_vma. Where the anon_vmas do not match, the seq counter is checked.
If a change is noticed, rmap_walk_anon drops its locks and starts again
from scratch as the VMA list may have changed. The dangling migration
PTE bug was not triggered after several hours of stress testing with
this patch applied.

[kamezawa.hiroyu@jp.fujitsu.com: Use of a seq counter]
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mm_types.h |   13 +++++++++++++
 mm/ksm.c                 |   17 +++++++++++++++--
 mm/mmap.c                |   30 ++++++++++++++++++++++++++++++
 mm/rmap.c                |   25 ++++++++++++++++++++++++-
 4 files changed, 82 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index b8bb9a6..fcd5db2 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -12,6 +12,7 @@
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/page-debug-flags.h>
+#include <linux/seqlock.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -240,6 +241,18 @@ struct mm_struct {
 	struct rw_semaphore mmap_sem;
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
 
+#ifdef CONFIG_MIGRATION
+	/*
+	 * During migration, rmap_walk walks all the VMAs mapping a particular
+	 * page to remove the migration ptes. It doesn't this without mmap_sem
+	 * held and the semaphore is unnecessarily heavily to take in this case.
+	 * File-backed VMAs are protected by the i_mmap_lock and anon-VMAs are
+	 * protected by this seq counter. If the seq counter changes while
+	 * the migration PTE is being removed, the operation restarts.
+	 */
+	seqcount_t span_seqcounter;
+#endif
+
 	struct list_head mmlist;		/* List of maybe swapped mm's.	These are globally strung
 						 * together off init_mm.mmlist, and are protected
 						 * by mmlist_lock
diff --git a/mm/ksm.c b/mm/ksm.c
index 3666d43..613c762 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1671,11 +1671,24 @@ again:
 		struct anon_vma_chain *vmac;
 		struct vm_area_struct *vma;
 
+retry:
 		spin_lock(&anon_vma->lock);
 		list_for_each_entry(vmac, &anon_vma->head, same_anon_vma) {
+			unsigned long update_race;
+			bool outside;
 			vma = vmac->vma;
-			if (rmap_item->address < vma->vm_start ||
-			    rmap_item->address >= vma->vm_end)
+
+			/* See comment in rmap_walk_anon about reading anon VMA info */
+			update_race = read_seqcount_begin(&vma->vm_mm->span_seqcounter);
+			outside = rmap_item->address < vma->vm_start ||
+						rmap_item->address >= vma->vm_end;
+			if (anon_vma != vma->anon_vma &&
+					read_seqcount_retry(&vma->vm_mm->span_seqcounter, update_race)) {
+				spin_unlock(&anon_vma->lock);
+				goto retry;
+			}
+
+			if (outside)
 				continue;
 			/*
 			 * Initially we examine only the vma which covers this
diff --git a/mm/mmap.c b/mm/mmap.c
index f90ea92..1508c43 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -491,6 +491,26 @@ __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
 		mm->mmap_cache = prev;
 }
 
+#ifdef CONFIG_MIGRATION
+static void vma_span_seqbegin(struct vm_area_struct *vma)
+{
+	write_seqcount_begin(&vma->vm_mm->span_seqcounter);
+}
+
+static void vma_span_seqend(struct vm_area_struct *vma)
+{
+	write_seqcount_end(&vma->vm_mm->span_seqcounter);
+}
+#else
+static inline void vma_span_seqbegin(struct vm_area_struct *vma)
+{
+}
+
+static void adjust_end_vma(struct vm_area_struct *vma)
+{
+}
+#endif /* CONFIG_MIGRATION */
+
 /*
  * We cannot adjust vm_start, vm_end, vm_pgoff fields of a vma that
  * is already present in an i_mmap tree without adjusting the tree.
@@ -578,6 +598,11 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 	}
 
+	if (vma->anon_vma) {
+		spin_lock(&vma->anon_vma->lock);
+		vma_span_seqbegin(vma);
+	}
+
 	if (root) {
 		flush_dcache_mmap_lock(mapping);
 		vma_prio_tree_remove(vma, root);
@@ -620,6 +645,11 @@ again:			remove_next = 1 + (end > next->vm_end);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
 
+	if (vma->anon_vma) {
+		vma_span_seqend(vma);
+		spin_unlock(&vma->anon_vma->lock);
+	}
+
 	if (remove_next) {
 		if (file) {
 			fput(file);
diff --git a/mm/rmap.c b/mm/rmap.c
index 85f203e..b2aec5d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1368,13 +1368,35 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
 	 * are holding mmap_sem. Users without mmap_sem are required to
 	 * take a reference count to prevent the anon_vma disappearing
 	 */
+retry:
 	anon_vma = page_anon_vma(page);
 	if (!anon_vma)
 		return ret;
 	spin_lock(&anon_vma->lock);
 	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
+		unsigned long update_race;
 		struct vm_area_struct *vma = avc->vma;
-		unsigned long address = vma_address(page, vma);
+		unsigned long address;
+
+		/*
+		 * We do not hold mmap_sem and there is no guarantee that the
+		 * pages anon_vma matches the VMAs anon_vma so we cannot hold
+		 * the same lock. Instead, the pages anon_vma lock protects
+		 * against the VMA list from changing underneath us and the
+		 * seqlock protects against updates of the VMA information.
+		 *
+		 * If the seq counter has changed, then the VMA information is
+		 * being updated. We release the anon_vma lock so the update
+		 * update completes and restart the entire operation
+		 */
+		update_race = read_seqcount_begin(&vma->vm_mm->span_seqcounter);
+		address = vma_address(page, vma);
+		if (anon_vma != vma->anon_vma && 
+				read_seqcount_retry(&vma->vm_mm->span_seqcounter, update_race)) {
+			spin_unlock(&anon_vma->lock);
+			goto retry;
+		}
+
 		if (address == -EFAULT)
 			continue;
 		ret = rmap_one(page, vma, address, arg);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
