Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 241196B0261
	for <linux-mm@kvack.org>; Tue, 31 May 2016 19:20:56 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s73so1975967pfs.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 16:20:56 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id ag3si6311106pad.44.2016.05.31.16.20.50
        for <linux-mm@kvack.org>;
        Tue, 31 May 2016 16:20:50 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v7 05/12] zsmalloc: use bit_spin_lock
Date: Wed,  1 Jun 2016 08:21:14 +0900
Message-Id: <1464736881-24886-6-git-send-email-minchan@kernel.org>
In-Reply-To: <1464736881-24886-1-git-send-email-minchan@kernel.org>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Use kernel standard bit spin-lock instead of custom mess. Even, it has
a bug which doesn't disable preemption. The reason we don't have any
problem is that we have used it during preemption disable section
by class->lock spinlock. So no need to go to stable.

Reviewed-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 79295c73dc9f..39f29aedd5d6 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -868,21 +868,17 @@ static unsigned long obj_idx_to_offset(struct page *page,
 
 static inline int trypin_tag(unsigned long handle)
 {
-	unsigned long *ptr = (unsigned long *)handle;
-
-	return !test_and_set_bit_lock(HANDLE_PIN_BIT, ptr);
+	return bit_spin_trylock(HANDLE_PIN_BIT, (unsigned long *)handle);
 }
 
 static void pin_tag(unsigned long handle)
 {
-	while (!trypin_tag(handle));
+	bit_spin_lock(HANDLE_PIN_BIT, (unsigned long *)handle);
 }
 
 static void unpin_tag(unsigned long handle)
 {
-	unsigned long *ptr = (unsigned long *)handle;
-
-	clear_bit_unlock(HANDLE_PIN_BIT, ptr);
+	bit_spin_unlock(HANDLE_PIN_BIT, (unsigned long *)handle);
 }
 
 static void reset_page(struct page *page)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
