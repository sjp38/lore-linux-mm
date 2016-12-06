Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 92A1C6B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 00:55:13 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id p66so423441154pga.4
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 21:55:13 -0800 (PST)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id p16si17962972pfd.92.2016.12.05.21.55.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 21:55:12 -0800 (PST)
Received: by mail-pf0-x230.google.com with SMTP id d2so68401729pfd.0
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 21:55:12 -0800 (PST)
Date: Mon, 5 Dec 2016 21:55:10 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: page_idle_get_page() does not need zone_lru_lock
Message-ID: <alpine.LSU.2.11.1612052152560.13021@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm@kvack.org

Rechecking PageLRU() after get_page_unless_zero() may have value, but
holding zone_lru_lock around that serves no useful purpose: delete it.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/page_idle.c |    4 ----
 1 file changed, 4 deletions(-)

--- 4.9-rc8/mm/page_idle.c	2016-10-02 16:24:33.000000000 -0700
+++ linux/mm/page_idle.c	2016-12-05 19:44:32.646625435 -0800
@@ -30,7 +30,6 @@
 static struct page *page_idle_get_page(unsigned long pfn)
 {
 	struct page *page;
-	struct zone *zone;
 
 	if (!pfn_valid(pfn))
 		return NULL;
@@ -40,13 +39,10 @@ static struct page *page_idle_get_page(u
 	    !get_page_unless_zero(page))
 		return NULL;
 
-	zone = page_zone(page);
-	spin_lock_irq(zone_lru_lock(zone));
 	if (unlikely(!PageLRU(page))) {
 		put_page(page);
 		page = NULL;
 	}
-	spin_unlock_irq(zone_lru_lock(zone));
 	return page;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
