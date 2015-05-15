Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9AB6B0070
	for <linux-mm@kvack.org>; Fri, 15 May 2015 12:04:49 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so42081135wic.1
        for <linux-mm@kvack.org>; Fri, 15 May 2015 09:04:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id mi6si4467089wic.25.2015.05.15.09.04.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 May 2015 09:04:47 -0700 (PDT)
Date: Fri, 15 May 2015 18:04:26 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 10/23] userfaultfd: add new syscall to provide memory
 externalization
Message-ID: <20150515160426.GD19097@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <1431624680-20153-11-git-send-email-aarcange@redhat.com>
 <CA+55aFwCODeiXUPDR7-Y-=2xE2abmVuCnmVV=ezFqhO+JkaW=A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwCODeiXUPDR7-Y-=2xE2abmVuCnmVV=ezFqhO+JkaW=A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, qemu-devel@nongnu.org, KVM list <kvm@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

On Thu, May 14, 2015 at 10:49:06AM -0700, Linus Torvalds wrote:
> On Thu, May 14, 2015 at 10:31 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > +static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
> > +                                          struct userfaultfd_wake_range *range)
> > +{
> > +       if (waitqueue_active(&ctx->fault_wqh))
> > +               __wake_userfault(ctx, range);
> > +}
> 
> Pretty much every single time people use this "if
> (waitqueue_active())" model, it tends to be a bug, because it means
> that there is zero serialization with people who are just about to go
> to sleep. It's fundamentally racy against all the "wait_event()" loops
> that carefully do memory barriers between testing conditions and going
> to sleep, because the memory barriers now don't exist on the waking
> side.

As far as 10/23 is concerned, the __wake_userfault taking the locks
would also ignore any "incoming" not yet "read(2)" userfault. "read(2)"
as in syscall read. So there was no race to worry about as "incoming"
userfaults would be ignored anyway by the wake.

The only case that had to be reliable in not missing wakeup events was
the "release" file operation. But that doesn't use waitqueue_active
and it relies on ctx->released combined with mmap_sem taken for writing.

    http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/tree/fs/userfaultfd.c?h=userfault&id=2f73ffa8267e41f04fe6b0d93d23feed45c0980a#n267

However later (after I started documenting what userland should do) I
started to question this old model of leaving the race handling to
userland. It's way too complex to leave the race handling to
userland. Furthermore it's inefficient because there would be lots of
spurious userfaults that we could have been waken up within the kernel
before userland could have a chance to read them.

So then I handled the race in the kernel in patch 17/23. That allowed
to drop hundres of line of locking code from qemu (two bits per page
and a mutex and lots of complexity) and then I didn't need to document
the complex rules described in this commit header:

     http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=5a2b3614e107482da9a1fcfcd120d30eb62d45dc

You can see from the patch it complicated the kernel by adding a
pagetable walk, but it's worth it because it's simpler than solving it
in userland, plus its solved at once for all users.

The only cons is that the old model would allow userland to be way
more consistent in enforcing asserts as it had the control.

With the current model POLLIN may be returned from poll() despite the
later read returns -EAGAIN, so it basically requires a non blocking
open if people uses poll(). (blocking reads without poll are still
fine)

Now back to your question: the waitqueue_active is still there in the
current model as well (since 17/23).

Since 17/23 losing a wakeup (as far as qemu is concerned) would mean
that qemu would read the address of the fault that didn't get waken up
because of the race, then it would send a page request to the source
node (it had no state in the destination node where the userfault runs
to know if it was a "dup"), which would discard the request (not
sending the page twice) noticing in its simple per-page bitmap that it
was already sent. So with the new model after 17/23 qemu, losing a
wakeup is a bug.

The wait_event is like this:

	handle_userfault (wait_event)
	-------
	spin_lock(&ctx->fault_pending_wqh.lock);
	/*
	 * After the __add_wait_queue the uwq is visible to userland
	 * through poll/read().
	 */
	__add_wait_queue(&ctx->fault_pending_wqh, &uwq.wq);
	/*
	 * The smp_mb() after __set_current_state prevents the reads
	 * following the spin_unlock to happen before the list_add in
	 * __add_wait_queue.
	 */
	set_current_state(TASK_KILLABLE);
	spin_unlock(&ctx->fault_pending_wqh.lock);

	must_wait = userfaultfd_must_wait(ctx, address, flags, reason);

	up_read(&mm->mmap_sem);

	if (likely(must_wait && !ACCESS_ONCE(ctx->released) &&
		   !fatal_signal_pending(current))) {
		wake_up_poll(&ctx->fd_wqh, POLLIN);
		schedule();

The wakeup side is:

	userfaultfd_copy
	-----------
	ret = mcopy_atomic(ctx->mm, uffdio_copy.dst, uffdio_copy.src,
			   uffdio_copy.len);
	if (unlikely(put_user(ret, &user_uffdio_copy->copy)))
		return -EFAULT;
	if (ret < 0)
		goto out;
	BUG_ON(!ret);
	/* len == 0 would wake all */
	range.len = ret;
	if (!(uffdio_copy.mode & UFFDIO_COPY_MODE_DONTWAKE)) {
		range.start = uffdio_copy.dst;
		wake_userfault(ctx, &range);


wake_userfault is the function that is using waitqueue_active so the
problem materializes if waitqueue_active moves before
mcopy_atomic. Precisely it should move before the set_pte_at below:

	mcopy_atomic_pte
	------
	set_pte_at(dst_mm, dst_addr, dst_pte, _dst_pte);

	/* No need to invalidate - it was non-present before */
	update_mmu_cache(dst_vma, dst_addr, dst_pte);

	pte_unmap_unlock(dst_pte, ptl);

unlock would allow the read to be reordered before it even on
x86. There's an up_read as well in between but it has the same
problem. So you're right that theoretically we can miss a wakeup.

Practically it sounds unlikely because of the sheer size of
mcopy_atomic and we never experienced it but it's still a bug.

>  So I'm making a new rule: if you use waitqueue_active(), I want an
> explanation for why it's not racy with the waiter. A big comment
> about the memory ordering, or about higher-level locks that are held
> by the caller, or something.  Linus

To fix it I added this along a comment:

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index c89e96f..6be316b 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -593,6 +593,21 @@ static void __wake_userfault(struct userfaultfd_ctx *ctx,
 static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
 					   struct userfaultfd_wake_range *range)
 {
+	/*
+	 * To be sure waitqueue_active() is not reordered by the CPU
+	 * before the pagetable update, use an explicit SMP memory
+	 * barrier here. PT lock release or up_read(mmap_sem) still
+	 * have release semantics that can allow the
+	 * waitqueue_active() to be reordered before the pte update.
+	 */
+	smp_mb();
+
+	/*
+	 * Use waitqueue_active because it's very frequent to
+	 * change the address space atomically even if there are no
+	 * userfaults yet. So we take the spinlock only when we're
+	 * sure we've userfaults to wake.
+	 */
 	if (waitqueue_active(&ctx->fault_pending_wqh) ||
 	    waitqueue_active(&ctx->fault_wqh))
 		__wake_userfault(ctx, range);

The wait_event/handle_userfault side already has a smp_mb() to prevent
the lockless pagetable walk to be reordered before the list_add in
__add_wait_queue (needed as well precisely because of the
waitqueue_active optimization that I'd like to keep).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
