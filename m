Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9EFD66B0261
	for <linux-mm@kvack.org>; Mon, 30 May 2016 09:06:14 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id h68so50439551lfh.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 06:06:14 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id el5si44405119wjd.31.2016.05.30.06.06.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 06:06:08 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id a136so22622841wme.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 06:06:08 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 4/6] mm, oom: skip vforked tasks from being selected
Date: Mon, 30 May 2016 15:05:54 +0200
Message-Id: <1464613556-16708-5-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

vforked tasks are not really sitting on any memory. They are sharing
the mm with parent until they exec into a new code. Until then it is
just pinning the address space. OOM killer will kill the vforked task
along with its parent but we still can end up selecting vforked task
when the parent wouldn't be selected. E.g. init doing vfork to launch
a task or vforked being a child of oom unkillable task with an updated
oom_score_adj to be killable.

Make sure to not select vforked task as an oom victim by checking
vfork_done in oom_badness.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 6bb322577fc6..92bc8c3ec97b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -176,11 +176,13 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 
 	/*
 	 * Do not even consider tasks which are explicitly marked oom
-	 * unkillable or have been already oom reaped.
+	 * unkillable or have been already oom reaped or the are in
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
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
