Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 26DE38E01D1
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 06:11:23 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id b185so4118020qkc.3
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 03:11:23 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x54si2813206qtx.347.2018.12.14.03.11.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 03:11:22 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: [PATCH v1 8/9] ia64: perfmon: Don't mark buffer pages as PG_reserved
Date: Fri, 14 Dec 2018 12:10:13 +0100
Message-Id: <20181214111014.15672-9-david@redhat.com>
In-Reply-To: <20181214111014.15672-1-david@redhat.com>
References: <20181214111014.15672-1-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-mediatek@lists.infradead.org, David Hildenbrand <david@redhat.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, David Howells <dhowells@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>

In the old days, remap_pfn_range() required pages to be marked as
PG_reserved, so they would e.g. never get swapped out. This was required
for special mappings. Nowadays, this is fully handled via the VMA
(VM_IO | VM_PFNMAP | VM_DONTEXPAND | VM_DONTDUMP inside remap_pfn_range()
to be precise). PG_reserved is no longer required but only a relict from
the past.

So only architecture specific MM handling might require it (e.g. to
detect them as MMIO pages). As there are no architecture specific checks
for PageReserved() apart from MCA handling in ia64code, this can go. Use
simple vzalloc()/vfree() instead.

Note that before calling vzalloc(), size has already been aligned to
PAGE_SIZE, no need to align again.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@redhat.com>
Cc: David Howells <dhowells@redhat.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/ia64/kernel/perfmon.c | 59 +++-----------------------------------
 1 file changed, 4 insertions(+), 55 deletions(-)

diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index a9d4dc6c0427..e1b9287dc455 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -583,17 +583,6 @@ pfm_put_task(struct task_struct *task)
 	if (task != current) put_task_struct(task);
 }
 
-static inline void
-pfm_reserve_page(unsigned long a)
-{
-	SetPageReserved(vmalloc_to_page((void *)a));
-}
-static inline void
-pfm_unreserve_page(unsigned long a)
-{
-	ClearPageReserved(vmalloc_to_page((void*)a));
-}
-
 static inline unsigned long
 pfm_protect_ctx_ctxsw(pfm_context_t *x)
 {
@@ -817,44 +806,6 @@ pfm_reset_msgq(pfm_context_t *ctx)
 	DPRINT(("ctx=%p msgq reset\n", ctx));
 }
 
-static void *
-pfm_rvmalloc(unsigned long size)
-{
-	void *mem;
-	unsigned long addr;
-
-	size = PAGE_ALIGN(size);
-	mem  = vzalloc(size);
-	if (mem) {
-		//printk("perfmon: CPU%d pfm_rvmalloc(%ld)=%p\n", smp_processor_id(), size, mem);
-		addr = (unsigned long)mem;
-		while (size > 0) {
-			pfm_reserve_page(addr);
-			addr+=PAGE_SIZE;
-			size-=PAGE_SIZE;
-		}
-	}
-	return mem;
-}
-
-static void
-pfm_rvfree(void *mem, unsigned long size)
-{
-	unsigned long addr;
-
-	if (mem) {
-		DPRINT(("freeing physical buffer @%p size=%lu\n", mem, size));
-		addr = (unsigned long) mem;
-		while ((long) size > 0) {
-			pfm_unreserve_page(addr);
-			addr+=PAGE_SIZE;
-			size-=PAGE_SIZE;
-		}
-		vfree(mem);
-	}
-	return;
-}
-
 static pfm_context_t *
 pfm_context_alloc(int ctx_flags)
 {
@@ -1499,7 +1450,7 @@ pfm_free_smpl_buffer(pfm_context_t *ctx)
 	/*
 	 * free the buffer
 	 */
-	pfm_rvfree(ctx->ctx_smpl_hdr, ctx->ctx_smpl_size);
+	vfree(ctx->ctx_smpl_hdr);
 
 	ctx->ctx_smpl_hdr  = NULL;
 	ctx->ctx_smpl_size = 0UL;
@@ -2138,7 +2089,7 @@ pfm_close(struct inode *inode, struct file *filp)
 	 * All memory free operations (especially for vmalloc'ed memory)
 	 * MUST be done with interrupts ENABLED.
 	 */
-	if (smpl_buf_addr)  pfm_rvfree(smpl_buf_addr, smpl_buf_size);
+	vfree(smpl_buf_addr);
 
 	/*
 	 * return the memory used by the context
@@ -2267,10 +2218,8 @@ pfm_smpl_buffer_alloc(struct task_struct *task, struct file *filp, pfm_context_t
 
 	/*
 	 * We do the easy to undo allocations first.
- 	 *
-	 * pfm_rvmalloc(), clears the buffer, so there is no leak
 	 */
-	smpl_buf = pfm_rvmalloc(size);
+	smpl_buf = vzalloc(size);
 	if (smpl_buf == NULL) {
 		DPRINT(("Can't allocate sampling buffer\n"));
 		return -ENOMEM;
@@ -2347,7 +2296,7 @@ pfm_smpl_buffer_alloc(struct task_struct *task, struct file *filp, pfm_context_t
 error:
 	vm_area_free(vma);
 error_kmem:
-	pfm_rvfree(smpl_buf, size);
+	vfree(smpl_buf);
 
 	return -ENOMEM;
 }
-- 
2.17.2
