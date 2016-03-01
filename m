Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id A2B296B0254
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 04:28:30 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fy10so108820504pac.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 01:28:30 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id t63si49266489pfa.240.2016.03.01.01.28.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 01:28:29 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH -mm] oom: make oom_reaper_list single linked
Date: Tue, 1 Mar 2016 12:28:20 +0300
Message-ID: <1456824500-30661-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Entries are only added/removed from oom_reaper_list at head so we can
use a single linked list and hence save a word in task_struct.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/sched.h |  2 +-
 mm/oom_kill.c         | 15 +++++++--------
 2 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 2118e963fba7..7b76e65595c3 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1853,7 +1853,7 @@ struct task_struct {
 #endif
 	int pagefault_disabled;
 #ifdef CONFIG_MMU
-	struct list_head oom_reaper_list;
+	struct task_struct *oom_reaper_list;
 #endif
 /* CPU-specific state of this task */
 	struct thread_struct thread;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5d5eca9d6737..1a91d9a26bc9 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -423,7 +423,7 @@ bool oom_killer_disabled __read_mostly;
  */
 static struct task_struct *oom_reaper_th;
 static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
-static LIST_HEAD(oom_reaper_list);
+static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
 
@@ -530,13 +530,11 @@ static int oom_reaper(void *unused)
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
 
@@ -555,7 +553,8 @@ static void wake_oom_reaper(struct task_struct *tsk)
 	get_task_struct(tsk);
 
 	spin_lock(&oom_reaper_lock);
-	list_add(&tsk->oom_reaper_list, &oom_reaper_list);
+	tsk->oom_reaper_list = oom_reaper_list;
+	oom_reaper_list = tsk;
 	spin_unlock(&oom_reaper_lock);
 	wake_up(&oom_reaper_wait);
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
