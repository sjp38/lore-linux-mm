Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 844BA6B003B
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 09:17:33 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id s7so151084lbd.2
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 06:17:32 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ax9si48826325lbc.59.2014.07.03.06.17.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 06:17:32 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH TRIVIAL -mm] fork: make mm_init_owner static
Date: Thu, 3 Jul 2014 17:17:23 +0400
Message-ID: <1404393443-14453-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

It's only used in fork.c:mm_init().

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/sched.h |    5 -----
 kernel/fork.c         |   14 +++++++-------
 2 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 322d4fc8976c..c1d6d46ce941 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2959,15 +2959,10 @@ static inline void inc_syscw(struct task_struct *tsk)
 
 #ifdef CONFIG_MEMCG
 extern void mm_update_next_owner(struct mm_struct *mm);
-extern void mm_init_owner(struct mm_struct *mm, struct task_struct *p);
 #else
 static inline void mm_update_next_owner(struct mm_struct *mm)
 {
 }
-
-static inline void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
-{
-}
 #endif /* CONFIG_MEMCG */
 
 static inline unsigned long task_rlimit(const struct task_struct *tsk,
diff --git a/kernel/fork.c b/kernel/fork.c
index c3117443f42e..371cb7cc4f80 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -526,6 +526,13 @@ static void mm_init_aio(struct mm_struct *mm)
 #endif
 }
 
+static void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
+{
+#ifdef CONFIG_MEMCG
+	mm->owner = p;
+#endif
+}
+
 static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 {
 	mm->mmap = NULL;
@@ -1098,13 +1105,6 @@ static void rt_mutex_init_task(struct task_struct *p)
 #endif
 }
 
-#ifdef CONFIG_MEMCG
-void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
-{
-	mm->owner = p;
-}
-#endif /* CONFIG_MEMCG */
-
 /*
  * Initialize POSIX timer handling for a single task.
  */
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
