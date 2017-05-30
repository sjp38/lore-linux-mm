Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B19136B02F4
	for <linux-mm@kvack.org>; Tue, 30 May 2017 08:06:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e7so92474962pfk.9
        for <linux-mm@kvack.org>; Tue, 30 May 2017 05:06:24 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u17si44509740plj.231.2017.05.30.05.06.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 05:06:23 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH] mm,oom: add tracepoints for oom reaper-related events
Date: Tue, 30 May 2017 13:05:32 +0100
Message-ID: <1496145932-18636-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Roman Gushchin <guro@fb.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Add tracepoints to simplify the debugging of the oom reaper code.

Trace the following events:
1) a process is marked as an oom victim,
2) a process is added to the oom reaper list,
3) the oom reaper starts reaping process's mm,
4) the oom reaper finished reaping,
5) the oom reaper skips reaping.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: kernel-team@fb.com
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
 include/trace/events/oom.h | 80 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/oom_kill.c              |  7 ++++
 2 files changed, 87 insertions(+)

diff --git a/include/trace/events/oom.h b/include/trace/events/oom.h
index 38baeb2..c3c19d4 100644
--- a/include/trace/events/oom.h
+++ b/include/trace/events/oom.h
@@ -70,6 +70,86 @@ TRACE_EVENT(reclaim_retry_zone,
 			__entry->wmark_check)
 );
 
+TRACE_EVENT(mark_victim,
+	TP_PROTO(int pid),
+
+	TP_ARGS(pid),
+
+	TP_STRUCT__entry(
+		__field(int, pid)
+	),
+
+	TP_fast_assign(
+		__entry->pid = pid;
+	),
+
+	TP_printk("pid=%d", __entry->pid)
+);
+
+TRACE_EVENT(wake_reaper,
+	TP_PROTO(int pid),
+
+	TP_ARGS(pid),
+
+	TP_STRUCT__entry(
+		__field(int, pid)
+	),
+
+	TP_fast_assign(
+		__entry->pid = pid;
+	),
+
+	TP_printk("pid=%d", __entry->pid)
+);
+
+TRACE_EVENT(start_task_reaping,
+	TP_PROTO(int pid),
+
+	TP_ARGS(pid),
+
+	TP_STRUCT__entry(
+		__field(int, pid)
+	),
+
+	TP_fast_assign(
+		__entry->pid = pid;
+	),
+
+	TP_printk("pid=%d", __entry->pid)
+);
+
+TRACE_EVENT(finish_task_reaping,
+	TP_PROTO(int pid),
+
+	TP_ARGS(pid),
+
+	TP_STRUCT__entry(
+		__field(int, pid)
+	),
+
+	TP_fast_assign(
+		__entry->pid = pid;
+	),
+
+	TP_printk("pid=%d", __entry->pid)
+);
+
+TRACE_EVENT(skip_task_reaping,
+	TP_PROTO(int pid),
+
+	TP_ARGS(pid),
+
+	TP_STRUCT__entry(
+		__field(int, pid)
+	),
+
+	TP_fast_assign(
+		__entry->pid = pid;
+	),
+
+	TP_printk("pid=%d", __entry->pid)
+);
+
 #ifdef CONFIG_COMPACTION
 TRACE_EVENT(compact_retry,
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 04c9143..409b685 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -490,6 +490,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		ret = false;
+		trace_skip_task_reaping(tsk->pid);
 		goto unlock_oom;
 	}
 
@@ -500,9 +501,12 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 */
 	if (!mmget_not_zero(mm)) {
 		up_read(&mm->mmap_sem);
+		trace_skip_task_reaping(tsk->pid);
 		goto unlock_oom;
 	}
 
+	trace_start_task_reaping(tsk->pid);
+
 	/*
 	 * Tell all users of get_user/copy_from_user etc... that the content
 	 * is no longer stable. No barriers really needed because unmapping
@@ -544,6 +548,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 * put the oom_reaper out of the way.
 	 */
 	mmput_async(mm);
+	trace_finish_task_reaping(tsk->pid);
 unlock_oom:
 	mutex_unlock(&oom_lock);
 	return ret;
@@ -615,6 +620,7 @@ static void wake_oom_reaper(struct task_struct *tsk)
 	tsk->oom_reaper_list = oom_reaper_list;
 	oom_reaper_list = tsk;
 	spin_unlock(&oom_reaper_lock);
+	trace_wake_reaper(tsk->pid);
 	wake_up(&oom_reaper_wait);
 }
 
@@ -666,6 +672,7 @@ static void mark_oom_victim(struct task_struct *tsk)
 	 */
 	__thaw_task(tsk);
 	atomic_inc(&oom_victims);
+	trace_mark_victim(tsk->pid);
 }
 
 /**
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
