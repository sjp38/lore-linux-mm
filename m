Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3C0B16B01E3
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 01:31:43 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3N5Vdi1020606
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 23 Apr 2010 14:31:39 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 58A6745DE51
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 14:31:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 318F545DE4E
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 14:31:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B481E08003
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 14:31:39 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C38D5E08001
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 14:31:38 +0900 (JST)
Date: Fri, 23 Apr 2010 14:27:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][mm][PATCH] fix migration race in rmap_walk
Message-Id: <20100423142738.d0114946.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <m2l28c262361004222211j602f224bv60ffd381f524e78a@mail.gmail.com>
References: <20100423120148.9ffa5881.kamezawa.hiroyu@jp.fujitsu.com>
	<m2l28c262361004222211j602f224bv60ffd381f524e78a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Apr 2010 14:11:37 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Fri, Apr 23, 2010 at 12:01 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > This patch itself is for -mm ..but may need to go -stable tree for memory
> > hotplug. (but we've got no report to hit this race...)
> >
> > This one is the simplest, I think and works well on my test set.
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > In rmap.c, at checking rmap in vma chain in page->mapping, anon_vma->lock
> > or mapping->i_mmap_lock is held and enter following loop.
> >
> > A  A  A  A for_each_vma_in_this_rmap_link(list from page->mapping) {
> > A  A  A  A  A  A  A  A unsigned long address = vma_address(page, vma);
> > A  A  A  A  A  A  A  A if (address == -EFAULT)
> > A  A  A  A  A  A  A  A  A  A  A  A continue;
> > A  A  A  A  A  A  A  A ....
> > A  A  A  A }
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
> > Apr 21 17:27:47 localhost kernel: Pid: 27892, comm: cc1 Tainted: G A  A  A  A W A  2.6.34-rc4-mm1+ #4 D2519/PRIMERGY
> > Apr 21 17:27:47 localhost kernel: RIP: 0010:[<ffffffff8114e9cf>] A [<ffffffff8114e9cf>] migration_entry_wait+0x16f/0x180
> > Apr 21 17:27:47 localhost kernel: RSP: 0000:ffff88008d9efe08 A EFLAGS: 00010246
> > Apr 21 17:27:47 localhost kernel: RAX: ffffea0000000000 RBX: ffffea0000241100 RCX: 0000000000000001
> > Apr 21 17:27:47 localhost kernel: RDX: 000000000000a4e0 RSI: ffff880621a4ab00 RDI: 000000000149c03e
> > Apr 21 17:27:47 localhost kernel: RBP: ffff88008d9efe38 R08: 0000000000000000 R09: 0000000000000000
> > Apr 21 17:27:47 localhost kernel: R10: 0000000000000000 R11: 0000000000000001 R12: ffff880621a4aae8
> > Apr 21 17:27:47 localhost kernel: R13: 00000000bf811000 R14: 000000000149c03e R15: 0000000000000000
> > Apr 21 17:27:47 localhost kernel: FS: A 00007fe6abc90700(0000) GS:ffff880005a00000(0000) knlGS:0000000000000000
> > Apr 21 17:27:47 localhost kernel: CS: A 0010 DS: 0000 ES: 0000 CR0: 0000000080050033
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
> > Apr 21 17:27:47 localhost kernel: RIP A [<ffffffff8114e9cf>] migration_entry_wait+0x16f/0x180
> > Apr 21 17:27:47 localhost kernel: RSP <ffff88008d9efe08>
> > Apr 21 17:27:47 localhost kernel: ---[ end trace 4860ab585c1fcddb ]---
> >
> >
> >
> > This patch adds vma_address_safe(). And update [start, end, pgoff]
> > under seq counter.
> >
> > Cc: Mel Gorman <mel@csn.ul.ie>
> > Cc: Minchan Kim <minchan.kim@gmail.com>
> > Cc: Christoph Lameter <cl@linux-foundation.org>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> That's exactly same what I have in mind. :)
> But I am hesitating. That's because AFAIR, we try to remove seqlock. Right?

Ah,..."don't use seqlock" is trend ?

> But in this case, seqlock is good, I think. :)
> 
BTW, this isn't seqlock but seq_counter :)

I'm still testing. What I doubt other than vma_address() is fork().
at fork(), followings _may_ happen. (but I'm not sure).

	chain vma.
	copy page table.
	   -> migration entry is copied, too.

At remap, 
	for each vma
	    look into page table and replace.

Then,
						rmap_walk().
	fork(parent, child)
						look into child's page table.
						=> we fond nothing.
	spin_lock(child's pagetable);
	spin_lock(parant's page table);
	copy migration entry
	spin_unlock(paranet's page table)
	spin_unlock(child's page table)
						update parent's paga table

If we always find parant's page table before child's , there is no race.
But I can't get prit_tree's list order as clear image. Hmm.

Thanks,
-Kame








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
