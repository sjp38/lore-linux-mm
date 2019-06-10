Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 446EAC282DD
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 07:46:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E47B8206E0
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 07:46:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E47B8206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 843286B000C; Mon, 10 Jun 2019 03:46:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F37C6B026C; Mon, 10 Jun 2019 03:46:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E2D86B0270; Mon, 10 Jun 2019 03:46:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 198996B000C
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 03:46:46 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id a5so4783433edx.12
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 00:46:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IiQUAbpdc3pVoJS9XtTefBWpZs7w3fgYZcr52ggR2+8=;
        b=IEJomAUcRQbA4gnor6S2GxTAu7fjdqo6cXcOhMIKYeZzJkecCy8No98j744a+oFa5Y
         OhEQYp9YGmuJ2JxV5pEbMMGAHqU8Qo4Ma93Lppj5N87q71BwgemLrsx2kzU5m9kShUGt
         7wvxwevNdGq4aHt5Y7MiKZJ2zx70dVNjz6/0LEhS8bCJuZcxs77nJvfOgip7nOZZ/hLk
         x9bilKN9dTtGJegPxgZh0kGIXqCZaslamQNY4dqaOlbMwh6Rqewj9/5a8Nb03r9O+dqR
         EKh6w259XQrudwQ+EB9EjGfb5OOT2Kr0OqCq5yuf8MxP4GNMnf3s4ncV0x2udBdKUKQs
         lx2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW8xzz4c1yye7nUFkw+VWeieGBTyqbJKKug+ogK6Tj4dcMpXipS
	YrvY+HQpSrfb2pM5aqXHJQmw+bukx+i8LPU6dAQ3Teno67cKKe3F4u8nWAeLIoJemdK/C6TxCwA
	k3eaucW0z9dB6FjYenbEBFZqo0IQ1l69urRAdx9CFRejnRKNwMM6JRnqDNII0jT4=
X-Received: by 2002:a50:b388:: with SMTP id s8mr3975408edd.15.1560152805606;
        Mon, 10 Jun 2019 00:46:45 -0700 (PDT)
X-Received: by 2002:a50:b388:: with SMTP id s8mr3975352edd.15.1560152804608;
        Mon, 10 Jun 2019 00:46:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560152804; cv=none;
        d=google.com; s=arc-20160816;
        b=mL5Snb23F0lxT+Hi6VaS6y8PzyQHeIzHzhf1Hu+pU+K+KOOpdyo2HbS53urAPakK7F
         JMtPI/gJ8cccV9mL6OZbxawnHnpYetQbCPMLZMdAyi9Y93thUuVrrMn34Ew93y5wYUmq
         h8BUf+f8aNsUnVPmSgWJ7C6BU0lbHF5vLA4/Jb1yGEdHaZhdJHdfsiyk6wyAeHCgq09W
         PGKqBsD5zLxcdWN4k5SB46xvGEBeS4PEjTAOnSVm0JXq3JDhVCUTQA1sYpKwNYpNt7XT
         1pRk0UDlRrxgERc6XG3s420WeT8zIQpXRsxwRh6eLy4QMTIJ+FM/YIZDBZm4PBLqIlfV
         xr6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=IiQUAbpdc3pVoJS9XtTefBWpZs7w3fgYZcr52ggR2+8=;
        b=OyQ7aJMMMBCQAL+sun7sa7161vJVBgQMF015wtJerIBrxJ9J+KZ6nL+pXh/fGO2MVC
         YYIfY9btdqKgcOWqvV4qKfSLikC0rD2TVpCpV8X9h66jVdDrGBvX/9JJdJrh4qpOxi9y
         HQSEI9OHTlte+mH+Skj/rAfg1BCKO94x/itgCzRHlww3QgfWYx6eB3IpUOCweGGBZQZQ
         ydr1I1qIihWag95vWTuBNCPZ5RNhVI1BgCAJi+CbQeB1Z4l3+rzryPcy84oXNunRErcE
         uxxz3qtnBT+IQWQd6353iN3Mdhs5Nz91qT2t+ntRGpOInHzwFNswbyr3mO12vAJhfadq
         M17w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t40sor6863873edd.13.2019.06.10.00.46.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 00:46:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqxPc/4T0hB/mog/LVyxMup6Rvf6SXW1VDs4NfyC7BC6TQE8iTkHdqkZVaL2h0A418Eq2pku3g==
X-Received: by 2002:aa7:c692:: with SMTP id n18mr20339213edq.220.1560152804119;
        Mon, 10 Jun 2019 00:46:44 -0700 (PDT)
Received: from tiehlicka.microfocus.com (prg-ext-pat.suse.com. [213.151.95.130])
        by smtp.gmail.com with ESMTPSA id s17sm1683015ejf.48.2019.06.10.00.46.42
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 00:46:42 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
To: Stable tree <stable@vger.kernel.org>
Cc: Greg KH <gregkh@linuxfoundation.org>,
	<linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Jann Horn <jannh@google.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Joel Fernandes <joel@joelfernandes.org>
Subject: [PATCH stable 4.4 v2] coredump: fix race condition between mmget_not_zero()/get_task_mm() and core dumping
Date: Mon, 10 Jun 2019 09:46:34 +0200
Message-Id: <20190610074635.2319-1-mhocko@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190604094953.26688-1-mhocko@kernel.org>
References: <20190604094953.26688-1-mhocko@kernel.org>
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
]
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
this is v2 of the backport. It turned out that the khugepaged part of my
backport was in fact missing in the upstream commit as well so Anrea has
posted a follow up fix with the full explanation [1] and that patch
should be routed to stable trees on its own.

A further review of the backport is highly appreciated of course.

[1] http://lkml.kernel.org/r/20190607161558.32104-1-aarcange@redhat.com

 drivers/android/binder.c |  6 ++++++
 fs/proc/task_mmu.c       | 18 ++++++++++++++++++
 fs/userfaultfd.c         | 10 ++++++++--
 include/linux/mm.h       | 21 +++++++++++++++++++++
 mm/mmap.c                |  7 ++++++-
 5 files changed, 59 insertions(+), 3 deletions(-)

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

