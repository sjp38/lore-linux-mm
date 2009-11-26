Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 451956B00A5
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 09:17:46 -0500 (EST)
Date: Thu, 26 Nov 2009 14:17:38 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH-RFC] cfq: Disable low_latency by default for 2.6.32
Message-ID: <20091126141738.GE13095@csn.ul.ie>
References: <20091126121945.GB13095@csn.ul.ie> <4e5e476b0911260547r33424098v456ed23203a61dd@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4e5e476b0911260547r33424098v456ed23203a61dd@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Corrado Zoccolo <czoccolo@gmail.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 26, 2009 at 02:47:10PM +0100, Corrado Zoccolo wrote:
> On Thu, Nov 26, 2009 at 1:19 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > (cc'ing the people from the page allocator failure thread as this might be
> > relevant to some of their problems)
> >
> > I know this is very last minute but I believe we should consider disabling
> > the "low_latency" tunable for block devices by default for 2.6.32.  There was
> > evidence that low_latency was a problem last week for page allocation failure
> > reports but the reproduction-case was unusual and involved high-order atomic
> > allocations in low-memory conditions. It took another few days to accurately
> > show the problem for more normal workloads and it's a bit more wide-spread
> > than just allocation failures.
> >
> > Basically, low_latency looks great as long as you have plenty of memory
> > but in low memory situations, it appears to cause problems that manifest
> > as reduced performance, desktop stalls and in some cases, page allocation
> > failures. I think most kernel developers are not seeing the problem as they
> > tend to test on beefier machines and without hitting swap or low-memory
> > situations for the most part. When they are hitting low-memory situations,
> > it tends to be for stress tests where stalls and low performance are expected.
> 
> The low latency tunable controls various policies inside cfq.
> The one that could affect memory reclaim is:
>         /*
>          * Async queues must wait a bit before being allowed dispatch.
>          * We also ramp up the dispatch depth gradually for async IO,
>          * based on the last sync IO we serviced
>          */
>         if (!cfq_cfqq_sync(cfqq) && cfqd->cfq_latency) {
>                 unsigned long last_sync = jiffies - cfqd->last_end_sync_rq;
>                 unsigned int depth;
> 
>                 depth = last_sync / cfqd->cfq_slice[1];
>                 if (!depth && !cfqq->dispatched)
>                         depth = 1;
>                 if (depth < max_dispatch)
>                         max_dispatch = depth;
>         }
> 
> here the async queues max depth is limited to 1 for up to 200 ms after
> a sync I/O is completed.
> Note: dirty page writeback goes through an async queue, so it is
> penalized by this.
> 
> This can affect both low and high end hardware. My non-NCQ sata disk
> can handle a depth of 2 when writing. NCQ sata disks can handle a
> depth up to 31, so limiting depth to 1 can cause write performance
> drop, and this in turn will slow down dirty page reclaim, and cause
> allocation failures.
> 
> It would be good to re-test the OOM conditions with that code commented out.
> 

All of it or just the cfq_latency part?

As it turns out the test machine does report for the disk NCQ (depth 31/32)
and it's the same on the laptop so slowing down dirty page cleaning
could be impacting reclaim.

> >
> > To show the problem, I used an x86-64 machine booting booted with 512MB of
> > memory. This is a small amount of RAM but the bug reports related to page
> > allocation failures were on smallish machines and the disks in the system
> > are not very high-performance.
> >
> > I used three tests. The first was sysbench on postgres running an IO-heavy
> > test against a large database with 10,000,000 rows. The second was IOZone
> > running most of the automatic tests with a record length of 4KB and the
> > last was a simulated launching of gitk with a music player running in the
> > background to act as a desktop-like scenario. The final test was similar
> > to the test described here http://lwn.net/Articles/362184/ except that
> > dm-crypt was not used as it has its own problems.
> 
> low_latency was tested on other scenarios:
> http://lkml.indiana.edu/hypermail/linux/kernel/0910.0/01410.html
> http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-11/msg04855.html
> where it improved actual and perceived performance, so disabling it
> completely may not be good.
> 

It may not indeed.

In case you mean a partial disabling of cfq_latency, I'm try the
following patch. The intention is to disable the low_latency logic if
kswapd is at work and presumably needs clean pages. Alternative
suggestions welcome.

======
cfq: Do not limit the async queue depth while kswapd is awake

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index aa1e953..dcab74e 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1308,7 +1308,7 @@ static bool cfq_may_dispatch(struct cfq_data *cfqd, struct cfq_queue *cfqq)
 	 * We also ramp up the dispatch depth gradually for async IO,
 	 * based on the last sync IO we serviced
 	 */
-	if (!cfq_cfqq_sync(cfqq) && cfqd->cfq_latency) {
+	if (!cfq_cfqq_sync(cfqq) && cfqd->cfq_latency && !kswapd_awake()) {
 		unsigned long last_sync = jiffies - cfqd->last_end_sync_rq;
 		unsigned int depth;
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6f75617..b593aff 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -655,6 +655,7 @@ typedef struct pglist_data {
 void get_zone_counts(unsigned long *active, unsigned long *inactive,
 			unsigned long *free);
 void build_all_zonelists(void);
+int kswapd_awake(void);
 void wakeup_kswapd(struct zone *zone, int order);
 int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		int classzone_idx, int alloc_flags);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 777af57..75cdd9a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2201,6 +2201,15 @@ static int kswapd(void *p)
 	return 0;
 }
 
+int kswapd_awake(void)
+{
+	pg_data_t *pgdat;
+	for_each_online_pgdat(pgdat)
+		if (!waitqueue_active(&pgdat->kswapd_wait))
+			return 1;
+	return 0;
+}
+
 /*
  * A zone is low on free memory, so wake its kswapd task to service it.
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
