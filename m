Date: Tue, 15 Apr 2008 10:27:17 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Smarter retry of costly-order allocations
Message-ID: <20080415092717.GC20316@csn.ul.ie>
References: <20080411233500.GA19078@us.ibm.com> <20080411233553.GB19078@us.ibm.com> <20080415085154.GA20316@csn.ul.ie> <20080415020220.0a6998e2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080415020220.0a6998e2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, clameter@sgi.com, apw@shadowen.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (15/04/08 02:02), Andrew Morton didst pronounce:
> On Tue, 15 Apr 2008 09:51:55 +0100 Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On (11/04/08 16:35), Nishanth Aravamudan didst pronounce:
> > > Because of page order checks in __alloc_pages(), hugepage (and similarly
> > > large order) allocations will not retry unless explicitly marked
> > > __GFP_REPEAT. However, the current retry logic is nearly an infinite
> > > loop (or until reclaim does no progress whatsoever). For these costly
> > > allocations, that seems like overkill and could potentially never
> > > terminate.
> > > 
> > > Modify try_to_free_pages() to indicate how many pages were reclaimed.
> > > Use that information in __alloc_pages() to eventually fail a large
> > > __GFP_REPEAT allocation when we've reclaimed an order of pages equal to
> > > or greater than the allocation's order. This relies on lumpy reclaim
> > > functioning as advertised. Due to fragmentation, lumpy reclaim may not
> > > be able to free up the order needed in one invocation, so multiple
> > > iterations may be requred. In other words, the more fragmented memory
> > > is, the more retry attempts __GFP_REPEAT will make (particularly for
> > > higher order allocations).
> > > 
> > > Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> > 
> > Changelog is a lot clearer now. Thanks.
> > 
> > Tested-by: Mel Gorman <mel@csn.ul.ie>
> 
> Tested in what way though?
> 

It was tested as part of the full patchset as hugepage allocations was the
easiest trigger for __GFP_REPEAT usage. It was based on 2.6.25-rc9. Test
was as follows

1. kernbench as a smoke-test
2. hugetlbcap test
	1. Build 6 trees simultaneously on a 512MB laptop
		(should have caught if pagetable allocations getting broken
		 by the change in __GFP_REPEAT semantics)
	2. Allocate hugepages via proc under load
	3. Kill all compile jobs
	4. Allocate hugepages at rest
3. Run hugepages_get test which is the output I posted as part of patch 3

The main check was to see if pagetable allocations were getting messed
up. I didn't notice a problem on the laptop, but it's 1-way so I've
started tests on larger machines just in case.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
