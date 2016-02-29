Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 93EB26B0005
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 13:07:19 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l68so1028344wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:07:19 -0800 (PST)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id 17si33296870wjv.159.2016.02.29.10.07.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 10:07:18 -0800 (PST)
Received: by mail-wm0-f50.google.com with SMTP id n186so950763wmn.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 10:07:18 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, fork: make dup_mmap wait for mmap_sem for write killable
Date: Mon, 29 Feb 2016 19:07:12 +0100
Message-Id: <1456769232-27592-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456752417-9626-9-git-send-email-mhocko@kernel.org>
References: <1456752417-9626-9-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>

From: Michal Hocko <mhocko@suse.com>

dup_mmap needs to lock current's mm mmap_sem for write. If the waiting
task gets killed by the oom killer it would block oom_reaper from
asynchronous address space reclaim and reduce the chances of timely OOM
resolving. Wait for the lock in the killable mode and return with EINTR
if the task got killed while waiting.

Cc: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 kernel/fork.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index d277e83ed3e0..139968026b76 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -413,7 +413,10 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 	unsigned long charge;
 
 	uprobe_start_dup_mmap();
-	down_write(&oldmm->mmap_sem);
+	if (down_write_killable(&oldmm->mmap_sem)) {
+		retval = -EINTR;
+		goto fail_uprobe_end;
+	}
 	flush_cache_dup_mm(oldmm);
 	uprobe_dup_mmap(oldmm, mm);
 	/*
@@ -525,6 +528,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 	up_write(&mm->mmap_sem);
 	flush_tlb_mm(oldmm);
 	up_write(&oldmm->mmap_sem);
+fail_uprobe_end:
 	uprobe_end_dup_mmap();
 	return retval;
 fail_nomem_anon_vma_fork:
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
