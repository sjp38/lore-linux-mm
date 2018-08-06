Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC566B0006
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 13:44:15 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h5-v6so5909321pgs.13
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 10:44:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e189-v6si4728746pfe.206.2018.08.06.10.44.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 10:44:13 -0700 (PDT)
Date: Mon, 6 Aug 2018 19:44:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WARNING in try_charge
Message-ID: <20180806174410.GB10003@dhcp22.suse.cz>
References: <fc6e173e-8bda-269f-d44f-1c5f5215beac@I-love.SAKURA.ne.jp>
 <0000000000006350880572c61e62@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000000000006350880572c61e62@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>
Cc: cgroups@vger.kernel.org, dvyukov@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penguin-kernel@I-love.SAKURA.ne.jp, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com

On Mon 06-08-18 08:42:02, syzbot wrote:
> Hello,
> 
> syzbot has tested the proposed patch but the reproducer still triggered
> crash:
> WARNING in try_charge
> 
> Killed process 6410 (syz-executor5) total-vm:37708kB, anon-rss:2128kB,
> file-rss:0kB, shmem-rss:0kB
> oom_reaper: reaped process 6410 (syz-executor5), now anon-rss:0kB,
> file-rss:0kB, shmem-rss:0kB
> task=syz-executor5 pid=6410 invoked memcg oom killer. oom_victim=1

Thank you. This is useful. The full oom picture is this
: [   65.363983] task=syz-executor5 pid=6415 invoked memcg oom killer. oom_victim=0
[...]
: [   65.920355] Task in /ile0 killed as a result of limit of /ile0
: [   65.926389] memory: usage 0kB, limit 0kB, failcnt 20
: [   65.931518] memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
: [   65.938296] kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
: [   65.944467] Memory cgroup stats for /ile0: cache:0KB rss:0KB rss_huge:0KB shmem:0KB mapped_file:0KB dirty:0KB writeback:0KB swap:0KB inactive_anon:0KB active_anon:0KB inactive_file:0KB active_file:0KB unevictable:0KB
: [   65.963878] Tasks state (memory values in pages):
: [   65.968743] [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
: [   65.977615] [   6410]     0  6410     9427      532    61440        0             0 syz-executor5
: [   65.986647] Memory cgroup out of memory: Kill process 6410 (syz-executor5) score 547000 or sacrifice child
: [   65.996474] Killed process 6410 (syz-executor5) total-vm:37708kB, anon-rss:2128kB, file-rss:0kB, shmem-rss:0kB
: [   66.007471] oom_reaper: reaped process 6410 (syz-executor5), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
: [   66.017652] task=syz-executor5 pid=6410 invoked memcg oom killer. oom_victim=1
: [   66.025137] ------------[ cut here ]------------
: [   66.029927] Memory cgroup charge failed because of no reclaimable memory! This looks like a misconfiguration or a kernel bug.
: [   66.030061] WARNING: CPU: 1 PID: 6410 at mm/memcontrol.c:1707 try_charge+0x734/0x1680

So we have only a single task in the memcg and it is this task which
triggers the OOM. It gets killed and oom_reaped. This means that
out_of_memory should return with true and so we should retry and force
the charge as I've already mentioned. For some reason this task has
triggered the oom killer path again and then we haven't found any
eligible task and resulted in the warning. This shouldn't happen.

I will stare to the code some more to see how the heck we get there
without passing 
	if (unlikely(tsk_is_oom_victim(current) ||
		     fatal_signal_pending(current) ||
		     current->flags & PF_EXITING))
		goto force;
-- 
Michal Hocko
SUSE Labs
