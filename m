Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 1B4206B0032
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 05:45:29 -0400 (EDT)
Date: Thu, 29 Aug 2013 11:45:25 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] cpuset: mm: Reduce large amounts of memory barrier
 related damage v3
Message-ID: <20130829094525.GY10002@twins.programming.kicks-ass.net>
References: <20120307180852.GE17697@suse.de>
 <20130823130332.GY31370@twins.programming.kicks-ass.net>
 <20130823181546.GA31370@twins.programming.kicks-ass.net>
 <20130829092828.GB22421@suse.de>
 <20130829094342.GX10002@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130829094342.GX10002@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com

On Thu, Aug 29, 2013 at 11:43:42AM +0200, Peter Zijlstra wrote:
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index 7431001..ae880c3 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -1755,22 +1755,24 @@ unsigned slab_node(void)
> >  }
> >  
> >  /* Do static interleaving for a VMA with known offset. */
> > -static unsigned offset_il_node(struct mempolicy *pol,
> > +static unsigned int offset_il_node(struct mempolicy *pol,
> >  		struct vm_area_struct *vma, unsigned long off)
> >  {
> > -	unsigned nnodes = nodes_weight(pol->v.nodes);
> > -	unsigned target;
> > -	int c;
> > -	int nid = -1;
> > +	unsigned int nr_nodes, target;
> > +	int i, nid;
> >  
> > -	if (!nnodes)
> > +again:
> > +	nr_nodes = nodes_weight(pol->v.nodes);
> > +	if (!nr_nodes)
> >  		return numa_node_id();
> > -	target = (unsigned int)off % nnodes;
> > -	c = 0;
> > -	do {
> > +	target = (unsigned int)off % nr_nodes;
> > +	for (i = 0, nid = first_node(pol->v.nodes); i < target; i++)
> >  		nid = next_node(nid, pol->v.nodes);
> > -		c++;
> > -	} while (c <= target);
> > +
> > +	/* Policy nodemask can potentially update in parallel */
> > +	if (unlikely(!node_isset(nid, pol->v.nodes)))
> > +		goto again;
> > +
> >  	return nid;
> >  }
> 
> So I explicitly didn't use the node_isset() test because that's more
> likely to trigger than the nid >= MAX_NUMNODES test. Its fine to return
> a node that isn't actually part of the mask anymore -- a race is a race
> anyway.

Oh more importantly, if nid does indeed end up being >= MAX_NUMNODES as
is possible with next_node() the node_isset() test will be out-of-bounds
and can crash itself.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
