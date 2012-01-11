Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 3CEAD6B006E
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 14:24:46 -0500 (EST)
Message-ID: <4F0DE1CE.5000006@redhat.com>
Date: Wed, 11 Jan 2012 14:23:58 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] make swapin readahead skip over holes
References: <20120109181023.7c81d0be@annuminas.surriel.com> <20120111165123.GF3910@csn.ul.ie>
In-Reply-To: <20120111165123.GF3910@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>

On 01/11/2012 11:51 AM, Mel Gorman wrote:
> On Mon, Jan 09, 2012 at 06:10:23PM -0500, Rik van Riel wrote:

>> +	get_swap_cluster(entry,&offset,&end_offset);
>> +
>> +	for (; offset<= end_offset ; offset++) {
>>   		/* Ok, do the async read-ahead now */
>>   		page = read_swap_cache_async(swp_entry(swp_type(entry), offset),
>>   						gfp_mask, vma, addr);
>>   		if (!page)
>> -			break;
>> +			continue;
>>   		page_cache_release(page);
>>   	}
>
> For a heavily fragmented swap file, this will result in more IO and
> the gamble is that pages nearby are needed soon. You say your virtual
> machines swapin faster and that does not surprise me. I also expect
> they need the data so it's a net win.

More IO operations, yes.  However, IO operations from nearby
blocks can often be done without incurring extra disk seeks,
because the disk head is already in the right place.

This seems to be born out by the fact that I saw swapin
rates increase from maybe 200-300kB/s to 5-15MB/s...

Even on some SSDs it could avoid some bank switches, though
of course there I would expect the effect to be much less
pronounced.

> There is an possibility that under memory pressure that swapping in
> more pages will cause more memory pressure (increased swapin causing
> clean page cache discards and pageout) and be an overall loss. This may
> be a net loss in some cases such as where the working set size is just
> over physical memory and the increased swapin causes a problem. I doubt
> this case is common but it is worth bearing in mind if future bug
> reports complain about increased swap activity.

True, there may be workloads that benefit from a smaller
page-cluster. The fact that the recently swapped in pages
are all put on the inactive anon list should help protect
the working set, too.

Another alternative may be a time based decision. If we
have swapped something out recently, go with a less
aggressive swapin readahead.

That would automatically give us fast swapin readahead
when in "memory hog just exited, let the system recover"
mode, and conservative swapin readahead in your situation.

However, that could still hurt badly if the system is just
moving the working set from one part of a program to another.

I suspect we will be faster off by having faster swap IO,
which this patch seems to provide.

>> -	si = swap_info[swp_type(entry)];
>> -	target = swp_offset(entry);
>> -	base = (target>>  our_page_cluster)<<  our_page_cluster;
>> -	end = base + (1<<  our_page_cluster);
>> -	if (!base)		/* first page is swap header */
>> -		base++;

>> +	si = swap_info[swp_type(entry)];
>> +	/* Round the begin down to a page_cluster boundary. */
>> +	offset = (offset>>  page_cluster)<<  page_cluster;
>
> Minor nit but it would feel more natural to me to see
>
> offset&  ~((1<<  page_cluster) - 1)
>
> but I understand that you are reusing the existing code.

Sure, I can do that.

While I'm there, I can also add that if (!base) base++
thing back in :)

>> +	*begin = offset;
>> +	/* Round the end up, but not beyond the end of the swap device. */
>> +	offset = offset + (1<<  page_cluster);
>> +	if (offset>  si->max)
>> +		offset = si->max;
>> +	*end = offset;
>>   	spin_unlock(&swap_lock);
>> -
>> -	/*
>> -	 * Indicate starting offset, and return number of pages to get:
>> -	 * if only 1, say 0, since there's then no readahead to be done.
>> -	 */
>> -	*offset = ++toff;
>> -	return nr_pages? ++nr_pages: 0;
>>   }
>
> This section deletes code which is nice but there is a
> problem. Your changelog says that this is duplicating the effort of
> read_swap_cache_async() which is true but what it does is
>
> 1. a swap cache lookup which will probably fail
> 2. alloc_page_vma()
> 3. radix_tree_preload()
> 4. swapcache_prepare
>     - calls __swap_duplicate()
>     - finds the hole, bails out
>
> That's a lot of work before the hole is found. Would it be worth
> doing a racy check in swapin_readahead without swap lock held before
> calling read_swap_cache_async()?

The problem is that without the swap_lock held, the swap_info
struct may disappear completely because of the swapin_readahead
happening concurrently with a swapoff.

I suspect that the CPU time spent doing 1-4 above will be
negligible compared to the amount of time spent doing disk IO,
but if there turns out to be a problem it should be possible
to move the swap hole identification closer to the top of
swap_cache_read_async().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
