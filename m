Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3F77E6B01F4
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 03:21:16 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3N7LC09007156
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 23 Apr 2010 16:21:13 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 933EB45DE70
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 16:21:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BF8545DE60
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 16:21:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 468651DB8040
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 16:21:12 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DB8DC1DB803B
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 16:21:11 +0900 (JST)
Date: Fri, 23 Apr 2010 16:17:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][mm][PATCH] fix migration race in rmap_walk
Message-Id: <20100423161713.3a9e79c5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <z2x28c262361004230000ubce8c5b0t759dceeee7b4ec19@mail.gmail.com>
References: <20100423120148.9ffa5881.kamezawa.hiroyu@jp.fujitsu.com>
	<m2l28c262361004222211j602f224bv60ffd381f524e78a@mail.gmail.com>
	<20100423142738.d0114946.kamezawa.hiroyu@jp.fujitsu.com>
	<z2x28c262361004230000ubce8c5b0t759dceeee7b4ec19@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Apr 2010 16:00:31 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Fri, Apr 23, 2010 at 2:27 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 23 Apr 2010 14:11:37 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> On Fri, Apr 23, 2010 at 12:01 PM, KAMEZAWA Hiroyuki
> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> >
> >> > This patch itself is for -mm ..but may need to go -stable tree for memory
> >> > hotplug. (but we've got no report to hit this race...)
> >> >
> >> > This one is the simplest, I think and works well on my test set.
> >> > ==
> >> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> >
> >> > In rmap.c, at checking rmap in vma chain in page->mapping, anon_vma->lock
> >> > or mapping->i_mmap_lock is held and enter following loop.
> >> >
> >> > A  A  A  A for_each_vma_in_this_rmap_link(list from page->mapping) {
> >> > A  A  A  A  A  A  A  A unsigned long address = vma_address(page, vma);
> >> > A  A  A  A  A  A  A  A if (address == -EFAULT)
> >> > A  A  A  A  A  A  A  A  A  A  A  A continue;
> >> > A  A  A  A  A  A  A  A ....
> >> > A  A  A  A }
> >> >
> >> > vma_address is checking [start, end, pgoff] v.s. page->index.
> >> >
> >> > But vma's [start, end, pgoff] is updated without locks. vma_address()
> >> > can hit a race and may return wrong result.
> >> >
> >> > This bahavior is no problem in usual routine as try_to_unmap() etc...
> >> > But for page migration, rmap_walk() has to find all migration_ptes
> >> > which migration code overwritten valid ptes. This race is critical and cause
> >> > BUG that a migration_pte is sometimes not removed.
> >> >
> >> > pr 21 17:27:47 localhost kernel: ------------[ cut here ]------------
> >> > Apr 21 17:27:47 localhost kernel: kernel BUG at include/linux/swapops.h:105!
> >> > Apr 21 17:27:47 localhost kernel: invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
> >> > Apr 21 17:27:47 localhost kernel: last sysfs file: /sys/devices/virtual/net/br0/statistics/collisions
> >> > Apr 21 17:27:47 localhost kernel: CPU 3
> >> > Apr 21 17:27:47 localhost kernel: Modules linked in: fuse sit tunnel4 ipt_MASQUERADE iptable_nat nf_nat bridge stp llc sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf xt_physdev ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 dm_multipath uinput ioatdma ppdev parport_pc i5000_edac bnx2 iTCO_wdt edac_core iTCO_vendor_support shpchp parport e1000e kvm_intel dca kvm i2c_i801 i2c_core i5k_amb pcspkr megaraid_sas [last unloaded: microcode]
> >> > Apr 21 17:27:47 localhost kernel:
> >> > Apr 21 17:27:47 localhost kernel: Pid: 27892, comm: cc1 Tainted: G A  A  A  A W A  2.6.34-rc4-mm1+ #4 D2519/PRIMERGY
> >> > Apr 21 17:27:47 localhost kernel: RIP: 0010:[<ffffffff8114e9cf>] A [<ffffffff8114e9cf>] migration_entry_wait+0x16f/0x180
> >> > Apr 21 17:27:47 localhost kernel: RSP: 0000:ffff88008d9efe08 A EFLAGS: 00010246
> >> > Apr 21 17:27:47 localhost kernel: RAX: ffffea0000000000 RBX: ffffea0000241100 RCX: 0000000000000001
> >> > Apr 21 17:27:47 localhost kernel: RDX: 000000000000a4e0 RSI: ffff880621a4ab00 RDI: 000000000149c03e
> >> > Apr 21 17:27:47 localhost kernel: RBP: ffff88008d9efe38 R08: 0000000000000000 R09: 0000000000000000
> >> > Apr 21 17:27:47 localhost kernel: R10: 0000000000000000 R11: 0000000000000001 R12: ffff880621a4aae8
> >> > Apr 21 17:27:47 localhost kernel: R13: 00000000bf811000 R14: 000000000149c03e R15: 0000000000000000
> >> > Apr 21 17:27:47 localhost kernel: FS: A 00007fe6abc90700(0000) GS:ffff880005a00000(0000) knlGS:0000000000000000
> >> > Apr 21 17:27:47 localhost kernel: CS: A 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >> > Apr 21 17:27:47 localhost kernel: CR2: 00007fe6a37279a0 CR3: 000000008d942000 CR4: 00000000000006e0
> >> > Apr 21 17:27:47 localhost kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> >> > Apr 21 17:27:47 localhost kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> >> > Apr 21 17:27:47 localhost kernel: Process cc1 (pid: 27892, threadinfo ffff88008d9ee000, task ffff8800b23ec820)
> >> > Apr 21 17:27:47 localhost kernel: Stack:
> >> > Apr 21 17:27:47 localhost kernel: ffffea000101aee8 ffff880621a4aae8 ffff88008d9efe38 00007fe6a37279a0
> >> > Apr 21 17:27:47 localhost kernel: <0> ffff8805d9706d90 ffff880621a4aa00 ffff88008d9efef8 ffffffff81126d05
> >> > Apr 21 17:27:47 localhost kernel: <0> ffff88008d9efec8 0000000000000246 0000000000000000 ffffffff81586533
> >> > Apr 21 17:27:47 localhost kernel: Call Trace:
> >> > Apr 21 17:27:47 localhost kernel: [<ffffffff81126d05>] handle_mm_fault+0x995/0x9b0
> >> > Apr 21 17:27:47 localhost kernel: [<ffffffff81586533>] ? do_page_fault+0x103/0x330
> >> > Apr 21 17:27:47 localhost kernel: [<ffffffff8104bf40>] ? finish_task_switch+0x0/0xf0
> >> > Apr 21 17:27:47 localhost kernel: [<ffffffff8158659e>] do_page_fault+0x16e/0x330
> >> > Apr 21 17:27:47 localhost kernel: [<ffffffff81582f35>] page_fault+0x25/0x30
> >> > Apr 21 17:27:47 localhost kernel: Code: 53 08 85 c9 0f 84 32 ff ff ff 8d 41 01 89 4d d8 89 45 d4 8b 75 d4 8b 45 d8 f0 0f b1 32 89 45 dc 8b 45 dc 39 c8 74 aa 89 c1 eb d7 <0f> 0b eb fe 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5
> >> > Apr 21 17:27:47 localhost kernel: RIP A [<ffffffff8114e9cf>] migration_entry_wait+0x16f/0x180
> >> > Apr 21 17:27:47 localhost kernel: RSP <ffff88008d9efe08>
> >> > Apr 21 17:27:47 localhost kernel: ---[ end trace 4860ab585c1fcddb ]---
> >> >
> >> >
> >> >
> >> > This patch adds vma_address_safe(). And update [start, end, pgoff]
> >> > under seq counter.
> >> >
> >> > Cc: Mel Gorman <mel@csn.ul.ie>
> >> > Cc: Minchan Kim <minchan.kim@gmail.com>
> >> > Cc: Christoph Lameter <cl@linux-foundation.org>
> >> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >>
> >> That's exactly same what I have in mind. :)
> >> But I am hesitating. That's because AFAIR, we try to remove seqlock. Right?
> >
> > Ah,..."don't use seqlock" is trend ?
> >
> >> But in this case, seqlock is good, I think. :)
> >>
> > BTW, this isn't seqlock but seq_counter :)
> >
> > I'm still testing. What I doubt other than vma_address() is fork().
> > at fork(), followings _may_ happen. (but I'm not sure).
> >
> > A  A  A  A chain vma.
> > A  A  A  A copy page table.
> > A  A  A  A  A  -> migration entry is copied, too.
> >
> > At remap,
> > A  A  A  A for each vma
> > A  A  A  A  A  A look into page table and replace.
> >
> > Then,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A rmap_walk().
> > A  A  A  A fork(parent, child)
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A look into child's page table.
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A => we fond nothing.
> > A  A  A  A spin_lock(child's pagetable);
> > A  A  A  A spin_lock(parant's page table);
> > A  A  A  A copy migration entry
> > A  A  A  A spin_unlock(paranet's page table)
> > A  A  A  A spin_unlock(child's page table)
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A update parent's paga table
> >
> > If we always find parant's page table before child's , there is no race.
> > But I can't get prit_tree's list order as clear image. Hmm.
> >
> > Thanks,
> > -Kame
> >
> 
> That's good point, Kame.
> I looked into prio_tree quickly.
> If I understand it right, list order is backward.
> 
> dup_mmap calls vma_prio_tree_add.
> 
>  * prio_tree_root
>  *      |
>  *      A       vm_set.head
>  *     / \      /
>  *    L   R -> H-I-J-K-M-N-O-P-Q-S
>  *    ^   ^    <-- vm_set.list -->
>  *  tree nodes
>  *
> 
> Maybe, parent and childs's vma are H~S.
> Then, comment said.
> 
> "vma->shared.vm_set.parent != NULL    ==> a tree node"
> So vma_prio_tree_add call not list_add_tail but list_add.
> 
Ah, thank you for explanation.

> Anyway, I think order isn't mixed.
> So, could we traverse it by backward in rmap?
> 
Doesn't it make prio-tree code dirty ?

Here is another idea....but ..hmm. Does this make fork() slow in some cases ?

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

At page migration, we replace pte with migration_entry, which has
similar format as swap_entry and replace it with real pfn at the
end of migration. But there is a race with fork()'s copy_page_range().

Assume page migraion on CPU A and fork in CPU B. On CPU A, a page of
a process is under migration. On CPU B, a page's pte is under copy.


	CPUA			CPU B
				do_fork()
				copy_mm() (from process 1 to process2)
				insert new vma to mmap_list (if inode/anon_vma)
	pte_lock(process1)
	unmap a page
	insert migration_entry
	pte_unlock(process1)

	migrate page copy
				copy_page_range
	remap new page by rmap_walk()
	pte_lock(process2)
	found no pte.
	pte_unlock(process2)
				pte lock(process2)
				pte lock(process1)
				copy migration entry to process2
				pte unlock(process1)
				pte unlokc(process2)
	pte_lock(process1)
	replace migration entry
	to new page's pte.
	pte_unlock(process1)

Then, some serialization is necessary. IIUC, this is very rare event.
So, I think copy_page_range() can wait for the end of migration.


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memory.c |   24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)

Index: linux-2.6.34-rc4-mm1/mm/memory.c
===================================================================
--- linux-2.6.34-rc4-mm1.orig/mm/memory.c
+++ linux-2.6.34-rc4-mm1/mm/memory.c
@@ -675,15 +675,8 @@ copy_one_pte(struct mm_struct *dst_mm, s
 			}
 			if (likely(!non_swap_entry(entry)))
 				rss[MM_SWAPENTS]++;
-			else if (is_write_migration_entry(entry) &&
-					is_cow_mapping(vm_flags)) {
-				/*
-				 * COW mappings require pages in both parent
-				 * and child to be set to read.
-				 */
-				make_migration_entry_read(&entry);
-				pte = swp_entry_to_pte(entry);
-				set_pte_at(src_mm, addr, src_pte, pte);
+			else {
+				BUG();
 			}
 		}
 		goto out_set_pte;
@@ -760,6 +753,19 @@ again:
 			progress++;
 			continue;
 		}
+		if (unlikely(!pte_present(*src_pte) && !pte_file(*src_pte))) {
+			entry = pte_to_swp_entry(*src_pte);
+			if (is_migration_entry(entry)) {
+				/*
+				 * Because copying pte has the race with
+				 * pte rewriting of migraton, release lock
+				 * and retry.
+				 */
+				progress = 0;
+				entry.val = 0;
+				break;
+			}
+		}
 		entry.val = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte,
 							vma, addr, rss);
 		if (entry.val)






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
