Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F548C31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:59:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6B1C21855
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 06:59:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6B1C21855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B5E88E0004; Mon, 17 Jun 2019 02:59:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73E6B8E0001; Mon, 17 Jun 2019 02:59:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DFAD8E0004; Mon, 17 Jun 2019 02:59:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 099B28E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 02:59:21 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id d15so2126980wrx.5
        for <linux-mm@kvack.org>; Sun, 16 Jun 2019 23:59:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Pxm0H44HQKV5fm7Ty3F8VpuA1HOQ8My7aYm0Qc0A8JU=;
        b=iWyEYUy5AbxqwsIhkMVXPOwRtVn0JsqjopDV6QNICqNSTEGIU0rgMC85najEcTGxl4
         IxbIiKHDWHc8elnoFsES98mWs7qAVjJxQB2a+3YAMYQxTXSNY0WLWGMstLxyep6MIIHN
         uCzv75aX4LRP4te/PEKiCz0+9wf7mfExYKj728wRaFH7b6p6Sea7Xt18y09/elGh3q5P
         FnEIuXKOkiRvoRQqTTrfXfwwaZ4kViZzuWjrA63FLsMHUkpezlqebGBzzHmtLOOFpX+O
         mLysz6JGtmnOZ5/RJg9gAihq8RmOsfWYJ6I47fdYEJ33AK95VQZVwGllN/KbGzD3cRCx
         y+Cg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWkrZfw2cO9RTdKzNCUAaOjjBKQIcOsnJ0WsvdZGl53TT4ypH50
	xbGqtVK0exU7ic22FBjZGL3bE2vcT5VdQOa/L383dv6ieKr9fYVdoy+Y5L5PnRdMqgd9nBPT/Ws
	6DhvPjzR8TIO4ah4ECQF3fnUaSRkXgH1BpOhbOchTa+cgNu6NjUTRj6WS2Gf8Hrg=
X-Received: by 2002:a5d:43c9:: with SMTP id v9mr73385890wrr.70.1560754760567;
        Sun, 16 Jun 2019 23:59:20 -0700 (PDT)
X-Received: by 2002:a5d:43c9:: with SMTP id v9mr73385825wrr.70.1560754759534;
        Sun, 16 Jun 2019 23:59:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560754759; cv=none;
        d=google.com; s=arc-20160816;
        b=rn+e+/FoCgMzvJqpWVBy+QnpJv7Sd+Z6W9EBfs23dcv+C7CwJG5WQGzhk/grclnsZU
         P7uIPu7ID+Fc2ZM3ZjSCvb9j/Va1zKN9U7nlS3SbpqCsvUwJkyzlnpBnRcnCQpB0t83a
         d7FBZ+KoPgqgtLOf4lAbEg12ghORly5pE3zl2iv4kBA6mIeQY+/OAoVdVlQ0KAl6ELvd
         ajY1UIuQ3VaR7RnzoNNL+te3Q6aHTmPijkyTKz0YydijJjDBCbkIXmxIqgkeqAvP9wtk
         F3T5Sb1iW8VypB0bTs3LBLSi52I5xz1NZAPLnb+Aymrhxr0Mlu4mRKlWLGZXjvin5tlV
         3toQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Pxm0H44HQKV5fm7Ty3F8VpuA1HOQ8My7aYm0Qc0A8JU=;
        b=RLTgoqpEk89cjf1z4fq44kwV8ORcMIw5NAVa0Tx7OI3T7b0WwZgt285SWtzlafSVgR
         qpJKam7WRTFBumObdD9I80IIjKbO3UWgKOXu6hGhAjXYwwIZ/0MzxrrKeJtU59M0QQUV
         e8Q10vTvpusCy21vkaiVd8H/SNE8Jnx4VXuEIDwzYOBh0LjFSyIYPhP+5LPCByvfxviw
         3coJttCEY4sHSTieR1L29h1XtJyDKzOShoZvdLs1R8+t5DXlr2EASp7d0lNZRk1RTuxa
         0RHPHlT3pfkl9H6/3gb/zp4aKHJxZhXaLF9B/RDZszI6m3xmJ7ylOhvhfkWJRjVQmrsi
         WUnw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i4sor2236920wru.25.2019.06.16.23.59.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Jun 2019 23:59:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqxlnG15SzuRBQmw0I107pYqTra3XN0WlSOLkJEhTFibg4QQzM9JrkkLymg02PqlRTZNOKf6LA==
X-Received: by 2002:adf:f246:: with SMTP id b6mr14387420wrp.92.1560754759114;
        Sun, 16 Jun 2019 23:59:19 -0700 (PDT)
Received: from tiehlicka.suse.cz (ip-37-188-180-103.eurotel.cz. [37.188.180.103])
        by smtp.gmail.com with ESMTPSA id c11sm7576979wrs.97.2019.06.16.23.59.16
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 16 Jun 2019 23:59:17 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
To: Stable tree <stable@vger.kernel.org>
Cc: Greg KH <gregkh@linuxfoundation.org>,
	Jason Gunthorpe <jgg@mellanox.com>,
	<linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Jann Horn <jannh@google.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Joel Fernandes <joel@joelfernandes.org>
Subject: [PATCH stable-4.4 v3] coredump: fix race condition between mmget_not_zero()/get_task_mm() and core dumping
Date: Mon, 17 Jun 2019 08:58:24 +0200
Message-Id: <20190617065824.28305-1-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190610074635.2319-1-mhocko@kernel.org>
References: <20190610074635.2319-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Upstream 04f5866e41fb70690e28397487d8bd8eea7d712a commit.

The core dumping code has always run without holding the mmap_sem for
writing, despite that is the only way to ensure that the entire vma
layout will not change from under it.  Only using some signal
serialization on the processes belonging to the mm is not nearly enough.
This was pointed out earlier.  For example in Hugh's post from Jul 2017:

  https://lkml.kernel.org/r/alpine.LSU.2.11.1707191716030.2055@eggly.anvils

  "Not strictly relevant here, but a related note: I was very surprised
   to discover, only quite recently, how handle_mm_fault() may be called
   without down_read(mmap_sem) - when core dumping. That seems a
   misguided optimization to me, which would also be nice to correct"

In particular because the growsdown and growsup can move the
vm_start/vm_end the various loops the core dump does around the vma will
not be consistent if page faults can happen concurrently.

Pretty much all users calling mmget_not_zero()/get_task_mm() and then
taking the mmap_sem had the potential to introduce unexpected side
effects in the core dumping code.

Adding mmap_sem for writing around the ->core_dump invocation is a
viable long term fix, but it requires removing all copy user and page
faults and to replace them with get_dump_page() for all binary formats
which is not suitable as a short term fix.

For the time being this solution manually covers the places that can
confuse the core dump either by altering the vma layout or the vma flags
while it runs.  Once ->core_dump runs under mmap_sem for writing the
function mmget_still_valid() can be dropped.

Allowing mmap_sem protected sections to run in parallel with the
coredump provides some minor parallelism advantage to the swapoff code
(which seems to be safe enough by never mangling any vma field and can
keep doing swapins in parallel to the core dumping) and to some other
corner case.

In order to facilitate the backporting I added "Fixes: 86039bd3b4e6"
however the side effect of this same race condition in /proc/pid/mem
should be reproducible since before 2.6.12-rc2 so I couldn't add any
other "Fixes:" because there's no hash beyond the git genesis commit.

Because find_extend_vma() is the only location outside of the process
context that could modify the "mm" structures under mmap_sem for
reading, by adding the mmget_still_valid() check to it, all other cases
that take the mmap_sem for reading don't need the new check after
mmget_not_zero()/get_task_mm().  The expand_stack() in page fault
context also doesn't need the new check, because all tasks under core
dumping are frozen.

Link: http://lkml.kernel.org/r/20190325224949.11068-1-aarcange@redhat.com
Fixes: 86039bd3b4e6 ("userfaultfd: add new syscall to provide memory externalization")
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: Jann Horn <jannh@google.com>
Suggested-by: Oleg Nesterov <oleg@redhat.com>
Acked-by: Peter Xu <peterx@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
Reviewed-by: Oleg Nesterov <oleg@redhat.com>
Reviewed-by: Jann Horn <jannh@google.com>
Acked-by: Jason Gunthorpe <jgg@mellanox.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Joel Fernandes (Google) <joel@joelfernandes.org>
[mhocko@suse.com: stable 4.4 backport
 - drop infiniband part because of missing 5f9794dc94f59
 - drop userfaultfd_event_wait_completion hunk because of
   missing 9cd75c3cd4c3d]
 - handle binder_update_page_range because of missing 720c241924046
 - handle mlx5_ib_disassociate_ucontext - akaher@vmware.com
]
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/android/binder.c          |  6 ++++++
 drivers/infiniband/hw/mlx4/main.c |  3 +++
 fs/proc/task_mmu.c                | 18 ++++++++++++++++++
 fs/userfaultfd.c                  | 10 ++++++++--
 include/linux/mm.h                | 21 +++++++++++++++++++++
 mm/mmap.c                         |  7 ++++++-
 6 files changed, 62 insertions(+), 3 deletions(-)

diff --git a/drivers/android/binder.c b/drivers/android/binder.c
index 260ce0e60187..1fb1cddbd19a 100644
--- a/drivers/android/binder.c
+++ b/drivers/android/binder.c
@@ -570,6 +570,12 @@ static int binder_update_page_range(struct binder_proc *proc, int allocate,
 
 	if (mm) {
 		down_write(&mm->mmap_sem);
+		if (!mmget_still_valid(mm)) {
+			if (allocate == 0)
+				goto free_range;
+			goto err_no_vma;
+		}
+
 		vma = proc->vma;
 		if (vma && mm != proc->vma_vm_mm) {
 			pr_err("%d: vma mm and task mm mismatch\n",
diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 67c4c73343d4..6968154a073e 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1042,6 +1042,8 @@ static void mlx4_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 	 * mlx4_ib_vma_close().
 	 */
 	down_write(&owning_mm->mmap_sem);
+	if (!mmget_still_valid(owning_mm))
+		goto skip_mm;
 	for (i = 0; i < HW_BAR_COUNT; i++) {
 		vma = context->hw_bar_info[i].vma;
 		if (!vma)
@@ -1061,6 +1063,7 @@ static void mlx4_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 		context->hw_bar_info[i].vma->vm_ops = NULL;
 	}
 
+skip_mm:
 	up_write(&owning_mm->mmap_sem);
 	mmput(owning_mm);
 	put_task_struct(owning_process);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 75691a20313c..ad1ccdcef74e 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -947,6 +947,24 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 					continue;
 				up_read(&mm->mmap_sem);
 				down_write(&mm->mmap_sem);
+				/*
+				 * Avoid to modify vma->vm_flags
+				 * without locked ops while the
+				 * coredump reads the vm_flags.
+				 */
+				if (!mmget_still_valid(mm)) {
+					/*
+					 * Silently return "count"
+					 * like if get_task_mm()
+					 * failed. FIXME: should this
+					 * function have returned
+					 * -ESRCH if get_task_mm()
+					 * failed like if
+					 * get_proc_task() fails?
+					 */
+					up_write(&mm->mmap_sem);
+					goto out_mm;
+				}
 				for (vma = mm->mmap; vma; vma = vma->vm_next) {
 					vma->vm_flags &= ~VM_SOFTDIRTY;
 					vma_set_page_prot(vma);
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 59d58bdad7d3..4053de7b7064 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -443,6 +443,8 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	 * taking the mmap_sem for writing.
 	 */
 	down_write(&mm->mmap_sem);
+	if (!mmget_still_valid(mm))
+		goto skip_mm;
 	prev = NULL;
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		cond_resched();
@@ -465,6 +467,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 		vma->vm_flags = new_flags;
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
 	}
+skip_mm:
 	up_write(&mm->mmap_sem);
 
 	/*
@@ -761,9 +764,10 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	end = start + uffdio_register.range.len;
 
 	down_write(&mm->mmap_sem);
-	vma = find_vma_prev(mm, start, &prev);
-
 	ret = -ENOMEM;
+	if (!mmget_still_valid(mm))
+		goto out_unlock;
+	vma = find_vma_prev(mm, start, &prev);
 	if (!vma)
 		goto out_unlock;
 
@@ -903,6 +907,8 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 	end = start + uffdio_unregister.len;
 
 	down_write(&mm->mmap_sem);
+	if (!mmget_still_valid(mm))
+		goto out_unlock;
 	vma = find_vma_prev(mm, start, &prev);
 
 	ret = -ENOMEM;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 251adf4d8a71..ed653ba47c46 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1098,6 +1098,27 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long address,
 void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long start, unsigned long end);
 
+/*
+ * This has to be called after a get_task_mm()/mmget_not_zero()
+ * followed by taking the mmap_sem for writing before modifying the
+ * vmas or anything the coredump pretends not to change from under it.
+ *
+ * NOTE: find_extend_vma() called from GUP context is the only place
+ * that can modify the "mm" (notably the vm_start/end) under mmap_sem
+ * for reading and outside the context of the process, so it is also
+ * the only case that holds the mmap_sem for reading that must call
+ * this function. Generally if the mmap_sem is hold for reading
+ * there's no need of this check after get_task_mm()/mmget_not_zero().
+ *
+ * This function can be obsoleted and the check can be removed, after
+ * the coredump code will hold the mmap_sem for writing before
+ * invoking the ->core_dump methods.
+ */
+static inline bool mmget_still_valid(struct mm_struct *mm)
+{
+	return likely(!mm->core_state);
+}
+
 /**
  * mm_walk - callbacks for walk_page_range
  * @pmd_entry: if set, called for each non-empty PMD (3rd-level) entry
diff --git a/mm/mmap.c b/mm/mmap.c
index baa4c1280bff..a24e42477001 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -42,6 +42,7 @@
 #include <linux/memory.h>
 #include <linux/printk.h>
 #include <linux/userfaultfd_k.h>
+#include <linux/mm.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -2398,7 +2399,8 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 	vma = find_vma_prev(mm, addr, &prev);
 	if (vma && (vma->vm_start <= addr))
 		return vma;
-	if (!prev || expand_stack(prev, addr))
+	/* don't alter vm_end if the coredump is running */
+	if (!prev || !mmget_still_valid(mm) || expand_stack(prev, addr))
 		return NULL;
 	if (prev->vm_flags & VM_LOCKED)
 		populate_vma_page_range(prev, addr, prev->vm_end, NULL);
@@ -2424,6 +2426,9 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 		return vma;
 	if (!(vma->vm_flags & VM_GROWSDOWN))
 		return NULL;
+	/* don't alter vm_start if the coredump is running */
+	if (!mmget_still_valid(mm))
+		return NULL;
 	start = vma->vm_start;
 	if (expand_stack(vma, addr))
 		return NULL;
-- 
2.20.1

