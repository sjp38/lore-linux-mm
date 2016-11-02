Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 59D4D6B028E
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:39:47 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id d67so24959867qkc.0
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:39:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y44si1942504qta.20.2016.11.02.12.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:12 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 19/33] userfaultfd: hugetlbfs: userfaultfd_huge_must_wait for hugepmd ranges
Date: Wed,  2 Nov 2016 20:33:51 +0100
Message-Id: <1478115245-32090-20-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

From: Mike Kravetz <mike.kravetz@oracle.com>

Add routine userfaultfd_huge_must_wait which has the same functionality as
the existing userfaultfd_must_wait routine.  Only difference is that new
routine must handle page table structure for hugepmd vmas.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 50 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 49 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index a73e999..9552734 100644
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
@@ -367,7 +410,12 @@ int handle_userfault(struct fault_env *fe, unsigned long reason)
 			  TASK_KILLABLE);
 	spin_unlock(&ctx->fault_pending_wqh.lock);
 
-	must_wait = userfaultfd_must_wait(ctx, fe->address, fe->flags, reason);
+	if (!is_vm_hugetlb_page(fe->vma))
+		must_wait = userfaultfd_must_wait(ctx, fe->address, fe->flags,
+						  reason);
+	else
+		must_wait = userfaultfd_huge_must_wait(ctx, fe->address,
+						       fe->flags, reason);
 	up_read(&mm->mmap_sem);
 
 	if (likely(must_wait && !ACCESS_ONCE(ctx->released) &&

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
