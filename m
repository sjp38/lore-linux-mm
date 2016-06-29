Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id F35576B0005
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 10:44:20 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m185so125502252qke.3
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 07:44:20 -0700 (PDT)
Received: from mail-ob0-x241.google.com (mail-ob0-x241.google.com. [2607:f8b0:4003:c01::241])
        by mx.google.com with ESMTPS id e7si3258311qkf.72.2016.06.29.07.44.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jun 2016 07:44:20 -0700 (PDT)
Received: by mail-ob0-x241.google.com with SMTP id qw9so3383999obb.3
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 07:44:20 -0700 (PDT)
MIME-Version: 1.0
From: vichy <vichy.kuo@gmail.com>
Date: Wed, 29 Jun 2016 22:44:19 +0800
Message-ID: <CAOVJa8EPGfWwLtAY8YNOzBqG99J7xL0dMrRmvXs0d8GaXJF9Xw@mail.gmail.com>
Subject: [PATCH 1/1] mm: allocate order 0 page from pcb before zone_watermark_ok
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

hi all:
In normal case, the allocation of any order page started after
zone_watermark_ok. But if so far pcp->count of this zone is not 0,
why don't we just let order-0-page allocation before zone_watermark_ok.
That mean the order-0-page will be successfully allocated even
free_pages is beneath zone->watermark.
For above idea, I made below patch for your reference.

Signed-off-by: pierre kuo <vichy.kuo@gmail.com>
---
 mm/page_alloc.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c1069ef..406655f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2622,6 +2622,14 @@ static void reset_alloc_batches(struct zone
*preferred_zone)
        } while (zone++ != preferred_zone);
 }

+static struct page *
+__get_hot_cold_page(bool cold, struct list_head *list)
+{
+       if (cold)
+               return list_last_entry(list, struct page, lru);
+       else
+               return list_first_entry(list, struct page, lru);
+}
 /*
  * get_page_from_freelist goes through the zonelist trying to allocate
  * a page.
@@ -2695,6 +2703,24 @@ zonelist_scan:
                if (ac->spread_dirty_pages && !zone_dirty_ok(zone))
                        continue;

+               if (likely(order == 0)) {
+                       struct per_cpu_pages *pcp;
+                       struct list_head *list;
+                       unsigned long flags;
+                       bool cold = ((gfp_mask & __GFP_COLD) != 0);
+
+                       local_irq_save(flags);
+                       pcp = &this_cpu_ptr(zone->pageset)->pcp;
+                       list = &pcp->lists[ac->migratetype];
+                       if (!list_empty(list)) {
+                               page = __get_hot_cold_page(cold, list);
+                               list_del(&page->lru);
+                               pcp->count--;
+                       }
+                       local_irq_restore(flags);
+                       if (page)
+                               goto get_page_order0;
+               }
                mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
                if (!zone_watermark_ok(zone, order, mark,
                                       ac->classzone_idx, alloc_flags)) {
@@ -2730,6 +2756,7 @@ zonelist_scan:
 try_this_zone:
                page = buffered_rmqueue(ac->preferred_zone, zone, order,
                                gfp_mask, alloc_flags, ac->migratetype);
+get_page_order0:
                if (page) {
                        if (prep_new_page(page, order, gfp_mask, alloc_flags))
                                goto try_this_zone;
--
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
