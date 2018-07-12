Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 473D06B026E
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 17:34:03 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v25-v6so11115271pfm.11
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 14:34:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v5-v6sor5520756pfd.58.2018.07.12.14.34.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 14:34:01 -0700 (PDT)
Date: Thu, 12 Jul 2018 14:34:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, oom: remove oom_lock from exit_mmap
Message-ID: <alpine.DEB.2.21.1807121432370.170100@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

oom_lock isn't needed for __oom_reap_task_mm().  If MMF_UNSTABLE is 
already set for the mm, we can simply back out immediately since oom 
reaping is already in progress (or done).

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/mmap.c     | 2 --
 mm/oom_kill.c | 6 ++++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index cd2431f46188..7f918eb725f6 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3072,9 +3072,7 @@ void exit_mmap(struct mm_struct *mm)
 		 * to mmu_notifier_release(mm) ensures mmu notifier callbacks in
 		 * __oom_reap_task_mm() will not block.
 		 */
-		mutex_lock(&oom_lock);
 		__oom_reap_task_mm(mm);
-		mutex_unlock(&oom_lock);
 
 		/*
 		 * Now, set MMF_UNSTABLE to avoid racing with the oom reaper.
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0fe4087d5151..e6328cef090f 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -488,9 +488,11 @@ void __oom_reap_task_mm(struct mm_struct *mm)
 	 * Tell all users of get_user/copy_from_user etc... that the content
 	 * is no longer stable. No barriers really needed because unmapping
 	 * should imply barriers already and the reader would hit a page fault
-	 * if it stumbled over a reaped memory.
+	 * if it stumbled over a reaped memory. If MMF_UNSTABLE is already set,
+	 * reaping as already occurred so nothing left to do.
 	 */
-	set_bit(MMF_UNSTABLE, &mm->flags);
+	if (test_and_set_bit(MMF_UNSTABLE, &mm->flags))
+		return;
 
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
 		if (!can_madv_dontneed_vma(vma))
