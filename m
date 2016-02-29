Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 511886B025F
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:27:32 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l68so36715657wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 05:27:32 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 13/18] exec: make exec path waiting for mmap_sem killable
Date: Mon, 29 Feb 2016 14:26:52 +0100
Message-Id: <1456752417-9626-14-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>, Alexander Viro <viro@zeniv.linux.org.uk>

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
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/exec.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index c4010b8207a1..29f2f22ae067 100644
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
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
