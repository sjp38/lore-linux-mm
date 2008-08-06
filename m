Subject: Re: [PATCH][RFC] dirty balancing for cgroups
In-Reply-To: Your message of "Fri, 11 Jul 2008 17:52:13 +0900"
	<20080711175213.dc69f068.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080711175213.dc69f068.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080806082046.349BE5A5F@siro.lan>
Date: Wed,  6 Aug 2008 17:20:46 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, menage@google.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

hi,

> On Fri, 11 Jul 2008 17:34:46 +0900 (JST)
> yamamoto@valinux.co.jp (YAMAMOTO Takashi) wrote:
> 
> > hi,
> > 
> > > > my patch penalizes heavy-writer cgroups as task_dirty_limit does
> > > > for heavy-writer tasks.  i don't think that it's necessary to be
> > > > tied to the memory subsystem because i merely want to group writers.
> > > > 
> > > Hmm, maybe what I need is different from this ;)
> > > Does not seem to be a help for memory reclaim under memcg.
> > 
> > to implement what you need, i think that we need to keep track of
> > the numbers of dirty-pages in each memory cgroups as a first step.
> > do you agree?
> > 
> yes, I think so, now.
> 
> may be not difficult but will add extra overhead ;( Sigh..

the following is a patch to add the overhead. :)
any comments?

YAMAMOTO Takashi


Signed-off-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
---

diff --git a/fs/buffer.c b/fs/buffer.c
index 9749a90..a2dc642 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -41,6 +41,7 @@
 #include <linux/bitops.h>
 #include <linux/mpage.h>
 #include <linux/bit_spinlock.h>
+#include <linux/memcontrol.h>
 
 static int fsync_buffers_list(spinlock_t *lock, struct list_head *list);
 
@@ -708,12 +709,19 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
 static int __set_page_dirty(struct page *page,
 		struct address_space *mapping, int warn)
 {
-	if (unlikely(!mapping))
-		return !TestSetPageDirty(page);
+	if (unlikely(!mapping)) {
+		if (TestSetPageDirty(page)) {
+			return 0;
+		} else {
+			mem_cgroup_set_page_dirty(page);
+			return 1;
+		}
+	}
 
 	if (TestSetPageDirty(page))
 		return 0;
 
+	mem_cgroup_set_page_dirty(page);
 	spin_lock_irq(&mapping->tree_lock);
 	if (page->mapping) {	/* Race with truncate? */
 		WARN_ON_ONCE(warn && !PageUptodate(page));
@@ -762,8 +770,14 @@ int __set_page_dirty_buffers(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 
-	if (unlikely(!mapping))
-		return !TestSetPageDirty(page);
+	if (unlikely(!mapping)) {
+		if (TestSetPageDirty(page)) {
+			return 0;
+		} else {
+			mem_cgroup_set_page_dirty(page);
+			return 1;
+		}
+	}
 
 	spin_lock(&mapping->private_lock);
 	if (page_has_buffers(page)) {
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ee1b2fc..f04441f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -57,6 +57,9 @@ extern int
 mem_cgroup_prepare_migration(struct page *page, struct page *newpage);
 extern void mem_cgroup_end_migration(struct page *page);
 
+extern void mem_cgroup_set_page_dirty(struct page *page);
+extern void mem_cgroup_clear_page_dirty(struct page *page);
+
 /*
  * For memory reclaim.
  */
@@ -132,6 +135,14 @@ static inline void mem_cgroup_end_migration(struct page *page)
 {
 }
 
+static inline void mem_cgroup_set_page_dirty(struct page *page)
+{
+}
+
+static inline void mem_cgroup_clear_page_dirty(struct page *page)
+{
+}
+
 static inline int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem)
 {
 	return 0;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 344a477..33d14b7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -49,6 +49,7 @@ enum mem_cgroup_stat_index {
 	 */
 	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
 	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as rss */
+	MEM_CGROUP_STAT_DIRTY,     /* # of dirty pages */
 	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
 	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
 
@@ -73,6 +74,14 @@ static void __mem_cgroup_stat_add_safe(struct mem_cgroup_stat *stat,
 	stat->cpustat[cpu].count[idx] += val;
 }
 
+static void __mem_cgroup_stat_add(struct mem_cgroup_stat *stat,
+		enum mem_cgroup_stat_index idx, int val)
+{
+	int cpu = get_cpu();
+	stat->cpustat[cpu].count[idx] += val;
+	put_cpu();
+}
+
 static s64 mem_cgroup_read_stat(struct mem_cgroup_stat *stat,
 		enum mem_cgroup_stat_index idx)
 {
@@ -164,6 +173,7 @@ struct page_cgroup {
 #define PAGE_CGROUP_FLAG_ACTIVE    (0x2)	/* page is active in this cgroup */
 #define PAGE_CGROUP_FLAG_FILE	   (0x4)	/* page is file system backed */
 #define PAGE_CGROUP_FLAG_UNEVICTABLE (0x8)	/* page is unevictableable */
+#define PAGE_CGROUP_FLAG_DIRTY     (0x10)	/* accounted as dirty */
 
 static int page_cgroup_nid(struct page_cgroup *pc)
 {
@@ -196,6 +206,9 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *mem, int flags,
 	else
 		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_RSS, val);
 
+	if (flags & PAGE_CGROUP_FLAG_DIRTY)
+		__mem_cgroup_stat_add_safe(stat, MEM_CGROUP_STAT_DIRTY, val);
+
 	if (charge)
 		__mem_cgroup_stat_add_safe(stat,
 				MEM_CGROUP_STAT_PGPGIN_COUNT, 1);
@@ -284,6 +297,7 @@ static void __mem_cgroup_remove_list(struct mem_cgroup_per_zone *mz,
 {
 	int lru = LRU_BASE;
 
+	VM_BUG_ON(!page_cgroup_locked(pc->page));
 	if (pc->flags & PAGE_CGROUP_FLAG_UNEVICTABLE)
 		lru = LRU_UNEVICTABLE;
 	else {
@@ -304,6 +318,7 @@ static void __mem_cgroup_add_list(struct mem_cgroup_per_zone *mz,
 {
 	int lru = LRU_BASE;
 
+	VM_BUG_ON(!page_cgroup_locked(pc->page));
 	if (pc->flags & PAGE_CGROUP_FLAG_UNEVICTABLE)
 		lru = LRU_UNEVICTABLE;
 	else {
@@ -328,6 +343,8 @@ static void __mem_cgroup_move_lists(struct page_cgroup *pc, enum lru_list lru)
 	enum lru_list from = unevictable ? LRU_UNEVICTABLE :
 				(LRU_FILE * !!file + !!active);
 
+	VM_BUG_ON(!page_cgroup_locked(pc->page));
+
 	if (lru == from)
 		return;
 
@@ -485,7 +502,10 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 		if (PageUnevictable(page) ||
 		    (PageActive(page) && !active) ||
 		    (!PageActive(page) && active)) {
-			__mem_cgroup_move_lists(pc, page_lru(page));
+			if (try_lock_page_cgroup(page)) {
+				__mem_cgroup_move_lists(pc, page_lru(page));
+				unlock_page_cgroup(page);
+			}
 			continue;
 		}
 
@@ -772,6 +792,38 @@ void mem_cgroup_end_migration(struct page *newpage)
 		mem_cgroup_uncharge_page(newpage);
 }
 
+void mem_cgroup_set_page_dirty(struct page *pg)
+{
+	struct page_cgroup *pc;
+
+	lock_page_cgroup(pg);
+	pc = page_get_page_cgroup(pg);
+	if (pc != NULL && (pc->flags & PAGE_CGROUP_FLAG_DIRTY) == 0) {
+		struct mem_cgroup *mem = pc->mem_cgroup;
+		struct mem_cgroup_stat *stat = &mem->stat;
+
+		pc->flags |= PAGE_CGROUP_FLAG_DIRTY;
+		__mem_cgroup_stat_add(stat, MEM_CGROUP_STAT_DIRTY, 1);
+	}
+	unlock_page_cgroup(pg);
+}
+
+void mem_cgroup_clear_page_dirty(struct page *pg)
+{
+	struct page_cgroup *pc;
+
+	lock_page_cgroup(pg);
+	pc = page_get_page_cgroup(pg);
+	if (pc != NULL && (pc->flags & PAGE_CGROUP_FLAG_DIRTY) != 0) {
+		struct mem_cgroup *mem = pc->mem_cgroup;
+		struct mem_cgroup_stat *stat = &mem->stat;
+
+		pc->flags &= ~PAGE_CGROUP_FLAG_DIRTY;
+		__mem_cgroup_stat_add(stat, MEM_CGROUP_STAT_DIRTY, -1);
+	}
+	unlock_page_cgroup(pg);
+}
+
 /*
  * A call to try to shrink memory usage under specified resource controller.
  * This is typically used for page reclaiming for shmem for reducing side
@@ -957,6 +1009,7 @@ static const struct mem_cgroup_stat_desc {
 } mem_cgroup_stat_desc[] = {
 	[MEM_CGROUP_STAT_CACHE] = { "cache", PAGE_SIZE, },
 	[MEM_CGROUP_STAT_RSS] = { "rss", PAGE_SIZE, },
+	[MEM_CGROUP_STAT_DIRTY] = { "dirty", 1, },
 	[MEM_CGROUP_STAT_PGPGIN_COUNT] = {"pgpgin", 1, },
 	[MEM_CGROUP_STAT_PGPGOUT_COUNT] = {"pgpgout", 1, },
 };
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index c6d6088..14dc9af 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -34,6 +34,7 @@
 #include <linux/syscalls.h>
 #include <linux/buffer_head.h>
 #include <linux/pagevec.h>
+#include <linux/memcontrol.h>
 
 /*
  * The maximum number of pages to writeout in a single bdflush/kupdate
@@ -1081,6 +1082,8 @@ int __set_page_dirty_nobuffers(struct page *page)
 		struct address_space *mapping = page_mapping(page);
 		struct address_space *mapping2;
 
+		mem_cgroup_set_page_dirty(page);
+
 		if (!mapping)
 			return 1;
 
@@ -1138,8 +1141,10 @@ static int __set_page_dirty(struct page *page)
 		return (*spd)(page);
 	}
 	if (!PageDirty(page)) {
-		if (!TestSetPageDirty(page))
+		if (!TestSetPageDirty(page)) {
+			mem_cgroup_set_page_dirty(page);
 			return 1;
+		}
 	}
 	return 0;
 }
@@ -1234,6 +1239,7 @@ int clear_page_dirty_for_io(struct page *page)
 		 * for more comments.
 		 */
 		if (TestClearPageDirty(page)) {
+			mem_cgroup_clear_page_dirty(page);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
@@ -1241,7 +1247,11 @@ int clear_page_dirty_for_io(struct page *page)
 		}
 		return 0;
 	}
-	return TestClearPageDirty(page);
+	if (TestClearPageDirty(page)) {
+		mem_cgroup_clear_page_dirty(page);
+		return 1;
+	}
+	return 0;
 }
 EXPORT_SYMBOL(clear_page_dirty_for_io);
 
diff --git a/mm/truncate.c b/mm/truncate.c
index 4d129a5..9b1e215 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -18,6 +18,7 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/buffer_head.h>	/* grr. try_to_release_page,
 				   do_invalidatepage */
+#include <linux/memcontrol.h>
 #include "internal.h"
 
 
@@ -72,6 +73,8 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
 {
 	if (TestClearPageDirty(page)) {
 		struct address_space *mapping = page->mapping;
+
+		mem_cgroup_clear_page_dirty(page);
 		if (mapping && mapping_cap_account_dirty(mapping)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
