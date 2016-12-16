Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4A66B02BA
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:50:21 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id g187so21139907itc.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:50:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 35si6185828iol.81.2016.12.16.06.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:28 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 23/42] userfaultfd: hugetlbfs: userfaultfd_huge_must_wait for hugepmd ranges
Date: Fri, 16 Dec 2016 15:48:02 +0100
Message-Id: <20161216144821.5183-24-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

From: Mike Kravetz <mike.kravetz@oracle.com>

Add routine userfaultfd_huge_must_wait which has the same functionality as
the existing userfaultfd_must_wait routine.  Only difference is that new
routine must handle page table structure for hugepmd vmas.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 51 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 49 insertions(+), 2 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 1268496..92614c0 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -195,6 +195,49 @@ static inline struct uffd_msg userfault_msg(unsigned long address,
 	return msg;
 }
 
+#ifdef CONFIG_HUGETLB_PAGE
+/*
+ * Same functionality as userfaultfd_must_wait below with modifications for
+ * hugepmd ranges.
+ */
+static inline bool userfaultfd_huge_must_wait(struct userfaultfd_ctx *ctx,
+					 unsigned long address,
+					 unsigned long flags,
+					 unsigned long reason)
+{
+	struct mm_struct *mm = ctx->mm;
+	pte_t *pte;
+	bool ret = true;
+
+	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
+
+	pte = huge_pte_offset(mm, address);
+	if (!pte)
+		goto out;
+
+	ret = false;
+
+	/*
+	 * Lockless access: we're in a wait_event so it's ok if it
+	 * changes under us.
+	 */
+	if (huge_pte_none(*pte))
+		ret = true;
+	if (!huge_pte_write(*pte) && (reason & VM_UFFD_WP))
+		ret = true;
+out:
+	return ret;
+}
+#else
+static inline bool userfaultfd_huge_must_wait(struct userfaultfd_ctx *ctx,
+					 unsigned long address,
+					 unsigned long flags,
+					 unsigned long reason)
+{
+	return false;	/* should never get here */
+}
+#endif /* CONFIG_HUGETLB_PAGE */
+
 /*
  * Verify the pagetables are still not ok after having reigstered into
  * the fault_pending_wqh to avoid userland having to UFFDIO_WAKE any
@@ -368,8 +411,12 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 			  TASK_KILLABLE);
 	spin_unlock(&ctx->fault_pending_wqh.lock);
 
-	must_wait = userfaultfd_must_wait(ctx, vmf->address, vmf->flags,
-					  reason);
+	if (!is_vm_hugetlb_page(vmf->vma))
+		must_wait = userfaultfd_must_wait(ctx, vmf->address, vmf->flags,
+						  reason);
+	else
+		must_wait = userfaultfd_huge_must_wait(ctx, vmf->address,
+						       vmf->flags, reason);
 	up_read(&mm->mmap_sem);
 
 	if (likely(must_wait && !ACCESS_ONCE(ctx->released) &&

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
