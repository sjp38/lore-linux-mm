Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CFCEF6B005C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 21:01:51 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0F21nS4011405
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 11:01:49 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F335245DE50
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 11:01:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CCDA845DD72
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 11:01:48 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B0C601DB8038
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 11:01:48 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B5B41DB803B
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 11:01:48 +0900 (JST)
Date: Thu, 15 Jan 2009 11:00:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/4] memcg: don't call res_counter_uncharge when
 obsolete
Message-Id: <20090115110044.3a863af8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090115100330.37d89d3d.nishimura@mxp.nes.nec.co.jp>
References: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp>
	<20090114175121.275ecd59.nishimura@mxp.nes.nec.co.jp>
	<7602a77a9fc6b1e8757468048fde749a.squirrel@webmail-b.css.fujitsu.com>
	<20090115100330.37d89d3d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jan 2009 10:03:30 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 14 Jan 2009 22:43:05 +0900 (JST), "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Daisuke Nishimura さんは書きました：
> > > This is a new one. Please review.
> > >
> > > ===
> > > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > >
> > > mem_cgroup_get ensures that the memcg that has been got can be accessed
> > > even after the directory has been removed, but it doesn't ensure that
> > > parents
> > > of it can be accessed: parents might have been freed already by rmdir.
> > >
> > > This causes a bug in case of use_hierarchy==1, because
> > > res_counter_uncharge
> > > climb up the tree.
> > >
> > > Check if the memcg is obsolete, and don't call res_counter_uncharge when
> > > obsole.
> > >
> > Hmm, did you see panic ?
> I saw 2 types of bugs, A: spinlock lockup and B: general protection fault.
> (described below)
> 
> Those bugs happened in case of (use_hierarchy && do_swap_account),
> and didn't happen (at leaset I haven't seen) in case of
> (!use_hierarchy && do_swap_account) nor (use_hierarchy && !do_swap_account).
> And, they didn't happen with this patch applied all through the last night.
> 
> A: spinlock lockup
> ===
> BUG: spinlock lockup on CPU#1, mmapstress10/27706, ffff880
> 3a41ef0a0
> Pid: 27706, comm: mmapstress10 Not tainted 2.6.28-git12-7c
> 99bf20 #1
> Call Trace:
>  [<ffffffff803687ba>] _raw_spin_lock+0xfb/0x122
>  [<ffffffff804d83b7>] _spin_lock+0x4e/0x5f
>  [<ffffffff8026f999>] res_counter_uncharge+0x2a/0x70
>  [<ffffffff8026f999>] res_counter_uncharge+0x2a/0x70
>  [<ffffffff802a5ddc>] swap_info_get+0x6a/0xa3
>  [<ffffffff802b72a2>] mem_cgroup_uncharge_swap+0x2a/0x35
>  [<ffffffff802a6059>] swap_entry_free+0x8f/0x93
>  [<ffffffff802a6076>] swap_free+0x19/0x28
>  [<ffffffff802a572d>] delete_from_swap_cache+0x36/0x43
>  [<ffffffff802a6be9>] free_swap_and_cache+0xb1/0xeb
>  [<ffffffff80299e77>] unmap_vmas+0x57f/0x837
>  [<ffffffff8029e426>] exit_mmap+0xa5/0x11c
>  [<ffffffff80239f78>] mmput+0x41/0x9f
>  [<ffffffff8023ddeb>] exit_mm+0x102/0x10d
>  [<ffffffff8023f36a>] do_exit+0x1a2/0x73e
>  [<ffffffff80246317>] __dequeue_signal+0x15/0x11c
>  [<ffffffff8023f979>] do_group_exit+0x73/0xa5
>  [<ffffffff8024870a>] get_signal_to_deliver+0x34f/0x3a1
>  [<ffffffff8020b212>] do_notify_resume+0x8c/0x7a5
>  [<ffffffff80250f64>] lock_hrtimer_base+0x1b/0x3c
>  [<ffffffff8025474e>] getnstimeofday+0x57/0xb6
>  [<ffffffff80251314>] ktime_get_ts+0x22/0x4b
>  [<ffffffff802513bf>] ktime_get+0xc/0x41
>  [<ffffffff802511fa>] hrtimer_nanosleep+0xa5/0xf1
>  [<ffffffff80250d24>] hrtimer_wakeup+0x0/0x22
>  [<ffffffff8020bf58>] sysret_signal+0x7c/0xcb
> ===
> 
>   This context has hold swap_lock already, so other contexts trying to hold
>   swap_lock also get spinlock lockup bug.
> 
> B: general protection fault
> ===
> general protection fault: 0000 [#1] SMP
> last sysfs file: /sys/devices/system/cpu/cpu15/cache/index1/shared_cpu_map
> CPU 3
> Modules linked in: ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp ipv6
> autofs4 hidp rfcomm l2cap bluetooth sunrpc dm_mirror dm_region_hash dm_log dm_multipath dm
> _mod sbs sbshc battery ac lp sg rtc_cmos rtc_core ide_cd_mod parport_pc rtc_lib parport se
> rio_raw cdrom acpi_memhotplug button e1000 i2c_i801 i2c_core shpchp pcspkr ata_piix libata
>  megaraid_mbox megaraid_mm sd_mod scsi_mod ext3 jbd ehci_hcd ohci_hcd uhci_hcd [last unloa
> ded: microcode]
> Pid: 8051, comm: bash Not tainted 2.6.29-rc1-0ed85935 #1
> RIP: 0010:[<ffffffff80368620>]  [<ffffffff80368620>] _raw_spin_trylock+0x0/0x39
> RSP: 0000:ffff8800bb995e00  EFLAGS: 00010092
> RAX: ffff88010b54a620 RBX: 0097040900455377 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0097040900455377
> RBP: 009704090045538f R08: 0000000000000002 R09: 0000000000000001
> R10: ffffe2000c861640 R11: ffffffff8026f9b5 R12: 0000000000000296
> R13: 0000000000001000 R14: ffff8801003cf080 R15: 00007fa79a932028
> FS:  00007fa79a9316f0(0000) GS:ffff8803af7d7a80(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007fa79a932028 CR3: 00000000cc8e0000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process bash (pid: 8051, threadinfo ffff8800bb994000, task ffff88010b54a620)
> Stack:
>  ffffffff804d8f1e ffffffff8026f9b5 0097040900455377 0097040900455357
>  ffffffff8026f9b5 0000000000000282 ffff88010e1a2000 ffffe2000c861640
>  ffff8801094f9000 0000000000000000 ffffffff802b7371 00000001ed3e8025
> Call Trace:
>  [<ffffffff804d8f1e>] ? _spin_lock+0x35/0x5f
>  [<ffffffff8026f9b5>] ? res_counter_uncharge+0x2a/0x70
>  [<ffffffff8026f9b5>] ? res_counter_uncharge+0x2a/0x70
>  [<ffffffff802b7371>] ? mem_cgroup_commit_charge_swapin+0x74/0x8a
>  [<ffffffff8029ad00>] ? handle_mm_fault+0x5e3/0x750
>  [<ffffffff804db70a>] ? do_page_fault+0x3b2/0x73e
>  [<ffffffff804d96ef>] ? page_fault+0x1f/0x30
> Code: 31 c0 e8 5f 4a ed ff 48 c7 c7 da df 5c 80 31 c0 e8 51 4a ed ff c7 05 cc d5 33 00 01
> 00 00 00 c7 05 62 c7 de 00 00 00 00 00 58 c3 <0f> b7 07 38 e0 8d 88 00 01 00 00 75 05 f0 6
> 6 0f b1 0f 0f 94 c1
> RIP  [<ffffffff80368620>] _raw_spin_trylock+0x0/0x39
>  RSP <ffff8800bb995e00>
> ---[ end trace 1ecf768aff114688 ]---
> ===
> 
> 
> > To handle the problem "parent may be obsolete",
> > 
> > call mem_cgroup_get(parent) at create()
> > call mem_cgroup_put(parent) at freeing memcg.
> >      (regardless of use_hierarchy.)
> > 
> > is clearer way to go, I think.
> > 
> > I wonder whether there is  mis-accounting problem or not..
> > 
> > So, adding css_tryget() around problematic code can be a fix.
> > --
> >   mem = swap_cgroup_record();
> >   if (css_tryget(&mem->css)) {
> >       res_counter_uncharge(&mem->memsw, PAZE_SIZE);
> >       css_put(&mem->css)
> >   }
> > --
> > I like css_tryget() rather than mem_cgroup_obsolete().
> I agree.
> The updated version is attached.
> 
> 
> Thanks,
> Daisuke nishimura.
> 
> > To be honest, I'd like to remove memcg special stuff when I can.
> > 
> > Thanks,
> > -Kame
> > 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> mem_cgroup_get ensures that the memcg that has been got can be accessed
> even after the directory has been removed, but it doesn't ensure that parents
> of it can be accessed: parents might have been freed already by rmdir.
> 
> This causes a bug in case of use_hierarchy==1, because res_counter_uncharge
> climb up the tree.
> 
> Check if the memcg is obsolete by css_tryget, and don't call
> res_counter_uncharge when obsole.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
seems nice loock.


> ---
>  mm/memcontrol.c |   15 ++++++++++++---
>  1 files changed, 12 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fb62b43..4e3b100 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1182,7 +1182,10 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
>  		/* avoid double counting */
>  		mem = swap_cgroup_record(ent, NULL);
>  		if (mem) {
> -			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> +			if (!css_tryget(&mem->css)) {
> +				res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> +				css_put(&mem->css);
> +			}
>  			mem_cgroup_put(mem);
>  		}
>  	}

I think css_tryget() returns "ture" at success....

So,
==
	if (mem && css_tryget(&mem->css))
		res_counter....

is correct.

-Kame


> @@ -1252,7 +1255,10 @@ void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
>  		struct mem_cgroup *memcg;
>  		memcg = swap_cgroup_record(ent, NULL);
>  		if (memcg) {
> -			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> +			if (!css_tryget(&memcg->css)) {
> +				res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> +				css_put(&memcg->css);
> +			}
>  			mem_cgroup_put(memcg);
>  		}
>  
> @@ -1397,7 +1403,10 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
>  
>  	memcg = swap_cgroup_record(ent, NULL);
>  	if (memcg) {
> -		res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> +		if (!css_tryget(&memcg->css)) {
> +			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> +			css_put(&memcg->css);
> +		}
>  		mem_cgroup_put(memcg);
>  	}
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
