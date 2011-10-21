Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EAE886B0035
	for <linux-mm@kvack.org>; Fri, 21 Oct 2011 06:06:30 -0400 (EDT)
Date: Fri, 21 Oct 2011 12:06:24 +0200
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/9] mm: alloc_contig_freed_pages() added
Message-ID: <20111021100624.GB4029@csn.ul.ie>
References: <1317909290-29832-1-git-send-email-m.szyprowski@samsung.com>
 <1317909290-29832-3-git-send-email-m.szyprowski@samsung.com>
 <20111018122109.GB6660@csn.ul.ie>
 <op.v3j5ent03l0zgt@mpn-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <op.v3j5ent03l0zgt@mpn-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Tue, Oct 18, 2011 at 10:26:37AM -0700, Michal Nazarewicz wrote:
> On Tue, 18 Oct 2011 05:21:09 -0700, Mel Gorman <mel@csn.ul.ie> wrote:
> 
> >At this point, I'm going to apologise for not reviewing this a long long
> >time ago.
> >
> >On Thu, Oct 06, 2011 at 03:54:42PM +0200, Marek Szyprowski wrote:
> >>From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >>
> >>This commit introduces alloc_contig_freed_pages() function
> >>which allocates (ie. removes from buddy system) free pages
> >>in range. Caller has to guarantee that all pages in range
> >>are in buddy system.
> >>
> >
> >Straight away, I'm wondering why you didn't use
> >
> >mm/compaction.c#isolate_freepages()
> >
> >It knows how to isolate pages within ranges. All its control information
> >is passed via struct compact_control() which I recognise may be awkward
> >for CMA but compaction.c know how to manage all the isolated pages and
> >pass them to migrate.c appropriately.
> 
> It is something to consider.  At first glance, I see that isolate_freepages
> seem to operate on pageblocks which is not desired for CMA.
> 

isolate_freepages_block operates on a range of pages that happens to be
hard-coded to be a pageblock because that was the requirements. It calculates
end_pfn and it is possible to make that a function parameter.

> >I haven't read all the patches yet but isolate_freepages() does break
> >everything up into order-0 pages. This may not be to your liking but it
> >would not be possible to change.
> 
> Splitting everything into order-0 pages is desired behaviour.
> 

Great.

> >>Along with this function, a free_contig_pages() function is
> >>provided which frees all (or a subset of) pages allocated
> >>with alloc_contig_free_pages().
> 
> >mm/compaction.c#release_freepages()
> 
> It sort of does the same thing but release_freepages() assumes that pages
> that are being freed are not-continuous and they need to be on the lru list.
> With free_contig_pages(), we can assume all pages are continuous.
> 

Ok, I jumped the gun here. release_freepages() may not be a perfect fit.
release_freepages() is also used when finishing compaction where as it
is a real free function that is required here.

> >You can do this in a more general fashion by checking the
> >zone boundaries and resolving the pfn->page every MAX_ORDER_NR_PAGES.
> >That will not be SPARSEMEM specific.
> 
> I've tried doing stuff that way but it ended up with much more code.
> 
> Dave suggested the above function to check if pointer arithmetic is valid.
> 
> Please see also <https://lkml.org/lkml/2011/9/21/220>.
> 

Ok, I'm still not fully convinced but I confess I'm not thinking about this
particular function too deeply because I am expecting the problem would
go away if compaction and CMA shared common code for freeing contiguous
regions via page migration.

> >> <SNIP>
> >>+		if (zone_pfn_same_memmap(pfn - count, pfn))
> >>+			page += count;
> >>+		else
> >>+			page = pfn_to_page(pfn);
> >>+	}
> >>+
> >>+	spin_unlock_irq(&zone->lock);
> >>+
> >>+	/* After this, pages in the range can be freed one be one */
> >>+	count = pfn - start;
> >>+	pfn = start;
> >>+	for (page = pfn_to_page(pfn); count; --count) {
> >>+		prep_new_page(page, 0, flag);
> >>+		++pfn;
> >>+		if (likely(zone_pfn_same_memmap(pfn - 1, pfn)))
> >>+			++page;
> >>+		else
> >>+			page = pfn_to_page(pfn);
> >>+	}
> >>+
> >
> >Here it looks like you have implemented something like split_free_page().
> 
> split_free_page() takes a single page, removes it from buddy system, and finally
> splits it. 

I'm referring to just this chunk.

split_free_page takes a page, checks the watermarks and performs similar
operations to prep_new_page(). There should be no need to introduce a
new similar function. split_free_page() does affect hte pageblock
migratetype and that is undesirable but that part could be taken out and
moved to compaction.c if necessary.

On the watermarks thing, CMA does not pay much attention to them. I have
a strong feeling that it is easy to deadlock a system by using CMA while
under memory pressure. Compaction had the same problem early in its
development FWIW. This is partially why I'd prefer to see CMA and
compaction sharing as much code as possible because compaction gets
continual testing.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
