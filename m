Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A4A516B0038
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 05:55:10 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 128so71004112pfz.1
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 02:55:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x5si10333922pgf.96.2016.10.13.02.55.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 02:55:09 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9D9sQUh101868
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 05:55:09 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26259gfpvr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 05:55:09 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 13 Oct 2016 19:55:00 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id EA8802BB0045
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 20:54:57 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9D9svSC6095182
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 20:54:57 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9D9svk8022702
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 20:54:57 +1100
Date: Thu, 13 Oct 2016 15:24:54 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: MPOL_BIND on memory only nodes
References: <57FE0184.6030008@linux.vnet.ibm.com> <20161012094337.GH17128@dhcp22.suse.cz> <20161012131626.GL17128@dhcp22.suse.cz>
In-Reply-To: <20161012131626.GL17128@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57FF59EE.9050508@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>

On 10/12/2016 06:46 PM, Michal Hocko wrote:
> On Wed 12-10-16 11:43:37, Michal Hocko wrote:
>> On Wed 12-10-16 14:55:24, Anshuman Khandual wrote:
> [...]
>>> Why we insist on __GFP_THISNODE ?
>>
>> AFAIU __GFP_THISNODE just overrides the given node to the policy
>> nodemask in case the current node is not part of that node mask. In
>> other words we are ignoring the given node and use what the policy says. 
>> I can see how this can be confusing especially when confronting the
>> documentation:
>>
>>  * __GFP_THISNODE forces the allocation to be satisified from the requested
>>  *   node with no fallbacks or placement policy enforcements.
> 
> You made me think and look into this deeper. I came to the conclusion
> that this is actually a relict from the past. policy_zonelist is called
> only from 3 places:
> - huge_zonelist - never should do __GFP_THISNODE when going this path
> - alloc_pages_vma - which shouldn't depend on __GFP_THISNODE either
> - alloc_pages_current - which uses default_policy id __GFP_THISNODE is
>   used
> 
> So AFAICS this is essentially a dead code or I am missing something. Mel
> do you remember why we needed it in the past? I would be really tempted
> to just get rid of this confusing code and this instead:
> ---
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index ad1c96ac313c..98beec47bba9 100644
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
> +		WARN_ON_ONCE(polic->mode == MPOL_BIND && (gfp && __GFP_THISNODE));
>  	}
> +
>  	return node_zonelist(nd, gfp);
>  }

Which makes the function look like this. Even with these changes, MPOL_BIND is
still going to pick up the local node's zonelist instead of the first node in
policy->v.nodes nodemask. It completely ignores policy->v.nodes which it should
not.

/* Return a zonelist indicated by gfp for node representing a mempolicy */
static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
        int nd)
{
        if (policy->mode == MPOL_PREFERRED && !(policy->flags & MPOL_F_LOCAL))
                nd = policy->v.preferred_node;
        else {
                /*
                 * __GFP_THISNODE shouldn't even be used with the bind policy because
                 * we might easily break the expectation to stay on the requested node
                 * and not break the policy.
                 */
                WARN_ON_ONCE(polic->mode == MPOL_BIND && (gfp && __GFP_THISNODE));
        }

        return node_zonelist(nd, gfp);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
