Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB7106B0006
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 07:05:18 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v17so4414900pff.9
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 04:05:18 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k136si4276839pga.630.2018.03.22.04.05.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 04:05:17 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom: Disable preemption inside the OOM killer.
Date: Thu, 22 Mar 2018 20:04:12 +0900
Message-Id: <1521716652-4868-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

cond_resched() from printk() or CONFIG_PREEMPT=y can allow other
contending allocating paths to disturb the owner of oom_lock.
They can break

  /*
   * Acquire the oom lock.  If that fails, somebody else is
   * making progress for us.
   */

assumption in __alloc_pages_may_oom().

If we use mutex_lock_killable() instead of mutex_trylock(), we can
guarantee that noone forever continues wasting CPU resource and disturbs
the owner of oom_lock. But when I proposed such change at [1], Michal
responded that it is worse because it significantly delays the OOM reaper
 from reclaiming memory. [2] is an alternative which will not delay the
OOM reaper, but [2] was already rejected.

Therefore, I proposed further steps at [3] and [4]. But Michal still does
not like it because it does not address preemption problem. I don't
consider preemption as a problem because [1] will eventually stop
disturbing the owner of oom_lock by stop wasting CPU resource.

It will be nice if we can make the OOM context not preemptible. But it is
not easy because printk() can be very slow which might not fit for
disabling the preemption. Since the printk() is responsible for printing
dying messages, we need to be careful not to deprive printk() of CPU
resources. From that aspect, [3] is safer direction than making the OOM
context not preemptible. Of course, if we could get rid of direct reclaim,
we won't need [3] from the beginning, for [3] is the last defense against
forever disturbing the owner of oom_lock by wasting CPU resource for
direct reclaim without any progress.

Nonetheless, this patch disables preemption inside the OOM killer as much
as possible, for this is the direction Michal wants to go.

[1] http://lkml.kernel.org/r/201802202232.IEC26597.FOQtMFOFJHOSVL@I-love.SAKURA.ne.jp
[2] http://lkml.kernel.org/r/1481020439-5867-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
[3] http://lkml.kernel.org/r/201802241700.JJB51016.FQOLFJHFOOSVMt@I-love.SAKURA.ne.jp
[4] http://lkml.kernel.org/r/201803022010.BJE26043.LtSOOVFQOMJFHF@I-love.SAKURA.ne.jp

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
---
 mm/oom_kill.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dcdb642..614d1a2 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -1068,7 +1068,7 @@ int unregister_oom_notifier(struct notifier_block *nb)
  * OR try to be smart about which process to kill. Note that we
  * don't have to be perfect here, we just have to be good.
  */
-bool out_of_memory(struct oom_control *oc)
+static bool __out_of_memory(struct oom_control *oc)
 {
 	unsigned long freed = 0;
 	enum oom_constraint constraint = CONSTRAINT_NONE;
@@ -1077,7 +1077,9 @@ bool out_of_memory(struct oom_control *oc)
 		return false;
 
 	if (!is_memcg_oom(oc)) {
+		preempt_enable();
 		blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
+		preempt_disable();
 		if (freed > 0)
 			/* Got some memory back in the last second. */
 			return true;
@@ -1138,6 +1140,16 @@ bool out_of_memory(struct oom_control *oc)
 	return !!oc->chosen_task;
 }
 
+bool out_of_memory(struct oom_control *oc)
+{
+	bool ret;
+
+	preempt_disable();
+	ret = __out_of_memory(oc);
+	preempt_enable();
+	return ret;
+}
+
 /*
  * The pagefault handler calls here because it is out of memory, so kill a
  * memory-hogging task. If oom_lock is held by somebody else, a parallel oom
-- 
1.8.3.1
