Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 63DE16B0003
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 08:45:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p3-v6so1497493wmc.7
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 05:45:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y5-v6sor5893295wrn.69.2018.07.31.05.45.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 05:45:14 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [PATCH] mm: make __paginginit based on CONFIG_MEMORY_HOTPLUG
Date: Tue, 31 Jul 2018 14:45:04 +0200
Message-Id: <20180731124504.27582-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com, vbabka@suse.cz, kirill.shutemov@linux.intel.com, pasha.tatashin@oracle.com, iamjoonsoo.kim@lge.com, mgorman@suse.de, jrdr.linux@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

__pagininit macro is being used to mark functions for:

a) Functions that we do not need to keep once the system is fully
   initialized with regard to memory.
b) Functions that will be needed for the memory-hotplug code,
   and because of that we need to keep them after initialization.

Right now, the condition to choose between one or the other is based on
CONFIG_SPARSEMEM, but I think that this should be changed to be based
on CONFIG_MEMORY_HOTPLUG.

The reason behind this is that it can very well be that we have CONFIG_SPARSEMEM
enabled, but not CONFIG_MEMORY_HOTPLUG, and thus, we will not need the
functions marked as __paginginit to stay around, since no
memory-hotplug code will call them.

Although the amount of freed bytes is not that big, I think it will
become more clear what __paginginit is used for.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 mm/internal.h | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 33c22754d282..c9170b4f7699 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -392,10 +392,11 @@ static inline struct page *mem_map_next(struct page *iter,
 /*
  * FLATMEM and DISCONTIGMEM configurations use alloc_bootmem_node,
  * so all functions starting at paging_init should be marked __init
- * in those cases. SPARSEMEM, however, allows for memory hotplug,
- * and alloc_bootmem_node is not used.
+ * in those cases.
+ * In case that MEMORY_HOTPLUG is enabled, we need to keep those
+ * functions around since they can be called when hot-adding memory.
  */
-#ifdef CONFIG_SPARSEMEM
+#ifdef CONFIG_MEMORY_HOTPLUG
 #define __paginginit __meminit
 #else
 #define __paginginit __init
-- 
2.13.6
