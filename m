Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 762856B004D
	for <linux-mm@kvack.org>; Sat, 12 Oct 2013 17:59:36 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so5921908pad.16
        for <linux-mm@kvack.org>; Sat, 12 Oct 2013 14:59:36 -0700 (PDT)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [RFC 10/23] mm/printk: Use memblock apis for early memory allocations
Date: Sat, 12 Oct 2013 17:58:53 -0400
Message-ID: <1381615146-20342-11-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
References: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, yinghai@kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, grygorii.strashko@ti.com, Santosh Shilimkar <santosh.shilimkar@ti.com>, Andrew Morton <akpm@linux-foundation.org>

Switch to memblock interfaces for early memory allocator

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 kernel/printk/printk.c |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index b4e8500..8624466 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -757,14 +757,10 @@ void __init setup_log_buf(int early)
 		return;
 
 	if (early) {
-		unsigned long mem;
-
-		mem = memblock_alloc(new_log_buf_len, PAGE_SIZE);
-		if (!mem)
-			return;
-		new_log_buf = __va(mem);
+		new_log_buf =
+			memblock_early_alloc_pages_nopanic(new_log_buf_len);
 	} else {
-		new_log_buf = alloc_bootmem_nopanic(new_log_buf_len);
+		new_log_buf = memblock_early_alloc_nopanic(new_log_buf_len);
 	}
 
 	if (unlikely(!new_log_buf)) {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
