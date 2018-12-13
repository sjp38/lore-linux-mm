Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA7F28E0161
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 22:27:53 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id s71so561024pfi.22
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 19:27:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 23sor913850pfr.25.2018.12.12.19.27.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 19:27:52 -0800 (PST)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm, memory_hotplug: pass next_memory_node to new_page_nodemask()
Date: Thu, 13 Dec 2018 11:27:44 +0800
Message-Id: <20181213032744.68323-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, osalvador@suse.de, david@redhat.com, Wei Yang <richard.weiyang@gmail.com>

As the document says new_page_nodemask() will try to allocate from a
different node, but current behavior just do the opposite by passing
current nid as preferred_nid to new_page_nodemask().

This patch pass next_memory_node as preferred_nid to new_page_nodemask()
to fix it.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/memory_hotplug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 6910e0eea074..0c075aac0a81 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1335,7 +1335,7 @@ static struct page *new_node_page(struct page *page, unsigned long private)
 	if (nodes_empty(nmask))
 		node_set(nid, nmask);
 
-	return new_page_nodemask(page, nid, &nmask);
+	return new_page_nodemask(page, next_memory_node(nid), &nmask);
 }
 
 #define NR_OFFLINE_AT_ONCE_PAGES	(256)
-- 
2.15.1
