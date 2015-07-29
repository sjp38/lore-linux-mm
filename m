Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id CBAA36B0256
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 09:30:48 -0400 (EDT)
Received: by wicgb10 with SMTP id gb10so200840303wic.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 06:30:48 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id by11si13644379wib.105.2015.07.29.06.30.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 06:30:46 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id A74659922A
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 13:30:45 +0000 (UTC)
Date: Wed, 29 Jul 2015 14:30:43 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC v2 1/4] mm: make alloc_pages_exact_node pass __GFP_THISNODE
Message-ID: <20150729133043.GE19352@techsingularity.net>
References: <1437749126-25867-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1437749126-25867-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Fri, Jul 24, 2015 at 04:45:23PM +0200, Vlastimil Babka wrote:
> The function alloc_pages_exact_node() was introduced in 6484eb3e2a81 ("page
> allocator: do not check NUMA node ID when the caller knows the node is valid")

No gold stars for that one.

> as an optimized variant of alloc_pages_node(), that doesn't allow the node id
> to be -1. Unfortunately the name of the function can easily suggest that the
> allocation is restricted to the given node and fails otherwise. In truth, the
> node is only preferred, unless __GFP_THISNODE is passed among the gfp flags.
> 
> The misleading name has lead to mistakes in the past, see 5265047ac301 ("mm,
> thp: really limit transparent hugepage allocation to local node") and
> b360edb43f8e ("mm, mempolicy: migrate_to_node should only migrate to node").
> 
> To prevent further mistakes and provide a convenience function for allocations
> truly restricted to a node, this patch makes alloc_pages_exact_node() pass
> __GFP_THISNODE to that effect. The previous implementation of

The change of what we have now is a good idea. What you have is a solid
improvement in my view but I see there are a few different suggestions
in the thread. Based on that I think it makes sense to just destroy
alloc_pages_exact_node. In the future "exact" in the allocator API will
mean "exactly this number of pages". Use your __alloc_pages_node helper
and specify __GFP_THISNODE if the caller requires that specific node.

> alloc_pages_exact_node() is copied as __alloc_pages_node() which implies it's
> an optimized variant of __alloc_pages_node() not intended for general usage.
> All three functions are described in the comment.
> 
> Existing callers of alloc_pages_exact_node() are adjusted as follows:
> - those that explicitly pass __GFP_THISNODE keep calling
>   alloc_pages_exact_node(), but the flag is removed from the call

__alloc_pages_node(__GFP_THISNODE) would be harder to get wrong in the future

> - others are converted to call __alloc_pages_node(). Some may still pass
>   __GFP_THISNODE if they serve as wrappers that get gfp_flags from higher
>   layers.
> 
> There's exception of sba_alloc_coherent() which open-codes the check for
> nid == -1, so it is converted to use alloc_pages_node() instead. This means
> it no longer performs some VM_BUG_ON checks, but otherwise the whole patch
> makes no functional changes.
> 

In general, checks for -1 should go away, particularly with new patches.
Use NUMA_NO_NODE.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
