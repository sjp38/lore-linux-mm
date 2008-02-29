Date: Fri, 29 Feb 2008 11:59:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/6] Filter based on a nodemask as well as a gfp_mask
Message-Id: <20080229115957.85d0b5b2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080227214747.6858.46514.sendpatchset@localhost>
References: <20080227214708.6858.53458.sendpatchset@localhost>
	<20080227214747.6858.46514.sendpatchset@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>, Mel Gorman <mel@csn.ul.ie>
Cc: akpm@linux-foundation.org, ak@suse.de, clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2008 16:47:47 -0500
Lee Schermerhorn <lee.schermerhorn@hp.com>, Mel Gorman <mel@csn.ul.ie> wrote:

> [PATCH 6/6] Filter based on a nodemask as well as a gfp_mask
> 
> V11r3 against 2.6.25-rc2-mm1
> 
> The MPOL_BIND policy creates a zonelist that is used for allocations
> controlled by that mempolicy. As the per-node zonelist is already being
> filtered based on a zone id, this patch adds a version of __alloc_pages()
> that takes a nodemask for further filtering. This eliminates the need
> for MPOL_BIND to create a custom zonelist.
> 
> A positive benefit of this is that allocations using MPOL_BIND now use the
> local node's distance-ordered zonelist instead of a custom node-id-ordered
> zonelist.  I.e., pages will be allocated from the closest allowed node with
> available memory.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Christoph Lameter <clameter@sgi.com>
> Tested-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> 

Thank you! I like this very much.
Next step is maybe to pass nodemask to try_to_free_pages().

BTW, cpuset memory limitation by nodemask has the same kind of feature.
But it seems cpuset_zone_allowed_soft/hardwall() has extra checks for system
sanity. 

Could you import them ? maybe like this
==
void __alloc_pages_internal(gfp_t gfp_mask, unsigned int order,
+			struct zonelist *zonelist, nodemask_t *nodemask))
{
	if (nodemask) {
		if (unlikely(test_thread_flag(TIF_MEMDIE)))
	                nodemask = NULL;
		if ((gfp_mask & __GFP_HARDWALL)
                     && (unlikely(test_thread_flag(TIF_MEMDIE)))
			nodemask = NULL;
	}
}
==
(I don't think above is clean.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
