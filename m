Date: Wed, 23 Apr 2008 17:59:40 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080423155940.GY24536@duo.random>
References: <ea87c15371b1bd49380c.1208872277@duo.random> <Pine.LNX.4.64.0804221315160.3640@schroedinger.engr.sgi.com> <20080422223545.GP24536@duo.random> <20080422230727.GR30298@sgi.com> <20080423133619.GV24536@duo.random> <20080423144747.GU30298@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423144747.GU30298@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 09:47:47AM -0500, Robin Holt wrote:
> It also makes the API consistent.  What you are proposing is equivalent
> to having a file you can open but never close.

That's not entirely true, you can close the file just fine it by
killing the tasks leading to an mmput. From an user prospective in KVM
terms, it won't make a difference as /dev/kvm will remain open and
it'll pin the module count until the kvm task is killed anyway, I
assume for GRU it's similar.

Until I had the idea of how to implement an mm_lock to ensure the
mmu_notifier_register could miss a running invalidate_range_begin, it
wasn't even possible to implement a mmu_notifier_unregister (see EMM
patches) and it looked like you were ok with that API that missed
_unregister...

> This whole discussion seems ludicrous.  You could refactor the code to get
> the sorted list of locks, pass that list into mm_lock to do the locking,
> do the register/unregister, then pass the same list into mm_unlock.

Correct, but it will keep the vmalloc ram pinned during the
runtime. There's no reason to keep that ram allocated per-VM while the
VM runs. We only need it during the startup and teardown.

> If the allocation fails, you could fall back to the older slower method
> of repeatedly scanning the lists and acquiring locks in ascending order.

Correct, I already thought about that. This is exactly why I'm
deferring this for later! Or those perfectionism not needed for
KVM/GRU will keep delaying indefinitely the part that is already
converged and that's enough for KVM and GRU (and for this specific
bit, actually enough for XPMEM as well).

We can make a second version of mm_lock_slow to use if mm_lock fails,
in mmu_notifier_unregister, with N^2 complexity later, after the
mmu-notifier-core is merged into mainline.

> If you are not going to provide the _unregister callout you need to change
> the API so I can scan the list of notifiers to see if my structures are
> already registered.

As said 1/N isn't enough for XPMEM anyway. 1/N has to only include the
absolute minimum and zero risk stuff, that is enough for both KVM and
GRU.

> We register our notifier structure at device open time.  If we receive a
> _release callout, we mark our structure as unregistered.  At device close
> time, if we have not been unregistered, we call _unregister.  If you
> take away _unregister, I have an xpmem kernel structure in use _AFTER_
> the device is closed with no indication that the process is using it.
> In that case, I need to get an extra reference to the module in my device
> open method and hold that reference until the _release callout.

Yes exactly, but you've to do that anyway, if mmu_notifier_unregister
fails because some driver already allocated all vmalloc space (even
x86-64 hasn't indefinite amount of vmalloc because of the vmalloc
being in the end of the address space) unless we've a N^2 fallback,
but the N^2 fallback will make the code more easily dosable and
unkillable, so if I would be an admin I'd prefer having to quickly
kill -9 a task in O(N) than having to wait some syscall that runs in
O(N^2) to complete before the task quits. So the fallback to a slower
algorithm isn't necessarily what will really happen after 2.6.26 is
released, we'll see. Relaying on ->release for the module unpin sounds
preferable, and it's certainly the only reliable way to unregister
that we'll provide in 2.6.26.

> Additionally, if the users program reopens the device, I need to scan the
> mmu_notifiers list to see if this tasks notifier is already registered.

But you don't need any browse the list for this, keep a flag in your
structure after the mmu_notifier struct, set the bitflag after
mmu_notifier_register returns, and clear the bitflag after ->release
runs or after mmu_notifier_unregister returns success. What's the big
deal to track if you've to call mmu_notifier_register a second time or
not? Or you can create a new structure every time somebody asks to
reattach.

> I view _unregister as essential.  Did I miss something?

We can add it later, and we can keep discussing on what's the best
model to implement it as long as you want after 2.6.26 is released
with mmu-notifier-core so GRU/KVM are done. It's unlikely KVM will use
mmu_notifier_unregister anyway as we need it attached for the whole
lifetime of the task, and only for the lifetime of the task.

This is the patch to add it, as you can see it's entirely orthogonal,
backwards compatible with previous API and it doesn't duplicate or
rewrite any code.

Don't worry, any kernel after 2.6.26 will have unregister, but we can't
focus on this for 2.6.26. We can also consider making
mmu_notifier_register safe against double calls on the same structure
but again that's not something we should be doing in 1/N and it can be
done later in a backwards compatible way (plus we're perfectly fine
with the API having not backwards compatible changes as long as 2.6.26
can work for us).

---------------------------------
Implement unregister but it's not reliable, only ->release is reliable.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -119,6 +119,8 @@
 
 extern int mmu_notifier_register(struct mmu_notifier *mn,
 				 struct mm_struct *mm);
+extern int mmu_notifier_unregister(struct mmu_notifier *mn,
+				   struct mm_struct *mm);
 extern void __mmu_notifier_release(struct mm_struct *mm);
 extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 					  unsigned long address);
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -106,3 +106,29 @@
 	return ret;
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_register);
+
+/*
+ * mm_users can't go down to zero while mmu_notifier_unregister()
+ * runs or it can race with ->release. So a mm_users pin must
+ * be taken by the caller (if mm can be different from current->mm).
+ *
+ * This function can fail (for example during out of memory conditions
+ * or after vmalloc virtual range shortage), so the only reliable way
+ * to unregister is to wait release() to be called.
+ */
+int mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	struct mm_lock_data data;
+	int ret;
+
+	BUG_ON(!atomic_read(&mm->mm_users));
+
+	ret = mm_lock(mm, &data);
+	if (unlikely(ret))
+		goto out;
+	hlist_del(&mn->hlist);
+	mm_unlock(mm, &data);
+out:
+	return ret;
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_unregister);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
