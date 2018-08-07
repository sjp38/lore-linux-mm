Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id DAD1B6B0006
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 06:15:31 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id p11-v6so14859617oih.17
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 03:15:31 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 186-v6si616391oie.236.2018.08.07.03.15.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 03:15:30 -0700 (PDT)
Subject: Re: [PATCH] memcg, oom: be careful about races when warning about no
 reclaimable task
References: <20180807072553.14941-1-mhocko@kernel.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <863d73ce-fae9-c117-e361-12c415c787de@i-love.sakura.ne.jp>
Date: Tue, 7 Aug 2018 19:15:11 +0900
MIME-Version: 1.0
In-Reply-To: <20180807072553.14941-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Dmitry Vyukov <dvyukov@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>

On 2018/08/07 16:25, Michal Hocko wrote:
> @@ -1703,7 +1703,8 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
>  		return OOM_ASYNC;
>  	}
>  
> -	if (mem_cgroup_out_of_memory(memcg, mask, order))
> +	if (mem_cgroup_out_of_memory(memcg, mask, order) ||
> +			tsk_is_oom_victim(current))
>  		return OOM_SUCCESS;
>  
>  	WARN(1,"Memory cgroup charge failed because of no reclaimable memory! "
> 

I don't think this patch is appropriate. This patch only avoids hitting WARN(1).
This patch does not address the root cause:

The task_will_free_mem(current) test in out_of_memory() is returning false
because test_bit(MMF_OOM_SKIP, &mm->flags) test in task_will_free_mem() is
returning false because MMF_OOM_SKIP was already set by the OOM reaper. The OOM
killer does not need to start selecting next OOM victim until "current thread
completes __mmput()" or "it fails to complete __mmput() within reasonable
period".

According to https://syzkaller.appspot.com/text?tag=CrashLog&x=15a1c770400000 ,
PID=23767 selected PID=23766 as an OOM victim and the OOM reaper set MMF_OOM_SKIP
before PID=23766 unnecessarily selects PID=23767 as next OOM victim.
At uptime = 366.550949, out_of_memory() should have returned true without selecting
next OOM victim because tsk_is_oom_victim(current) == true.

[  365.869417] syz-executor2 invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), order=0, oom_score_adj=0
[  365.878899] CPU: 0 PID: 23767 Comm: syz-executor2 Not tainted 4.18.0-rc6-next-20180725+ #18
(...snipped...)
[  366.487490] Tasks state (memory values in pages):
[  366.492349] [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
[  366.501237] [  23766]     0 23766    17620     8221   126976        0             0 syz-executor3
[  366.510367] [  23767]     0 23767    17618     8218   126976        0             0 syz-executor2
[  366.519409] Memory cgroup out of memory: Kill process 23766 (syz-executor3) score 8252000 or sacrifice child
[  366.529422] Killed process 23766 (syz-executor3) total-vm:70480kB, anon-rss:116kB, file-rss:32768kB, shmem-rss:0kB
[  366.540456] oom_reaper: reaped process 23766 (syz-executor3), now anon-rss:0kB, file-rss:32000kB, shmem-rss:0kB
[  366.550949] syz-executor3 invoked oom-killer: gfp_mask=0x6000c0(GFP_KERNEL), order=0, oom_score_adj=0
[  366.560374] CPU: 1 PID: 23766 Comm: syz-executor3 Not tainted 4.18.0-rc6-next-20180725+ #18
(...snipped...)
[  367.138136] Tasks state (memory values in pages):
[  367.142986] [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
[  367.151889] [  23766]     0 23766    17620     8002   126976        0             0 syz-executor3
[  367.160946] [  23767]     0 23767    17618     8218   126976        0             0 syz-executor2
[  367.169994] Memory cgroup out of memory: Kill process 23767 (syz-executor2) score 8249000 or sacrifice child
[  367.180119] Killed process 23767 (syz-executor2) total-vm:70472kB, anon-rss:104kB, file-rss:32768kB, shmem-rss:0kB
[  367.192101] oom_reaper: reaped process 23767 (syz-executor2), now anon-rss:0kB, file-rss:32000kB, shmem-rss:0kB
[  367.202986] ------------[ cut here ]------------
[  367.207845] Memory cgroup charge failed because of no reclaimable memory! This looks like a misconfiguration or a kernel bug.
[  367.207965] WARNING: CPU: 1 PID: 23767 at mm/memcontrol.c:1710 try_charge+0x734/0x1680
[  367.227540] Kernel panic - not syncing: panic_on_warn set ...

Of course, if the hard limit is 0, all processes will be killed after all. But
Michal is ignoring the fact that if the hard limit were not 0, there is a chance
of saving next process from needlessly killed if we waited until "mm of PID=23766
completed __mmput()" or "mm of PID=23766 failed to complete __mmput() within
reasonable period". 

We can make efforts not to return false at

	/*
	 * This task has already been drained by the oom reaper so there are
	 * only small chances it will free some more
	 */
	if (test_bit(MMF_OOM_SKIP, &mm->flags))
		return false;

(I admit that ignoring MMF_OOM_SKIP for once might not be sufficient for memcg
case), and we can use feedback based backoff like
"[PATCH 4/4] mm, oom: Fix unnecessary killing of additional processes." *UNTIL*
we come to the point where the OOM reaper can always reclaim all memory.
