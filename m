Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 855E26B0006
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:10:07 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id k19so2305011ita.8
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:10:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d3sor862113itf.14.2018.02.16.10.10.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Feb 2018 10:10:06 -0800 (PST)
Date: Fri, 16 Feb 2018 12:09:58 -0600
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: [PATCH v2 3/3] percpu: allow select gfp to be passed to underlying
 allocators
Message-ID: <20180216180958.GB81034@localhost>
References: <cover.1518668149.git.dennisszhou@gmail.com>
 <a166972c727e3a1235a7ad17b9df94ca407a1548.1518668149.git.dennisszhou@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a166972c727e3a1235a7ad17b9df94ca407a1548.1518668149.git.dennisszhou@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The prior patch added support for passing gfp flags through to the
underlying allocators. This patch allows users to pass along gfp flags
(currently only __GFP_NORETRY and __GFP_NOWARN) to the underlying
allocators. This should allow users to decide if they are ok with
failing allocations recovering in a more graceful way.

Additionally, gfp passing was done as additional flags in the previous
patch. Instead, change this to caller passed semantics. GFP_KERNEL is
also removed as the default flag. It continues to be used for internally
caused underlying percpu allocations.

V2:
Removed gfp_percpu_mask in favor of doing it inline.
Removed GFP_KERNEL as a default flag for __alloc_percpu_gfp.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
---
 mm/percpu-km.c |  2 +-
 mm/percpu-vm.c |  4 ++--
 mm/percpu.c    | 16 +++++++---------
 3 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/mm/percpu-km.c b/mm/percpu-km.c
index 0d88d7b..38de70a 100644
--- a/mm/percpu-km.c
+++ b/mm/percpu-km.c
@@ -56,7 +56,7 @@ static struct pcpu_chunk *pcpu_create_chunk(gfp_t gfp)
 	if (!chunk)
 		return NULL;
 
-	pages = alloc_pages(gfp | GFP_KERNEL, order_base_2(nr_pages));
+	pages = alloc_pages(gfp, order_base_2(nr_pages));
 	if (!pages) {
 		pcpu_free_chunk(chunk);
 		return NULL;
diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
index 0af71eb..d8078de 100644
--- a/mm/percpu-vm.c
+++ b/mm/percpu-vm.c
@@ -37,7 +37,7 @@ static struct page **pcpu_get_pages(void)
 	lockdep_assert_held(&pcpu_alloc_mutex);
 
 	if (!pages)
-		pages = pcpu_mem_zalloc(pages_size, 0);
+		pages = pcpu_mem_zalloc(pages_size, GFP_KERNEL);
 	return pages;
 }
 
@@ -86,7 +86,7 @@ static int pcpu_alloc_pages(struct pcpu_chunk *chunk,
 	unsigned int cpu, tcpu;
 	int i;
 
-	gfp |= GFP_KERNEL | __GFP_HIGHMEM;
+	gfp |= __GFP_HIGHMEM;
 
 	for_each_possible_cpu(cpu) {
 		for (i = page_start; i < page_end; i++) {
diff --git a/mm/percpu.c b/mm/percpu.c
index f97443d..fa3f854 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -454,9 +454,6 @@ static void pcpu_next_fit_region(struct pcpu_chunk *chunk, int alloc_bits,
  * This is to facilitate passing through whitelisted flags.  The
  * returned memory is always zeroed.
  *
- * CONTEXT:
- * Does GFP_KERNEL allocation.
- *
  * RETURNS:
  * Pointer to the allocated area on success, NULL on failure.
  */
@@ -466,10 +463,9 @@ static void *pcpu_mem_zalloc(size_t size, gfp_t gfp)
 		return NULL;
 
 	if (size <= PAGE_SIZE)
-		return kzalloc(size, gfp | GFP_KERNEL);
+		return kzalloc(size, gfp);
 	else
-		return __vmalloc(size, gfp | GFP_KERNEL | __GFP_ZERO,
-				 PAGE_KERNEL);
+		return __vmalloc(size, gfp | __GFP_ZERO, PAGE_KERNEL);
 }
 
 /**
@@ -1344,6 +1340,8 @@ static struct pcpu_chunk *pcpu_chunk_addr_search(void *addr)
 static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 				 gfp_t gfp)
 {
+	/* whitelisted flags that can be passed to the backing allocators */
+	gfp_t pcpu_gfp = gfp & (GFP_KERNEL | __GFP_NORETRY | __GFP_NOWARN);
 	bool is_atomic = (gfp & GFP_KERNEL) != GFP_KERNEL;
 	bool do_warn = !(gfp & __GFP_NOWARN);
 	static int warn_limit = 10;
@@ -1426,7 +1424,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 	}
 
 	if (list_empty(&pcpu_slot[pcpu_nr_slots - 1])) {
-		chunk = pcpu_create_chunk(0);
+		chunk = pcpu_create_chunk(pcpu_gfp);
 		if (!chunk) {
 			err = "failed to allocate new chunk";
 			goto fail;
@@ -1455,7 +1453,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 					   page_start, page_end) {
 			WARN_ON(chunk->immutable);
 
-			ret = pcpu_populate_chunk(chunk, rs, re, 0);
+			ret = pcpu_populate_chunk(chunk, rs, re, pcpu_gfp);
 
 			spin_lock_irqsave(&pcpu_lock, flags);
 			if (ret) {
@@ -1576,7 +1574,7 @@ void __percpu *__alloc_reserved_percpu(size_t size, size_t align)
 static void pcpu_balance_workfn(struct work_struct *work)
 {
 	/* gfp flags passed to underlying allocators */
-	const gfp_t gfp = __GFP_NORETRY | __GFP_NOWARN;
+	const gfp_t gfp = GFP_KERNEL | __GFP_NORETRY | __GFP_NOWARN;
 	LIST_HEAD(to_free);
 	struct list_head *free_head = &pcpu_slot[pcpu_nr_slots - 1];
 	struct pcpu_chunk *chunk, *next;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
