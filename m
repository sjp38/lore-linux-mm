Date: Wed, 15 Nov 2006 13:32:16 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] mm: call into direct reclaim without PF_MEMALLOC set
Message-Id: <20061115133216.3a45a176.akpm@osdl.org>
In-Reply-To: <1163625815.5968.66.camel@twins>
References: <1163618703.5968.50.camel@twins>
	<20061115124228.db0b42a6.akpm@osdl.org>
	<1163625815.5968.66.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Nov 2006 22:23:35 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> (Sorry about the dup Andrew, I noticed I hit the wrong reply button)
> 
> OK, so how about this?
> 
> No use running direct reclaim if we're already in there.
> 
> ---
> 
> PF_MEMALLOC is also used to prevent recursion of direct reclaim.
> However this invocation does not set PF_MEMALLOC nor checks it and
> hence a can make it nest a single time. Either by reaching this
> spot from reclaim and then calling it again or entering here and 
> encountering a __GFP_WAIT alloc from within.
> 
> So check for PF_MEMALLOC and avoid a second invocation and otherwise
> set PF_MEMALLOC.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  fs/buffer.c |   15 ++++++++++++++-
>  1 file changed, 14 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6-git/fs/buffer.c
> ===================================================================
> --- linux-2.6-git.orig/fs/buffer.c	2006-11-15 20:32:14.000000000 +0100
> +++ linux-2.6-git/fs/buffer.c	2006-11-15 21:52:05.000000000 +0100
> @@ -360,8 +360,18 @@ static void free_more_memory(void)
>  
>  	for_each_online_pgdat(pgdat) {
>  		zones = pgdat->node_zonelists[gfp_zone(GFP_NOFS)].zones;
> -		if (*zones)
> +		if (*zones && !(current->flags & PF_MEMALLOC)) {
> +			struct task_struct *p = current;
> +			struct reclaim_state reclaim_state = { 0 };
> +
> +			p->flags |= PF_MEMALLOC;
> +			p->reclaim_state = &reclaim_state;
> +
>  			try_to_free_pages(zones, GFP_NOFS);
> +
> +			p->reclaim_state = NULL;
> +			p->flags &= ~PF_MEMALLOC;
> +		}
>  	}
>  }
>  
spose so.  It assume that current->reclaim_state is NULL if !PF_MEMALLOC
which I guess is true.

But do we need to set current->reclaim_state at all in here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
