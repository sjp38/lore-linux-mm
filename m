Received: from m4.gw.fujitsu.co.jp ([10.0.50.74]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i966WIUI028090 for <linux-mm@kvack.org>; Wed, 6 Oct 2004 15:32:18 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp by m4.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i966WHfQ009674 for <linux-mm@kvack.org>; Wed, 6 Oct 2004 15:32:17 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s4.gw.fujitsu.co.jp (localhost [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C3DDA15362F
	for <linux-mm@kvack.org>; Wed,  6 Oct 2004 15:32:17 +0900 (JST)
Received: from fjmail506.fjmail.jp.fujitsu.com (fjmail506-0.fjmail.jp.fujitsu.com [10.59.80.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 80BEE153635
	for <linux-mm@kvack.org>; Wed,  6 Oct 2004 15:32:17 +0900 (JST)
Received: from jp.fujitsu.com
 (fjscan501-0.fjmail.jp.fujitsu.com [10.59.80.120]) by
 fjmail506.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I5500DVFGTR71@fjmail506.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Wed,  6 Oct 2004 15:32:16 +0900 (JST)
Date: Wed, 06 Oct 2004 15:37:51 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC/PATCH]  pfn_valid() more generic : arch independent part[0/2]
Message-id: <416392BF.1020708@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LinuxIA64 <linux-ia64@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is generic parts.

Boot-time routine:
At first, information of valid pages is gathered into a list.
After gathering all information, 2 level table are created.
Why I create table instead of using a list is only for good cache hit.

pfn_valid_init()  <- initilize some structures
validate_pages(start,size) <- gather valid pfn information
pfn_valid_setup() <- create 1st and 2nd table.



Kame <kamezawa.hiroyu@jp.fujitsu.com>


---

 test-pfn-valid-kamezawa/include/linux/mm.h        |    2
 test-pfn-valid-kamezawa/include/linux/pfn_valid.h |   51 +++++
 test-pfn-valid-kamezawa/mm/page_alloc.c           |  191 ++++++++++++++++++++++
 3 files changed, 244 insertions(+)

diff -puN /dev/null include/linux/pfn_valid.h
--- /dev/null	2004-06-25 03:05:40.000000000 +0900
+++ test-pfn-valid-kamezawa/include/linux/pfn_valid.h	2004-10-05 12:03:54.000000000 +0900
@@ -0,0 +1,51 @@
+#ifndef _LINUX_PFN_VALID_H
+#define _LINUX_PFN_VALID_H
+/*
+ * Implementing pfn_valid() for managing memory hole.
+ * this uses 2 level table.
+ * 1st table is accessed by index of (pfn >> PFN_VALID_MAPSHIFT).
+ * It has rough information and pointer to 2nd table.
+ * If rough information is enough, 2nd table is not accessed.
+ * 2nd table has (start_pfn, nr_pages) entry which are sorted by start_pfn.
+ */
+
+#ifdef CAREFUL_PFN_VALID
+/* for 2nd level */
+struct pfn_valid_info {
+	unsigned long start_pfn;
+	unsigned long end_pfn;   /* Caution:end_pfn is not included in
+                                    this valid pfn range */
+};
+/* for 1st level */
+typedef union {
+	unsigned short valid;    /* for fast checking. take 2 values */
+	unsigned short index;    /* index to table,start for searching */
+}pfn_validmap_t;
+
+#define PFN_ALL_INVALID 0xffff
+#define PFN_ALL_VALID   0xfffe
+#define pfn_all_valid(ent)   ((ent)->valid == PFN_ALL_VALID)
+#define pfn_all_invalid(ent) ((ent)->valid == PFN_ALL_INVALID)
+
+#ifndef PFN_VALID_MAPSHIFT
+#define PFN_VALID_MAPSHIFT 16
+#endif
+
+#define PFN_VALID_MAPSIZE   (1 << PFN_VALID_MAPSHIFT)
+#define PFN_VALID_MAPMASK   (~(PFN_VALID_MAPSIZE - 1))
+
+extern void __init validate_pages(unsigned long start_pfn,
+				  unsigned long nr_pages);
+extern void __init pfn_valid_init(void);
+extern void __init pfn_valid_setup(void);
+extern int careful_pfn_valid(unsigned long pfn);
+
+#else /* CAREFUL_PFN_VALID */
+
+#define pfn_valid_init() do {}while(0)
+#define validate_pages(a, b) do {}while(0)
+#define pfn_validmap_setup() do{} while(0)
+
+
+#endif /* CAREFUL_PFN_VALID */
+#endif
diff -puN mm/page_alloc.c~careful_pfn_valid mm/page_alloc.c
--- test-pfn-valid/mm/page_alloc.c~careful_pfn_valid	2004-10-05 12:03:54.000000000 +0900
+++ test-pfn-valid-kamezawa/mm/page_alloc.c	2004-10-05 15:22:16.000000000 +0900
@@ -1399,6 +1399,8 @@ void __init memmap_init_zone(unsigned lo
 	struct page *start = pfn_to_page(start_pfn);
 	struct page *page;

+	validate_pages(start_pfn, size);
+
 	for (page = start; page < (start + size); page++) {
 		set_page_zone(page, NODEZONE(nid, zone));
 		set_page_count(page, 0);
@@ -2069,3 +2071,192 @@ void *__init alloc_large_system_hash(con

 	return table;
 }
+
+
+#ifdef CAREFUL_PFN_VALID
+/*
+ * this structure is not used when system is runnning.this used only for
+ * setup table
+ */
+struct pfn_valid_info_list {
+	struct list_head list;
+ 	struct pfn_valid_info info;
+};
+
+int num_pfn_valid_info;
+unsigned long max_valid_pfn;
+pfn_validmap_t *pfn_validmap;
+struct pfn_valid_info *pfn_valid_info_table;
+struct list_head __initdata pfn_valid_info_head;
+struct list_head __initdata pfn_valid_info_free;
+struct pfn_valid_info_list pfn_valid_info_list_pool[8 * MAX_NUMNODES] __initdata;
+
+/*
+ * initialize all structures and allocate pfn_valid_info_list.
+ * pfn_valid_info_lists are freed when we finish initializaiton.
+ */
+void __init pfn_valid_init()
+{
+	struct pfn_valid_info_list *info;
+	int i, num;
+	INIT_LIST_HEAD(&pfn_valid_info_head);
+	INIT_LIST_HEAD(&pfn_valid_info_free);
+	/* this memory is used only in boot-time */
+	info = pfn_valid_info_list_pool;
+	num = 8 * MAX_NUMNODES;
+	for (i = 0;i < num; i++, info++) {
+		list_add(&info->list, &pfn_valid_info_free);
+	}
+	num_pfn_valid_info = 0;
+	max_valid_pfn = 0;
+	pfn_validmap = NULL;
+	pfn_valid_info_table = NULL;
+}
+
+static struct pfn_valid_info_list * __init alloc_pfn_valid_info_list(
+				        unsigned long start_pfn,
+					unsigned long nr_pages)
+{
+	struct pfn_valid_info_list *ret;
+	struct list_head *top;
+	if (list_empty(&pfn_valid_info_free)) {
+		printk("pfn valid info are exhausted. too much small mems?");
+		BUG();
+	}
+ 	top = pfn_valid_info_free.next;
+	list_del(top);
+	ret = list_entry(top, struct pfn_valid_info_list, list);
+	ret->info.start_pfn = start_pfn;
+	ret->info.end_pfn = start_pfn + nr_pages;
+	num_pfn_valid_info++;
+	return ret;
+}
+
+static void __init free_pfn_valid_info_list(struct pfn_valid_info_list *ent)
+{
+	list_add(&ent->list, &pfn_valid_info_free);
+	num_pfn_valid_info--;
+}
+
+void __init validate_pages(unsigned long start_pfn,
+			   unsigned long nr_pages)
+{
+	struct pfn_valid_info_list *new, *ent, *next;
+	struct list_head *pos;
+	/* add entries */
+	new = alloc_pfn_valid_info_list(start_pfn, nr_pages);
+	list_for_each_entry(ent, &pfn_valid_info_head, list) {
+		if (ent->info.start_pfn >= new->info.start_pfn)
+			break;
+	}
+	list_add_tail(&new->list, &ent->list);
+	/* we must find and coalesce overlapped entries */
+	pos = pfn_valid_info_head.next;
+	while (pos != &pfn_valid_info_head) {
+		if (pos->next == &pfn_valid_info_head)
+			break;
+		ent = list_entry(pos, struct pfn_valid_info_list,list);
+		next = list_entry(pos->next, struct pfn_valid_info_list, list);
+		if ((ent->info.start_pfn <= next->info.start_pfn) &&
+		    (ent->info.end_pfn >= next->info.start_pfn)) {
+			ent->info.end_pfn =
+				(ent->info.end_pfn > next->info.end_pfn)?
+				ent->info.end_pfn : next->info.end_pfn;
+			list_del(pos->next);
+			free_pfn_valid_info_list(next);
+		} else {
+			pos = pos->next;
+		}
+	}
+	if (start_pfn + nr_pages > max_valid_pfn)
+		max_valid_pfn = start_pfn + nr_pages;
+	return;
+}
+
+/*
+ * before calling pfn_valid_map_setup(), we onlu have a list of valid pfn.
+ * we create a table of valid pfn and a map. The map works as a hash table
+ * and enables direct access to valid pfn. We call the map as level-1 table,
+ * the table of valid pfn as level-2 table.
+ * Note: after initilization, the list of valid pfn will be discarded.
+ */
+
+void __init pfn_valid_setup(void)
+{
+	struct pfn_valid_info *info;
+	struct pfn_valid_info_list *lent;
+	unsigned long pfn, end, index, offset;
+	int tablesize, mapsize;
+	/* create 2nd level table from list */
+	/* allocate space for table */
+	tablesize = sizeof(struct pfn_valid_info) * (num_pfn_valid_info + 1);
+	tablesize = LONG_ALIGN(tablesize);
+	pfn_valid_info_table = alloc_bootmem(tablesize);
+ 	memset(pfn_valid_info_table, 0, tablesize);
+	/* fill entries */
+	info = pfn_valid_info_table;
+        list_for_each_entry(lent, &pfn_valid_info_head, list) {
+		info->start_pfn = lent->info.start_pfn;
+		info->end_pfn = lent->info.end_pfn;
+		info++;
+	}
+	info->start_pfn = ~(0UL);
+	info->end_pfn = 0;
+
+	/* init level 1 table */
+	mapsize = sizeof(pfn_validmap_t) *
+		((max_valid_pfn >> PFN_VALID_MAPSHIFT) + 1);
+	mapsize = LONG_ALIGN(mapsize);
+	pfn_validmap = alloc_bootmem(mapsize);
+	memset(pfn_validmap, 0, mapsize);
+
+	/* fill level 1 table */
+	for (pfn = 0; pfn < max_valid_pfn; pfn += PFN_VALID_MAPSIZE) {
+		end = pfn + PFN_VALID_MAPSIZE - 1;
+		for (info = pfn_valid_info_table, offset=0;
+		     info->end_pfn != 0;
+		     info++, offset++) {
+			if (((info->start_pfn <= pfn) &&
+			     (info->end_pfn > pfn)) ||
+			     ((info->start_pfn > pfn) &&
+			      (info->start_pfn < end)) )
+				break;
+		}
+		index = pfn >> PFN_VALID_MAPSHIFT;
+		if (info->end_pfn != 0) {
+			if ((info->start_pfn <= pfn) && (info->end_pfn > end))
+				pfn_validmap[index].valid = PFN_ALL_VALID;
+			else
+				pfn_validmap[index].index = offset;
+		} else {
+			pfn_validmap[index].valid = PFN_ALL_INVALID;
+		}
+	}
+	return;
+}
+
+int careful_pfn_valid(unsigned long pfn)
+{
+	int index;
+	pfn_validmap_t *map;
+	struct pfn_valid_info *info;
+	if (pfn >= max_valid_pfn)
+		return 0;
+	index = pfn >> PFN_VALID_MAPSHIFT;
+	map = &pfn_validmap[index];
+	if (pfn_all_valid(map))
+		return 1;
+	if (pfn_all_invalid(map))
+		return 0;
+	/* go to 2nd level */
+	info = pfn_valid_info_table + map->index;
+	/* table is sorted */
+	while (info->start_pfn <= pfn) {
+		if ((info->start_pfn <= pfn) && (info->end_pfn > pfn))
+			return 1;
+		info++;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(careful_pfn_valid);
+#endif /* CAREFUL_PFN_VALID */
diff -puN include/linux/mm.h~careful_pfn_valid include/linux/mm.h
--- test-pfn-valid/include/linux/mm.h~careful_pfn_valid	2004-10-05 12:03:54.000000000 +0900
+++ test-pfn-valid-kamezawa/include/linux/mm.h	2004-10-05 12:03:54.000000000 +0900
@@ -41,6 +41,8 @@ extern int sysctl_legacy_va_layout;
 #define MM_VM_SIZE(mm)	TASK_SIZE
 #endif

+#include <linux/pfn_valid.h>
+
 /*
  * Linux kernel virtual memory manager primitives.
  * The idea being to have a "virtual" mm in the same way

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
