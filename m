From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070410191926.8011.86159.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 4/5] Add ability to list alloc / free callers per slab
Date: Tue, 10 Apr 2007 12:19:26 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

This patch enables listing the callers who allocated or freed objects in a cache.

For example to list the allocators for kmalloc-128 do

cat /sys/slab/kmalloc-128/alloc_calls
      7 sn_io_slot_fixup+0x40/0x700
      7 sn_io_slot_fixup+0x80/0x700
      9 sn_bus_fixup+0xe0/0x380
      6 param_sysfs_setup+0xf0/0x280
    276 percpu_populate+0xf0/0x1a0
     19 __register_chrdev_region+0x30/0x360
      8 expand_files+0x2e0/0x6e0
      1 sys_epoll_create+0x60/0x200
      1 __mounts_open+0x140/0x2c0
     65 kmem_alloc+0x110/0x280
      3 alloc_disk_node+0xe0/0x200
     33 as_get_io_context+0x90/0x280
     74 kobject_kset_add_dir+0x40/0x140
     12 pci_create_bus+0x2a0/0x5c0
      1 acpi_ev_create_gpe_block+0x120/0x9e0
     41 con_insert_unipair+0x100/0x1c0
      1 uart_open+0x1c0/0xba0
      1 dma_pool_create+0xe0/0x340
      2 neigh_table_init_no_netlink+0x260/0x4c0
      6 neigh_parms_alloc+0x30/0x200
      1 netlink_kernel_create+0x130/0x320
      5 fz_hash_alloc+0x50/0xe0
      2 sn_common_hubdev_init+0xd0/0x6e0
     28 kernel_param_sysfs_setup+0x30/0x180
     72 process_zones+0x70/0x2e0

cat /sys/slab/kmalloc-128/free_calls
    558 <not-available>
      3 sn_io_slot_fixup+0x600/0x700
     84 free_fdtable_rcu+0x120/0x260
      2 seq_release+0x40/0x60
      6 kmem_free+0x70/0xc0
     24 free_as_io_context+0x20/0x200
      1 acpi_get_object_info+0x3a0/0x3e0
      1 acpi_add_single_object+0xcf0/0x1e40
      2 con_release_unimap+0x80/0x140
      1 free+0x20/0x40

SLAB_STORE_USER must be enabled for a slab cache by either booting with
"slab_debug" or enabling user tracking specifically for the slab of interest.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |  162 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 162 insertions(+)

Index: linux-2.6.21-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.21-rc6-mm1.orig/mm/slub.c	2007-04-09 22:30:11.000000000 -0700
+++ linux-2.6.21-rc6-mm1/mm/slub.c	2007-04-09 22:30:16.000000000 -0700
@@ -67,9 +67,6 @@
  *
  * - Support PAGE_ALLOC_DEBUG. Should be easy to do.
  *
- * - Support DEBUG_SLAB_LEAK. Trouble is we do not know where the full
- *   slabs are in SLUB.
- *
  * - SLAB_DEBUG_INITIAL is not supported but I have never seen a use of
  *   it.
  *
@@ -2407,6 +2404,169 @@ static unsigned long validate_slab_cache
 	return count;
 }
 
+/*
+ * Generate lists of locations where slabcache objects are allocated
+ * and freed.
+ */
+
+struct location {
+	unsigned long count;
+	void *addr;
+};
+
+struct loc_track {
+	unsigned long max;
+	unsigned long count;
+	struct location *loc;
+};
+
+static void free_loc_track(struct loc_track *t)
+{
+	if (t->max)
+		free_pages((unsigned long)t->loc,
+			get_order(sizeof(struct location) * t->max));
+}
+
+static int alloc_loc_track(struct loc_track *t, unsigned long max)
+{
+	struct location *l;
+	int order;
+
+	if (!max)
+		max = PAGE_SIZE / sizeof(struct location);
+
+	order = get_order(sizeof(struct location) * max);
+
+	l = (void *)__get_free_pages(GFP_KERNEL, order);
+
+	if (!l)
+		return 0;
+
+	if (t->count) {
+		memcpy(l, t->loc, sizeof(struct location) * t->count);
+		free_loc_track(t);
+	}
+	t->max = max;
+	t->loc = l;
+	return 1;
+}
+
+static int add_location(struct loc_track *t, struct kmem_cache *s,
+						void *addr)
+{
+	long start, end, pos;
+	struct location *l;
+	void *caddr;
+
+	start = -1;
+	end = t->count;
+
+	for(;;) {
+		pos = start + (end - start + 1) / 2;
+
+		/*
+		 * There is nothing at "end". If we end up there
+		 * we need to add something to before end.
+		 */
+		if (pos == end)
+			break;
+
+		caddr = t->loc[pos].addr;
+		if (addr == caddr) {
+			t->loc[pos].count++;
+			return 1;
+		}
+
+		if (addr < caddr)
+			end = pos;
+		else
+			start = pos;
+	}
+
+	/*
+	 * Not found. Insert new tracking element
+	 */
+	if (t->count >= t->max && !alloc_loc_track(t, 2 * t->max))
+		return 0;
+
+	l = t->loc + pos;
+	if (pos < t->count)
+		memmove(l + 1, l,
+			(t->count - pos) * sizeof(struct location));
+	t->count++;
+	l->count = 1;
+	l->addr = addr;
+	return 1;
+}
+
+static void process_slab(struct loc_track *t, struct kmem_cache *s,
+		struct page *page, enum track_item alloc)
+{
+	void *addr = page_address(page);
+	unsigned long map[BITS_TO_LONGS(s->objects)];
+	void *p;
+
+	bitmap_zero(map, s->objects);
+	for(p = page->freelist; p; p = get_freepointer(s, p))
+		set_bit((p - addr) / s->size, map);
+
+	for(p = addr; p < addr + s->objects * s->size; p += s->size)
+		if (!test_bit((p - addr) / s->size, map)) {
+			void *addr = get_track(s, p, alloc)->addr;
+
+			add_location(t, s, addr);
+		}
+}
+
+static int list_locations(struct kmem_cache *s, char *buf,
+					enum track_item alloc)
+{
+	int n = 0;
+	unsigned long i;
+	struct loc_track t;
+	int node;
+
+	t.count = 0;
+	t.max = 0;
+
+	/* Push back cpu slabs */
+	flush_all(s);
+
+	for_each_online_node(node) {
+		struct kmem_cache_node *n = get_node(s, node);
+		unsigned long flags;
+		struct page *page;
+
+		if (!atomic_read(&n->nr_slabs))
+			continue;
+
+		spin_lock_irqsave(&n->list_lock, flags);
+		list_for_each_entry(page, &n->partial, lru)
+			process_slab(&t, s, page, alloc);
+		list_for_each_entry(page, &n->full, lru)
+			process_slab(&t, s, page, alloc);
+		spin_unlock_irqrestore(&n->list_lock, flags);
+	}
+
+	for (i = 0; i < t.count; i++) {
+		void *addr = t.loc[i].addr;
+
+		if (n > PAGE_SIZE - 100)
+			break;
+		n += sprintf(buf + n, "%7ld ", t.loc[i].count);
+		if (addr)
+			n += sprint_symbol(buf + n, (unsigned long)t.loc[i].addr);
+		else
+			n += sprintf(buf + n, "<not-available>");
+		n += sprintf(buf + n, "\n");
+	}
+
+	free_loc_track(&t);
+	if (!t.count)
+		n += sprintf(buf, "No data\n");
+	return n;
+}
+
 static unsigned long count_partial(struct kmem_cache_node *n)
 {
 	unsigned long flags;
@@ -2757,6 +2917,22 @@ static ssize_t validate_store(struct kme
 }
 SLAB_ATTR(validate);
 
+static ssize_t alloc_calls_show(struct kmem_cache *s, char *buf)
+{
+	if (!(s->flags & SLAB_STORE_USER))
+		return -ENOSYS;
+	return list_locations(s, buf, TRACK_ALLOC);
+}
+SLAB_ATTR_RO(alloc_calls);
+
+static ssize_t free_calls_show(struct kmem_cache *s, char *buf)
+{
+	if (!(s->flags & SLAB_STORE_USER))
+		return -ENOSYS;
+	return list_locations(s, buf, TRACK_FREE);
+}
+SLAB_ATTR_RO(free_calls);
+
 #ifdef CONFIG_NUMA
 static ssize_t defrag_ratio_show(struct kmem_cache *s, char *buf)
 {
@@ -2797,6 +2973,8 @@ static struct attribute * slab_attrs[] =
 	&poison_attr.attr,
 	&store_user_attr.attr,
 	&validate_attr.attr,
+	&alloc_calls_attr.attr,
+	&free_calls_attr.attr,
 #ifdef CONFIG_ZONE_DMA
 	&cache_dma_attr.attr,
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
