Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3A38E6B00FA
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 16:06:08 -0400 (EDT)
Date: Wed, 22 Apr 2009 20:59:06 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 2/3][rfc] swap: try to reuse freed slots in the allocation
 area
In-Reply-To: <1240259085-25872-2-git-send-email-hannes@cmpxchg.org>
Message-ID: <Pine.LNX.4.64.0904222020140.18587@blonde.anvils>
References: <1240259085-25872-1-git-send-email-hannes@cmpxchg.org>
 <1240259085-25872-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Apr 2009, Johannes Weiner wrote:

> A swap slot for an anonymous memory page might get freed again just
> after allocating it when further steps in the eviction process fail.
> 
> But the clustered slot allocation will go ahead allocating after this
> now unused slot, leaving a hole at this position.  Holes waste space
> and act as a boundary for optimistic swap-in.
> 
> To avoid this, check if the next page to be swapped out can sensibly
> be placed at this just freed position.  And if so, point the next
> cluster offset to it.
> 
> The acceptable 'look-back' distance is the number of slots swap-in
> clustering uses as well so that the latter continues to get related
> context when reading surrounding swap slots optimistically.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Hugh Dickins <hugh@veritas.com>
> Cc: Rik van Riel <riel@redhat.com>

I'm glad you're looking into this area, thank you.
I've a feeling that you're going to come up with something good
here, but that neither of these patches (2/3 and 3/3) is yet it.

This patch looks plausible, but I'm not persuaded by it.

I wonder what contribution it made to the impressive figures in
your testing - I suspect none, that it barely exercised this path.

I worry that by jumping back to use the slot in this way, you're
actually propagating the glitch: by which I mean, if the pages are
all as nicely linear as you're supposing, then now one of them
will get placed out of sequence, unlike with the existing code.

And note that swapin's page_cluster is used in a strictly aligned
way (unlike swap allocation's SWAPFILE_CLUSTER): if you're going
to use page_cluster to bound this, then perhaps you should be
aligning too.  Perhaps, perhaps not.

If this patch is worthwhile, then don't you want also to be
removing the " && vm_swap_full()" test from vmscan.c, where
shrink_page_list() activate_locked does try_to_free_swap(page)?

But bigger And/Or: you remark that "holes act as a boundary for
optimistic swap-in".  Maybe that's more worth attacking?  I think
that behaviour is dictated purely by the convenience of a simple
offset:length interface between swapfile.c's valid_swaphandles()
and swap_state.c's swapin_readahead().

If swapin readahead is a good thing (I tend to be pessimistic about
it: think it's worth reading several pages while the disk head is
there, but hold no great hopes that the other pages will be useful -
though when I've experimented with removing, it's certainly proved
to be of some value), then I think you'd do better to restructure
that interface, so as not to stop at the holes.

Hugh

> ---
>  mm/swapfile.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 312fafe..fc88278 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -484,6 +484,15 @@ static int swap_entry_free(struct swap_info_struct *p, swp_entry_t ent)
>  				p->lowest_bit = offset;
>  			if (offset > p->highest_bit)
>  				p->highest_bit = offset;
> +			/*
> +			 * If the next allocation is only some slots
> +			 * ahead, reuse this now free slot instead of
> +			 * leaving a hole.
> +			 */
> +			if (p->cluster_next - offset <= 1 << page_cluster) {
> +				p->cluster_next = offset;
> +				p->cluster_nr++;
> +			}
>  			if (p->prio > swap_info[swap_list.next].prio)
>  				swap_list.next = p - swap_info;
>  			nr_swap_pages++;
> -- 
> 1.6.2.1.135.gde769

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
