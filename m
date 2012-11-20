Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 7D0AA6B0072
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 18:33:26 -0500 (EST)
Date: Tue, 20 Nov 2012 15:33:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v11 4/7] mm: introduce compaction and migration for
 ballooned pages
Message-Id: <20121120153324.7119bd3b.akpm@linux-foundation.org>
In-Reply-To: <20121109121602.GQ3886@csn.ul.ie>
References: <cover.1352256081.git.aquini@redhat.com>
	<08be4346b620ae9344691cc6c2ad0bc51f492e01.1352256088.git.aquini@redhat.com>
	<20121109121602.GQ3886@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, 9 Nov 2012 12:16:02 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> On Wed, Nov 07, 2012 at 01:05:51AM -0200, Rafael Aquini wrote:
> > Memory fragmentation introduced by ballooning might reduce significantly
> > the number of 2MB contiguous memory blocks that can be used within a guest,
> > thus imposing performance penalties associated with the reduced number of
> > transparent huge pages that could be used by the guest workload.
> > 
> > This patch introduces the helper functions as well as the necessary changes
> > to teach compaction and migration bits how to cope with pages which are
> > part of a guest memory balloon, in order to make them movable by memory
> > compaction procedures.
> > 
>
> ...
>
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -14,6 +14,7 @@
> >  #include <linux/backing-dev.h>
> >  #include <linux/sysctl.h>
> >  #include <linux/sysfs.h>
> > +#include <linux/balloon_compaction.h>
> >  #include "internal.h"
> >  
> >  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> > @@ -565,9 +566,24 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
> >  			goto next_pageblock;
> >  		}
> >  
> > -		/* Check may be lockless but that's ok as we recheck later */
> > -		if (!PageLRU(page))
> > +		/*
> > +		 * Check may be lockless but that's ok as we recheck later.
> > +		 * It's possible to migrate LRU pages and balloon pages
> > +		 * Skip any other type of page
> > +		 */
> > +		if (!PageLRU(page)) {
> > +			if (unlikely(balloon_page_movable(page))) {
> 
> Because it's lockless, it really seems that the barrier stuck down there
> is unnecessary. At worst you get a temporarily incorrect answer that you
> recheck later under page lock in balloon_page_isolate.

What happened with this?

Also: what barrier?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
