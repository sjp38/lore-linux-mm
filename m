Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3655C6B0038
	for <linux-mm@kvack.org>; Mon,  4 May 2015 11:27:58 -0400 (EDT)
Received: by labbd9 with SMTP id bd9so106766563lab.2
        for <linux-mm@kvack.org>; Mon, 04 May 2015 08:27:57 -0700 (PDT)
Received: from mail-la0-x22e.google.com (mail-la0-x22e.google.com. [2a00:1450:4010:c03::22e])
        by mx.google.com with ESMTPS id n7si10298519lbs.61.2015.05.04.08.27.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 08:27:55 -0700 (PDT)
Received: by layy10 with SMTP id y10so106731212lay.0
        for <linux-mm@kvack.org>; Mon, 04 May 2015 08:27:55 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] mm: only define hashdist variable when needed
Date: Mon,  4 May 2015 17:27:29 +0200
Message-Id: <1430753249-30850-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

For !CONFIG_NUMA, hashdist will always be 0, since it's setter is
otherwise compiled out. So we can save 4 bytes of data and some .text
(although mostly in __init functions) by only defining it for
CONFIG_NUMA.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 include/linux/bootmem.h | 8 ++++----
 mm/page_alloc.c         | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 0995c2de8162..f589222bfa87 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -357,12 +357,12 @@ extern void *alloc_large_system_hash(const char *tablename,
 /* Only NUMA needs hash distribution. 64bit NUMA architectures have
  * sufficient vmalloc space.
  */
-#if defined(CONFIG_NUMA) && defined(CONFIG_64BIT)
-#define HASHDIST_DEFAULT 1
+#ifdef CONFIG_NUMA
+#define HASHDIST_DEFAULT IS_ENABLED(CONFIG_64BIT)
+extern int hashdist;		/* Distribute hashes across NUMA nodes? */
 #else
-#define HASHDIST_DEFAULT 0
+#define hashdist (0)
 #endif
-extern int hashdist;		/* Distribute hashes across NUMA nodes? */
 
 
 #endif /* _LINUX_BOOTMEM_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebffa0e4a9c0..159dbbc3375d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6013,9 +6013,9 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_NUMA
 int hashdist = HASHDIST_DEFAULT;
 
-#ifdef CONFIG_NUMA
 static int __init set_hashdist(char *str)
 {
 	if (!str)
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
