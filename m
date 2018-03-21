Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 532996B000C
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 00:38:24 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v126so118526pgb.23
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 21:38:24 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id b7si2219038pgc.551.2018.03.20.21.38.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 21:38:23 -0700 (PDT)
Received: from epcas5p3.samsung.com (unknown [182.195.41.41])
	by mailout4.samsung.com (KnoxPortal) with ESMTP id 20180321043820epoutp04554ef1e2f9ebf6d6fde07fa49f22a748~d1ZiPXRrN1601316013epoutp04k
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 04:38:20 +0000 (GMT)
From: Maninder Singh <maninder1.s@samsung.com>
Subject: [PATCH 1/1] mm/page_owner: fix recursion bug after changing skip
 entries
Date: Wed, 21 Mar 2018 10:07:23 +0530
Message-Id: <1521607043-34670-1-git-send-email-maninder1.s@samsung.com>
Content-Type: text/plain; charset="utf-8"
References: <CGME20180321043818epcas5p176fe0e0bbfce685420df2bfb7a421acd@epcas5p1.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com, osalvador@techadventures.net, gregkh@linuxfoundation.org, ayush.m@samsung.com, guptap@codeaurora.org, vinmenon@codeaurora.org, gomonovych@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, a.sahrawat@samsung.com, pankaj.m@samsung.com, Maninder Singh <maninder1.s@samsung.com>, Vaneet Narang <v.narang@samsung.com>

This patch fixes "5f48f0bd4e368425db4424b9afd1bd251d32367a".
(mm, page_owner: skip unnecessary stack_trace entries)

Because if we skip first two entries then logic of checking count
value as 2 for recursion is broken and code will go in one depth
recursion.

so we need to check only one call of _RET_IP(__set_page_owner)
while checking for recursion.

Current Backtrace while checking for recursion:-

(save_stack)             from (__set_page_owner)  // (But recursion returns true here)
(__set_page_owner)       from (get_page_from_freelist)
(get_page_from_freelist) from (__alloc_pages_nodemask)
(__alloc_pages_nodemask) from (depot_save_stack)
(depot_save_stack)       from (save_stack)       // recursion should return true here
(save_stack)             from (__set_page_owner)
(__set_page_owner)       from (get_page_from_freelist)
(get_page_from_freelist) from (__alloc_pages_nodemask+)
(__alloc_pages_nodemask) from (depot_save_stack)
(depot_save_stack)       from (save_stack)
(save_stack)             from (__set_page_owner)
(__set_page_owner)       from (get_page_from_freelist)

Correct Backtrace with fix:

(save_stack)             from (__set_page_owner) // recursion returned true here
(__set_page_owner)       from (get_page_from_freelist)
(get_page_from_freelist) from (__alloc_pages_nodemask+)
(__alloc_pages_nodemask) from (depot_save_stack)
(depot_save_stack)       from (save_stack)
(save_stack)             from (__set_page_owner)
(__set_page_owner)       from (get_page_from_freelist)

Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
Signed-off-by: Vaneet Narang <v.narang@samsung.com>
---
 mm/page_owner.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 8592543..46ab1c4 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -123,13 +123,13 @@ void __reset_page_owner(struct page *page, unsigned int order)
 static inline bool check_recursive_alloc(struct stack_trace *trace,
 					unsigned long ip)
 {
-	int i, count;
+	int i;
 
 	if (!trace->nr_entries)
 		return false;
 
-	for (i = 0, count = 0; i < trace->nr_entries; i++) {
-		if (trace->entries[i] == ip && ++count == 2)
+	for (i = 0; i < trace->nr_entries; i++) {
+		if (trace->entries[i] == ip)
 			return true;
 	}
 
-- 
1.7.1
