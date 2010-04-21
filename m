Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 92D1F6B01F1
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 12:52:13 -0400 (EDT)
Received: by pwi2 with SMTP id 2so5044931pwi.14
        for <linux-mm@kvack.org>; Wed, 21 Apr 2010 09:52:11 -0700 (PDT)
Subject: Re: error at compaction  (Re: mmotm 2010-04-15-14-42 uploaded
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100421102039.GG30306@csn.ul.ie>
References: <201004152210.o3FMA7KV001909@imap1.linux-foundation.org>
	 <20100419190133.50a13021.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100419181442.GA19264@csn.ul.ie> <20100419193919.GB19264@csn.ul.ie>
	 <20100421172838.0377e0cc.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100421184806.2c3ecc87.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100421102039.GG30306@csn.ul.ie>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 22 Apr 2010 01:52:04 +0900
Message-ID: <1271868724.2100.169.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, Mel. 

On Wed, 2010-04-21 at 11:20 +0100, Mel Gorman wrote:
> On Wed, Apr 21, 2010 at 06:48:06PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Wed, 21 Apr 2010 17:28:38 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Mon, 19 Apr 2010 20:39:19 +0100
> > > Mel Gorman <mel@csn.ul.ie> wrote:
> > > 
> > > > On Mon, Apr 19, 2010 at 07:14:42PM +0100, Mel Gorman wrote: 
> > > > ==== CUT HERE ====
> > > > mm,compaction: Map free pages in the address space after they get split for compaction
> > > > 
> > > > split_free_page() is a helper function which takes a free page from the
> > > > buddy lists and splits it into order-0 pages. It is used by memory
> > > > compaction to build a list of destination pages. If
> > > > CONFIG_DEBUG_PAGEALLOC is set, a kernel paging request bug is triggered
> > > > because split_free_page() did not call the arch-allocation hooks or map
> > > > the page into the kernel address space.
> > > > 
> > > > This patch does not update split_free_page() as it is called with
> > > > interrupts held. Instead it documents that callers of split_free_page()
> > > > are responsible for calling the arch hooks and to map the page and fixes
> > > > compaction.
> > > > 
> > > > This is a fix to the patch mm-compaction-memory-compaction-core.patch.
> > > > 
> > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > 
> > > Sorry, I think I hit another? error again. (sorry, no log.)
> > > What I did was...
> > >    Running 2 shells.
> > >    while true; do make -j 16;make cleanl;done
> > >    and
> > >    while true; do echo 0 > /proc/sys/vm/compact_memory;done
> > > 
> > > 
> > > Using the same config.
> > > 
> > > Apr 21 17:27:47 localhost kernel: ------------[ cut here ]------------
> > > Apr 21 17:27:47 localhost kernel: kernel BUG at include/linux/swapops.h:105!
> > > Apr 21 17:27:47 localhost kernel: invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
> > > Apr 21 17:27:47 localhost kernel: last sysfs file: /sys/devices/virtual/net/br0/statistics/collisions
> > > Apr 21 17:27:47 localhost kernel: CPU 3
> > > Apr 21 17:27:47 localhost kernel: Modules linked in: fuse sit tunnel4 ipt_MASQUERADE iptable_nat nf_nat bridge stp llc sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf xt_physdev ip6t_REJECT nf_conntrack_ipv6 ip6table_filter ip6_tables ipv6 dm_multipath uinput ioatdma ppdev parport_pc i5000_edac bnx2 iTCO_wdt edac_core iTCO_vendor_support shpchp parport e1000e kvm_intel dca kvm i2c_i801 i2c_core i5k_amb pcspkr megaraid_sas [last unloaded: microcode]
> > > Apr 21 17:27:47 localhost kernel:
> > > Apr 21 17:27:47 localhost kernel: Pid: 27892, comm: cc1 Tainted: G        W   2.6.34-rc4-mm1+ #4 D2519/PRIMERGY          
> > > Apr 21 17:27:47 localhost kernel: RIP: 0010:[<ffffffff8114e9cf>]  [<ffffffff8114e9cf>] migration_entry_wait+0x16f/0x180
> > > Apr 21 17:27:47 localhost kernel: RSP: 0000:ffff88008d9efe08  EFLAGS: 00010246
> > > Apr 21 17:27:47 localhost kernel: RAX: ffffea0000000000 RBX: ffffea0000241100 RCX: 0000000000000001
> > > Apr 21 17:27:47 localhost kernel: RDX: 000000000000a4e0 RSI: ffff880621a4ab00 RDI: 000000000149c03e
> > > Apr 21 17:27:47 localhost kernel: RBP: ffff88008d9efe38 R08: 0000000000000000 R09: 0000000000000000
> > > Apr 21 17:27:47 localhost kernel: R10: 0000000000000000 R11: 0000000000000001 R12: ffff880621a4aae8
> > > Apr 21 17:27:47 localhost kernel: R13: 00000000bf811000 R14: 000000000149c03e R15: 0000000000000000
> > > Apr 21 17:27:47 localhost kernel: FS:  00007fe6abc90700(0000) GS:ffff880005a00000(0000) knlGS:0000000000000000
> > > Apr 21 17:27:47 localhost kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > > Apr 21 17:27:47 localhost kernel: CR2: 00007fe6a37279a0 CR3: 000000008d942000 CR4: 00000000000006e0
> > > Apr 21 17:27:47 localhost kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > > Apr 21 17:27:47 localhost kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > > Apr 21 17:27:47 localhost kernel: Process cc1 (pid: 27892, threadinfo ffff88008d9ee000, task ffff8800b23ec820)
> > > Apr 21 17:27:47 localhost kernel: Stack:
> > > Apr 21 17:27:47 localhost kernel: ffffea000101aee8 ffff880621a4aae8 ffff88008d9efe38 00007fe6a37279a0
> > > Apr 21 17:27:47 localhost kernel: <0> ffff8805d9706d90 ffff880621a4aa00 ffff88008d9efef8 ffffffff81126d05
> > > Apr 21 17:27:47 localhost kernel: <0> ffff88008d9efec8 0000000000000246 0000000000000000 ffffffff81586533
> > > Apr 21 17:27:47 localhost kernel: Call Trace:
> > > Apr 21 17:27:47 localhost kernel: [<ffffffff81126d05>] handle_mm_fault+0x995/0x9b0
> > > Apr 21 17:27:47 localhost kernel: [<ffffffff81586533>] ? do_page_fault+0x103/0x330
> > > Apr 21 17:27:47 localhost kernel: [<ffffffff8104bf40>] ? finish_task_switch+0x0/0xf0
> > > Apr 21 17:27:47 localhost kernel: [<ffffffff8158659e>] do_page_fault+0x16e/0x330
> > > Apr 21 17:27:47 localhost kernel: [<ffffffff81582f35>] page_fault+0x25/0x30
> > > Apr 21 17:27:47 localhost kernel: Code: 53 08 85 c9 0f 84 32 ff ff ff 8d 41 01 89 4d d8 89 45 d4 8b 75 d4 8b 45 d8 f0 0f b1 32 89 45 dc 8b 45 dc 39 c8 74 aa 89 c1 eb d7 <0f> 0b eb fe 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5
> > > Apr 21 17:27:47 localhost kernel: RIP  [<ffffffff8114e9cf>] migration_entry_wait+0x16f/0x180
> > > Apr 21 17:27:47 localhost kernel: RSP <ffff88008d9efe08>
> > > Apr 21 17:27:47 localhost kernel: ---[ end trace 4860ab585c1fcddb ]---
> > > 
> > 
> > It seems that this is a new error.
> > 
> > 
> > static inline struct page *migration_entry_to_page(swp_entry_t entry)
> > {
> >         struct page *p = pfn_to_page(swp_offset(entry));
> >         /*
> >          * Any use of migration entries may only occur while the
> >          * corresponding page is locked
> >          */
> >         BUG_ON(!PageLocked(p));
> >         return p;
> > }
> > 
> > 
> > Hits this BUG_ON()....then, the page migration_entry points to is unlocked.
> > 
> > But we always do
> > 
> > 	lock_page(old_page);
> > 	unamp(old_page);
> > 	remap(new_page);
> > 	unlock_page(old_page);
> > 
> > So....some pte wasn't updated at remap ?
> > 
> 
> I'm working on reproducing the problem. I've hit it only once. My stress
> tests were using dd instead of make like yours did and my
> compilation-orientated test would not have been hitting compaction as
> hard.
> 
> The theory I'm working on is that it's a PageSwapCache page that was
> unmapped and not remapped (remap_swapcache == 0) in move_to_new_page().
> In this case, the page would be migrated, left in place and unlocked.
> Later when a swap fault occurred, the migration PTE is found and the
> bug_on triggers i.e. the bug check is no longer valid because it is
> possible for an unlocked migration pte to be left behind.

Hmm. How about the situation?


CPU A						CPU B

1. unmap_and_move
2. lock_page
3. PageAnon && !page_mapped && PageSwapCache	3' do_fork 
4. remap_swapcache = 0				4' pte lock, page_dup_rmap <- race happens
5. try_to_unmap - make migration entry by 4'	
6. move_to_newpage
7. don't call remove_migration due to 4
						8. do_swap_page
						9. migration_entry_wait
						10. goto out
						11. fault!
						
In this case, process of CPU B will be killed although it passes PageLocked				
So I think we have to find another method. 

I might be wrong since nearly falling asleep. :(

-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
