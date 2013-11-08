Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 20F486B0249
	for <linux-mm@kvack.org>; Fri,  8 Nov 2013 18:43:31 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id q10so2805678pdj.14
        for <linux-mm@kvack.org>; Fri, 08 Nov 2013 15:43:30 -0800 (PST)
Received: from psmtp.com ([74.125.245.189])
        by mx.google.com with SMTP id yk3si8440849pac.157.2013.11.08.15.43.29
        for <linux-mm@kvack.org>;
        Fri, 08 Nov 2013 15:43:29 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH 21/24] mm/firmware: Use memblock apis for early memory allocations
Date: Fri, 8 Nov 2013 18:41:57 -0500
Message-ID: <1383954120-24368-22-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
References: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Grygorii Strashko <grygorii.strashko@ti.com>

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
 drivers/firmware/memmap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
index e2e04b0..15550b2 100644
--- a/drivers/firmware/memmap.c
+++ b/drivers/firmware/memmap.c
@@ -324,7 +324,7 @@ int __init firmware_map_add_early(u64 start, u64 end, const char *type)
 {
 	struct firmware_map_entry *entry;
 
-	entry = alloc_bootmem(sizeof(struct firmware_map_entry));
+	entry = memblock_virt_alloc(sizeof(struct firmware_map_entry));
 	if (WARN_ON(!entry))
 		return -ENOMEM;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
