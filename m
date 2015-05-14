Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 602616B008C
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:31:38 -0400 (EDT)
Received: by qkgw4 with SMTP id w4so13796616qkg.3
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:31:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l35si2439237qgd.62.2015.05.14.10.31.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:31:29 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 17/23] userfaultfd: solve the race between UFFDIO_COPY|ZEROPAGE and read
Date: Thu, 14 May 2015 19:31:14 +0200
Message-Id: <1431624680-20153-18-git-send-email-aarcange@redhat.com>
In-Reply-To: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

Solve in-kernel the race between UFFDIO_COPY|ZEROPAGE and
userfaultfd_read if they are run on different threads simultaneously.

Until now qemu solved the race in userland: the race was explicitly
and intentionally left for userland to solve. However we can also
solve it in kernel.

Requiring all users to solve this race if they use two threads (one
for the background transfer and one for the userfault reads) isn't
very attractive from an API prospective, furthermore this allows to
remove a whole bunch of mutex and bitmap code from qemu, making it
faster. The cost of __get_user_pages_fast should be insignificant
considering it scales perfectly and the pagetables are already hot in
the CPU cache, compared to the overhead in userland to maintain those
structures.

Applying this patch is backwards compatible with respect to the
userfaultfd userland API, however reverting this change wouldn't be
backwards compatible anymore.

Without this patch qemu in the background transfer thread, has to read
the old state, and do UFFDIO_WAKE if old_state is missing but it
become REQUESTED by the time it tries to set it to RECEIVED (signaling
the other side received an userfault).

    vcpu                background_thr userfault_thr
    -----               -----          -----
    vcpu0 handle_mm_fault()

			postcopy_place_page
			read old_state -> MISSING
 			UFFDIO_COPY 0x7fb76a139000 (no wakeup, still pending)

    vcpu0 fault at 0x7fb76a139000 enters handle_userfault
    poll() is kicked

 					poll() -> POLLIN
 					read() -> 0x7fb76a139000
 					postcopy_pmi_change_state(MISSING, REQUESTED) -> REQUESTED

 			tmp_state = postcopy_pmi_change_state(old_state, RECEIVED) -> REQUESTED
			/* check that no userfault raced with UFFDIO_COPY */
			if (old_state == MISSING && tmp_state == REQUESTED)
				UFFDIO_WAKE from background thread

And a second case where a UFFDIO_WAKE would be needed is in the userfault thread:

    vcpu                background_thr userfault_thr
    -----               -----          -----
    vcpu0 handle_mm_fault()

			postcopy_place_page
			read old_state -> MISSING
 			UFFDIO_COPY 0x7fb76a139000 (no wakeup, still pending)
 			tmp_state = postcopy_pmi_change_state(old_state, RECEIVED) -> RECEIVED

    vcpu0 fault at 0x7fb76a139000 enters handle_userfault
    poll() is kicked

 					poll() -> POLLIN
 					read() -> 0x7fb76a139000

 					if (postcopy_pmi_change_state(MISSING, REQUESTED) == RECEIVED)
						UFFDIO_WAKE from userfault thread

This patch removes the need of both UFFDIO_WAKE and of the associated
per-page tristate as well.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 81 +++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 66 insertions(+), 15 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 5542fe7..6772c22 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -167,6 +167,67 @@ static inline struct uffd_msg userfault_msg(unsigned long address,
 }
 
 /*
+ * Verify the pagetables are still not ok after having reigstered into
+ * the fault_pending_wqh to avoid userland having to UFFDIO_WAKE any
+ * userfault that has already been resolved, if userfaultfd_read and
+ * UFFDIO_COPY|ZEROPAGE are being run simultaneously on two different
+ * threads.
+ */
+static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
+					 unsigned long address,
+					 unsigned long flags,
+					 unsigned long reason)
+{
+	struct mm_struct *mm = ctx->mm;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd, _pmd;
+	pte_t *pte;
+	bool ret = true;
+
+	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
+
+	pgd = pgd_offset(mm, address);
+	if (!pgd_present(*pgd))
+		goto out;
+	pud = pud_offset(pgd, address);
+	if (!pud_present(*pud))
+		goto out;
+	pmd = pmd_offset(pud, address);
+	/*
+	 * READ_ONCE must function as a barrier with narrower scope
+	 * and it must be equivalent to:
+	 *	_pmd = *pmd; barrier();
+	 *
+	 * This is to deal with the instability (as in
+	 * pmd_trans_unstable) of the pmd.
+	 */
+	_pmd = READ_ONCE(*pmd);
+	if (!pmd_present(_pmd))
+		goto out;
+
+	ret = false;
+	if (pmd_trans_huge(_pmd))
+		goto out;
+
+	/*
+	 * the pmd is stable (as in !pmd_trans_unstable) so we can re-read it
+	 * and use the standard pte_offset_map() instead of parsing _pmd.
+	 */
+	pte = pte_offset_map(pmd, address);
+	/*
+	 * Lockless access: we're in a wait_event so it's ok if it
+	 * changes under us.
+	 */
+	if (pte_none(*pte))
+		ret = true;
+	pte_unmap(pte);
+
+out:
+	return ret;
+}
+
+/*
  * The locking rules involved in returning VM_FAULT_RETRY depending on
  * FAULT_FLAG_ALLOW_RETRY, FAULT_FLAG_RETRY_NOWAIT and
  * FAULT_FLAG_KILLABLE are not straightforward. The "Caution"
@@ -188,6 +249,7 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 	struct userfaultfd_ctx *ctx;
 	struct userfaultfd_wait_queue uwq;
 	int ret;
+	bool must_wait;
 
 	BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
 
@@ -247,9 +309,6 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 	/* take the reference before dropping the mmap_sem */
 	userfaultfd_ctx_get(ctx);
 
-	/* be gentle and immediately relinquish the mmap_sem */
-	up_read(&mm->mmap_sem);
-
 	init_waitqueue_func_entry(&uwq.wq, userfaultfd_wake_function);
 	uwq.wq.private = current;
 	uwq.msg = userfault_msg(address, flags, reason);
@@ -269,7 +328,10 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 	set_current_state(TASK_KILLABLE);
 	spin_unlock(&ctx->fault_pending_wqh.lock);
 
-	if (likely(!ACCESS_ONCE(ctx->released) &&
+	must_wait = userfaultfd_must_wait(ctx, address, flags, reason);
+	up_read(&mm->mmap_sem);
+
+	if (likely(must_wait && !ACCESS_ONCE(ctx->released) &&
 		   !fatal_signal_pending(current))) {
 		wake_up_poll(&ctx->fd_wqh, POLLIN);
 		schedule();
@@ -845,17 +907,6 @@ out:
 }
 
 /*
- * userfaultfd_wake is needed in case an userfault is in flight by the
- * time a UFFDIO_COPY (or other ioctl variants) completes. The page
- * may be well get mapped and the page fault if repeated wouldn't lead
- * to a userfault anymore, but before scheduling in TASK_KILLABLE mode
- * handle_userfault() doesn't recheck the pagetables and it doesn't
- * serialize against UFFDO_COPY (or other ioctl variants). Ultimately
- * the knowledge of which pages are mapped is left to userland who is
- * responsible for handling the race between read() userfaults and
- * background UFFDIO_COPY (or other ioctl variants), if done by
- * separate concurrent threads.
- *
  * userfaultfd_wake may be used in combination with the
  * UFFDIO_*_MODE_DONTWAKE to wakeup userfaults in batches.
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
