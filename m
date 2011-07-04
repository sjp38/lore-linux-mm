Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8FBF19000C2
	for <linux-mm@kvack.org>; Mon,  4 Jul 2011 10:05:37 -0400 (EDT)
Received: by mail-iy0-f169.google.com with SMTP id 8so6219561iyl.14
        for <linux-mm@kvack.org>; Mon, 04 Jul 2011 07:05:35 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v4 06/10] migration: introudce migrate_ilru_pages
Date: Mon,  4 Jul 2011 23:04:39 +0900
Message-Id: <132686a2ab204bb917bea5faa4eb5cb797940518.1309787991.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1309787991.git.minchan.kim@gmail.com>
References: <cover.1309787991.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1309787991.git.minchan.kim@gmail.com>
References: <cover.1309787991.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

This patch defines new APIs to put back new page into old page's position as LRU order.
for LRU churning of compaction.

The idea I suggested in LSF/MM is simple.

When we try to put back the page into lru list and if friends(prev, next) of the page
still is nearest neighbor, we can insert isolated page into prev's next instead of
head of LRU list. So it keeps LRU history without losing the LRU information.

Before :
       LRU POV : H - P1 - P2 - P3 - P4 -T

Isolate P3 :
       LRU POV : H - P1 - P2 - P4 - T

Putback P3 :
       if (P2->next == P4)
               putback(P3, P2);
       So,
       LRU POV : H - P1 - P2 - P3 - P4 -T

I implemented this idea in RFC but it had two problems.

1)
For implement, I defined new structure _pages_lru_ which remembers
both lru friend pages of isolated one and handling functions.
For space of pages_lru, I allocated the space dynamically in kmalloc(GFP_AOTMIC)
but as we know, compaction is a reclaim path so it's not good idea to allocate memory
dynamically in the path. The space need to store pages_lru is enough to allocate just a page
as current compaction migrates unit of chunk of 32 pages.
In addition, compaction makes sure lots of order-0 free pages before starting
so it wouldn't a big problem, I think. But I admit it can pin some pages
so migration successful ratio might be down if concurrent compaction happens.

I decide changing my mind. I don't use dynamic memory space any more.
As I see migration, we don't need doubly linked list of page->lru.
Whole of operation is performed with enumeration so I think singly linked list is enough.
If we can use singly linked list, we can use a pointer as another buffer.
In here, we use it to store prev LRU page of page isolated.

2)
The page-relation approach had a problem on contiguous pages.
That's because the idea can not work since friend pages are isolated, too.
It means prev_page->next == next_page always is _false_ and both pages are not
LRU any more at that time. It's pointed out by Rik at LSF/MM summit.
So for solving the problem, I changed the idea.
We don't need both friend(prev, next) pages relation but just consider
either prev or next page that it is still same LRU

Worst case in this approach, prev or next page is free and allocate new
so it's in head of LRU and our isolated page is located on next of head.
But it's almost same situation with current problem. So it doesn't make worse
than now.

New idea works below.

How to work inorder_lru
Assumption : we isolate pages P3-P7 and we consider only prev LRU pointer.
Notation : (P3,P2) = (isolated page, previous LRU page of isolated page)

H - P1 - P2 - P3 - P4 - P5 - P6 - P7 - P8 - P9 - P10 - T

If we isolate P3,
H - P1 - P2 - P4 - P5 - P6 - P7 - P8 - P9 - P10 - T
Isolated page list - (P3,P2)

If we isolate P4,

H - P1 - P2 - P5 - P6 - P7 - P8 - P9 - P10 - T
Isolated page list - (P4,P2) - (P3,P2)

If we isolate P5,

H - P1 - P2 - P6 - P7 - P8 - P9 - P10 - T
Isolated page list - (P5,P2) - (P4,P2) - (P3,P2)

..

If we isolate P7, following as
H - P1 - P2 - P8 - P9 - P10 - T
Isolated page list - (P7,P2) - (P6,P2) - (P5,P2) - (P4,P2) - (P3,P2)

Let's start putback from P7

P7.
H - P1 - P2 - P8 - P9 - P10 - T
prev P2 is on still LRU so P7 would be located at P2's next.
H - P1 - P2 - P7 - P8 - P9 - P10 - T

P6.
H - P1 - P2 - P7 - P8 - P9 - P10 - T
prev P2 is on still LRU so P6 would be located at P2's next.
H - P1 - P2 - P6 - P7 - P8 - P9 - P10 - T

P5.
..

P3.
H - P1 - P2 - P4 - P5 - P6 - P7 - P8 - P9 - P10 - T
prev P2 is on still LRU so P3 would be located at P2's next.
H - P1 - P2 - P3 - P4 - P5 - P6 - P7 - P8 - P9 - P10 - T

In addtion, this patch introduces new API *migrate_ilru_pages* which
is aware of inorder_lru putback. So newpage is located at old page's
LRU position.

[migrate_pages vs migrate_ilru_pages]

1) we need handle singly linked list.
   The page->lru isn't doubly linked list any more in inorder_lru handling
   So migrate_ilru_pages have to handle singly linked list instead of doubly lined list.

2) We need defer old page's putback.
   At present, during migration, old page would be freed through unmap_and_move's
   putback_lru_page. It has a problem in inorder-putback's logic.
   The same_lru in migrate_ilru_pages checks old pages's PageLRU and something
   for determining whether the page can be located at old page's position or not.
   If old page is freed before handling inorder-lru list, it ends up having !PageLRU
   and same_lru returns 'false' so that inorder putback would become no-op.

3) we need adjust prev_page of inorder_lru page list when we putback newpage
   and free old page.

For example,

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P4 - P3 - P2 - P1 - T
inorder_lru : 0

We isolate P2,P3,P4 so inorder_lru has following list

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P1 - T
inorder_lru : (P4,P5) - (P3,P4) - (P2,P3)

After 1st putback,

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P4' - P1 - T
inorder_lru : (P3,P4) - (P2,P3)
P4' is newpage and P4(ie, old page) would freed

In 2nd putback, P3 would find P4 in same_lru but P4 is in buddy
so it returns 'false' then inorder_lru doesn't work any more.
The bad effect continues until P2. That's too bad.
For fixing, this patch defines adjust_ilru_prev_page.
It works following as.

Notation)
PHY : page physical layout on memory
LRU : page logical layout as LRU order
ilru : inorder_lru list
PN : old page(ie, source page of migration)
PN' : new page(ie, destination page of migration)

Let's assume there is below layout.
PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P4 - P3 - P2 - P1 - T
ilru :

We isolate P2,P3,P4 so inorder_lru has following as.

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P1 - T
ilru : (P4,P5) - (P3,P4) - (P2,P3)

After 1st putback happens,

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P4' - P1 - T
ilru : (P3,P4) - (P2,P3)
P4' is a newpage and P4(ie, old page) would freed

In 2nd putback, P3 would try findding P4 but P4 would be freed.
so same_lru returns 'false' so that inorder_lru doesn't work any more.
The bad effect continues until P2. That's too bad.
For fixing, we define adjust_ilru_prev_page. It works following as.

After 1st putback,
PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P4' - P1 - T
ilru : (P3,P4') - (P2,P3)
It replaces prev pointer of pages remained in inorder_lru list with
new one's so in 2nd putback,

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P4' - P3' - P1 -  T
ilru : (P2,P3')

In 3rd putback,

PHY : H - P1 - P2 - P3 - P4 - P5 - T
LRU : H - P5 - P4' - P3' - P2' - P1 - T
ilru :

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/migrate.h  |   87 +++++++++++++++++
 include/linux/mm_types.h |   18 +++-
 include/linux/swap.h     |    4 +
 mm/internal.h            |    1 +
 mm/migrate.c             |  242 +++++++++++++++++++++++++++++++++++++++++++++-
 mm/swap.c                |    2 +-
 mm/vmscan.c              |   51 ++++++++++
 7 files changed, 402 insertions(+), 3 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index e39aeec..62724e1 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -9,12 +9,99 @@ typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 #ifdef CONFIG_MIGRATION
 #define PAGE_MIGRATION 1
 
+/* How to work inorder_lru
+ * Assumption : we isolate pages P3-P7 and we consider only prev LRU pointer.
+ * Notation : (P3,P2) = (isolated page, previous LRU page of isolated page)
+ *
+ * H - P1 - P2 - P3 - P4 - P5 - P6 - P7 - P8 - P9 - P10 - T
+ *
+ * If we isolate P3,
+ *
+ * H - P1 - P2 - P4 - P5 - P6 - P7 - P8 - P9 - P10 - T
+ * Isolated page list - (P3,P2)
+ *
+ * If we isolate P4,
+ *
+ * H - P1 - P2 - P5 - P6 - P7 - P8 - P9 - P10 - T
+ * Isolated page list - (P4,P2) - (P3,P2)
+ *
+ * If we isolate P5,
+ *
+ * H - P1 - P2 - P6 - P7 - P8 - P9 - P10 - T
+ * Isolated page list - (P5,P2) - (P4,P2) - (P3,P2)
+ *
+ * ..
+ *
+ * If we isolate P7, following as
+ * H - P1 - P2 - P8 - P9 - P10 - T
+ * Isolated page list - (P7,P2) - (P6,P2) - (P5,P2) - (P4,P2) - (P3,P2)
+ *
+ * Let's start putback from P7
+ *
+ * P7.
+ * H - P1 - P2 - P8 - P9 - P10 - T
+ * prev P2 is on still LRU so P7 would be located at P2's next.
+ * H - P1 - P2 - P7 - P8 - P9 - P10 - T
+ *
+ * P6.
+ * H - P1 - P2 - P7 - P8 - P9 - P10 - T
+ * prev P2 is on still LRU so P6 would be located at P2's next.
+ * H - P1 - P2 - P6 - P7 - P8 - P9 - P10 - T
+ *
+ * P5.
+ * ..
+ *
+ * P3.
+ * H - P1 - P2 - P4 - P5 - P6 - P7 - P8 - P9 - P10 - T
+ * prev P2 is on still LRU so P3 would be located at P2's next.
+ * H - P1 - P2 - P3 - P4 - P5 - P6 - P7 - P8 - P9 - P10 - T
+ */
+
+/*
+ * ilru_list is singly linked list and used for compaction
+ * for keeping LRU ordering.
+ */
+static inline void INIT_ILRU_LIST(struct inorder_lru *list)
+{
+	list->prev_page = NULL;
+	list->next = list;
+}
+
+static inline int ilru_list_empty(const struct inorder_lru *head)
+{
+	return head->next == head;
+}
+
+static inline void ilru_list_add(struct page *page, struct page *prev_page,
+				struct inorder_lru *head)
+{
+	VM_BUG_ON(PageLRU(page));
+
+	page->ilru.prev_page = prev_page;
+	page->ilru.next = head->next;
+	head->next = &page->ilru;
+}
+
+static inline void ilru_list_del(struct page *page, struct inorder_lru *head)
+{
+	head->next = page->ilru.next;
+}
+
+#define list_for_each_ilru_entry	list_for_each_entry
+#define list_for_each_ilru_entry_safe	list_for_each_entry_safe
+
+extern void putback_ilru_pages(struct inorder_lru *l);
 extern void putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
 extern int migrate_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
 			bool sync);
+
+extern int migrate_ilru_pages(struct inorder_lru *l, new_page_t x,
+			unsigned long private, bool offlining,
+			bool sync);
+
 extern int migrate_huge_pages(struct list_head *l, new_page_t x,
 			unsigned long private, bool offlining,
 			bool sync);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 027935c..3634c04 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -24,6 +24,19 @@ struct address_space;
 
 #define USE_SPLIT_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
 
+struct page;
+
+/*
+ * The inorder_lru is used by compaction for keeping LRU order
+ * during migration.
+ */
+struct inorder_lru {
+	/* prev LRU page of isolated page */
+	struct page *prev_page;
+	/* next for singly linked list*/
+	struct inorder_lru *next;
+};
+
 /*
  * Each physical page in the system has a struct page associated with
  * it to keep track of whatever it is we are using the page for at the
@@ -72,9 +85,12 @@ struct page {
 		pgoff_t index;		/* Our offset within mapping. */
 		void *freelist;		/* SLUB: freelist req. slab lock */
 	};
-	struct list_head lru;		/* Pageout list, eg. active_list
+	union {
+		struct inorder_lru ilru;/* compaction: migrated page list */
+		struct list_head lru;	/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
 					 */
+	};
 	/*
 	 * On machines where all RAM is mapped into kernel address space,
 	 * we can simply calculate the virtual address. On machines with
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 03727bf..2208412 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -228,6 +228,8 @@ extern int lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
 extern void deactivate_page(struct page *page);
 extern void swap_setup(void);
+extern void update_page_reclaim_stat(struct zone *zone, struct page *page,
+		int file, int rotated);
 
 extern void add_page_to_unevictable_list(struct page *page);
 
@@ -257,6 +259,8 @@ extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						struct zone *zone,
 						unsigned long *nr_scanned);
 extern int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file);
+extern int isolate_ilru_page(struct page *page, isolate_mode_t mode, int file,
+						struct page **prev_page);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
diff --git a/mm/internal.h b/mm/internal.h
index d071d38..8a919c7 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -42,6 +42,7 @@ extern unsigned long highest_memmap_pfn;
 /*
  * in mm/vmscan.c:
  */
+extern void putback_page_to_lru(struct page *page, struct page *head_page);
 extern int isolate_lru_page(struct page *page);
 extern void putback_lru_page(struct page *page);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 71713fc..b997de5 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -85,6 +85,50 @@ void putback_lru_pages(struct list_head *l)
 }
 
 /*
+ * Check if page and prev are on same LRU.
+ * zone->lru_lock must be hold.
+ */
+static bool same_lru(struct page *page, struct page *prev)
+{
+	bool ret = false;
+	if (!prev || !PageLRU(prev))
+		goto out;
+
+	if (unlikely(PageUnevictable(prev)))
+		goto out;
+
+	if (page_lru_base_type(page) != page_lru_base_type(prev))
+		goto out;
+
+	ret = true;
+out:
+	return ret;
+}
+
+
+void putback_ilru_pages(struct inorder_lru *l)
+{
+	struct zone *zone;
+	struct page *page, *page2, *prev;
+
+	list_for_each_ilru_entry_safe(page, page2, l, ilru) {
+		ilru_list_del(page, l);
+		dec_zone_page_state(page, NR_ISOLATED_ANON +
+				page_is_file_cache(page));
+		zone = page_zone(page);
+		spin_lock_irq(&zone->lru_lock);
+		prev = page->ilru.prev_page;
+		if (same_lru(page, prev)) {
+			putback_page_to_lru(page, prev);
+			spin_unlock_irq(&zone->lru_lock);
+			put_page(page);
+		} else {
+			spin_unlock_irq(&zone->lru_lock);
+			putback_lru_page(page);
+		}
+	}
+}
+/*
  * Restore a potential migration pte to a working pte entry
  */
 static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
@@ -821,6 +865,151 @@ out:
 }
 
 /*
+ * We need adjust prev_page of ilru_list when we putback newpage
+ * and free old page. Let's think about it.
+ * For example,
+ *
+ * Notation)
+ * PHY : page physical layout on memory
+ * LRU : page logical layout as LRU order
+ * ilru : inorder_lru list
+ * PN : old page(ie, source page of migration)
+ * PN' : new page(ie, destination page of migration)
+ *
+ * Let's assume there is below layout.
+ * PHY : H - P1 - P2 - P3 - P4 - P5 - T
+ * LRU : H - P5 - P4 - P3 - P2 - P1 - T
+ * ilru :
+ *
+ * We isolate P2,P3,P4 so inorder_lru has following as.
+ *
+ * PHY : H - P1 - P2 - P3 - P4 - P5 - T
+ * LRU : H - P5 - P1 - T
+ * ilru : (P4,P5) - (P3,P4) - (P2,P3)
+ *
+ * After 1st putback happens,
+ *
+ * PHY : H - P1 - P2 - P3 - P4 - P5 - T
+ * LRU : H - P5 - P4' - P1 - T
+ * ilru : (P3,P4) - (P2,P3)
+ * P4' is a newpage and P4(ie, old page) would freed
+ *
+ * In 2nd putback, P3 would try findding P4 but P4 would be freed.
+ * so same_lru returns 'false' so that inorder_lru doesn't work any more.
+ * The bad effect continues until P2. That's too bad.
+ * For fixing, we define adjust_ilru_prev_page. It works following as.
+ *
+ * After 1st putback,
+ *
+ * PHY : H - P1 - P2 - P3 - P4 - P5 - T
+ * LRU : H - P5 - P4' - P1 - T
+ * ilru : (P3,P4') - (P2,P3)
+ * It replaces prev pointer of pages remained in inorder_lru list with
+ * new one's so in 2nd putback,
+ *
+ * PHY : H - P1 - P2 - P3 - P4 - P5 - T
+ * LRU : H - P5 - P4' - P3' - P1 -  T
+ * ilru : (P2,P3')
+ *
+ * In 3rd putback,
+ *
+ * PHY : H - P1 - P2 - P3 - P4 - P5 - T
+ * LRU : H - P5 - P4' - P3' - P2' - P1 - T
+ * ilru :
+ */
+static inline void adjust_ilru_prev_page(struct inorder_lru *head,
+		struct page *prev_page, struct page *new_page)
+{
+	struct page *page;
+	list_for_each_ilru_entry(page, head, ilru)
+		if (page->ilru.prev_page == prev_page)
+			page->ilru.prev_page = new_page;
+}
+
+void __put_ilru_pages(struct page *page, struct page *newpage,
+		struct inorder_lru *prev_lru, struct inorder_lru *ihead)
+{
+	struct page *prev_page;
+	struct zone *zone;
+	prev_page = page->ilru.prev_page;
+	/*
+	 * A page that has been migrated has all references
+	 * removed and will be freed. A page that has not been
+	 * migrated will have kepts its references and be
+	 * restored.
+	 */
+	ilru_list_del(page, prev_lru);
+	dec_zone_page_state(page, NR_ISOLATED_ANON +
+			page_is_file_cache(page));
+
+	/*
+	 * Move the new page to the LRU. If migration was not successful
+	 * then this will free the page.
+	 */
+	zone = page_zone(newpage);
+	spin_lock_irq(&zone->lru_lock);
+	if (same_lru(page, prev_page)) {
+		putback_page_to_lru(newpage, prev_page);
+		spin_unlock_irq(&zone->lru_lock);
+		/*
+		 * The newpage replaced LRU position of old page and
+		 * old one would be freed. So let's adjust prev_page of pages
+		 * remained in inorder_lru list.
+		 */
+		adjust_ilru_prev_page(ihead, page, newpage);
+		put_page(newpage);
+	} else {
+		spin_unlock_irq(&zone->lru_lock);
+		putback_lru_page(newpage);
+	}
+
+	putback_lru_page(page);
+}
+
+/*
+ * Counterpart of unmap_and_move() for compaction.
+ * The logic is almost same with unmap_and_move. The difference is that
+ * this function handles inorder_lru for locating new page into old pages's
+ * LRU position.
+ */
+static int unmap_and_move_ilru(new_page_t get_new_page, unsigned long private,
+		struct page *page, int force, bool offlining, bool sync,
+		struct inorder_lru *prev_lru, struct inorder_lru *ihead)
+{
+	int rc = 0;
+	int *result = NULL;
+	struct page *newpage = get_new_page(page, private, &result);
+
+	if (!newpage)
+		return -ENOMEM;
+
+	if (page_count(page) == 1) {
+		/* page was freed from under us. So we are done. */
+		goto out;
+	}
+
+	if (unlikely(PageTransHuge(page)))
+		if (unlikely(split_huge_page(page)))
+			goto out;
+
+	rc = __unmap_and_move(page, newpage, force, offlining, sync);
+out:
+	if (rc != -EAGAIN)
+		__put_ilru_pages(page, newpage, prev_lru, ihead);
+	else
+		putback_lru_page(newpage);
+
+	if (result) {
+		if (rc)
+			*result = rc;
+		else
+			*result = page_to_nid(newpage);
+	}
+
+	return rc;
+}
+
+/*
  * Counterpart of unmap_and_move_page() for hugepage migration.
  *
  * This function doesn't wait the completion of hugepage I/O
@@ -920,7 +1109,7 @@ int migrate_pages(struct list_head *from,
 	if (!swapwrite)
 		current->flags |= PF_SWAPWRITE;
 
-	for(pass = 0; pass < 10 && retry; pass++) {
+	for (pass = 0; pass < 10 && retry; pass++) {
 		retry = 0;
 
 		list_for_each_entry_safe(page, page2, from, lru) {
@@ -956,6 +1145,57 @@ out:
 	return nr_failed + retry;
 }
 
+int migrate_ilru_pages(struct inorder_lru *ihead, new_page_t get_new_page,
+		unsigned long private, bool offlining, bool sync)
+{
+	int retry = 1;
+	int nr_failed = 0;
+	int pass = 0;
+	struct page *page, *page2;
+	struct inorder_lru *prev;
+	int swapwrite = current->flags & PF_SWAPWRITE;
+	int rc;
+
+	if (!swapwrite)
+		current->flags |= PF_SWAPWRITE;
+
+	for (pass = 0; pass < 10 && retry; pass++) {
+		retry = 0;
+		prev = ihead;
+		list_for_each_ilru_entry_safe(page, page2, ihead, ilru) {
+			cond_resched();
+
+			rc = unmap_and_move_ilru(get_new_page, private,
+					page, pass > 2, offlining,
+					sync, prev, ihead);
+
+			switch (rc) {
+			case -ENOMEM:
+				goto out;
+			case -EAGAIN:
+				retry++;
+				prev = &page->ilru;
+				break;
+			case 0:
+				break;
+			default:
+				/* Permanent failure */
+				nr_failed++;
+				break;
+			}
+		}
+	}
+	rc = 0;
+out:
+	if (!swapwrite)
+		current->flags &= ~PF_SWAPWRITE;
+
+	if (rc)
+		return rc;
+
+	return nr_failed + retry;
+}
+
 int migrate_huge_pages(struct list_head *from,
 		new_page_t get_new_page, unsigned long private, bool offlining,
 		bool sync)
diff --git a/mm/swap.c b/mm/swap.c
index 3a442f1..bdaf329 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -252,7 +252,7 @@ void rotate_reclaimable_page(struct page *page)
 	}
 }
 
-static void update_page_reclaim_stat(struct zone *zone, struct page *page,
+void update_page_reclaim_stat(struct zone *zone, struct page *page,
 				     int file, int rotated)
 {
 	struct zone_reclaim_stat *reclaim_stat = &zone->reclaim_stat;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0d9ae67..938dea9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -566,6 +566,35 @@ int remove_mapping(struct address_space *mapping, struct page *page)
 }
 
 /**
+ * putback_page_to_lru - put isolated @page onto @head
+ * @page: page to be put back to appropriate lru list
+ * @head_page: lru position to be put back
+ *
+ * Insert previously isolated @page to appropriate position of lru list
+ * zone->lru_lock must be hold.
+ */
+void putback_page_to_lru(struct page *page, struct page *head_page)
+{
+	int lru, active, file;
+	struct zone *zone = page_zone(page);
+
+	VM_BUG_ON(PageLRU(page));
+
+	lru = page_lru(head_page);
+	active = is_active_lru(lru);
+	file = is_file_lru(lru);
+
+	if (active)
+		SetPageActive(page);
+	else
+		ClearPageActive(page);
+
+	update_page_reclaim_stat(zone, page, file, active);
+	SetPageLRU(page);
+	__add_page_to_lru_list(zone, page, lru, &head_page->lru);
+}
+
+/**
  * putback_lru_page - put previously isolated page onto appropriate LRU list
  * @page: page to be put back to appropriate lru list
  *
@@ -1025,6 +1054,28 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
 }
 
 /*
+ * It's same with __isolate_lru_page except that it returns previous page
+ * of page isolated as LRU order if isolation is successful.
+ */
+int isolate_ilru_page(struct page *page, isolate_mode_t mode, int file,
+						struct page **prev_page)
+{
+	int ret = __isolate_lru_page(page, mode, file);
+	if (!ret) {
+		struct zone *zone = page_zone(page);
+		enum lru_list l = page_lru(page);
+		if (&zone->lru[l].list == page->lru.prev) {
+			*prev_page = NULL;
+			return ret;
+		}
+
+		*prev_page = lru_to_page(&page->lru);
+	}
+
+	return ret;
+}
+
+/*
  * zone->lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
  * and working on them outside the LRU lock.
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
