Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 95C2B6B00B3
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 17:35:28 -0400 (EDT)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id o2GLZMK8011420
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 22:35:22 +0100
Received: from pxi3 (pxi3.prod.google.com [10.243.27.3])
	by spaceape8.eur.corp.google.com with ESMTP id o2GLZGtM025136
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 14:35:21 -0700
Received: by pxi3 with SMTP id 3so301349pxi.28
        for <linux-mm@kvack.org>; Tue, 16 Mar 2010 14:35:19 -0700 (PDT)
Date: Tue, 16 Mar 2010 14:35:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mempolicy: remove redundant check
In-Reply-To: <1268747703-8343-1-git-send-email-user@bob-laptop>
Message-ID: <alpine.DEB.2.00.1003161433560.10930@chino.kir.corp.google.com>
References: <1268747703-8343-1-git-send-email-user@bob-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 16 Mar 2010, Bob Liu wrote:

> From: Bob Liu <lliubbo@gmail.com>
> 
> 1. Lee's patch "mempolicy: use MPOL_PREFERRED for system-wide
> default policy" has made the MPOL_DEFAULT only used in the
> memory policy APIs. So, no need to check in __mpol_equal also.
> 
> 2. In policy_zonelist() mode MPOL_INTERLEAVE shouldn't happen,
> so fall through to BUG() instead of break to return.I also fix
> the comment.
> 

These are two seperate functional changes, so you'll need to break them 
out into individual patches.

> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/mempolicy.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 643f66e..c4b16c9 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1441,15 +1441,15 @@ static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy)
>  		/*
>  		 * Normally, MPOL_BIND allocations are node-local within the
>  		 * allowed nodemask.  However, if __GFP_THISNODE is set and the
> -		 * current node is part of the mask, we use the zonelist for
> +		 * current node isn't part of the mask, we use the zonelist for
>  		 * the first node in the mask instead.
>  		 */
>  		if (unlikely(gfp & __GFP_THISNODE) &&
>  				unlikely(!node_isset(nd, policy->v.nodes)))
>  			nd = first_node(policy->v.nodes);
>  		break;
> -	case MPOL_INTERLEAVE: /* should not happen */
> -		break;
> +	case MPOL_INTERLEAVE:
> +		/* Should not happen, so fall through to BUG()*/
>  	default:
>  		BUG();
>  	}

Looks good.

> @@ -1806,7 +1806,7 @@ int __mpol_equal(struct mempolicy *a, struct mempolicy *b)
>  		return 0;
>  	if (a->mode != b->mode)
>  		return 0;
> -	if (a->mode != MPOL_DEFAULT && !mpol_match_intent(a, b))
> +	if (!mpol_match_intent(a, b))
>  		return 0;
>  	switch (a->mode) {
>  	case MPOL_BIND:

Ok.  Could you also get rid of mpol_match_intent() and move its logic 
directly into __mpol_equal() with the other comparison tests?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
