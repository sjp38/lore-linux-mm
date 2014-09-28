Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id E4AB76B0035
	for <linux-mm@kvack.org>; Sun, 28 Sep 2014 10:01:14 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id v10so2383528qac.29
        for <linux-mm@kvack.org>; Sun, 28 Sep 2014 07:01:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w4si11338053qar.1.2014.09.28.07.01.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Sep 2014 07:01:13 -0700 (PDT)
Date: Sun, 28 Sep 2014 16:00:27 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: RFC: get_user_pages_locked|unlocked to leverage VM_FAULT_RETRY
Message-ID: <20140928140027.GE4590@redhat.com>
References: <20140926172535.GC4590@redhat.com>
 <CAJu=L58c1ErLKZqAWVAT7widbJFMHKWfX1gPJoBZ3RaODjXfEg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJu=L58c1ErLKZqAWVAT7widbJFMHKWfX1gPJoBZ3RaODjXfEg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

On Fri, Sep 26, 2014 at 12:54:46PM -0700, Andres Lagar-Cavilla wrote:
> On Fri, Sep 26, 2014 at 10:25 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > On Thu, Sep 25, 2014 at 02:50:29PM -0700, Andres Lagar-Cavilla wrote:
> >> It's nearly impossible to name it right because 1) it indicates we can
> >> relinquish 2) it returns whether we still hold the mmap semaphore.
> >>
> >> I'd prefer it'd be called mmap_sem_hold, which conveys immediately
> >> what this is about ("nonblocking" or "locked" could be about a whole
> >> lot of things)
> >
> > To me FOLL_NOWAIT/FAULT_FLAG_RETRY_NOWAIT is nonblocking,
> > "locked"/FAULT_FLAG_ALLOW_RETRY is still very much blocking, just
> > without the mmap_sem, so I called it "locked"... but I'm fine to
> > change the name to mmap_sem_hold. Just get_user_pages_mmap_sem_hold
> > seems less friendly than get_user_pages_locked(..., &locked). locked
> > as you used comes intuitive when you do later "if (locked) up_read".
> >
> 
> Heh. I was previously referring to the int *locked param , not the
> _(un)locked suffix. That param is all about the mmap semaphore, so why
> not name it less ambiguously. It's essentially a tristate.

I got you were referring to the parameter name, problem I didn't want
to call the function get_user_pages_mmap_sem_hold(), and if I call it
get_user_pages_locked() calling the parameter "*locked" just like you
did in your patch looked more intuitive.

Suggestions to a better than gup_locked are welcome though!

> My suggestion is that you just make gup behave as your proposed
> gup_locked, and no need to introduce another call. But I understand if
> you want to phase this out politely.

Yes replacing gup would be ideal but there are various drivers that
make use if and have a larger critical section and I didn't want to
have to deal with all that immediately. Not to tell if anything uses
the "vmas" parameter that prevent releasing the mmap_sem by design and
will require larger modifications to get rid of.

So with this patch there's an optimal version of gup_locked|unlocked,
and a "nonscalable" one that allows for a large critical section
before and after gup with the vmas parameter too.

> > Then I added an _unlocked kind which is a drop in replacement for many
> > places just to clean it up.
> >
> > get_user_pages_unlocked and get_user_pages_fast are equivalent in
> > semantics, so any call of get_user_pages_unlocked(current,
> > current->mm, ...) has no reason to exist and should be replaced to
> > get_user_pages_fast unless "force = 1" (gup_fast has no force param
> > just to make the argument list a bit more confusing across the various
> > versions of gup).
> >
> > get_user_pages over time should be phased out and dropped.
> 
> Please. Too many variants. So the end goal is
> * __gup_fast
> * gup_fast == __gup_fast + gup_unlocked for fallback
> * gup (or gup_locked)
> * gup_unlocked
> (and flat __gup remains buried in the impl)?

That's exactly the end goal, yes.

> Basically all this discussion should go into the patch as comments.
> Help people shortcut git blame.

Sure, I added the comments of the commit header inline too.

> > +static inline long __get_user_pages_locked(struct task_struct *tsk,
> > +                                          struct mm_struct *mm,
> > +                                          unsigned long start,
> > +                                          unsigned long nr_pages,
> > +                                          int write, int force,
> > +                                          struct page **pages,
> > +                                          struct vm_area_struct **vmas,
> > +                                          int *locked,
> > +                                          bool immediate_unlock)
> s/immediate_unlock/notify_drop/

Applied.

> > +{
> > +       int flags = FOLL_TOUCH;
> > +       long ret, pages_done;
> > +       bool lock_dropped;
> s/lock_dropped/sem_dropped/

Well, this sounds a bit more confusing actually, unless we stop
calling the parameter "locked" first.

I mean it's the very "locked" parameter the "lock_dropped" variable
refers to. So I wouldn't bother to change to "sem" and stick to the
generic concept of locked/unlocked regardless of the underlying
implementation (the rwsem for reading).

> > +
> > +       if (locked) {
> > +               /* if VM_FAULT_RETRY can be returned, vmas become invalid */
> > +               BUG_ON(vmas);
> > +               /* check caller initialized locked */
> > +               BUG_ON(*locked != 1);
> > +       } else {
> > +               /*
> > +                * Not really important, the value is irrelevant if
> > +                * locked is NULL, but BUILD_BUG_ON costs nothing.
> > +                */
> > +               BUILD_BUG_ON(immediate_unlock);
> > +       }
> > +
> > +       if (pages)
> > +               flags |= FOLL_GET;
> > +       if (write)
> > +               flags |= FOLL_WRITE;
> > +       if (force)
> > +               flags |= FOLL_FORCE;
> > +
> > +       pages_done = 0;
> > +       lock_dropped = false;
> > +       for (;;) {
> > +               ret = __get_user_pages(tsk, mm, start, nr_pages, flags, pages,
> > +                                      vmas, locked);
> > +               if (!locked)
> > +                       /* VM_FAULT_RETRY couldn't trigger, bypass */
> > +                       return ret;
> > +
> > +               /* VM_FAULT_RETRY cannot return errors */
> > +               if (!*locked) {
> 
> Set lock_dropped = 1. In case we break out too soon (which we do if
> nr_pages drops to zero a couple lines below) and report a stale value.

This is purely a debug path (I suppose the compiler will nuke the
!*locked check too and the branch, if BUG_ON() is defined to a noop).

We don't need to set lock_dropped if the mmap_sem was released because
*locked is checked later:

	if (notify_drop && lock_dropped && *locked) {

So I set lock_dropped only by the time I "reacquire" the mmap_sem for
reading and I force *locked back to 1. As long as *locked == 0,
there's no point to set lock_dropped.

> > +                       BUG_ON(ret < 0);
> > +                       BUG_ON(nr_pages == 1 && ret);
> > +               }
> > +
> > +               if (!pages)
> > +                       /* If it's a prefault don't insist harder */
> > +                       return ret;
> > +
> > +               if (ret > 0) {
> > +                       nr_pages -= ret;
> > +                       pages_done += ret;
> > +                       if (!nr_pages)
> > +                               break;
> > +               }
> > +               if (*locked) {
> > +                       /* VM_FAULT_RETRY didn't trigger */
> > +                       if (!pages_done)
> > +                               pages_done = ret;
> 
> Replace top two lines with
> if (ret >0)
>     pages_done += ret;

I don't get what to change above exactly. In general every time
pages_done is increased nr_pages shall be decreased so just doing
pages_done += ret doesn't look right so it's not clear.

> > +                       break;
> > +               }
> > +               /* VM_FAULT_RETRY triggered, so seek to the faulting offset */
> > +               pages += ret;
> > +               start += ret << PAGE_SHIFT;
> > +
> > +               /*
> > +                * Repeat on the address that fired VM_FAULT_RETRY
> > +                * without FAULT_FLAG_ALLOW_RETRY but with
> > +                * FAULT_FLAG_TRIED.
> > +                */
> > +               *locked = 1;
> > +               lock_dropped = true;
> 
> Not really needed if set where previously suggested.

Yes, I just thought it's simpler to set it here, because lock_dropped
only is meant to cover the case of when we "reacquire" the mmap_sem
and override *locked = 1 (to notify the caller we destroyed the
critical section if the caller gets locked == 1 and it thinks it was
never released). Just in case the caller does something like:

      down_read(mmap_sem);
      vma = find_vma_somehow();
      ...
      locked = 1;
      gup_locked(&locked);
      if (!locked) {
      	 down_read(mmap_sem);
	 vma = find_vma_somehow();
      }
      use vma
      up_read(mmap_sem);

that's what notify_drop and lock_dropped are all about and it only
matters for gup_locked (only gup_locked will set notify_drop to true).

> > +               down_read(&mm->mmap_sem);
> > +               ret = __get_user_pages(tsk, mm, start, nr_pages, flags | FOLL_TRIED,
> > +                                      pages, NULL, NULL);
> 
> s/nr_pages/1/ otherwise we block on everything left ahead, not just
> the one that fired RETRY.

Applied. This just slipped. At least there would have been no risk
this would go unnoticed, it would BUG_ON below at the first O_DIRECT
just below with ret > 1 :).

> > +               if (ret != 1) {
> > +                       BUG_ON(ret > 1);
> 
> Can ret ever be zero here with count == 1? (ENOENT for a stack guard
> page TTBOMK, but what the heck are we doing gup'ing stacks. Suggest
> fixing that one case inside __gup impl so count == 1 never returns
> zero)

I'm ok with that change but I'd leave for later. I'd rather prefer to
leave get_user_pages API indentical for the legacy callers of gup().

> 
> > +                       if (!pages_done)
> > +                               pages_done = ret;
> 
> Don't think so. ret is --errno at this point (maybe zero). So remove.

Hmm I don't get what's wrong with the above if ret is --errno or zero.

If we get anything but 1 int the gup(locked == NULL) invocation on the
page that return VM_FAULT_RETRY we must stop and that is definitive
retval of __gup_locked (we must forget that error and return the
pages_done if any earlier pass of the loop succeeded).

Or if I drop it, we could leak all pinned pages in the previous loops
that succeeded or miss the error if we got an error and this was the
first loop.

This is __gup behavior too:

		if (IS_ERR(page))
			return i ? i : PTR_ERR(page);

It's up to the caller to figure that the page at address "start +
(pages_done << PAGE_SHIFT)" failed gup, and should be retried from
that address, if the caller wants to get a meaningful -errno.

> > +                       break;
> > +               }
> > +               nr_pages--;
> > +               pages_done++;
> > +               if (!nr_pages)
> > +                       break;
> > +               pages++;
> > +               start += PAGE_SIZE;
> > +       }
> > +       if (!immediate_unlock && lock_dropped && *locked) {
> > +               /*
> > +                * We must let the caller know we temporarily dropped the lock
> > +                * and so the critical section protected by it was lost.
> > +                */
> > +               up_read(&mm->mmap_sem);
> 
> With my suggestion of s/immediate_unlock/notify_drop/ this gets a lot
> more understandable (IMHO).

It become like this yes:

	if (notify_drop && lock_dropped && *locked) {
		/*
		 * We must let the caller know we temporarily dropped the lock
		 * and so the critical section protected by it was lost.
		 */
		up_read(&mm->mmap_sem);
		*locked = 0;
	}

And only gup_locked pass it to true (unlocked would drop the lock
anyway if it was set before returning so it doesn't need a notify).

[..]
long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
[..]
	return __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
				       pages, NULL, locked, true);
[..]
long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
[..]
	ret = __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
				      pages, NULL, &locked, false);
[..]
long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
[..]
	return __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
				       pages, vmas, NULL, false);
[..]


> *Or*, forget about gup_locked and just leave gup as proposed in this
> patch. Then gup_unlocked (again IMHO) becomes more meaningful ... "Ah,
> that's the one I call when I have no locks taken".

Yes, that's the longer term objective but that will require also
getting rid of vmas argument and more auditing.

> > -               npages = get_user_pages_fast(addr, 1, write_fault,
> > -                                            page);
> > +               npages = get_user_pages_unlocked(current, current->mm, addr, 1,
> > +                                                write_fault, 0, page);
> >         if (npages != 1)
> >                 return npages;
> 
> Acked, for the spirit. Likely my patch will go in and then you can
> just throw this one on top, removing kvm_get_user_page_io in the
> process.

Sure, that's fine. I'm very happy with your patch and it should go in
first as it's a first step in the right direction. Making this
incremental is trivial.

Also note gup_fast would also be doing the right thing with my patch
applied so we could theoretically still call gup_fast in the kvm slow
path, but I figure from the review of your patch the __gup_fast was
already tried shortly earlier by the time we got there, so it should
be more efficient to skip the irq-disabled path and just take the
gup_locked() slow-path. So replacing kvm_get_user_page_io with
gup_locked sounds better than going back to the original gup_fast.

> > While at it I also converted some obvious candidate for gup_fast that
> > had no point in running slower (which I should split off in a separate
> > patch).
> 
> Yes to all.

Thanks for the review! 

> The part that I'm missing is how would MADV_USERFAULT handle this. It
> would be buried in faultin_page, if no RETRY possible raise sigbus,
> otherwise drop the mmap semaphore and signal and sleep on the
> userfaultfd?

Below are the userfaultfd entry points.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index af61e57..26f59af 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -728,6 +732,20 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		pte_free(mm, pgtable);
 	} else {
 		pmd_t entry;
+
+		/* Deliver the page fault to userland */
+		if (vma->vm_flags & VM_USERFAULT) {
+			int ret;
+
+			spin_unlock(ptl);
+			mem_cgroup_uncharge_page(page);
+			put_page(page);
+			pte_free(mm, pgtable);
+			ret = handle_userfault(vma, haddr, flags);
+			VM_BUG_ON(ret & VM_FAULT_FALLBACK);
+			return ret;
+		}
+
 		entry = mk_huge_pmd(page, vma);
 		page_add_new_anon_rmap(page, vma, haddr);
 		pgtable_trans_huge_deposit(mm, pmd, pgtable);
@@ -808,14 +825,27 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			return VM_FAULT_FALLBACK;
 		}
 		ptl = pmd_lock(mm, pmd);
-		set = set_huge_zero_page(pgtable, mm, vma, haddr, pmd,
-				zero_page);
-		spin_unlock(ptl);
+		ret = 0;
+		set = false;
+		if (pmd_none(*pmd)) {
+			if (vma->vm_flags & VM_USERFAULT) {
+				spin_unlock(ptl);
+				ret = handle_userfault(vma, haddr, flags);
+				VM_BUG_ON(ret & VM_FAULT_FALLBACK);
+			} else {
+				set_huge_zero_page(pgtable, mm, vma,
+						   haddr, pmd,
+						   zero_page);
+				spin_unlock(ptl);
+				set = true;
+			}
+		} else
+			spin_unlock(ptl);
 		if (!set) {
 			pte_free(mm, pgtable);
 			put_huge_zero_page();
 		}
-		return 0;
+		return ret;
 	}
 	page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
 			vma, haddr, numa_node_id(), 0);
diff --git a/mm/memory.c b/mm/memory.c
index 986ddb2..18b8dde 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3244,6 +3245,11 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 		if (!pte_none(*page_table))
 			goto unlock;
+		/* Deliver the page fault to userland, check inside PT lock */
+		if (vma->vm_flags & VM_USERFAULT) {
+			pte_unmap_unlock(page_table, ptl);
+			return handle_userfault(vma, address, flags);
+		}
 		goto setpte;
 	}
 
@@ -3271,6 +3277,14 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!pte_none(*page_table))
 		goto release;
 
+	/* Deliver the page fault to userland, check inside PT lock */
+	if (vma->vm_flags & VM_USERFAULT) {
+		pte_unmap_unlock(page_table, ptl);
+		mem_cgroup_uncharge_page(page);
+		page_cache_release(page);
+		return handle_userfault(vma, address, flags);
+	}
+
 	inc_mm_counter_fast(mm, MM_ANONPAGES);
 	page_add_new_anon_rmap(page, vma, address);
 setpte:

I hope the developers working on the volatile pages could help to add
the pagecache entry points for tmpfs too so they can use
MADV_USERFAULT (and userfaultfd) on tmpfs backed memory in combination
with volatile pages (so they don't need to use syscalls before
touching the volatile memory and they can catch the fault in userland
with SIGBUS or the userfaultfd protocol). Then we've to decide how to
resolve the fault if they want to do it all on-demand paging. For
anonymous memory we do it with a newly introduced remap_anon_pages
which is like a strict and optimized version of mremap that only
touches two trans_huge_pmds/ptes and takes only the mmap_sem for
reading (and won't ever risk to lead to silent memory corruption if
userland is buggy because it triggers all sort of errors if src
pmd/pte is null or the dst pmd/pte is not null). But if there's a
fault they could also just drop the volatile range and rebuild the
area (similarly to what would happen with the syscall, just it avoids
to run the syscall in the fast path). The slow path is probably not
performance critical because it's not as common as in the KVM case (in
KVM case we know we'll fire a flood of userfaults so the userfault
handler must be as efficient as possible with remap_anon_pages THP
aware too, the volatile pages slow path shouldn't ever run normally
instead).

Anyway the first priority is to solve the above problem with
gup_locked, my last userfaultfd patch was rock solid in practice on
KVM but I was too aggressive at dropping the mmap_sem even when I
should have not, so it wasn't yet production quality and I just can't
allow userland to indefinitely keep the mmap_sem hold for reading
without special user privileges either (and no, I don't want
userfaultfd to require special permissions).

In the meantime I also implemented the range
registration/deregistration ops so you can have an infinite numbers of
userfaultfds for each process so shared libs are free to use
userfaultfd independently of each other as long as each one is
tracking its own ranges as vmas (supposedly each library will use
userfaultfd for its own memory not stepping into each other toes, two
different libraries pretending to handle userfaults on the same memory
wouldn't make sense by design in the first place, so this constraint
looks fine).

I had to extend vma_merge though, it still looks cleaner to work with
native vmas than building up a per-process range registration layer
inside userfaultfd without collisions. The vmas are already solving
99% of that problem so it felt better to make a small extension to the
vmas, exactly like it was done for the vma_policy earlier.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
