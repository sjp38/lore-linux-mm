Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DATE_IN_FUTURE_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EE25C43613
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 05:01:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9479420843
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 05:01:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9479420843
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D2DE6B0003; Sat, 22 Jun 2019 01:01:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2849E8E0002; Sat, 22 Jun 2019 01:01:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 172868E0001; Sat, 22 Jun 2019 01:01:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D183E6B0003
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 01:01:54 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id u10so4688948plq.21
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 22:01:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version;
        bh=1WhF6WRW29t4JGYTp97LOe92+QWH1u7qXPt6K87cbjI=;
        b=YQG6XB0jbrrteRWwBcdX5CfTiPvrXh9wWdvhCHyuAH0VYEKJTzM/9NJJe8nwAh9ec6
         nveZRivN29i6C6w1kmEg3r70vVLQifUmXGG36OvwKXedRkY0BAQYb9lRmtallbfh4yoL
         Bq5zbkl911pkQ8JoPLvGeEXzXnP3QyYvh9wpQwA+9tLsj3eIfkQ0Oj7BJa9PiUj7HRbQ
         QNNIVkGBu6hFXnJ5eavhQBJOw6ea2vjx/uwriCYmdbRZ/CZ0oOfuj7woWm1Vq5q6IosL
         qNoIZf8mQ4rlfetJpVud52XOT000SjU465NO800OofNozEWnZIoKeDQv2x6b3FkdMLnV
         xVWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAX3fmCusfcMeJXirCAE+de5R+hYtPHxg1t1HqBxE5dKwuN+WVcb
	Exy98jCfR387FdoPO/EPfFapnv5a1rYsK+soSporBxYuZ+cx32PI0dD+eyWT7GPkcoVyGsvNoOa
	jFFg8f5+U2I5SxfmvDFmpgxzPxBoYJokWwxQIpX5inSJWsFNu+wvCDj4KLHvbN4Gvqw==
X-Received: by 2002:a17:902:4201:: with SMTP id g1mr27353748pld.300.1561179714459;
        Fri, 21 Jun 2019 22:01:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoM/9eA/7pzYwLrUF6hCqRZsx9UFypbNFzYSJgN9i+gC0juLyTlKqDkjPMLFdtHGJ7SpP+
X-Received: by 2002:a17:902:4201:: with SMTP id g1mr27353650pld.300.1561179712992;
        Fri, 21 Jun 2019 22:01:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561179712; cv=none;
        d=google.com; s=arc-20160816;
        b=0ydEWOXm4/A0xB9eiU6UU8fquzLejkrEeSyws/O8lQcQf5NZwsVGqagqCxiF780/k4
         oNeClNuN+Vb9GTjcwbB/ISe9ZOL19iWe31BFk+vp3xNEmBE9X0CWyX++bxJU+ft8djKc
         AtWMd6qF356ECQGPyLJyRNuuDgPLw095RgYYruC1d53XE99+7jOh6fzbjPv595XzWyvf
         fMxn6AVQ+KGIfjo2JEzaqraoRSrVRBnHnFbJvI6koD6bPq1vXh3/7yRp1kB4fdA8EnG5
         +8RJE94T67mUxE+1K3birqsJWd2pk9BZiL0E6inROzIJk1TCQLoO7k8LQJRv3K6kiCgK
         Bxiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:cc:to:from;
        bh=1WhF6WRW29t4JGYTp97LOe92+QWH1u7qXPt6K87cbjI=;
        b=it2LoKjZAAsOXoLaWoVYM6leze3s+zwPwIKpi8/mhYtgjkSujZC5NBluBvKvtqVdCC
         sdrFs68WqQXp/gHNJzXgYytFYXQ3dLecZ1k0gMk52OmSF32oz2X1+NY/FB7D1y1u0Uvl
         63FYP3BZCCpegMpKGN0mmqQx4EUlDE7GkbihMZ/5i0zecVy9orvV1OdZbiGipEeGOWFn
         w1dHXAres8r2eFnVaNxt/RqlLXUT4fx6jl9NncsTSOtYkmlTfQoMc64TrX1SlJpp3MQU
         PU5GDNo36XtQE/fIAa6cEI6p5inv3xttMaBYiy0YuYKFe5reSUReuVBeaz5lL9FH+iHC
         idhg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id v4si3970027pgr.475.2019.06.21.22.01.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 21 Jun 2019 22:01:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 21 Jun 2019 22:01:48 -0700
Received: from akaher-lnx-dev.eng.vmware.com (unknown [10.110.19.203])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 57E364173D;
	Fri, 21 Jun 2019 22:01:45 -0700 (PDT)
From: Ajay Kaher <akaher@vmware.com>
To: <aarcange@redhat.com>, <jannh@google.com>, <oleg@redhat.com>,
	<peterx@redhat.com>, <rppt@linux.ibm.com>, <jgg@mellanox.com>,
	<mhocko@suse.com>
CC: <jglisse@redhat.com>, <akpm@linux-foundation.org>,
	<mike.kravetz@oracle.com>, <viro@zeniv.linux.org.uk>,
	<riandrews@android.com>, <arve@android.com>, <yishaih@mellanox.com>,
	<dledford@redhat.com>, <sean.hefty@intel.com>, <hal.rosenstock@gmail.com>,
	<matanb@mellanox.com>, <leonro@mellanox.com>,
	<linux-fsdevel@vger.kernel.org>, <linux-mm@kvack.org>,
	<devel@driverdev.osuosl.org>, <linux-rdma@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <stable@vger.kernel.org>,
	<akaher@vmware.com>, <srivatsab@vmware.com>, <amakhalov@vmware.com>, Linus
 Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>
Subject: [PATCH v3 1/2] [v4.9.y] coredump: fix race condition between mmget_not_zero()/get_task_mm() and core dumping
Date: Sat, 22 Jun 2019 18:32:17 +0530
Message-ID: <1561208539-29682-1-git-send-email-akaher@vmware.com>
X-Mailer: git-send-email 2.7.4
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-002.vmware.com: akaher@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

commit 04f5866e41fb70690e28397487d8bd8eea7d712a upstream.

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
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
[akaher@vmware.com: stable 4.9 backport
 -  handle binder_update_page_range - mhocko@suse.com]
Signed-off-by: Ajay Kaher <akaher@vmware.com>
---
 drivers/android/binder.c |  6 ++++++
 fs/proc/task_mmu.c       | 18 ++++++++++++++++++
 fs/userfaultfd.c         |  9 +++++++++
 include/linux/mm.h       | 21 +++++++++++++++++++++
 mm/mmap.c                |  6 +++++-
 5 files changed, 59 insertions(+), 1 deletion(-)

diff --git a/drivers/android/binder.c b/drivers/android/binder.c
index 80499f4..f05ab8f 100644
--- a/drivers/android/binder.c
+++ b/drivers/android/binder.c
@@ -581,6 +581,12 @@ static int binder_update_page_range(struct binder_proc *proc, int allocate,
 
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
index 5138e78..4b207b1 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1057,6 +1057,24 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 					count = -EINTR;
 					goto out_mm;
 				}
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
index 784d667..8bf425a 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -479,6 +479,8 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	 * taking the mmap_sem for writing.
 	 */
 	down_write(&mm->mmap_sem);
+	if (!mmget_still_valid(mm))
+		goto skip_mm;
 	prev = NULL;
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		cond_resched();
@@ -501,6 +503,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 		vma->vm_flags = new_flags;
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
 	}
+skip_mm:
 	up_write(&mm->mmap_sem);
 	mmput(mm);
 wakeup:
@@ -802,6 +805,9 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		goto out;
 
 	down_write(&mm->mmap_sem);
+	if (!mmget_still_valid(mm))
+		goto out_unlock;
+
 	vma = find_vma_prev(mm, start, &prev);
 	if (!vma)
 		goto out_unlock;
@@ -947,6 +953,9 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		goto out;
 
 	down_write(&mm->mmap_sem);
+	if (!mmget_still_valid(mm))
+		goto out_unlock;
+
 	vma = find_vma_prev(mm, start, &prev);
 	if (!vma)
 		goto out_unlock;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e3c8d40..c239984 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1189,6 +1189,27 @@ void zap_page_range(struct vm_area_struct *vma, unsigned long address,
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
index 3f2314a..19368fb 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2448,7 +2448,8 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 	vma = find_vma_prev(mm, addr, &prev);
 	if (vma && (vma->vm_start <= addr))
 		return vma;
-	if (!prev || expand_stack(prev, addr))
+	/* don't alter vm_end if the coredump is running */
+	if (!prev || !mmget_still_valid(mm) || expand_stack(prev, addr))
 		return NULL;
 	if (prev->vm_flags & VM_LOCKED)
 		populate_vma_page_range(prev, addr, prev->vm_end, NULL);
@@ -2474,6 +2475,9 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
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
2.7.4

