Date: Fri, 24 Aug 2007 15:52:34 +0100
Subject: Re: [PATCH] Fix find_next_best_node (Re: [BUG] 2.6.23-rc3-mm1 Kernel panic - not syncing: DMA: Memory would be corrupted)
Message-ID: <20070824145233.GA26374@skynet.ie>
References: <617E1C2C70743745A92448908E030B2A023EB020@scsmsx411.amr.corp.intel.com> <20070823142133.9359a1ce.akpm@linux-foundation.org> <20070824153945.3C75.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070824153945.3C75.Y-GOTO@jp.fujitsu.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, "Luck, Tony" <tony.luck@intel.com>, Jeremy Higdon <jeremy@sgi.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (24/08/07 15:53), Yasunori Goto didst pronounce:
> 
> I found find_next_best_node() was wrong.
> I confirmed boot up by the following patch.
> Mel-san, Kamalesh-san, could you try this?
> 

This boots the IA-64 successful and gets rid of that DMA corrupts
memory message. As a bonus, it fixes up the memoryless nodes (the bug
where Total pages == 0 and there is a BUG in page_alloc.c) by building
zonelists properly. The machine still fails to boot with the more familiar
net/core/skbuff.c:95 but that is a separate problem.

Well spotted Yasunori-san.

Andrew, this fixes a real problem and should be considered a fix to
memoryless-nodes-fixup-uses-of-node_online_map-in-generic-code.patch unless
Christoph Lameter objects.

> Bye.
> ---
> 
> Fix decision of memoryless node in find_next_best_node().
> This can be cause of SW-IOMMU's allocation failure.
> 
> This patch is for 2.6.23-rc3-mm1.
> 
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> 

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
>  mm/page_alloc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: current/mm/page_alloc.c
> ===================================================================
> --- current.orig/mm/page_alloc.c	2007-08-24 16:03:17.000000000 +0900
> +++ current/mm/page_alloc.c	2007-08-24 16:04:06.000000000 +0900
> @@ -2136,7 +2136,7 @@ static int find_next_best_node(int node,
>  		 * Note:  N_HIGH_MEMORY state not guaranteed to be
>  		 *        populated yet.
>  		 */
> -		if (pgdat->node_present_pages)
> +		if (!pgdat->node_present_pages)
>  			continue;
>  
>  		/* Don't want a node to appear more than once */
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
