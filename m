Date: Wed, 13 Sep 2006 14:40:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Get rid of zone_table
In-Reply-To: <1158180795.9141.158.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0609131425010.19380@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131340050.19059@schroedinger.engr.sgi.com>
 <1158180795.9141.158.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Sep 2006, Dave Hansen wrote:

> > The section_to_node table (if we still need it) is still the size of the 
> > number of sections but the individual elements are integers (which already 
> > saves 50% on 64 bit platforms) and we do not need to duplicate the entries 
> > per zone type. So even if we have to keep the table then we shrink it to 
> > 1/4th (32bit) or 1/8th )(64bit).
> 
> It doesn't feel like this is the best fit to go with sparsemem, but the
> impact is pretty tiny, and it does seem somewhat sensible to put it
> there.
> 
> A few concerns: is there a cache or readability impact from keeping this
> structure separate from the mem_section, when it is logically and
> functionally pretty paired with it?  It doesn't work with
> SPARSEMEM_EXTREME (it would just blow up horribly), and this part at
> least deserves a comment.  Is there any impact from making this a
> non-inlined call, unlike the old zonetable lookup?

I am not that familiar with sparsemem thats why I asked you about it at 
first. I doubt there is much of an impact from making this non inlined. 
IMHO it is clearer and easier to maintain if the code to do the section 
lookup is put with the code that generates the sections. Its also an 
exceptional thing that is not needed in general.

The main performance issue is probably the number of cachelines touched 
and the situation gets better here even for the worst case that we have to 
keep a separate lookup array. The array is denser.

For page_zone(page) one would have to do two lookups in the worst case. 
One to get the node id and then another one in NODE_DATA() to get to the 
zone. However, the NODE_DATA()is frequently referenced so its likely to be 
in cache. The existing 3 lookups for page_to_nid() are reduced 
to a single lookup in the section_to_node_table(). Before we had to
determine the zone and then fetch the corresponding pgdat address and then 
fetch the node number from the pgdat structure (yuck).

You could put the node number with the section (put it in a separate 
cacheline before the start of the memsection array?) but then it would be 
in a cacheline of its own. This way you have the node number of a set of 
neighboring sections in one cacheline. With a 128 byte cacheline you 
have the nodes for the 32 neighboring section of memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
