Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id D77AE6B13F3
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 05:10:09 -0500 (EST)
Date: Wed, 1 Feb 2012 10:10:05 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: compaction: Check pfn_valid when entering a new
 MAX_ORDER_NR_PAGES block during isolation for migration
Message-ID: <20120201101005.GA4065@suse.de>
References: <20120131163528.GR4065@suse.de>
 <20120131124026.15c0f495.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120131124026.15c0f495.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Herbert van den Bergh <herbert.van.den.bergh@oracle.com>, Michal Nazarewicz <mina86@mina86.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 31, 2012 at 12:40:26PM -0800, Andrew Morton wrote:
> On Tue, 31 Jan 2012 16:35:28 +0000
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > When isolating for migration, migration starts at the start of a zone
> > which is not necessarily pageblock aligned. Further, it stops isolating
> > when COMPACT_CLUSTER_MAX pages are isolated so migrate_pfn is generally
> > not aligned.
> > 
> > The problem is that pfn_valid is only called on the first PFN being
> > checked. Lets say we have a case like this
> > 
> > H = MAX_ORDER_NR_PAGES boundary
> > | = pageblock boundary
> > m = cc->migrate_pfn
> > f = cc->free_pfn
> > o = memory hole
> > 
> > H------|------H------|----m-Hoooooo|ooooooH-f----|------H
> > 
> > The migrate_pfn is just below a memory hole and the free scanner is
> > beyond the hole. When isolate_migratepages started, it scans from
> > migrate_pfn to migrate_pfn+pageblock_nr_pages which is now in a memory
> > hole. It checks pfn_valid() on the first PFN but then scans into the
> > hole where there are not necessarily valid struct pages.
> > 
> > This patch ensures that isolate_migratepages calls pfn_valid when
> > necessary.
> > 
> > Reported-and-tested-by: Herbert van den Bergh <herbert.van.den.bergh@oracle.com>
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > Acked-by: Michal Nazarewicz <mina86@mina86.com>
> 
> The changelog forgot to describe the user-visible effects of the bug.
> 

My bad. This changelog originally had a bugzilla number which I cut
out when reposting. Here is the same patch with a better changelog

=== CUT HERE ===
mm: compaction: Check pfn_valid when entering a new MAX_ORDER_NR_PAGES block during isolation for migration

When isolating for migration, migration starts at the start of a
zone which is not necessarily pageblock aligned. Further, it stops
isolating when COMPACT_CLUSTER_MAX pages are isolated so migrate_pfn
is generally not aligned. This allows isolate_migratepages() to call
pfn_to_page() on an invalid PFN which can result in a crash. This
was originally reported against a 3.0-based kernel with the following
trace in a crash dump.

PID: 9902   TASK: d47aecd0  CPU: 0   COMMAND: "memcg_process_s"
 #0 [d72d3ad0] crash_kexec at c028cfdb
 #1 [d72d3b24] oops_end at c05c5322
 #2 [d72d3b38] __bad_area_nosemaphore at c0227e60
 #3 [d72d3bec] bad_area at c0227fb6
 #4 [d72d3c00] do_page_fault at c05c72ec
 #5 [d72d3c80] error_code (via page_fault) at c05c47a4
    EAX: 00000000  EBX: 000c0000  ECX: 00000001  EDX: 00000807  EBP: 000c0000 
    DS:  007b      ESI: 00000001  ES:  007b      EDI: f3000a80  GS:  6f50
    CS:  0060      EIP: c030b15a  ERR: ffffffff  EFLAGS: 00010002 
 #6 [d72d3cb4] isolate_migratepages at c030b15a
 #7 [d72d3d14] zone_watermark_ok at c02d26cb
 #8 [d72d3d2c] compact_zone at c030b8de
 #9 [d72d3d68] compact_zone_order at c030bba1
#10 [d72d3db4] try_to_compact_pages at c030bc84
#11 [d72d3ddc] __alloc_pages_direct_compact at c02d61e7
#12 [d72d3e08] __alloc_pages_slowpath at c02d66c7
#13 [d72d3e78] __alloc_pages_nodemask at c02d6a97
#14 [d72d3eb8] alloc_pages_vma at c030a845
#15 [d72d3ed4] do_huge_pmd_anonymous_page at c03178eb
#16 [d72d3f00] handle_mm_fault at c02f36c6
#17 [d72d3f30] do_page_fault at c05c70ed
#18 [d72d3fb0] error_code (via page_fault) at c05c47a4
    EAX: b71ff000  EBX: 00000001  ECX: 00001600  EDX: 00000431 
    DS:  007b      ESI: 08048950  ES:  007b      EDI: bfaa3788
    SS:  007b      ESP: bfaa36e0  EBP: bfaa3828  GS:  6f50
    CS:  0073      EIP: 080487c8  ERR: ffffffff  EFLAGS: 00010202 

It was also reported by Herbert van den Bergh against 3.1-based kernel
with the following snippit from the console log.

BUG: unable to handle kernel paging request at 01c00008
IP: [<c0522399>] isolate_migratepages+0x119/0x390
*pdpt = 000000002f7ce001 *pde = 0000000000000000

It is expected that it also affects 3.2.x and current mainline.

The problem is that pfn_valid is only called on the first PFN being
checked and that PFN is not necessarily aligned. Lets say we have a
case like this

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

Reported-and-tested-by: Herbert van den Bergh <herbert.van.den.bergh@oracle.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
Cc: stable <stable@vger.kernel.org>
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
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
