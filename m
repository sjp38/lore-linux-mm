Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A16426B026D
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 04:24:15 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x44-v6so4273084edd.17
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 01:24:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y52-v6sor5617975edb.19.2018.10.25.01.24.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 01:24:13 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH v2 2/3] mm, oom: keep retrying the oom_reap operation as long as there is substantial memory left
Date: Thu, 25 Oct 2018 10:24:02 +0200
Message-Id: <20181025082403.3806-3-mhocko@kernel.org>
In-Reply-To: <20181025082403.3806-1-mhocko@kernel.org>
References: <20181025082403.3806-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

oom_reaper is not able to reap all types of memory. E.g. mlocked
mappings or page tables. In some cases this might be a lot of memory
and we do rely on exit_mmap to release that memory. Yet we cannot rely
on exit_mmap to set MMF_OOM_SKIP right now because there are several
places when sleeping locks are taken.

This patch adds a simple heuristic to check for the amount of memory
the mm is sitting on after oom_reaper is done with it. If this is still
a considerable amount of the original memory (more than 1/4 of the
original badness) then simply keep retrying oom_reap_task_mm. The
portion is quite arbitrary and a subject of future tuning based on real
life usecases but it should catch some outliars when the vast portion
of the memory is consumed by non-reapable memory.

Changes since RFC
- do not use hardcoded threshold for retry and rather use a portion of
  the original badness instead

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 32 ++++++++++++++++++++++++++------
 1 file changed, 26 insertions(+), 6 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index b3b2c2bbd8ab..ab42717661dc 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -189,6 +189,16 @@ static bool is_dump_unreclaim_slabs(void)
 	return (global_node_page_state(NR_SLAB_UNRECLAIMABLE) > nr_lru);
 }
 
+/*
+ * Rough memory consumption of the given mm which should be theoretically freed
+ * when the mm is removed.
+ */
+static unsigned long oom_badness_pages(struct mm_struct *mm)
+{
+	return get_mm_rss(mm) + get_mm_counter(mm, MM_SWAPENTS) +
+		mm_pgtables_bytes(mm) / PAGE_SIZE;
+}
+
 /**
  * oom_badness - heuristic function to determine which candidate task to kill
  * @p: task struct of which task we should calculate
@@ -230,8 +240,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss, pagetable and swap space use.
 	 */
-	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
-		mm_pgtables_bytes(p->mm) / PAGE_SIZE;
+	points = oom_badness_pages(p->mm);
 	task_unlock(p);
 
 	/* Normalize to oom_score_adj units */
@@ -488,7 +497,7 @@ static DECLARE_WAIT_QUEUE_HEAD(oom_reaper_wait);
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
-static bool __oom_reap_task_mm(struct mm_struct *mm)
+static bool __oom_reap_task_mm(struct mm_struct *mm, unsigned long original_badness)
 {
 	struct vm_area_struct *vma;
 	bool ret = true;
@@ -532,6 +541,16 @@ static bool __oom_reap_task_mm(struct mm_struct *mm)
 		}
 	}
 
+	/*
+	 * If we still sit on a noticeable amount of memory even after successfully
+	 * reaping the address space then keep retrying until exit_mmap makes some
+	 * further progress.
+	 * TODO: add a flag for a stage when the exit path doesn't block anymore
+	 * and hand over MMF_OOM_SKIP handling there in that case
+	 */
+	if (oom_badness_pages(mm) > (original_badness >> 2))
+		ret = false;
+
 	return ret;
 }
 
@@ -541,7 +560,7 @@ static bool __oom_reap_task_mm(struct mm_struct *mm)
  * Returns true on success and false if none or part of the address space
  * has been reclaimed and the caller should retry later.
  */
-static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
+static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm, unsigned long original_badness)
 {
 	bool ret = true;
 
@@ -564,7 +583,7 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	trace_start_task_reaping(tsk->pid);
 
 	/* failed to reap part of the address space. Try again later */
-	ret = __oom_reap_task_mm(mm);
+	ret = __oom_reap_task_mm(mm, original_badness);
 	if (!ret)
 		goto out_finish;
 
@@ -586,9 +605,10 @@ static void oom_reap_task(struct task_struct *tsk)
 {
 	int attempts = 0;
 	struct mm_struct *mm = tsk->signal->oom_mm;
+	unsigned long original_badness = oom_badness_pages(mm);
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !oom_reap_task_mm(tsk, mm))
+	while (attempts++ < MAX_OOM_REAP_RETRIES && !oom_reap_task_mm(tsk, mm, original_badness))
 		schedule_timeout_idle(HZ/10);
 
 	if (attempts <= MAX_OOM_REAP_RETRIES ||
-- 
2.19.1
