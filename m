Subject: Re: [PATCH v4][RFC] hugetlb: add per-node nr_hugepages sysfs
	attribute
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070613191908.GR3798@us.ibm.com>
References: <20070612001542.GJ14458@us.ibm.com>
	 <20070612034407.GB11773@holomorphy.com> <20070612050910.GU3798@us.ibm.com>
	 <20070612051512.GC11773@holomorphy.com> <20070612174503.GB3798@us.ibm.com>
	 <20070612191347.GE11781@holomorphy.com> <20070613000446.GL3798@us.ibm.com>
	 <20070613152649.GN3798@us.ibm.com> <20070613152847.GO3798@us.ibm.com>
	 <1181759027.6148.77.camel@localhost>  <20070613191908.GR3798@us.ibm.com>
Content-Type: text/plain
Date: Wed, 13 Jun 2007 16:05:10 -0400
Message-Id: <1181765111.6148.98.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>, Christoph Lameter <clameter@sgi.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-06-13 at 12:19 -0700, Nishanth Aravamudan wrote:
> On 13.06.2007 [14:23:47 -0400], Lee Schermerhorn wrote:
> > On Wed, 2007-06-13 at 08:28 -0700, Nishanth Aravamudan wrote:
> > <snip>
> > > 
> > > commit 05a7edb8c909c674cdefb0323348825cf3e2d1d0
> > > Author: Nishanth Aravamudan <nacc@us.ibm.com>
> > > Date:   Thu Jun 7 08:54:48 2007 -0700
> > > 
> > > hugetlb: add per-node nr_hugepages sysfs attribute
> > > 
> > > Allow specifying the number of hugepages to allocate on a particular
> > > node. Our current global sysctl will try its best to put hugepages
> > > equally on each node, but htat may not always be desired. This allows
> > > the admin to control the layout of hugepage allocation at a finer level
> > > (while not breaking the existing interface). Add callbacks in the sysfs
> > > node registration and unregistration functions into hugetlb to add the
> > > nr_hugepages attribute, which is a no-op if !NUMA or !HUGETLB.
> > > 
> > > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> > > Cc: William Lee Irwin III <wli@holomorphy.com>
> > > Cc: Christoph Lameter <clameter@sgi.com>
> > > Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
> > > Cc: Anton Blanchard <anton@sambar.org>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > 
> > > ---
> > > Do the dummy function definitions need to be (void)0?
> > > 
> > 
> > <snip>

I tested hugepage allocation on my HP rx8620 platform [16 cpu ia64, 32GB
in 4 "real" nodes and one pseudo-node containing only DMA memory].  As
expected, I don't get a balanced distribution across the real nodes.
Here's what I see:

# before allocating huge pages:
root@gwydyr(root):cat /sys/devices/system/node/node*/meminfo | grep HugeP 
Node 0 HugePages_Total:     0
Node 0 HugePages_Free:      0
Node 1 HugePages_Total:     0
Node 1 HugePages_Free:      0
Node 2 HugePages_Total:     0
Node 2 HugePages_Free:      0
Node 3 HugePages_Total:     0
Node 3 HugePages_Free:      0
Node 4 HugePages_Total:     0
Node 4 HugePages_Free:      0

# Now allocate 64 256MB pages.  Only nodes 0-3 have NORMAL memory.
# Zone 4 contains ~512MB of DMA memory.  Some has already been
# used, so I doubt that even 1 256MB [aligned] huge page is available.

root@gwydyr(root):echo 64 >/proc/sys/vm/nr_hugepages
root@gwydyr(root):cat /sys/devices/system/node/node*/meminfo | grep HugeP
Node 0 HugePages_Total:    13	<---???
Node 0 HugePages_Free:     26	<---???
Node 1 HugePages_Total:    12
Node 1 HugePages_Free:     12
Node 2 HugePages_Total:    13
Node 2 HugePages_Free:     13
Node 3 HugePages_Total:    13
Node 3 HugePages_Free:     13
Node 4 HugePages_Total:    13	<---???
Node 4 HugePages_Free:      0

# 13 of the pages say they're from Node 4, but I know that has only
~512MB or memory, of which some is already used.  Unlikely that I can
allocate even 1 256MB huge page because of alignment.  Note that the
free pages are accounted on Node 0, where they actually reside.

Here's some zoneinfo after the allocation above [forgot to snap it
before].

# zoneinfo shell function contains:
# cat /proc/zoneinfo | egrep '^Node|^  pages |^  *present|^  *spanned'
# results after allocating huge pages
root@gwydyr(root):zoneinfo
Node 0, zone   Normal
  pages free     36157
        spanned  486400
        present  484738
Node 1, zone   Normal
  pages free     318034
        spanned  520192
        present  518413
Node 2, zone   Normal
  pages free     301526
        spanned  520192
        present  518414
Node 3, zone   Normal
  pages free     301932
        spanned  520182
        present  518362
Node 4, zone      DMA
  pages free     31706
        spanned  32767
        present  32656
^^^^^^^^^^^^^^^^^^^^^^ Nope!  no huge pages allocated from here!

# now try to free the huge pages.

root@gwydyr(root):echo 0 >/proc/sys/vm/nr_hugepages
root@gwydyr(root):cat /sys/devices/system/node/node*/meminfo | grep HugeP
Node 0 HugePages_Total: 4294967283 <--- ???
Node 0 HugePages_Free:      0
Node 1 HugePages_Total:     0
Node 1 HugePages_Free:      0
Node 2 HugePages_Total:     0
Node 2 HugePages_Free:      0
Node 3 HugePages_Total:     0
Node 3 HugePages_Free:      0
Node 4 HugePages_Total:    13	<---??? they weren't really there to begin with!
Node 4 HugePages_Free:      0

# Apparently on remove, the pages were decremented from node 0 instead
of node 4 where they were accounted for on allocation, resulting in a
negative count on node 0 and the original 13 count still on node 4.  

------------------

I tried to "tighten up"  alloc_pages_node() to check the location of the
first zone in the selected zonelist, as discussed in previous exchange.
When I do this, I hit a BUG() in slub.c in
early_kmem_cache_node_alloc(), as it apparently can't handle new_slab()
returning a NULL page, even tho' it calls it with GFP_THISNODE.  Slub
should be able to handle memoryless nodes, right?  I'm looking for a
work around to this now.

Lee







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
