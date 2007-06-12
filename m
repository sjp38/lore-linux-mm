Date: Mon, 11 Jun 2007 18:12:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v2][RFC] Fix INTERLEAVE with memoryless nodes
In-Reply-To: <20070611175700.e5268342.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0706111810150.24692@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
 <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
 <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com>
 <Pine.LNX.4.64.0706111613100.23857@schroedinger.engr.sgi.com>
 <20070612001436.GI14458@us.ibm.com> <20070611175700.e5268342.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, lee.schermerhorn@hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Andrew Morton wrote:

> > +	unsigned nid;
> 
> This variable appears to be unneeded.
> 
> >  	PDprintk("setting mode %d nodes[0] %lx\n", mode, nodes_addr(*nodes)[0]);
> >  	if (mode == MPOL_DEFAULT)
> > @@ -184,8 +185,12 @@ static struct mempolicy *mpol_new(int mode, nodemask_t *nodes)
> >  	atomic_set(&policy->refcnt, 1);
> >  	switch (mode) {
> >  	case MPOL_INTERLEAVE:
> > -		policy->v.nodes = *nodes;
> > -		if (nodes_weight(*nodes) == 0) {
> > +		/*
> > +		 * Clear any memoryless nodes here so that v.nodes can be used
> > +		 * without extra checks
> > +		 */
> > +		nodes_and(policy->v.nodes, *nodes, node_populated_mask);
> > +		if (nodes_weight(policy->v.nodes) == 0) {
> >  			kmem_cache_free(policy_cache, policy);
> >  			return ERR_PTR(-EINVAL);
> >  		}
> 
> I have no node_populated_mask.
> 
> The below improves the situation, but I wonder about, ahem, the maturity of
> this code.

Yeah. No one compiled it. But I think we have the general outline how this 
could be done.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
