Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 97AA39000C2
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 05:50:02 -0400 (EDT)
Date: Tue, 26 Apr 2011 19:49:47 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 03/13] mm: Introduce __GFP_MEMALLOC to allow access to
 emergency reserves
Message-ID: <20110426194947.764e048a@notabene.brown>
In-Reply-To: <1303803414-5937-4-git-send-email-mgorman@suse.de>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
	<1303803414-5937-4-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, 26 Apr 2011 08:36:44 +0100 Mel Gorman <mgorman@suse.de> wrote:

> __GFP_MEMALLOC will allow the allocation to disregard the watermarks,
> much like PF_MEMALLOC. It allows one to pass along the memalloc state in
> object related allocation flags as opposed to task related flags, such
> as sk->sk_allocation. This removes the need for ALLOC_PFMEMALLOC as
> callers using __GFP_MEMALLOC can get the ALLOC_NO_WATERMARK flag which
> is now enough to identify allocations related to page reclaim.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  include/linux/gfp.h      |    4 +++-
>  include/linux/mm_types.h |    2 +-
>  mm/page_alloc.c          |   14 ++++++--------
>  mm/slab.c                |    2 +-
>  4 files changed, 11 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index bfb8f93..4e011e7 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -23,6 +23,7 @@ struct vm_area_struct;
>  #define ___GFP_REPEAT		0x400u
>  #define ___GFP_NOFAIL		0x800u
>  #define ___GFP_NORETRY		0x1000u
> +#define ___GFP_MEMALLOC		0x2000u
>  #define ___GFP_COMP		0x4000u
>  #define ___GFP_ZERO		0x8000u
>  #define ___GFP_NOMEMALLOC	0x10000u
> @@ -75,6 +76,7 @@ struct vm_area_struct;
>  #define __GFP_REPEAT	((__force gfp_t)___GFP_REPEAT)	/* See above */
>  #define __GFP_NOFAIL	((__force gfp_t)___GFP_NOFAIL)	/* See above */
>  #define __GFP_NORETRY	((__force gfp_t)___GFP_NORETRY) /* See above */
> +#define __GFP_MEMALLOC	((__force gfp_t)___GFP_MEMALLOC)/* Allow access to emergency reserves */
>  #define __GFP_COMP	((__force gfp_t)___GFP_COMP)	/* Add compound page metadata */
>  #define __GFP_ZERO	((__force gfp_t)___GFP_ZERO)	/* Return zeroed page on success */
>  #define __GFP_NOMEMALLOC ((__force gfp_t)___GFP_NOMEMALLOC) /* Don't use emergency reserves */

Having both "MEMALLOC" and  "NOMEMALLOC" seems ... unfortunate.

It appears that NOMEMALLOC over-rides MEMALLOC.  It might be good to document
this 

> +#define __GFP_MEMALLOC	((__force gfp_t)___GFP_MEMALLOC)/* Allow access to emergency reserves
                                                                   unless __GFP_NOMEMALLOC is set*/

>  #define __GFP_NOMEMALLOC ((__force gfp_t)___GFP_NOMEMALLOC) /* Don't use emergency reserves
                                                                  Overrides __GFP_MEMALLOC */

I suspect that it is never valid to set both.  So NOMEMALLOC is really
NO_PF_MEMALLOC, but making that change is probably just noise.

Maybe a
   WARN_ON((gfp_mask & __GFP_MEMALLOC) && (gfp_mask & __GFP_NOMEMALLOC));
might be wise?

NeilBrown.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
