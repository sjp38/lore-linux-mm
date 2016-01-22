Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 78D756B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 10:14:46 -0500 (EST)
Received: by mail-qk0-f174.google.com with SMTP id x1so29698428qkc.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 07:14:46 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n70si1624062qkh.115.2016.01.22.07.14.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 07:14:45 -0800 (PST)
Subject: Re: [BUG] oom hangs the system, NMI backtrace shows most CPUs in
 shrink_slab
References: <569D06F8.4040209@redhat.com>
 <569E1010.2070806@I-love.SAKURA.ne.jp>
From: Jan Stancek <jstancek@redhat.com>
Message-ID: <56A24760.5020503@redhat.com>
Date: Fri, 22 Jan 2016 16:14:40 +0100
MIME-Version: 1.0
In-Reply-To: <569E1010.2070806@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org
Cc: ltp@lists.linux.it

On 01/19/2016 11:29 AM, Tetsuo Handa wrote:
> although I
> couldn't find evidence that mlock() and madvice() are related with this hangup,

I simplified reproducer by having only single thread allocating
memory when OOM triggers:
  http://jan.stancek.eu/tmp/oom_hangs/console.log.3-v4.4-8606-with-memalloc.txt

In this instance it was mmap + mlock, as you can see from oom call trace.
It made it to do_exit(), but couldn't complete it:

[19419.667714] oom01           R  running task    11568 32704  32676 0x00000084
[19419.675606]  0000000000000000 0000000000000000 ffffffff81c8dfc0 0000000000000007
[19419.683910]  ffff88045fbd7ad8 ffff880451c88000 ffff88045aac8000 ffff880456f18000
[19419.692207]  ffff88044fb239c0 0000000000000000 ffffffff81205113 ffff880456f17428
[19419.700507] Call Trace:
[19419.703235]  [<ffffffff8177e8af>] ? _raw_spin_unlock+0x1f/0x40
[19419.709746]  [<ffffffff81779207>] ? preempt_schedule_common+0x1f/0x38
[19419.716936]  [<ffffffff8177923c>] ? _cond_resched+0x1c/0x30
[19419.723146]  [<ffffffff811e7369>] ? shrink_slab.part.42+0x119/0x540
[19419.730141]  [<ffffffff81027c59>] ? sched_clock+0x9/0x10
[19419.736070]  [<ffffffff811ecc2a>] ? shrink_zone+0x30a/0x330
[19419.742290]  [<ffffffff811ecff4>] ? do_try_to_free_pages+0x174/0x440
[19419.749381]  [<ffffffff811ed3c0>] ? try_to_free_pages+0x100/0x2c0
[19419.756182]  [<ffffffff81269102>] ? __alloc_pages_slowpath+0x278/0x78c
[19419.763468]  [<ffffffff811dcdb1>] ? __alloc_pages_nodemask+0x4a1/0x4d0
[19419.770755]  [<ffffffff810d592c>] ? local_clock+0x1c/0x30
[19419.776782]  [<ffffffff8123482e>] ? alloc_pages_vma+0xbe/0x2d0
[19419.783294]  [<ffffffff812224d8>] ? __read_swap_cache_async+0x118/0x200
[19419.790666]  [<ffffffff812225e6>] ? read_swap_cache_async+0x26/0x60
[19419.797665]  [<ffffffff81222785>] ? swapin_readahead+0x165/0x1f0
[19419.804367]  [<ffffffff811d0e15>] ? find_get_entry+0x5/0x220
[19419.810686]  [<ffffffff811d1c4c>] ? pagecache_get_page+0x2c/0x270
[19419.817487]  [<ffffffff810f930a>] ? __lock_acquire+0x2aa/0x1130
[19419.824094]  [<ffffffff8120aeac>] ? do_swap_page.isra.61+0x48c/0x830
[19419.831185]  [<ffffffff810f51f4>] ? __lock_is_held+0x54/0x70
[19419.837502]  [<ffffffff8120d3b9>] ? handle_mm_fault+0xa99/0x1720
[19419.844207]  [<ffffffff8120c979>] ? handle_mm_fault+0x59/0x1720
[19419.850814]  [<ffffffff810f51f4>] ? __lock_is_held+0x54/0x70
[19419.857130]  [<ffffffff8107480a>] ? __do_page_fault+0x1ca/0x470
[19419.863737]  [<ffffffff81074ae0>] ? do_page_fault+0x30/0x80
[19419.869955]  [<ffffffff8177ff87>] ? native_iret+0x7/0x7
[19419.875788]  [<ffffffff81781838>] ? page_fault+0x28/0x30
[19419.881708]  [<ffffffff813c77ef>] ? __get_user_8+0x1f/0x29
[19419.887831]  [<ffffffff8113b072>] ? exit_robust_list+0x52/0x1a0
[19419.894437]  [<ffffffff810f8cfd>] ? trace_hardirqs_on+0xd/0x10
[19419.900952]  [<ffffffff81095913>] ? mm_release+0x143/0x160
[19419.907075]  [<ffffffff8109bf36>] ? do_exit+0x166/0xce0
[19419.912899]  [<ffffffff8109cb3c>] ? do_group_exit+0x4c/0xc0
[19419.919118]  [<ffffffff810aaaf1>] ? get_signal+0x331/0x8f0
[19419.925243]  [<ffffffff8101d3c7>] ? do_signal+0x37/0x680
[19419.931172]  [<ffffffff810d592c>] ? local_clock+0x1c/0x30
[19419.937197]  [<ffffffff81117653>] ? rcu_read_lock_sched_held+0x93/0xa0
[19419.944485]  [<ffffffff8123f11d>] ? kfree+0x1bd/0x290
[19419.950124]  [<ffffffff810926a4>] ? exit_to_usermode_loop+0x33/0xac
[19419.957110]  [<ffffffff810926cf>] ? exit_to_usermode_loop+0x5e/0xac
[19419.964107]  [<ffffffff81003d0b>] ? syscall_return_slowpath+0xbb/0x130
[19419.971383]  [<ffffffff8177f55a>] ? int_ret_from_sys_call+0x25/0x9f

[19430.309232] MemAlloc-Info: 12 stalling task, 0 dying task, 0 victim task.
[19430.316821] MemAlloc: auditd(783) seq=615 gfp=0x24201ca order=0 delay=40786
[19430.324593] MemAlloc: irqbalance(806) seq=8107 gfp=0x24201ca order=0 delay=44125
[19430.332847] MemAlloc: chronyd(808) seq=3155 gfp=0x24200ca order=0 delay=10259
[19430.340812] MemAlloc: systemd-logind(818) seq=2191 gfp=0x24200ca order=0 delay=21762
[19430.349456] MemAlloc: NetworkManager(820) seq=10854 gfp=0x24200ca order=0 delay=45212
[19430.358190] MemAlloc: gssproxy(826) seq=586 gfp=0x24201ca order=0 delay=44172
[19430.366157] MemAlloc: tuned(1337) seq=40098 gfp=0x24201ca order=0 delay=45585
[19430.374121] MemAlloc: crond(2242) seq=5612 gfp=0x24201ca order=0 delay=41014
[19430.381989] MemAlloc: systemd-journal(22961) seq=151917 gfp=0x24201ca order=0 delay=46264
[19430.391118] MemAlloc: sendmail(31908) seq=7256 gfp=0x24200ca order=0 delay=43318
[19430.399365] MemAlloc: kworker/2:2(32161) seq=9 gfp=0x2400000 order=0 delay=45574
[19430.407619] MemAlloc: oom01(32704) seq=6391 gfp=0x24200ca order=0 delay=44849 exiting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
