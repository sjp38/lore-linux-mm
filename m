Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id D852C6B003A
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 12:51:35 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id l18so1059214wgh.6
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 09:51:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j4si32575012wja.141.2014.07.02.09.51.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jul 2014 09:51:34 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 10/10] userfaultfd: use VM_FAULT_RETRY in handle_userfault()
Date: Wed,  2 Jul 2014 18:50:16 +0200
Message-Id: <1404319816-30229-11-git-send-email-aarcange@redhat.com>
In-Reply-To: <1404319816-30229-1-git-send-email-aarcange@redhat.com>
References: <1404319816-30229-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Paolo Bonzini <pbonzini@redhat.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>, Mel Gorman <mgorman@suse.de>

This optimizes the userfault handler to repeat the fault without
returning to userland if it's a page faults and it teaches it to
handle FOLL_NOWAIT if it's a nonblocking gup invocation from KVM. The
FOLL_NOWAIT part is actually more than an optimization because if
FOLL_NOWAIT is set the gup caller assumes the mmap_sem cannot be
released (and it could assume that the structures protected by it
potentially read earlier cannot have become stale).

The locking rules to comply with FAULT_FLAG_KILLABLE,
FAULT_FLAG_ALLOW_RETRY, FAULT_FLAG_RETRY_NOWAIT flags looks quite
convoluted (and nor well documented, aside from a "Caution" comment in
__lock_page_or_retry) so this is not a trivial change and in turn it's
kept incremental at the end of the patchset.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c            | 68 ++++++++++++++++++++++++++++++++++++++++++---
 include/linux/userfaultfd.h |  6 ++--
 mm/huge_memory.c            |  8 +++---
 mm/memory.c                 |  4 +--
 4 files changed, 74 insertions(+), 12 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index deed8cb..b8b0fb7 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -155,12 +155,29 @@ static void userfaultfd_ctx_put(struct userfaultfd_ctx *ctx)
 	kref_put(&ctx->kref, userfaultfd_free);
 }
 
-int handle_userfault(struct vm_area_struct *vma, unsigned long address)
+/*
+ * The locking rules involved in returning VM_FAULT_RETRY depending on
+ * FAULT_FLAG_ALLOW_RETRY, FAULT_FLAG_RETRY_NOWAIT and
+ * FAULT_FLAG_KILLABLE are not straightforward. The "Caution"
+ * recommendation in __lock_page_or_retry is not an understatement.
+ *
+ * If FAULT_FLAG_ALLOW_RETRY is set, the mmap_sem must be released
+ * before returning VM_FAULT_RETRY only if FAULT_FLAG_RETRY_NOWAIT is
+ * not set.
+ *
+ * If FAULT_FLAG_ALLOW_RETRY is set but FAULT_FLAG_KILLABLE is not
+ * set, VM_FAULT_RETRY can still be returned if and only if there are
+ * fatal_signal_pending()s, and the mmap_sem must be released before
+ * returning it.
+ */
+int handle_userfault(struct vm_area_struct *vma, unsigned long address,
+		     unsigned int flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct mm_slot *slot;
 	struct userfaultfd_ctx *ctx;
 	struct userfaultfd_wait_queue uwq;
+	int ret;
 
 	BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
 
@@ -188,10 +205,53 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address)
 	__add_wait_queue(&ctx->fault_wqh, &uwq.wq);
 	for (;;) {
 		set_current_state(TASK_INTERRUPTIBLE);
-		if (fatal_signal_pending(current))
+		if (fatal_signal_pending(current) || ctx->released) {
+			/*
+			 * If we have to fail because the task is
+			 * killed or the file was relased, so simulate
+			 * VM_FAULT_SIGBUS or just return to userland
+			 * through VM_FAULT_RETRY if we come from a
+			 * page fault.
+			 */
+			ret = VM_FAULT_SIGBUS;
+			if (fatal_signal_pending(current) &&
+			    (flags & FAULT_FLAG_KILLABLE)) {
+				/*
+				 * If FAULT_FLAG_KILLABLE is set we
+				 * and there's a fatal signal pending
+				 * can return VM_FAULT_RETRY
+				 * regardless if
+				 * FAULT_FLAG_ALLOW_RETRY is set or
+				 * not as long as we release the
+				 * mmap_sem. The page fault will
+				 * return stright to userland then to
+				 * handle the fatal signal.
+				 */
+				up_read(&mm->mmap_sem);
+				ret = VM_FAULT_RETRY;
+			}
+			break;
+		}
+		if (!uwq.pending) {
+			ret = 0;
+			if (flags & FAULT_FLAG_ALLOW_RETRY) {
+				ret = VM_FAULT_RETRY;
+				if (!(flags & FAULT_FLAG_RETRY_NOWAIT))
+					up_read(&mm->mmap_sem);
+			}
 			break;
-		if (!uwq.pending)
+		}
+		if (((FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT) &
+		     flags) ==
+		    (FAULT_FLAG_ALLOW_RETRY|FAULT_FLAG_RETRY_NOWAIT)) {
+			ret = VM_FAULT_RETRY;
+			/*
+			 * The mmap_sem must not be released if
+			 * FAULT_FLAG_RETRY_NOWAIT is set despite we
+			 * return VM_FAULT_RETRY (FOLL_NOWAIT case).
+			 */
 			break;
+		}
 		spin_unlock(&ctx->fault_wqh.lock);
 		up_read(&mm->mmap_sem);
 
@@ -211,7 +271,7 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address)
 	 */
 	userfaultfd_ctx_put(ctx);
 
-	return 0;
+	return ret;
 }
 
 static int userfaultfd_release(struct inode *inode, struct file *file)
diff --git a/include/linux/userfaultfd.h b/include/linux/userfaultfd.h
index 8200a71..b7caef5 100644
--- a/include/linux/userfaultfd.h
+++ b/include/linux/userfaultfd.h
@@ -26,11 +26,13 @@
 
 #ifdef CONFIG_USERFAULTFD
 
-int handle_userfault(struct vm_area_struct *vma, unsigned long address);
+int handle_userfault(struct vm_area_struct *vma, unsigned long address,
+		     unsigned int flags);
 
 #else /* CONFIG_USERFAULTFD */
 
-static int handle_userfault(struct vm_area_struct *vma, unsigned long address)
+static int handle_userfault(struct vm_area_struct *vma, unsigned long address,
+			    unsigned int flags)
 {
 	return VM_FAULT_SIGBUS;
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d6efd80..e1a74a2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -714,7 +714,7 @@ static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
 static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long haddr, pmd_t *pmd,
-					struct page *page)
+					struct page *page, unsigned int flags)
 {
 	pgtable_t pgtable;
 	spinlock_t *ptl;
@@ -753,7 +753,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 			mem_cgroup_uncharge_page(page);
 			put_page(page);
 			pte_free(mm, pgtable);
-			ret = handle_userfault(vma, haddr);
+			ret = handle_userfault(vma, haddr, flags);
 			VM_BUG_ON(ret & VM_FAULT_FALLBACK);
 			return ret;
 		}
@@ -835,7 +835,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (pmd_none(*pmd)) {
 			if (vma->vm_flags & VM_USERFAULT) {
 				spin_unlock(ptl);
-				ret = handle_userfault(vma, haddr);
+				ret = handle_userfault(vma, haddr, flags);
 				VM_BUG_ON(ret & VM_FAULT_FALLBACK);
 			} else {
 				set_huge_zero_page(pgtable, mm, vma,
@@ -863,7 +863,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		count_vm_event(THP_FAULT_FALLBACK);
 		return VM_FAULT_FALLBACK;
 	}
-	return __do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page);
+	return __do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page, flags);
 }
 
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
diff --git a/mm/memory.c b/mm/memory.c
index a6a04ed..44506e9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2645,7 +2645,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		/* Deliver the page fault to userland, check inside PT lock */
 		if (vma->vm_flags & VM_USERFAULT) {
 			pte_unmap_unlock(page_table, ptl);
-			return handle_userfault(vma, address);
+			return handle_userfault(vma, address, flags);
 		}
 		goto setpte;
 	}
@@ -2679,7 +2679,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		pte_unmap_unlock(page_table, ptl);
 		mem_cgroup_uncharge_page(page);
 		page_cache_release(page);
-		return handle_userfault(vma, address);
+		return handle_userfault(vma, address, flags);
 	}
 
 	inc_mm_counter_fast(mm, MM_ANONPAGES);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
