Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 06B5D6B0047
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 06:40:14 -0500 (EST)
Date: Mon, 22 Feb 2010 20:42:37 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
Message-Id: <20100222204237.61e3c615.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20100222151513.0605d69e.kamezawa.hiroyu@jp.fujitsu.com>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002151610380.14484@chino.kir.corp.google.com>
	<20100216092311.86bceb0c.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002160058470.17122@chino.kir.corp.google.com>
	<20100217084239.265c65ea.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002161550550.11952@chino.kir.corp.google.com>
	<20100217090124.398769d5.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002161623190.11952@chino.kir.corp.google.com>
	<20100217094137.a0d26fbb.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002161648570.31753@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002161756100.15079@chino.kir.corp.google.com>
	<20100217111319.d342f10e.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002161825280.2768@chino.kir.corp.google.com>
	<20100217113430.9528438d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100222143151.9e362c88.nishimura@mxp.nes.nec.co.jp>
	<20100222151513.0605d69e.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Feb 2010 15:15:13 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 22 Feb 2010 14:31:51 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > Hi.
> > 
> > On Wed, 17 Feb 2010 11:34:30 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Tue, 16 Feb 2010 18:28:05 -0800 (PST)
> > > David Rientjes <rientjes@google.com> wrote:
> > > 
> > > > On Wed, 17 Feb 2010, KAMEZAWA Hiroyuki wrote:
> > > > 
> > > > > > What do you think about making pagefaults use out_of_memory() directly and 
> > > > > > respecting the sysctl_panic_on_oom settings?
> > > > > > 
> > > > > 
> > > > > I don't think this patch is good. Because several memcg can
> > > > > cause oom at the same time independently, system-wide oom locking is
> > > > > unsuitable. BTW, what I doubt is much more fundamental thing.
> > > > > 
> > > > 
> > > > We want to lock all populated zones with ZONE_OOM_LOCKED to avoid 
> > > > needlessly killing more than one task regardless of how many memcgs are 
> > > > oom.
> > > > 
> > > Current implentation archive what memcg want. Why remove and destroy memcg ?
> > > 
> > It might be a bit off-topic, but memcg's check for last_oom_jiffies seems
> > not to work well under heavy load, and pagefault_out_of_memory() causes
> > global oom.
> > 
> > Step.1 make a memory cgroup directory and sed memory.limit_in_bytes to a small value
> > 
> >   > mkdir /cgroup/memory/test
> >   > echo 1M >/cgroup/memory/test/memory.limit_in_bytes
> > 
> > Stem.2 run attached test program(which allocates memory and does fork recursively)
> > 
> >   > ./recursive_fork -c 8 -s `expr 1 \* 1024 \* 1024`
> > 
> > This causes not only memcg's oom, but also global oom(My machine has 8 CPUS).
> > 
> > ===
> > [348090.121808] recursive_fork3 invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=0
> > [348090.121821] recursive_fork3 cpuset=/ mems_allowed=0
> > [348090.121829] Pid: 22744, comm: recursive_fork3 Not tainted 2.6.32.8-00001-gb6cd517 #3
> > [348090.121832] Call Trace:
> > [348090.121849]  [<ffffffff810d6015>] oom_kill_process+0x86/0x295
> > [348090.121855]  [<ffffffff810d64cf>] ? select_bad_process+0x63/0xf0
> > [348090.121861]  [<ffffffff810d687a>] mem_cgroup_out_of_memory+0x69/0x87
> > [348090.121870]  [<ffffffff811119c2>] __mem_cgroup_try_charge+0x15f/0x1d4
> > [348090.121876]  [<ffffffff811126bc>] mem_cgroup_try_charge_swapin+0x104/0x159
> > [348090.121885]  [<ffffffff810edd9b>] handle_mm_fault+0x4ca/0x76c
> > [348090.121895]  [<ffffffff8143419f>] ? do_page_fault+0x141/0x2da
> > [348090.121904]  [<ffffffff81087286>] ? trace_hardirqs_on+0xd/0xf
> > [348090.121910]  [<ffffffff8143419f>] ? do_page_fault+0x141/0x2da
> > [348090.121915]  [<ffffffff8143431c>] do_page_fault+0x2be/0x2da
> > [348090.121922]  [<ffffffff81432115>] page_fault+0x25/0x30
> > [348090.121929] Task in /test killed as a result of limit of /test
> > [348090.121936] memory: usage 1024kB, limit 1024kB, failcnt 279335
> > [348090.121940] memory+swap: usage 4260kB, limit 9007199254740991kB, failcnt 0
> > [348090.121943] Mem-Info:
> > [348090.121947] Node 0 DMA per-cpu:
> > [348090.121952] CPU    0: hi:    0, btch:   1 usd:   0
> > [348090.121956] CPU    1: hi:    0, btch:   1 usd:   0
> > [348090.121960] CPU    2: hi:    0, btch:   1 usd:   0
> > [348090.121963] CPU    3: hi:    0, btch:   1 usd:   0
> > [348090.121967] CPU    4: hi:    0, btch:   1 usd:   0
> > [348090.121970] CPU    5: hi:    0, btch:   1 usd:   0
> > [348090.121974] CPU    6: hi:    0, btch:   1 usd:   0
> > [348090.121977] CPU    7: hi:    0, btch:   1 usd:   0
> > [348090.121980] Node 0 DMA32 per-cpu:
> > [348090.121984] CPU    0: hi:  186, btch:  31 usd:  19
> > [348090.121988] CPU    1: hi:  186, btch:  31 usd:  11
> > [348090.121992] CPU    2: hi:  186, btch:  31 usd: 178
> > [348090.121995] CPU    3: hi:  186, btch:  31 usd:   0
> > [348090.121999] CPU    4: hi:  186, btch:  31 usd: 182
> > [348090.122002] CPU    5: hi:  186, btch:  31 usd:  29
> > [348090.122006] CPU    6: hi:  186, btch:  31 usd:   0
> > [348090.122009] CPU    7: hi:  186, btch:  31 usd:   0
> > [348090.122012] Node 0 Normal per-cpu:
> > [348090.122016] CPU    0: hi:  186, btch:  31 usd:  54
> > [348090.122020] CPU    1: hi:  186, btch:  31 usd: 109
> > [348090.122023] CPU    2: hi:  186, btch:  31 usd: 149
> > [348090.122027] CPU    3: hi:  186, btch:  31 usd: 119
> > [348090.122030] CPU    4: hi:  186, btch:  31 usd: 123
> > [348090.122033] CPU    5: hi:  186, btch:  31 usd: 145
> > [348090.122037] CPU    6: hi:  186, btch:  31 usd:  54
> > [348090.122041] CPU    7: hi:  186, btch:  31 usd:  95
> > [348090.122049] active_anon:5354 inactive_anon:805 isolated_anon:0
> > [348090.122051]  active_file:18317 inactive_file:57785 isolated_file:0
> > [348090.122053]  unevictable:0 dirty:0 writeback:211 unstable:0
> > [348090.122054]  free:3324478 slab_reclaimable:18860 slab_unreclaimable:13472
> > [348090.122056]  mapped:4315 shmem:63 pagetables:1098 bounce:0
> > [348090.122059] Node 0 DMA free:15676kB min:12kB low:12kB high:16kB active_anon:0kB inacti
> > ve_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(
> > file):0kB present:15100kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_re
> > claimable:0kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:
> > 0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> > [348090.122076] lowmem_reserve[]: 0 3204 13932 13932
> > [348090.122083] Node 0 DMA32 free:2773244kB min:3472kB low:4340kB high:5208kB active_anon:
> > 0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB
> >  isolated(file):0kB present:3281248kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem
> > :0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:
> > 0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> > [348090.122100] lowmem_reserve[]: 0 0 10728 10728
> > [348090.122108] Node 0 Normal free:10508992kB min:11624kB low:14528kB high:17436kB active_
> > anon:21416kB inactive_anon:3220kB active_file:73268kB inactive_file:231140kB unevictable:0
> > kB isolated(anon):0kB isolated(file):0kB present:10985984kB mlocked:0kB dirty:0kB writebac
> > k:844kB mapped:17260kB shmem:252kB slab_reclaimable:75440kB slab_unreclaimable:53872kB ker
> > nel_stack:1224kB pagetables:4392kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned
> > :0 all_unreclaimable? no
> > [348090.122125] lowmem_reserve[]: 0 0 0 0
> > [348090.122788] Node 0 DMA: 1*4kB 1*8kB 3*16kB 2*32kB 3*64kB 2*128kB 1*256kB 1*512kB 2*102
> > 4kB 2*2048kB 2*4096kB = 15676kB
> > [348090.122853] Node 0 DMA32: 11*4kB 6*8kB 2*16kB 4*32kB 6*64kB 13*128kB 4*256kB 6*512kB 6
> > *1024kB 4*2048kB 672*4096kB = 2773244kB
> > [348090.122915] Node 0 Normal: 188*4kB 128*8kB 214*16kB 409*32kB 107*64kB 18*128kB 4*256kB
> >  1*512kB 2*1024kB 0*2048kB 2558*4096kB = 10508592kB
> > [348090.122936] 76936 total pagecache pages
> > [348090.122940] 816 pages in swap cache
> > [348090.122943] Swap cache stats: add 7851711, delete 7850894, find 3676243/4307445
> > [348090.122946] Free swap  = 1995492kB
> > [348090.122949] Total swap = 2000888kB
> > [348090.300467] 3670016 pages RAM
> > [348090.300471] 153596 pages reserved
> > [348090.300474] 38486 pages shared
> > [348090.300476] 162081 pages non-shared
> > [348090.300482] Memory cgroup out of memory: kill process 22072 (recursive_fork3) score 12
> > 48 or a child
> > [348090.300486] Killed process 22072 (recursive_fork3)
> > [348090.300524] Kernel panic - not syncing: out of memory from page fault. panic_on_oom is
> >  selected.
> > [348090.300526]
> > [348090.311038] Pid: 22744, comm: recursive_fork3 Not tainted 2.6.32.8-00001-gb6cd517 #3
> > [348090.311050] Call Trace:
> > [348090.311073]  [<ffffffff8142efa4>] panic+0x75/0x133
> > [348090.311090]  [<ffffffff810d67d2>] pagefault_out_of_memory+0x50/0x8f
> > [348090.311104]  [<ffffffff81036a2d>] mm_fault_error+0x37/0xba
> > [348090.311117]  [<ffffffff8143428d>] do_page_fault+0x22f/0x2da
> > [348090.311130]  [<ffffffff81432115>] page_fault+0x25/0x30
> > ===
> > 
> > I take a kdump by enabling panic_on_oom, and compared the last_oom_jiffies and jiffies.
> > 
> > crash> struct mem_cgroup.last_oom_jiffies 0xffffc90013514000
> >   last_oom_jiffies = 4642757419,
> > crash> p jiffies
> > jiffies = $10 = 4642757607
> > 
> > I agree this is a extreme example, but this is not a desirable behavior.
> > Changing "HZ/10" in mem_cgroup_last_oom_called() to "HZ/2" or some would fix
> > this case, but it's not a essential fix.
> 
> Yes, current design is not the best thing, my bad.
> (I had to band-aid against unexpected panic in pagefault_out_of_memory.)
> 
> But tweaking that vaule seems not promissing.
> 
> Essential fix is better. The best fix is don't call oom-killer in
> pagefault_out_of_memory. So, returning other than VM_FAULT_OOM is
> the best, I think. But hmm...we don't have VM_FAULT_AGAIN etc..
> So, please avoid quick fix. 
> 
> One thing I can think of is sleep-and-retry in try_charge() if PF_MEMDIE
> is not set. (But..By this, memcg will never return faiulre in page fault.
> but it may sound reasonable.)
> 
hmm, I can agree with you. But I think we need some trick to distinguish normal VM_FAULT_OOM
and memcg's VM_FAULT_OOM(the current itself was killed by memcg's oom, so exited the retry)
at mem_cgroup_oom_called() to avoid the system from panic when panic_on_oom is enabled.
(Mark the task which is being killed by memcg's oom ?).


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
