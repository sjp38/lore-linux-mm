Date: Fri, 7 Mar 2008 13:35:13 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [git pull] slab allocators: Fixes and updates
Message-ID: <Pine.LNX.4.64.0803071332120.8339@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

The following changes since commit 5d49c101a126808a38f2a1f4eedc1fd28233e37f:
  Tilman Schmidt (1):
        gigaset: fix Oops on module unload regression

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git slab-linus

Christoph Lameter (2):
      slub statistics: Fix check for DEACTIVATE_REMOTE_FREES
      slab numa fallback logic: Do not pass unfiltered flags to page allocator

Itaru Kitayama (1):
      slub: fix typo in Documentation/vm/slub.txt

Joe Korty (1):
      slab: NUMA slab allocator migration bugfix

Joe Perches (1):
      slab - use angle brackets for include of kmalloc_sizes.h

Nick Piggin (1):
      slub: Do not cross cacheline boundaries for very small objects

 Documentation/vm/slub.txt |    4 ++--
 include/linux/slab_def.h  |    4 ++--
 mm/slab.c                 |    9 ++++-----
 mm/slub.c                 |   13 ++++++++-----
 4 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/Documentation/vm/slub.txt b/Documentation/vm/slub.txt
index dcf8bcf..7c13f22 100644
--- a/Documentation/vm/slub.txt
+++ b/Documentation/vm/slub.txt
@@ -50,14 +50,14 @@ F.e. in order to boot just with sanity checks and red zoning one would specify:
 
 Trying to find an issue in the dentry cache? Try
 
-	slub_debug=,dentry_cache
+	slub_debug=,dentry
 
 to only enable debugging on the dentry cache.
 
 Red zoning and tracking may realign the slab.  We can just apply sanity checks
 to the dentry cache with
 
-	slub_debug=F,dentry_cache
+	slub_debug=F,dentry
 
 In case you forgot to enable debugging on the kernel command line: It is
 possible to enable debugging manually when the kernel is up. Look at the
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index fcc4809..39c3a5e 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -41,7 +41,7 @@ static inline void *kmalloc(size_t size, gfp_t flags)
 			goto found; \
 		else \
 			i++;
-#include "kmalloc_sizes.h"
+#include <linux/kmalloc_sizes.h>
 #undef CACHE
 		{
 			extern void __you_cannot_kmalloc_that_much(void);
@@ -75,7 +75,7 @@ static inline void *kmalloc_node(size_t size, gfp_t flags, int node)
 			goto found; \
 		else \
 			i++;
-#include "kmalloc_sizes.h"
+#include <linux/kmalloc_sizes.h>
 #undef CACHE
 		{
 			extern void __you_cannot_kmalloc_that_much(void);
diff --git a/mm/slab.c b/mm/slab.c
index 473e6c2..e6c698f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -333,7 +333,7 @@ static __always_inline int index_of(const size_t size)
 		return i; \
 	else \
 		i++;
-#include "linux/kmalloc_sizes.h"
+#include <linux/kmalloc_sizes.h>
 #undef CACHE
 		__bad_size();
 	} else
@@ -2964,11 +2964,10 @@ static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags)
 	struct array_cache *ac;
 	int node;
 
-	node = numa_node_id();
-
+retry:
 	check_irq_off();
+	node = numa_node_id();
 	ac = cpu_cache_get(cachep);
-retry:
 	batchcount = ac->batchcount;
 	if (!ac->touched && batchcount > BATCHREFILL_LIMIT) {
 		/*
@@ -3280,7 +3279,7 @@ retry:
 		if (local_flags & __GFP_WAIT)
 			local_irq_enable();
 		kmem_flagcheck(cache, flags);
-		obj = kmem_getpages(cache, flags, -1);
+		obj = kmem_getpages(cache, local_flags, -1);
 		if (local_flags & __GFP_WAIT)
 			local_irq_disable();
 		if (obj) {
diff --git a/mm/slub.c b/mm/slub.c
index 0863fd3..96d63eb 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1368,7 +1368,7 @@ static void deactivate_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 	struct page *page = c->page;
 	int tail = 1;
 
-	if (c->freelist)
+	if (page->freelist)
 		stat(c, DEACTIVATE_REMOTE_FREES);
 	/*
 	 * Merge cpu freelist into slab freelist. Typically we get here
@@ -1856,12 +1856,15 @@ static unsigned long calculate_alignment(unsigned long flags,
 	 * The hardware cache alignment cannot override the specified
 	 * alignment though. If that is greater then use it.
 	 */
-	if ((flags & SLAB_HWCACHE_ALIGN) &&
-			size > cache_line_size() / 2)
-		return max_t(unsigned long, align, cache_line_size());
+	if (flags & SLAB_HWCACHE_ALIGN) {
+		unsigned long ralign = cache_line_size();
+		while (size <= ralign / 2)
+			ralign /= 2;
+		align = max(align, ralign);
+	}
 
 	if (align < ARCH_SLAB_MINALIGN)
-		return ARCH_SLAB_MINALIGN;
+		align = ARCH_SLAB_MINALIGN;
 
 	return ALIGN(align, sizeof(void *));
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
