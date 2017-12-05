Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 68E046B026A
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 14:49:35 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id r58so1095891qtc.7
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 11:49:35 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 34si223804qkv.261.2017.12.05.11.49.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 11:49:34 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v3 4/7] mm: enlarge type of offset argument in mem_map_offset and mem_map_next
Date: Tue,  5 Dec 2017 14:52:17 -0500
Message-Id: <20171205195220.28208-5-daniel.m.jordan@oracle.com>
In-Reply-To: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
References: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
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
index e6bd35182dae..cee1325fa682 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -366,7 +366,8 @@ static inline void mlock_migrate_page(struct page *new, struct page *old) { }
  * the maximally aligned gigantic page 'base'.  Handle any discontiguity
  * in the mem_map at MAX_ORDER_NR_PAGES boundaries.
  */
-static inline struct page *mem_map_offset(struct page *base, int offset)
+static inline struct page *mem_map_offset(struct page *base,
+					  unsigned long offset)
 {
 	if (unlikely(offset >= MAX_ORDER_NR_PAGES))
 		return nth_page(base, offset);
@@ -377,8 +378,8 @@ static inline struct page *mem_map_offset(struct page *base, int offset)
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
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
