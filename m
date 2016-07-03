Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2036C6B0253
	for <linux-mm@kvack.org>; Sat,  2 Jul 2016 22:42:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 143so321234154pfx.0
        for <linux-mm@kvack.org>; Sat, 02 Jul 2016 19:42:33 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f64si1425728pfd.84.2016.07.02.19.42.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 02 Jul 2016 19:42:32 -0700 (PDT)
Subject: [PATCH 7/8] mm,oom_reaper: Pass OOM victim's comm and pid values via mm_struct.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
In-Reply-To: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
Message-Id: <201607031141.IFH64089.FHMSOFQFtLJOOV@I-love.SAKURA.ne.jp>
Date: Sun, 3 Jul 2016 11:41:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

>From 14cb84f6c1cd3a7ace58e52fea2fb52cb8e16f91 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 2 Jul 2016 23:04:23 +0900
Subject: [PATCH 7/8] mm,oom_reaper: Pass OOM victim's comm and pid values via mm_struct.

In order to make OOM reaper operate on mm_struct, pass comm and pid values
which are used for printing result of OOM reap attempt via oom_mm embedded
into mm_struct.

While it is possible to add pointer to task_struct to oom_mm struct,
we don't want to hold a reference to task_struct because that OOM victim
might be able to exit soon. Thus, copy comm and pid values as of calling
mark_oom_victim().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/mm_types.h |  4 ++++
 mm/oom_kill.c            | 20 ++++++++++++--------
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 718c0bd..3eabea9 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -397,6 +397,10 @@ struct oom_mm {
 	struct list_head list; /* Linked to oom_mm_list list. */
 	struct mem_cgroup *memcg; /* No deref. Maybe NULL. */
 	const nodemask_t *nodemask; /* No deref. Maybe NULL. */
+#ifdef CONFIG_MMU
+	char comm[16]; /* Copy of task_struct->comm[TASK_COMM_LEN]. */
+	pid_t pid; /* Copy of task_struct->pid. */
+#endif
 };
 
 struct kioctx_table;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 45e7de2..317ce2c 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -471,7 +471,7 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
-static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
+static bool __oom_reap_vmas(struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
@@ -519,10 +519,10 @@ static bool __oom_reap_task(struct task_struct *tsk, struct mm_struct *mm)
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
 	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
-			task_pid_nr(tsk), tsk->comm,
-			K(get_mm_counter(mm, MM_ANONPAGES)),
-			K(get_mm_counter(mm, MM_FILEPAGES)),
-			K(get_mm_counter(mm, MM_SHMEMPAGES)));
+		mm->oom_mm.pid, mm->oom_mm.comm,
+		K(get_mm_counter(mm, MM_ANONPAGES)),
+		K(get_mm_counter(mm, MM_FILEPAGES)),
+		K(get_mm_counter(mm, MM_SHMEMPAGES)));
 	up_read(&mm->mmap_sem);
 
 	/*
@@ -559,14 +559,14 @@ static void oom_reap_task(struct task_struct *tsk)
 	task_unlock(p);
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task(tsk, mm))
+	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_vmas(mm))
 		schedule_timeout_idle(HZ/10);
 
 	if (attempts <= MAX_OOM_REAP_RETRIES)
 		goto done;
 
 	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-		task_pid_nr(tsk), tsk->comm);
+		mm->oom_mm.pid, mm->oom_mm.comm);
 
 	/*
 	 * If we've already tried to reap this task in the past and
@@ -576,7 +576,7 @@ static void oom_reap_task(struct task_struct *tsk)
 	 */
 	if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &mm->flags)) {
 		pr_info("oom_reaper: giving up pid:%d (%s)\n",
-			task_pid_nr(tsk), tsk->comm);
+			mm->oom_mm.pid, mm->oom_mm.comm);
 		set_bit(MMF_OOM_REAPED, &mm->flags);
 	}
 	debug_show_all_locks();
@@ -662,6 +662,10 @@ void mark_oom_victim(struct task_struct *tsk, struct oom_control *oc)
 		atomic_inc(&mm->mm_count);
 		mm->oom_mm.memcg = oc->memcg;
 		mm->oom_mm.nodemask = oc->nodemask;
+#ifdef CONFIG_MMU
+		strncpy(mm->oom_mm.comm, tsk->comm, sizeof(mm->oom_mm.comm));
+		mm->oom_mm.pid = task_pid_nr(tsk);
+#endif
 		list_add_tail(&mm->oom_mm.list, &oom_mm_list);
 	}
 	spin_unlock(&oom_mm_lock);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
