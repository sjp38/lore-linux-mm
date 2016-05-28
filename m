Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id B36716B007E
	for <linux-mm@kvack.org>; Sat, 28 May 2016 04:55:09 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id fs8so197605676obb.2
        for <linux-mm@kvack.org>; Sat, 28 May 2016 01:55:09 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s51si16437213otb.144.2016.05.28.01.55.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 28 May 2016 01:55:08 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] mm,oom_reaper: don't call mmput_async() without atomic_inc_not_zero()
Date: Sat, 28 May 2016 17:16:05 +0900
Message-Id: <1464423365-5555-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>, Arnd Bergmann <arnd@arndb.de>

Commit e2fe14564d3316d1 ("oom_reaper: close race with exiting task")
reduced frequency of needlessly selecting next OOM victim, but was
calling mmput_async() when atomic_inc_not_zero() failed.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 mm/oom_kill.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index dfb1ab6..0d781b8 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -478,6 +478,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	mm = p->mm;
 	if (!atomic_inc_not_zero(&mm->mm_users)) {
 		task_unlock(p);
+		mm = NULL;
 		goto unlock_oom;
 	}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
