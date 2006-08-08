Date: Tue, 8 Aug 2006 11:49:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [1/3] Add __GFP_THISNODE to avoid fallback to other nodes and
 ignore cpuset/memory policy restrictions.
In-Reply-To: <20060808111855.531e4e29.pj@sgi.com>
Message-ID: <Pine.LNX.4.64.0608081142130.29355@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0608081748070.24142@skynet.skynet.ie>
 <Pine.LNX.4.64.0608081001220.27866@schroedinger.engr.sgi.com>
 <20060808104752.3e7052dd.pj@sgi.com> <Pine.LNX.4.64.0608081052460.28259@schroedinger.engr.sgi.com>
 <20060808111855.531e4e29.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: mel@csn.ul.ie, akpm@osdl.org, linux-mm@kvack.org, jes@sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Aug 2006, Paul Jackson wrote:

> Christoph wrote:
> > If we would look at the users at all 
> > the _node allocators then we surely will find users of kmalloc_node and 
> > vmalloc_node etc that expect memory on exactly that node.
> 
> Perhaps.  Do you know of any specific examples needing this?

Sure. Some examples

For kmalloc_node()  look at vmalloc.c and slab.c for starters.

For vmalloc_node see drivers/oprofile/buffer.c
net/ipv4/netfilter/... various places.

This is going to increase with the more NUMA awareness throughout the 
kernel.

Interesting constructs in ip_tables.c:

counters = vmalloc_node(countersize, numa_node_id());

It seems what they really want is:

counters = __vmalloc(countersize, __GFP_THISNODE, PAGE_KERNEL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
