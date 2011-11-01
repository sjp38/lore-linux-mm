Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 12F276B002D
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 08:07:37 -0400 (EDT)
Date: Tue, 1 Nov 2011 12:07:26 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mremap: enforce rmap src/dst vma ordering in case of
 vma_merge succeeding in copy_vma
Message-ID: <20111101120726.GA25123@suse.de>
References: <20111031171441.GD3466@redhat.com>
 <1320082040-1190-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1320082040-1190-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Nai Xia <nai.xia@gmail.com>, Hugh Dickins <hughd@google.com>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Mon, Oct 31, 2011 at 06:27:20PM +0100, Andrea Arcangeli wrote:
> migrate was doing a rmap_walk with speculative lock-less access on
> pagetables. That could lead it to not serialize properly against
> mremap PT locks. But a second problem remains in the order of vmas in
> the same_anon_vma list used by the rmap_walk.
> 
> If vma_merge would succeed in copy_vma, the src vma could be placed
> after the dst vma in the same_anon_vma list. That could still lead
> migrate to miss some pte.
> 

For future reference, why? How about this as an explanation?

If vma_merge would succeed in copy_vma, the src vma could be placed
after the dst vma in the same_anon_vma list. That leads to a race
between migration and mremap whereby a migration PTE is left behind.

mremap				migration
create dst VMA
				rmap_walk
				finds dst, no ptes, release PTL
move_ptes
copies src PTEs to dst
				finds src, ptes empty, releases PTL

The migration PTE is now left behind because the order of VMAs matter.

> This patch adds a anon_vma_order_tail() function to force the dst vma
> at the end of the list before mremap starts to solve the problem.
> 

Document the alternative just in case?

"One fix would be to have mremap take the anon_vma lock which would
serialise migration and mremap but this would hurt scalability. Instead,
this patch adds....."

I would also prefer something like anon_vma_moveto_tail() but maybe
it's just me that sees "order" and thinks "high-order allocation".

> If the mremap is very large and there are a lots of parents or childs
> sharing the anon_vma root lock, this should still scale better than
> taking the anon_vma root lock around every pte copy practically for
> the whole duration of mremap.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  include/linux/rmap.h |    1 +
>  mm/mmap.c            |    8 ++++++++
>  mm/rmap.c            |   44 ++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 53 insertions(+), 0 deletions(-)
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
>  			*vmap = new_vma;
> +		else
> +			anon_vma_order_tail(new_vma);
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
> +

This is following the same rules as anon_vma_clone() and I didn't see a
flaw in your explanation as to why it's safe.

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
