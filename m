Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 170226B0047
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 02:59:33 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1J7xVMx011113
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Feb 2010 16:59:31 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EB3445DE51
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 16:59:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F09CC45DE4F
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 16:59:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D980A1DB803A
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 16:59:30 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 72A2DE78001
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 16:59:27 +0900 (JST)
Date: Fri, 19 Feb 2010 16:56:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [regression] cpuset,mm: update tasks' mems_allowed in time
 (58568d2)
Message-Id: <20100219165602.5e9edfdb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100218134921.GF9738@laptop>
References: <20100218134921.GF9738@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Miao Xie <miaox@cn.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Feb 2010 00:49:21 +1100
Nick Piggin <npiggin@suse.de> wrote:

> Hi,
> 
> The patch cpuset,mm: update tasks' mems_allowed in time (58568d2) causes
> a regression uncovered by SGI. Basically it is allowing possible but not
> online nodes in the task_struct.mems_allowed nodemask (which is contrary
> to several comments still in kernel/cpuset.c), and that causes
> cpuset_mem_spread_node() to return an offline node to slab, causing an
> oops.
> 
> Easy to reproduce if you have a machine with !online nodes.
> 
>         - mkdir /dev/cpuset
>         - mount cpuset -t cpuset /dev/cpuset
>         - echo 1 > /dev/cpuset/memory_spread_slab
> 
> kernel BUG at
> /usr/src/packages/BUILD/kernel-default-2.6.32/linux-2.6.32/mm/slab.c:3271!
> bash[6885]: bugcheck! 0 [1]
> Pid: 6885, CPU 5, comm:                 bash
> psr : 00001010095a2010 ifs : 800000000000038b ip  : [<a00000010020cf00>]
> Tainted: G        W    (2.6.32-0.6.8-default)
> ip is at ____cache_alloc_node+0x440/0x500
> 
> unat: 0000000000000000 pfs : 000000000000038b rsc : 0000000000000003
> rnat: 0000000000283d85 bsps: 0000000000000001 pr  : 99596aaa69aa6999
> ldrs: 0000000000000000 ccv : 0000000000000018 fpsr: 0009804c0270033f
> csd : 0000000000000000 ssd : 0000000000000000
> b0  : a00000010020cf00 b6  : a0000001004962c0 b7  : a000000100493240
> f6  : 000000000000000000000 f7  : 000000000000000000000
> f8  : 000000000000000000000 f9  : 000000000000000000000
> f10 : 000000000000000000000 f11 : 000000000000000000000
> r1  : a0000001015c6fc0 r2  : 000000000000e662 r3  : 000000000000fffe
> r8  : 000000000000005c r9  : 0000000000000000 r10 : 0000000000004000
> r11 : 0000000000000000 r12 : e000003c3904fcc0 r13 : e000003c39040000
> r14 : 000000000000e662 r15 : a00000010138ed88 r16 : ffffffffffff65c8
> r17 : a00000010138ed80 r18 : a0000001013c7ad0 r19 : a0000001013d3b60
> r20 : e00001b03afdfe18 r21 : 0000000000000001 r22 : e0000130030365c8
> r23 : e000013003040000 r24 : ffffffffffff0400 r25 : 00000000000068ef
> r26 : 00000000000068ef r27 : a0000001029621d0 r28 : 00000000000068f0
> r29 : 00000000000068f0 r30 : 00000000000068f0 r31 : 000000000000000a
> 
> Call Trace:
> [<a000000100017a80>] show_stack+0x80/0xa0
> [<a0000001000180e0>] show_regs+0x640/0x920
> [<a000000100029a90>] die+0x190/0x2e0
> [<a000000100029c30>] die_if_kernel+0x50/0x80
> [<a000000100904af0>] ia64_bad_break+0x470/0x760
> [<a00000010000cb60>] ia64_native_leave_kernel+0x0/0x270
> [<a00000010020cf00>] ____cache_alloc_node+0x440/0x500
> [<a00000010020ffa0>] kmem_cache_alloc+0x360/0x660
> 
> A simple bandaid is to skip !online nodes in cpuset_mem_spread_node().

I think that's good.


> However I'm a bit worried about 58568d2.
> 
> It is doing a lot of stuff. It is removing the callback_mutex from
> around several seemingly unrelated places (eg. from around
> guarnatee_online_cpus, which explicitly asks to be called with that
> lock held), and other places, so I don't know how it is not racy
> with hotplug.

Because removing pgdat is not archieved yet. It was verrrry difficult..
So, once node become online, it never turns to be offline.
But all pages on the node are removed. Just zonelists are rebuilded.
(zonelist rebuild uses stop_machine_run.

> 
> Then it also says that the fastpath doesn't use any locking, so the
> update-path first adds the newly allowed nodes, then removes the
> newly prohibited nodes. Unfortunately there are no barriers apparent
> (and none added), and cpumask/nodemask can be larger than one word,
> so it seems there could be races.
> 
Maybe. IMHO, "newly allowed node" and "newly prohobited node" come from
user's command. We don't need to guarantee correctness.

So, our concerns is only "don't access offlined node". Right ?
But as I wrote, a node once onlined will never be offlined.
So, I think it's difficult to cause panic.
My concern is zonelist rather than bitmap. But I hear no panic report
about update of it until now. (Maybe because "struct zone" is never
freed.)

> It also seems like the exported cpuset_mems_allowed and
> cpuset_cpus_allowed APIs are just broken wrt hotplug because the
> hotplug lock is dropped before returning.
> 
About cpu, it can disappear...then, it should be fixed.

> I'd just like to get opinions or comments from people who know the
> code better before wading in too far myself. I'd be really keen on
> making the locking simpler, using seqlocks for fastpaths, etc.
> 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
