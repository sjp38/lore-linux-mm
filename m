Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m18NeXkV023647
	for <linux-mm@kvack.org>; Fri, 8 Feb 2008 18:40:33 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m18NeX0e212244
	for <linux-mm@kvack.org>; Fri, 8 Feb 2008 16:40:33 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m18NeWEM026958
	for <linux-mm@kvack.org>; Fri, 8 Feb 2008 16:40:33 -0700
Date: Fri, 8 Feb 2008 15:40:31 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 2/2] Explicitly retry hugepage allocations
Message-ID: <20080208234031.GE27150@us.ibm.com>
References: <20080206230726.GF3477@us.ibm.com> <20080206231243.GG3477@us.ibm.com> <Pine.LNX.4.64.0802061529480.22648@schroedinger.engr.sgi.com> <20080208171132.GE15903@us.ibm.com> <Pine.LNX.4.64.0802081117340.1654@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802081117340.1654@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: melgor@ie.ibm.com, apw@shadowen.org, agl@us.ibm.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 08.02.2008 [11:19:54 -0800], Christoph Lameter wrote:
> On Fri, 8 Feb 2008, Nishanth Aravamudan wrote:
> 
> > I also am not 100% positive on how I would test the result of such a
> > change, since there are not that many large-order allocations in the
> > kernel... Did you have any thoughts on that?
> 
> Boot the kernel with
> 
> 	slub_min_order=<whatever order you wish>
> 
> to get lots of allocations of a higher order.
> 
> You can run slub with huge pages by booting with
> 
> 	slub_min_order=9
> 
> this causes some benchmarks to run much faster...
> 
> In general the use of higher order pages is discouraged right now due
> to the page allocators flaky behavior when allocating pages but there
> are several projects that would benefit from that. Amoung them large
> bufferer support for the I/O layer and larger page support for the VM
> to reduce 4k page scanning overhead.

That all makes sense. However, for now, if it would be ok with you, just
make higher order allocations coming from hugetlb.c use the __REPEAT
logic I'm trying to add. If the method seems good in general, then we
just need to mark other locations (SLUB allocation paths?) with
__GFP_REPEAT. When slub_min_order <= PAGE_ALLOC_COSTLY_ORDER, then we
shouldn't see any difference and when it is greater, we should hit the
logic I added. Does that seem reasonable to you? I think it's a separate
idea, though, and I'd prefer keeping it in a separate patch, if that's
ok with you.

Thanks,
Nish


-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
