Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id DAD0F6B0038
	for <linux-mm@kvack.org>; Fri, 13 Feb 2015 04:18:15 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id nt9so17448189obb.13
        for <linux-mm@kvack.org>; Fri, 13 Feb 2015 01:18:15 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id n145si842866oig.14.2015.02.13.01.18.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Feb 2015 01:18:15 -0800 (PST)
From: Sheng Yong <shengyong1@huawei.com>
Subject: [PATCH] memory hotplug: Use macro to switch between section and pfn
Date: Fri, 13 Feb 2015 09:13:23 +0000
Message-ID: <1423818803-202364-1-git-send-email-shengyong1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org

Use macro section_nr_to_pfn and pfn_to_section_nr to switch between section
and pfn, instead of bit operations, no semantic changes.

Signed-off-by: Sheng Yong <shengyong1@huawei.com>
---
 drivers/base/memory.c | 2 +-
 mm/memory_hotplug.c   | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 85be040..8f6d988 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -228,7 +228,7 @@ memory_block_action(unsigned long phys_index, unsigned long action, int online_t
 	struct page *first_page;
 	int ret;
 
-	start_pfn = phys_index << PFN_SECTION_SHIFT;
+	start_pfn = section_nr_to_pfn(phys_index);
 	first_page = pfn_to_page(start_pfn);
 
 	switch (action) {
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index b82b61e..2afda10 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -502,7 +502,7 @@ int __ref __add_pages(int nid, struct zone *zone, unsigned long phys_start_pfn,
 	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
 
 	for (i = start_sec; i <= end_sec; i++) {
-		err = __add_section(nid, zone, i << PFN_SECTION_SHIFT);
+		err = __add_section(nid, zone, section_nr_to_pfn(i));
 
 		/*
 		 * EEXIST is finally dealt with by ioresource collision
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
