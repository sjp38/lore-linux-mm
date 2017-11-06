Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 014E56B0033
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 14:31:48 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 11so6557359wrb.10
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 11:31:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k60si2314238edc.530.2017.11.06.11.31.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 11:31:46 -0800 (PST)
Date: Mon, 6 Nov 2017 20:31:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Guaranteed allocation of huge pages (1G) using movablecore=N
 doesn't seem to work at all
Message-ID: <20171106193145.v7s4rjyc3tfvcqkq@dhcp22.suse.cz>
References: <CACAwPwbA0NpTC9bfV7ySHkxPrbZJVvjH=Be5_c25Q3S8qNay+w@mail.gmail.com>
 <CACAwPwamD4RL9O8wujK_jCKGu=x0dBBmH9O-9078cUEEk4WsMA@mail.gmail.com>
 <CACAwPwYKjK5RT-ChQqqUnD7PrtpXg1WhTHGK3q60i6StvDMDRg@mail.gmail.com>
 <CACAwPwav-eY4_nt=Z7TQB8WMFg+1X5WY2Gkgxph74X7=Ovfvrw@mail.gmail.com>
 <CACAwPwaP05FgxTp=kavwgFZF+LEGO-OSspJ4jH+Y=_uRxiVZaA@mail.gmail.com>
 <CACAwPwY5ss_D9kj7XoLVVkQ9=KXDFCnyDzdoxkGxhJZBNFre3w@mail.gmail.com>
 <CACAwPwYp4TysdH_1w1F9L7BpwFAGR8dNg04F6QASyQeYYNErkg@mail.gmail.com>
 <20171106180406.diowlwanvucnwkbp@dhcp22.suse.cz>
 <CACAwPwaTejMB8yOrkOxpDj297B=Y6bTvw2nAyHsiJKC+aB=a2w@mail.gmail.com>
 <20171106183237.64b3hj25hbfw7v4l@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171106183237.64b3hj25hbfw7v4l@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Cc: linux-mm@kvack.org

On Mon 06-11-17 19:32:37, Michal Hocko wrote:
> On Mon 06-11-17 20:13:36, Maxim Levitsky wrote:
> > Yes, I tested git head from mainline and few kernels from ubuntu repos
> > since I was lazy to compile them too.
> 
> OK, so this hasn't worked realiably as I've suspected.
> 
> > Do you have an idea what can I do about this issue? Do you think its
> > feasable to fix this?
> 
> Well, I think that giga pages need quite some love to be usable
> reliably. The current implementation is more towards "make it work if
> there is enough unused memory".
> 
> > And if not using moveable zone, how would it even be possible to have
> > guaranreed allocation of 1g pages
> 
> Having a guaranteed giga pages is something the kernel is not yet ready
> to offer.  Abusing zone movable might look like the right direction
> but that is not really the case until we make sure those pages are
> migratable.
> 
> There has been a simple patch which makes PUD (1GB) pages migrateable
> http://lkml.kernel.org/r/20170913101047.GA13026@gmail.com but I've had
> concerns that it really didn't consider the migration path much
> http://lkml.kernel.org/r/20171003073301.hydw7jf2wztsx2om%40dhcp22.suse.cz
> I still believe the patch is not complete but maybe it is not that far
> away from being so. E.g. the said pfn_range_valid_gigantic can be
> enhanced to make the migration much more reliable or get rid of it
> altogether because the pfn based allocator already knows how to do
> migration and other stuff.

Here is the first shot on the weird pfn_range_valid_gigantic. This is
completely (even compile) untested. It should just give an idea. I will
think about this some more later. If you have a scratch system that you
are not afraid to play with I would appreciate if you could give it a
try.
---
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5ab12fda8ed5..17ca753560b7 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1071,34 +1071,6 @@ static int __alloc_gigantic_page(unsigned long start_pfn,
 				  gfp_mask);
 }
 
-static bool pfn_range_valid_gigantic(struct zone *z,
-			unsigned long start_pfn, unsigned long nr_pages)
-{
-	unsigned long i, end_pfn = start_pfn + nr_pages;
-	struct page *page;
-
-	for (i = start_pfn; i < end_pfn; i++) {
-		if (!pfn_valid(i))
-			return false;
-
-		page = pfn_to_page(i);
-
-		if (page_zone(page) != z)
-			return false;
-
-		if (PageReserved(page))
-			return false;
-
-		if (page_count(page) > 0)
-			return false;
-
-		if (PageHuge(page))
-			return false;
-	}
-
-	return true;
-}
-
 static bool zone_spans_last_pfn(const struct zone *zone,
 			unsigned long start_pfn, unsigned long nr_pages)
 {
@@ -1110,7 +1082,7 @@ static struct page *alloc_gigantic_page(int nid, struct hstate *h)
 {
 	unsigned int order = huge_page_order(h);
 	unsigned long nr_pages = 1 << order;
-	unsigned long ret, pfn, flags;
+	unsigned long ret, pfn;
 	struct zonelist *zonelist;
 	struct zone *zone;
 	struct zoneref *z;
@@ -1119,28 +1091,29 @@ static struct page *alloc_gigantic_page(int nid, struct hstate *h)
 	gfp_mask = htlb_alloc_mask(h) | __GFP_THISNODE;
 	zonelist = node_zonelist(nid, gfp_mask);
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, gfp_zone(gfp_mask), NULL) {
-		spin_lock_irqsave(&zone->lock, flags);
 
 		pfn = ALIGN(zone->zone_start_pfn, nr_pages);
 		while (zone_spans_last_pfn(zone, pfn, nr_pages)) {
-			if (pfn_range_valid_gigantic(zone, pfn, nr_pages)) {
-				/*
-				 * We release the zone lock here because
-				 * alloc_contig_range() will also lock the zone
-				 * at some point. If there's an allocation
-				 * spinning on this lock, it may win the race
-				 * and cause alloc_contig_range() to fail...
-				 */
-				spin_unlock_irqrestore(&zone->lock, flags);
-				ret = __alloc_gigantic_page(pfn, nr_pages, gfp_mask);
-				if (!ret)
-					return pfn_to_page(pfn);
-				spin_lock_irqsave(&zone->lock, flags);
+			struct page *page = pfn_to_online_page(pfn);
+
+			/*
+			 * be careful about offline pageblocks and interleaving
+			 * zones
+			 */
+			if (!page || page_zone(page) != zone) {
+				pfn += pageblock_nr_pages;
+				continue;
 			}
+			if (PageReserved(page)) {
+				pfn++;
+				continue;
+			}
+
+			ret = __alloc_gigantic_page(pfn, nr_pages, gfp_mask);
+			if (!ret)
+				return pfn_to_page(pfn);
 			pfn += nr_pages;
 		}
-
-		spin_unlock_irqrestore(&zone->lock, flags);
 	}
 
 	return NULL;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
