Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 486156B00F5
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 15:40:53 -0500 (EST)
Date: Wed, 25 Feb 2009 20:40:26 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] mm: don't free swap slots on page deactivation
In-Reply-To: <20090225192550.GA5645@cmpxchg.org>
Message-ID: <Pine.LNX.4.64.0902252022460.19132@blonde.anvils>
References: <20090225023830.GA1611@cmpxchg.org> <20090225192550.GA5645@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Feb 2009, Johannes Weiner wrote:

> The pagevec_swap_free() at the end of shrink_active_list() was
> introduced in 68a22394 "vmscan: free swap space on swap-in/activation"
> when shrink_active_list() was still rotating referenced active pages.
> 
> In 7e9cd48 "vmscan: fix pagecache reclaim referenced bit check" this
> was changed, the rotating removed but the pagevec_swap_free() after
> the rotation loop was forgotten, applying now to the pagevec of the
> deactivation loop instead.
> 
> Now swap space is freed for deactivated pages.  And only for those
> that happen to be on the pagevec after the deactivation loop.
> 
> Complete 7e9cd48 and remove the rest of the swap freeing.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>

Nice observation.  I was going to object that the original code was
indifferent to whether it was freeing swap from active or inactive,
they all got lumped into the same pvec.  But that was just an oversight
in the original code: you're right that if it was our intention to free
swap from inactive pages here (when vm_swap_full), then we'd be freeing
it from them in the loop above (where the buffer_heads_over_limit
pagevec_strip is done).

Once upon a time (early 2007), testing an earlier incarnation of that
code, I did find almost nothing being freed by that pagevec_swap_free
anyway: other vm_swap_full frees were being effective, effective
enough to render this one rather pointless, even when it was operating
as intended.  But I never got around to checking on that in 2008's
splitLRU patches, and a lot changed in between: I may be misleading.

If Rik agrees (I think these do need his Ack), note that there are
no other users of pagevec_swap_free, so you'd do well to remove it
from mm/swap.c and include/linux/pagevec.h - I can well imagine us
wanting to bring it back some time, but can easily look it up when
and if we do need it again in the future.

Hugh

> ---
>  mm/vmscan.c |    3 ---
>  1 file changed, 3 deletions(-)
> 
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1303,9 +1303,6 @@ static void shrink_active_list(unsigned 
>  	spin_unlock_irq(&zone->lru_lock);
>  	if (buffer_heads_over_limit)
>  		pagevec_strip(&pvec);
> -	if (vm_swap_full())
> -		pagevec_swap_free(&pvec);
> -
>  	pagevec_release(&pvec);
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
