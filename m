Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5B86B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 15:33:37 -0500 (EST)
Received: by pabrd3 with SMTP id rd3so8895107pab.1
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 12:33:37 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id kr9si1129155pdb.94.2015.02.17.12.33.34
        for <linux-mm@kvack.org>;
        Tue, 17 Feb 2015 12:33:35 -0800 (PST)
Message-ID: <54E3A59C.7090202@intel.com>
Date: Tue, 17 Feb 2015 12:33:32 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: [RFC] Bogus zone->watermark[WMARK_MIN] for big systems
Content-Type: multipart/mixed;
 boundary="------------050704090307020007070908"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------050704090307020007070908
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

I've got a 2TB 8-node system (256GB per NUMA node) that's behaving a bit
strangely (OOMs with GB of free memory).

Its watermarks look wonky, with a min watermark of 0 pages for DMA and
only 11 pages for DMA32:

> Node 0 DMA    free:7428kB    min:0kB    low:0kB    high:0kB    ...
> Node 0 DMA32  free:1024084kB min:44kB   low:52kB   high:64kB   ... present:1941936kB   managed:1862456kB
> Node 0 Normal free:4808kB    min:6348kB low:7932kB high:9520kB ... present:266338304kB managed:262138972kB

This looks to be caused by us trying to evenly distribute the
min_free_kbytes value across the zones, but with such a huge size
imbalance (16MB zone vs 2TB system), 1/131072th of the default
min_free_kbytes ends up <1 page.

Should we be setting up some absolute floors on the watermarks, like the
attached patch?

BTW, it seems to be this code:

> static void __setup_per_zone_wmarks(void)
> {
>         unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
...
>         for_each_zone(zone) {
>                 u64 tmp;
> 
>                 spin_lock_irqsave(&zone->lock, flags);
>                 tmp = (u64)pages_min * zone->managed_pages;
>                 do_div(tmp, lowmem_pages);


--------------050704090307020007070908
Content-Type: text/x-patch;
 name="mm-absolute-floors-for-watermarks.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="mm-absolute-floors-for-watermarks.patch"



---

 b/mm/page_alloc.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff -puN mm/page_alloc.c~mm-absolute-floors-for-watermarks mm/page_alloc.c
--- a/mm/page_alloc.c~mm-absolute-floors-for-watermarks	2015-02-17 11:19:48.470054562 -0800
+++ b/mm/page_alloc.c	2015-02-17 11:26:48.164983632 -0800
@@ -5739,6 +5739,14 @@ static void __setup_per_zone_wmarks(void
 	}
 
 	for_each_zone(zone) {
+		/*
+		 * For very small zones (think 16MB ZONE_DMA on a 4TB system),
+		 * proportionally distributing pages_min can lean to
+		 * watermarks of 0.  Give it an absolute floor so we always
+		 * have at least a minimal watermark based on the size of the
+		 * *zone*, not the system.
+		 */
+		unsigned long absolute_min = zone->managed_pages / 256;
 		u64 tmp;
 
 		spin_lock_irqsave(&zone->lock, flags);
@@ -5766,7 +5774,8 @@ static void __setup_per_zone_wmarks(void
 			 */
 			zone->watermark[WMARK_MIN] = tmp;
 		}
-
+		zone->watermark[WMARK_MIN]  = max(zone->watermark[WMARK_MIN],
+						  absolute_min);
 		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + (tmp >> 2);
 		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp >> 1);
 
_

--------------050704090307020007070908--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
