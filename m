Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0E2PDNe025477
	for <linux-mm@kvack.org>; Fri, 13 Jan 2006 21:25:13 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0E2PBfW085052
	for <linux-mm@kvack.org>; Fri, 13 Jan 2006 21:25:13 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k0E2PAj8026194
	for <linux-mm@kvack.org>; Fri, 13 Jan 2006 21:25:11 -0500
Subject: Re: [PATCH] BUG: gfp_zone() not mapping zone modifiers correctly
	and bad ordering of fallback lists
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060113121652.114941a3.akpm@osdl.org>
References: <20060113155026.GA4811@skynet.ie>
	 <20060113121652.114941a3.akpm@osdl.org>
Content-Type: text/plain
Date: Fri, 13 Jan 2006 18:24:44 -0800
Message-Id: <1137205485.7130.81.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Mel Gorman <mel@csn.ul.ie>, lhms-devel@lists.sourceforge.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Whitcroft <apw@shadowen.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-01-13 at 12:16 -0800, Andrew Morton wrote:
> mel@csn.ul.ie (Mel Gorman) wrote:
> > build_zonelists() attempts to be smart, and uses highest_zone() so that it
> > doesn't attempt to call build_zonelists_node() for empty zones.  However,
> > build_zonelists_node() is smart enough to do the right thing by itself and
> > build_zonelists() already has the zone index that highest_zone() is meant
> > to provide. So, remove the unnecessary function highest_zone().
> 
> Dave, Andy: could you please have a think about the fallback list thing?

It's bogus.  Mel, I didn't take a close enough look when we were talking
about it earlier, and I fear I led you astray.  I misunderstood what it
was trying to do, and though that the zone_populated() check replaced
the highest_zone() check, when they actually do completely different
things.

highest_zone(zone_nr) actually means, given these "zone_bits" (which is
actually a set of __GFP_XXXX flags), what is the highest zone number
that we could possibly use to satisfy an allocation with those __GFP
flags.

We can't just get rid of it.  If we do, we might put a highmem zone in
the fallback list for a normal zone.  Badness.

So, Mel, I have couple of patches that I put together that the two
copies of build_zonelists(), and move some of build_zonelists() itself
down into build_zonelists_node(), including the highest_zone() call.
They're no good to you by themselves.  But, I think we can make a little
function to go into the loop in build_zonelists_node().  The new
function would ask, "can this zone be used to satisfy this GFP mask?"
We'd start the loop at the absolutely highest-numbered zone.  I think
that's a decently clean way to do what you want with the reclaim zone.  

In the process of investigating this, I noticed that Andy's nice
calculation and comment for GFP_ZONETYPES went away.  Might be nice to
put it back, just so we know how '5' got there:

http://www.kernel.org/git/gitweb.cgi?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=ac3461ad632e86e7debd871776683c05ef3ba4c6

Mel, you might also want to take a look at what Linus is suggesting
there.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
