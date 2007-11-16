Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAG0waBJ004169
	for <linux-mm@kvack.org>; Thu, 15 Nov 2007 19:58:36 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lAG0waUE111332
	for <linux-mm@kvack.org>; Thu, 15 Nov 2007 17:58:36 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAG0wZvv002319
	for <linux-mm@kvack.org>; Thu, 15 Nov 2007 17:58:36 -0700
Date: Thu, 15 Nov 2007 16:58:34 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH][UPDATED] hugetlb: retry pool allocation attempts
Message-ID: <20071116005834.GG21245@us.ibm.com>
References: <20071115201053.GA21245@us.ibm.com> <20071115201826.GB21245@us.ibm.com> <20071116001911.GB7372@skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071116001911.GB7372@skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: wli@holomorphy.com, kenchen@google.com, david@gibson.dropbear.id.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 16.11.2007 [00:19:11 +0000], Mel Gorman wrote:
> On (15/11/07 12:18), Nishanth Aravamudan didst pronounce:
> > On 15.11.2007 [12:10:53 -0800], Nishanth Aravamudan wrote:
> > > Currently, successive attempts to allocate the hugepage pool via the
> > > sysctl can result in the following sort of behavior (assume each attempt
> > > is trying to grow the pool by 100 hugepages, starting with 100 hugepages
> > > in the pool, on x86_64):
> > 
> > Sigh, same patch, fixed up a few checkpatch issues with long lines.
> > Sorry for the noise.
> > 
> > hugetlb: retry pool allocation attempts
> > 
> > Currently, successive attempts to allocate the hugepage pool via the
> > sysctl can result in the following sort of behavior (assume each attempt
> > is trying to grow the pool by 100 hugepages, starting with 100 hugepages
> > in the pool, on x86_64):

<snip>

> > Modify __alloc_pages() to retry GFP_REPEAT COSTLY_ORDER allocations up
> > to COSTLY_ORDER_RETRY_ATTEMPTS times, which I've set to 5, and use
> > GFP_REPEAT in the hugetlb pool allocation. 5 seems to give reasonable
> > results for x86, x86_64 and ppc64, but I'm not sure how to come up with
> > the "best" number here (suggestions are welcome!). With this patch
> > applied, the same box that gave the above results now gives:

<snip>

> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -33,6 +33,12 @@
> >   * will not.
> >   */
> >  #define PAGE_ALLOC_COSTLY_ORDER 3
> > +/*
> > + * COSTLY_ORDER_RETRY_ATTEMPTS is the number of retry attempts for
> > + * allocations above PAGE_ALLOC_COSTLY_ORDER with __GFP_REPEAT
> > + * specified.
> 
> Perhaps add a note here saying that __GFP_REPEAT for allocations below
> PAGE_ALLOC_COSTLY_ORDER behaves like __GFP_NOFAIL?

Good idea.

<snip>

> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c

<snip>

> > @@ -1622,16 +1622,25 @@ nofail_alloc:
> >  	 *
> >  	 * In this implementation, __GFP_REPEAT means __GFP_NOFAIL for order
> >  	 * <= 3, but that may not be true in other implementations.
> > +	 *
> > +	 * For order > 3, __GFP_REPEAT means try to reclaim memory 5
> > +	 * times, but that may not be true in other implementations.
> 
> magic number alert. s/3/PAGE_ALLOC_COSTLY_ORDER and
> s/5/COSTLY_ORDER_RETRY_ATTEMPTS

I was trying to avoid changing too much outside of the context of the
intents of the patch, but this does help clarify things.

> >  	 */
> > -	do_retry = 0;
> >  	if (!(gfp_mask & __GFP_NORETRY)) {
> > -		if ((order <= PAGE_ALLOC_COSTLY_ORDER) ||
> > -						(gfp_mask & __GFP_REPEAT))
> > -			do_retry = 1;
> > +		if (gfp_mask & __GFP_REPEAT) {
> > +			if (order <= PAGE_ALLOC_COSTLY_ORDER) {
> > +				do_retry_attempts = 1;
> > +			} else {
> > +				if (do_retry_attempts >
> > +					COSTLY_ORDER_RETRY_ATTEMPTS)
> > +					goto nopage;
> > +				do_retry_attempts += 1;
> > +			}
> 
> Seems fair enough logic. The second if looks a little ugly but I don't
> see a nicer way of expressing it right now.

Yeah, I'm open to suggestions. I also didn't want to always increment
do_retry_attempts, because __NOFAIL might lead to it growing without
bound and wrapping...

Hrm, looking closer, this hunk is wrong anyways... the original code
says this, I think:

  if gfp_mask does not specify NORETRY
	if order is less than or equal to COSTLY_ORDER
	or gpf_mask specifies REPEAT
		engage in NOFAIL behavior

My changes lead to:

  if gfp_mask does not specify NORETRY
	if gfp_mask does specify REPEAT
		if order is less than or equal to COSTLY_ORDER
			engage in NOFAIL behavior

So before, if an allocation is less than COSTLY_ORDER regardless of
__GFP_REPEAT's state in the gfp_mask, we upgrade the behavior to NOFAIL.
That's my reading, at least. Easy enough to keep that behavior with my
code, but the comment sort of implies a different behavior. I'll update
the comment further in my patch to reflect the cases, I think.

> > +		}
> >  		if (gfp_mask & __GFP_NOFAIL)
> > -			do_retry = 1;
> > +			do_retry_attempts = 1;
> >  	}
> > -	if (do_retry) {
> > +	if (do_retry_attempts) {
> >  		congestion_wait(WRITE, HZ/50);
> >  		goto rebalance;
> >  	}
> > 
> 
> Overall, seems fine to me.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
