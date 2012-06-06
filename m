Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 2A61F6B00A1
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 08:56:30 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (mailout3.samsung.com [203.254.224.33])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M57008NB5A42JF0@mailout3.samsung.com> for
 linux-mm@kvack.org; Wed, 06 Jun 2012 21:56:28 +0900 (KST)
Received: from bzolnier-desktop.localnet ([106.116.48.38])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M5700BKE5A28S60@mmp2.samsung.com> for linux-mm@kvack.org;
 Wed, 06 Jun 2012 21:56:28 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH v9] mm: compaction: handle incorrect MIGRATE_UNMOVABLE type
 pageblocks
Date: Wed, 06 Jun 2012 14:55:28 +0200
References: <201206041543.56917.b.zolnierkie@samsung.com>
 <op.wfdt8dh53l0zgt@mpn-glaptop>
In-reply-to: <op.wfdt8dh53l0zgt@mpn-glaptop>
MIME-version: 1.0
Message-id: <201206061455.28980.b.zolnierkie@samsung.com>
Content-type: Text/Plain; charset=us-ascii
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>

On Monday 04 June 2012 16:22:51 Michal Nazarewicz wrote:
> On Mon, 04 Jun 2012 15:43:56 +0200, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com> wrote:
> > +/*
> > + * Returns true if MIGRATE_UNMOVABLE pageblock can be successfully
> > + * converted to MIGRATE_MOVABLE type, false otherwise.
> > + */
> > +static bool can_rescue_unmovable_pageblock(struct page *page, bool locked)
> > +{
> > +	unsigned long pfn, start_pfn, end_pfn;
> > +	struct page *start_page, *end_page, *cursor_page;
> > +
> > +	pfn = page_to_pfn(page);
> > +	start_pfn = pfn & ~(pageblock_nr_pages - 1);
> > +	end_pfn = start_pfn + pageblock_nr_pages - 1;
> > +
> > +	start_page = pfn_to_page(start_pfn);
> > +	end_page = pfn_to_page(end_pfn);
> > +
> > +	for (cursor_page = start_page, pfn = start_pfn; cursor_page <= end_page;
> > +		pfn++, cursor_page++) {
> > +		struct zone *zone = page_zone(start_page);
> > +		unsigned long flags;
> > +
> > +		if (!pfn_valid_within(pfn))
> > +			continue;
> > +
> > +		/* Do not deal with pageblocks that overlap zones */
> > +		if (page_zone(cursor_page) != zone)
> > +			return false;
> > +
> > +		if (!locked)
> > +			spin_lock_irqsave(&zone->lock, flags);
> > +
> > +		if (PageBuddy(cursor_page)) {
> > +			int order = page_order(cursor_page);
> >-/* Returns true if the page is within a block suitable for migration to */
> > -static bool suitable_migration_target(struct page *page)
> > +			pfn += (1 << order) - 1;
> > +			cursor_page += (1 << order) - 1;
> > +
> > +			if (!locked)
> > +				spin_unlock_irqrestore(&zone->lock, flags);
> > +			continue;
> > +		} else if (page_count(cursor_page) == 0 ||
> > +			   PageLRU(cursor_page)) {
> > +			if (!locked)
> > +				spin_unlock_irqrestore(&zone->lock, flags);
> > +			continue;
> > +		}
> > +
> > +		if (!locked)
> > +			spin_unlock_irqrestore(&zone->lock, flags);
> 
> spin_unlock in three spaces is ugly.  How about adding a flag that holds the
> result of the function which you use as for loop condition and you set it to
> false inside an additional else clause?  Eg.:
> 
> 	bool result = true;
> 	for (...; result && cursor_page <= end_page; ...) {
> 		...
> 		if (!pfn_valid_within(pfn)) continue;
> 		if (page_zone(cursor_page) != zone) return false;
> 		if (!locked) spin_lock_irqsave(...);
> 		
> 		if (PageBuddy(...)) {
> 			...
> 		} else if (page_count(cursor_page) == 0 ||
> 			   PageLRU(cursor_page)) {
> 			...
> 		} else {
> 			result = false;
> 		}
> 		if (!locked) spin_unlock_irqsave(...);
> 	}
> 	return result;

Thanks, I'll use the hint (if still applicable) in the next patch version.

> > +		return false;
> > +	}
> > +
> > +	return true;
> > +}
> 
> How do you make sure that a page is not allocated while this runs?  Or you just
> don't care?  Not that even with zone lock, page may be allocated from pcp list
> on (another) CPU.

Ok, I see the issue (i.e. pcp page can be returned by rmqueue_bulk() in
buffered_rmqueue() and its page count will be increased in prep_new_page()
a bit later with zone lock dropped so while we may not see the page as
"bad" one in can_rescue_unmovable_pageblock() it may end up as unmovable
one in a pageblock that was just changed to MIGRATE_MOVABLE type).

It is basically similar problem to page allocation vs alloc_contig_range()
races present in CMA [*] so we may deal with it in a similar manner as
CMA: isolate pageblock so no new allocations will be allowed from it,
check if we can do pageblock transition to MIGRATE_MOVABLE type and do
it if so, drain pcp lists, check if the transition was successful and
if there are some pages that slipped through just revert the operation..

However I worry that this still won't cover all races as we can have
some page in "transient state" (no longer on pcp list but not yet used,
simply still being processed by buffered_rmqueue() while we count it
as "good" one in the pageblock transition verification code)?

[*] BTW please see http://marc.info/?l=linux-mm&m=133775797022645&w=2
for CMA related fixes

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
