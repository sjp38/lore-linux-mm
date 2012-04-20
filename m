Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 00C056B00E8
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 17:49:21 -0400 (EDT)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 6/6] frontswap: s/put_page/store/g s/get_page/load
Date: Fri, 20 Apr 2012 17:44:15 -0400
Message-Id: <1334958255-6612-7-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1334958255-6612-1-git-send-email-konrad.wilk@oracle.com>
References: <1334958255-6612-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, ngupta@vflare.org, sjenning@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com, aarcange@redhat.com, dhowells@redhat.com, riel@redhat.com, JBeulich@novell.com
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Sounds so much more natural.

Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 Documentation/vm/frontswap.txt        |   50 ++++++++++++++--------------
 drivers/staging/ramster/zcache-main.c |    8 ++--
 drivers/staging/zcache/zcache-main.c  |   10 +++---
 drivers/xen/tmem.c                    |    8 ++--
 include/linux/frontswap.h             |   16 +++++-----
 mm/frontswap.c                        |   56 ++++++++++++++++----------------
 mm/page_io.c                          |    4 +-
 7 files changed, 76 insertions(+), 76 deletions(-)

diff --git a/Documentation/vm/frontswap.txt b/Documentation/vm/frontswap.txt
index a9f731a..37067cf 100644
--- a/Documentation/vm/frontswap.txt
+++ b/Documentation/vm/frontswap.txt
@@ -21,21 +21,21 @@ frontswap_ops funcs appropriately and the functions it provides must
 conform to certain policies as follows:
 
 An "init" prepares the device to receive frontswap pages associated
-with the specified swap device number (aka "type").  A "put_page" will
+with the specified swap device number (aka "type").  A "store" will
 copy the page to transcendent memory and associate it with the type and
-offset associated with the page. A "get_page" will copy the page, if found,
+offset associated with the page. A "load" will copy the page, if found,
 from transcendent memory into kernel memory, but will NOT remove the page
 from from transcendent memory.  An "invalidate_page" will remove the page
 from transcendent memory and an "invalidate_area" will remove ALL pages
 associated with the swap type (e.g., like swapoff) and notify the "device"
-to refuse further puts with that swap type.
+to refuse further stores with that swap type.
 
-Once a page is successfully put, a matching get on the page will normally
+Once a page is successfully stored, a matching load on the page will normally
 succeed.  So when the kernel finds itself in a situation where it needs
-to swap out a page, it first attempts to use frontswap.  If the put returns
+to swap out a page, it first attempts to use frontswap.  If the store returns
 success, the data has been successfully saved to transcendent memory and
 a disk write and, if the data is later read back, a disk read are avoided.
-If a put returns failure, transcendent memory has rejected the data, and the
+If a store returns failure, transcendent memory has rejected the data, and the
 page can be written to swap as usual.
 
 If a backend chooses, frontswap can be configured as a "writethrough
@@ -44,18 +44,18 @@ in swap device writes is lost (and also a non-trivial performance advantage)
 in order to allow the backend to arbitrarily "reclaim" space used to
 store frontswap pages to more completely manage its memory usage.
 
-Note that if a page is put and the page already exists in transcendent memory
-(a "duplicate" put), either the put succeeds and the data is overwritten,
-or the put fails AND the page is invalidated.  This ensures stale data may
+Note that if a page is stored and the page already exists in transcendent memory
+(a "duplicate" store), either the store succeeds and the data is overwritten,
+or the store fails AND the page is invalidated.  This ensures stale data may
 never be obtained from frontswap.
 
 If properly configured, monitoring of frontswap is done via debugfs in
 the /sys/kernel/debug/frontswap directory.  The effectiveness of
 frontswap can be measured (across all swap devices) with:
 
-failed_puts	- how many put attempts have failed
-gets		- how many gets were attempted (all should succeed)
-succ_puts	- how many put attempts have succeeded
+failed_stores	- how many store attempts have failed
+loads		- how many loads were attempted (all should succeed)
+succ_stores	- how many store attempts have succeeded
 invalidates	- how many invalidates were attempted
 
 A backend implementation may provide additional metrics.
@@ -125,7 +125,7 @@ nothingness and the only overhead is a few extra bytes per swapon'ed
 swap device.  If CONFIG_FRONTSWAP is enabled but no frontswap "backend"
 registers, there is one extra global variable compared to zero for
 every swap page read or written.  If CONFIG_FRONTSWAP is enabled
-AND a frontswap backend registers AND the backend fails every "put"
+AND a frontswap backend registers AND the backend fails every "store"
 request (i.e. provides no memory despite claiming it might),
 CPU overhead is still negligible -- and since every frontswap fail
 precedes a swap page write-to-disk, the system is highly likely
@@ -159,13 +159,13 @@ entirely dynamic and random.
 
 Whenever a swap-device is swapon'd frontswap_init() is called,
 passing the swap device number (aka "type") as a parameter.
-This notifies frontswap to expect attempts to "put" swap pages
+This notifies frontswap to expect attempts to "store" swap pages
 associated with that number.
 
 Whenever the swap subsystem is readying a page to write to a swap
-device (c.f swap_writepage()), frontswap_put_page is called.  Frontswap
+device (c.f swap_writepage()), frontswap_store is called.  Frontswap
 consults with the frontswap backend and if the backend says it does NOT
-have room, frontswap_put_page returns -1 and the kernel swaps the page
+have room, frontswap_store returns -1 and the kernel swaps the page
 to the swap device as normal.  Note that the response from the frontswap
 backend is unpredictable to the kernel; it may choose to never accept a
 page, it could accept every ninth page, or it might accept every
@@ -177,7 +177,7 @@ corresponding to the page offset on the swap device to which it would
 otherwise have written the data.
 
 When the swap subsystem needs to swap-in a page (swap_readpage()),
-it first calls frontswap_get_page() which checks the frontswap_map to
+it first calls frontswap_load() which checks the frontswap_map to
 see if the page was earlier accepted by the frontswap backend.  If
 it was, the page of data is filled from the frontswap backend and
 the swap-in is complete.  If not, the normal swap-in code is
@@ -185,7 +185,7 @@ executed to obtain the page of data from the real swap device.
 
 So every time the frontswap backend accepts a page, a swap device read
 and (potentially) a swap device write are replaced by a "frontswap backend
-put" and (possibly) a "frontswap backend get", which are presumably much
+store" and (possibly) a "frontswap backend loads", which are presumably much
 faster.
 
 4) Can't frontswap be configured as a "special" swap device that is
@@ -215,8 +215,8 @@ that are inappropriate for a RAM-oriented device including delaying
 the write of some pages for a significant amount of time.  Synchrony is
 required to ensure the dynamicity of the backend and to avoid thorny race
 conditions that would unnecessarily and greatly complicate frontswap
-and/or the block I/O subsystem.  That said, only the initial "put"
-and "get" operations need be synchronous.  A separate asynchronous thread
+and/or the block I/O subsystem.  That said, only the initial "store"
+and "load" operations need be synchronous.  A separate asynchronous thread
 is free to manipulate the pages stored by frontswap.  For example,
 the "remotification" thread in RAMster uses standard asynchronous
 kernel sockets to move compressed frontswap pages to a remote machine.
@@ -229,7 +229,7 @@ choose to accept pages only until host-swapping might be imminent,
 then force guests to do their own swapping.
 
 There is a downside to the transcendent memory specifications for
-frontswap:  Since any "put" might fail, there must always be a real
+frontswap:  Since any "store" might fail, there must always be a real
 slot on a real swap device to swap the page.  Thus frontswap must be
 implemented as a "shadow" to every swapon'd device with the potential
 capability of holding every page that the swap device might have held
@@ -240,16 +240,16 @@ installation, frontswap is useless.  Swapless portable devices
 can still use frontswap but a backend for such devices must configure
 some kind of "ghost" swap device and ensure that it is never used.
 
-5) Why this weird definition about "duplicate puts"?  If a page
-   has been previously successfully put, can't it always be
+5) Why this weird definition about "duplicate stores"?  If a page
+   has been previously successfully stored, can't it always be
    successfully overwritten?
 
 Nearly always it can, but no, sometimes it cannot.  Consider an example
 where data is compressed and the original 4K page has been compressed
 to 1K.  Now an attempt is made to overwrite the page with data that
 is non-compressible and so would take the entire 4K.  But the backend
-has no more space.  In this case, the put must be rejected.  Whenever
-frontswap rejects a put that would overwrite, it also must invalidate
+has no more space.  In this case, the store must be rejected.  Whenever
+frontswap rejects a store that would overwrite, it also must invalidate
 the old data and ensure that it is no longer accessible.  Since the
 swap subsystem then writes the new data to the read swap device,
 this is the correct course of action to ensure coherency.
diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
index 68b2e05..2627b3d 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -3002,7 +3002,7 @@ static inline struct tmem_oid oswiz(unsigned type, u32 ind)
 	return oid;
 }
 
-static int zcache_frontswap_put_page(unsigned type, pgoff_t offset,
+static int zcache_frontswap_store(unsigned type, pgoff_t offset,
 				   struct page *page)
 {
 	u64 ind64 = (u64)offset;
@@ -3025,7 +3025,7 @@ static int zcache_frontswap_put_page(unsigned type, pgoff_t offset,
 
 /* returns 0 if the page was successfully gotten from frontswap, -1 if
  * was not present (should never happen!) */
-static int zcache_frontswap_get_page(unsigned type, pgoff_t offset,
+static int zcache_frontswap_load(unsigned type, pgoff_t offset,
 				   struct page *page)
 {
 	u64 ind64 = (u64)offset;
@@ -3080,8 +3080,8 @@ static void zcache_frontswap_init(unsigned ignored)
 }
 
 static struct frontswap_ops zcache_frontswap_ops = {
-	.put_page = zcache_frontswap_put_page,
-	.get_page = zcache_frontswap_get_page,
+	.store = zcache_frontswap_store,
+	.load = zcache_frontswap_load,
 	.invalidate_page = zcache_frontswap_flush_page,
 	.invalidate_area = zcache_frontswap_flush_area,
 	.init = zcache_frontswap_init
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 2734dac..784c796 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -1835,7 +1835,7 @@ static int zcache_frontswap_poolid = -1;
  * Swizzling increases objects per swaptype, increasing tmem concurrency
  * for heavy swaploads.  Later, larger nr_cpus -> larger SWIZ_BITS
  * Setting SWIZ_BITS to 27 basically reconstructs the swap entry from
- * frontswap_get_page(), but has side-effects. Hence using 8.
+ * frontswap_load(), but has side-effects. Hence using 8.
  */
 #define SWIZ_BITS		8
 #define SWIZ_MASK		((1 << SWIZ_BITS) - 1)
@@ -1849,7 +1849,7 @@ static inline struct tmem_oid oswiz(unsigned type, u32 ind)
 	return oid;
 }
 
-static int zcache_frontswap_put_page(unsigned type, pgoff_t offset,
+static int zcache_frontswap_store(unsigned type, pgoff_t offset,
 				   struct page *page)
 {
 	u64 ind64 = (u64)offset;
@@ -1870,7 +1870,7 @@ static int zcache_frontswap_put_page(unsigned type, pgoff_t offset,
 
 /* returns 0 if the page was successfully gotten from frontswap, -1 if
  * was not present (should never happen!) */
-static int zcache_frontswap_get_page(unsigned type, pgoff_t offset,
+static int zcache_frontswap_load(unsigned type, pgoff_t offset,
 				   struct page *page)
 {
 	u64 ind64 = (u64)offset;
@@ -1919,8 +1919,8 @@ static void zcache_frontswap_init(unsigned ignored)
 }
 
 static struct frontswap_ops zcache_frontswap_ops = {
-	.put_page = zcache_frontswap_put_page,
-	.get_page = zcache_frontswap_get_page,
+	.store = zcache_frontswap_store,
+	.load = zcache_frontswap_load,
 	.invalidate_page = zcache_frontswap_flush_page,
 	.invalidate_area = zcache_frontswap_flush_area,
 	.init = zcache_frontswap_init
diff --git a/drivers/xen/tmem.c b/drivers/xen/tmem.c
index dcb7952..89f264c 100644
--- a/drivers/xen/tmem.c
+++ b/drivers/xen/tmem.c
@@ -269,7 +269,7 @@ static inline struct tmem_oid oswiz(unsigned type, u32 ind)
 }
 
 /* returns 0 if the page was successfully put into frontswap, -1 if not */
-static int tmem_frontswap_put_page(unsigned type, pgoff_t offset,
+static int tmem_frontswap_store(unsigned type, pgoff_t offset,
 				   struct page *page)
 {
 	u64 ind64 = (u64)offset;
@@ -295,7 +295,7 @@ static int tmem_frontswap_put_page(unsigned type, pgoff_t offset,
  * returns 0 if the page was successfully gotten from frontswap, -1 if
  * was not present (should never happen!)
  */
-static int tmem_frontswap_get_page(unsigned type, pgoff_t offset,
+static int tmem_frontswap_load(unsigned type, pgoff_t offset,
 				   struct page *page)
 {
 	u64 ind64 = (u64)offset;
@@ -362,8 +362,8 @@ static int __init no_frontswap(char *s)
 __setup("nofrontswap", no_frontswap);
 
 static struct frontswap_ops __initdata tmem_frontswap_ops = {
-	.put_page = tmem_frontswap_put_page,
-	.get_page = tmem_frontswap_get_page,
+	.store = tmem_frontswap_store,
+	.load = tmem_frontswap_load,
 	.invalidate_page = tmem_frontswap_flush_page,
 	.invalidate_area = tmem_frontswap_flush_area,
 	.init = tmem_frontswap_init
diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
index 68ff7af..0e4e2ee 100644
--- a/include/linux/frontswap.h
+++ b/include/linux/frontswap.h
@@ -7,8 +7,8 @@
 
 struct frontswap_ops {
 	void (*init)(unsigned);
-	int (*put_page)(unsigned, pgoff_t, struct page *);
-	int (*get_page)(unsigned, pgoff_t, struct page *);
+	int (*store)(unsigned, pgoff_t, struct page *);
+	int (*load)(unsigned, pgoff_t, struct page *);
 	void (*invalidate_page)(unsigned, pgoff_t);
 	void (*invalidate_area)(unsigned);
 };
@@ -21,8 +21,8 @@ extern unsigned long frontswap_curr_pages(void);
 extern void frontswap_writethrough(bool);
 
 extern void __frontswap_init(unsigned type);
-extern int __frontswap_put_page(struct page *page);
-extern int __frontswap_get_page(struct page *page);
+extern int __frontswap_store(struct page *page);
+extern int __frontswap_load(struct page *page);
 extern void __frontswap_invalidate_page(unsigned, pgoff_t);
 extern void __frontswap_invalidate_area(unsigned);
 
@@ -88,21 +88,21 @@ static inline unsigned long *frontswap_map_get(struct swap_info_struct *p)
 }
 #endif
 
-static inline int frontswap_put_page(struct page *page)
+static inline int frontswap_store(struct page *page)
 {
 	int ret = -1;
 
 	if (frontswap_enabled)
-		ret = __frontswap_put_page(page);
+		ret = __frontswap_store(page);
 	return ret;
 }
 
-static inline int frontswap_get_page(struct page *page)
+static inline int frontswap_load(struct page *page)
 {
 	int ret = -1;
 
 	if (frontswap_enabled)
-		ret = __frontswap_get_page(page);
+		ret = __frontswap_load(page);
 	return ret;
 }
 
diff --git a/mm/frontswap.c b/mm/frontswap.c
index 8c0a5f8..e250255 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -39,7 +39,7 @@ bool frontswap_enabled __read_mostly;
 EXPORT_SYMBOL(frontswap_enabled);
 
 /*
- * If enabled, frontswap_put will return failure even on success.  As
+ * If enabled, frontswap_store will return failure even on success.  As
  * a result, the swap subsystem will always write the page to swap, in
  * effect converting frontswap into a writethrough cache.  In this mode,
  * there is no direct reduction in swap writes, but a frontswap backend
@@ -54,27 +54,27 @@ static bool frontswap_writethrough_enabled __read_mostly;
  * properly configured).  These are for information only so are not protected
  * against increment races.
  */
-static u64 frontswap_gets;
-static u64 frontswap_succ_puts;
-static u64 frontswap_failed_puts;
+static u64 frontswap_loads;
+static u64 frontswap_succ_stores;
+static u64 frontswap_failed_stores;
 static u64 frontswap_invalidates;
 
-static inline void inc_frontswap_gets(void) {
-	frontswap_gets++;
+static inline void inc_frontswap_loads(void) {
+	frontswap_loads++;
 }
-static inline void inc_frontswap_succ_puts(void) {
-	frontswap_succ_puts++;
+static inline void inc_frontswap_succ_stores(void) {
+	frontswap_succ_stores++;
 }
-static inline void inc_frontswap_failed_puts(void) {
-	frontswap_failed_puts++;
+static inline void inc_frontswap_failed_stores(void) {
+	frontswap_failed_stores++;
 }
 static inline void inc_frontswap_invalidates(void) {
 	frontswap_invalidates++;
 }
 #else
-static inline void inc_frontswap_gets(void) { }
-static inline void inc_frontswap_succ_puts(void) { }
-static inline void inc_frontswap_failed_puts(void) { }
+static inline void inc_frontswap_loads(void) { }
+static inline void inc_frontswap_succ_stores(void) { }
+static inline void inc_frontswap_failed_stores(void) { }
 static inline void inc_frontswap_invalidates(void) { }
 #endif
 /*
@@ -116,13 +116,13 @@ void __frontswap_init(unsigned type)
 EXPORT_SYMBOL(__frontswap_init);
 
 /*
- * "Put" data from a page to frontswap and associate it with the page's
+ * "Store" data from a page to frontswap and associate it with the page's
  * swaptype and offset.  Page must be locked and in the swap cache.
  * If frontswap already contains a page with matching swaptype and
  * offset, the frontswap implmentation may either overwrite the data and
  * return success or invalidate the page from frontswap and return failure.
  */
-int __frontswap_put_page(struct page *page)
+int __frontswap_store(struct page *page)
 {
 	int ret = -1, dup = 0;
 	swp_entry_t entry = { .val = page_private(page), };
@@ -134,10 +134,10 @@ int __frontswap_put_page(struct page *page)
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset))
 		dup = 1;
-	ret = (*frontswap_ops.put_page)(type, offset, page);
+	ret = (*frontswap_ops.store)(type, offset, page);
 	if (ret == 0) {
 		frontswap_set(sis, offset);
-		inc_frontswap_succ_puts();
+		inc_frontswap_succ_stores();
 		if (!dup)
 			atomic_inc(&sis->frontswap_pages);
 	} else if (dup) {
@@ -147,22 +147,22 @@ int __frontswap_put_page(struct page *page)
 		 */
 		frontswap_clear(sis, offset);
 		atomic_dec(&sis->frontswap_pages);
-		inc_frontswap_failed_puts();
+		inc_frontswap_failed_stores();
 	} else
-		inc_frontswap_failed_puts();
+		inc_frontswap_failed_stores();
 	if (frontswap_writethrough_enabled)
 		/* report failure so swap also writes to swap device */
 		ret = -1;
 	return ret;
 }
-EXPORT_SYMBOL(__frontswap_put_page);
+EXPORT_SYMBOL(__frontswap_store);
 
 /*
  * "Get" data from frontswap associated with swaptype and offset that were
  * specified when the data was put to frontswap and use it to fill the
  * specified page with data. Page must be locked and in the swap cache.
  */
-int __frontswap_get_page(struct page *page)
+int __frontswap_load(struct page *page)
 {
 	int ret = -1;
 	swp_entry_t entry = { .val = page_private(page), };
@@ -173,12 +173,12 @@ int __frontswap_get_page(struct page *page)
 	BUG_ON(!PageLocked(page));
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset))
-		ret = (*frontswap_ops.get_page)(type, offset, page);
+		ret = (*frontswap_ops.load)(type, offset, page);
 	if (ret == 0)
-		inc_frontswap_gets();
+		inc_frontswap_loads();
 	return ret;
 }
-EXPORT_SYMBOL(__frontswap_get_page);
+EXPORT_SYMBOL(__frontswap_load);
 
 /*
  * Invalidate any data from frontswap associated with the specified swaptype
@@ -301,10 +301,10 @@ static int __init init_frontswap(void)
 	struct dentry *root = debugfs_create_dir("frontswap", NULL);
 	if (root == NULL)
 		return -ENXIO;
-	debugfs_create_u64("gets", S_IRUGO, root, &frontswap_gets);
-	debugfs_create_u64("succ_puts", S_IRUGO, root, &frontswap_succ_puts);
-	debugfs_create_u64("failed_puts", S_IRUGO, root,
-				&frontswap_failed_puts);
+	debugfs_create_u64("loads", S_IRUGO, root, &frontswap_loads);
+	debugfs_create_u64("succ_stores", S_IRUGO, root, &frontswap_succ_stores);
+	debugfs_create_u64("failed_stores", S_IRUGO, root,
+				&frontswap_failed_stores);
 	debugfs_create_u64("invalidates", S_IRUGO,
 				root, &frontswap_invalidates);
 #endif
diff --git a/mm/page_io.c b/mm/page_io.c
index 651a912..34f0292 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -99,7 +99,7 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 		unlock_page(page);
 		goto out;
 	}
-	if (frontswap_put_page(page) == 0) {
+	if (frontswap_store(page) == 0) {
 		set_page_writeback(page);
 		unlock_page(page);
 		end_page_writeback(page);
@@ -129,7 +129,7 @@ int swap_readpage(struct page *page)
 
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(PageUptodate(page));
-	if (frontswap_get_page(page) == 0) {
+	if (frontswap_load(page) == 0) {
 		SetPageUptodate(page);
 		unlock_page(page);
 		goto out;
-- 
1.7.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
