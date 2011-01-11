Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1DB356B00E7
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 22:35:38 -0500 (EST)
Date: Mon, 10 Jan 2011 22:35:34 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1182272788.40910.1294716934667.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <alpine.DEB.2.00.1101101914560.13327@chino.kir.corp.google.com>
Subject: Re: known oom issues on numa in -mm tree?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


> I'm assuming you've setup a cpuset with cpuset.mems == 1 if you're
> citing
> the fact that node 1 is exhausted (please confirm this since your
> initial
> post said this was an issue with both cpusets and memcg, but failed to
> give details on the actual configuration). ZONE_NORMAL for that node
> has
> its all_unreclaimable flag still off, so it indicates it's still
> possible
> to free memory before killing a task. You may also want to ensure that
> no
> other tasks are dying in the background because the oom killer will
> silently give them access to memory reserves so they can quietly and
> quickly exit rather than killing something else in its place.
Sorry for the confusing. There are two tests - oom02 and oom04. oom02
tested cpuset on NUMA while oom04 tested cpuset and memcg on NUMA. The
above sysrq-m only referred to oom02. Although both tests indicated
problems, it is normal easier to solve it one-by-one. I can't see any
obvious tasks that were dying in background. Those were tests that were
running right after a fresh-installed system. Not sure if KSM was coming
in play here, as it was enabled and all of those allocations were using the
same memory contents. In any case, here was the additional sysrq-t output
when oom02 hung.

kswapd0         S ffff88021a566b50     0    81      2 0x00000000
 ffff88021a5cbdc0 0000000000000046 0000000000000000 dead000000000000
 ffff88021a5665c0 0000000000014d80 ffff88021a5cbfd8 ffff88021a5ca010
 ffff88021a5cbfd8 0000000000014d80 ffffffff81a0b020 ffff88021a5665c0
Call Trace:
 [<ffffffff8110a880>] ? kswapd+0x0/0x9e0
 [<ffffffff8110b1d8>] kswapd+0x958/0x9e0
 [<ffffffff8149fcab>] ? schedule+0x3eb/0x9b0
 [<ffffffff81082930>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8110a880>] ? kswapd+0x0/0x9e0
 [<ffffffff810822a6>] kthread+0x96/0xa0
 [<ffffffff8100ce04>] kernel_thread_helper+0x4/0x10
 [<ffffffff81082210>] ? kthread+0x0/0xa0
 [<ffffffff8100ce00>] ? kernel_thread_helper+0x0/0x10
kswapd1         R  running task        0    82      2 0x00000000
 0000000000000000 0000000051eb851f 0000000000000000 0000000000000000
 ffff88021a5cdd70 ffffffff81167c09 ffff88042ffda290 ffff88042ffda288
 ffff88021a5cdd70 ffffffffffffffff 000000061f995fd8 ffffffffa03d7540
Call Trace:
 [<ffffffff81167c09>] ? shrink_icache_memory+0x39/0x330
 [<ffffffff81106e39>] ? shrink_slab+0x89/0x180
 [<ffffffff8110acc6>] ? kswapd+0x446/0x9e0
 [<ffffffff8110a880>] ? kswapd+0x0/0x9e0
 [<ffffffff810822a6>] ? kthread+0x96/0xa0
 [<ffffffff8100ce04>] ? kernel_thread_helper+0x4/0x10
 [<ffffffff81082210>] ? kthread+0x0/0xa0
 [<ffffffff8100ce00>] ? kernel_thread_helper+0x0/0x10
ksmd            S ffff88021a562b50     0    83      2 0x00000000
 ffff88021a61fe30 0000000000000046 ffffffff8113c360 0000000000000000
 ffff88021a5625c0 0000000000014d80 ffff88021a61ffd8 ffff88021a61e010
 ffff88021a61ffd8 0000000000014d80 ffff88021f2055c0 ffff88021a5625c0
Call Trace:
 [<ffffffff8113c360>] ? ksm_scan_thread+0x0/0xc30
 [<ffffffff8113c360>] ? ksm_scan_thread+0x0/0xc30
 [<ffffffff8113caf2>] ksm_scan_thread+0x792/0xc30
 [<ffffffff81082930>] ? autoremove_wake_function+0x0/0x40
 [<ffffffff8113c360>] ? ksm_scan_thread+0x0/0xc30
 [<ffffffff810822a6>] kthread+0x96/0xa0
 [<ffffffff8100ce04>] kernel_thread_helper+0x4/0x10
 [<ffffffff81082210>] ? kthread+0x0/0xa0
 [<ffffffff8100ce00>] ? kernel_thread_helper+0x0/0x10

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
