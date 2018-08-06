Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5261D6B000E
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 13:56:36 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d5-v6so4501175edq.3
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 10:56:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w3-v6si6777700edc.289.2018.08.06.10.56.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 10:56:35 -0700 (PDT)
Date: Mon, 6 Aug 2018 19:56:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WARNING in try_charge
Message-ID: <20180806175627.GC10003@dhcp22.suse.cz>
References: <fc6e173e-8bda-269f-d44f-1c5f5215beac@I-love.SAKURA.ne.jp>
 <0000000000006350880572c61e62@google.com>
 <20180806174410.GB10003@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180806174410.GB10003@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>
Cc: cgroups@vger.kernel.org, dvyukov@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penguin-kernel@I-love.SAKURA.ne.jp, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com

On Mon 06-08-18 19:44:10, Michal Hocko wrote:
> On Mon 06-08-18 08:42:02, syzbot wrote:
> > Hello,
> > 
> > syzbot has tested the proposed patch but the reproducer still triggered
> > crash:
> > WARNING in try_charge
> > 
> > Killed process 6410 (syz-executor5) total-vm:37708kB, anon-rss:2128kB,
> > file-rss:0kB, shmem-rss:0kB
> > oom_reaper: reaped process 6410 (syz-executor5), now anon-rss:0kB,
> > file-rss:0kB, shmem-rss:0kB
> > task=syz-executor5 pid=6410 invoked memcg oom killer. oom_victim=1
> 
> Thank you. This is useful. The full oom picture is this
> : [   65.363983] task=syz-executor5 pid=6415 invoked memcg oom killer. oom_victim=0
> [...]
> : [   65.920355] Task in /ile0 killed as a result of limit of /ile0
> : [   65.926389] memory: usage 0kB, limit 0kB, failcnt 20
> : [   65.931518] memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
> : [   65.938296] kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
> : [   65.944467] Memory cgroup stats for /ile0: cache:0KB rss:0KB rss_huge:0KB shmem:0KB mapped_file:0KB dirty:0KB writeback:0KB swap:0KB inactive_anon:0KB active_anon:0KB inactive_file:0KB active_file:0KB unevictable:0KB
> : [   65.963878] Tasks state (memory values in pages):
> : [   65.968743] [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
> : [   65.977615] [   6410]     0  6410     9427      532    61440        0             0 syz-executor5
> : [   65.986647] Memory cgroup out of memory: Kill process 6410 (syz-executor5) score 547000 or sacrifice child
> : [   65.996474] Killed process 6410 (syz-executor5) total-vm:37708kB, anon-rss:2128kB, file-rss:0kB, shmem-rss:0kB
> : [   66.007471] oom_reaper: reaped process 6410 (syz-executor5), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> : [   66.017652] task=syz-executor5 pid=6410 invoked memcg oom killer. oom_victim=1
> : [   66.025137] ------------[ cut here ]------------
> : [   66.029927] Memory cgroup charge failed because of no reclaimable memory! This looks like a misconfiguration or a kernel bug.
> : [   66.030061] WARNING: CPU: 1 PID: 6410 at mm/memcontrol.c:1707 try_charge+0x734/0x1680
> 
> So we have only a single task in the memcg and it is this task which
> triggers the OOM. It gets killed and oom_reaped. This means that
> out_of_memory should return with true and so we should retry and force
> the charge as I've already mentioned. For some reason this task has
> triggered the oom killer path again and then we haven't found any
> eligible task and resulted in the warning. This shouldn't happen.
> 
> I will stare to the code some more to see how the heck we get there
> without passing 
> 	if (unlikely(tsk_is_oom_victim(current) ||
> 		     fatal_signal_pending(current) ||
> 		     current->flags & PF_EXITING))
> 		goto force;

Hmm, so while the OOM killer was invoked from
[   65.405905] Call Trace:
[   65.408498]  dump_stack+0x1c9/0x2b4
[   65.421606]  dump_header+0x27b/0xf70
[   65.545094]  oom_kill_process.cold.28+0x10/0x95a
[   65.605696]  out_of_memory+0xa8a/0x14d0
[   65.627227]  mem_cgroup_out_of_memory+0x213/0x300
[   65.641293]  try_charge+0x720/0x1680
[   65.674806]  memcg_kmem_charge_memcg+0x7c/0x120
[   65.687939]  cache_grow_begin+0x207/0x710
[   65.696553]  fallback_alloc+0x203/0x2c0
[   65.700519]  ____cache_alloc_node+0x1c7/0x1e0
[   65.704999]  kmem_cache_alloc+0x1e5/0x760
[   65.717947]  shmem_alloc_inode+0x1b/0x40
[   65.722003]  alloc_inode+0x63/0x190
[   65.725642]  new_inode_pseudo+0x71/0x1a0
[   65.738077]  new_inode+0x1c/0x40
[   65.741432]  shmem_get_inode+0xf1/0x910
[   65.771550]  __shmem_file_setup.part.48+0x83/0x2a0
[   65.776482]  shmem_file_setup+0x65/0x90
[   65.780444]  __x64_sys_memfd_create+0x2af/0x4f0

The warning happened from a different path
[   66.151455] RIP: 0010:try_charge+0x734/0x1680
[...]
[   66.270886]  mem_cgroup_try_charge+0x4ff/0xa70
[   66.305602]  mem_cgroup_try_charge_delay+0x1d/0x90
[   66.310514]  __handle_mm_fault+0x25be/0x4470
[   66.366608]  handle_mm_fault+0x53e/0xc80
[   66.402384]  do_page_fault+0xf6/0x8c0
[   66.451629]  page_fault+0x1e/0x30

So the oom victim indeed passed the above force path after the oom
invocation. But later on hit the page fault path and that behaved
differently and for some reason the force path hasn't triggered. I am
wondering how could we hit the page fault path in the first place. The
task is already killed! So what the hell is going on here.

I must be missing something obvious here.
-- 
Michal Hocko
SUSE Labs
