Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 735F36B006C
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 06:59:34 -0500 (EST)
Date: Tue, 27 Nov 2012 09:59:10 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v11 4/7] mm: introduce compaction and migration for
 ballooned pages
Message-ID: <20121127115910.GA1812@t510.redhat.com>
References: <cover.1352256081.git.aquini@redhat.com>
 <08be4346b620ae9344691cc6c2ad0bc51f492e01.1352256088.git.aquini@redhat.com>
 <20121109121602.GQ3886@csn.ul.ie>
 <20121120153324.7119bd3b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121120153324.7119bd3b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, Nov 20, 2012 at 03:33:24PM -0800, Andrew Morton wrote:
> On Fri, 9 Nov 2012 12:16:02 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Wed, Nov 07, 2012 at 01:05:51AM -0200, Rafael Aquini wrote:
> > > Memory fragmentation introduced by ballooning might reduce significantly
> > > the number of 2MB contiguous memory blocks that can be used within a guest,
> > > thus imposing performance penalties associated with the reduced number of
> > > transparent huge pages that could be used by the guest workload.
> > > 
> > > This patch introduces the helper functions as well as the necessary changes
> > > to teach compaction and migration bits how to cope with pages which are
> > > part of a guest memory balloon, in order to make them movable by memory
> > > compaction procedures.
> > > 
> >
> > ...
> >
> > > --- a/mm/compaction.c
> > > +++ b/mm/compaction.c
> > > @@ -14,6 +14,7 @@
> > >  #include <linux/backing-dev.h>
> > >  #include <linux/sysctl.h>
> > >  #include <linux/sysfs.h>
> > > +#include <linux/balloon_compaction.h>
> > >  #include "internal.h"
> > >  
> > >  #if defined CONFIG_COMPACTION || defined CONFIG_CMA
> > > @@ -565,9 +566,24 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
> > >  			goto next_pageblock;
> > >  		}
> > >  
> > > -		/* Check may be lockless but that's ok as we recheck later */
> > > -		if (!PageLRU(page))
> > > +		/*
> > > +		 * Check may be lockless but that's ok as we recheck later.
> > > +		 * It's possible to migrate LRU pages and balloon pages
> > > +		 * Skip any other type of page
> > > +		 */
> > > +		if (!PageLRU(page)) {
> > > +			if (unlikely(balloon_page_movable(page))) {
> > 
> > Because it's lockless, it really seems that the barrier stuck down there
> > is unnecessary. At worst you get a temporarily incorrect answer that you
> > recheck later under page lock in balloon_page_isolate.
> 

Sorry for the late reply.

> What happened with this?
> 
This Mel's concern were addressed by the last submitted review (v12)


> Also: what barrier?

Mel was refering to these barriers, at balloon_compaction.h:
---8<---
+/*
+ * balloon_page_insert - insert a page into the balloon's page list and make
+ *                      the page->mapping assignment accordingly.
+ * @page    : page to be assigned as a 'balloon page'
+ * @mapping : allocated special 'balloon_mapping'
+ * @head    : balloon's device page list head
+ */
+static inline void balloon_page_insert(struct page *page,
+                                      struct address_space *mapping,
+                                      struct list_head *head)
+{
+       list_add(&page->lru, head);
+       /*
+        * Make sure the page is already inserted on balloon's page list
+        * before assigning its ->mapping.
+        */
+       smp_wmb();
+       page->mapping = mapping;
+}
+
+/*
+ * balloon_page_delete - clear the page->mapping and delete the page from
+ *                      balloon's page list accordingly.
+ * @page    : page to be released from balloon's page list
+ */
+static inline void balloon_page_delete(struct page *page)
+{
+       page->mapping = NULL;
+       /*
+        * Make sure page->mapping is cleared before we proceed with
+        * balloon's page list deletion.
+        */
+       smp_wmb();
+       list_del(&page->lru);
+}
+
+/*
+ * __is_movable_balloon_page - helper to perform @page mapping->flags tests
+ */
+static inline bool __is_movable_balloon_page(struct page *page)
+{
+       /*
+        * we might attempt to read ->mapping concurrently to other
+        * threads trying to write to it.
+        */
+       struct address_space *mapping = ACCESS_ONCE(page->mapping);
+       smp_read_barrier_depends();
+       return mapping_balloon(mapping);
+}
---8<---

The last review got rid of them to stick with Mel's ACK.


Cheers!
--Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
