Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id B138E6B0044
	for <linux-mm@kvack.org>; Sat, 24 Mar 2012 10:46:03 -0400 (EDT)
Date: Sat, 24 Mar 2012 10:45:59 -0400
Message-Id: <E1SBSEB-0008Mf-4s@tytso-glaptop.cam.corp.google.com>
Subject: RCU stalls in merge-window (v3.3-6946-gf1d38e4)
From: "Theodore Ts'o" <tytso@mit.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>


I've been running xfstests of my ext4 dev branch merged in with
v3.3-6946-gf1d38e3 --- the latest from Linus's tree as of this morning
--- as a last minute check before sending a pull request to Linus, and
I'm seeing that xfstests #76 is quite reliably causing an rcu_sched
self-detecting stall warning, followed by a wedged kernel.

A quick web search shows that Dan Carpenter noticed a similar problem
about two weeks ago, but there was no follow-up as far as I could tell:

	https://lkml.org/lkml/2012/3/13/360

Since Dan reported that "light e-mail and the occasional git pull" on
his netbook is sufficient to reproduce this problem, it seems rather
serious...

Any updates on this issue?

					- Ted


076	[  216.353320] INFO: rcu_sched self-detected stall on CPU { 0}  (t=18000 jiffies)
[  216.353321] Pid: 623, comm: kswapd0 Not tainted 3.3.0-07010-g1a897e3 #36
[  216.353321] Call Trace:
[  216.353321]  [<c01b91be>] __rcu_pending+0x9e/0x34e
[  216.353321]  [<c01b948f>] rcu_pending+0x21/0x4d
[  216.353321]  [<c01b9956>] rcu_check_callbacks+0x79/0x97
[  216.353321]  [<c0163869>] update_process_times+0x32/0x5d
[  216.353321]  [<c019349b>] tick_sched_timer+0x6d/0x9b
[  216.353321]  [<c01744f2>] __run_hrtimer+0xa7/0x11e
[  216.353321]  [<c019342e>] ? tick_nohz_handler+0xd9/0xd9
[  216.353321]  [<c0174773>] hrtimer_interrupt+0xe6/0x1ec
[  216.353321]  [<c0147f7a>] smp_apic_timer_interrupt+0x6c/0x7f
[  216.353321]  [<c06db117>] apic_timer_interrupt+0x2f/0x34
[  216.353321]  [<c01dfa12>] ? zone_watermark_ok_safe+0x22/0x85
[  216.353321]  [<c01e9eb5>] kswapd+0x3d8/0x7f9
[  216.353321]  [<c0170d68>] ? wake_up_bit+0x60/0x60
[  216.353321]  [<c01e9add>] ? shrink_all_memory+0xa8/0xa8
[  216.353321]  [<c01709e6>] kthread+0x6c/0x71
[  216.353321]  [<c017097a>] ? __init_kthread_worker+0x47/0x47
[  216.353321]  [<c06e08ba>] kernel_thread_helper+0x6/0x10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
