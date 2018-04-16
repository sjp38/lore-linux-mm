Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DDFB96B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 06:59:16 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id f19so8995142pfn.6
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 03:59:16 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id c23-v6si11216215plo.80.2018.04.16.03.59.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 03:59:15 -0700 (PDT)
From: Chintan Pandya <cpandya@codeaurora.org>
Subject: [PATCH v2] mm: vmalloc: Clean up vunmap to avoid pgtable ops twice
Date: Mon, 16 Apr 2018 16:29:02 +0530
Message-Id: <1523876342-10545-1-git-send-email-cpandya@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, labbott@redhat.com, catalin.marinas@arm.com, hannes@cmpxchg.org, f.fainelli@gmail.com, xieyisheng1@huawei.com, ard.biesheuvel@linaro.org, richard.weiyang@gmail.com, byungchul.park@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>

vunmap does page table clear operations twice in the
case when DEBUG_PAGEALLOC_ENABLE_DEFAULT is enabled.

So, clean up the code as that is unintended.

As a perf gain, we save few us. Below ftrace data was
obtained while doing 1 MB of vmalloc/vfree on ARM64
based SoC *without* this patch applied. After this
patch, we can save ~3 us (on 1 extra vunmap_page_range).

  CPU  DURATION                  FUNCTION CALLS
  |     |   |                     |   |   |   |
 6)               |  __vunmap() {
 6)               |    vmap_debug_free_range() {
 6)   3.281 us    |      vunmap_page_range();
 6) + 45.468 us   |    }
 6)   2.760 us    |    vunmap_page_range();
 6) ! 505.105 us  |  }

Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
---
 mm/vmalloc.c | 25 +++----------------------
 1 file changed, 3 insertions(+), 22 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index ebff729..6729400 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -603,26 +603,6 @@ static void unmap_vmap_area(struct vmap_area *va)
 	vunmap_page_range(va->va_start, va->va_end);
 }
 
-static void vmap_debug_free_range(unsigned long start, unsigned long end)
-{
-	/*
-	 * Unmap page tables and force a TLB flush immediately if pagealloc
-	 * debugging is enabled.  This catches use after free bugs similarly to
-	 * those in linear kernel virtual address space after a page has been
-	 * freed.
-	 *
-	 * All the lazy freeing logic is still retained, in order to minimise
-	 * intrusiveness of this debugging feature.
-	 *
-	 * This is going to be *slow* (linear kernel virtual address debugging
-	 * doesn't do a broadcast TLB flush so it is a lot faster).
-	 */
-	if (debug_pagealloc_enabled()) {
-		vunmap_page_range(start, end);
-		flush_tlb_kernel_range(start, end);
-	}
-}
-
 /*
  * lazy_max_pages is the maximum amount of virtual address space we gather up
  * before attempting to purge with a TLB flush.
@@ -756,6 +736,9 @@ static void free_unmap_vmap_area(struct vmap_area *va)
 {
 	flush_cache_vunmap(va->va_start, va->va_end);
 	unmap_vmap_area(va);
+	if (debug_pagealloc_enabled())
+		flush_tlb_kernel_range(va->va_start, va->va_end);
+
 	free_vmap_area_noflush(va);
 }
 
@@ -1142,7 +1125,6 @@ void vm_unmap_ram(const void *mem, unsigned int count)
 	BUG_ON(!PAGE_ALIGNED(addr));
 
 	debug_check_no_locks_freed(mem, size);
-	vmap_debug_free_range(addr, addr+size);
 
 	if (likely(count <= VMAP_MAX_ALLOC)) {
 		vb_free(mem, size);
@@ -1499,7 +1481,6 @@ struct vm_struct *remove_vm_area(const void *addr)
 		va->flags |= VM_LAZY_FREE;
 		spin_unlock(&vmap_area_lock);
 
-		vmap_debug_free_range(va->va_start, va->va_end);
 		kasan_free_shadow(vm);
 		free_unmap_vmap_area(va);
 
-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation
Center, Inc., is a member of Code Aurora Forum, a Linux Foundation
Collaborative Project
