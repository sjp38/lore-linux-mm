Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id EEAD16B007E
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 07:38:51 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id 4so130865870pfd.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 04:38:51 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id e5si7719709pat.66.2016.03.21.04.38.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Mar 2016 04:38:50 -0700 (PDT)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] signal: Make oom_flags a bool
Date: Mon, 21 Mar 2016 20:38:13 +0900
Message-Id: <1458560293-24074-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Currently the size of "struct signal_struct"->oom_flags member is
sizeof(unsigned) bytes, but only one flag OOM_FLAG_ORIGIN which is
updated by current thread is defined. We can convert OOM_FLAG_ORIGIN
into a bool, and reuse the saved bytes for updating from the OOM killer
and/or the OOM reaper thread.

By the way, do we care about a race window between run_store() and
swapoff() because it would be theoretically possible that two threads
sharing the "struct signal_struct" concurrently call respective
functions? If we care, we can make oom_flags an atomic_t.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/oom.h   | 9 +++------
 include/linux/sched.h | 6 +++++-
 include/linux/types.h | 1 -
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index dad467a..96da253 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -50,24 +50,21 @@ enum oom_scan_t {
 	OOM_SCAN_SELECT,	/* always select this thread first */
 };
 
-/* Thread is the potential origin of an oom condition; kill first on oom */
-#define OOM_FLAG_ORIGIN		((__force oom_flags_t)0x1)
-
 extern struct mutex oom_lock;
 
 static inline void set_current_oom_origin(void)
 {
-	current->signal->oom_flags |= OOM_FLAG_ORIGIN;
+	current->signal->oom_flag_origin = true;
 }
 
 static inline void clear_current_oom_origin(void)
 {
-	current->signal->oom_flags &= ~OOM_FLAG_ORIGIN;
+	current->signal->oom_flag_origin = false;
 }
 
 static inline bool oom_task_origin(const struct task_struct *p)
 {
-	return !!(p->signal->oom_flags & OOM_FLAG_ORIGIN);
+	return p->signal->oom_flag_origin;
 }
 
 extern void mark_oom_victim(struct task_struct *tsk);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 888bc15..83bd309b 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -784,7 +784,11 @@ struct signal_struct {
 	struct tty_audit_buf *tty_audit_buf;
 #endif
 
-	oom_flags_t oom_flags;
+	/*
+	 * Thread is the potential origin of an oom condition; kill first on
+	 * oom
+	 */
+	bool oom_flag_origin;
 	short oom_score_adj;		/* OOM kill score adjustment */
 	short oom_score_adj_min;	/* OOM kill score adjustment min value.
 					 * Only settable by CAP_SYS_RESOURCE. */
diff --git a/include/linux/types.h b/include/linux/types.h
index 70dd3df..baf7183 100644
--- a/include/linux/types.h
+++ b/include/linux/types.h
@@ -156,7 +156,6 @@ typedef u32 dma_addr_t;
 
 typedef unsigned __bitwise__ gfp_t;
 typedef unsigned __bitwise__ fmode_t;
-typedef unsigned __bitwise__ oom_flags_t;
 
 #ifdef CONFIG_PHYS_ADDR_T_64BIT
 typedef u64 phys_addr_t;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
