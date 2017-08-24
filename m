Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E1434440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 16:48:48 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id x36so2835034qtx.9
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 13:48:48 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 22si5087431qkt.444.2017.08.24.13.48.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 13:48:46 -0700 (PDT)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v2 4/7] mm: enlarge type of offset argument in mem_map_offset and mem_map_next
Date: Thu, 24 Aug 2017 16:50:01 -0400
Message-Id: <20170824205004.18502-5-daniel.m.jordan@oracle.com>
In-Reply-To: <20170824205004.18502-1-daniel.m.jordan@oracle.com>
References: <20170824205004.18502-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

Changes the type of 'offset' from int to unsigned long in both
mem_map_offset and mem_map_next.

This facilitates ktask's use of mem_map_next with its unsigned long
types to avoid silent truncation when these unsigned longs are passed as
ints.

It also fixes the preexisting truncation of 'offset' from unsigned long
to int by the sole caller of mem_map_offset, follow_hugetlb_page.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Steve Sistare <steven.sistare@oracle.com>
Cc: Aaron Lu <aaron.lu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Tim Chen <tim.c.chen@intel.com>
---
 mm/internal.h | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 4ef49fc55e58..a033b47c44d3 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -365,7 +365,8 @@ static inline void mlock_migrate_page(struct page *new, struct page *old) { }
  * the maximally aligned gigantic page 'base'.  Handle any discontiguity
  * in the mem_map at MAX_ORDER_NR_PAGES boundaries.
  */
-static inline struct page *mem_map_offset(struct page *base, int offset)
+static inline struct page *mem_map_offset(struct page *base,
+					  unsigned long offset)
 {
 	if (unlikely(offset >= MAX_ORDER_NR_PAGES))
 		return nth_page(base, offset);
@@ -376,8 +377,8 @@ static inline struct page *mem_map_offset(struct page *base, int offset)
  * Iterator over all subpages within the maximally aligned gigantic
  * page 'base'.  Handle any discontiguity in the mem_map.
  */
-static inline struct page *mem_map_next(struct page *iter,
-						struct page *base, int offset)
+static inline struct page *mem_map_next(struct page *iter, struct page *base,
+					unsigned long offset)
 {
 	if (unlikely((offset & (MAX_ORDER_NR_PAGES - 1)) == 0)) {
 		unsigned long pfn = page_to_pfn(base) + offset;
-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
