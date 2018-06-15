Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE5056B0003
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 11:58:05 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id i64-v6so8258750qkh.14
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 08:58:05 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id t127-v6si5809796qkc.292.2018.06.15.08.58.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 08:58:04 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH] mm: skip invalid pages block at a time in zero_resv_unresv
Date: Fri, 15 Jun 2018 11:57:33 -0400
Message-Id: <20180615155733.1175-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org, osalvador@suse.de, willy@infradead.org, mingo@kernel.org, dan.j.williams@intel.com, ying.huang@intel.com

The role of zero_resv_unavail() is to make sure that every struct page that
is allocated but is not backed by memory that is accessible by kernel is
zeroed and not in some uninitialized state.

Since struct pages are allocated in blocks (2M pages in x86 case), we can
skip pageblock_nr_pages at a time, when the first one is found to be
invalid.

This optimization may help since now on x86 every hole in e820 maps
is marked as reserved in memblock, and thus will go through this function.

This function is called before sched_clock() is initialized, so I used my
x86 early boot clock patches to measure the performance improvement.

With 1T hole on i7-8700 currently we would take 0.606918s of boot time, but
with this optimization 0.001103s.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/page_alloc.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1521100f1e63..94f1b3201735 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6404,8 +6404,11 @@ void __paginginit zero_resv_unavail(void)
 	pgcnt = 0;
 	for_each_resv_unavail_range(i, &start, &end) {
 		for (pfn = PFN_DOWN(start); pfn < PFN_UP(end); pfn++) {
-			if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages)))
+			if (!pfn_valid(ALIGN_DOWN(pfn, pageblock_nr_pages))) {
+				pfn = ALIGN_DOWN(pfn, pageblock_nr_pages)
+					+ pageblock_nr_pages - 1;
 				continue;
+			}
 			mm_zero_struct_page(pfn_to_page(pfn));
 			pgcnt++;
 		}
-- 
2.17.1
