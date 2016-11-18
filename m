Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 93C6C6B041E
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 08:04:33 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id p66so253368112pga.4
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 05:04:33 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id b17si8192909pgf.67.2016.11.18.05.04.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 05:04:32 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 08/10] mm: mark all calls into the vmalloc subsystem as potentially sleeping
Date: Fri, 18 Nov 2016 14:03:54 +0100
Message-Id: <1479474236-4139-9-git-send-email-hch@lst.de>
In-Reply-To: <1479474236-4139-1-git-send-email-hch@lst.de>
References: <1479474236-4139-1-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aryabinin@virtuozzo.com, joelaf@google.com, jszhang@marvell.com, chris@chris-wilson.co.uk, joaodias@google.com, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

We will take a sleeping lock in later in this series, so this adds the
proper safeguards.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Tested-by: Jisheng Zhang <jszhang@marvell.com>
---
 mm/vmalloc.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index e2030b4..25283af 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -365,7 +365,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	BUG_ON(offset_in_page(size));
 	BUG_ON(!is_power_of_2(align));
 
-	might_sleep_if(gfpflags_allow_blocking(gfp_mask));
+	might_sleep();
 
 	va = kmalloc_node(sizeof(struct vmap_area),
 			gfp_mask & GFP_RECLAIM_MASK, node);
@@ -1037,6 +1037,8 @@ void vm_unmap_aliases(void)
 	if (unlikely(!vmap_initialized))
 		return;
 
+	might_sleep();
+
 	for_each_possible_cpu(cpu) {
 		struct vmap_block_queue *vbq = &per_cpu(vmap_block_queue, cpu);
 		struct vmap_block *vb;
@@ -1080,6 +1082,7 @@ void vm_unmap_ram(const void *mem, unsigned int count)
 	unsigned long addr = (unsigned long)mem;
 	struct vmap_area *va;
 
+	might_sleep();
 	BUG_ON(!addr);
 	BUG_ON(addr < VMALLOC_START);
 	BUG_ON(addr > VMALLOC_END);
@@ -1431,6 +1434,8 @@ struct vm_struct *remove_vm_area(const void *addr)
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
