Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id D75E06B0032
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 05:43:52 -0400 (EDT)
Date: Thu, 29 Aug 2013 11:43:42 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] cpuset: mm: Reduce large amounts of memory barrier
 related damage v3
Message-ID: <20130829094342.GX10002@twins.programming.kicks-ass.net>
References: <20120307180852.GE17697@suse.de>
 <20130823130332.GY31370@twins.programming.kicks-ass.net>
 <20130823181546.GA31370@twins.programming.kicks-ass.net>
 <20130829092828.GB22421@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130829092828.GB22421@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com

On Thu, Aug 29, 2013 at 10:28:29AM +0100, Mel Gorman wrote:
> On Fri, Aug 23, 2013 at 08:15:46PM +0200, Peter Zijlstra wrote:
> > On Fri, Aug 23, 2013 at 03:03:32PM +0200, Peter Zijlstra wrote:
> > > So I think this patch is broken (still).
> 
> I am assuming the lack of complaints is that it is not a heavily executed
> path. I expect that you (and Rik) are hitting this as part of automatic
> NUMA balancing. Still a bug, just slightly less urgent if NUMA balancing
> is the reproduction case.

I thought it was, we crashed somewhere suspiciously close, but no. You
need shared mpols for this to actually trigger and the NUMA stuff
doesn't use that.

> > +	if (unlikely((unsigned)nid >= MAX_NUMNODES))
> > +		goto again;
> > +
> 
> MAX_NUMNODES is unrelated to anything except that it might prevent a crash
> and even then nr_online_nodes is probably what you wanted and even that
> assumes the NUMA node numbering is contiguous. 

I used whatever nodemask.h did to detect end-of-bitmap and they use
MAX_NUMNODES. See __next_node() and for_each_node() like.

MAX_NUMNODES doesn't assume contiguous numbers since its the actual size
of the bitmap, nr_online_nodes would hoever.

> The real concern is whether
> the updated mask is an allowed target for the updated memory policy. If
> it's not then "nid" can be pointing off the deep end somewhere.  With this
> conversion to a for loop there is race after you check nnodes where target
> gets set to 0 and then return a nid of -1 which I suppose will just blow
> up differently but it's fixable.

But but but, I did i <= target, which will match when target == 0 so
you'll get at least a single iteration and nid will be set.

> This? Untested. Fixes implicit types while it's there. Note the use of
> first node and (c < target) to guarantee nid gets set and that the first
> potential node is still used as an interleave target.
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 7431001..ae880c3 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1755,22 +1755,24 @@ unsigned slab_node(void)
>  }
>  
>  /* Do static interleaving for a VMA with known offset. */
> -static unsigned offset_il_node(struct mempolicy *pol,
> +static unsigned int offset_il_node(struct mempolicy *pol,
>  		struct vm_area_struct *vma, unsigned long off)
>  {
> -	unsigned nnodes = nodes_weight(pol->v.nodes);
> -	unsigned target;
> -	int c;
> -	int nid = -1;
> +	unsigned int nr_nodes, target;
> +	int i, nid;
>  
> -	if (!nnodes)
> +again:
> +	nr_nodes = nodes_weight(pol->v.nodes);
> +	if (!nr_nodes)
>  		return numa_node_id();
> -	target = (unsigned int)off % nnodes;
> -	c = 0;
> -	do {
> +	target = (unsigned int)off % nr_nodes;
> +	for (i = 0, nid = first_node(pol->v.nodes); i < target; i++)
>  		nid = next_node(nid, pol->v.nodes);
> -		c++;
> -	} while (c <= target);
> +
> +	/* Policy nodemask can potentially update in parallel */
> +	if (unlikely(!node_isset(nid, pol->v.nodes)))
> +		goto again;
> +
>  	return nid;
>  }

So I explicitly didn't use the node_isset() test because that's more
likely to trigger than the nid >= MAX_NUMNODES test. Its fine to return
a node that isn't actually part of the mask anymore -- a race is a race
anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
