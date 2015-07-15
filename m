Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 004D928027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 02:35:43 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so19398664pdj.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 23:35:42 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id db5si5804832pbb.103.2015.07.14.23.35.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 23:35:42 -0700 (PDT)
Received: by padck2 with SMTP id ck2so18570364pad.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 23:35:41 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 1/2] mm/cma_debug: fix debugging alloc/free interface
Date: Wed, 15 Jul 2015 15:35:28 +0900
Message-Id: <1436942129-18020-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Stefan Strogin <stefan.strogin@gmail.com>, Michal Nazarewicz <mina86@mina86.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

CMA has alloc/free interface for debugging. It is intended that alloc/free
occurs in specific CMA region, but, currently, alloc/free interface is
on root dir due to the bug so we can't select CMA region where alloc/free
happens.

This patch fixes this problem by making alloc/free interface per
CMA region.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/cma_debug.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/cma_debug.c b/mm/cma_debug.c
index 7621ee3..22190a7 100644
--- a/mm/cma_debug.c
+++ b/mm/cma_debug.c
@@ -170,10 +170,10 @@ static void cma_debugfs_add_one(struct cma *cma, int idx)
 
 	tmp = debugfs_create_dir(name, cma_debugfs_root);
 
-	debugfs_create_file("alloc", S_IWUSR, cma_debugfs_root, cma,
+	debugfs_create_file("alloc", S_IWUSR, tmp, cma,
 				&cma_alloc_fops);
 
-	debugfs_create_file("free", S_IWUSR, cma_debugfs_root, cma,
+	debugfs_create_file("free", S_IWUSR, tmp, cma,
 				&cma_free_fops);
 
 	debugfs_create_file("base_pfn", S_IRUGO, tmp,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
