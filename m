Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        id j5E0oMLF014467 for <linux-mm@kvack.org>; Tue, 14 Jun 2005 09:50:22 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp by m4.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id j5E0oLIx024482 for <linux-mm@kvack.org>; Tue, 14 Jun 2005 09:50:22 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s2.gw.fujitsu.co.jp (s2 [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DFF164E0067
	for <linux-mm@kvack.org>; Tue, 14 Jun 2005 09:50:21 +0900 (JST)
Received: from fjm505.ms.jp.fujitsu.com (fjm505.ms.jp.fujitsu.com [10.56.99.83])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C52C4E0066
	for <linux-mm@kvack.org>; Tue, 14 Jun 2005 09:50:21 +0900 (JST)
Received: from [127.0.0.1] (fjmscan503.ms.jp.fujitsu.com [10.56.99.143])by fjm505.ms.jp.fujitsu.com with ESMTP id j5E0oE9R010014
	for <linux-mm@kvack.org>; Tue, 14 Jun 2005 09:50:16 +0900
Message-ID: <42AE2B37.9050802@jp.fujitsu.com>
Date: Tue, 14 Jun 2005 09:56:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [Lhms-devel] [RFC] page based page release handler
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

  Attached one is a sample implementation of page-based release handler.
I wrote this with intention of enhancing memory-hotplug.
This is only a RFC and I wants some comments.

  When a page is isolated, it is out of the kernel memory management.
Here ,*isolated page* means
   (a)a page is allocated and never freed intentionally
   (b)a page is set PG_reserved and out of control.
   (c)a page is allocated and has no release routine.
This is enough now, and it just leaks from the kernel.

When the kernel wants to remove/move an above page, I think, the kernel has
3 ways.
(1) try to call all subsystem's release handler, one by one
     (the kernel doesn't know its owner)
(2) call the release handler attached to the page.
(3) give up ;(

This patch is the base of (2) and registers page release handler
into pfn indexed radix-tree. Radix trees are separated into zones.
I think (1) can be more complicated than (2).

If someone has an idea, plz reply.

Regards,
-- Kame

--

<<Introduction>>
In some subsystem, a page is sometimes isolated from the kernel.

*isolated* means
1. pages are allocated and never freed
2. pages are set PG_reserved and removed from the kernel's page allocator.
3. subsystem has no page release routine which can be called by
    the kernel's memory management system.

Now, the kernel's page allocator has no concerns for isolated pages
and they are just leaked. This works enough.

Considering memory-hotplug, leaked pages cannot be removed at hot-remove.
To remove all these pages, memory hot-remove has to call
all subsystem's memory release handler, which are not implemented now.

In this patch, new interface page_set_hold()/page_release() are implemented.

- page_set_hold() registers a page release handler for the page.
- page_release()  calls per-page page release hander.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---

  linux-2.6.12-rc6-kamezawa/include/linux/mm.h     |   42 ++++++++++++
  linux-2.6.12-rc6-kamezawa/include/linux/mmzone.h |    5 +
  linux-2.6.12-rc6-kamezawa/mm/page_alloc.c        |   79 +++++++++++++++++++++++
  3 files changed, 126 insertions(+)

diff -puN include/linux/mmzone.h~page_hold include/linux/mmzone.h
--- linux-2.6.12-rc6/include/linux/mmzone.h~page_hold	2005-06-10 15:54:06.000000000 +0900
+++ linux-2.6.12-rc6-kamezawa/include/linux/mmzone.h	2005-06-13 15:43:07.000000000 +0900
@@ -13,6 +13,7 @@
  #include <linux/numa.h>
  #include <linux/init.h>
  #include <asm/atomic.h>
+#include <linux/radix-tree.h>

  /* Free memory management - zoned buddy allocator.  */
  #ifndef CONFIG_FORCE_MAX_ZONEORDER
@@ -206,6 +207,10 @@ struct zone {
  	unsigned long		spanned_pages;	/* total size, including holes */
  	unsigned long		present_pages;	/* amount of memory (excluding holes) */

+	/* used for page_set_hold(). */
+	rwlock_t		page_holder_lock;
+	struct radix_tree_root  page_holder;
+
  	/*
  	 * rarely used fields:
  	 */
diff -puN include/linux/mm.h~page_hold include/linux/mm.h
--- linux-2.6.12-rc6/include/linux/mm.h~page_hold	2005-06-10 16:15:13.000000000 +0900
+++ linux-2.6.12-rc6-kamezawa/include/linux/mm.h	2005-06-13 16:20:55.000000000 +0900
@@ -654,6 +654,48 @@ struct shrinker;
  extern struct shrinker *set_shrinker(int, shrinker_t);
  extern void remove_shrinker(struct shrinker *shrinker);

+
+
+/*
+ * Followings pages cannot be freed by the kernel memory controller,
+ * page allocator/kswapd etc..
+ *
+ * 1. allocate a page and never free.
+ * 2. set PG_reserved (if it's mapped by processes)
+ * 3. a page held by a subsystem which has no interface for page shirinking/release.
+ *
+ * page_set_hold()/release_page() are generic interface for registering page-release-handler.
+ * With this interface, all subsystems can implement its own
+ * page-relsease-handler and page-type-recognition in a generic way.
+ *
+ * Note: Because major subsystems (filesystems etc...) have its own handler/information in
+ *       the page struct, they will not need this.
+ *       this interface doesn't support stack of handlers for a page.
+ */
+
+struct page_holder_ops {
+        char    *name;
+        int     (*release)(struct page *);
+};
+extern int page_set_hold(struct page *page, struct page_holder_ops *ops, int overwrite);
+extern void page_unset_hold(struct page *page);
+extern int page_release(struct page *page);
+extern struct page_holder_ops *__is_page_held(struct page *page);
+
+static inline int is_page_held(struct page *page)
+{
+	return (__is_page_held(page))? 1 : 0;
+}
+
+static inline char *page_owner(struct page *page)
+{
+	struct page_holder_ops *ops;
+	ops = __is_page_held(page);
+	if (!ops)
+		return NULL;
+	return ops->name;
+}
+
  /*
   * On a two-level or three-level page table, this ends up being trivial. Thus
   * the inlining and the symmetry break with pte_alloc_map() that does all
diff -puN mm/page_alloc.c~page_hold mm/page_alloc.c
--- linux-2.6.12-rc6/mm/page_alloc.c~page_hold	2005-06-10 18:26:25.000000000 +0900
+++ linux-2.6.12-rc6-kamezawa/mm/page_alloc.c	2005-06-13 16:30:02.000000000 +0900
@@ -1739,6 +1739,8 @@ static void __init free_area_init_core(s
  			printk(KERN_CRIT "BUG: wrong zone alignment, it will crash\n");

  		memmap_init(size, nid, j, zone_start_pfn);
+		rwlock_init(&zone->page_holder_lock);
+		INIT_RADIX_TREE(&zone->page_holder, GFP_KERNEL);

  		zone_start_pfn += size;

@@ -2236,3 +2238,80 @@ void *__init alloc_large_system_hash(con

  	return table;
  }
+
+/*
+ * page_hold()/page_release()
+ * informations is managed by radix-tree per zone.
+ */
+static struct page_holder_ops * __lookup_page_holder(struct zone *zone, unsigned long pfn)
+{
+	struct page_holder_ops *op;
+	read_lock_irq(&zone->page_holder_lock);
+	op = radix_tree_lookup(&zone->page_holder, pfn);
+	read_unlock_irq(&zone->page_holder_lock);
+	return op;
+}
+
+static int add_to_page_holder(struct zone *zone, unsigned long pfn, struct page_holder_ops *ops)
+{
+	int error;
+	error = radix_tree_preload(GFP_KERNEL);
+	if (!error) {
+		write_lock_irq(&zone->page_holder_lock);
+		error = radix_tree_insert(&zone->page_holder, pfn, ops);
+		write_unlock_irq(&zone->page_holder_lock);
+		radix_tree_preload_end();
+	}
+	return error;
+}
+
+static int remove_from_page_holder(struct zone *zone, unsigned long pfn)
+{
+	struct page_holder_ops *ops;
+	write_lock_irq(&zone->page_holder_lock);
+	ops = radix_tree_delete(&zone->page_holder, pfn);
+	write_unlock_irq(&zone->page_holder_lock);
+	return (ops)? 1 : 0;
+}
+
+int page_set_hold(struct page *page, struct page_holder_ops *ops, int overwrite)
+{
+	struct zone *zone;
+	struct page_holder_ops *tmp;
+	unsigned long pfn = page_to_pfn(page);
+	int error;
+	zone = page_zone(page);
+	tmp = __lookup_page_holder(zone, pfn);
+	if (!overwrite && tmp) {
+		printk("page_hold_handler is overwritten [%s] %lx\n",ops->name, pfn);
+		return 1;
+	}
+	error = add_to_page_holder(zone, pfn, ops);
+	return error;
+}
+
+void page_unset_hold(struct page *page)
+{
+	return remove_from_page_holder(page_zone(page), page_to_pfn(page));
+}
+
+struct page_holder_ops *__is_page_held(struct page *page) {
+	return  __lookup_page_holder(page_zone(page), page_to_pfn(page));
+}
+
+int page_release(struct page *page)
+{
+	int error;
+	struct page_holder_ops *ops;
+	struct zone *zone = page_zone(page);
+	unsigned long pfn = page_to_pfn(page);
+
+	ops = __lookup_page_holder(zone, pfn);
+	if ((!ops) || (!ops->release)) /* this page has no page_release_hander */
+		return 1;
+	error = (*ops->release)(page);
+	if (error)
+		return error;
+	remove_from_page_holder(zone, pfn);
+	return 0;
+}

_




-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
Lhms-devel mailing list
Lhms-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/lhms-devel


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
