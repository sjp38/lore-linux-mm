Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3F7306B0047
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 08:49:28 -0500 (EST)
Date: Fri, 19 Feb 2010 00:49:21 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: [regression] cpuset,mm: update tasks' mems_allowed in time
 (58568d2)
Message-ID: <20100218134921.GF9738@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Miao Xie <miaox@cn.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hi,

The patch cpuset,mm: update tasks' mems_allowed in time (58568d2) causes
a regression uncovered by SGI. Basically it is allowing possible but not
online nodes in the task_struct.mems_allowed nodemask (which is contrary
to several comments still in kernel/cpuset.c), and that causes
cpuset_mem_spread_node() to return an offline node to slab, causing an
oops.

Easy to reproduce if you have a machine with !online nodes.

        - mkdir /dev/cpuset
        - mount cpuset -t cpuset /dev/cpuset
        - echo 1 > /dev/cpuset/memory_spread_slab

kernel BUG at
/usr/src/packages/BUILD/kernel-default-2.6.32/linux-2.6.32/mm/slab.c:3271!
bash[6885]: bugcheck! 0 [1]
Pid: 6885, CPU 5, comm:                 bash
psr : 00001010095a2010 ifs : 800000000000038b ip  : [<a00000010020cf00>]
Tainted: G        W    (2.6.32-0.6.8-default)
ip is at ____cache_alloc_node+0x440/0x500

unat: 0000000000000000 pfs : 000000000000038b rsc : 0000000000000003
rnat: 0000000000283d85 bsps: 0000000000000001 pr  : 99596aaa69aa6999
ldrs: 0000000000000000 ccv : 0000000000000018 fpsr: 0009804c0270033f
csd : 0000000000000000 ssd : 0000000000000000
b0  : a00000010020cf00 b6  : a0000001004962c0 b7  : a000000100493240
f6  : 000000000000000000000 f7  : 000000000000000000000
f8  : 000000000000000000000 f9  : 000000000000000000000
f10 : 000000000000000000000 f11 : 000000000000000000000
r1  : a0000001015c6fc0 r2  : 000000000000e662 r3  : 000000000000fffe
r8  : 000000000000005c r9  : 0000000000000000 r10 : 0000000000004000
r11 : 0000000000000000 r12 : e000003c3904fcc0 r13 : e000003c39040000
r14 : 000000000000e662 r15 : a00000010138ed88 r16 : ffffffffffff65c8
r17 : a00000010138ed80 r18 : a0000001013c7ad0 r19 : a0000001013d3b60
r20 : e00001b03afdfe18 r21 : 0000000000000001 r22 : e0000130030365c8
r23 : e000013003040000 r24 : ffffffffffff0400 r25 : 00000000000068ef
r26 : 00000000000068ef r27 : a0000001029621d0 r28 : 00000000000068f0
r29 : 00000000000068f0 r30 : 00000000000068f0 r31 : 000000000000000a

Call Trace:
[<a000000100017a80>] show_stack+0x80/0xa0
[<a0000001000180e0>] show_regs+0x640/0x920
[<a000000100029a90>] die+0x190/0x2e0
[<a000000100029c30>] die_if_kernel+0x50/0x80
[<a000000100904af0>] ia64_bad_break+0x470/0x760
[<a00000010000cb60>] ia64_native_leave_kernel+0x0/0x270
[<a00000010020cf00>] ____cache_alloc_node+0x440/0x500
[<a00000010020ffa0>] kmem_cache_alloc+0x360/0x660

A simple bandaid is to skip !online nodes in cpuset_mem_spread_node().
However I'm a bit worried about 58568d2.

It is doing a lot of stuff. It is removing the callback_mutex from
around several seemingly unrelated places (eg. from around
guarnatee_online_cpus, which explicitly asks to be called with that
lock held), and other places, so I don't know how it is not racy
with hotplug.

Then it also says that the fastpath doesn't use any locking, so the
update-path first adds the newly allowed nodes, then removes the
newly prohibited nodes. Unfortunately there are no barriers apparent
(and none added), and cpumask/nodemask can be larger than one word,
so it seems there could be races.

It also seems like the exported cpuset_mems_allowed and
cpuset_cpus_allowed APIs are just broken wrt hotplug because the
hotplug lock is dropped before returning.

I'd just like to get opinions or comments from people who know the
code better before wading in too far myself. I'd be really keen on
making the locking simpler, using seqlocks for fastpaths, etc.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
