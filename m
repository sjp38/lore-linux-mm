Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 318646B01AC
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 06:46:40 -0400 (EDT)
Date: Fri, 26 Mar 2010 10:46:18 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 08/11] Add /proc trigger for memory compaction
Message-ID: <20100326104618.GZ2024@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie> <1269347146-7461-9-git-send-email-mel@csn.ul.ie> <20100324133351.c7730969.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100324133351.c7730969.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 24, 2010 at 01:33:51PM -0700, Andrew Morton wrote:
> On Tue, 23 Mar 2010 12:25:43 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > This patch adds a proc file /proc/sys/vm/compact_memory. When an arbitrary
> > value is written to the file, all zones are compacted. The expected user
> > of such a trigger is a job scheduler that prepares the system before the
> > target application runs.
> > 
> >
> > ...
> >
> > +/* This is the entry point for compacting all nodes via /proc/sys/vm */
> > +int sysctl_compaction_handler(struct ctl_table *table, int write,
> > +			void __user *buffer, size_t *length, loff_t *ppos)
> > +{
> > +	if (write)
> > +		return compact_nodes();
> > +
> > +	return 0;
> > +}
> 
> Neato.  When I saw the overall description I was afraid that this stuff
> would be fiddling with kernel threads.
> 

Not yet anyway. It has been floated in the past to have a kcompactd
similar to kswapd but right now there is no justification for it. Like
other suggestions made in the past, it has potential but needs data to
justify.

> The underlying compaction code can at times cause rather large amounts
> of memory to be put onto private lists, so it's lost to the rest of the
> kernel.  What happens if 10000 processes simultaneously write to this
> thing?  It's root-only so I guess the answer is "root becomes unemployed".
> 

Well, root becomes unemployed but I shouldn't be supplying the rope.
Lets keep min_free_kbytes as the "fall off the cliff" tunable. I added
too_many_isolated()-like logic and also handling of fatal signals.

> I fear that the overall effect of this feature is that people will come
> up with ghastly hacks which keep on poking this tunable as a workaround
> for some VM shortcoming.  This will lead to more shortcomings, and
> longer-lived ones.
> 

That would be very unfortunate and also a self-defeating measure in the short
run, let alone the long run.  I consider the tunable to be more like the
"drop_caches" tunable. It can be used for good or bad and all the bad uses
kick you in the ass because it does not resolve the underlying problem and
is expensive to use.

I had three legit uses in mind for it

1. Batch-systems that compact memory before a job is scheduler to reduce
   start-up time of applications using huge pages. Depending on their
   setup, sysfs might be a better fit for them

2. Illustrate a bug in direct compaction. i.e. I'd get a report on some
   allocation failure that was consistent but when the tunable is poked,
   it works perfectly

3. Development uses. Measuring worst-case scenarios for compaction (rare
   obviously), stress testing compaction to try catch bugs in migration
   and measuring how effective compaction currently is.

Do these justify the existance of the tunable or is the risk of abuse
too high?

This is what the isolate logic looks like


diff --git a/mm/compaction.c b/mm/compaction.c
index e0e8100..a6a6958 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -13,6 +13,7 @@
 #include <linux/mm_inline.h>
 #include <linux/sysctl.h>
 #include <linux/sysfs.h>
+#include <linux/backing-dev.h>
 #include "internal.h"
 
 /*
@@ -197,6 +198,20 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
 	__mod_zone_page_state(zone, NR_ISOLATED_FILE, cc->nr_file);
 }
 
+/* Similar to reclaim, but different enough that they don't share logic */
+static int too_many_isolated(struct zone *zone)
+{
+
+	unsigned long inactive, isolated;
+
+	inactive = zone_page_state(zone, NR_INACTIVE_FILE) +
+					zone_page_state(zone, NR_INACTIVE_ANON);
+	isolated = zone_page_state(zone, NR_ISOLATED_FILE) +
+					zone_page_state(zone, NR_ISOLATED_ANON);
+
+	return isolated > inactive;
+}
+
 /*
  * Isolate all pages that can be migrated from the block pointed to by
  * the migrate scanner within compact_control.
@@ -223,6 +238,14 @@ static unsigned long isolate_migratepages(struct zone *zone,
 		return 0;
 	}
 
+	/* Do not isolate the world */
+	while (unlikely(too_many_isolated(zone))) {
+		congestion_wait(BLK_RW_ASYNC, HZ/10);
+
+		if (fatal_signal_pending(current))
+			return 0;
+	}
+
 	/* Time to isolate some pages for migration */
 	spin_lock_irq(&zone->lru_lock);
 	for (; low_pfn < end_pfn; low_pfn++) {
@@ -309,6 +332,9 @@ static int compact_finished(struct zone *zone,
 	unsigned int order;
 	unsigned long watermark = low_wmark_pages(zone) + (1 << cc->order);
 
+	if (fatal_signal_pending(current))
+		return COMPACT_PARTIAL;
+
 	/* Compaction run completes if the migrate and free scanner meet */
 	if (cc->free_pfn <= cc->migrate_pfn)
 		return COMPACT_COMPLETE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
