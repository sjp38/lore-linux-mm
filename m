Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 785BF6B0253
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 06:56:09 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id 63so11476147pfe.3
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 03:56:09 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r3si4366671pfr.120.2016.03.08.03.56.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Mar 2016 03:56:08 -0800 (PST)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] android,lowmemorykiller: Don't abuse TIF_MEMDIE.
Date: Tue,  8 Mar 2016 20:01:32 +0900
Message-Id: <1457434892-12642-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@driverdev.osuosl.org, linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.cz>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arve Hjonnevag <arve@android.com>, Riley Andrews <riandrews@android.com>

Currently, lowmemorykiller (LMK) is using TIF_MEMDIE for two purposes.
One is to remember processes killed by LMK, and the other is to
accelerate termination of processes killed by LMK.

But since LMK is invoked as a memory shrinker function, there still
should be some memory available. It is very likely that memory
allocations by processes killed by LMK will succeed without using
ALLOC_NO_WATERMARKS via TIF_MEMDIE. Even if their allocations cannot
escape from memory allocation loop unless they use ALLOC_NO_WATERMARKS,
lowmem_deathpending_timeout can guarantee forward progress by choosing
next victim process.

On the other hand, mark_oom_victim() assumes that it must be called with
oom_lock held and it must not be called after oom_killer_disable() was
called. But LMK is calling it without holding oom_lock and checking
oom_killer_disabled. It is possible that LMK calls mark_oom_victim()
due to allocation requests by kernel threads after current thread
returned from oom_killer_disabled(). This will break synchronization
for PM/suspend.

This patch introduces per a task_struct flag for remembering processes
killed by LMK, and replaces TIF_MEMDIE with that flag. By applying this
patch, assumption by mark_oom_victim() becomes true.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arve Hjonnevag <arve@android.com>
Cc: Riley Andrews <riandrews@android.com>
---
 drivers/staging/android/lowmemorykiller.c | 9 ++-------
 include/linux/sched.h                     | 4 ++++
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
index 4b8a56c..a1dd798 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -129,7 +129,7 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
 		if (!p)
 			continue;
 
-		if (test_tsk_thread_flag(p, TIF_MEMDIE) &&
+		if (task_lmk_waiting(p) && p->mm &&
 		    time_before_eq(jiffies, lowmem_deathpending_timeout)) {
 			task_unlock(p);
 			rcu_read_unlock();
@@ -160,13 +160,8 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
 	if (selected) {
 		task_lock(selected);
 		send_sig(SIGKILL, selected, 0);
-		/*
-		 * FIXME: lowmemorykiller shouldn't abuse global OOM killer
-		 * infrastructure. There is no real reason why the selected
-		 * task should have access to the memory reserves.
-		 */
 		if (selected->mm)
-			mark_oom_victim(selected);
+			task_set_lmk_waiting(selected);
 		task_unlock(selected);
 		lowmem_print(1, "Killing '%s' (%d), adj %hd,\n"
 				 "   to free %ldkB on behalf of '%s' (%d) because\n"
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 0b44fbc..de9ced9 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2187,6 +2187,7 @@ static inline void memalloc_noio_restore(unsigned int flags)
 #define PFA_NO_NEW_PRIVS 0	/* May not gain new privileges. */
 #define PFA_SPREAD_PAGE  1      /* Spread page cache over cpuset */
 #define PFA_SPREAD_SLAB  2      /* Spread some slab caches over cpuset */
+#define PFA_LMK_WAITING  3      /* Lowmemorykiller is waiting */
 
 
 #define TASK_PFA_TEST(name, func)					\
@@ -2210,6 +2211,9 @@ TASK_PFA_TEST(SPREAD_SLAB, spread_slab)
 TASK_PFA_SET(SPREAD_SLAB, spread_slab)
 TASK_PFA_CLEAR(SPREAD_SLAB, spread_slab)
 
+TASK_PFA_TEST(LMK_WAITING, lmk_waiting)
+TASK_PFA_SET(LMK_WAITING, lmk_waiting)
+
 /*
  * task->jobctl flags
  */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
