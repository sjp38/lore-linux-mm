Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5FA958D0069
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 01:23:34 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 77E903EE0B5
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:23:30 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E33345DE68
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:23:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 458A145DE61
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:23:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AF5E1DB8043
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:23:30 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D11131DB803B
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:23:29 +0900 (JST)
Date: Fri, 21 Jan 2011 15:17:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4] mm: add replace_page_cache_page() function
Message-Id: <20110121151720.04c00c62.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110121145222.82694908.nishimura@mxp.nes.nec.co.jp>
References: <E1Pf9Zj-0002td-Ct@pomaz-ex.szeredi.hu>
	<20110118152844.88cfdc2c.akpm@linux-foundation.org>
	<20110119092733.4927f935.nishimura@mxp.nes.nec.co.jp>
	<20110119094813.2ea20439.kamezawa.hiroyu@jp.fujitsu.com>
	<isapiwc.47df251f.f8b.4d363a30.58500.62@mail.jp.nec.com>
	<20110119102348.56a41328.kamezawa.hiroyu@jp.fujitsu.com>
	<20110121145222.82694908.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, minchan.kim@gmail.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2011 14:52:22 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 19 Jan 2011 10:23:48 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Wed, 19 Jan 2011 10:11:12 +0900
> > nishimura@mxp.nes.nec.co.jp wrote:
> > 
> > > > On Wed, 19 Jan 2011 09:27:33 +0900
> > > > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > 
> > > >> On Tue, 18 Jan 2011 15:28:44 -0800
> > > >> Andrew Morton <akpm@linux-foundation.org> wrote:
> > > >> 
> > > >> > On Tue, 18 Jan 2011 12:18:11 +0100
> > > >> > Miklos Szeredi <miklos@szeredi.hu> wrote:
> > > >> > 
> > > >> > > +int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
> > > >> > > +{
> > > >> > > +	int error;
> > > >> > > +	struct mem_cgroup *memcg = NULL;
> > > >> > 
> > > >> > I'm suspecting that the unneeded initialisation was added to suppress a
> > > >> > warning?
> > > >> > 
> > > >> No.
> > > >> It's necessary for mem_cgroup_{prepare|end}_migration().
> > > >> mem_cgroup_prepare_migration() will return without doing anything in
> > > >> "if (mem_cgroup_disabled()" case(iow, "memcg" is not overwritten),
> > > >> but mem_cgroup_end_migration() depends on the value of "memcg" to decide
> > > >> whether prepare_migration has succeeded or not.
> > > >> This may not be a good implementation, but IMHO I'd like to to initialize
> > > >> valuable before using it in general.
> > > >> 
> > > > 
> > > > I think it can be initlized in mem_cgroup_prepare_migration().
> > > > I'll send patch later.
> > > > 
> > > I see, thanks.
> > > 
> > > I think you know it, but just a note:
> > > mem_cgroup_{try_charge|commit_charge}_swapin()
> > > use the same logic, so try_charge_swapin() should also be changed
> > > for consistency.
> > > 
> > 
> > Thank you for caution. But I think THP+memcg bugs should be fixed before
> > style fixes..
> > 
> I do agree.
> 
> > After my patch (yesterday), accounting information seems works well but
> > I saw very huge latency when we hit limits.
> > ==
> > Jan 18 10:27:22 rhel6-test kernel: [56177.770922] sh used greatest stack depth: 3592 bytes l
> > eft
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007] INFO: rcu_sched_state detected stall on CP
> > U 0 (t=60000 jiffies)
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007] sending NMI to all CPUs:
> > ...
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007] NMI backtrace for cpu 0
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007] CPU 0
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007] Modules linked in: autofs4 sunrpc ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables ipv6 virtio_balloon virtio_net virtio_blk virtio_pci virtio_ring virtio [last unloaded: scsi_wait_scan]
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]
> > ...
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  <IRQ>
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  [<ffffffff8102a04e>] arch_trigger_all_cpu_backtrace+0x5e/0xa0
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  [<ffffffff810bca09>] __rcu_pending+0x169/0x3b0
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  [<ffffffff8108a250>] ? tick_sched_timer+0x0/0xc0
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  [<ffffffff810bccbc>] rcu_check_callbacks+0x6c/0x120
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  [<ffffffff810689a8>] update_process_times+0x48/0x90
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  [<ffffffff8108a2b6>] tick_sched_timer+0x66/0xc0
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  [<ffffffff8107ede0>] __run_hrtimer+0x90/0x1e0
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  [<ffffffff81032db9>] ? kvm_clock_get_cycles+0x9/0x10
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  [<ffffffff8107f1be>] hrtimer_interrupt+0xde/0x240
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  [<ffffffff8155268b>] smp_apic_timer_interrupt+0x6b/0x9b
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  [<ffffffff8100c9d3>] apic_timer_interrupt+0x13/0x20
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  <EOI>
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  [<ffffffff810a726a>] ? res_counter_charge+0xda/0x100
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  [<ffffffff81145459>] __mem_cgroup_try_charge+0x199/0x5d0
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  [<ffffffff811461c6>] mem_cgroup_charge_common+0x96/0x110
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  [<ffffffff811463b5>] mem_cgroup_newpage_charge+0x45/0x50
> > Jan 18 10:28:29 rhel6-test kernel: [56245.286007]  [<ffffffff8113dbd4>] khugepaged+0x924/0x1430
> > ==
> > 
> > I guess we need to relax retry logic when page_size > PAGE_SIZE.
> > I need to stop test application with Ctrl-C.
> > (Test was make -j 16 under 200M limit.)
> > 
> I think this is caused by a following scenario.
> 
> 1. mem_cgroup_charge_common() try to charge a huge page(i.e. page_size != PAGE_SIZE).
> 2. mem_cgroup_do_charge() fails to charge, and return CHARGE_RETRY, because
>    "csize > PAGE_SIZE".
> 3. When mem_cgroup_do_charge() returns CHARGE_RETRY, mem_cgroup_charge_common()
>    changes 'csize' to 'page_size', which is bigger than PAGE_SIZE.
> 
> I think you're stuck inside a loop between 2 and 3.
> 

I'll post paches soon. It passed my test, right now ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
