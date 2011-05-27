Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E17FD6B0011
	for <linux-mm@kvack.org>; Fri, 27 May 2011 00:41:23 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B9B0D3EE0B6
	for <linux-mm@kvack.org>; Fri, 27 May 2011 13:41:19 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 68E7345DF99
	for <linux-mm@kvack.org>; Fri, 27 May 2011 13:41:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 46DFA45DF96
	for <linux-mm@kvack.org>; Fri, 27 May 2011 13:41:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 31CFF1DB802F
	for <linux-mm@kvack.org>; Fri, 27 May 2011 13:41:19 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A7D291DB8041
	for <linux-mm@kvack.org>; Fri, 27 May 2011 13:41:18 +0900 (JST)
Date: Fri, 27 May 2011 13:34:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH v3 0/10] memcg async reclaim
Message-Id: <20110527133431.471eefc2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTi=Cw8HSTUjNfJzH8GhfwQhUua-h7w@mail.gmail.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikcdOGkJWxS0Sey8C1ereVk8ucvQQ@mail.gmail.com>
	<20110527111639.22e3e257.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=Cw8HSTUjNfJzH8GhfwQhUua-h7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Thu, 26 May 2011 21:33:32 -0700
Ying Han <yinghan@google.com> wrote:

> On Thu, May 26, 2011 at 7:16 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 26 May 2011 18:49:26 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> >> On Wed, May 25, 2011 at 10:10 PM, KAMEZAWA Hiroyuki
> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> >
> >> > It's now merge window...I just dump my patch queue to hear other's idea.
> >> > I wonder I should wait until dirty_ratio for memcg is queued to mmotm...
> >> > I'll be busy with LinuxCon Japan etc...in the next week.
> >> >
> >> > This patch is onto mmotm-May-11 + some patches queued in mmotm, as numa_stat.
> >> >
> >> > This is a patch for memcg to keep margin to the limit in background.
> >> > By keeping some margin to the limit in background, application can
> >> > avoid foreground memory reclaim at charge() and this will help latency.
> >> >
> >> > Main changes from v2 is.
> >> > A - use SCHED_IDLE.
> >> > A - removed most of heuristic codes. Now, code is very simple.
> >> >
> >> > By using SCHED_IDLE, async memory reclaim can only consume 0.3%? of cpu
> >> > if the system is truely busy but can use much CPU if the cpu is idle.
> >> > Because my purpose is for reducing latency without affecting other running
> >> > applications, SCHED_IDLE fits this work.
> >> >
> >> > If application need to stop by some I/O or event, background memory reclaim
> >> > will cull memory while the system is idle.
> >> >
> >> > Perforemce:
> >> > A Running an httpd (apache) under 300M limit. And access 600MB working set
> >> > A with normalized distribution access by apatch-bench.
> >> > A apatch bench's concurrency was 4 and did 40960 accesses.
> >> >
> >> > Without async reclaim:
> >> > Connection Times (ms)
> >> > A  A  A  A  A  A  A min A mean[+/-sd] median A  max
> >> > Connect: A  A  A  A 0 A  A 0 A  0.0 A  A  A 0 A  A  A  2
> >> > Processing: A  A 30 A  37 A 28.3 A  A  32 A  A 1793
> >> > Waiting: A  A  A  28 A  35 A 25.5 A  A  31 A  A 1792
> >> > Total: A  A  A  A  30 A  37 A 28.4 A  A  32 A  A 1793
> >> >
> >> > Percentage of the requests served within a certain time (ms)
> >> > A 50% A  A  32
> >> > A 66% A  A  32
> >> > A 75% A  A  33
> >> > A 80% A  A  34
> >> > A 90% A  A  39
> >> > A 95% A  A  60
> >> > A 98% A  A 100
> >> > A 99% A  A 133
> >> > A 100% A  1793 (longest request)
> >> >
> >> > With async reclaim:
> >> > Connection Times (ms)
> >> > A  A  A  A  A  A  A min A mean[+/-sd] median A  max
> >> > Connect: A  A  A  A 0 A  A 0 A  0.0 A  A  A 0 A  A  A  2
> >> > Processing: A  A 30 A  35 A 12.3 A  A  32 A  A  678
> >> > Waiting: A  A  A  28 A  34 A 12.0 A  A  31 A  A  658
> >> > Total: A  A  A  A  30 A  35 A 12.3 A  A  32 A  A  678
> >> >
> >> > Percentage of the requests served within a certain time (ms)
> >> > A 50% A  A  32
> >> > A 66% A  A  32
> >> > A 75% A  A  33
> >> > A 80% A  A  34
> >> > A 90% A  A  39
> >> > A 95% A  A  49
> >> > A 98% A  A  71
> >> > A 99% A  A  86
> >> > A 100% A  A 678 (longest request)
> >> >
> >> >
> >> > It seems latency is stabilized by hiding memory reclaim.
> >> >
> >> > The score for memory reclaim was following.
> >> > See patch 10 for meaning of each member.
> >> >
> >> > == without async reclaim ==
> >> > recent_scan_success_ratio 44
> >> > limit_scan_pages 388463
> >> > limit_freed_pages 162238
> >> > limit_elapsed_ns 13852159231
> >> > soft_scan_pages 0
> >> > soft_freed_pages 0
> >> > soft_elapsed_ns 0
> >> > margin_scan_pages 0
> >> > margin_freed_pages 0
> >> > margin_elapsed_ns 0
> >> >
> >> > == with async reclaim ==
> >> > recent_scan_success_ratio 6
> >> > limit_scan_pages 0
> >> > limit_freed_pages 0
> >> > limit_elapsed_ns 0
> >> > soft_scan_pages 0
> >> > soft_freed_pages 0
> >> > soft_elapsed_ns 0
> >> > margin_scan_pages 1295556
> >> > margin_freed_pages 122450
> >> > margin_elapsed_ns 644881521
> >> >
> >> >
> >> > For this case, SCHED_IDLE workqueue can reclaim enough memory to the httpd.
> >> >
> >> > I may need to dig why scan_success_ratio is far different in the both case.
> >> > I guess the difference of epalsed_ns is because several threads enter
> >> > memory reclaim when async reclaim doesn't run. But may not...
> >> >
> >>
> >>
> >> Hmm.. I noticed a very strange behavior on a simple test w/ the patch set.
> >>
> >> Test:
> >> I created a 4g memcg and start doing cat. Then the memcg being OOM
> >> killed as soon as it reaches its hard_limit. We shouldn't hit OOM even
> >> w/o async-reclaim.
> >>
> >> Again, I will read through the patch. But like to post the test result first.
> >>
> >> $ echo $$ >/dev/cgroup/memory/A/tasks
> >> $ cat /dev/cgroup/memory/A/memory.limit_in_bytes
> >> 4294967296
> >>
> >> $ time cat /export/hdc3/dd_A/tf0 > /dev/zero
> >> Killed
> >>
> >
> > I did the same kind of test without any problem...but ok, I'll do more test
> > later.
> >
> >
> >
> >> real A 0m53.565s
> >> user A 0m0.061s
> >> sys A  0m4.814s
> >>
> >> Here is the OOM log:
> >>
> >> May 26 18:43:00 A kernel: [ A 963.489112] cat invoked oom-killer:
> >> gfp_mask=0xd0, order=0, oom_adj=0, oom_score_adj=0
> >> May 26 18:43:00 A kernel: [ A 963.489121] Pid: 9425, comm: cat Tainted:
> >> G A  A  A  A W A  2.6.39-mcg-DEV #131
> >> May 26 18:43:00 A kernel: [ A 963.489123] Call Trace:
> >> May 26 18:43:00 A kernel: [ A 963.489134] A [<ffffffff810e3512>]
> >> dump_header+0x82/0x1af
> >> May 26 18:43:00 A kernel: [ A 963.489137] A [<ffffffff810e33ca>] ?
> >> spin_lock+0xe/0x10
> >> May 26 18:43:00 A kernel: [ A 963.489140] A [<ffffffff810e33f9>] ?
> >> find_lock_task_mm+0x2d/0x67
> >> May 26 18:43:00 A kernel: [ A 963.489143] A [<ffffffff810e38dd>]
> >> oom_kill_process+0x50/0x27b
> >> May 26 18:43:00 A kernel: [ A 963.489155] A [<ffffffff810e3dc6>]
> >> mem_cgroup_out_of_memory+0x9a/0xe4
> >> May 26 18:43:00 A kernel: [ A 963.489160] A [<ffffffff811153aa>]
> >> mem_cgroup_handle_oom+0x134/0x1fe
> >> May 26 18:43:00 A kernel: [ A 963.489163] A [<ffffffff81114a72>] ?
> >> __mem_cgroup_insert_exceeded+0x83/0x83
> >> May 26 18:43:00 A kernel: [ A 963.489176] A [<ffffffff811166e9>]
> >> __mem_cgroup_try_charge.clone.3+0x368/0x43a
> >> May 26 18:43:00 A kernel: [ A 963.489179] A [<ffffffff81117586>]
> >> mem_cgroup_cache_charge+0x95/0x123
> >> May 26 18:43:00 A kernel: [ A 963.489183] A [<ffffffff810e16d8>]
> >> add_to_page_cache_locked+0x42/0x114
> >> May 26 18:43:00 A kernel: [ A 963.489185] A [<ffffffff810e17db>]
> >> add_to_page_cache_lru+0x31/0x5f
> >> May 26 18:43:00 A kernel: [ A 963.489189] A [<ffffffff81145636>]
> >> mpage_readpages+0xb6/0x132
> >> May 26 18:43:00 A kernel: [ A 963.489194] A [<ffffffff8119992f>] ?
> >> noalloc_get_block_write+0x24/0x24
> >> May 26 18:43:00 A kernel: [ A 963.489197] A [<ffffffff8119992f>] ?
> >> noalloc_get_block_write+0x24/0x24
> >> May 26 18:43:00 A kernel: [ A 963.489201] A [<ffffffff81036742>] ?
> >> __switch_to+0x160/0x212
> >> May 26 18:43:00 A kernel: [ A 963.489205] A [<ffffffff811978b2>]
> >> ext4_readpages+0x1d/0x1f
> >> May 26 18:43:00 A kernel: [ A 963.489209] A [<ffffffff810e8d4b>]
> >> __do_page_cache_readahead+0x144/0x1e3
> >> May 26 18:43:00 A kernel: [ A 963.489212] A [<ffffffff810e8e0b>]
> >> ra_submit+0x21/0x25
> >> May 26 18:43:00 A kernel: [ A 963.489215] A [<ffffffff810e9075>]
> >> ondemand_readahead+0x18c/0x19f
> >> May 26 18:43:00 A kernel: [ A 963.489218] A [<ffffffff810e9105>]
> >> page_cache_async_readahead+0x7d/0x86
> >> May 26 18:43:00 A kernel: [ A 963.489221] A [<ffffffff810e2b7e>]
> >> generic_file_aio_read+0x2d8/0x5fe
> >> May 26 18:43:00 A kernel: [ A 963.489225] A [<ffffffff81119626>]
> >> do_sync_read+0xcb/0x108
> >> May 26 18:43:00 A kernel: [ A 963.489230] A [<ffffffff811f168a>] ?
> >> fsnotify_perm+0x66/0x72
> >> May 26 18:43:00 A kernel: [ A 963.489233] A [<ffffffff811f16f7>] ?
> >> security_file_permission+0x2e/0x33
> >> May 26 18:43:00 A kernel: [ A 963.489236] A [<ffffffff8111a0c8>]
> >> vfs_read+0xab/0x107
> >> May 26 18:43:00 A kernel: [ A 963.489239] A [<ffffffff8111a1e4>] sys_read+0x4a/0x6e
> >> May 26 18:43:00 A kernel: [ A 963.489244] A [<ffffffff8140f469>]
> >> sysenter_dispatch+0x7/0x27
> >> May 26 18:43:00 A kernel: [ A 963.489248] Task in /A killed as a result
> >> of limit of /A
> >> May 26 18:43:00 A kernel: [ A 963.489251] memory: usage 4194304kB, limit
> >> 4194304kB, failcnt 26
> >> May 26 18:43:00 A kernel: [ A 963.489253] memory+swap: usage 0kB, limit
> >> 9007199254740991kB, failcnt 0
> >>
> >
> > Hmm, why memory+swap usage 0kb here...
> >
> > In this set, I used mem_cgroup_margin() rather than res_counter_margin().
> > Hmm, do you disable swap accounting ? If so, I may miss some.
> 
> Yes, I disabled the swap accounting in .config:
> # CONFIG_CGROUP_MEM_RES_CTLR_SWAP is not set
> 
> 
> Here is how i reproduce it:
> 
> $ mkdir /dev/cgroup/memory/D
> $ echo 4g >/dev/cgroup/memory/D/memory.limit_in_bytes
> 
> $ cat /dev/cgroup/memory/D/memory.limit_in_bytes
> 4294967296
> 
> $ cat /dev/cgroup/memory/D/memory.
> memory.async_control             memory.max_usage_in_bytes
> memory.soft_limit_in_bytes       memory.use_hierarchy
> memory.failcnt                   memory.move_charge_at_immigrate
> memory.stat
> memory.force_empty               memory.oom_control
> memory.swappiness
> memory.limit_in_bytes            memory.reclaim_stat
> memory.usage_in_bytes
> 
> $ cat /dev/cgroup/memory/D/memory.async_control
> 0
> $ echo 1 >/dev/cgroup/memory/D/memory.async_control
> $ cat /dev/cgroup/memory/D/memory.async_control
> 1
> 
> $ echo $$ >/dev/cgroup/memory/D/tasks
> $ cat /proc/4358/cgroup
> 3:memory:/D
> 
> $ time cat /export/hdc3/dd_A/tf0 > /dev/zero
> Killed
> 

If you applied my patches collectly, async_control can be seen if
swap controller is configured because of BUG in patch.

I could cat 20G file under 4G limit without any problem with boot option
swapaccount=0. no problem if async_control == 0 ?



Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
