Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 08CDC8E0006
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 08:55:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id 57-v6so7210559edt.15
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 05:55:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y50-v6sor14275219edd.15.2018.09.10.05.55.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 05:55:55 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 2/3] mm, oom: keep retrying the oom_reap operation as long as there is substantial memory left
Date: Mon, 10 Sep 2018 14:55:12 +0200
Message-Id: <20180910125513.311-3-mhocko@kernel.org>
In-Reply-To: <20180910125513.311-1-mhocko@kernel.org>
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180910125513.311-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

oom_reaper is not able to reap all types of memory. E.g. mlocked
mappings or page tables. In some cases this might be a lot of memory
and we do rely on exit_mmap to release that memory. Yet we cannot rely
on exit_mmap to set MMF_OOM_SKIP right now because there are several
places when sleeping locks are taken.

This patch adds a simple heuristic to check for the amount of memory
the mm is sitting on after oom_reaper is done with it. If this is still
few megabytes (this is a subject for further tunning based on real world
usecases) then simply keep retrying oom_reap_task_mm.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f10aa5360616..049e67dc039b 100644
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
@@ -532,6 +541,16 @@ bool __oom_reap_task_mm(struct mm_struct *mm)
 		}
 	}
 
+	/*
+	 * If we still sit on a noticeable amount of memory even after successfully
+	 * reaping the address space then keep retrying until exit_mmap makes some
+	 * further progress.
+	 * TODO: add a flag for a stage when the exit path doesn't block anymore
+	 * and hand over MMF_OOM_SKIP handling there in that case
+	 */
+	if (ret && oom_badness_pages(mm) > 1024)
+		ret = false;
+
 	return ret;
 }
 
-- 
2.18.0
