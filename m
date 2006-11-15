Date: Wed, 15 Nov 2006 12:42:28 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: mm: call into direct reclaim without PF_MEMALLOC set
Message-Id: <20061115124228.db0b42a6.akpm@osdl.org>
In-Reply-To: <1163618703.5968.50.camel@twins>
References: <1163618703.5968.50.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Nov 2006 20:25:03 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> 
> PF_MEMALLOC keeps direct reclaim from recursing into itself, I noticed this
> call to try_to_free_pages didn't set it thus opening the floodgates.
> 

Fair enough, I guess.

The changelog needs work - I had to think about it too much.

So it prevents a single level of recursion into try_to_free_pages() in the
case where free_more_memory() is not being called by try_to_free_pages()
(ie: the usual case).

> /me wonders why this never triggered...

Nobody would notice if it did - just a bit more stack space.

For the extra level of recursion to happen we'd require
try_to_free_pages(GFP_NOFS) to perform some allocation with __GFP_WAIT set.
 There will be some such cases, but not many.

> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  fs/buffer.c |   12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6-git/fs/buffer.c
> ===================================================================
> --- linux-2.6-git.orig/fs/buffer.c	2006-11-15 20:14:58.000000000 +0100
> +++ linux-2.6-git/fs/buffer.c	2006-11-15 20:19:22.000000000 +0100
> @@ -360,8 +360,18 @@ static void free_more_memory(void)
>  
>  	for_each_online_pgdat(pgdat) {
>  		zones = pgdat->node_zonelists[gfp_zone(GFP_NOFS)].zones;
> -		if (*zones)
> +		if (*zones) {
> +			struct task_struct *p = current;
> +			struct reclaim_state reclaim_state;
> +			reclaim_state.reclaim_slab = 0;
> +			p->flags |= PF_MEMALLOC;
> +			p->reclaim_state = &reclaim_state;
> +
>  			try_to_free_pages(zones, GFP_NOFS);
> +
> +			p->reclaim_state = NULL;
> +			p->flags &= ~PF_MEMALLOC;
> +		}
>  	}

Consider

	alloc_pages
	->try_to_free_pages
	  ->writepage
	    ->alloc_page_buffers
	      ->free_more_memory

The caller has already set PF_MEMALLOC, but your new code goes and
incorrectly clears it.

And I don't think we need the reclaim_state here?  If we do, you'll need to
save the caller's copy locally and restore it, rather than unconditionally
unwiring it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
