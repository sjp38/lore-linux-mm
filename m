Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 27B536B002D
	for <linux-mm@kvack.org>; Fri,  4 Nov 2011 03:31:09 -0400 (EDT)
Received: by ggnh4 with SMTP id h4so2891876ggn.14
        for <linux-mm@kvack.org>; Fri, 04 Nov 2011 00:31:06 -0700 (PDT)
Date: Fri, 4 Nov 2011 00:31:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
In-Reply-To: <1320082040-1190-1-git-send-email-aarcange@redhat.com>
Message-ID: <alpine.LSU.2.00.1111032318290.2058@sister.anvils>
References: <20111031171441.GD3466@redhat.com> <1320082040-1190-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Nai Xia <nai.xia@gmail.com>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Mon, 31 Oct 2011, Andrea Arcangeli wrote:

> migrate was doing a rmap_walk with speculative lock-less access on
> pagetables. That could lead it to not serialize properly against
> mremap PT locks. But a second problem remains in the order of vmas in
> the same_anon_vma list used by the rmap_walk.

I do think that Nai Xia deserves special credit for thinking deeper
into this than the rest of us (before you came back): something like

Issue-conceived-by: Nai Xia <nai.xia@gmail.com>

> 
> If vma_merge would succeed in copy_vma, the src vma could be placed
> after the dst vma in the same_anon_vma list. That could still lead
> migrate to miss some pte.
> 
> This patch adds a anon_vma_order_tail() function to force the dst vma

I agree with Mel that anon_vma_moveto_tail() would be a better name;
or even anon_vma_move_to_tail().

> at the end of the list before mremap starts to solve the problem.
> 
> If the mremap is very large and there are a lots of parents or childs
> sharing the anon_vma root lock, this should still scale better than
> taking the anon_vma root lock around every pte copy practically for
> the whole duration of mremap.

But I'm sorry to say that I'm actually not persuaded by the patch,
on three counts.

> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  include/linux/rmap.h |    1 +
>  mm/mmap.c            |    8 ++++++++
>  mm/rmap.c            |   44 ++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 53 insertions(+), 0 deletions(-)
B
> 
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index 2148b12..45eb098 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -120,6 +120,7 @@ void anon_vma_init(void);	/* create anon_vma_cachep */
>  int  anon_vma_prepare(struct vm_area_struct *);
>  void unlink_anon_vmas(struct vm_area_struct *);
>  int anon_vma_clone(struct vm_area_struct *, struct vm_area_struct *);
> +void anon_vma_order_tail(struct vm_area_struct *);
>  int anon_vma_fork(struct vm_area_struct *, struct vm_area_struct *);
>  void __anon_vma_link(struct vm_area_struct *);
>  
> diff --git a/mm/mmap.c b/mm/mmap.c
> index a65efd4..a5858dc 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2339,7 +2339,15 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
>  		 */
>  		if (vma_start >= new_vma->vm_start &&
>  		    vma_start < new_vma->vm_end)
> +			/*
> +			 * No need to call anon_vma_order_tail() in
> +			 * this case because the same PT lock will
> +			 * serialize the rmap_walk against both src
> +			 * and dst vmas.
> +			 */

Really?  Please convince me: I just do not see what ensures that
the same pt lock covers both src and dst areas in this case.

>  			*vmap = new_vma;
> +		else
> +			anon_vma_order_tail(new_vma);

And if this puts new_vma in the right position for the normal
move_page_tables(), as anon_vma_clone() does in the block below,
aren't they both in exactly the wrong position for the abnormal
move_page_tables(), called to put ptes back where they were if
the original move_page_tables() fails?

It might be possible to argue that move_page_tables() can only
fail by failing to allocate memory for pud or pmd, and that (perhaps)
could only happen if the task was being OOM-killed and ran out of
reserves at this point, and if it's being OOM-killed then we don't
mind losing a migration entry for a moment... perhaps.

Certainly I'd agree that it's a very rare case.  But it feels wrong
to be attempting to fix the already unlikely issue, while ignoring
this aspect, or relying on such unrelated implementation details.

Perhaps some further anon_vma_ordering could fix it up,
but that would look increasingly desperate.

>  	} else {
>  		new_vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
>  		if (new_vma) {
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 8005080..6dbc165 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -272,6 +272,50 @@ int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
>  }
>  
>  /*
> + * Some rmap walk that needs to find all ptes/hugepmds without false
> + * negatives (like migrate and split_huge_page) running concurrent
> + * with operations that copy or move pagetables (like mremap() and
> + * fork()) to be safe depends the anon_vma "same_anon_vma" list to be
> + * in a certain order: the dst_vma must be placed after the src_vma in
> + * the list. This is always guaranteed by fork() but mremap() needs to
> + * call this function to enforce it in case the dst_vma isn't newly
> + * allocated and chained with the anon_vma_clone() function but just
> + * an extension of a pre-existing vma through vma_merge.
> + *
> + * NOTE: the same_anon_vma list can still be changed by other
> + * processes while mremap runs because mremap doesn't hold the
> + * anon_vma mutex to prevent modifications to the list while it
> + * runs. All we need to enforce is that the relative order of this
> + * process vmas isn't changing (we don't care about other vmas
> + * order). Each vma corresponds to an anon_vma_chain structure so
> + * there's no risk that other processes calling anon_vma_order_tail()
> + * and changing the same_anon_vma list under mremap() will screw with
> + * the relative order of this process vmas in the list, because we
> + * won't alter the order of any vma that isn't belonging to this
> + * process. And there can't be another anon_vma_order_tail running
> + * concurrently with mremap() coming from this process because we hold
> + * the mmap_sem for the whole mremap(). fork() ordering dependency
> + * also shouldn't be affected because we only care that the parent
> + * vmas are placed in the list before the child vmas and
> + * anon_vma_order_tail won't reorder vmas from either the fork parent
> + * or child.
> + */
> +void anon_vma_order_tail(struct vm_area_struct *dst)
> +{
> +	struct anon_vma_chain *pavc;
> +	struct anon_vma *root = NULL;
> +
> +	list_for_each_entry_reverse(pavc, &dst->anon_vma_chain, same_vma) {
> +		struct anon_vma *anon_vma = pavc->anon_vma;
> +		VM_BUG_ON(pavc->vma != dst);
> +		root = lock_anon_vma_root(root, anon_vma);
> +		list_del(&pavc->same_anon_vma);
> +		list_add_tail(&pavc->same_anon_vma, &anon_vma->head);
> +	}
> +	unlock_anon_vma_root(root);
> +}

I thought this was correct, but now I'm not so sure.  You rightly
consider the question of interference between concurrent mremaps in
different mms in your comment above, but I'm still not convinced it
is safe.  Oh, probably just my persistent failure to picture these
avcs properly.

If we were back in the days of the simple anon_vma list, I'd probably
share your enthusiasm for the list ordering solution; but now it looks
like a fragile and contorted way of avoiding the obvious... we just
need to use the anon_vma_lock (but perhaps there are some common and
easily tested conditions under which we can skip it e.g. when a single
pt lock covers src and dst?).

Sorry to be so negative!  I may just be wrong on all counts.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
