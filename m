Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id A8F536B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 16:03:54 -0400 (EDT)
Date: Tue, 25 Sep 2012 13:03:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 8/9] mm: compaction: Cache if a pageblock was scanned
 and no pages were isolated
Message-Id: <20120925130352.0d60957a.akpm@linux-foundation.org>
In-Reply-To: <20120925091207.GD11266@suse.de>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
	<1348224383-1499-9-git-send-email-mgorman@suse.de>
	<20120921143656.60a9a6cd.akpm@linux-foundation.org>
	<20120924093938.GZ11266@suse.de>
	<20120924142644.06c38b80.akpm@linux-foundation.org>
	<20120925091207.GD11266@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 25 Sep 2012 10:12:07 +0100
Mel Gorman <mgorman@suse.de> wrote:

> First, we'd introduce a variant of get_pageblock_migratetype() that returns
> all the bits for the pageblock flags and then helpers to extract either the
> migratetype or the PG_migrate_skip. We already are incurring the cost of
> get_pageblock_migratetype() so it will not be much more expensive than what
> is already there. If there is an allocation or free within a pageblock that
> as the PG_migrate_skip bit set then we increment a counter. When the counter
> reaches some to-be-decided "threshold" then compaction may clear all the
> bits. This would match the criteria of the clearing being based on activity.
> 
> There are four potential problems with this
> 
> 1. The logic to retrieve all the bits and split them up will be a little
>    convulated but maybe it would not be that bad.
> 
> 2. The counter is a shared-writable cache line but obviously it could
>    be moved to vmstat and incremented with inc_zone_page_state to offset
>    the cost a little.
> 
> 3. The biggested weakness is that there is not way to know if the
>    counter is incremented based on activity in a small subset of blocks.
> 
> 4. What should the threshold be?
> 
> The first problem is minor but the other three are potentially a mess.
> Adding another vmstat counter is bad enough in itself but if the counter
> is incremented based on a small subsets of pageblocks, the hint becomes
> is potentially useless.
> 
> However, does this match what you have in mind or am I over-complicating
> things?

Sounds complicated.

Using wall time really does suck.  Are you sure you can't think of
something more logical?

How would we demonstrate the suckage?  What would be the observeable downside of
switching that 5 seconds to 5 hours?

> > > > > +	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
> > > > > +		struct page *page;
> > > > > +		if (!pfn_valid(pfn))
> > > > > +			continue;
> > > > > +
> > > > > +		page = pfn_to_page(pfn);
> > > > > +		if (zone != page_zone(page))
> > > > > +			continue;
> > > > > +
> > > > > +		clear_pageblock_skip(page);
> > > > > +	}
> > > > 
> > > > What's the worst-case loop count here?
> > > > 
> > > 
> > > zone->spanned_pages >> pageblock_order
> > 
> > What's the worst-case value of (zone->spanned_pages >> pageblock_order) :)
> 
> Lets take an unlikely case - 128G single-node machine. That loop count
> on x86-64 would be 65536. It'll be fast enough, particularly in this
> path.

That could easily exceed a millisecond.  Can/should we stick a
cond_resched() in there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
