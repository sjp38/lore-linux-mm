Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C35216B0418
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 08:04:23 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x23so253505293pgx.6
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 05:04:23 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id b126si7020876pgc.125.2016.11.18.05.04.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 05:04:22 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 02/10] mm: remove free_unmap_vmap_area_addr
Date: Fri, 18 Nov 2016 14:03:48 +0100
Message-Id: <1479474236-4139-3-git-send-email-hch@lst.de>
In-Reply-To: <1479474236-4139-1-git-send-email-hch@lst.de>
References: <1479474236-4139-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aryabinin@virtuozzo.com, joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

Just inline it into the only caller.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Tested-by: Jisheng Zhang <jszhang@marvell.com>
---
 mm/vmalloc.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 45de736..cf1a5ab 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -731,16 +731,6 @@ static struct vmap_area *find_vmap_area(unsigned long addr)
 	return va;
 }
 
-static void free_unmap_vmap_area_addr(unsigned long addr)
-{
-	struct vmap_area *va;
-
-	va = find_vmap_area(addr);
-	BUG_ON(!va);
-	free_unmap_vmap_area(va);
-}
-
-
 /*** Per cpu kva allocator ***/
 
 /*
@@ -1098,6 +1088,7 @@ void vm_unmap_ram(const void *mem, unsigned int count)
 {
 	unsigned long size = (unsigned long)count << PAGE_SHIFT;
 	unsigned long addr = (unsigned long)mem;
+	struct vmap_area *va;
 
 	BUG_ON(!addr);
 	BUG_ON(addr < VMALLOC_START);
@@ -1107,10 +1098,14 @@ void vm_unmap_ram(const void *mem, unsigned int count)
 	debug_check_no_locks_freed(mem, size);
 	vmap_debug_free_range(addr, addr+size);
 
-	if (likely(count <= VMAP_MAX_ALLOC))
+	if (likely(count <= VMAP_MAX_ALLOC)) {
 		vb_free(mem, size);
-	else
-		free_unmap_vmap_area_addr(addr);
+		return;
+	}
+
+	va = find_vmap_area(addr);
+	BUG_ON(!va);
+	free_unmap_vmap_area(va);
 }
 EXPORT_SYMBOL(vm_unmap_ram);
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
