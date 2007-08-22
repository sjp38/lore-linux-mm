Date: Wed, 22 Aug 2007 15:19:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Limit the maximum size of merged slab caches
Message-ID: <Pine.LNX.4.64.0708221518200.17370@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

We always switch off the debugging bits of slabs that are too large
for free pointer relocationi (256k, 512k). This means that we may create
kmem_cache structures that look as if they are satisfying the requirements
for merging even if slub_debug is set. Sysfs handling may think they are
mergeable and thus creates unique ids that may then clash.

[Patches in the works are soon going to make that limit obsolete]

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 mm/slub.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 9a57d46..fefbc6d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -209,6 +209,7 @@ static inline void ClearSlabDebug(struct page *page)
  * The page->inuse field is 16 bit thus we have this limitation
  */
 #define MAX_OBJECTS_PER_SLAB 65535
+#define MAX_MERGE_SIZE (MAX_OBJECTS_PER_SLAB * sizeof(void))
 
 /* Internal SLUB flags */
 #define __OBJECT_POISON		0x80000000 /* Poison object */
@@ -1000,7 +1001,7 @@ static void kmem_cache_open_debug_check(struct kmem_cache *s)
 	 * Debugging or ctor may create a need to move the free
 	 * pointer. Fail if this happens.
 	 */
-	if (s->objsize >= 65535 * sizeof(void *)) {
+	if (s->objsize >= MAX_MERGE_SIZE) {
 		BUG_ON(s->flags & (SLAB_RED_ZONE | SLAB_POISON |
 				SLAB_STORE_USER | SLAB_DESTROY_BY_RCU));
 		BUG_ON(s->ctor);
@@ -2656,6 +2657,12 @@ static int slab_unmergeable(struct kmem_cache *s)
 	if (s->refcount < 0)
 		return 1;
 
+	/*
+	 * Or a slab that is too large for merging
+	 */
+	if (s->size >= MAX_MERGE_SIZE)
+		return 1;
+
 	return 0;
 }
 
@@ -2675,6 +2682,9 @@ static struct kmem_cache *find_mergeable(size_t size,
 	align = calculate_alignment(flags, align, size);
 	size = ALIGN(size, align);
 
+	if (size >= MAX_MERGE_SIZE)
+		return NULL;
+
 	list_for_each_entry(s, &slab_caches, list) {
 		if (slab_unmergeable(s))
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
