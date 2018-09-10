Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD7CD8E0006
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 08:55:57 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d47-v6so7204403edb.3
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 05:55:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v1-v6sor14861574edf.9.2018.09.10.05.55.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 05:55:56 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 3/3] mm, oom: hand over MMF_OOM_SKIP to exit path if it is guranteed to finish
Date: Mon, 10 Sep 2018 14:55:13 +0200
Message-Id: <20180910125513.311-4-mhocko@kernel.org>
In-Reply-To: <20180910125513.311-1-mhocko@kernel.org>
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180910125513.311-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

David Rientjes has noted that certain user space memory allocators leave
a lot of page tables behind and the current implementation of oom_reaper
doesn't deal with those workloads very well. In order to improve these
workloads define a point when exit_mmap is guaranteed to finish the tear
down without any further blocking etc. This is right after we unlink
vmas (those still depend on locks which are held while performing memory
allocations from other contexts) and before we start releasing page
tables.

Opencode free_pgtables and explicitly unlink all vmas first. Then set
mm->mmap to NULL (there shouldn't be anybody looking at it at this
stage) and check for mm->mmap in the oom_reaper path. If the mm->mmap
is NULL we rely on the exit path and won't set MMF_OOM_SKIP from the
reaper.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/mmap.c     | 24 ++++++++++++++++++++----
 mm/oom_kill.c | 13 +++++++------
 2 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 3481424717ac..99bb9ce29bc5 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3085,8 +3085,27 @@ void exit_mmap(struct mm_struct *mm)
 	/* oom_reaper cannot race with the page tables teardown */
 	if (oom)
 		down_write(&mm->mmap_sem);
+	/*
+	 * Hide vma from rmap and truncate_pagecache before freeing
+	 * pgtables
+	 */
+	while (vma) {
+		unlink_anon_vmas(vma);
+		unlink_file_vma(vma);
+		vma = vma->vm_next;
+	}
+	vma = mm->mmap;
+	if (oom) {
+		/*
+		 * the exit path is guaranteed to finish without any unbound
+		 * blocking at this stage so make it clear to the caller.
+		 */
+		mm->mmap = NULL;
+		up_write(&mm->mmap_sem);
+	}
 
-	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
+	free_pgd_range(&tlb, vma->vm_start, vma->vm_prev->vm_end,
+			FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
 
 	/*
@@ -3099,9 +3118,6 @@ void exit_mmap(struct mm_struct *mm)
 		vma = remove_vma(vma);
 	}
 	vm_unacct_memory(nr_accounted);
-
-	if (oom)
-		up_write(&mm->mmap_sem);
 }
 
 /* Insert vm structure into process list sorted by address
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 049e67dc039b..0ebf93c76c81 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -570,12 +570,10 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	}
 
 	/*
-	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
-	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
-	 * under mmap_sem for reading because it serializes against the
-	 * down_write();up_write() cycle in exit_mmap().
+	 * If exit path clear mm->mmap then we know it will finish the tear down
+	 * and we can go and bail out here.
 	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
+	if (!mm->mmap) {
 		trace_skip_task_reaping(tsk->pid);
 		goto out_unlock;
 	}
@@ -624,8 +622,11 @@ static void oom_reap_task(struct task_struct *tsk)
 	/*
 	 * Hide this mm from OOM killer because it has been either reaped or
 	 * somebody can't call up_write(mmap_sem).
+	 * Leave the MMF_OOM_SKIP to the exit path if it managed to reach the
+	 * point it is guaranteed to finish without any blocking
 	 */
-	set_bit(MMF_OOM_SKIP, &mm->flags);
+	if (mm->mmap)
+		set_bit(MMF_OOM_SKIP, &mm->flags);
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);
-- 
2.18.0
