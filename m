Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A134A6B000C
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 07:18:23 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 132-v6so7043984pga.18
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 04:18:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u68-v6sor301542pfd.13.2018.08.07.04.18.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 04:18:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180806185554.GG10003@dhcp22.suse.cz>
References: <20180806181339.GD10003@dhcp22.suse.cz> <0000000000002ec4580572c85e46@google.com>
 <20180806185554.GG10003@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 7 Aug 2018 13:18:00 +0200
Message-ID: <CACT4Y+Zg3DhAnKWBAyJ-Y-3XVL+jCQy1U2iWR8mdraX6w23X_Q@mail.gmail.com>
Subject: Re: WARNING in try_charge
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Mon, Aug 6, 2018 at 8:55 PM, Michal Hocko <mhocko@kernel.org> wrote:
> The debugging patch was wrong but I guess I see it finally.
> It's a race
>
> : [   72.901666] Memory cgroup out of memory: Kill process 6584 (syz-executor1) score 550000 or sacrifice child
> : [   72.917037] Killed process 6584 (syz-executor1) total-vm:37704kB, anon-rss:2140kB, file-rss:0kB, shmem-rss:0kB
> : [   72.927256] task=syz-executor5 pid=6581 charge bypass
> : [   72.928046] oom_reaper: reaped process 6584 (syz-executor1), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> : [   72.932818] task=syz-executor6 pid=6576 invoked memcg oom killer. oom_victim=1
> : [   72.942790] task=syz-executor5 pid=6581 charge for nr_pages=1
> : [   72.949769] syz-executor6 invoked oom-killer: gfp_mask=0x6040c0(GFP_KERNEL|__GFP_COMP), nodemask=(null), order=0, oom_score_adj=0
> : [   72.955606] task=syz-executor5 pid=6581 charge bypass
> : [   72.967394] syz-executor6 cpuset=/ mems_allowed=0
> : [   72.973175] task=syz-executor5 pid=6581 charge for nr_pages=1
> : [...]
> : [   73.534865] Task in /ile0 killed as a result of limit of /ile0
> : [   73.540865] memory: usage 76kB, limit 0kB, failcnt 260
> : [   73.546142] memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
> : [   73.552898] kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
> : [   73.559051] Memory cgroup stats for /ile0: cache:0KB rss:0KB rss_huge:0KB shmem:0KB mapped_file:0KB dirty:0KB writeback:0KB swap:0KB inactive_anon:0KB active_anon:0KB inactive_file:0KB active_file:0KB unevictable:0KB
> : [   73.578533] Tasks state (memory values in pages):
> : [   73.583404] [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
> : [   73.592277] [   6569]     0  6562     9427        1    53248        0             0 syz-executor0
> : [   73.601299] [   6576]     0  6576     9426        0    61440        0             0 syz-executor6
> : [   73.610333] [   6578]     0  6578     9426      534    61440        0             0 syz-executor4
> : [   73.619381] [   6579]     0  6579     9426        0    57344        0             0 syz-executor5
> : [   73.628414] [   6582]     0  6582     9426        0    61440        0             0 syz-executor7
> : [   73.637441] [   6584]     0  6584     9426        0    57344        0             0 syz-executor1
> : [   73.646464] Memory cgroup out of memory: Kill process 6578 (syz-executor4) score 549000 or sacrifice child
> : [   73.656295] task=syz-executor6 pid=6576 is oom victim now
>
> This should be 6578 but we at least know that we are running in 6576
> context so the we are setting the state from a remote context which
> itself has been killed already
>
> : [   73.661841] Killed process 6578 (syz-executor4) total-vm:37704kB, anon-rss:2136kB, file-rss:0kB, shmem-rss:0kB
> : [   73.672035] task=syz-executor6 pid=6576 charge bypass
> : [   73.672801] oom_reaper: reaped process 6578 (syz-executor4), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> : [   73.678829] task=syz-executor4 pid=6578 invoked memcg oom killer. oom_victim=1
>
> and here the victim finally reached the oom path finally.
>
> : [   73.687453] task=syz-executor6 pid=6576 charge for nr_pages=1
> : [   73.694534] ------------[ cut here ]------------
> : [   73.700424] task=syz-executor6 pid=6576 charge bypass
> : [   73.705175] Memory cgroup charge failed because of no reclaimable memory! This looks like a misconfiguration or a kernel bug.
> : [   73.705321] WARNING: CPU: 1 PID: 6578 at mm/memcontrol.c:1707 try_charge+0xafa/0x1710
>
> But there is nobody killable. So the oom kill happened _after_ our force
> charge path. Therefore we should do the following regardless whether we
> make tis warn or pr_$foo

Great we are making progress here!

So if it's something to fix in kernel we just leave WARN alone. It
served its intended purpose of notifying kernel developers about
something to fix in kernel. And as you noted 0 is not actually special
in this context anyway. I misunderstood how exactly misconfiguration
is involved here.


> #syz test: git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git 116b181bb646afedd770985de20a68721bdb2648
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4603ad75c9a9..1b6eed1bc404 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1703,7 +1703,8 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
>                 return OOM_ASYNC;
>         }
>
> -       if (mem_cgroup_out_of_memory(memcg, mask, order))
> +       if (mem_cgroup_out_of_memory(memcg, mask, order) ||
> +                       tsk_is_oom_victim(current))
>                 return OOM_SUCCESS;
>
>         WARN(1,"Memory cgroup charge failed because of no reclaimable memory! "
> --
> Michal Hocko
> SUSE Labs
