Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 279F26B007E
	for <linux-mm@kvack.org>; Sat,  4 Jun 2016 03:20:14 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id lp2so32353008igb.3
        for <linux-mm@kvack.org>; Sat, 04 Jun 2016 00:20:14 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id n206si4456591oif.136.2016.06.04.00.20.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 04 Jun 2016 00:20:13 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] oom_reaper: avoid pointless atomic_inc_not_zero usage.
Date: Sat,  4 Jun 2016 16:19:19 +0900
Message-Id: <1465024759-8074-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>, Arnd Bergmann <arnd@arndb.de>

Since commit 36324a990cf578b5 ("oom: clear TIF_MEMDIE after oom_reaper
managed to unmap the address space") changed to use find_lock_task_mm()
for finding a mm_struct to reap, it is guaranteed that mm->mm_users > 0
because find_lock_task_mm() returns a task_struct with ->mm != NULL.
Therefore, we can safely use atomic_inc().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/oom_kill.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dfb1ab6..8050fa0 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -474,13 +474,8 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	p = find_lock_task_mm(tsk);
 	if (!p)
 		goto unlock_oom;
-
 	mm = p->mm;
-	if (!atomic_inc_not_zero(&mm->mm_users)) {
-		task_unlock(p);
-		goto unlock_oom;
-	}
-
+	atomic_inc(&mm->mm_users);
 	task_unlock(p);
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
