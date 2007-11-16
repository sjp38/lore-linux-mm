Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAG0k3n0000639
	for <linux-mm@kvack.org>; Thu, 15 Nov 2007 19:46:03 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAG0k34e422120
	for <linux-mm@kvack.org>; Thu, 15 Nov 2007 19:46:03 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAG0k2Sa030456
	for <linux-mm@kvack.org>; Thu, 15 Nov 2007 19:46:02 -0500
Date: Thu, 15 Nov 2007 16:46:01 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH][UPDATED] hugetlb: retry pool allocation attempts
Message-ID: <20071116004601.GF21245@us.ibm.com>
References: <20071115201053.GA21245@us.ibm.com> <20071115201826.GB21245@us.ibm.com> <1195162475.7078.224.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1195162475.7078.224.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: wli@holomorphy.com, kenchen@google.com, david@gibson.dropbear.id.au, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On 15.11.2007 [13:34:35 -0800], Dave Hansen wrote:
> On Thu, 2007-11-15 at 12:18 -0800, Nishanth Aravamudan wrote:
> > b) __alloc_pages() does not currently retry allocations for order >
> > PAGE_ALLOC_COSTLY_ORDER.
> 
> ... when __GFP_REPEAT has not been specified, right?

Err, yes, sorry -- will fix the commit message. If __GFP_REPEAT is set,
though, it is translated directly to __GFP_NOFAIL.

> > Modify __alloc_pages() to retry GFP_REPEAT COSTLY_ORDER allocations
> > up to COSTLY_ORDER_RETRY_ATTEMPTS times, which I've set to 5, and
> > use GFP_REPEAT in the hugetlb pool allocation. 5 seems to give
> > reasonable results for x86, x86_64 and ppc64, but I'm not sure how
> > to come up with the "best" number here (suggestions are welcome!).
> > With this patch applied, the same box that gave the above results
> > now gives: 
> 
> Coding in an explicit number of retries like this seems a bit hackish
> to me.  Retrying the allocations N times internally (through looping)
> should give roughly the same number of huge pages that retrying them N
> times externally (from the /proc file).  Does doing another ~50
> allocations get you to the same number of huge pages?

Yes, in that first example, the userspace shell script, which is just
repeatedly trying to grow the pool by 100 hugepages eventually gets to
the same maximum value, just slower.

> What happens if you *only* specify GFP_REPEAT from hugetlbfs?

We get __NOFAIL behavior, as I understand it -- I haven't tried this,
though. And it seems undesirable to even have that semantic in hugetlb
code.

> I think you're asking a bit much of the page allocator (and reclaim)
> here.  There is a discrete amount of memory pressure applied for each
> allocator request.  Increasing the number of requests will virtually
> always increase the memory pressure and make more pages available.

I'm not sure how I follow that this is "a bit much"? It seems like it is
reasonable to try a little harder to satisfy a larger order request, if
the callee specified as much.

> What is the actual behavior that you want to get here?  Do you want
> that 34th request to always absolutely plateau the number of huge
> pages?

I think I said this in the commit message, but yes, in an ideal world,
we'd never have a sequence of requests where a particular number of
hugepages are requested (X) but the kernel allocates fewer, then the
same request is made and more hugepages are allocated (due to the
increased memory pressure). That may mean waiting a long time in the
kernel, though, so I figured this compromise of some effort (not
necessarliy best effort, I suppose) for trying to satisfy the request
gets us a little closer, at least.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
