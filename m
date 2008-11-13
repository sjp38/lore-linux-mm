Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAD1AGNS019252
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 13 Nov 2008 10:10:17 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C7B9B45DE4E
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 10:10:16 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A87D745DE4F
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 10:10:16 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 93AA61DB8038
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 10:10:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A3211DB803E
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 10:10:13 +0900 (JST)
Date: Thu, 13 Nov 2008 10:09:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: 2.6.28-rc4 mem_cgroup_charge_common panic
Message-Id: <20081113100937.533c43b7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1226527376.4835.8.camel@badari-desktop>
References: <1226353408.8805.12.camel@badari-desktop>
	<20081111101440.f531021d.kamezawa.hiroyu@jp.fujitsu.com>
	<20081111110934.d41fa8db.kamezawa.hiroyu@jp.fujitsu.com>
	<1226527376.4835.8.camel@badari-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Nov 2008 14:02:56 -0800
Badari Pulavarty <pbadari@us.ibm.com> wrote:

> On Tue, 2008-11-11 at 11:09 +0900, KAMEZAWA Hiroyuki wrote:
> > On Tue, 11 Nov 2008 10:14:40 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > On Mon, 10 Nov 2008 13:43:28 -0800
> > > Badari Pulavarty <pbadari@us.ibm.com> wrote:
> > > 
> > > > Hi KAME,
> > > > 
> > > > Thank you for the fix for online/offline page_cgroup panic.
> > > > 
> > > > While running memory offline/online tests ran into another
> > > > mem_cgroup panic.
> > > > 
> > > 
> > > Hm, should I avoid freeing mem_cgroup at memory Offline ?
> > > (memmap is also not free AFAIK.)
> > > 
> > > Anyway, I'll dig this. thanks.
> > > 
> > it seems not the same kind of bug..
> > 
> > Could you give me disassemble of mem_cgroup_charge_common() ?
> > (I'm not sure I can read ppc asm but I want to know what is "0x20"
> >  of fault address....)
> > 
> > As first impression, it comes from page migration..
> > rc4's page migration handler of memcg handles *usual* path but not so good.
> > 
> > new migration code of memcg in mmotm is much better, I think.
> > Could you try mmotm if you have time ?
> 
> I tried mmtom. Its even worse :(
> 
> Ran into following quickly .. Sorry!!
> 
Hmm...mmotm + start_pfn fix ?

disassemble is also helpful.

Thanks,
-Kame


> Thanks,
> Badari
> 
> 
> Oops: Kernel access of bad area, sig: 11 [#1]
> SMP NR_CPUS=32 NUMA pSeries
> Modules linked in:
> NIP: c000000000109e50 LR: c000000000109de8 CTR: c0000000000c2414
> REGS: c0000000e66d72d0 TRAP: 0300   Not tainted  (2.6.28-rc4-mm1)
> MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 44008424  XER: 20000010
> DAR: 0000000000000008, DSISR: 0000000042000000
> TASK = c0000000e7dfa050[4835] 'drmgr' THREAD: c0000000e66d4000 CPU: 0
> GPR00: 0000000000000020 c0000000e66d7550 c000000000b472d8 c0000000e910d958 
> GPR04: c00000000010a730 c0000000000b96a8 c0000000e66d7660 0000000000000000 
> GPR08: c000000005520440 0000000000000000 c0000000e910d960 c0000000e910d948 
> GPR12: 0000000024000422 c000000000b68300 00000000200957bc 0000000000000000 
> GPR16: 0000000000000000 c0000000e66d78f8 0000000000000000 c000000000aeea70 
> GPR20: 000000000000006d 0000000000000000 c000000003709e78 00000000000e6000 
> GPR24: 0000000000000000 0000000000000000 0000000000000001 c0000000e910d938 
> GPR28: c000000005520428 0000000000000001 c000000000abc220 c0000000e66d7550 
> NIP [c000000000109e50] .__mem_cgroup_add_list+0x98/0xec
> LR [c000000000109de8] .__mem_cgroup_add_list+0x30/0xec
> Call Trace:
> [c0000000e66d7550] [c000000000109de8] .__mem_cgroup_add_list+0x30/0xec (unreliable)
> [c0000000e66d75f0] [c00000000010a730] .__mem_cgroup_commit_charge+0x108/0x154
> [c0000000e66d7690] [c00000000010adf8] .mem_cgroup_end_migration+0xb4/0x130
> [c0000000e66d7730] [c000000000108c84] .migrate_pages+0x460/0x62c
> [c0000000e66d7880] [c000000000106760] .offline_pages+0x398/0x5ac
> [c0000000e66d7990] [c0000000001069b8] .remove_memory+0x44/0x60
> [c0000000e66d7a20] [c00000000040758c] .memory_block_change_state+0x198/0x230
> [c0000000e66d7ad0] [c000000000407cac] .store_mem_state+0xcc/0x144
> [c0000000e66d7b70] [c0000000003fa8b0] .sysdev_store+0x74/0xa4
> [c0000000e66d7c10] [c00000000017b084] .sysfs_write_file+0x128/0x1a4
> [c0000000e66d7cd0] [c00000000010fb7c] .vfs_write+0xf0/0x1c4
> [c0000000e66d7d80] [c000000000110518] .sys_write+0x6c/0xb8
> [c0000000e66d7e30] [c00000000000852c] syscall_exit+0x0/0x40
> Instruction dump:
> 794b1f24 794026e4 7d6bda14 7d3b0214 7d234b78 39490008 e92b0048 39290001 
> f92b0048 419e001c e9230008 f93c0018 <f9090008> f9030008 f9480008 48000018 
> ---[ end trace 9dd57aaf4994aeb0 ]---
> Unable to handle kernel paging request for data at address 0x00000008
> Faulting instruction address: 0xc000000000109e50
> Oops: Kernel access of bad area, sig: 11 [#2]
> SMP NR_CPUS=32 NUMA pSeries
> Modules linked in:
> NIP: c000000000109e50 LR: c000000000109de8 CTR: c0000000000c2414
> REGS: c0000000e661b6e0 TRAP: 0300   Tainted: G      D     (2.6.28-rc4-mm1)
> MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 28000484  XER: 20000010
> DAR: 0000000000000008, DSISR: 0000000042000000
> TASK = c0000000e7d5e050[4839] 'drmgr' THREAD: c0000000e6618000 CPU: 3
> GPR00: 0000000000000010 c0000000e661b960 c000000000b472d8 c0000000e910cb48 
> GPR04: c00000000010a730 c0000000000b96a8 0000000000000001 0000000000000000 
> GPR08: c000000005520580 0000000000000000 c0000000e910cb50 c0000000e910cb40 
> GPR12: 0000000000000000 c000000000b68900 00000000200957bc 00000000ff844928 
> GPR16: 00000000100b8808 00000000100ee4a0 0000000002000000 c0000000e6326fe0 
> GPR20: 0000000000000000 00000000ff841cd0 c0000000e6189400 c0000000e6084880 
> GPR24: 0000000000000001 0000000000000000 0000000000000001 c0000000e910cb38 
> GPR28: c000000005520568 0000000000000001 c000000000abc220 c0000000e661b960 
> NIP [c000000000109e50] .__mem_cgroup_add_list+0x98/0xec
> LR [c000000000109de8] .__mem_cgroup_add_list+0x30/0xec
> Call Trace:
> [c0000000e661b960] [c000000000109de8] .__mem_cgroup_add_list+0x30/0xec (unreliable)
> [c0000000e661ba00] [c00000000010a730] .__mem_cgroup_commit_charge+0x108/0x154
> [c0000000e661baa0] [c00000000010af90] .mem_cgroup_charge_common+0x94/0xc4
> [c0000000e661bb60] [c00000000010b0fc] .mem_cgroup_newpage_charge+0x9c/0xc8
> [c0000000e661bc00] [c0000000000deea0] .handle_mm_fault+0x2d0/0xb08
> [c0000000e661bd00] [c0000000005b0910] .do_page_fault+0x384/0x5a0
> [c0000000e661be30] [c00000000000517c] handle_page_fault+0x20/0x5c
> Instruction dump:
> 794b1f24 794026e4 7d6bda14 7d3b0214 7d234b78 39490008 e92b0048 39290001 
> f92b0048 419e001c e9230008 f93c0018 <f9090008> f9030008 f9480008 48000018 
> ---[ end trace 9dd57aaf4994aeb0 ]---
> INFO: RCU detected CPU 1 stall (t=4295407979/2500 jiffies)
> Call Trace:
> [c0000000e65e6c90] [c0000000000102bc] .show_stack+0x94/0x198 (unreliable)
> [c0000000e65e6d40] [c0000000000103e8] .dump_stack+0x28/0x3c
> [c0000000e65e6dc0] [c0000000000b338c] .__rcu_pending+0xa8/0x2c4
> [c0000000e65e6e60] [c0000000000b35f4] .rcu_pending+0x4c/0xa0
> [c0000000e65e6ef0] [c0000000000788a0] .update_process_times+0x50/0xa8
> [c0000000e65e6f90] [c00000000009875c] .tick_sched_timer+0xb0/0x100
> [c0000000e65e7040] [c00000000008cbf8] .__run_hrtimer+0xa4/0x13c
> [c0000000e65e70e0] [c00000000008de64] .hrtimer_interrupt+0x128/0x200
> [c0000000e65e71c0] [c0000000000284c4] .timer_interrupt+0xc0/0x11c
> [c0000000e65e7260] [c000000000003710] decrementer_common+0x110/0x180
> --- Exception: 901 at ._spin_lock_irqsave+0x84/0xd4
>     LR = ._spin_lock_irqsave+0x7c/0xd4
> [c0000000e65e7550] [c0000000005ae7a0] ._spin_lock_irqsave+0x28/0xd4 (unreliable)
> [c0000000e65e75f0] [c00000000010a718] .__mem_cgroup_commit_charge+0xf0/0x154
> [c0000000e65e7690] [c00000000010adf8] .mem_cgroup_end_migration+0xb4/0x130
> [c0000000e65e7730] [c000000000108c84] .migrate_pages+0x460/0x62c
> [c0000000e65e7880] [c000000000106760] .offline_pages+0x398/0x5ac
> [c0000000e65e7990] [c0000000001069b8] .remove_memory+0x44/0x60
> [c0000000e65e7a20] [c00000000040758c] .memory_block_change_state+0x198/0x230
> [c0000000e65e7ad0] [c000000000407cac] .store_mem_state+0xcc/0x144
> [c0000000e65e7b70] [c0000000003fa8b0] .sysdev_store+0x74/0xa4
> [c0000000e65e7c10] [c00000000017b084] .sysfs_write_file+0x128/0x1a4
> [c0000000e65e7cd0] [c00000000010fb7c] .vfs_write+0xf0/0x1c4
> [c0000000e65e7d80] [c000000000110518] .sys_write+0x6c/0xb8
> [c0000000e65e7e30] [c00000000000852c] syscall_exit+0x0/0x40
> 
> 
> > 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
