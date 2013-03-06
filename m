Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 2C6EB6B0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 11:36:09 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 6 Mar 2013 10:53:09 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 2E08C38C806D
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 10:52:47 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r26FqkUD260928
	for <linux-mm@kvack.org>; Wed, 6 Mar 2013 10:52:46 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r26FqkOU007919
	for <linux-mm@kvack.org>; Wed, 6 Mar 2013 10:52:46 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCHv7 8/8] zswap: add documentation
Date: Wed,  6 Mar 2013 09:52:23 -0600
Message-Id: <1362585143-6482-9-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1362585143-6482-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1362585143-6482-1-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

This patch adds the documentation file for the zswap functionality

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 Documentation/vm/zswap.txt | 82 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/zswap.c                 | 17 +++++-----
 2 files changed, 90 insertions(+), 9 deletions(-)
 create mode 100644 Documentation/vm/zswap.txt

diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
new file mode 100644
index 0000000..f29b82f
--- /dev/null
+++ b/Documentation/vm/zswap.txt
@@ -0,0 +1,82 @@
+Overview:
+
+Zswap is a lightweight compressed cache for swap pages. It takes
+pages that are in the process of being swapped out and attempts to
+compress them into a dynamically allocated RAM-based memory pool.
+If this process is successful, the writeback to the swap device is
+deferred and, in many cases, avoided completely.A  This results in
+a significant I/O reduction and performance gains for systems that
+are swapping.
+
+Zswap provides compressed swap caching that basically trades CPU cycles
+for reduced swap I/O.A  This trade-off can result in a significant
+performance improvement as reads to/writes from to the compressed
+cache almost always faster that reading from a swap device
+which incurs the latency of an asynchronous block I/O read.
+
+Some potential benefits:
+* Desktop/laptop users with limited RAM capacities can mitigate the
+A A A  performance impact of swapping.
+* Overcommitted guests that share a common I/O resource can
+A A A  dramatically reduce their swap I/O pressure, avoiding heavy
+A A A  handed I/O throttling by the hypervisor.A  This allows more work
+A A A  to get done with less impact to the guest workload and guests
+A A A  sharing the I/O subsystem
+* Users with SSDs as swap devices can extend the life of the device by
+A A A  drastically reducing life-shortening writes.
+
+Zswap evicts pages from compressed cache on an LRU basis to the backing
+swap device when the compress pool reaches it size limit or the pool is
+unable to obtain additional pages from the buddy allocator.A  This
+requirement had been identified in prior community discussions.
+
+To enabled zswap, the "enabled" attribute must be set to 1 at boot time.
+e.g. zswap.enabled=1
+
+Design:
+
+Zswap receives pages for compression through the Frontswap API and
+is able to evict pages from its own compressed pool on an LRU basis
+and write them back to the backing swap device in the case that the
+compressed pool is full or unable to secure additional pages from
+the buddy allocator.
+
+Zswap makes use of zsmalloc for the managing the compressed memory
+pool.  This is because zsmalloc is specifically designed to minimize
+fragmentation on large (> PAGE_SIZE/2) allocation sizes.  Each
+allocation in zsmalloc is not directly accessible by address.
+Rather, a handle is return by the allocation routine and that handle
+must be mapped before being accessed.  The compressed memory pool grows
+on demand and shrinks as compressed pages are freed.  The pool is
+not preallocated.
+
+When a swap page is passed from frontswap to zswap, zswap maintains
+a mapping of the swap entry, a combination of the swap type and swap
+offset, to the zsmalloc handle that references that compressed swap
+page.  This mapping is achieved with a red-black tree per swap type.
+The swap offset is the search key for the tree nodes.
+
+During a page fault on a PTE that is a swap entry, frontswap calls
+the zswap load function to decompress the page into the page
+allocated by the page fault handler.
+
+Once there are no PTEs referencing a swap page stored in zswap
+(i.e. the count in the swap_map goes to 0) the swap code calls
+the zswap invalidate function, via frontswap, to free the compressed
+entry.
+
+Zswap seeks to be simple in its policies.  Sysfs attributes allow for
+two user controlled policies:
+* max_compression_ratio - Maximum compression ratio, as as percentage,
+    for an acceptable compressed page. Any page that does not compress
+    by at least this ratio will be rejected.
+* max_pool_percent - The maximum percentage of memory that the compressed
+    pool can occupy.
+
+Zswap allows the compressor to be selected at kernel boot time by
+setting the a??compressora?? attribute.  The default compressor is lzo.
+e.g. zswap.compressor=deflate
+
+A debugfs interface is provided for various statistic about pool size,
+number of pages stored, and various counters for the reasons pages
+are rejected.
diff --git a/mm/zswap.c b/mm/zswap.c
index 9b86ad9..54996b3 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -190,7 +190,6 @@ struct zswap_entry {
 	struct rb_node rbnode;
 	struct list_head lru;
 	int refcount;
-	unsigned type;
 	pgoff_t offset;
 	unsigned long handle;
 	unsigned int length;
@@ -207,6 +206,7 @@ struct zswap_tree {
 	struct list_head lru;
 	spinlock_t lock;
 	struct zs_pool *pool;
+	unsigned type;
 };
 
 static struct zswap_tree *zswap_trees[MAX_SWAPFILES];
@@ -566,10 +566,9 @@ static int zswap_get_swap_cache_page(swp_entry_t entry,
  * the swap cache, the compressed version stored by zswap can be
  * freed.
  */
-static int zswap_writeback_entry(struct zswap_entry *entry)
+static int zswap_writeback_entry(struct zswap_tree *tree, struct zswap_entry *entry)
 {
-	unsigned long type = entry->type;
-	struct zswap_tree *tree = zswap_trees[type];
+	unsigned long type = tree->type;
 	struct page *page;
 	swp_entry_t swpentry;
 	u8 *src, *dst;
@@ -627,9 +626,8 @@ static int zswap_writeback_entry(struct zswap_entry *entry)
  * Attempts to free nr of entries via writeback to the swap device.
  * The number of entries that were actually freed is returned.
  */
-static int zswap_writeback_entries(unsigned type, int nr)
+static int zswap_writeback_entries(struct zswap_tree *tree, int nr)
 {
-	struct zswap_tree *tree = zswap_trees[type];
 	struct zswap_entry *entry;
 	int i, ret, refcount, freed_nr = 0;
 
@@ -660,7 +658,7 @@ static int zswap_writeback_entries(unsigned type, int nr)
 		spin_unlock(&tree->lock);
 
 		/* attempt writeback */
-		ret = zswap_writeback_entry(entry);
+		ret = zswap_writeback_entry(tree, entry);
 
 		spin_lock(&tree->lock);
 
@@ -829,7 +827,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 		/* try to free up some space */
 		/* TODO: replace with more targeted policy */
-		zswap_writeback_entries(type, 16);
+		zswap_writeback_entries(tree, 16);
 		/* try again, allowing wait */
 		handle = zs_malloc(tree->pool, dlen,
 			__GFP_NORETRY | __GFP_HIGHMEM | __GFP_NOMEMALLOC |
@@ -852,7 +850,6 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 		put_cpu_var(zswap_dstmem);
 
 	/* populate entry */
-	entry->type = type;
 	entry->offset = offset;
 	entry->handle = handle;
 	entry->length = dlen;
@@ -1010,6 +1007,7 @@ static void zswap_frontswap_invalidate_area(unsigned type)
 		rb_erase(&entry->rbnode, &tree->rbroot);
 		zs_free(tree->pool, entry->handle);
 		zswap_entry_cache_free(entry);
+		atomic_dec(&zswap_stored_pages);
 	}
 	tree->rbroot = RB_ROOT;
 	INIT_LIST_HEAD(&tree->lru);
@@ -1030,6 +1028,7 @@ static void zswap_frontswap_init(unsigned type)
 	tree->rbroot = RB_ROOT;
 	INIT_LIST_HEAD(&tree->lru);
 	spin_lock_init(&tree->lock);
+	tree->type = type;
 	zswap_trees[type] = tree;
 	return;
 
-- 
1.8.1.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
