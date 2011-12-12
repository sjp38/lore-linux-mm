Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id EF3626B01A2
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 12:20:18 -0500 (EST)
Date: Mon, 12 Dec 2011 17:20:15 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02/11] mm: compaction: introduce
 isolate_{free,migrate}pages_range().
Message-ID: <20111212172015.GL3277@csn.ul.ie>
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
 <1321634598-16859-3-git-send-email-m.szyprowski@samsung.com>
 <20111212140728.GC3277@csn.ul.ie>
 <op.v6dub1ms3l0zgt@mpn-glaptop>
 <20111212163052.GK3277@csn.ul.ie>
 <op.v6dx7bo43l0zgt@mpn-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <op.v6dx7bo43l0zgt@mpn-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Mon, Dec 12, 2011 at 05:46:13PM +0100, Michal Nazarewicz wrote:
> On Mon, 12 Dec 2011 17:30:52 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> 
> >On Mon, Dec 12, 2011 at 04:22:39PM +0100, Michal Nazarewicz wrote:
> >>> <SNIP>
> >>>
> >>>>+		if (!pfn_valid_within(pfn))
> >>>>+			goto skip;
> >>>
> >>>The flow of this function in general with gotos of skipped and next
> >>>is confusing in comparison to the existing function. For example,
> >>>if this PFN is not valid, and no freelist is provided, then we call
> >>>__free_page() on a PFN that is known to be invalid.
> >>>
> >>>>+		++nr_scanned;
> >>>>+
> >>>>+		if (!PageBuddy(page)) {
> >>>>+skip:
> >>>>+			if (freelist)
> >>>>+				goto next;
> >>>>+			for (; start < pfn; ++start)
> >>>>+				__free_page(pfn_to_page(pfn));
> >>>>+			return 0;
> >>>>+		}
> >>>
> >>>So if a PFN is valid and !PageBuddy and no freelist is provided, we
> >>>call __free_page() on it regardless of reference count. That does not
> >>>sound safe.
> >>
> >>Sorry about that.  It's a bug in the code which was caught later on.  The
> >>code should read ???__free_page(pfn_to_page(start))???.
> 
> On Mon, 12 Dec 2011 17:30:52 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> >That will call free on valid PFNs but why is it safe to call
> >__free_page() at all?  You say later that CMA requires that all
> >pages in the range be valid but if the pages are in use, that does
> >not mean that calling __free_page() is safe. I suspect you have not
> >seen a problem because the pages in the range were free as expected
> >and not in use because of MIGRATE_ISOLATE.
> 
> All pages from [start, pfn) have passed through the loop body which
> means that they are valid and they have been removed from buddy (for
> caller's use). Also, because of split_free_page(), all of those pages
> have been split into 0-order pages. 

Ah, I see. Even though you are not putting the pages on a freelist, the
function still returns with an elevated reference count and it's up to
the caller to find them again.

> Therefore, in error recovery, to
> undo what the loop has done so far, we put give back to buddy by
> calling __free_page() on each 0-order page.
> 

Ok.

> >>>> 		/* Found a free page, break it into order-0 pages */
> >>>> 		isolated = split_free_page(page);
> >>>> 		total_isolated += isolated;
> >>>>-		for (i = 0; i < isolated; i++) {
> >>>>-			list_add(&page->lru, freelist);
> >>>>-			page++;
> >>>>+		if (freelist) {
> >>>>+			struct page *p = page;
> >>>>+			for (i = isolated; i; --i, ++p)
> >>>>+				list_add(&p->lru, freelist);
> >>>> 		}
> >>>>
> >>>>-		/* If a page was split, advance to the end of it */
> >>>>-		if (isolated) {
> >>>>-			blockpfn += isolated - 1;
> >>>>-			cursor += isolated - 1;
> >>>>-		}
> >>>>+next:
> >>>>+		pfn += isolated;
> >>>>+		page += isolated;
> >>>
> >>>The name isolated is now confusing because it can mean either
> >>>pages isolated or pages scanned depending on context. Your patch
> >>>appears to be doing a lot more than is necessary to convert
> >>>isolate_freepages_block into isolate_freepages_range and at this point,
> >>>it's unclear why you did that.
> >>
> >>When CMA uses this function, it requires all pages in the range to be valid
> >>and free. (Both conditions should be met but you never know.)
> 
> To be clear, I meant that the CMA expects pages to be in buddy when the function
> is called but after the function finishes, all the pages in the range are removed
> from buddy.  This, among other things, is why the call to split_free_page() is
> necessary.
> 

Understood.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
