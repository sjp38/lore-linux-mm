Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 3B4346B0034
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 02:12:04 -0400 (EDT)
Date: Thu, 11 Jul 2013 15:12:01 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 1/5] mm, page_alloc: support multiple pages allocation
Message-ID: <20130711061201.GA2400@lge.com>
References: <1372840460-5571-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1372840460-5571-2-git-send-email-iamjoonsoo.kim@lge.com>
 <51DDE5BA.9020800@intel.com>
 <20130711010248.GB7756@lge.com>
 <51DE44CC.2070700@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51DE44CC.2070700@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 10, 2013 at 10:38:20PM -0700, Dave Hansen wrote:
> On 07/10/2013 06:02 PM, Joonsoo Kim wrote:
> > On Wed, Jul 10, 2013 at 03:52:42PM -0700, Dave Hansen wrote:
> >> On 07/03/2013 01:34 AM, Joonsoo Kim wrote:
> >>> -		if (page)
> >>> +		do {
> >>> +			page = buffered_rmqueue(preferred_zone, zone, order,
> >>> +							gfp_mask, migratetype);
> >>> +			if (!page)
> >>> +				break;
> >>> +
> >>> +			if (!nr_pages) {
> >>> +				count++;
> >>> +				break;
> >>> +			}
> >>> +
> >>> +			pages[count++] = page;
> >>> +			if (count >= *nr_pages)
> >>> +				break;
> >>> +
> >>> +			mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
> >>> +			if (!zone_watermark_ok(zone, order, mark,
> >>> +					classzone_idx, alloc_flags))
> >>> +				break;
> >>> +		} while (1);
> >>
> >> I'm really surprised this works as well as it does.  Calling
> >> buffered_rmqueue() a bunch of times enables/disables interrupts a bunch
> >> of times, and mucks with the percpu pages lists a whole bunch.
> >> buffered_rmqueue() is really meant for _single_ pages, not to be called
> >> a bunch of times in a row.
> >>
> >> Why not just do a single rmqueue_bulk() call?
> > 
> > rmqueue_bulk() needs a zone lock. If we allocate not so many pages,
> > for example, 2 or 3 pages, it can have much more overhead rather than
> > allocationg 1 page multiple times. So, IMHO, it is better that
> > multiple pages allocation is supported on top of percpu pages list.
> 
> It makes _zero_ sense to be doing a number of buffered_rmqueue() calls
> that are approaching the size of the percpu pages batches.  If you end
> up doing that, you pay both the overhead in manipulating both the percpu
> page data _and_ the buddy lists.
> 
> You're probably right for small numbers of pages.  But, if we're talking
> about things that are more than, say, 100 pages (isn't the pcp batch
> size clamped to 128 4k pages?) you surely don't want to be doing
> buffered_rmqueue().

Yes, you are right.
Firstly, I thought that I can use this for readahead. On my machine,
readahead reads (maximum) 32 pages in advance if faulted. And batch size
of percpu pages list is close to or larger than 32 pages
on today's machine. So I didn't consider more than 32 pages before.
But to cope with a request for more pages, using rmqueue_bulk() is
a right way. How about using rmqueue_bulk() conditionally?

> 
> I'd also like to see some scalability numbers on this.  How do your
> tests look when all the CPUs on the system are hammering away?

What test do you mean?
Please elaborate on this more.

> > And I think that enables/disables interrupts a bunch of times help
> > to avoid a latency problem. If we disable interrupts until the whole works
> > is finished, interrupts can be handled too lately.
> > free_hot_cold_page_list() already do enables/disalbed interrupts a bunch of
> > times.
> 
> I don't think interrupt latency is going to be a problem on the scale
> we're talking about here.  There are much, much, much worse offenders in
> the kernel.

Hmm, rmqueue_bulk() doesn't stop until all requested pages are allocated.
If we request too many pages (1024 pages or more), interrupt latency can
be a problem.

Thanks!!

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
