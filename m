Date: Thu, 7 Apr 2005 21:34:36 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: Excessive memory trapped in pageset lists
Message-ID: <20050408023436.GA1927@sgi.com>
References: <20050407211101.GA29069@sgi.com> <1112923481.21749.88.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1112923481.21749.88.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, Apr 07, 2005 at 06:24:41PM -0700, Dave Hansen wrote:
> On Thu, 2005-04-07 at 16:11 -0500, Jack Steiner wrote:
> >    28 pages/node/cpu * 512 cpus * 256nodes * 16384 bytes/page = 60GB  (Yikes!!!)
> ...
> > I have a couple of ideas for fixing this but it looks like Christoph is
> > actively making changes in this area. Christoph do you want to address
> > this issue or should I wait for your patch to stabilize?
> 
> What about only keeping the page lists populated for cpus which can
> locally allocate from the zone?
> 
> 	cpu_to_node(cpu) == page_nid(pfn_to_page(zone->zone_start_pfn)) 

Exactly. That is at the top of my list. What I haven't decided is whether to:

	- leave the list_heads for offnode pages in the per_cpu_pages
	  struct. Offnode lists would be unused but the amount of wasted space
	  is small - probably 0 because of the cacheline alignment 
	  of the per_cpu_pageset. This is the simplest solution
	  but is not clean because of the unused fields. Unless some
	  architectures want to control whether offnode pages
	  are kept in the lists (???).

	  	OR

	- remove the list_heads from the per_cpu_pageset and make it
	  a standalone array in the zone struct. Array size would be
	  MAX_CPUS_PER_NODE. I don't recall any notion of MAX_CPUS_PER_NODE
	  or a relative cpu number on a node (have I overlooked this?). 
	  This solution is cleaner in the long run but may involve more 
	  infrastructure than I wanted to get into at this point.

	  	OR

	- sane as above but have a SINGLE list_head per zone. The list
	  would be used by all cpus on the node. Thsi avoids the page coloring
	  issues I ran into earlier (see prev posting). Obviously, this requires 
	  a lock. However, only on-node cpus would normally take the lock. 
	  Another advantage of this scheme is that an offnode shaker could 
	  acquire the lock & drain the lists if memory became low.

I haven't fully thought thru these ideas. Maybe other alternatives would
be even better.... Suggestions????


> 
> There certainly aren't a lot of cases where frequent, persistent
> single-page allocations are occurring off-node, unless a node is empty.

Hmmmm. True, but one of our popular configurations consists of memory-only nodes.
I know of one site that has 240 memory-only nodes & 16 nodes with
both cpus & memory. For this configuration, most memory if offnode 
to EVERY cpu. (But I still don't want to cache offnode pages).


> If you go to an off-node 'struct zone', you're probably bouncing so many
> cachelines that you don't get any benefit from per-cpu-pages anyway.

Agree, although on the SGI systems, we set a global policy to roundrobin
all file pages across all nodes. However, I'm not suggesting we cache
offnode pages in the per_cpu_pageset. That gets us back to where we 
started - too much memory in percpu page lists. Also, creating a file
page already bounces a lot of cachelines around.

> 
> Maybe there could be a per-cpu-pages miss rate that's required to occur
> before the lists are even populated.  That would probably account better
> for cases where nodes are disproportionately populated with memory.
> This, along with the occasional flushing of the pages back into the
> general allocator if the miss rate isn't satisfied should give some good
> self-tuning behavior.

Makes sense.

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
