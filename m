Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B5E576B026A
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 10:26:21 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id t23-v6so1694507ioa.9
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 07:26:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id j10-v6si840466ioa.125.2018.07.03.07.26.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 07:26:20 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH 7/8] mm,oom: Do not sleep with oom_lock held.
Date: Tue,  3 Jul 2018 23:25:08 +0900
Message-Id: <1530627910-3415-8-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
In-Reply-To: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

Since oom_reap_mm() might take quite long time, it is not a good thing to
block other threads in different OOM domains. This patch allows calling
oom_reap_mm() from multiple concurrently allocating threads. By this
change, the page allocator can spend CPU resource for oom_reap_mm() in
their interested OOM domains.

Also, out_of_memory() no longer holds oom_lock which might sleep (except
cond_resched() and CONFIG_PREEMPT=y cases), for both OOM notifiers and
oom_reap_mm() are called outside of oom_lock. This means that oom_lock is
almost a spinlock now. But this patch does not convert oom_lock, for
saving CPU resources for selecting OOM victims, printk() etc. is a still
good thing to do.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Fixes: CVE-2016-10723
Cc: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>
---
 mm/oom_kill.c | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index a1d3616..d534684 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -921,11 +921,18 @@ static bool oom_has_pending_victims(struct oom_control *oc)
 	struct task_struct *p, *tmp;
 	bool ret = false;
 	bool gaveup = false;
+	unsigned int pos = 0;
+	unsigned int last_pos = 0;
 
+ retry:
 	lockdep_assert_held(&oom_lock);
 	list_for_each_entry_safe(p, tmp, &oom_victim_list, oom_victim_list) {
 		struct mm_struct *mm = p->signal->oom_mm;
 
+		if (pos++ < last_pos)
+			continue;
+		last_pos = pos;
+
 		/* Skip OOM victims which current thread cannot select. */
 		if (oom_unkillable_task(p, oc->memcg, oc->nodemask))
 			continue;
@@ -937,8 +944,23 @@ static bool oom_has_pending_victims(struct oom_control *oc)
 		 */
 		if (down_read_trylock(&mm->mmap_sem)) {
 			if (!test_bit(MMF_OOM_SKIP, &mm->flags) &&
-			    !mm_has_blockable_invalidate_notifiers(mm))
+			    !mm_has_blockable_invalidate_notifiers(mm)) {
+				get_task_struct(p);
+				mmgrab(mm);
+				mutex_unlock(&oom_lock);
 				oom_reap_mm(mm);
+				up_read(&mm->mmap_sem);
+				mmdrop(mm);
+				put_task_struct(p);
+				mutex_lock(&oom_lock);
+				/*
+				 * Since ret == true, skipping some OOM victims
+				 * by racing with exit_oom_mm() will not cause
+				 * premature OOM victim selection.
+				 */
+				pos = 0;
+				goto retry;
+			}
 			up_read(&mm->mmap_sem);
 		}
 #endif
-- 
1.8.3.1
