Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id mADIt4t1006876
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 13:55:04 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mADIq8Je172408
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 13:52:09 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mADIq8lv011106
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 13:52:08 -0500
Subject: Re: 2.6.28-rc4 mem_cgroup_charge_common panic
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20081113111702.9a5b6ce7.kamezawa.hiroyu@jp.fujitsu.com>
References: <1226353408.8805.12.camel@badari-desktop>
	 <20081111101440.f531021d.kamezawa.hiroyu@jp.fujitsu.com>
	 <20081111110934.d41fa8db.kamezawa.hiroyu@jp.fujitsu.com>
	 <1226527376.4835.8.camel@badari-desktop>
	 <20081113111702.9a5b6ce7.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Thu, 13 Nov 2008 10:53:24 -0800
Message-Id: <1226602404.29381.6.camel@badari-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-11-13 at 11:17 +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 12 Nov 2008 14:02:56 -0800
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> 
> > On Tue, 2008-11-11 at 11:09 +0900, KAMEZAWA Hiroyuki wrote:
> > > On Tue, 11 Nov 2008 10:14:40 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > On Mon, 10 Nov 2008 13:43:28 -0800
> > > > Badari Pulavarty <pbadari@us.ibm.com> wrote:
> > > > 
> > > > > Hi KAME,
> > > > > 
> > > > > Thank you for the fix for online/offline page_cgroup panic.
> > > > > 
> > > > > While running memory offline/online tests ran into another
> > > > > mem_cgroup panic.
> > > > > 
> > > > 
> > > > Hm, should I avoid freeing mem_cgroup at memory Offline ?
> > > > (memmap is also not free AFAIK.)
> > > > 
> > > > Anyway, I'll dig this. thanks.
> > > > 
> > > it seems not the same kind of bug..
> > > 
> > > Could you give me disassemble of mem_cgroup_charge_common() ?
> > > (I'm not sure I can read ppc asm but I want to know what is "0x20"
> > >  of fault address....)
> > > 
> > > As first impression, it comes from page migration..
> > > rc4's page migration handler of memcg handles *usual* path but not so good.
> > > 
> > > new migration code of memcg in mmotm is much better, I think.
> > > Could you try mmotm if you have time ?
> > 
> > I tried mmtom. Its even worse :(
> > 
> > Ran into following quickly .. Sorry!!
> > 
> From 
> > Instruction dump:
> > 794b1f24 794026e4 7d6bda14 7d3b0214 7d234b78 39490008 e92b0048 39290001 
> > f92b0048 419e001c e9230008 f93c0018 <f9090008> f9030008 f9480008 48000018 
> 
> the reason doesn't seem to be different from the one you saw in rc4.
> 
> We'do add_list() hear, so (maybe) used page_cgroup is zero-cleared, I think.
> We usually do migration test on cpuset and confirmed this works with migration.
> 
> Hmm...I susupect following. could you try ?
> 
> Sorry.
> -Kame
> ==
> 
> Index: mmotm-2.6.28-Nov10/mm/page_cgroup.c
> ===================================================================
> --- mmotm-2.6.28-Nov10.orig/mm/page_cgroup.c
> +++ mmotm-2.6.28-Nov10/mm/page_cgroup.c
> @@ -166,7 +166,7 @@ int online_page_cgroup(unsigned long sta
>  	end = ALIGN(start_pfn + nr_pages, PAGES_PER_SECTION);
> 
>  	for (pfn = start; !fail && pfn < end; pfn += PAGES_PER_SECTION) {
> -		if (!pfn_present(pfn))
> +		if (!pfn_valid(pfn))
>  			continue;
>  		fail = init_section_page_cgroup(pfn);
>  	}
> 
> 

I tried mmtom + startpfn fix + this fix + notifier fix. Didn't help.
I am not using SLUB (using SLAB). Yes. I am testing "real" memory
remove (not just offline/online), since it executes more code of
freeing memmap etc.

Code that is panicing is list_add() in mem_cgroup_add_list().
I will debug it further.

Thanks,
Badari

Oops: Kernel access of bad area, sig: 11 [#1]
SMP NR_CPUS=32 NUMA pSeries
Modules linked in:
NIP: c000000000109e50 LR: c000000000109de8 CTR: c0000000000c2414
REGS: c0000000e653f2d0 TRAP: 0300   Not tainted  (2.6.28-rc4-mm1)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 44008484  XER: 20000018
DAR: 0000000000000007, DSISR: 0000000042000000
TASK = c0000000e7db9950[4927] 'drmgr' THREAD: c0000000e653c000 CPU: 0
GPR00: 0000000000000020 c0000000e653f550 c000000000b472d8 c0000000e910d558 
GPR04: c00000000010a730 c0000000000b96a8 c0000000e653f660 0000000000000000 
GPR08: c000000005432358 ffffffffffffffff c0000000e910d560 c0000000e910d548 
GPR12: 0000000024000482 c000000000b68300 00000000200957bc 0000000000000000 
GPR16: 0000000000000000 c0000000e653f8f8 0000000000000000 c000000000aeea70 
GPR20: 0000000000000056 0000000000000000 c00000000370c300 00000000000e6000 
GPR24: 0000000000000000 0000000000000000 0000000000000001 c0000000e910d538 
GPR28: c000000005432340 0000000000000001 c000000000abc220 c0000000e653f550 
NIP [c000000000109e50] .__mem_cgroup_add_list+0x98/0xec
LR [c000000000109de8] .__mem_cgroup_add_list+0x30/0xec
Call Trace:
[c0000000e653f550] [c000000000109de8] .__mem_cgroup_add_list+0x30/0xec (unreliable)
[c0000000e653f5f0] [c00000000010a730] .__mem_cgroup_commit_charge+0x108/0x154
[c0000000e653f690] [c00000000010adf8] .mem_cgroup_end_migration+0xb4/0x130
[c0000000e653f730] [c000000000108c84] .migrate_pages+0x460/0x62c
[c0000000e653f880] [c000000000106760] .offline_pages+0x398/0x5ac
[c0000000e653f990] [c0000000001069b8] .remove_memory+0x44/0x60
[c0000000e653fa20] [c000000000407590] .memory_block_change_state+0x198/0x230
[c0000000e653fad0] [c000000000407cb0] .store_mem_state+0xcc/0x144
[c0000000e653fb70] [c0000000003fa8b4] .sysdev_store+0x74/0xa4
[c0000000e653fc10] [c00000000017b088] .sysfs_write_file+0x128/0x1a4
[c0000000e653fcd0] [c00000000010fb80] .vfs_write+0xf0/0x1c4
[c0000000e653fd80] [c00000000011051c] .sys_write+0x6c/0xb8
[c0000000e653fe30] [c00000000000852c] syscall_exit+0x0/0x40
Instruction dump:
794b1f24 794026e4 7d6bda14 7d3b0214 7d234b78 39490008 e92b0048 39290001 
f92b0048 419e001c e9230008 f93c0018 <f9090008> f9030008 f9480008 48000018 
---[ end trace e803fa4abaa22794 ]---
Unable to handle kernel paging request for data at address 0x00000008
Faulting instruction address: 0xc000000000109e50
Oops: Kernel access of bad area, sig: 11 [#2]
SMP NR_CPUS=32 NUMA pSeries
Modules linked in:
NIP: c000000000109e50 LR: c000000000109de8 CTR: c0000000000c2414
REGS: c0000000e63b3110 TRAP: 0300   Tainted: G      D     (2.6.28-rc4-mm1)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 44044844  XER: 20000010
DAR: 0000000000000008, DSISR: 0000000042000000
TASK = c0000000e9966690[2719] 'syslog-ng' THREAD: c0000000e63b0000 CPU: 1
GPR00: 0000000000000020 c0000000e63b3390 c000000000b472d8 c0000000e910c758 
GPR04: c00000000010a730 c0000000000b96a8 0000000000000001 0000000000000000 
GPR08: c000000005431ea8 0000000000000000 c0000000e910c760 c0000000e910c748 
GPR12: c0000000e6e040f8 c000000000b68500 000000000000f8e5 0000000000000004 
GPR16: 0000000000000000 00000000000003fa c0000000e63b3b30 c0000000be125000 
GPR20: c0000000be124000 0000000000000005 0000000002180404 0000000000001694 
GPR24: 0000000000000000 0000000000000000 0000000000000001 c0000000e910c738 
GPR28: c000000005431e90 0000000000000001 c000000000abc220 c0000000e63b3390 
NIP [c000000000109e50] .__mem_cgroup_add_list+0x98/0xec
LR [c000000000109de8] .__mem_cgroup_add_list+0x30/0xec
Call Trace:
[c0000000e63b3390] [c000000000109de8] .__mem_cgroup_add_list+0x30/0xec (unreliable)
[c0000000e63b3430] [c00000000010a730] .__mem_cgroup_commit_charge+0x108/0x154
[c0000000e63b34d0] [c00000000010af90] .mem_cgroup_charge_common+0x94/0xc4
[c0000000e63b3590] [c00000000010b588] .mem_cgroup_cache_charge+0x130/0x154
[c0000000e63b3630] [c0000000000c5308] .add_to_page_cache_locked+0x64/0x18c
[c0000000e63b36e0] [c0000000000c54b0] .add_to_page_cache_lru+0x80/0xe4
[c0000000e63b3780] [c0000000000c59bc] .find_or_create_page+0x74/0xc8
[c0000000e63b3830] [c00000000013e8a4] .__getblk+0x150/0x2f8
[c0000000e63b38f0] [c0000000001aac0c] .do_journal_end+0x9c4/0xfa0
[c0000000e63b3a20] [c0000000001ab28c] .journal_end_sync+0xa4/0xc4
[c0000000e63b3ac0] [c0000000001af044] .reiserfs_commit_for_inode+0x188/0x22c
[c0000000e63b3bc0] [c000000000190948] .reiserfs_sync_file+0x6c/0xe4
[c0000000e63b3c60] [c00000000013c114] .do_fsync+0xa0/0x120
[c0000000e63b3d00] [c00000000013c1e4] .__do_fsync+0x50/0x84
[c0000000e63b3da0] [c00000000013c290] .sys_fsync+0x30/0x48
[c0000000e63b3e30] [c00000000000852c] syscall_exit+0x0/0x40
Instruction dump:
794b1f24 794026e4 7d6bda14 7d3b0214 7d234b78 39490008 e92b0048 39290001 
f92b0048 419e001c e9230008 f93c0018 <f9090008> f9030008 f9480008 48000018 
---[ end trace e803fa4abaa22794 ]---
INFO: RCU detected CPU 0 stall (t=4295359473/2500 jiffies)
Call Trace:
[c0000000e6662c90] [c0000000000102bc] .show_stack+0x94/0x198 (unreliable)
[c0000000e6662d40] [c0000000000103e8] .dump_stack+0x28/0x3c
[c0000000e6662dc0] [c0000000000b338c] .__rcu_pending+0xa8/0x2c4
[c0000000e6662e60] [c0000000000b35f4] .rcu_pending+0x4c/0xa0
[c0000000e6662ef0] [c0000000000788a0] .update_process_times+0x50/0xa8
[c0000000e6662f90] [c00000000009875c] .tick_sched_timer+0xb0/0x100
[c0000000e6663040] [c00000000008cbf8] .__run_hrtimer+0xa4/0x13c
[c0000000e66630e0] [c00000000008de64] .hrtimer_interrupt+0x128/0x200
[c0000000e66631c0] [c0000000000284c4] .timer_interrupt+0xc0/0x11c
[c0000000e6663260] [c000000000003710] decrementer_common+0x110/0x180
--- Exception: 901 at ._spin_lock_irqsave+0x80/0xd4
    LR = ._spin_lock_irqsave+0x7c/0xd4
[c0000000e6663550] [c0000000005ae7a0] ._spin_lock_irqsave+0x28/0xd4 (unreliable)
[c0000000e66635f0] [c00000000010a718] .__mem_cgroup_commit_charge+0xf0/0x154
[c0000000e6663690] [c00000000010adf8] .mem_cgroup_end_migration+0xb4/0x130
[c0000000e6663730] [c000000000108c84] .migrate_pages+0x460/0x62c
[c0000000e6663880] [c000000000106760] .offline_pages+0x398/0x5ac
[c0000000e6663990] [c0000000001069b8] .remove_memory+0x44/0x60
[c0000000e6663a20] [c000000000407590] .memory_block_change_state+0x198/0x230
[c0000000e6663ad0] [c000000000407cb0] .store_mem_state+0xcc/0x144
[c0000000e6663b70] [c0000000003fa8b4] .sysdev_store+0x74/0xa4
[c0000000e6663c10] [c00000000017b088] .sysfs_write_file+0x128/0x1a4
[c0000000e6663cd0] [c00000000010fb80] .vfs_write+0xf0/0x1c4
[c0000000e6663d80] [c00000000011051c] .sys_write+0x6c/0xb8
[c0000000e6663e30] [c00000000000852c] syscall_exit+0x0/0x40
INFO: RCU detected CPU 0 stall (t=4295366973/10000 jiffies)
Call Trace:
[c0000000e6662c90] [c0000000000102bc] .show_stack+0x94/0x198 (unreliable)
[c0000000e6662d40] [c0000000000103e8] .dump_stack+0x28/0x3c
[c0000000e6662dc0] [c0000000000b338c] .__rcu_pending+0xa8/0x2c4
[c0000000e6662e60] [c0000000000b35f4] .rcu_pending+0x4c/0xa0
[c0000000e6662ef0] [c0000000000788a0] .update_process_times+0x50/0xa8
[c0000000e6662f90] [c00000000009875c] .tick_sched_timer+0xb0/0x100
[c0000000e6663040] [c00000000008cbf8] .__run_hrtimer+0xa4/0x13c
[c0000000e66630e0] [c00000000008de64] .hrtimer_interrupt+0x128/0x200
[c0000000e66631c0] [c0000000000284c4] .timer_interrupt+0xc0/0x11c
[c0000000e6663260] [c000000000003710] decrementer_common+0x110/0x180
--- Exception: 901 at ._spin_lock_irqsave+0x84/0xd4
    LR = ._spin_lock_irqsave+0x7c/0xd4
[c0000000e6663550] [c0000000005ae7a0] ._spin_lock_irqsave+0x28/0xd4 (unreliable)
[c0000000e66635f0] [c00000000010a718] .__mem_cgroup_commit_charge+0xf0/0x154
[c0000000e6663690] [c00000000010adf8] .mem_cgroup_end_migration+0xb4/0x130
[c0000000e6663730] [c000000000108c84] .migrate_pages+0x460/0x62c
[c0000000e6663880] [c000000000106760] .offline_pages+0x398/0x5ac
[c0000000e6663990] [c0000000001069b8] .remove_memory+0x44/0x60
[c0000000e6663a20] [c000000000407590] .memory_block_change_state+0x198/0x230
[c0000000e6663ad0] [c000000000407cb0] .store_mem_state+0xcc/0x144
[c0000000e6663b70] [c0000000003fa8b4] .sysdev_store+0x74/0xa4
[c0000000e6663c10] [c00000000017b088] .sysfs_write_file+0x128/0x1a4
[c0000000e6663cd0] [c00000000010fb80] .vfs_write+0xf0/0x1c4
[c0000000e6663d80] [c00000000011051c] .sys_write+0x6c/0xb8




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
