Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5496C6B0649
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 20:39:36 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y190so66886114pgb.3
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 17:39:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e70si4571666pgc.620.2017.08.02.17.39.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 17:39:34 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm, oom: task_will_free_mem(current) should ignore MMF_OOM_SKIP for once.
Date: Thu,  3 Aug 2017 08:55:04 +0900
Message-Id: <1501718104-8099-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Manish Jaggi <mjaggi@caviumnetworks.com>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@virtuozzo.com>

Manish Jaggi noticed that running LTP oom01/oom02 ltp tests with high core
count causes random kernel panics when an OOM victim which consumed memory
in a way the OOM reaper does not help was selected by the OOM killer.

----------
oom02       0  TINFO  :  start OOM testing for mlocked pages.
oom02       0  TINFO  :  expected victim is 4578.
oom02       0  TINFO  :  thread (ffff8b0e71f0), allocating 3221225472 bytes.
oom02       0  TINFO  :  thread (ffff8b8e71f0), allocating 3221225472 bytes.
(...snipped...)
oom02       0  TINFO  :  thread (ffff8a0e71f0), allocating 3221225472 bytes.
[  364.737486] oom02:4583 invoked oom-killer: gfp_mask=0x16080c0(GFP_KERNEL|__GFP_ZERO|__GFP_NOTRACK), nodemask=1,  order=0, oom_score_adj=0
(...snipped...)
[  365.036127] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[  365.044691] [ 1905]     0  1905     3236     1714      10       4        0             0 systemd-journal
[  365.054172] [ 1908]     0  1908    20247      590       8       4        0             0 lvmetad
[  365.062959] [ 2421]     0  2421     3241      878       9       3        0         -1000 systemd-udevd
[  365.072266] [ 3125]     0  3125     3834      719       9       4        0         -1000 auditd
[  365.080963] [ 3145]     0  3145     1086      630       6       4        0             0 systemd-logind
[  365.090353] [ 3146]     0  3146     1208      596       7       3        0             0 irqbalance
[  365.099413] [ 3147]    81  3147     1118      625       5       4        0          -900 dbus-daemon
[  365.108548] [ 3149]   998  3149   116294     4180      26       5        0             0 polkitd
[  365.117333] [ 3164]   997  3164    19992      785       9       3        0             0 chronyd
[  365.126118] [ 3180]     0  3180    55605     7880      29       3        0             0 firewalld
[  365.135075] [ 3187]     0  3187    87842     3033      26       3        0             0 NetworkManager
[  365.144465] [ 3290]     0  3290    43037     1224      16       5        0             0 rsyslogd
[  365.153335] [ 3295]     0  3295   108279     6617      30       3        0             0 tuned
[  365.161944] [ 3308]     0  3308    27846      676      11       3        0             0 crond
[  365.170554] [ 3309]     0  3309     3332      616      10       3        0         -1000 sshd
[  365.179076] [ 3371]     0  3371    27307      364       6       3        0             0 agetty
[  365.187790] [ 3375]     0  3375    29397     1125      11       3        0             0 login
[  365.196402] [ 4178]     0  4178     4797     1119      14       4        0             0 master
[  365.205101] [ 4209]    89  4209     4823     1396      12       4        0             0 pickup
[  365.213798] [ 4211]    89  4211     4842     1485      12       3        0             0 qmgr
[  365.222325] [ 4491]     0  4491    27965     1022       8       3        0             0 bash
[  365.230849] [ 4513]     0  4513      670      365       5       3        0             0 oom02
[  365.239459] [ 4578]     0  4578 37776030 32890957   64257     138        0             0 oom02
[  365.248067] Out of memory: Kill process 4578 (oom02) score 952 or sacrifice child
[  365.255581] Killed process 4578 (oom02) total-vm:151104120kB, anon-rss:131562528kB, file-rss:1300kB, shmem-rss:0kB
[  365.266829] out_of_memory: Current (4583) has a pending SIGKILL
[  365.267347] oom_reaper: reaped process 4578 (oom02), now anon-rss:131559616kB, file-rss:0kB, shmem-rss:0kB
[  365.282658] oom_reaper: reaped process 4583 (oom02), now anon-rss:131561664kB, file-rss:0kB, shmem-rss:0kB
[  365.283361] oom02:4586 invoked oom-killer: gfp_mask=0x16040c0(GFP_KERNEL|__GFP_COMP|__GFP_NOTRACK), nodemask=1,  order=0, oom_score_adj=0
(...snipped...)
[  365.576164] oom02:4585 invoked oom-killer: gfp_mask=0x16080c0(GFP_KERNEL|__GFP_ZERO|__GFP_NOTRACK), nodemask=1,  order=0, oom_score_adj=0
(...snipped...)
[  365.576298] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[  365.576338] [ 2421]     0  2421     3241      878       9       3        0         -1000 systemd-udevd
[  365.576342] [ 3125]     0  3125     3834      719       9       4        0         -1000 auditd
[  365.576347] [ 3309]     0  3309     3332      616      10       3        0         -1000 sshd
[  365.576356] [ 4580]     0  4578 37776030 32890417   64258     138        0             0 oom02
[  365.576361] Kernel panic - not syncing: Out of memory and no killable processes...
----------

Since commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
oom_reaped tasks") changed task_will_free_mem(current) in out_of_memory()
to return false as soon as MMF_OOM_SKIP is set, many threads sharing
the victim's mm were not able to try allocation from memory reserves
after the OOM reaper gave up reclaiming memory.

We don't need to give up task_will_free_mem(current) without trying
allocation from memory reserves. We will need to select next OOM victim
only when allocation from memory reserves did not help.

Thus, this patch allows task_will_free_mem(current) to ignore MMF_OOM_SKIP
for once so that task_will_free_mem(current) will not start selecting next
OOM victim without trying allocation from memory reserves.

Link: http://lkml.kernel.org/r/e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com
Reported-by: Manish Jaggi <mjaggi@caviumnetworks.com>
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: David Rientjes <rientjes@google.com>
Fixes: 696453e66630ad45 ("mm, oom: task_will_free_mem should skip oom_reaped tasks")
---
 include/linux/sched.h |  1 +
 mm/oom_kill.c         | 14 +++++++++++---
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 94137e7..88da211 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -652,6 +652,7 @@ struct task_struct {
 	/* disallow userland-initiated cgroup migration */
 	unsigned			no_cgroup_migration:1;
 #endif
+	unsigned			oom_kill_free_check_raced:1;
 
 	unsigned long			atomic_flags; /* Flags requiring atomic access. */
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9e8b4f0..a1ae78d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -780,11 +780,19 @@ static bool task_will_free_mem(struct task_struct *task)
 		return false;
 
 	/*
-	 * This task has already been drained by the oom reaper so there are
-	 * only small chances it will free some more
+	 * It is possible that current thread fails to try allocation from
+	 * memory reserves if the OOM reaper set MMF_OOM_SKIP on this mm before
+	 * current thread calls out_of_memory() in order to get TIF_MEMDIE.
+	 * In that case, allow current thread to try TIF_MEMDIE allocation
+	 * before start selecting next OOM victims.
 	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags))
+	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
+		if (task == current && !task->oom_kill_free_check_raced) {
+			task->oom_kill_free_check_raced = true;
+			return true;
+		}
 		return false;
+	}
 
 	if (atomic_read(&mm->mm_users) <= 1)
 		return true;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
