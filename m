Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F47C828E1
	for <linux-mm@kvack.org>; Thu, 26 May 2016 08:40:33 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e3so35647304wme.3
        for <linux-mm@kvack.org>; Thu, 26 May 2016 05:40:33 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id f143si4471275wme.52.2016.05.26.05.40.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 05:40:27 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id a136so5050445wme.0
        for <linux-mm@kvack.org>; Thu, 26 May 2016 05:40:27 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 4/6] mm, oom: skip over vforked tasks
Date: Thu, 26 May 2016 14:40:13 +0200
Message-Id: <1464266415-15558-5-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

vforked tasks are not really sitting on memory so it doesn't matter much
to kill them. Parents are waiting for vforked task killable so it is
better to chose parent which is the real mm owner. Teach oom_badness
to ignore all tasks which haven't passed mm_release. oom_kill_process
should ignore them as well because they will drop the mm soon and they
will not block oom_reaper because they cannot touch any memory.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index eeccb4d7e7f5..d1cbaaa1a666 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -176,11 +176,13 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 
 	/*
 	 * Do not even consider tasks which are explicitly marked oom
-	 * unkillable or have been already oom reaped.
+	 * unkillable or have been already oom reaped or they are in
+	 * the middle of vfork
 	 */
 	adj = (long)p->signal->oom_score_adj;
 	if (adj == OOM_SCORE_ADJ_MIN ||
-			test_bit(MMF_OOM_REAPED, &p->mm->flags)) {
+			test_bit(MMF_OOM_REAPED, &p->mm->flags) ||
+			p->vfork_done) {
 		task_unlock(p);
 		return 0;
 	}
@@ -839,6 +841,13 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	for_each_process(p) {
 		if (!process_shares_mm(p, mm))
 			continue;
+		/*
+		 * vforked tasks are ignored because they will drop the mm soon
+		 * hopefully and even if not they will not mind being oom
+		 * reaped because they cannot touch any memory.
+		 */
+		if (p->vfork_done)
+			continue;
 		if (same_thread_group(p, victim))
 			continue;
 		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
