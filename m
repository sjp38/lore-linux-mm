Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4216B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 07:35:04 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id f134so25946845lfg.6
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 04:35:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s4si2221154wjh.13.2016.10.21.04.35.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Oct 2016 04:35:02 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9LBXsU9098959
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 07:35:01 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0b-001b2d01.pphosted.com with ESMTP id 267dsuc1v2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 07:35:01 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 21 Oct 2016 05:35:00 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm, mempolicy: clean up __GFP_THISNODE confusion in policy_zonelist
In-Reply-To: <20161013125958.32155-1-mhocko@kernel.org>
References: <20161013125958.32155-1-mhocko@kernel.org>
Date: Fri, 21 Oct 2016 17:04:50 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <877f92ue91.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Michal Hocko <mhocko@kernel.org> writes:

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
>   used
>
> So we shouldn't even need to care about this possibility and can drop
> the confusing code. Let's keep a WARN_ON_ONCE in place to catch
> potential users and fix them up properly (aka use a different allocation
> function which ignores mempolicy).
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
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

For both MPOL_PREFERED and MPOL_INTERLEAVE we pick the zone list from
the node other than the current running node. Why don't we do that for
MPOL_BIND ?ie, if the current node is not part of the policy node mask
why are we not picking the first node from the policy node mask for
MPOL_BIND ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
