Date: Tue, 8 Aug 2006 10:47:52 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [1/3] Add __GFP_THISNODE to avoid fallback to other nodes and
 ignore cpuset/memory policy restrictions.
Message-Id: <20060808104752.3e7052dd.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608081001220.27866@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0608081748070.24142@skynet.skynet.ie>
	<Pine.LNX.4.64.0608081001220.27866@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: mel@csn.ul.ie, akpm@osdl.org, linux-mm@kvack.org, jes@sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

> > alloc_pages_node() would be altered to call alloc_pages_zonelist() with the
> > currect zonelist. To avoid fallbacks, callers would need a helper function
> > that provided a zonelist with just zones in a single node.
> 
> We would need a whole selection of allocators for this purpose. Some 
> candidates:

Would we really need "a whole selection"?  Seems like we just
need a variant of alloc_pages_node(), for now.

My recollection is that most calls to alloc_pages_node() and
other node specific allocators really mean:
  * get memory on or near to the specified node (best effort)

but a few such calls, such as from the memory migration code
(which is determined to recreate the relative per-node memory layout
across the migration) really mean:
  * get memory on -exactly- this node (Pike's Peak or bust)

If I were God, we'd rename 'alloc_pages_node()' to be instead
'alloc_pages_near_node()', and have another routine named
'alloc_pages_exact_node()' for use in a few places such as the
migration code.  It's mildly unfortunate that many of the callers
of 'alloc_pages_node()' (using my God-like powers of mind reading)
are expecting -exactly- that node, not just a best effort -near-
that node.  Fortunately, they don't know what they want.

Back to reality ... rather than a "whole set of allocators", how
about just provide such exact node allocators on demand, as needed
by the few calls, such as migration, that need it.

For example, add an 'alloc_pages_exact_node()' to be used by the
new_page_node() in the migration code, and the uncached_add_chunk()
in kernel/uncached.c.  It would pass a zonelist with just zones from
the allowed node to __alloc_pages().  Such a routine sounds very much
like an MPOL_BIND on a single node. Perhaps there is potential synergy
between the implementation of MPOL_BIND and 'alloc_pages_exact_node'.

So far, only alloc_pages_exact_node is needed, not "a whole selection."

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
