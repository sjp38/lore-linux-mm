Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2FC4B6B0253
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 06:08:33 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id c33so10931481itf.8
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 03:08:33 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id n22si9670149ioc.210.2017.12.04.03.08.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 03:08:32 -0800 (PST)
Subject: Re: BUG: workqueue lockup (2)
References: <94eb2c03c9bc75aff2055f70734c@google.com>
 <CACT4Y+bGNU1WkyHW3nNBg49rhg8uN1j0sA0DxRj5cmZOSmsWSQ@mail.gmail.com>
 <alpine.DEB.2.20.1712031547010.2199@nanos>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <111af2fa-c3ef-e892-13fe-f745e6046d4c@I-love.SAKURA.ne.jp>
Date: Mon, 4 Dec 2017 20:08:17 +0900
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1712031547010.2199@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <bot+e38be687a2450270a3b593bacb6b5795a7a74edb@syzkaller.appspotmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Philippe Ombredanne <pombredanne@nexb.com>, syzkaller-bugs@googlegroups.com

On 2017/12/03 23:48, Thomas Gleixner wrote:
> On Sun, 3 Dec 2017, Dmitry Vyukov wrote:
> 
>> On Sun, Dec 3, 2017 at 3:31 PM, syzbot
>> <bot+e38be687a2450270a3b593bacb6b5795a7a74edb@syzkaller.appspotmail.com>
>> wrote:
>>> Hello,
>>>
>>> syzkaller hit the following crash on
>>> 2db767d9889cef087149a5eaa35c1497671fa40f
>>> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/master
>>> compiler: gcc (GCC) 7.1.1 20170620
>>> .config is attached
>>> Raw console output is attached.
>>>
>>> Unfortunately, I don't have any reproducer for this bug yet.
>>>
>>>
>>> BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 48s!
>>> BUG: workqueue lockup - pool cpus=0-1 flags=0x4 nice=0 stuck for 47s!
>>> Showing busy workqueues and worker pools:
>>> workqueue events: flags=0x0
>>>   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
>>>     pending: perf_sched_delayed, vmstat_shepherd, jump_label_update_timeout,
>>> cache_reap
>>> workqueue events_power_efficient: flags=0x80
>>>   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
>>>     pending: neigh_periodic_work, neigh_periodic_work, do_cache_clean,
>>> reg_check_chans_work
>>> workqueue mm_percpu_wq: flags=0x8
>>>   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
>>>     pending: vmstat_update
>>> workqueue writeback: flags=0x4e
>>>   pwq 4: cpus=0-1 flags=0x4 nice=0 active=1/256
>>>     in-flight: 3401:wb_workfn
>>> workqueue kblockd: flags=0x18
>>>   pwq 1: cpus=0 node=0 flags=0x0 nice=-20 active=1/256
>>>     pending: blk_mq_timeout_work
>>> pool 4: cpus=0-1 flags=0x4 nice=0 hung=0s workers=11 idle: 3423 4249 92 21
>>
>>
>> This error report does not look actionable. Perhaps if code that
>> detect it would dump cpu/task stacks, it would be actionable.
> 
> That might be related to the RCU stall issue we are chasing, where a timer
> does not fire for yet unknown reasons. We have a reproducer now and
> hopefully a solution in the next days.

Can you tell me where "the RCU stall issue" is discussed at? According to my
stress tests, wb_workfn is in-flight and other work items remain pending is a
possible sign of OOM lockup that wb_workfn is unable to invoke the OOM killer
(due to GFP_NOFS allocation request like an example shown below).

[  162.810797] kworker/u16:27: page allocation stalls for 10001ms, order:0, mode:0x1400040(GFP_NOFS), nodemask=(null)
[  162.810805] kworker/u16:27 cpuset=/ mems_allowed=0
[  162.810812] CPU: 2 PID: 354 Comm: kworker/u16:27 Not tainted 4.12.0-next-20170713+ #629
[  162.810813] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  162.810819] Workqueue: writeback wb_workfn (flush-8:0)
[  162.810822] Call Trace:
[  162.810829]  dump_stack+0x67/0x9e
[  162.810835]  warn_alloc+0x10f/0x1b0
[  162.810843]  ? wake_all_kswapds+0x56/0x96
[  162.810850]  __alloc_pages_nodemask+0xabd/0xeb0
[  162.810873]  alloc_pages_current+0x65/0xb0
[  162.810879]  xfs_buf_allocate_memory+0x15b/0x298
[  162.810886]  xfs_buf_get_map+0xf4/0x150
[  162.810893]  xfs_buf_read_map+0x29/0xd0
[  162.810900]  xfs_trans_read_buf_map+0x9a/0x1a0
[  162.810906]  xfs_btree_read_buf_block.constprop.35+0x73/0xc0
[  162.810915]  xfs_btree_lookup_get_block+0x83/0x160
[  162.810922]  xfs_btree_lookup+0xcb/0x3b0
[  162.810930]  ? xfs_allocbt_init_cursor+0x3c/0xe0
[  162.810936]  xfs_alloc_ag_vextent_near+0x216/0x840
[  162.810949]  xfs_alloc_ag_vextent+0x137/0x150
[  162.810952]  xfs_alloc_vextent+0x2ff/0x370
[  162.810958]  xfs_bmap_btalloc+0x211/0x760
[  162.810980]  xfs_bmap_alloc+0x9/0x10
[  162.810983]  xfs_bmapi_write+0x618/0xc00
[  162.811015]  xfs_iomap_write_allocate+0x18e/0x390
[  162.811034]  xfs_map_blocks+0x160/0x170
[  162.811042]  xfs_do_writepage+0x1b9/0x6b0
[  162.811056]  write_cache_pages+0x1f6/0x490
[  162.811061]  ? xfs_aops_discard_page+0x130/0x130
[  162.811079]  xfs_vm_writepages+0x66/0xa0
[  162.811088]  do_writepages+0x17/0x80
[  162.811092]  __writeback_single_inode+0x33/0x170
[  162.811097]  writeback_sb_inodes+0x2cb/0x5e0
[  162.811116]  __writeback_inodes_wb+0x87/0xc0
[  162.811122]  wb_writeback+0x1d9/0x210
[  162.811135]  wb_workfn+0x1a2/0x260
[  162.811148]  process_one_work+0x1d0/0x3e0
[  162.811150]  ? process_one_work+0x16a/0x3e0
[  162.811159]  worker_thread+0x48/0x3c0
[  162.811169]  kthread+0x10d/0x140
[  162.811170]  ? process_one_work+0x3e0/0x3e0
[  162.811173]  ? kthread_create_on_node+0x60/0x60
[  162.811179]  ret_from_fork+0x27/0x40

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
