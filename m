Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7466B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 05:52:32 -0500 (EST)
Received: by wggy19 with SMTP id y19so2766228wgg.10
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 02:52:31 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bb7si10266855wjb.130.2015.02.25.02.52.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Feb 2015 02:52:30 -0800 (PST)
Message-ID: <54EDA96C.4000609@suse.cz>
Date: Wed, 25 Feb 2015 11:52:28 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [patch v2 for-4.0] mm, thp: really limit transparent hugepage
 allocation to local node
References: <alpine.DEB.2.10.1502241422370.11324@chino.kir.corp.google.com> <alpine.DEB.2.10.1502241522590.9480@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1502241522590.9480@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/25/2015 12:24 AM, David Rientjes wrote:
> From: Greg Thelen <gthelen@google.com>
>
> Commit 077fcf116c8c ("mm/thp: allocate transparent hugepages on local
> node") restructured alloc_hugepage_vma() with the intent of only
> allocating transparent hugepages locally when there was not an effective
> interleave mempolicy.
>
> alloc_pages_exact_node() does not limit the allocation to the single
> node, however, but rather prefers it.  This is because __GFP_THISNODE is
> not set which would cause the node-local nodemask to be passed.  Without
> it, only a nodemask that prefers the local node is passed.

Oops, good catch.
But I believe we have the same problem with khugepaged_alloc_page(), 
rendering the recent node determination and zone_reclaim strictness 
patches partially useless.

Then I start to wonder about other alloc_pages_exact_node() users. Some 
do pass __GFP_THISNODE, others not - are they also mistaken? I guess the 
function is a misnomer - when I see "exact_node", I expect the 
__GFP_THISNODE behavior.

I think to avoid such hidden catches, we should create 
alloc_pages_preferred_node() variant, change the exact_node() variant to 
pass __GFP_THISNODE, and audit and adjust all callers accordingly.

Also, you pass __GFP_NOWARN but that should be covered by GFP_TRANSHUGE 
already. Of course, nothing guarantees that hugepage == true implies 
that gfp == GFP_TRANSHUGE... but current in-tree callers conform to that.

> Fix this by passing __GFP_THISNODE and falling back to small pages when
> the allocation fails.
>
> Fixes: 077fcf116c8c ("mm/thp: allocate transparent hugepages on local node")
> Signed-off-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>   v2: GFP_THISNODE actually defers compaction and reclaim entirely based on
>       the combination of gfp flags.  We want to try compaction and reclaim,
>       so only set __GFP_THISNODE.  We still set __GFP_NOWARN to suppress
>       oom warnings in the kernel log when we can simply fallback to small
>       pages.
>
>   mm/mempolicy.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1985,7 +1985,10 @@ retry_cpuset:
>   		nmask = policy_nodemask(gfp, pol);
>   		if (!nmask || node_isset(node, *nmask)) {
>   			mpol_cond_put(pol);
> -			page = alloc_pages_exact_node(node, gfp, order);
> +			page = alloc_pages_exact_node(node, gfp |
> +							    __GFP_THISNODE |
> +							    __GFP_NOWARN,
> +						      order);
>   			goto out;
>   		}
>   	}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
