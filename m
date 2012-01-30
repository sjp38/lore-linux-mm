Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 141ED6B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 04:09:28 -0500 (EST)
Date: Mon, 30 Jan 2012 09:09:23 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [BUG] 3.2.2 crash in isolate_migratepages
Message-ID: <20120130090923.GD4065@suse.de>
References: <4F231A6B.1050607@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F231A6B.1050607@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Herbert van den Bergh <herbert.van.den.bergh@oracle.com>
Cc: linux-mm@kvack.org

On Fri, Jan 27, 2012 at 01:43:07PM -0800, Herbert van den Bergh wrote:
> 
> 3.2.2 panics on a 16GB i686 blade:
> 
> BUG: unable to handle kernel paging request at 01c00008
> IP: [<c0522399>] isolate_migratepages+0x119/0x390
> *pdpt = 000000002f7ce001 *pde = 0000000000000000
> 
> The crash happens on this line in mm/compaction.c::isolate_migratepages:
> 
>     328                 page = pfn_to_page(low_pfn);
> 

This is not line 328 on kernel 3.2.2. Can you double check what version
you are using?

> This macro finds the struct page pointer for a given pfn.  These struct
> page pointers are stored in sections of 131072 pages if
> CONFIG_SPARSEMEM=y.  If an entire section has no memory pages, the page
> structs are not allocated for this section.  On this particular machine,
> there is no RAM mapped from 2GB - 4GB:
> 
> # dmesg|grep usable
>  BIOS-e820: 0000000000000000 - 000000000009f400 (usable)
>  BIOS-e820: 0000000000100000 - 000000007fe4e000 (usable)
>  BIOS-e820: 000000007fe56000 - 000000007fe57000 (usable)
>  BIOS-e820: 0000000100000000 - 000000047ffff000 (usable)
> 
> So there are no page structs for the sections between 2GB and 4GB.
> 
> I believe this check was intended to catch page numbers that point to holes:
> 
>     323                 if (!pfn_valid_within(low_pfn))
>     324                         continue;

Can you try the following patch please?

---8<---
mm: compaction: Check pfn_valid when entering a new MAX_ORDER_NR_PAGES block during isolation for migration

When isolating for migration, migration starts at the start of a zone
which is not necessarily pageblock aligned. Further, it stops isolating
when COMPACT_CLUSTER_MAX pages are isolated so migrate_pfn is generally
not aligned.

The problem is that pfn_valid is only called on the first PFN being
checked. Lets say we have a case like this

H = MAX_ORDER_NR_PAGES boundary
| = pageblock boundary
m = cc->migrate_pfn
f = cc->free_pfn
o = memory hole

H------|------H------|----m-Hoooooo|ooooooH-f----|------H

The migrate_pfn is just below a memory hole and the free scanner is
beyond the hole. When isolate_migratepages started, it scans from
migrate_pfn to migrate_pfn+pageblock_nr_pages which is now in a memory
hole. It checks pfn_valid() on the first PFN but then scans into the
hole where there are not necessarily valid struct pages.

This patch ensures that isolate_migratepages calls pfn_valid when
necessary.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 899d956..edc1e26 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -313,6 +313,19 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 		} else if (!locked)
 			spin_lock_irq(&zone->lru_lock);
 
+		/*
+		 * migrate_pfn does not necessarily start aligned to a
+		 * pageblock. Ensure that pfn_valid is called when moving
+		 * into a new MAX_ORDER_NR_PAGES range in case of large
+		 * memory holes within the zone
+		 */
+		if ((low_pfn & (MAX_ORDER_NR_PAGES - 1)) == 0) {
+			if (!pfn_valid(low_pfn)) {
+				low_pfn += MAX_ORDER_NR_PAGES - 1;
+				continue;
+			}
+		}
+
 		if (!pfn_valid_within(low_pfn))
 			continue;
 		nr_scanned++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
