Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4949F6B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 23:05:24 -0400 (EDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 4/4] percpu: rename pcpu_mem_alloc to pcpu_mem_zalloc
Date: Thu, 4 Aug 2011 11:09:50 +0800
Message-ID: <1312427390-20005-4-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1312427390-20005-3-git-send-email-lliubbo@gmail.com>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
 <1312427390-20005-2-git-send-email-lliubbo@gmail.com>
 <1312427390-20005-3-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, namhyung@gmail.com, hannes@cmpxchg.org, mhocko@suse.cz, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com, dan.magenheimer@oracle.com, Bob Liu <lliubbo@gmail.com>

Currently pcpu_mem_alloc() is implemented always return zeroed memory.
So rename it to make user like pcpu_get_pages_and_bitmap() know don't reinit it.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/percpu-vm.c |    5 ++---
 mm/percpu.c    |   17 +++++++++--------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
index ea53496..29e3730 100644
--- a/mm/percpu-vm.c
+++ b/mm/percpu-vm.c
@@ -50,14 +50,13 @@ static struct page **pcpu_get_pages_and_bitmap(struct pcpu_chunk *chunk,
 
 	if (!pages || !bitmap) {
 		if (may_alloc && !pages)
-			pages = pcpu_mem_alloc(pages_size);
+			pages = pcpu_mem_zalloc(pages_size);
 		if (may_alloc && !bitmap)
-			bitmap = pcpu_mem_alloc(bitmap_size);
+			bitmap = pcpu_mem_zalloc(bitmap_size);
 		if (!pages || !bitmap)
 			return NULL;
 	}
 
-	memset(pages, 0, pages_size);
 	bitmap_copy(bitmap, chunk->populated, pcpu_unit_pages);
 
 	*bitmapp = bitmap;
diff --git a/mm/percpu.c b/mm/percpu.c
index bf80e55..28c37a2 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -273,11 +273,11 @@ static void __maybe_unused pcpu_next_pop(struct pcpu_chunk *chunk,
 	     (rs) = (re) + 1, pcpu_next_pop((chunk), &(rs), &(re), (end)))
 
 /**
- * pcpu_mem_alloc - allocate memory
+ * pcpu_mem_zalloc - allocate memory
  * @size: bytes to allocate
  *
  * Allocate @size bytes.  If @size is smaller than PAGE_SIZE,
- * kzalloc() is used; otherwise, vmalloc() is used.  The returned
+ * kzalloc() is used; otherwise, vzalloc() is used.  The returned
  * memory is always zeroed.
  *
  * CONTEXT:
@@ -286,7 +286,7 @@ static void __maybe_unused pcpu_next_pop(struct pcpu_chunk *chunk,
  * RETURNS:
  * Pointer to the allocated area on success, NULL on failure.
  */
-static void *pcpu_mem_alloc(size_t size)
+static void *pcpu_mem_zalloc(size_t size)
 {
 	if (WARN_ON_ONCE(!slab_is_available()))
 		return NULL;
@@ -302,7 +302,7 @@ static void *pcpu_mem_alloc(size_t size)
  * @ptr: memory to free
  * @size: size of the area
  *
- * Free @ptr.  @ptr should have been allocated using pcpu_mem_alloc().
+ * Free @ptr.  @ptr should have been allocated using pcpu_mem_zalloc().
  */
 static void pcpu_mem_free(void *ptr, size_t size)
 {
@@ -384,7 +384,7 @@ static int pcpu_extend_area_map(struct pcpu_chunk *chunk, int new_alloc)
 	size_t old_size = 0, new_size = new_alloc * sizeof(new[0]);
 	unsigned long flags;
 
-	new = pcpu_mem_alloc(new_size);
+	new = pcpu_mem_zalloc(new_size);
 	if (!new)
 		return -ENOMEM;
 
@@ -604,11 +604,12 @@ static struct pcpu_chunk *pcpu_alloc_chunk(void)
 {
 	struct pcpu_chunk *chunk;
 
-	chunk = pcpu_mem_alloc(pcpu_chunk_struct_size);
+	chunk = pcpu_mem_zalloc(pcpu_chunk_struct_size);
 	if (!chunk)
 		return NULL;
 
-	chunk->map = pcpu_mem_alloc(PCPU_DFL_MAP_ALLOC * sizeof(chunk->map[0]));
+	chunk->map = pcpu_mem_zalloc(PCPU_DFL_MAP_ALLOC *
+						sizeof(chunk->map[0]));
 	if (!chunk->map) {
 		kfree(chunk);
 		return NULL;
@@ -1889,7 +1890,7 @@ void __init percpu_init_late(void)
 
 		BUILD_BUG_ON(size > PAGE_SIZE);
 
-		map = pcpu_mem_alloc(size);
+		map = pcpu_mem_zalloc(size);
 		BUG_ON(!map);
 
 		spin_lock_irqsave(&pcpu_lock, flags);
-- 
1.6.3.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
