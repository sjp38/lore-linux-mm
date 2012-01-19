Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id AB1E76B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 00:54:08 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C714F3EE0B6
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 14:54:06 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A836A45DE69
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 14:54:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EB4645DE55
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 14:54:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E3B61DB802C
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 14:54:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E5D01DB803C
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 14:54:06 +0900 (JST)
Date: Thu, 19 Jan 2012 14:52:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] kernel BUG at mm/memcontrol.c:1074!
Message-Id: <20120119145250.acf3ccc8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1326949826.5016.5.camel@lappy>
References: <1326949826.5016.5.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: hannes <hannes@cmpxchg.org>, mhocko@suse.cz, bsingharora@gmail.com, Dave Jones <davej@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu, 19 Jan 2012 07:10:26 +0200
Sasha Levin <levinsasha928@gmail.com> wrote:

> The problem is, that it looks like this has triggered a BUG() in the memory cgroup code:
> 
> [  526.737227] ------------[ cut here ]------------
> [  526.738032] 
> [  526.738032] invalid opcode: 0000 [#1] PREEMPT SMP 
> [  526.738032] CPU 0 
> [  526.738032] Pid: 1091, comm: kswapd0 Not tainted 3.2.0-next-20120119-sasha #128  
> [  526.738032] RIP: 0010:[<ffffffff811c4b4a>]  [<ffffffff811c4b4a>] mem_cgroup_lru_del_list+0xca/0xd0
> [  526.738032] RSP: 0018:ffff8800127139a0  EFLAGS: 00010046
> [  526.738032] RAX: 0000000000000001 RBX: ffffea0000358300 RCX: 0000000000000000
> [  526.738032] RDX: ffff880012c0b800 RSI: 0000000000000000 RDI: 0000000000000000
> [  526.738032] RBP: ffff8800127139b0 R08: ffff880012713ad0 R09: 0000000000000001
> [  526.738032] R10: 0000000000000000 R11: 0000000000000001 R12: 0000000000000002
> [  526.738032] R13: ffffea0000358300 R14: ffffea0000358320 R15: 0000000000000001
> [  526.738032] FS:  0000000000000000(0000) GS:ffff880013a00000(0000) knlGS:0000000000000000
> [  526.738032] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  526.738032] CR2: 00007fea7fa42e66 CR3: 000000000c42a000 CR4: 00000000000406f0
> [  526.738032] DR0: ffffffff810aaee0 DR1: 0000000000000000 DR2: 0000000000000000
> [  526.738032] DR3: 0000000000000000 DR6: 00000000ffff4ff0 DR7: 0000000000000600
> [  526.738032] Process kswapd0 (pid: 1091, threadinfo ffff880012712000, task ffff880012f7d840)
> [  526.738032] Stack:
> [  526.738032]  ffff880012c0b968 ffff880012c0b968 ffff8800127139c0 ffffffff811c4f0a
> [  526.738032]  ffff880012713a70 ffffffff81178c63 ffff8800127139e0 ffffea00000cbba0
> [  526.738032]  ffff880012713a40 ffff880012713b08 0000000000000001 ffffffffffffffff
> [  526.738032] Call Trace:
> [  526.738032]  [<ffffffff811c4f0a>] mem_cgroup_lru_del+0x3a/0x40
> [  526.738032]  [<ffffffff81178c63>] isolate_lru_pages+0xe3/0x330
> [  526.738032]  [<ffffffff8117a11e>] ? shrink_inactive_list+0xce/0x480
> [  526.738032]  [<ffffffff8117a153>] shrink_inactive_list+0x103/0x480
> [  526.738032]  [<ffffffff811c2a46>] ? mem_cgroup_iter+0x176/0x310
> [  526.738032]  [<ffffffff810e2c55>] ? sched_clock_local+0x25/0x90
> [  526.738032]  [<ffffffff8117ac04>] shrink_mem_cgroup_zone+0x3f4/0x580
> [  526.738032]  [<ffffffff81107cfe>] ? put_lock_stats.clone.18+0xe/0x40
> [  526.738032]  [<ffffffff8117adfe>] shrink_zone+0x6e/0xa0
> [  526.738032]  [<ffffffff8117be65>] balance_pgdat+0x545/0x750
> [  526.738032]  [<ffffffff810de1ed>] ? sub_preempt_count+0x9d/0xd0
> [  526.738032]  [<ffffffff8117c233>] kswapd+0x1c3/0x320
> [  526.738032]  [<ffffffff810cee30>] ? abort_exclusive_wait+0xb0/0xb0
> [  526.738032]  [<ffffffff8117c070>] ? balance_pgdat+0x750/0x750
> [  526.738032]  [<ffffffff810ce06e>] kthread+0xbe/0xd0
> [  526.738032]  [<ffffffff82585df4>] kernel_thread_helper+0x4/0x10
> [  526.738032]  [<ffffffff810d8c88>] ? finish_task_switch+0x78/0x100
> [  526.738032]  [<ffffffff825840f8>] ? retint_restore_args+0x13/0x13
> [  526.738032]  [<ffffffff810cdfb0>] ? kthread_flush_work_fn+0x10/0x10
> [  526.738032]  [<ffffffff82585df0>] ? gs_change+0x13/0x13
> [  526.738032] Code: 8b 1c 24 4c 8b 64 24 08 c9 c3 0f 1f 80 00 00 00 00 8b 4b 68 eb ba 0f 1f 00 0f b6 4b 68 bb 01 00 00 00 d3 e3 48 63 cb eb c2 0f 0b <0f> 0b 0f 1f 40 00 55 48 89 e5 48 83 ec 60 48 89 5d d8 4c 89 65 
> [  526.738032] RIP  [<ffffffff811c4b4a>] mem_cgroup_lru_del_list+0xca/0xd0
> [  526.738032]  RSP <ffff8800127139a0>
> [  526.738032] ---[ end trace 866f4f6c624b8d58 ]---

my memo here.

1. This is caused by pc->mem_cgroup was NULL at mem_cgroup_lru_del().

2. IIUC, PageLRU(page) should be true to cause this BUG. Then,
   there is a page whose pc->mem_cgroup == NULL but PageLRU(page)==true.
   But, memcg's lru_add() routine accesses pc->mem_cgroup...so it should
   cause NULL pointer access if the page was added to LRU with pc->mem_cgroup is NULL.

   One possibility is that the page was PageLRU set but not added to memcg's LRU
   ... added to zone's LRU directly..
   Or PageLRU(page) was true but not added to any lru list without pc->mem_cgroup updates.

3. IIUC, There is no routine to set pc->mem_cgroup as NULL once page is used.
   But I need to check it....

Regards,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
