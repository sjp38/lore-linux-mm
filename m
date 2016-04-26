Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A460A6B0269
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 08:56:59 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s63so11698145wme.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:59 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id kd3si19805132wjb.79.2016.04.26.05.56.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 05:56:41 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id n3so4764361wmn.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 05:56:41 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 13/18] exec: make exec path waiting for mmap_sem killable
Date: Tue, 26 Apr 2016 14:56:20 +0200
Message-Id: <1461675385-5934-14-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
References: <1461675385-5934-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Oleg Nesterov <oleg@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

From: Michal Hocko <mhocko@suse.com>

setup_arg_pages requires mmap_sem for write. If the waiting task
gets killed by the oom killer it would block oom_reaper from
asynchronous address space reclaim and reduce the chances of timely
OOM resolving. Wait for the lock in the killable mode and return with
EINTR if the task got killed while waiting. All the callers are already
handling error path and the fatal signal doesn't need any additional
treatment.

The same applies to __bprm_mm_init.

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Acked-by: Oleg Nesterov <oleg@redhat.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/exec.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 2f44590d88a9..d7a6ff09bb7a 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -267,7 +267,10 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 	if (!vma)
 		return -ENOMEM;
 
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem)) {
+		err = -EINTR;
+		goto err_free;
+	}
 	vma->vm_mm = mm;
 
 	/*
@@ -294,6 +297,7 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 	return 0;
 err:
 	up_write(&mm->mmap_sem);
+err_free:
 	bprm->vma = NULL;
 	kmem_cache_free(vm_area_cachep, vma);
 	return err;
@@ -700,7 +704,9 @@ int setup_arg_pages(struct linux_binprm *bprm,
 		bprm->loader -= stack_shift;
 	bprm->exec -= stack_shift;
 
-	down_write(&mm->mmap_sem);
+	if (down_write_killable(&mm->mmap_sem))
+		return -EINTR;
+
 	vm_flags = VM_STACK_FLAGS;
 
 	/*
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
