Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 16BAB6B01AD
	for <linux-mm@kvack.org>; Sat, 26 Jun 2010 21:03:45 -0400 (EDT)
Received: by iwn36 with SMTP id 36so360420iwn.14
        for <linux-mm@kvack.org>; Sat, 26 Jun 2010 18:03:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1006250857040.18900@router.home>
References: <20100625201915.8067.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1006250857040.18900@router.home>
Date: Sun, 27 Jun 2010 10:03:44 +0900
Message-ID: <AANLkTimAF9O3kupOWHv2lLuZefDU7HLgq5ApnD-FE_Ng@mail.gmail.com>
Subject: Re: [PATCH 1/2] vmscan: shrink_slab() require number of lru_pages,
	not page order
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 25, 2010 at 11:07 PM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> On Fri, 25 Jun 2010, KOSAKI Motohiro wrote:
>
>> Fix simple argument error. Usually 'order' is very small value than
>> lru_pages. then it can makes unnecessary icache dropping.
>
> This is going to reduce the delta that is added to shrinker->nr
> significantly thereby increasing the number of times that shrink_slab() is
> called.
>
> What does the "lru_pages" parameter do in shrink_slab()? Looks
> like its only role is as a divison factor in a complex calculation of
> pages to be scanned.

Yes. But I think it can make others confuse like this.

Except zone_reclaim, lru_pages had been used for balancing slab
reclaim VS page reclaim.
So lru_page naming is a good.

But in 0ff38490, you observed rather corner case.
AFAIU with your description, you wanted to shrink slabs until
unsuccessful or reached the limit.
So you intentionally passed order instead of the number of lru pages
for shrinking many slabs as possible as.

So at least, we need some comment to prevent confusion.

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9c7e57c..5523eae 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2626,6 +2626,9 @@ static int __zone_reclaim(struct zone *zone,
gfp_t gfp_mask, unsigned int order)
                 *
                 * Note that shrink_slab will free memory on all zones and may
                 * take a long time.
+                *
+                * We pass order instead of lru_pages for shrinking slab
+                * as much as possible.
                 */
                while (shrink_slab(sc.nr_scanned, gfp_mask, order) &&
                        zone_page_state(zone, NR_SLAB_RECLAIMABLE) >


>
> do_try_to_free_pages passes 0 as "lru_pages" to shrink_slab() when trying
> to do cgroup lru scans. Why is that?
>

memcg doesn't call shrink_slab.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
