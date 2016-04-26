Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D8D8D6B0264
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:56:48 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y84so11520245lfc.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:48 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id f141si3158777wmf.102.2016.04.26.05.56.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 05:56:37 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id w143so4194427wmw.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:37 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 08/18] mm, fork: make dup_mmap wait for mmap_sem for write killable
Date: Tue, 26 Apr 2016 14:56:15 +0200
Message-Id: <1461675385-5934-9-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Vlastimil Babka <vbabka@suse.cz>

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
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 kernel/fork.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 4bb0a7a0fbe0..bb29839a7e1b 100644
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
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
