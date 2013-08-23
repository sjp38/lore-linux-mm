Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id A508E6B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 09:03:40 -0400 (EDT)
Date: Fri, 23 Aug 2013 15:03:32 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] cpuset: mm: Reduce large amounts of memory barrier
 related damage v3
Message-ID: <20130823130332.GY31370@twins.programming.kicks-ass.net>
References: <20120307180852.GE17697@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120307180852.GE17697@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com

On Wed, Mar 07, 2012 at 06:08:52PM +0000, Mel Gorman wrote:
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 06b145f..013d981 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1843,18 +1843,24 @@ struct page *
>  alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>  		unsigned long addr, int node)
>  {
> -	struct mempolicy *pol = get_vma_policy(current, vma, addr);
> +	struct mempolicy *pol;
>  	struct zonelist *zl;
>  	struct page *page;
> +	unsigned int cpuset_mems_cookie;
> +
> +retry_cpuset:
> +	pol = get_vma_policy(current, vma, addr);
> +	cpuset_mems_cookie = get_mems_allowed();
>  
> -	get_mems_allowed();
>  	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
>  		unsigned nid;
>  
>  		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
>  		mpol_cond_put(pol);
>  		page = alloc_page_interleave(gfp, order, nid);
> -		put_mems_allowed();
> +		if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
> +			goto retry_cpuset;
> +
>  		return page;
>  	}
>  	zl = policy_zonelist(gfp, pol, node);

So I think this patch is broken (still). Suppose we have an
INTERLEAVE mempol like 0x3 and change it to 0xc.

Original:	0x3
Rebind Step 1:	0xf /* set bits */
Rebind Step 2:	0xc /* clear bits */

Now look at what can happen with offset_il_node() when its ran
concurrently with step 2:

  nnodes = nodes_weight(pol->v.nodes); /* observes 0xf and returns 4 */

  /* now we clear the actual bits */
  
  target = (unsigned int)off % nnodes; /* assume target >= 2 */
  c = 0;
  do {
  	nid = next_node(nid, pol->v.nodes);
	c++;
  } while (c <= target);

  /* here nid := MAX_NUMNODES */


This nid is then blindly inserted into node_zonelist() which does an
NODE_DATA() array access out of bounds and off we go.

This would suggest we put the whole seqcount thing inside
offset_il_node().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
