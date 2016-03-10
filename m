Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id A5B4D828E1
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 15:51:40 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id p65so3409711wmp.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 12:51:40 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id km6si7002804wjc.1.2016.03.10.12.51.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 12:51:39 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: memcontrol: clarify the uncharge_list() loop
Date: Thu, 10 Mar 2016 15:50:15 -0500
Message-Id: <1457643015-8828-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

uncharge_list() does an unusual list walk because the function can
take regular lists with dedicated list_heads as well as singleton
lists where a single page is passed via the page->lru list node.

This can sometimes lead to confusion as well as suggestions to replace
the loop with a list_for_each_entry(), which wouldn't work.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8614e0d750e5..fa7bf354ae32 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5420,6 +5420,10 @@ static void uncharge_list(struct list_head *page_list)
 	struct list_head *next;
 	struct page *page;
 
+	/*
+	 * Note that the list can be a single page->lru; hence the
+	 * do-while loop instead of a simple list_for_each_entry().
+	 */
 	next = page_list->next;
 	do {
 		unsigned int nr_pages = 1;
-- 
2.7.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
