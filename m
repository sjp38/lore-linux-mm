Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DE2AC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:49:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02D6A206C0
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:49:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02D6A206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FA426B000A; Mon, 25 Mar 2019 18:49:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A8946B000C; Mon, 25 Mar 2019 18:49:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7983A6B000D; Mon, 25 Mar 2019 18:49:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 547436B000A
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 18:49:57 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 18so11790043qtw.20
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 15:49:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=WJqenjV6sTNdbpabH13hu+FX29iH4QmvLGr4ornSV2w=;
        b=idSsxsWoBTbk//Fdv+bHnIFkem8AQ1A/QzzvOcZOAAF3fAFAhGjhMa731CPxWTUZ4p
         3ozdhZQojkeSJ5PuyAb+y2AJ3mk9R65LAweAGFiI0M5z/QeyyrhRHrI1yOMUxSPubX7U
         6dcXp/85tLKkkLhJF+GiFluT2l6e44yLlFZMU2CxoXnlJVe/XNVohsFXZ/MhpHyiW5jZ
         6W1bvQUWrQeoQi3tJdG1EC6lhhgpM/Gm5gPAcoHYRVhaC/IzkF/7bXcO6yvbvIoBpha6
         UaE58lk1l7iKHG4dOUAtFCbTH8qE4HgquLx4hTgvPUjOShVnT9BQwmnw5HzQsiN8EFHX
         4XbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWbmzPZMUwsf0nQDp0wF7BNanniIHf5BKst9YPNGNyh9BW4oQyX
	nl8I/2omMilnUq/fqOpW8oNAYUQ0zgGNVBWMYnmngzVFZCaDYvfNbNt4jj+aRfrWpyUjV/v1L1n
	V4frzIIeqv/NbJ7U32tzbrZlGmw9LhMsOSoCTkj+XAfKIIwnaEoFIwRA1/voNUayO7w==
X-Received: by 2002:a05:620a:15e7:: with SMTP id p7mr21017667qkm.283.1553554197034;
        Mon, 25 Mar 2019 15:49:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBXdO0AGmyLzO0uTek9ooi3PtLsvvO5AHlXhpENNH8ax3sk8wMf/Gm70cxdzrKlS5NmIjG
X-Received: by 2002:a05:620a:15e7:: with SMTP id p7mr21017609qkm.283.1553554195901;
        Mon, 25 Mar 2019 15:49:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553554195; cv=none;
        d=google.com; s=arc-20160816;
        b=P0bo8YxZJhxgvS6GhtcX/+iS6ktv1h4F0h3+Lxrv/zaD92GIDLYf/GP//P26i19Sdc
         UzE9LbusbujQkNA0Yx2ogk4mvv2SPj6iZjGhkqos94RKb4IiSVF+WNX50/ziBZGhcyG7
         1ei7H4fLVyIZEJxA0aPnCUStwVUs02KMhnD6c/skrq5VlwU+tOH+G45jjqw9JnxFtbVK
         rHtNu437eOTRKBQBvWGTvQe3lPGKqBLY6lLJrlT7ah0kDdiUiapxYwVKasCf9H1FOcuP
         FOkHFOG9aaSGTT04CKKZLQ3TQauOfxXQcDijw+c/lCAhNuB5zGYL1Y0gGAXCn7O3fVDy
         iAmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=WJqenjV6sTNdbpabH13hu+FX29iH4QmvLGr4ornSV2w=;
        b=Z/UhOECNaQw9Lcbrv8FELhAsD6sZzdVHEf/3cphDhiXtPkPCHmJ/IS29ClA4XO5qL2
         QFDD9IhFIg0K+Bw5nBhe2Fbqdltq4ea93xPjfOuktYrLORAziv/wwqmJ16npCCYp2jck
         CbfWVzel2poxpKITqmiGWP36BlUZaZ7LAK3KYshdK6m+QGusp5waf/+eDoHxO+LDyue2
         8OULD76pABHHBHT+w5jmlIqYUrVqCoCdy7Hoz/NohNjlMRp3H4RpHKPdgpPLb68/cQd8
         V6d3tnpHobppgqnJkF3akdm2StKuyUjN8cA6tU2iqTwfyq8lXiA38X7DmZp7v6yI+j96
         ZWug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c2si1892994qkf.260.2019.03.25.15.49.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 15:49:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C34EF30842B3;
	Mon, 25 Mar 2019 22:49:54 +0000 (UTC)
Received: from sky.random (ovpn-120-118.rdu2.redhat.com [10.10.120.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 549E560CD0;
	Mon, 25 Mar 2019 22:49:50 +0000 (UTC)
From: Andrea Arcangeli <aarcange@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	Oleg Nesterov <oleg@redhat.com>,
	Jann Horn <jannh@google.com>,
	Hugh Dickins <hughd@google.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Peter Xu <peterx@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH 1/1] coredump: fix race condition between mmget_not_zero()/get_task_mm() and core dumping
Date: Mon, 25 Mar 2019 18:49:49 -0400
Message-Id: <20190325224949.11068-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Mon, 25 Mar 2019 22:49:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The core dumping code has always run without holding the mmap_sem for
writing, despite that is the only way to ensure that the entire vma
layout will not change from under it. Only using some signal
serialization on the processes belonging to the mm is not nearly
enough. This was pointed out earlier. For example in Hugh's post from
Jul 2017:

https://lkml.kernel.org/r/alpine.LSU.2.11.1707191716030.2055@eggly.anvils

"Not strictly relevant here, but a related note: I was very surprised
to discover, only quite recently, how handle_mm_fault() may be called
without down_read(mmap_sem) - when core dumping.  That seems a
misguided optimization to me, which would also be nice to correct"

In particular because the growsdown and growsup can move the
vm_start/vm_end the various loops the core dump does around the vma
will not be consistent if page faults can happen concurrently.

Pretty much all users calling mmget_not_zero()/get_task_mm() and then
taking the mmap_sem had the potential to introduce unexpected side
effects in the core dumping code.

Adding mmap_sem for writing around the ->core_dump invocation is a
viable long term fix, but it requires removing all copy user and page
faults and to replace them with get_dump_page() for all binary formats
which is not suitable as a short term fix.

For the time being this solution manually covers the places that can
confuse the core dump either by altering the vma layout or the vma
flags while it runs. Once ->core_dump runs under mmap_sem for writing
the function mmget_still_valid() can be dropped.

Allowing mmap_sem protected sections to run in parallel with the
coredump provides some minor parallelism advantage to the swapoff
code (which seems to be safe enough by never mangling any vma field
and can keep doing swapins in parallel to the core dumping) and to
some other corner case.

In order to facilitate the backporting I added "Fixes: 86039bd3b4e6"
however the side effect of this same race condition in /proc/pid/mem
should be reproducible since before commit
1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 so I couldn't add any other
"Fixes:" because there's no hash beyond the git genesis commit.

Because find_extend_vma() is the only location outside of the process
context that could modify the "mm" structures under mmap_sem for
reading, by adding the mmget_still_valid() check to it, all other
cases that take the mmap_sem for reading don't need the new check
after mmget_not_zero()/get_task_mm(). The expand_stack() in page fault
context also doesn't need the new check, because all tasks under core
dumping are frozen.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: Jann Horn <jannh@google.com>
Suggested-by: Oleg Nesterov <oleg@redhat.com>
Fixes: 86039bd3b4e6 ("userfaultfd: add new syscall to provide memory externalization")
Cc: stable@kernel.org
Acked-by: Peter Xu <peterx@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
Reviewed-by: Oleg Nesterov <oleg@redhat.com>
Reviewed-by: Jann Horn <jannh@google.com>
---
 drivers/infiniband/core/uverbs_main.c |  3 +++
 fs/proc/task_mmu.c                    | 18 ++++++++++++++++++
 fs/userfaultfd.c                      |  9 +++++++++
 include/linux/sched/mm.h              | 21 +++++++++++++++++++++
 mm/mmap.c                             |  7 ++++++-
 5 files changed, 57 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/core/uverbs_main.c b/drivers/infiniband/core/uverbs_main.c
index 70b7d80431a9..f2e7ffe6fc54 100644
--- a/drivers/infiniband/core/uverbs_main.c
+++ b/drivers/infiniband/core/uverbs_main.c
@@ -993,6 +993,8 @@ void uverbs_user_mmap_disassociate(struct ib_uverbs_file *ufile)
 		 * will only be one mm, so no big deal.
 		 */
 		down_write(&mm->mmap_sem);
+		if (!mmget_still_valid(mm))
+			goto skip_mm;
 		mutex_lock(&ufile->umap_lock);
 		list_for_each_entry_safe (priv, next_priv, &ufile->umaps,
 					  list) {
@@ -1007,6 +1009,7 @@ void uverbs_user_mmap_disassociate(struct ib_uverbs_file *ufile)
 			vma->vm_flags &= ~(VM_SHARED | VM_MAYSHARE);
 		}
 		mutex_unlock(&ufile->umap_lock);
+	skip_mm:
 		up_write(&mm->mmap_sem);
 		mmput(mm);
 	}
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 92a91e7816d8..95ca1fe7283c 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1143,6 +1143,24 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
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
index 89800fc7dc9d..f5de1e726356 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -629,6 +629,8 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 
 		/* the various vma->vm_userfaultfd_ctx still points to it */
 		down_write(&mm->mmap_sem);
+		/* no task can run (and in turn coredump) yet */
+		VM_WARN_ON(!mmget_still_valid(mm));
 		for (vma = mm->mmap; vma; vma = vma->vm_next)
 			if (vma->vm_userfaultfd_ctx.ctx == release_new_ctx) {
 				vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
@@ -883,6 +885,8 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	 * taking the mmap_sem for writing.
 	 */
 	down_write(&mm->mmap_sem);
+	if (!mmget_still_valid(mm))
+		goto skip_mm;
 	prev = NULL;
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		cond_resched();
@@ -905,6 +909,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 		vma->vm_flags = new_flags;
 		vma->vm_userfaultfd_ctx = NULL_VM_UFFD_CTX;
 	}
+skip_mm:
 	up_write(&mm->mmap_sem);
 	mmput(mm);
 wakeup:
@@ -1333,6 +1338,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		goto out;
 
 	down_write(&mm->mmap_sem);
+	if (!mmget_still_valid(mm))
+		goto out_unlock;
 	vma = find_vma_prev(mm, start, &prev);
 	if (!vma)
 		goto out_unlock;
@@ -1520,6 +1527,8 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		goto out;
 
 	down_write(&mm->mmap_sem);
+	if (!mmget_still_valid(mm))
+		goto out_unlock;
 	vma = find_vma_prev(mm, start, &prev);
 	if (!vma)
 		goto out_unlock;
diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
index 0cd9f10423fb..a3fda9f024c3 100644
--- a/include/linux/sched/mm.h
+++ b/include/linux/sched/mm.h
@@ -49,6 +49,27 @@ static inline void mmdrop(struct mm_struct *mm)
 		__mmdrop(mm);
 }
 
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
  * mmget() - Pin the address space associated with a &struct mm_struct.
  * @mm: The address space to pin.
diff --git a/mm/mmap.c b/mm/mmap.c
index 41eb48d9b527..bd7b9f293b39 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -45,6 +45,7 @@
 #include <linux/moduleparam.h>
 #include <linux/pkeys.h>
 #include <linux/oom.h>
+#include <linux/sched/mm.h>
 
 #include <linux/uaccess.h>
 #include <asm/cacheflush.h>
@@ -2525,7 +2526,8 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 	vma = find_vma_prev(mm, addr, &prev);
 	if (vma && (vma->vm_start <= addr))
 		return vma;
-	if (!prev || expand_stack(prev, addr))
+	/* don't alter vm_end if the coredump is running */
+	if (!prev || !mmget_still_valid(mm) || expand_stack(prev, addr))
 		return NULL;
 	if (prev->vm_flags & VM_LOCKED)
 		populate_vma_page_range(prev, addr, prev->vm_end, NULL);
@@ -2551,6 +2553,9 @@ find_extend_vma(struct mm_struct *mm, unsigned long addr)
 		return vma;
 	if (!(vma->vm_flags & VM_GROWSDOWN))
 		return NULL;
+	/* don't alter vm_start if the coredump is running */
+	if (!mmget_still_valid(mm))
+		return NULL;
 	start = vma->vm_start;
 	if (expand_stack(vma, addr))
 		return NULL;

