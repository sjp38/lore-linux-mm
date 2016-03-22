Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7E67F6B0263
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 07:01:15 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id l68so157763719wml.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 04:01:15 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id jy5si10495149wjc.55.2016.03.22.04.01.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 04:01:09 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id p65so29046584wmp.1
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 04:01:09 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 7/9] oom: make oom_reaper_list single linked
Date: Tue, 22 Mar 2016 12:00:24 +0100
Message-Id: <1458644426-22973-8-git-send-email-mhocko@kernel.org>
In-Reply-To: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>

From: Vladimir Davydov <vdavydov@virtuozzo.com>

Entries are only added/removed from oom_reaper_list at head so we can use
a single linked list and hence save a word in task_struct.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/sched.h |  2 +-
 mm/oom_kill.c         | 15 +++++++--------
 2 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index acb480b581e3..d118445a332e 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1841,7 +1841,7 @@ struct task_struct {
 #endif
 	int pagefault_disabled;
 #ifdef CONFIG_MMU
-	struct list_head oom_reaper_list;
+	struct task_struct *oom_reaper_list;
 #endif
 /* CPU-specific state of this task */
 	struct thread_struct thread;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b38a648558f9..af75260f32c3 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -417,7 +417,7 @@ bool oom_killer_disabled __read_mostly;
  */
 static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static LIST_HEAD(oom_reaper_list);
+static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
 
@@ -527,13 +527,11 @@ static int oom_reaper(void *unused)
 	while (true) {
 		struct task_struct *tsk = NULL;
 
-		wait_event_freezable(oom_reaper_wait,
-				     (!list_empty(&oom_reaper_list)));
+		wait_event_freezable(oom_reaper_wait, oom_reaper_list != NULL);
 		spin_lock(&oom_reaper_lock);
-		if (!list_empty(&oom_reaper_list)) {
-			tsk = list_first_entry(&oom_reaper_list,
-					struct task_struct, oom_reaper_list);
-			list_del(&tsk->oom_reaper_list);
+		if (oom_reaper_list != NULL) {
+			tsk = oom_reaper_list;
+			oom_reaper_list = tsk->oom_reaper_list;
 		}
 		spin_unlock(&oom_reaper_lock);
 
@@ -552,7 +550,8 @@ static void wake_oom_reaper(struct task_struct *tsk)
 	get_task_struct(tsk);
 
 	spin_lock(&oom_reaper_lock);
-	list_add(&tsk->oom_reaper_list, &oom_reaper_list);
+	tsk->oom_reaper_list = oom_reaper_list;
+	oom_reaper_list = tsk;
 	spin_unlock(&oom_reaper_lock);
 	wake_up(&oom_reaper_wait);
 }
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
