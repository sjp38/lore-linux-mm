Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1FF696B0260
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 05:26:59 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a4so78320424lfa.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 02:26:59 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id pa7si2805749wjb.109.2016.07.01.02.26.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 02:26:54 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id 187so3863900wmz.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 02:26:54 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 4/6] oom, oom_reaper: consider mmget_not_zero as a failure
Date: Fri,  1 Jul 2016 11:26:28 +0200
Message-Id: <1467365190-24640-5-git-send-email-mhocko@kernel.org>
In-Reply-To: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
References: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

mmget_not_zero failing means that we are racing with mmput->__mmput
and we are currently interpreting this as a success because we believe
that __mmput will release the address space. This is not guaranteed
though because at least exit_aio might wait on IO and it is not entirely
clear whether it will terminate in a bounded amount of time. It is hard
to tell what else is lurking there.

This patch makes this path more conservative and we report a failure
which will lead to setting MMF_OOM_NOT_REAPABLE and MMF_OOM_REAPED if
this state is permanent.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/oom_kill.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4ac089cba353..b2210b6c38ba 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -460,7 +460,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	struct mm_struct *mm = NULL;
 	struct zap_details details = {.check_swap_entries = true,
 				      .ignore_dirty = true};
-	bool ret = true;
+	bool ret = false;
 
 	/*
 	 * We have to make sure to not race with the victim exit path
@@ -479,10 +479,8 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	mutex_lock(&oom_lock);
 
 	mm = tsk->signal->oom_mm;
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		ret = false;
+	if (!down_read_trylock(&mm->mmap_sem))
 		goto unlock_oom;
-	}
 
 	/*
 	 * increase mm_users only after we know we will reap something so
@@ -494,6 +492,7 @@ static bool __oom_reap_task(struct task_struct *tsk)
 		goto unlock_oom;
 	}
 
+	ret = true;
 	tlb_gather_mmu(&tlb, mm, 0, -1);
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
 		if (is_vm_hugetlb_page(vma))
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
