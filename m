Date: Thu, 17 Jan 2008 22:47:04 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [BUG] at mm/slab.c:3320
In-Reply-To: <Pine.LNX.4.64.0801170631000.19208@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0801172243210.21599@sbz-30.cs.Helsinki.FI>
References: <20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com>
 <20080109065015.GG7602@us.ibm.com>  <Pine.LNX.4.64.0801090949440.10163@schroedinger.engr.sgi.com>
  <20080109185859.GD11852@skywalker>  <Pine.LNX.4.64.0801091122490.11317@schroedinger.engr.sgi.com>
  <20080109214707.GA26941@us.ibm.com>  <Pine.LNX.4.64.0801091349430.12505@schroedinger.engr.sgi.com>
  <20080109221315.GB26941@us.ibm.com>  <Pine.LNX.4.64.0801091601080.14723@schroedinger.engr.sgi.com>
 <84144f020801170431l2d6d0d63i1fb7ebc5145539f4@mail.gmail.com>
 <Pine.LNX.4.64.0801170631000.19208@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Nishanth Aravamudan <nacc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Jan 2008, Christoph Lameter wrote:
> > > +       if (!objp) {
> > > +               int node_id = numa_node_id();
> > > +               if (likely(cache->nodelists[node_id])) /* fast path */
> > > +                       objp = ____cache_alloc_node(cache, flags, node_id);
> > > +               else /* this function can do good fallback */
> > > +                       objp = __cache_alloc_node(cache, flags, node_id,
> > > +                                       __builtin_return_address(0));
> > > +       }
> > 
> > But __cache_alloc_node() will call fallback_alloc() that does
> > cache_grow() for the node that doesn't have N_NORMAL_MEMORY, no?
> 
> No fallback_alloc will fallback to a node that has normal memory.

Hmm, looking at this again, I still can't quite figure it out. If the node 
returned by numa_node_id() has cache->nodelists set to NULL, you end up 
calling kmem_getpages() with -1 as the node id which is translated to 
numa_node_id() by alloc_pages_node(). But the reason we called 
fallback_alloc() in the first place is because numa_node_id() doesn't have 
a ->nodelist...

What am I missing here?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
