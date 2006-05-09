Date: Tue, 9 May 2006 12:05:35 +0100
Subject: [PATCH 2/3] x86 align highmem zone boundries with NUMA
Message-ID: <20060509110535.GA9732@shadowen.org>
References: <exportbomb.1147172704@pinky>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Andy Whitcroft <apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Bob Picco <bob.picco@hp.com>, Ingo Molnar <mingo@elte.hu>, "Martin J. Bligh" <mbligh@mbligh.org>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

x86 align highmem zone boundries with NUMA

When in x86 NUMA mode we allocate struct pages's node local and map
them into the kernel virtual address space in the remap space.
This space cuts into the end of ZONE_NORMAL.  When we round
ZONE_NORMAL down we must ensure we maintain the zone boundry
constraint, we must round to MAX_ORDER.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 discontig.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)
diff -upN reference/arch/i386/mm/discontig.c current/arch/i386/mm/discontig.c
--- reference/arch/i386/mm/discontig.c
+++ current/arch/i386/mm/discontig.c
@@ -304,10 +304,13 @@ unsigned long __init setup_memory(void)
 	/* partially used pages are not usable - thus round upwards */
 	system_start_pfn = min_low_pfn = PFN_UP(init_pg_tables_end);
 
-	system_max_low_pfn = max_low_pfn = find_max_low_pfn() - reserve_pages;
+	max_low_pfn = find_max_low_pfn() - reserve_pages;
 	printk("reserve_pages = %ld find_max_low_pfn() ~ %ld\n",
 			reserve_pages, max_low_pfn + reserve_pages);
 	printk("max_pfn = %ld\n", max_pfn);
+
+	system_max_low_pfn = max_low_pfn = zone_boundry_align_pfn(max_low_pfn);
+
 #ifdef CONFIG_HIGHMEM
 	highstart_pfn = highend_pfn = max_pfn;
 	if (max_pfn > system_max_low_pfn)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
