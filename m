Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C4E5D6B02EE
	for <linux-mm@kvack.org>; Sun, 30 Apr 2017 07:32:05 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id w23so5060642pgm.22
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 04:32:05 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id b12si12407808plm.77.2017.04.30.04.32.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Apr 2017 04:32:05 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id b23so8281856pfc.0
        for <linux-mm@kvack.org>; Sun, 30 Apr 2017 04:32:04 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH 1/3] mm/slub: pack red_left_pad with another int to save a word
Date: Sun, 30 Apr 2017 19:31:50 +0800
Message-Id: <20170430113152.6590-2-richard.weiyang@gmail.com>
In-Reply-To: <20170430113152.6590-1-richard.weiyang@gmail.com>
References: <20170430113152.6590-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

On 64bit arch, struct is 8-bytes aligned, so int will occupy a word if it
doesn't sits well.

This patch pack red_left_pad with reserved to save 8 bytes for struct
kmem_cache on a 64bit arch.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 include/linux/slub_def.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 07ef550c6627..ec13aab32647 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -79,9 +79,9 @@ struct kmem_cache {
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
 	int reserved;		/* Reserved bytes at the end of slabs */
+	int red_left_pad;	/* Left redzone padding size */
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
-	int red_left_pad;	/* Left redzone padding size */
 #ifdef CONFIG_SYSFS
 	struct kobject kobj;	/* For sysfs */
 #endif
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
