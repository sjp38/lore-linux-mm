Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3BE6E6B0069
	for <linux-mm@kvack.org>; Sat, 29 Nov 2014 06:24:18 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so8136668pad.37
        for <linux-mm@kvack.org>; Sat, 29 Nov 2014 03:24:17 -0800 (PST)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id d6si2243216pdm.104.2014.11.29.03.24.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 29 Nov 2014 03:24:15 -0800 (PST)
Received: by mail-pd0-f170.google.com with SMTP id fp1so8025022pdb.29
        for <linux-mm@kvack.org>; Sat, 29 Nov 2014 03:24:14 -0800 (PST)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [RFC PATCH] mm/zsmalloc: allocate exactly size of struct zs_pool
Date: Sat, 29 Nov 2014 19:23:55 +0800
Message-Id: <1417260235-32053-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, ddstreet@ieee.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

In zs_create_pool(), we allocate memory more then sizeof(struct zs_pool)
  ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);

This patch allocate memory of exactly needed size.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
---
 mm/zsmalloc.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 2021df5..4d0a063 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -979,12 +979,11 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
  */
 struct zs_pool *zs_create_pool(gfp_t flags)
 {
-	int i, ovhd_size;
+	int i;
 	struct zs_pool *pool;
 	struct size_class *prev_class = NULL;
 
-	ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
-	pool = kzalloc(ovhd_size, GFP_KERNEL);
+	pool = kzalloc(sizeof(*pool), GFP_KERNEL);
 	if (!pool)
 		return NULL;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
