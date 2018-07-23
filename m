Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5C93D6B0006
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 01:57:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x21-v6so7462488eds.2
        for <linux-mm@kvack.org>; Sun, 22 Jul 2018 22:57:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j5-v6si6059450edp.51.2018.07.22.22.57.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jul 2018 22:57:13 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6N5s1mV031321
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 01:57:11 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kd4uu8wug-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 01:57:10 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 23 Jul 2018 06:57:08 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 1/4] ia64: contig/paging_init: reduce code duplication
Date: Mon, 23 Jul 2018 08:56:55 +0300
In-Reply-To: <1532325418-22617-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1532325418-22617-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1532325418-22617-2-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The FLATMEM version of paging_init has calls to free_area_init_nodes() in
the end of every branch of 'if' and 'ifdef' statements.

Let's call this function outside the 'ifdef' and 'if' statements instead.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/ia64/mm/contig.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index 7d64b30..1835144 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -248,7 +248,6 @@ paging_init (void)
 	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
 	if (max_gap < LARGE_GAP) {
 		vmem_map = (struct page *) 0;
-		free_area_init_nodes(max_zone_pfns);
 	} else {
 		unsigned long map_size;
 
@@ -266,13 +265,12 @@ paging_init (void)
 		 */
 		NODE_DATA(0)->node_mem_map = vmem_map +
 			find_min_pfn_with_active_regions();
-		free_area_init_nodes(max_zone_pfns);
 
 		printk("Virtual mem_map starts at 0x%p\n", mem_map);
 	}
 #else /* !CONFIG_VIRTUAL_MEM_MAP */
 	memblock_add_node(0, PFN_PHYS(max_low_pfn), 0);
-	free_area_init_nodes(max_zone_pfns);
 #endif /* !CONFIG_VIRTUAL_MEM_MAP */
+	free_area_init_nodes(max_zone_pfns);
 	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
 }
-- 
2.7.4
