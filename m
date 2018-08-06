Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 44D0B6B0008
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 13:49:39 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id q21-v6so8954347pff.21
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 10:49:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w5-v6sor3886366pfn.0.2018.08.06.10.49.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 10:49:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180806174410.GB10003@dhcp22.suse.cz>
References: <fc6e173e-8bda-269f-d44f-1c5f5215beac@I-love.SAKURA.ne.jp>
 <0000000000006350880572c61e62@google.com> <20180806174410.GB10003@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 6 Aug 2018 19:49:16 +0200
Message-ID: <CACT4Y+YDTvOTrSWBU-cZ-yFAbsJP=J9Nhp9w1F2cGG7hw4P81Q@mail.gmail.com>
Subject: Re: WARNING in try_charge
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Mon, Aug 6, 2018 at 7:44 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 06-08-18 08:42:02, syzbot wrote:
>> Hello,
>>
>> syzbot has tested the proposed patch but the reproducer still triggered
>> crash:
>> WARNING in try_charge
>>
>> Killed process 6410 (syz-executor5) total-vm:37708kB, anon-rss:2128kB,
>> file-rss:0kB, shmem-rss:0kB
>> oom_reaper: reaped process 6410 (syz-executor5), now anon-rss:0kB,
>> file-rss:0kB, shmem-rss:0kB
>> task=syz-executor5 pid=6410 invoked memcg oom killer. oom_victim=1
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
>         if (unlikely(tsk_is_oom_victim(current) ||
>                      fatal_signal_pending(current) ||
>                      current->flags & PF_EXITING))
>                 goto force;


This is the syzkaller reproducer if it will give you any hints:

mkdir(&(0x7f0000000340)='./file0\x00', 0x0)
mount(&(0x7f00000000c0)='./file0//ile0\x00',
&(0x7f0000000080)='./file0\x00', &(0x7f0000000200)='cgroup2\x00', 0x0,
0x0)
r0 = open(&(0x7f0000000040)='./file0//ile0\x00', 0x0, 0x0)
r1 = openat$cgroup_procs(r0, &(0x7f00000001c0)='cgroup.procs\x00', 0x2, 0x0)
write$cgroup_pid(r1, &(0x7f0000000100), 0x12)
syz_mount_image$xfs(&(0x7f0000000280)='xfs\x00',
&(0x7f00000002c0)='./file0//ile0\x00', 0x0, 0x0, &(0x7f0000000740),
0x0, &(0x7f0000000800))
getsockopt$sock_cred(r0, 0x1, 0x11, &(0x7f0000000180), &(0x7f0000000240)=0xc)
r2 = open(&(0x7f0000000040)='./file0//ile0\x00', 0x0, 0x0)
write$FUSE_STATFS(r2, &(0x7f0000000280)={0x60, 0xfffffffffffffffe,
0x7, {{0x401, 0x7, 0x7d, 0x1c, 0xd8, 0xb7, 0x2, 0x3}}}, 0x60)
r3 = openat$cgroup_int(r2, &(0x7f00000001c0)='memory.max\x00', 0x2, 0x0)
write$cgroup_int(r3, &(0x7f00000000c0), 0x12)
