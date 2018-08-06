Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B1EB6B0007
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 05:15:55 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t10-v6so3958754eds.7
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 02:15:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j4-v6si9335530edl.323.2018.08.06.02.15.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 02:15:53 -0700 (PDT)
Date: Mon, 6 Aug 2018 11:15:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: WARNING in try_charge
Message-ID: <20180806091552.GE19540@dhcp22.suse.cz>
References: <0000000000005e979605729c1564@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000000000005e979605729c1564@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>
Cc: cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com

On Sat 04-08-18 06:33:02, syzbot wrote:
> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    d1e0b8e0cb7a Add linux-next specific files for 20180725
> git tree:       linux-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=15a1c770400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=eef3552c897e4d33
> dashboard link: https://syzkaller.appspot.com/bug?extid=bab151e82a4e973fa325
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> 
> Unfortunately, I don't have any reproducer for this crash yet.
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com
> 
> Killed process 23767 (syz-executor2) total-vm:70472kB, anon-rss:104kB,
> file-rss:32768kB, shmem-rss:0kB
> oom_reaper: reaped process 23767 (syz-executor2), now anon-rss:0kB,
> file-rss:32000kB, shmem-rss:0kB

More interesting stuff is higher in the kernel log
: [  366.435015] oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),cpuset=/,mems_allowed=0,oom_memcg=/ile0,task_memcg=/ile0,task=syz-executor3,pid=23766,uid=0
: [  366.449416] memory: usage 112kB, limit 0kB, failcnt 1605

Are you sure you want to have hard limit set to 0?

: [  366.454963] memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
: [  366.461787] kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
: [  366.467946] Memory cgroup stats for /ile0: cache:12KB rss:0KB rss_huge:0KB shmem:0KB mapped_file:0KB dirty:0KB writeback:0KB swap:0KB inactive_anon:0KB active_anon:0KB inactive_file:0KB active_file:0KB unevictable:0KB

There are only 3 pages charged to this memcg!

: [  366.487490] Tasks state (memory values in pages):
: [  366.492349] [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
: [  366.501237] [  23766]     0 23766    17620     8221   126976        0             0 syz-executor3
: [  366.510367] [  23767]     0 23767    17618     8218   126976        0             0 syz-executor2
: [  366.519409] Memory cgroup out of memory: Kill process 23766 (syz-executor3) score 8252000 or sacrifice child
: [  366.529422] Killed process 23766 (syz-executor3) total-vm:70480kB, anon-rss:116kB, file-rss:32768kB, shmem-rss:0kB
: [  366.540456] oom_reaper: reaped process 23766 (syz-executor3), now anon-rss:0kB, file-rss:32000kB, shmem-rss:0kB

The oom reaper cannot reclaim file backed memory  from a large part. I
assume this is are shared mappings which are living outside of memcg
because of the counter.

: [...]
: [  367.085870] oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),cpuset=/,mems_allowed=0,oom_memcg=/ile0,task_memcg=/ile0,task=syz-executor2,pid=23767,uid=0
: [  367.100073] memory: usage 112kB, limit 0kB, failcnt 1615
: [  367.105549] memory+swap: usage 0kB, limit 9007199254740988kB, failcnt 0
: [  367.112428] kmem: usage 0kB, limit 9007199254740988kB, failcnt 0
: [  367.118593] Memory cgroup stats for /ile0: cache:12KB rss:0KB rss_huge:0KB shmem:0KB mapped_file:0KB dirty:0KB writeback:0KB swap:0KB inactive_anon:0KB active_anon:0KB inactive_file:0KB active_file:0KB unevictable:0KB
: [  367.138136] Tasks state (memory values in pages):
: [  367.142986] [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
: [  367.151889] [  23766]     0 23766    17620     8002   126976        0             0 syz-executor3
: [  367.160946] [  23767]     0 23767    17618     8218   126976        0             0 syz-executor2
: [  367.169994] Memory cgroup out of memory: Kill process 23767 (syz-executor2) score 8249000 or sacrifice child
: [  367.180119] Killed process 23767 (syz-executor2) total-vm:70472kB, anon-rss:104kB, file-rss:32768kB, shmem-rss:0kB
: [  367.192101] oom_reaper: reaped process 23767 (syz-executor2), now anon-rss:0kB, file-rss:32000kB, shmem-rss:0kB 
: [  367.202986] ------------[ cut here ]------------
: [  367.207845] Memory cgroup charge failed because of no reclaimable memory! This looks like a misconfiguration or a kernel bug.
: [  367.207965] WARNING: CPU: 1 PID: 23767 at mm/memcontrol.c:1710 try_charge+0x734/0x1680
: [  367.227540] Kernel panic - not syncing: panic_on_warn set ...

This is unexpected though. We have killed a task (23767) which is trying
to charge the memory which means it should
trigger the charge retry and that one should force the charge

	/*
	 * Unlike in global OOM situations, memcg is not in a physical
	 * memory shortage.  Allow dying and OOM-killed tasks to
	 * bypass the last charges so that they can exit quickly and
	 * free their memory.
	 */
	if (unlikely(tsk_is_oom_victim(current) ||
		     fatal_signal_pending(current) ||
		     current->flags & PF_EXITING))
		goto force;

There doesn't seem to be any other sign of OOM killer invocation which
could then indeed lead to the warning as there is no other task to kill
(both syz-executor[23] have been killed and oom_reaped already). So I
would be curious what happened between 367.180119 which was the last
successful oom invocation and 367.207845. An additional printk in
mem_cgroup_out_of_memory might tell us more.

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4603ad75c9a9..852cd3dbdcd9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1388,6 +1388,8 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	bool ret;
 
 	mutex_lock(&oom_lock);
+	pr_info("task=%s pid=%d invoked memcg oom killer. oom_victim=%d\n",
+			current->comm, current->pid, tsk_is_oom_victim(current));
 	ret = out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
 	return ret;

Anyway your memcg setup is indeed misconfigured. Memcg with 0 hard limit
and basically no memory charged by existing tasks is not going to fly
and the warning is exactly to call that out.

If this is some sort of race and we warn too eagerly is still to be
checked and potentially fixed of course.
-- 
Michal Hocko
SUSE Labs
