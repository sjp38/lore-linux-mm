Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3F0DB6B02C3
	for <linux-mm@kvack.org>; Sat, 24 Jun 2017 22:53:18 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v36so19017524pgn.6
        for <linux-mm@kvack.org>; Sat, 24 Jun 2017 19:53:18 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id j61si7022164plb.197.2017.06.24.19.53.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Jun 2017 19:53:17 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id e187so11012811pgc.3
        for <linux-mm@kvack.org>; Sat, 24 Jun 2017 19:53:17 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [RFC PATCH 1/4] mm/hotplug: aligne the hotplugable range with memory_block
Date: Sun, 25 Jun 2017 10:52:24 +0800
Message-Id: <20170625025227.45665-2-richard.weiyang@gmail.com>
In-Reply-To: <20170625025227.45665-1-richard.weiyang@gmail.com>
References: <20170625025227.45665-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, linux-mm@kvack.org
Cc: Wei Yang <richard.weiyang@gmail.com>

memory hotplug is memory block aligned instead of section aligned.

This patch fix the range check during hotplug.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 drivers/base/memory.c  | 3 ++-
 include/linux/memory.h | 2 ++
 mm/memory_hotplug.c    | 9 +++++----
 3 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index c7c4e0325cdb..b54cfe9cd98b 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -31,7 +31,8 @@ static DEFINE_MUTEX(mem_sysfs_mutex);
 
 #define to_memory_block(dev) container_of(dev, struct memory_block, dev)
 
-static int sections_per_block;
+int sections_per_block;
+EXPORT_SYMBOL(sections_per_block);
 
 static inline int base_memory_block_id(int section_nr)
 {
diff --git a/include/linux/memory.h b/include/linux/memory.h
index b723a686fc10..51a6355aa56d 100644
--- a/include/linux/memory.h
+++ b/include/linux/memory.h
@@ -142,4 +142,6 @@ extern struct memory_block *find_memory_block(struct mem_section *);
  */
 extern struct mutex text_mutex;
 
+extern int sections_per_block;
+
 #endif /* _LINUX_MEMORY_H_ */
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 387ca386142c..f5d06afc8645 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1183,11 +1183,12 @@ static int check_hotplug_memory_range(u64 start, u64 size)
 {
 	u64 start_pfn = PFN_DOWN(start);
 	u64 nr_pages = size >> PAGE_SHIFT;
+	u64 page_per_block = sections_per_block * PAGES_PER_SECTION;
 
-	/* Memory range must be aligned with section */
-	if ((start_pfn & ~PAGE_SECTION_MASK) ||
-	    (nr_pages % PAGES_PER_SECTION) || (!nr_pages)) {
-		pr_err("Section-unaligned hotplug range: start 0x%llx, size 0x%llx\n",
+	/* Memory range must be aligned with memory_block */
+	if ((start_pfn & (page_per_block - 1)) ||
+	    (nr_pages % page_per_block) || (!nr_pages)) {
+		pr_err("Memory_block-unaligned hotplug range: start 0x%llx, size 0x%llx\n",
 				(unsigned long long)start,
 				(unsigned long long)size);
 		return -EINVAL;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
