Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 271DA6B00FB
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 16:52:03 -0500 (EST)
Received: by mail-yh0-f52.google.com with SMTP id i72so3225247yha.39
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 13:52:02 -0800 (PST)
Received: from arroyo.ext.ti.com (arroyo.ext.ti.com. [192.94.94.40])
        by mx.google.com with ESMTPS id n44si11292468yhn.140.2013.12.09.13.52.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 13:52:02 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH v3 10/23] mm/printk: Use memblock apis for early memory allocations
Date: Mon, 9 Dec 2013 16:50:43 -0500
Message-ID: <1386625856-12942-11-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com>
References: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Grygorii Strashko <grygorii.strashko@ti.com>

Switch to memblock interfaces for early memory allocator instead of
bootmem allocator. No functional change in beahvior than what it is
in current code from bootmem users points of view.

Archs already converted to NO_BOOTMEM now directly use memblock
interfaces instead of bootmem wrappers build on top of memblock. And the
archs which still uses bootmem, these new apis just fallback to exiting
bootmem APIs.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 kernel/printk/printk.c |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index be7c86b..f8b41bd 100644
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
+			memblock_virt_alloc(new_log_buf_len, PAGE_SIZE);
 	} else {
-		new_log_buf = alloc_bootmem_nopanic(new_log_buf_len);
+		new_log_buf = memblock_virt_alloc_nopanic(new_log_buf_len, 0);
 	}
 
 	if (unlikely(!new_log_buf)) {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
