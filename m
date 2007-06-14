Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706140852150.29460@schroedinger.engr.sgi.com>
References: <20070612032055.GQ3798@us.ibm.com>
	 <1181660782.5592.50.camel@localhost> <20070612172858.GV3798@us.ibm.com>
	 <1181674081.5592.91.camel@localhost>
	 <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com>
	 <1181677473.5592.149.camel@localhost>
	 <Pine.LNX.4.64.0706121245200.7983@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0706121257290.7983@schroedinger.engr.sgi.com>
	 <20070612200125.GG3798@us.ibm.com> <1181748606.6148.19.camel@localhost>
	 <20070613175802.GP3798@us.ibm.com> <1181758874.6148.73.camel@localhost>
	 <Pine.LNX.4.64.0706131550520.32399@schroedinger.engr.sgi.com>
	 <1181836247.5410.85.camel@localhost>
	 <Pine.LNX.4.64.0706140852150.29460@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 14 Jun 2007 12:54:23 -0400
Message-Id: <1181840063.5410.146.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-06-14 at 08:57 -0700, Christoph Lameter wrote:
> On Thu, 14 Jun 2007, Lee Schermerhorn wrote:
> 
> > The point of all this is that, as you've pointed out, the original NUMA
> > and memory policy designs assumed a fairly symmetric system
> > configuration with all nodes populated with [similar amounts?] of
> > roughly equivalent memory.  That probably describes a majority of NUMA
> > systems, so the system should handle this well, as a default.  We still
> > need to be able to handle the less symmetric configs--with boot
> > parameters, sysctls, cpusets, ...--that specify non-default behavior,
> > and cause the generic code to do the right thing.  Certainly, the
> > generic code can't "fall over and die" in the presence of memoryless
> > nodes or other "interesting" configurations.
> 
> The hugepage distribution issues have to be handled by the hugepage code. 
> There is no point in adding inconsistencies in the definition of a 
> memoryless node to satisfy hugepage distribution issues on one platform.

I don't disagree.  I originally tried to fix this in the hugetlb
allocation code.  But, I was using zonelist internal knowledge [ensuring
that the first zone was on-node], but I recall that both you and Nish
didn't like this--huge page code having knowledge of zonelist internals.
That led me off to defining a node_populated_map that had the right
semantics for hugetlb fresh page allocation [for my platform, anyway].
Then, we started using the node_populated_map for other things and it
evolved to where alloc_pages_node() can leak off-node pages for some
platforms [mine :-(].  


> The memoryless node handling addresses one particular assymmetry: No 
> memory vs. some memory. The fine grained stuff that relates to particular 
> page types (like I do not want hugepages on my DMA node...) have to be 
> handled by the management of that particular page type. Here we need some 
> control over huge page distribution. There is already another case where 
> we may need to control the nodes that slab uses for its allocations. The 
> slab node restrictions have to be handled by the slab code. Same thing for 
> hugepages.
> 

If we agree that I can filter off-node pages in
alloc_fresh_huge_page_node(), freeing a page and returning NULL if it's
off-node, that will solve the problem for huge page setup.  

I'll try that atop your latest patch stream, once Nish has reposted his
huge page allocation set.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
