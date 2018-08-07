Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 239486B0008
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 03:26:01 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id t17-v6so5051654edr.21
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 00:26:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h4-v6sor313092edq.9.2018.08.07.00.25.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 00:25:59 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] memcg, oom: be careful about races when warning about no reclaimable task
Date: Tue,  7 Aug 2018 09:25:53 +0200
Message-Id: <20180807072553.14941-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dmitry Vyukov <dvyukov@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

"memcg, oom: move out_of_memory back to the charge path" has added a
warning triggered when the oom killer cannot find any eligible task
and so there is no way to reclaim the oom memcg under its hard limit.
Further charges for such a memcg are forced and therefore the hard limit
isolation is weakened.

The current warning is however too eager to trigger  even when we are not
really hitting the above condition. Syzbot[1] and Greg Thelen have noticed
that we can hit this condition even when there is still oom victim
pending. E.g. the following race is possible:

memcg has two tasks taskA, taskB.

CPU1 (taskA)			CPU2			CPU3 (taskB)
try_charge
  mem_cgroup_out_of_memory				try_charge
      select_bad_process(taskB)
      oom_kill_process		oom_reap_task
				# No real memory reaped
    				  			  mem_cgroup_out_of_memory
				# set taskB -> MMF_OOM_SKIP
  # retry charge
  mem_cgroup_out_of_memory
    oom_lock						    oom_lock
    select_bad_process(self)
    oom_kill_process(self)
    oom_unlock
							    # no eligible task

In fact syzbot test triggered this situation by placing multiple tasks
into a memcg with hard limit set to 0. So no task really had any memory
charged to the memcg

: Memory cgroup stats for /ile0: cache:0KB rss:0KB rss_huge:0KB shmem:0KB mapped_file:0KB dirty:0KB writeback:0KB swap:0KB inactive_anon:0KB active_anon:0KB inactive_file:0KB active_file:0KB unevictable:0KB
: Tasks state (memory values in pages):
: [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
: [   6569]     0  6562     9427        1    53248        0             0 syz-executor0
: [   6576]     0  6576     9426        0    61440        0             0 syz-executor6
: [   6578]     0  6578     9426      534    61440        0             0 syz-executor4
: [   6579]     0  6579     9426        0    57344        0             0 syz-executor5
: [   6582]     0  6582     9426        0    61440        0             0 syz-executor7
: [   6584]     0  6584     9426        0    57344        0             0 syz-executor1

so in principle there is indeed nothing reclaimable in this memcg and
this looks like a misconfiguration. On the other hand we can clearly
kill all those tasks so it is a bit early to warn and scare users. Do
that by checking that the current is the oom victim and bypass the
warning then. The victim is allowed to force charge and terminate to
release its temporal charge along the way.

[1] http://lkml.kernel.org/r/0000000000005e979605729c1564@google.com
Fixes: "memcg, oom: move out_of_memory back to the charge path"
Noticed-by: Greg Thelen <gthelen@google.com>
Reported-and-tested-by: syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/memcontrol.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4603ad75c9a9..1b6eed1bc404 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1703,7 +1703,8 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
 		return OOM_ASYNC;
 	}
 
-	if (mem_cgroup_out_of_memory(memcg, mask, order))
+	if (mem_cgroup_out_of_memory(memcg, mask, order) ||
+			tsk_is_oom_victim(current))
 		return OOM_SUCCESS;
 
 	WARN(1,"Memory cgroup charge failed because of no reclaimable memory! "
-- 
2.18.0
