Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id 74C076B0036
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 20:55:53 -0400 (EDT)
Received: by mail-qc0-f174.google.com with SMTP id i17so18488131qcy.33
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 17:55:53 -0700 (PDT)
Received: from e8.ny.us.ibm.com (e8.ny.us.ibm.com. [32.97.182.138])
        by mx.google.com with ESMTPS id c17si17217858qae.59.2014.09.09.17.55.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 17:55:52 -0700 (PDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nacc@linux.vnet.ibm.com>;
	Tue, 9 Sep 2014 20:55:52 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 8EC7FC90048
	for <linux-mm@kvack.org>; Tue,  9 Sep 2014 20:55:40 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s8A0tnlx8126974
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 00:55:49 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s8A0tmkH011669
	for <linux-mm@kvack.org>; Tue, 9 Sep 2014 20:55:48 -0400
Date: Tue, 9 Sep 2014 17:55:42 -0700
From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] slub: fallback to node_to_mem_node() node if
 allocating on memoryless node
Message-ID: <20140910005542.GI22906@linux.vnet.ibm.com>
References: <20140909190154.GC22906@linux.vnet.ibm.com>
 <20140909190326.GD22906@linux.vnet.ibm.com>
 <20140909190514.GE22906@linux.vnet.ibm.com>
 <20140909171125.de9844579d55599c59260afb@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140909171125.de9844579d55599c59260afb@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Han Pingtian <hanpt@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Anton Blanchard <anton@samba.org>, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org

On 09.09.2014 [17:11:25 -0700], Andrew Morton wrote:
> On Tue, 9 Sep 2014 12:05:14 -0700 Nishanth Aravamudan <nacc@linux.vnet.ibm.com> wrote:
> 
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > Update the SLUB code to search for partial slabs on the nearest node
> > with memory in the presence of memoryless nodes. Additionally, do not
> > consider it to be an ALLOC_NODE_MISMATCH (and deactivate the slab) when
> > a memoryless-node specified allocation goes off-node.
> > 
> > ...
> >
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1699,7 +1699,12 @@ static void *get_partial(struct kmem_cache *s, gfp_t flags, int node,
> >  		struct kmem_cache_cpu *c)
> >  {
> >  	void *object;
> > -	int searchnode = (node == NUMA_NO_NODE) ? numa_mem_id() : node;
> > +	int searchnode = node;
> > +
> > +	if (node == NUMA_NO_NODE)
> > +		searchnode = numa_mem_id();
> > +	else if (!node_present_pages(node))
> > +		searchnode = node_to_mem_node(node);
> 
> I expect a call to node_to_mem_node() will always be preceded by a test
> of node_present_pages().  Perhaps node_to_mem_node() should just do the
> node_present_pages() call itself?

Really, we don't need that test here. We could always use the result of
node_to_mem_node() in the else. If memoryless nodes are not supported
(off in .config), then node_to_mem_node() trivially returns. If they are
supported, it returns the correct value for all nodes.
 
It's just an optimization (premature?) since we can avoid worrying (in
this path) about memoryless nodes if the node in question has memory.

And, in fact, in __slab_alloc(), we could do the following:

...
	int searchnode = node;

	if (node != NUMA_NO_NODE)
		searchnode = node_to_mem_node(node);

	if (node != searchnode &&
		unlikely(!node_match(page, searchnode))) {

...

which would minimize the impact to non-memoryless node NUMA configs.

Does that seem better to you? I can add comments to this patch as well.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
