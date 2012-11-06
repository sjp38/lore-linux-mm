Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 4C5616B0062
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:43:24 -0500 (EST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 7 Nov 2012 01:13:21 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6JhB7e59834412
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 01:13:11 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA71D1KZ031122
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 12:13:02 +1100
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH 10/10] mm: Create memory regions at boot-up
Date: Wed, 07 Nov 2012 01:12:07 +0530
Message-ID: <20121106194202.6560.9541.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20121106193650.6560.71366.stgit@srivatsabhat.in.ibm.com>
References: <20121106193650.6560.71366.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Ankita Garg <gargankita@gmail.com>

Memory regions are created at boot up time, from the information obtained
from the firmware. But since the firmware doesn't yet export information
about memory units that can be independently power managed, for the purpose
of demonstration, we hard code memory region size to be 512MB.

In future, we expect ACPI 5.0 compliant firmware to expose the required
info in the form of MPST (Memory Power State Table) tables.

Signed-off-by: Ankita Garg <gargankita@gmail.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |   28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9c1d680..13d1b2f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4491,6 +4491,33 @@ void __init set_pageblock_order(void)
 
 #endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
 
+#define REGIONS_SIZE	(512 << 20) >> PAGE_SHIFT
+
+static void init_node_memory_regions(struct pglist_data *pgdat)
+{
+	int cnt = 0;
+	unsigned long i;
+	unsigned long start_pfn = pgdat->node_start_pfn;
+	unsigned long spanned_pages = pgdat->node_spanned_pages;
+	unsigned long total = 0;
+
+	for (i = start_pfn; i < start_pfn + spanned_pages; i += REGIONS_SIZE) {
+		struct mem_region *region = &pgdat->node_regions[cnt];
+
+		region->start_pfn = i;
+		if ((spanned_pages - total) < REGIONS_SIZE)
+			region->spanned_pages = spanned_pages - total;
+		else
+			region->spanned_pages = REGIONS_SIZE;
+
+		region->node = pgdat->node_id;
+		region->region = cnt;
+		pgdat->nr_node_regions++;
+		total += region->spanned_pages;
+		cnt++;
+	}
+}
+
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved
@@ -4653,6 +4680,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 		(unsigned long)pgdat->node_mem_map);
 #endif
 
+	init_node_memory_regions(pgdat);
 	free_area_init_core(pgdat, zones_size, zholes_size);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
