Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5287E44093F
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 18:16:11 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id m68so122861357ith.1
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 15:16:11 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id j125si3257300ith.0.2017.07.14.15.16.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 15:16:10 -0700 (PDT)
From: daniel.m.jordan@oracle.com
Subject: [RFC PATCH v1 4/6] mm: enlarge type of offset argument in mem_map_offset and mem_map_next
Date: Fri, 14 Jul 2017 15:16:11 -0700
Message-Id: <1500070573-3948-5-git-send-email-daniel.m.jordan@oracle.com>
In-Reply-To: <1500070573-3948-1-git-send-email-daniel.m.jordan@oracle.com>
References: <1500070573-3948-1-git-send-email-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Changes the type of 'offset' from int to unsigned long in both
mem_map_offset and mem_map_next.

This facilitates ktask's use of mem_map_next with its unsigned long
types to avoid silent truncation when these unsigned longs are passed as
ints.

It also fixes the preexisting truncation of 'offset' from unsigned long
to int by the sole caller of mem_map_offset, follow_hugetlb_page.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 mm/internal.h |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 0e4f558..96d9669 100644
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
@@ -376,8 +377,8 @@ static inline void mlock_migrate_page(struct page *new, struct page *old) { }
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
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
