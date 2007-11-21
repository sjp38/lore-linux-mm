Date: Wed, 21 Nov 2007 14:28:04 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Page allocator: Get rid of the list of cold pages
In-Reply-To: <20071121222059.GC31674@csn.ul.ie>
Message-ID: <Pine.LNX.4.64.0711211421550.3809@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711141148200.18811@schroedinger.engr.sgi.com>
 <20071115162706.4b9b9e2a.akpm@linux-foundation.org> <20071121222059.GC31674@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, apw@shadowen.org, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Nov 2007, Mel Gorman wrote:

> 1. In general, the split lists are faster than the combined list
> 2. Disabling Per-CPU has comparable performance to having the lists

That is only true for the single threaded case (actually I am measuring a 
slight performance benefit if I switch them off). If you have multiple 
processes allocating from the same zone then you can get the zone locks 
hot. That was the reason for the recent regression in SLUB. The networking
layer went from an order 0 alloc to order 1. Zonelock contention then
dropped performance by 50% on an 8p! The potential for lock contention is 
higher the more processor per nodeare involved. So you are not going to 
see this as high on a standard NUMA config with 2p per node.

The main point at this juncture of the pcp lists seems to be avoiding 
zone lock contention! The overhead of extracting a page from the buddy 
lists is not such a problem.

> single-pcplist-batch8: This is Christophs patch with pcp->high == 8*batch
> 	as suggested by Martin Bligh (I agreed with him that keeping lists
> 	the same size made sense)

Ack.

I have not had a look at the details of your performance measurements yet. 
More later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
