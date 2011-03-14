Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CF2938D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 13:17:36 -0400 (EDT)
Date: Mon, 14 Mar 2011 18:17:31 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp+memcg-numa: fix BUG at include/linux/mm.h:370!
Message-ID: <20110314171730.GF10696@random.random>
References: <alpine.LSU.2.00.1103140059510.1661@sister.anvils>
 <20110314155232.GB10696@random.random>
 <alpine.LSU.2.00.1103140910570.2601@sister.anvils>
 <AANLkTikvt+o+UaksmvM5C7FWt7hTMJyaPiUGhQ+6OKBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTikvt+o+UaksmvM5C7FWt7hTMJyaPiUGhQ+6OKBg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

Hello,

On Mon, Mar 14, 2011 at 09:56:10AM -0700, Linus Torvalds wrote:
> On Mon, Mar 14, 2011 at 9:37 AM, Hugh Dickins <hughd@google.com> wrote:
> >
> > I did try it that way at first (didn't help when I mistakenly put
> > #ifndef instead of #ifdef around the put_page!), but was repulsed
> > by seeing yet another #ifdef CONFIG_NUMA, so went with the duplicating
> > version - which Linus has now taken.
> 
> I have to admit to being repulsed by the whole patch, but my main
> source of "that's effin ugly" was from the crazy lock handling.
> 
> Does mem_cgroup_newpage_charge() even _need_ the mmap_sem at all? And
> if not, why not release the read-lock early? And even if it _does_
> need it, why not do
> 

The mmap_sem is needed for the page allocation, or the "vma" can
become a dangling pointer (the vma is passed to alloc_hugepage_vma).

>     ret = mem_cgroup_newpage_charge();
>     up_read(&mm->mmap_sem);
>     if (ret) {
>         ...
> 
> finally, the #ifdef CONFIG_NUMA is ugly, but it's ugly in the return
> path of the function too, and the nicer way would probably be to have
> it in one place and do something like
> 
>     /*
>      * The allocation rules are different for the NUMA/non-NUMA cases
>      * For the NUMA case, we allocate here, for the non-numa case we
>      * use the allocation in *hpage
>      */
>     static inline struct page *collapse_alloc_hugepage(struct page **hpage)
>     {
>     #ifdef CONFIG_NUMA
>         VM_BUG_ON(*hpage);
>         return alloc_hugepage_vma(khugepaged_defrag(), vma, address, node);
>     #else
>         VM_BUG_ON(!*hpage);
>         return *hpage;
>     #endif
>     }
> 
>     static inline void collapse_free_hugepage(struct page *page)
>     {
>     #ifdef CONFIG_NUMA
>         put_page(new_page);
>     #else
>         /* Nothing to do */
>     #endif
>     }
> 
> and use that instead. The point being that the #ifdef'fery now ends up
> being in a much more targeted area and much better abstracted, rather
> than in the middle of code, and ugly as sin.

Agreed about the cleanup. I didn't add a new function for it like
probably I should have to make it less ugly...

About mem_cgroup_newpage_charge I think you're right it won't need the
mmap_sem. Running it under it is sure safe. But if it's not needed we
can move the up_read before the mem_cgroup_newpage_charge like you
suggested. Johannes/Minchan could you confirm the mmap_sem isn't
needed around mem_cgroup_newpage_charge? The mm and new_page are
stable without the mmap_sem, only the vma goes away but the memcg
shouldn't care.

> But as mentioned, the lock handling is disgusting. Why is it even safe
> to drop and re-take the lock at all?

We have to upgrade the rwsem from read to write (hugepmd isn't allowed
to materialize under code that runs with the mmap_sem read mode,
that's one of the invariants to be safe when split_huge_page_pmd does
nothing and let the regular pte walk go ahead). It is safe because we
revalidate the vma after dropping the read lock and taking the write
lock. It's generally impossible to upgrade the lock without first
dropping it if more than one thread does that in parallel on the same
mm (they all hold the read lock so somebody has to drop the read lock
and revalidate before anyone has a chance to take the write lock). Now
interestingly I notice that in this very case khugepaged is single
threaded and no other places would call upgrade_read() on the mmap_sem
anywhere, so it probably would be safe, but there's no method for that
(because it'd need to be called at most by one thread at once on the
same mm and that's probably not considered an useful case, even if it
probably would be in collapse_huge_page). If we ever thread khugepaged
to run on more than one core then we'd be forced to drop the lock too
(unless we make the scan on the same mm mutually exclusive which isn't
the best for large mm anyway). But I exclude we ever need to thread
khugepaged though, it's blazing fast (unlike the ksmd scan). So if we
implment an upgrade_read() we might be able to remove a find_vma in
collapse_huge_page. It's not very important to optimize though as the
memory copy should be the biggest cost anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
