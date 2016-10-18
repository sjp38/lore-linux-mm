Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5129F6B025E
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 02:56:26 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u84so220027511pfj.6
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 23:56:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id f19si26188055pgk.152.2016.10.17.23.56.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 23:56:25 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 2/6] mm: mark all calls into the vmalloc subsystem as potentially sleeping
Date: Tue, 18 Oct 2016 08:56:07 +0200
Message-Id: <1476773771-11470-3-git-send-email-hch@lst.de>
In-Reply-To: <1476773771-11470-1-git-send-email-hch@lst.de>
References: <1476773771-11470-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org

This is how everyone seems to already use them, but let's make that
explicit.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/vmalloc.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d045a10..9830514 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -365,7 +365,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	BUG_ON(offset_in_page(size));
 	BUG_ON(!is_power_of_2(align));
 
-	might_sleep_if(gfpflags_allow_blocking(gfp_mask));
+	might_sleep();
 
 	va = kmalloc_node(sizeof(struct vmap_area),
 			gfp_mask & GFP_RECLAIM_MASK, node);
@@ -1056,6 +1056,8 @@ void vm_unmap_aliases(void)
 	if (unlikely(!vmap_initialized))
 		return;
 
+	might_sleep();
+
 	for_each_possible_cpu(cpu) {
 		struct vmap_block_queue *vbq = &per_cpu(vmap_block_queue, cpu);
 		struct vmap_block *vb;
@@ -1098,6 +1100,7 @@ void vm_unmap_ram(const void *mem, unsigned int count)
 	unsigned long size = (unsigned long)count << PAGE_SHIFT;
 	unsigned long addr = (unsigned long)mem;
 
+	might_sleep();
 	BUG_ON(!addr);
 	BUG_ON(addr < VMALLOC_START);
 	BUG_ON(addr > VMALLOC_END);
@@ -1445,6 +1448,8 @@ struct vm_struct *remove_vm_area(const void *addr)
 {
 	struct vmap_area *va;
 
+	might_sleep();
+
 	va = find_vmap_area((unsigned long)addr);
 	if (va && va->flags & VM_VM_AREA) {
 		struct vm_struct *vm = va->vm;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
