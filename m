Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAFLZ7Hd005123
	for <linux-mm@kvack.org>; Thu, 15 Nov 2007 16:35:07 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAFLYwxB700552
	for <linux-mm@kvack.org>; Thu, 15 Nov 2007 16:35:00 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAFLYn2L021570
	for <linux-mm@kvack.org>; Thu, 15 Nov 2007 14:34:49 -0700
Subject: Re: [PATCH][UPDATED] hugetlb: retry pool allocation attempts
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071115201826.GB21245@us.ibm.com>
References: <20071115201053.GA21245@us.ibm.com>
	 <20071115201826.GB21245@us.ibm.com>
Content-Type: text/plain
Date: Thu, 15 Nov 2007 13:34:35 -0800
Message-Id: <1195162475.7078.224.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: wli@holomorphy.com, kenchen@google.com, david@gibson.dropbear.id.au, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-11-15 at 12:18 -0800, Nishanth Aravamudan wrote:
> b) __alloc_pages() does not currently retry allocations for order >
> PAGE_ALLOC_COSTLY_ORDER.

... when __GFP_REPEAT has not been specified, right?

> Modify __alloc_pages() to retry GFP_REPEAT COSTLY_ORDER allocations up
> to COSTLY_ORDER_RETRY_ATTEMPTS times, which I've set to 5, and use
> GFP_REPEAT in the hugetlb pool allocation. 5 seems to give reasonable
> results for x86, x86_64 and ppc64, but I'm not sure how to come up with
> the "best" number here (suggestions are welcome!). With this patch
> applied, the same box that gave the above results now gives: 

Coding in an explicit number of retries like this seems a bit hackish to
me.  Retrying the allocations N times internally (through looping)
should give roughly the same number of huge pages that retrying them N
times externally (from the /proc file).  Does doing another ~50
allocations get you to the same number of huge pages?

What happens if you *only* specify GFP_REPEAT from hugetlbfs?

I think you're asking a bit much of the page allocator (and reclaim)
here.  There is a discrete amount of memory pressure applied for each
allocator request.  Increasing the number of requests will virtually
always increase the memory pressure and make more pages available.

What is the actual behavior that you want to get here?  Do you want that
34th request to always absolutely plateau the number of huge pages?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
