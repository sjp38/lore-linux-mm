Date: Fri, 16 Nov 2007 00:10:14 +0000
Subject: Re: [PATCH][UPDATED] hugetlb: retry pool allocation attempts
Message-ID: <20071116001014.GA7372@skynet.ie>
References: <20071115201053.GA21245@us.ibm.com> <20071115201826.GB21245@us.ibm.com> <1195162475.7078.224.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1195162475.7078.224.camel@localhost>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, wli@holomorphy.com, kenchen@google.com, david@gibson.dropbear.id.au, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On (15/11/07 13:34), Dave Hansen didst pronounce:
> On Thu, 2007-11-15 at 12:18 -0800, Nishanth Aravamudan wrote:
> > b) __alloc_pages() does not currently retry allocations for order >
> > PAGE_ALLOC_COSTLY_ORDER.
> 
> ... when __GFP_REPEAT has not been specified, right?
> 

Currently if hugetlbfs specified __GFP_RELEAT, it would end up trying to
allocate indefinitly - that does not sound like sane behaviour. Indefinite
retries for small allocations makes some sense, but for the larger allocs
it should give up after a while as __GFP_REPEAT is documented to do.

> > Modify __alloc_pages() to retry GFP_REPEAT COSTLY_ORDER allocations up
> > to COSTLY_ORDER_RETRY_ATTEMPTS times, which I've set to 5, and use
> > GFP_REPEAT in the hugetlb pool allocation. 5 seems to give reasonable
> > results for x86, x86_64 and ppc64, but I'm not sure how to come up with
> > the "best" number here (suggestions are welcome!). With this patch
> > applied, the same box that gave the above results now gives: 
> 
> Coding in an explicit number of retries like this seems a bit hackish to
> me.  Retrying the allocations N times internally (through looping)
> should give roughly the same number of huge pages that retrying them N
> times externally (from the /proc file). 

The third case is where the pool is being dynamically resized and this
allocation attempt is happening via the mmap() or fault paths. In those cases
it should be making a serious attempt to satisfy the allocation without
peppering retry logic in multiple places when __GFP_REPEAT is meant to do
what is desired.

>Does doing another ~50
> allocations get you to the same number of huge pages?
> 
> What happens if you *only* specify GFP_REPEAT from hugetlbfs?
> 

Potentially, it will stay forever in a reclaim loop.

> I think you're asking a bit much of the page allocator (and reclaim)
> here. 

The ideal is that direct reclaim is only entered once. In practice, it
may not work as even if lumpy reclaim gets the necessary contiguous
pages, there is no guarantee that another process will take the pages
because a process does not take ownership of those pages. Fixing that
would be pretty invasive and while I expect those patches to exist
eventually, they are pretty far away.

Ideally Nish could just say "__GFP_REPEAT" in the flags but it looks
like he had alter slightly how __GFP_REPEAT behaves so it is not an
alias for __GFP_NOFAIL.

> There is a discrete amount of memory pressure applied for each
> allocator request.  Increasing the number of requests will virtually
> always increase the memory pressure and make more pages available.
> 

For a __GFP_REPEAT allocation, it says "try and pressure more because I
really could do with this page" as opposed to failing.

> What is the actual behavior that you want to get here?  Do you want that
> 34th request to always absolutely plateau the number of huge pages?
> 

I believe the desired behaviour is that for larger allocations specifying
__GFP_REPEAT to apply a bit more pressure than might have been used
otherwise.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
