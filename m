Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 390F26B0038
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 08:51:47 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f6so56537347qtd.4
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 05:51:47 -0700 (PDT)
Received: from mail-qt0-f171.google.com (mail-qt0-f171.google.com. [209.85.216.171])
        by mx.google.com with ESMTPS id w23si2990006qka.222.2016.10.13.05.51.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 05:51:46 -0700 (PDT)
Received: by mail-qt0-f171.google.com with SMTP id q7so42529408qtq.1
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 05:51:46 -0700 (PDT)
Date: Thu, 13 Oct 2016 14:51:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: MPOL_BIND on memory only nodes
Message-ID: <20161013125143.GN21678@dhcp22.suse.cz>
References: <57FE0184.6030008@linux.vnet.ibm.com>
 <20161012094337.GH17128@dhcp22.suse.cz>
 <20161012131626.GL17128@dhcp22.suse.cz>
 <57FF59EE.9050508@linux.vnet.ibm.com>
 <20161013100708.GI21678@dhcp22.suse.cz>
 <57FF68D3.5030507@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57FF68D3.5030507@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>

On Thu 13-10-16 16:28:27, Anshuman Khandual wrote:
> On 10/13/2016 03:37 PM, Michal Hocko wrote:
> > On Thu 13-10-16 15:24:54, Anshuman Khandual wrote:
> > [...]
> >> Which makes the function look like this. Even with these changes, MPOL_BIND is
> >> still going to pick up the local node's zonelist instead of the first node in
> >> policy->v.nodes nodemask. It completely ignores policy->v.nodes which it should
> >> not.
> > 
> > Not really. I have tried to explain earlier. We do not ignore policy
> > nodemask. This one comes from policy_nodemask. We start with the local
> > node but fallback to some of the nodes from the nodemask defined by the
> > policy.
> > 
> 
> Yeah saw your response but did not get that exactly. We dont ignore
> policy nodemask while memory allocation, correct. But my point was
> we are ignoring policy nodemask while selecting zonelist which will
> be used during page allocation. Though the zone contents of both the
> zonelists are likely to be same, would not it be better to get the
> zone list from the nodemask as well ?

Why. Zonelist from the current node should contain all availanle zones
and get_page_from_freelist then filters this zonelist accoring to
mempolicy and nodemask

> Or I am still missing something
> here. The following change is what I am trying to propose.
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index ad1c96a..f60ab80 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1685,14 +1685,7 @@ static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
>                         nd = policy->v.preferred_node;
>                 break;
>         case MPOL_BIND:
> -               /*
> -                * Normally, MPOL_BIND allocations are node-local within the
> -                * allowed nodemask.  However, if __GFP_THISNODE is set and the
> -                * current node isn't part of the mask, we use the zonelist for
> -                * the first node in the mask instead.
> -                */
> -               if (unlikely(gfp & __GFP_THISNODE) &&
> -                               unlikely(!node_isset(nd, policy->v.nodes)))
> +               if (unlikely(!node_isset(nd, policy->v.nodes)))
>                         nd = first_node(policy->v.nodes);

That shouldn't make much difference as per above.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
