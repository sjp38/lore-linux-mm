Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2048D6B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 05:44:30 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b75so7242505lfg.3
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 02:44:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h129si21824987lfd.226.2016.10.18.02.44.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Oct 2016 02:44:28 -0700 (PDT)
Subject: Re: [PATCH] mm, mempolicy: clean up __GFP_THISNODE confusion in
 policy_zonelist
References: <20161013125958.32155-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7e4ed04c-8bec-029a-cedc-4573df8fb0aa@suse.cz>
Date: Tue, 18 Oct 2016 11:44:27 +0200
MIME-Version: 1.0
In-Reply-To: <20161013125958.32155-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 10/13/2016 02:59 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> __GFP_THISNODE is documented to enforce the allocation to be satisified
> from the requested node with no fallbacks or placement policy
> enforcements. policy_zonelist seemingly breaks this semantic if the
> current policy is MPOL_MBIND and instead of taking the node it will
> fallback to the first node in the mask if the requested one is not in
> the mask. This is confusing to say the least because it fact we
> shouldn't ever go that path. First tasks shouldn't be scheduled on CPUs
> with nodes outside of their mempolicy binding. And secondly
> policy_zonelist is called only from 3 places:
> - huge_zonelist - never should do __GFP_THISNODE when going this path
> - alloc_pages_vma - which shouldn't depend on __GFP_THISNODE either
> - alloc_pages_current - which uses default_policy id __GFP_THISNODE is

						    ^ if

>   used
>
> So we shouldn't even need to care about this possibility and can drop
> the confusing code. Let's keep a WARN_ON_ONCE in place to catch
> potential users and fix them up properly (aka use a different allocation
> function which ignores mempolicy).
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Looks good, and a BUG_ON() removed as a bonus :)
Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>
> Hi,
> I have noticed this while discussing this code [1]. The code as is
> quite confusing and I think it is worth cleaning up. I decided to be
> conservative and keep at least WARN_ON_ONCE if we have some caller which
> relies on __GFP_THISNODE in a mempolicy context so that we can fix it up.
>
> [1] http://lkml.kernel.org/r/57FE0184.6030008@linux.vnet.ibm.com
>
>  mm/mempolicy.c | 24 ++++++++----------------
>  1 file changed, 8 insertions(+), 16 deletions(-)
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index ad1c96ac313c..33a305397bd4 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1679,25 +1679,17 @@ static nodemask_t *policy_nodemask(gfp_t gfp, struct mempolicy *policy)
>  static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
>  	int nd)
>  {
> -	switch (policy->mode) {
> -	case MPOL_PREFERRED:
> -		if (!(policy->flags & MPOL_F_LOCAL))
> -			nd = policy->v.preferred_node;
> -		break;
> -	case MPOL_BIND:
> +	if (policy->mode == MPOL_PREFERRED && !(policy->flags & MPOL_F_LOCAL))
> +		nd = policy->v.preferred_node;
> +	else {
>  		/*
> -		 * Normally, MPOL_BIND allocations are node-local within the
> -		 * allowed nodemask.  However, if __GFP_THISNODE is set and the
> -		 * current node isn't part of the mask, we use the zonelist for
> -		 * the first node in the mask instead.
> +		 * __GFP_THISNODE shouldn't even be used with the bind policy because
> +		 * we might easily break the expectation to stay on the requested node
> +		 * and not break the policy.
>  		 */
> -		if (unlikely(gfp & __GFP_THISNODE) &&
> -				unlikely(!node_isset(nd, policy->v.nodes)))
> -			nd = first_node(policy->v.nodes);
> -		break;
> -	default:
> -		BUG();
> +		WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
>  	}
> +
>  	return node_zonelist(nd, gfp);
>  }
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
