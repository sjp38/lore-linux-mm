Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 640BE6B0047
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 12:30:21 -0500 (EST)
Date: Tue, 9 Mar 2010 17:30:03 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] page-allocator: Under memory pressure, wait on
	pressure to relieve instead of congestion
Message-ID: <20100309173003.GH4883@csn.ul.ie>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie> <1268048904-19397-2-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1003090946180.28897@router.home> <4B966F93.9060207@linux.vnet.ibm.com> <alpine.DEB.2.00.1003091005310.28897@router.home> <20100309170123.GG4883@csn.ul.ie> <alpine.DEB.2.00.1003091109040.28897@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003091109040.28897@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 09, 2010 at 11:11:55AM -0600, Christoph Lameter wrote:
> On Tue, 9 Mar 2010, Mel Gorman wrote:
> 
> > Until it's timeout at least. It's still better than the current
> > situation of sleeping on congestion.
> 
> Congestion may clear if memory becomes available in other zones.
> 

I understand that.

> > The ideal would be waiting on a per-node basis. I'm just not liking having
> > to look up the node structure when freeing a patch of pages and making a
> > cache line in there unnecessarily hot.
> 
> The node structure (pgdat) contains the zone structures. If you know the
> type of zone then you can calculate the pgdat address.
> 

I know you can lookup the pgdat from the zone structure. The concern is that
the suggestion requires adding fields to the node structure that then become
hot in the free_page path when the per-cpu lists are being drained. This patch
also adds a hot cache line to the zone but at least it can be eliminated by
using zone->flags. The same optimisation does not apply to working on a
per-node basis.

Adding such a hot line is a big minus and the gain is that processes may
wake up slightly faster when under memory pressure. It's not a good trade-off.

> > > But then an overallocated node may stall processes. If that node is full
> > > of unreclaimable memory then the process may never wake up?
> >
> > Processes wake after a timeout.
> 
> Ok that limits it but still we may be waiting for no reason.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
