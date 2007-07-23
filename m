Subject: Re: [PATCH v4][RFC] hugetlb: add per-node nr_hugepages sysfs
	attribute
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070723122327.3610adf4@schroedinger.engr.sgi.com>
References: <20070612001542.GJ14458@us.ibm.com>
	 <20070612034407.GB11773@holomorphy.com> <20070612050910.GU3798@us.ibm.com>
	 <20070612051512.GC11773@holomorphy.com> <20070612174503.GB3798@us.ibm.com>
	 <20070612191347.GE11781@holomorphy.com> <20070613000446.GL3798@us.ibm.com>
	 <20070613152649.GN3798@us.ibm.com> <20070613152847.GO3798@us.ibm.com>
	 <1181759027.6148.77.camel@localhost> <20070613191908.GR3798@us.ibm.com>
	 <1181765111.6148.98.camel@localhost>
	 <20070723122327.3610adf4@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 23 Jul 2007 16:14:05 -0400
Message-Id: <1185221645.5074.32.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, William Lee Irwin III <wli@holomorphy.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-07-23 at 12:23 -0700, Christoph Lameter wrote:
> On Wed, 13 Jun 2007 16:05:10 -0400
> Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> 
> > I tried to "tighten up"  alloc_pages_node() to check the location of
> > the first zone in the selected zonelist, as discussed in previous
> > exchange. When I do this, I hit a BUG() in slub.c in
> > early_kmem_cache_node_alloc(), as it apparently can't handle
> > new_slab() returning a NULL page, even tho' it calls it with
> > GFP_THISNODE.  Slub should be able to handle memoryless nodes,
> > right?  I'm looking for a work around to this now.
> 
> The memoryless node patchset results in SLUB not attempting to allocate
> on memoryless nodes during bootstrap.
> 

Christoph:

The message that you're responding to is from 13jun, before your
memoryless nodes patch.  We discussed it and have more or less resolved
it.  I was trying to ensure that GFP_THISNODE would fail on my funky
interleaved node with just DMA memory, when you ask for a higher zone.
I.e., no fallback.  You disagreed with this, so I'm waiting for the
memoryless nodes patches to get into -mm, so I can address the issue of
hugepages [and regular interleaved pages] being allocated from a node
where they shouldn't on my platform.  

This has been discussed in the past week by Nish, Paul Mundt, and others
in the -mm thread:

	[hugetlb] Try to grow pool for MAP_SHARED mappings

I think we can handle the fundamental issue [even nodes with memory are
not necessarily candidates for interleave, hugepages, ...] by adding
another node_state[].  See the mentioned thread.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
