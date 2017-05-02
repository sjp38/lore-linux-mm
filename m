Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BFAD96B02E1
	for <linux-mm@kvack.org>; Tue,  2 May 2017 10:45:42 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e16so85180731pfj.15
        for <linux-mm@kvack.org>; Tue, 02 May 2017 07:45:42 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id p19si17701346pgj.156.2017.05.02.07.45.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 07:45:42 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id t7so22775236pgt.1
        for <linux-mm@kvack.org>; Tue, 02 May 2017 07:45:42 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH V2 1/3] mm/slub: pack red_left_pad with another int to save a word
Date: Tue,  2 May 2017 22:45:31 +0800
Message-Id: <20170502144533.10729-2-richard.weiyang@gmail.com>
In-Reply-To: <20170502144533.10729-1-richard.weiyang@gmail.com>
References: <20170502144533.10729-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org
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
