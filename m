Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id AF0106B0005
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 12:12:51 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p85so155951240lfg.3
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 09:12:51 -0700 (PDT)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id j186si8614116wmg.39.2016.08.05.05.18.24
        for <linux-mm@kvack.org>;
        Fri, 05 Aug 2016 05:18:24 -0700 (PDT)
From: James Hogan <james.hogan@imgtec.com>
Subject: [PATCH] metag: Drop show_mem() from mem_init()
Date: Fri, 5 Aug 2016 13:17:04 +0100
Message-ID: <20160805121704.32198-1-james.hogan@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-metag@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, James Hogan <james.hogan@imgtec.com>, Mel Gorman <mgorman@techsingularity.net>

The recent commit 599d0c954f91 ("mm, vmscan: move LRU lists to node"),
changed memory management code so that show_mem() is no longer safe to
call prior to setup_per_cpu_pageset(), as pgdat->per_cpu_nodestats will
still be NULL. This causes an oops on metag due to the call to
show_mem() from mem_init():

  node_page_state_snapshot(...) + 0x48
  pgdat_reclaimable(struct pglist_data * pgdat = 0x402517a0)
  show_free_areas(unsigned int filter = 0) + 0x2cc
  show_mem(unsigned int filter = 0) + 0x18
  mem_init()
  mm_init()
  start_kernel() + 0x204

This wasn't a problem before with zone_reclaimable() as zone_pcp_init()
was already setting zone->pageset to &boot_pageset, via setup_arch() and
paging_init(), which happens before mm_init():

  zone_pcp_init(...)
  free_area_init_core(...) + 0x138
  free_area_init_node(int nid = 0, ...) + 0x1a0
  free_area_init_nodes(...) + 0x440
  paging_init(unsigned long mem_end = 0x4fe00000) + 0x378
  setup_arch(char ** cmdline_p = 0x4024e038) + 0x2b8
  start_kernel() + 0x54

No other arches appear to call show_mem() during boot, and it doesn't
really add much value to the log, so lets just drop it from mem_init().

Signed-off-by: James Hogan <james.hogan@imgtec.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-metag@vger.kernel.org
---
 arch/metag/mm/init.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/metag/mm/init.c b/arch/metag/mm/init.c
index 11fa51c89617..c0ec116b3993 100644
--- a/arch/metag/mm/init.c
+++ b/arch/metag/mm/init.c
@@ -390,7 +390,6 @@ void __init mem_init(void)
 
 	free_all_bootmem();
 	mem_init_print_info(NULL);
-	show_mem(0);
 }
 
 void free_initmem(void)
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
