Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9540C6B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 05:06:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 187so166220wmn.2
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 02:06:16 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d9sor4939895wrd.25.2017.09.13.02.06.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Sep 2017 02:06:15 -0700 (PDT)
From: Gioh Kim <gi-oh.kim@profitbricks.com>
Subject: [PATCH] mm/memblock.c: make the index explicit argument of for_each_memblock_type
Date: Wed, 13 Sep 2017 11:06:06 +0200
Message-Id: <20170913090606.16412-1-gi-oh.kim@profitbricks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gioh Kim <gi-oh.kim@profitbricks.com>

for_each_memblock_type macro function uses idx variable that is
the local variable of caller. This patch makes for_each_memblock_type
use only its own arguments.

Signed-off-by: Gioh Kim <gi-oh.kim@profitbricks.com>
---
 include/linux/memblock.h | 8 ++++----
 mm/memblock.c            | 8 ++++----
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index bae11c7e7bf3..ce0e5634c2f9 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -389,10 +389,10 @@ static inline unsigned long memblock_region_reserved_end_pfn(const struct memblo
 	     region < (memblock.memblock_type.regions + memblock.memblock_type.cnt);	\
 	     region++)
 
-#define for_each_memblock_type(memblock_type, rgn)			\
-	for (idx = 0, rgn = &memblock_type->regions[0];			\
-	     idx < memblock_type->cnt;					\
-	     idx++, rgn = &memblock_type->regions[idx])
+#define for_each_memblock_type(i, memblock_type, rgn)			\
+	for (i = 0, rgn = &memblock_type->regions[0];			\
+	     i < memblock_type->cnt;					\
+	     i++, rgn = &memblock_type->regions[i])
 
 #ifdef CONFIG_MEMTEST
 extern void early_memtest(phys_addr_t start, phys_addr_t end);
diff --git a/mm/memblock.c b/mm/memblock.c
index 91205780e6b1..18dbb69086bc 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -533,7 +533,7 @@ int __init_memblock memblock_add_range(struct memblock_type *type,
 	base = obase;
 	nr_new = 0;
 
-	for_each_memblock_type(type, rgn) {
+	for_each_memblock_type(idx, type, rgn) {
 		phys_addr_t rbase = rgn->base;
 		phys_addr_t rend = rbase + rgn->size;
 
@@ -637,7 +637,7 @@ static int __init_memblock memblock_isolate_range(struct memblock_type *type,
 		if (memblock_double_array(type, base, size) < 0)
 			return -ENOMEM;
 
-	for_each_memblock_type(type, rgn) {
+	for_each_memblock_type(idx, type, rgn) {
 		phys_addr_t rbase = rgn->base;
 		phys_addr_t rend = rbase + rgn->size;
 
@@ -1715,7 +1715,7 @@ static void __init_memblock memblock_dump(struct memblock_type *type)
 
 	pr_info(" %s.cnt  = 0x%lx\n", type->name, type->cnt);
 
-	for_each_memblock_type(type, rgn) {
+	for_each_memblock_type(idx, type, rgn) {
 		char nid_buf[32] = "";
 
 		base = rgn->base;
@@ -1739,7 +1739,7 @@ memblock_reserved_memory_within(phys_addr_t start_addr, phys_addr_t end_addr)
 	unsigned long size = 0;
 	int idx;
 
-	for_each_memblock_type((&memblock.reserved), rgn) {
+	for_each_memblock_type(idx, (&memblock.reserved), rgn) {
 		phys_addr_t start, end;
 
 		if (rgn->base + rgn->size < start_addr)
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
