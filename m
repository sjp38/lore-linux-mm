Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 613278D0069
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 14:57:42 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p0KJvRA7003906
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:57:30 -0800
Received: from iyb26 (iyb26.prod.google.com [10.241.49.90])
	by kpbe16.cbf.corp.google.com with ESMTP id p0KJuu78017252
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:57:26 -0800
Received: by iyb26 with SMTP id 26so973969iyb.27
        for <linux-mm@kvack.org>; Thu, 20 Jan 2011 11:57:22 -0800 (PST)
Date: Thu, 20 Jan 2011 11:57:08 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 00/21] mm: Preemptibility -v6
In-Reply-To: <1295457039.28776.137.camel@laptop>
Message-ID: <alpine.LSU.2.00.1101201052060.1603@sister.anvils>
References: <20101126143843.801484792@chello.nl> <alpine.LSU.2.00.1101172301340.2899@sister.anvils> <1295457039.28776.137.camel@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@kernel.dk>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

We seem to agree nicely on most points :) just a few extracts:

On Wed, 19 Jan 2011, Peter Zijlstra wrote:
> On Mon, 2011-01-17 at 23:12 -0800, Hugh Dickins wrote:
> 
> One thing I was wondering about, should I fold all these patches into
> one big patch to improve bisectability? Because after the first patch
> all !generic-tlb archs won't compile anymore due to the mm/* changes.

Ah.  Personally I like how you've split it up: certainly the larger
powerpc and sparc patches are easier to grasp in their smaller pieces,
and each arch needs to collect approval from each arch maintainer.

But that doesn't preclude lumping them all together for the final commit,
for ease of bisection.  I think Andrew and Ben are the ones to decide
on that: Ben's bisectability got burnt by THP just now, so he'll have
strong feelings and good reasons.

> > 18/21 mutex-provide_mutex_is_contended.patch
> >       I suppose so, though if we use it in the truncate path, then we are
> >       stuck with the vm_truncate_count stuff I'd rather hoped would go away;
> >       but I guess you're right, that if we did spin_needbreak/need_lockbreak
> >       before, then we ought to do this now - though I suspect I only added
> >       it because I had to insert a resched-point anyway, and it seemed a good
> >       idea at the time to check lockbreak too since that had just been added.
> 
> Since its now preemptable we might consider simply removing that. I
> simply wanted to keep the changes to a minimum for now.

Removing that along with the restart_addr stuff, yes.  I keep wavering.
Yes it would be nice to get rid of all that, particularly now we find
it's had holes in all these years.  The only significant loser, I think,
would be page reclaim (when concurrent with truncation): could spin for a
long time waiting for the i_mmap_mutex it expects would soon be dropped?

> > 05/21 mm-move_anon_vma_ref_out_from_under_config_ksm.patch
> >       Acked-by: Hugh Dickins <hughd@google.com>
> >       but you shouldn't need to touch mm/migrate.c again here with 38-rc1.
> >       Didn't you end up double-decrementing refcount in the huge_page case?
> 
> I'm afraid I need a little help here, what huge_page case? I tried
> applying this comment to both patches 5 and 6, but failed to find a
> huge_page case..

The 05/21 I was looking at had a hunk modifying mm/migrate.c, replacing
anon_vma->external_refcount by anon_vma->refcount in two places in
unmap_and_move_huge_page().  But once you've rebased to 38-rc1, it's
a different story: unmap_and_move_huge_page() using the same anon_vma
functions as unmap_and_move(), neither referring to refcount directly.

After your patchset, unmap_and_move_huge_page() ended up doing:

	if (anon_vma && atomic_dec_and_mutex_lock(&anon_vma->refcount,
					    &anon_vma->lock)) {
		int empty = list_empty(&anon_vma->head);
		mutex_unlock(&anon_vma->lock);
		if (empty)
			put_anon_vma(anon_vma);
	}

where put_anon_vma() does:

	if (atomic_dec_and_test(&anon_vma->refcount))
		__put_anon_vma(anon_vma);

But that should just be history since 38-rc1 simplified it.

> > 06/21 mm-simplify_anon_vma_refcounts.patch
> >       Acked-by: Hugh Dickins <hughd@google.com>
> >       except page_get_anon_vma() is being declared in rmap.h a patch early,
> >       and you shouldn't need to touch mm/ksm.c again here with 38-rc1.
> >       Did wonder if __put_anon_vma() is right to put anon_vma->root *before*
> >       freeing anon_vma, but suppose your not_zero strictness makes it safe.
> 
> It seemed like the natural order to do things, release the reference we
> hold on ->root right before we free ourselves.
> 
> The race you're worried about is the page_lock_anon_vma() where we
> access ->root? Afaict that's ok because we check page_mapped() and
> decrementing that should be done _before_ the last put_anon_vma(),
> otherwise that function is already racy.

I didn't get as far as worrying about any particular race: it was just
that I thought we used to be careful that root be the last to be freed,
for fear of references coming via those referring to it, even though
they are about to be freed.

Looking at 38-rc1 I see anon_vma_unlink() does
	if (empty) {
		/* We no longer need the root anon_vma */
		if (anon_vma->root != anon_vma)
			drop_anon_vma(anon_vma->root);
		anon_vma_free(anon_vma);
	}
but drop_anon_vma() does
		if (empty) {
			anon_vma_free(anon_vma);
			if (root_empty && last_root_user)
				anon_vma_free(root);
		}

So long as the safeguards are right elsewhere, it shouldn't matter.

> 
> > 19/21 mm-convert_i_mmap_lock_and_anon_vma-_lock_to_mutexes.patch
> >       I suggest doing the anon_vma lock->mutex conversion separately here.
> >       Acked-by: Hugh Dickins <hughd@google.com>
> >       except that in the past we have renamed a lock when we've done this
> >       kind of conversion, so I'd expect anon_vma->mutex throughout now.
> >       Or am I just out of date?  I don't feel very strongly about it.
> 
> Done.. however:
> 
> Index: linux-2.6/include/linux/huge_mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/huge_mm.h
> +++ linux-2.6/include/linux/huge_mm.h
> @@ -91,12 +91,8 @@ extern void __split_huge_page_pmd(struct
>  #define wait_split_huge_page(__anon_vma, __pmd)				\
>  	do {								\
>  		pmd_t *____pmd = (__pmd);				\
> -		spin_unlock_wait(&(__anon_vma)->root->lock);		\
> -		/*							\
> -		 * spin_unlock_wait() is just a loop in C and so the	\
> -		 * CPU can reorder anything around it.			\
> -		 */							\
> -		smp_mb();						\
> +		anon_vma_lock(__anon_vma);				\
> +		anon_vma_unlock(__anon_vma);				\
>  		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
>  		       pmd_trans_huge(*____pmd));			\
>  	} while (0)
> 
> Andrea, is that smp_mb() simply to avoid us doing anything before the
> lock is free? Why isn't there an mb() before to ensure nothing leaks
> past it from the other end?

I'll leave that in for Andrea to answer, I've not given it any thought.

> 
> > 21/21 mm-optimize_page_lock_anon_vma_fast-path.patch
> >       I certainly see the call for this patch, I want to eliminate those
> >       doubled atomics too.  This appears correct to me, and I've not dreamt
> >       up an alternative; but I do dislike it, and I suspect you don't like
> >       it much either.  I'm ambivalent about it, would love a better patch.
> 
> Like said, I fully agree with that sentiment, just haven't been able to
> come up with anything saner :/ Although I can optimize the
> __put_anon_vma() path a bit by doing something like:
> 
>   if (mutex_is_locked()) { anon_vma_lock(); anon_vma_unlock(); }
> 
> But I bet that wants a barrier someplace and my head hurts.. 

Without daring to hurt my head very much, yes, I'd say those kind
of "optimizations" have a habit of turning out to be racily wrong.

But you put your finger on it: if you hadn't had to add that lock-
unlock pair into __put_anon_vma(), I wouldn't have minded the
contortions added to page_lock_anon_vma().

> > A few checkpatch warnings, many of which I don't particularly agree with -
> > though I do get annoyed by comments going over 80-cols without any need!
> 
> Agreed, although I didn't spot any comments crossing the 80-column
> boundary.

06/21 mm-simplify_anon_vma_refcounts.patch
+		 * Initialise the anon_vma root to point to itself. If called from

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
