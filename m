Subject: Re: Suspect use of "first_zones_zonelist()"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080422161524.GA27624@csn.ul.ie>
References: <1208877444.5534.34.camel@localhost>
	 <20080422161524.GA27624@csn.ul.ie>
Content-Type: text/plain
Date: Tue, 22 Apr 2008 13:10:15 -0400
Message-Id: <1208884215.5534.57.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-04-22 at 17:15 +0100, Mel Gorman wrote:
> On (22/04/08 11:17), Lee Schermerhorn didst pronounce:
> > Mel:
> > 
> > I was testing my "lazy migration" patches and noticed something
> > interesting about first_zones_zonelist().  I use this function to find
> > the target node for MPOL_BIND policy to determine if a page is
> > "misplaced" and should be migrated.  In my testing, I found that I was
> > always "off by one".  E.g., if my mempolicy nodemask contained only node
> > 2, I'd migrate to node 3.  If it contained node 3, I'd migrate to node 0
> > [on a 4-node platform], etc.
> > 
> > Following the usage in slab_node(), I was doing something like:
> > 
> > zr = first_zones_zonelist(node_zonelist(nid, ...), gfp_zone(...),
> > &pol->v.vnodes, &dummy);
> > newnid = zonelist_node_idx(zr);
> > 
> > Turns out that the return value is the NEXT zoneref in the zonelist
> > AFTER the one of interest
> 
> Yes, the intention was that the cursor (zr) was meant to be pointing to
> the next reference likely to be of interest. Bad usage of the cursor was
> a pretty stupid mistake particularly as the cursor was implemented this
> way intentionally.
> 
> /me beats self with clue-stick
> 
> > --i.e., the first that satisfies any nodemask
> > constraint.  I renamed 'dummy' to 'zone', ignore the return value and
> > use:  newnid = zone->node.  [I guess I could use zonelist_node_idx(zr
> > -1) as well.] 
> 
> zr - 1 would be vunerable to the iterator implementation changing.

Ah, good point.  Shouldn't peek under the covers like that.

> 
> >  This results in page migration to the expected node.
> > 
> 
> This use of zone instead of the zoneref cursor should be made throughout.
> 
> > Anyway, after discovering this, I checked other usages of
> > first_zones_zonelist() outside of the iterator macros, and I THINK they
> > might be making the same mistake?
> > 
> 
> Yes, you're right.
> 
> > Here's a patch that "fixes" these.  Do you agree?  Or am I
> > misunderstanding this area [again!]?
> > 
> 
> No, I screwed up with the use of cursors and didn't get caught for it as
> the effect would be very difficult to spot normally. I extended your patch
> slightly below to catch the other callers. Can you take a read-through please?

OK.  Looks good.  I see I missed one case.

A suggestion.  How about enhancing the comment [maybe a kernel doc
block?] on first_zones_zonelist() to explain that it returns the zone
via the zone parameter and that the return value is a cursor for
iterators?  Perhaps similarly for next_zones_zonelist() in mmzone.c?

Or would you like me to take a cut at this?

Lee

<patch snipped>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
