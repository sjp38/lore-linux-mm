Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 463076B0012
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:08:04 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id j21so11963942wre.20
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:08:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m196sor1062331wma.12.2018.03.05.12.08.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:08:03 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 12/25] slub: make ->reserved unsigned int
Date: Mon,  5 Mar 2018 23:07:17 +0300
Message-Id: <20180305200730.15812-12-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

->reserved is either 0 or sizeof(struct rcu_head), can't be negative.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h | 2 +-
 mm/slub.c                | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 9f59fc16444b..2b4417aa15d8 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -100,7 +100,7 @@ struct kmem_cache {
 	void (*ctor)(void *);
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
-	int reserved;		/* Reserved bytes at the end of slabs */
+	unsigned int reserved;		/* Reserved bytes at the end of slabs */
 	unsigned int red_left_pad;	/* Left redzone padding size */
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
diff --git a/mm/slub.c b/mm/slub.c
index d9db1d184549..72623f210892 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5093,7 +5093,7 @@ SLAB_ATTR_RO(destroy_by_rcu);
 
 static ssize_t reserved_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", s->reserved);
+	return sprintf(buf, "%u\n", s->reserved);
 }
 SLAB_ATTR_RO(reserved);
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
