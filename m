Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 543C06B0007
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 03:13:15 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d10-v6so959838pll.22
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 00:13:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x36-v6sor932674pgl.294.2018.08.08.00.13.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Aug 2018 00:13:14 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/2] memcg, oom: be careful about races when warning about no reclaimable task
Date: Wed,  8 Aug 2018 09:13:00 +0200
Message-Id: <20180808071301.12478-2-mhocko@kernel.org>
In-Reply-To: <20180808071301.12478-1-mhocko@kernel.org>
References: <20180808064414.GA27972@dhcp22.suse.cz>
 <20180808071301.12478-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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
 mm/memcontrol.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4603ad75c9a9..c80e5b6a8e9f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1705,6 +1705,15 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
 
 	if (mem_cgroup_out_of_memory(memcg, mask, order))
 		return OOM_SUCCESS;
+	
+	/*
+	 * under rare race the current task might have been selected while
+	 * reaching mem_cgroup_out_of_memory and there is no other oom victim
+	 * left. There is still no reason to warn because this task will
+	 * die and release its bypassed charge eventually.
+	 */
+	if (tsk_is_oom_victim(current))
+		return OOM_SUCCESS;
 
 	WARN(1,"Memory cgroup charge failed because of no reclaimable memory! "
 		"This looks like a misconfiguration or a kernel bug.");
-- 
2.18.0
