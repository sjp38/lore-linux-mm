Date: Fri, 16 Nov 2007 00:19:11 +0000
Subject: Re: [PATCH][UPDATED] hugetlb: retry pool allocation attempts
Message-ID: <20071116001911.GB7372@skynet.ie>
References: <20071115201053.GA21245@us.ibm.com> <20071115201826.GB21245@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20071115201826.GB21245@us.ibm.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: wli@holomorphy.com, kenchen@google.com, david@gibson.dropbear.id.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (15/11/07 12:18), Nishanth Aravamudan didst pronounce:
> On 15.11.2007 [12:10:53 -0800], Nishanth Aravamudan wrote:
> > Currently, successive attempts to allocate the hugepage pool via the
> > sysctl can result in the following sort of behavior (assume each attempt
> > is trying to grow the pool by 100 hugepages, starting with 100 hugepages
> > in the pool, on x86_64):
> 
> Sigh, same patch, fixed up a few checkpatch issues with long lines.
> Sorry for the noise.
> 
> hugetlb: retry pool allocation attempts
> 
> Currently, successive attempts to allocate the hugepage pool via the
> sysctl can result in the following sort of behavior (assume each attempt
> is trying to grow the pool by 100 hugepages, starting with 100 hugepages
> in the pool, on x86_64):
> 
> Attempt 1: 200 hugepages
> Attempt 2: 300 hugepages
> ...
> Attempt 33: 3400 hugepages
> Attempt 34: 3438 hugepages
> Attempt 35: 3438 hugepages
> Attempt 36: 3438 hugepages
> Attempt 37: 3439 hugepages
> Attempt 38: 3440 hugepages
> Attempt 39: 3441 hugepages
> Attempt 40: 3441 hugepages
> Attempt 41: 3442 hugepages
> ...
> 
> I think, in an ideal world, we would not have a situation where the
> hugepage pool grows on an attempt after a previous attempt has failed
> (we should have freed up sufficient memory earlier). We also wouldn't
> get successive single-page allocations, but would have a single
> larger-size allocation. There are two reasons this doesn't happen
> currently:
> 
> a) hugetlb pool allocation calls do not specify __GFP_REPEAT to ask the
> VM to retry the allocations (invoking reclaim to help the requests
> succeed).
> 
> b) __alloc_pages() does not currently retry allocations for order >
> PAGE_ALLOC_COSTLY_ORDER.
> 
> Modify __alloc_pages() to retry GFP_REPEAT COSTLY_ORDER allocations up
> to COSTLY_ORDER_RETRY_ATTEMPTS times, which I've set to 5, and use
> GFP_REPEAT in the hugetlb pool allocation. 5 seems to give reasonable
> results for x86, x86_64 and ppc64, but I'm not sure how to come up with
> the "best" number here (suggestions are welcome!). With this patch
> applied, the same box that gave the above results now gives:
> 
> Attempt 1: 200 hugepages
> Attempt 2: 300 hugepages
> ...
> Attempt 33: 3400 hugepages
> Attempt 34: 3438 hugepages
> Attempt 35: 3442 hugepages
> Attempt 36: 3443 hugepages
> Attempt 37: 3443 hugepages
> Attempt 38: 3443 hugepages
> Attempt 39: 3443 hugepages
> Attempt 40: 3443 hugepages
> Attempt 41: 3444 hugepages
> ...
> 
> While the patch makes things better (we get more hugepages sooner), but
> we still get an allocation success (of one hugepage) after getting a few
> failures in a row. But, even with 10 retry attempts, I got similar
> results. Determining the perfect number, I expect, would require know
> the current/future I/O characteristics and current/future system
> activity -- in lieu of this prescience, this heuristic does seem to
> improve things and does not require userspace applications to implement
> their own retry logic (or, more accurately, makes those userspace
> retries more effective).
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> ---
> $ git show HEAD | ./scripts/checkpatch.pl -
> Your patch has no obvious style problems and is ready for submission.
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 4c4522a..c4e36ba 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -33,6 +33,12 @@
>   * will not.
>   */
>  #define PAGE_ALLOC_COSTLY_ORDER 3
> +/*
> + * COSTLY_ORDER_RETRY_ATTEMPTS is the number of retry attempts for
> + * allocations above PAGE_ALLOC_COSTLY_ORDER with __GFP_REPEAT
> + * specified.

Perhaps add a note here saying that __GFP_REPEAT for allocations below
PAGE_ALLOC_COSTLY_ORDER behaves like __GFP_NOFAIL?

> + */
> +#define COSTLY_ORDER_RETRY_ATTEMPTS 5
>  
>  #define MIGRATE_UNMOVABLE     0
>  #define MIGRATE_RECLAIMABLE   1
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 8b809ec..0eb2953 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -171,7 +171,8 @@ static struct page *alloc_fresh_huge_page_node(int nid)
>  	struct page *page;
>  
>  	page = alloc_pages_node(nid,
> -		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|__GFP_NOWARN,
> +		htlb_alloc_mask|__GFP_COMP|__GFP_THISNODE|
> +						__GFP_REPEAT|__GFP_NOWARN,
>  		HUGETLB_PAGE_ORDER);
>  	if (page) {
>  		set_compound_page_dtor(page, free_huge_page);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index da69d83..3fcedda 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1470,7 +1470,7 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order,
>  	struct page *page;
>  	struct reclaim_state reclaim_state;
>  	struct task_struct *p = current;
> -	int do_retry;
> +	int do_retry_attempts = 0;
>  	int alloc_flags;
>  	int did_some_progress;
>  
> @@ -1622,16 +1622,25 @@ nofail_alloc:
>  	 *
>  	 * In this implementation, __GFP_REPEAT means __GFP_NOFAIL for order
>  	 * <= 3, but that may not be true in other implementations.
> +	 *
> +	 * For order > 3, __GFP_REPEAT means try to reclaim memory 5
> +	 * times, but that may not be true in other implementations.

magic number alert. s/3/PAGE_ALLOC_COSTLY_ORDER and
s/5/COSTLY_ORDER_RETRY_ATTEMPTS

>  	 */
> -	do_retry = 0;
>  	if (!(gfp_mask & __GFP_NORETRY)) {
> -		if ((order <= PAGE_ALLOC_COSTLY_ORDER) ||
> -						(gfp_mask & __GFP_REPEAT))
> -			do_retry = 1;
> +		if (gfp_mask & __GFP_REPEAT) {
> +			if (order <= PAGE_ALLOC_COSTLY_ORDER) {
> +				do_retry_attempts = 1;
> +			} else {
> +				if (do_retry_attempts >
> +					COSTLY_ORDER_RETRY_ATTEMPTS)
> +					goto nopage;
> +				do_retry_attempts += 1;
> +			}

Seems fair enough logic. The second if looks a little ugly but I don't
see a nicer way of expressing it right now.

> +		}
>  		if (gfp_mask & __GFP_NOFAIL)
> -			do_retry = 1;
> +			do_retry_attempts = 1;
>  	}
> -	if (do_retry) {
> +	if (do_retry_attempts) {
>  		congestion_wait(WRITE, HZ/50);
>  		goto rebalance;
>  	}
> 

Overall, seems fine to me.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
