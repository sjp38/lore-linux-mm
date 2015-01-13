Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 216D36B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 11:38:50 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so22539328wib.4
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 08:38:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id en7si4864606wib.96.2015.01.13.08.38.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jan 2015 08:38:49 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 5/5] mm: gup: kvm use get_user_pages_unlocked
Date: Tue, 13 Jan 2015 17:37:54 +0100
Message-Id: <1421167074-9789-6-git-send-email-aarcange@redhat.com>
In-Reply-To: <1421167074-9789-1-git-send-email-aarcange@redhat.com>
References: <1421167074-9789-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Feiner <pfeiner@google.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

Use the more generic get_user_pages_unlocked which has the additional
benefit of passing FAULT_FLAG_ALLOW_RETRY at the very first page fault
(which allows the first page fault in an unmapped area to be always
able to block indefinitely by being allowed to release the mmap_sem).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/kvm_host.h | 11 -----------
 virt/kvm/async_pf.c      |  2 +-
 virt/kvm/kvm_main.c      | 50 ++++--------------------------------------------
 3 files changed, 5 insertions(+), 58 deletions(-)

diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index 26f1060..d189ee0 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -200,17 +200,6 @@ int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, unsigned long hva,
 int kvm_async_pf_wakeup_all(struct kvm_vcpu *vcpu);
 #endif
 
-/*
- * Carry out a gup that requires IO. Allow the mm to relinquish the mmap
- * semaphore if the filemap/swap has to wait on a page lock. pagep == NULL
- * controls whether we retry the gup one more time to completion in that case.
- * Typically this is called after a FAULT_FLAG_RETRY_NOWAIT in the main tdp
- * handler.
- */
-int kvm_get_user_page_io(struct task_struct *tsk, struct mm_struct *mm,
-			 unsigned long addr, bool write_fault,
-			 struct page **pagep);
-
 enum {
 	OUTSIDE_GUEST_MODE,
 	IN_GUEST_MODE,
diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index 5ff7f7f..44660ae 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -80,7 +80,7 @@ static void async_pf_execute(struct work_struct *work)
 
 	might_sleep();
 
-	kvm_get_user_page_io(NULL, mm, addr, 1, NULL);
+	get_user_pages_unlocked(NULL, mm, addr, 1, 1, 0, NULL);
 	kvm_async_page_present_sync(vcpu, apf);
 
 	spin_lock(&vcpu->async_pf.lock);
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 1cc6e2e..458b9b1 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1128,43 +1128,6 @@ static int get_user_page_nowait(struct task_struct *tsk, struct mm_struct *mm,
 	return __get_user_pages(tsk, mm, start, 1, flags, page, NULL, NULL);
 }
 
-int kvm_get_user_page_io(struct task_struct *tsk, struct mm_struct *mm,
-			 unsigned long addr, bool write_fault,
-			 struct page **pagep)
-{
-	int npages;
-	int locked = 1;
-	int flags = FOLL_TOUCH | FOLL_HWPOISON |
-		    (pagep ? FOLL_GET : 0) |
-		    (write_fault ? FOLL_WRITE : 0);
-
-	/*
-	 * If retrying the fault, we get here *not* having allowed the filemap
-	 * to wait on the page lock. We should now allow waiting on the IO with
-	 * the mmap semaphore released.
-	 */
-	down_read(&mm->mmap_sem);
-	npages = __get_user_pages(tsk, mm, addr, 1, flags, pagep, NULL,
-				  &locked);
-	if (!locked) {
-		VM_BUG_ON(npages);
-
-		if (!pagep)
-			return 0;
-
-		/*
-		 * The previous call has now waited on the IO. Now we can
-		 * retry and complete. Pass TRIED to ensure we do not re
-		 * schedule async IO (see e.g. filemap_fault).
-		 */
-		down_read(&mm->mmap_sem);
-		npages = __get_user_pages(tsk, mm, addr, 1, flags | FOLL_TRIED,
-					  pagep, NULL, NULL);
-	}
-	up_read(&mm->mmap_sem);
-	return npages;
-}
-
 static inline int check_user_page_hwpoison(unsigned long addr)
 {
 	int rc, flags = FOLL_TOUCH | FOLL_HWPOISON | FOLL_WRITE;
@@ -1227,15 +1190,10 @@ static int hva_to_pfn_slow(unsigned long addr, bool *async, bool write_fault,
 		npages = get_user_page_nowait(current, current->mm,
 					      addr, write_fault, page);
 		up_read(&current->mm->mmap_sem);
-	} else {
-		/*
-		 * By now we have tried gup_fast, and possibly async_pf, and we
-		 * are certainly not atomic. Time to retry the gup, allowing
-		 * mmap semaphore to be relinquished in the case of IO.
-		 */
-		npages = kvm_get_user_page_io(current, current->mm, addr,
-					      write_fault, page);
-	}
+	} else
+		npages = __get_user_pages_unlocked(current, current->mm, addr, 1,
+						   write_fault, 0, page,
+						   FOLL_TOUCH|FOLL_HWPOISON);
 	if (npages != 1)
 		return npages;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
