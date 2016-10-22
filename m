Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 91EED6B025E
	for <linux-mm@kvack.org>; Sat, 22 Oct 2016 11:17:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u84so80222017pfj.6
        for <linux-mm@kvack.org>; Sat, 22 Oct 2016 08:17:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id p123si7359959pga.86.2016.10.22.08.17.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Oct 2016 08:17:30 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/7] mm: remove free_unmap_vmap_area_addr
Date: Sat, 22 Oct 2016 17:17:15 +0200
Message-Id: <1477149440-12478-3-git-send-email-hch@lst.de>
In-Reply-To: <1477149440-12478-1-git-send-email-hch@lst.de>
References: <1477149440-12478-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org

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
