Date: Mon, 3 Apr 2006 23:57:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060404065750.24532.67454.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 2/6] Swapless V1:  Add SWP_TYPE_MIGRATION
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, lhms-devel@lists.sourceforge.net, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Add migration swap type

SWP_TYPE_MIGRATION is a special swap type that encodes the pfn of the
page in the swp_offset.

Note that the swp_offset size is limited. This is 27 bits on 32 bit and
54 bits on IA64. pfn numbers must fit into that size of a field for
this scheme to work. Could that be a problem?

SWP_TYPE_MIGRATION is only set for a pte while the corresponding page
is locked. It is removed while the page is still locked. Therefore the
processing for this special type of swap page can be simple.

The freeing of this type of entry is simply ignored.

lookup_swap_cache() determines the page from the pfn and only takes a
reference on the page.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc1/mm/swap_state.c
===================================================================
--- linux-2.6.17-rc1.orig/mm/swap_state.c	2006-04-02 20:22:10.000000000 -0700
+++ linux-2.6.17-rc1/mm/swap_state.c	2006-04-03 23:26:21.000000000 -0700
@@ -10,6 +10,7 @@
 #include <linux/mm.h>
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
+#include <linux/swapops.h>
 #include <linux/init.h>
 #include <linux/pagemap.h>
 #include <linux/buffer_head.h>
@@ -299,6 +300,16 @@ struct page * lookup_swap_cache(swp_entr
 {
 	struct page *page;
 
+	/*
+	 * If the swap type is SWP_TYPE_MIGRATION then the
+	 * swap entry contains the pfn of a page.
+	 */
+	if (unlikely(swp_type(entry) == SWP_TYPE_MIGRATION)) {
+		page = pfn_to_page(swp_offset(entry));
+		get_page(page);
+		return page;
+	}
+
 	page = find_get_page(&swapper_space, entry.val);
 
 	if (page)
Index: linux-2.6.17-rc1/mm/swapfile.c
===================================================================
--- linux-2.6.17-rc1.orig/mm/swapfile.c	2006-04-02 20:22:10.000000000 -0700
+++ linux-2.6.17-rc1/mm/swapfile.c	2006-04-03 23:26:21.000000000 -0700
@@ -395,6 +395,9 @@ void free_swap_and_cache(swp_entry_t ent
 	struct swap_info_struct * p;
 	struct page *page = NULL;
 
+	if (swp_type(entry) == SWP_TYPE_MIGRATION)
+		return;
+
 	p = swap_info_get(entry);
 	if (p) {
 		if (swap_entry_free(p, swp_offset(entry)) == 1) {
@@ -1710,6 +1713,9 @@ int swap_duplicate(swp_entry_t entry)
 	int result = 0;
 
 	type = swp_type(entry);
+	if (type == SWP_TYPE_MIGRATION)
+		return 1;
+
 	if (type >= nr_swapfiles)
 		goto bad_file;
 	p = type + swap_info;
Index: linux-2.6.17-rc1/include/linux/swap.h
===================================================================
--- linux-2.6.17-rc1.orig/include/linux/swap.h	2006-04-02 20:22:10.000000000 -0700
+++ linux-2.6.17-rc1/include/linux/swap.h	2006-04-03 23:43:03.000000000 -0700
@@ -29,7 +29,10 @@ static inline int current_is_kswapd(void
  * the type/offset into the pte as 5/27 as well.
  */
 #define MAX_SWAPFILES_SHIFT	5
-#define MAX_SWAPFILES		(1 << MAX_SWAPFILES_SHIFT)
+#define MAX_SWAPFILES		((1 << MAX_SWAPFILES_SHIFT)-1)
+
+/* Use last entry for page migration swap entries */
+#define SWP_TYPE_MIGRATION	MAX_SWAPFILES
 
 /*
  * Magic header for a swap area. The first part of the union is
@@ -293,7 +296,6 @@ static inline void disable_swap_token(vo
 #define swap_duplicate(swp)			/*NOTHING*/
 #define swap_free(swp)				/*NOTHING*/
 #define read_swap_cache_async(swp,vma,addr)	NULL
-#define lookup_swap_cache(swp)			NULL
 #define valid_swaphandles(swp, off)		0
 #define can_share_swap_page(p)			0
 #define move_to_swap_cache(p, swp)		1
@@ -302,6 +304,12 @@ static inline void disable_swap_token(vo
 #define delete_from_swap_cache(p)		/*NOTHING*/
 #define swap_token_default_timeout		0
 
+#ifdef CONFIG_MIGRATION
+extern struct page* lookup_swap_cache(swp_entry_t);
+#else
+#define lookup_swap_cache(swp)			NULL
+#endif
+
 static inline int remove_exclusive_swap_page(struct page *p)
 {
 	return 0;
Index: linux-2.6.17-rc1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc1.orig/mm/migrate.c	2006-04-03 22:07:40.000000000 -0700
+++ linux-2.6.17-rc1/mm/migrate.c	2006-04-03 23:44:10.000000000 -0700
@@ -32,6 +32,18 @@
 
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
+#ifndef CONFIG_SWAP
+struct page *lookup_swap_cache(swp_entry_t entry)
+{
+	if (unlikely(swp_type(entry) == SWP_TYPE_MIGRATION)) {
+		struct page *page = pfn_to_page(swp_offset(entry));
+		get_page(page);
+		return page;
+	}
+	return NULL;
+}
+#endif
+
 /*
  * Isolate one page from the LRU lists. If successful put it onto
  * the indicated list with elevated page count.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
