Received: by yw-out-1718.google.com with SMTP id 5so231937ywm.26
        for <linux-mm@kvack.org>; Tue, 09 Sep 2008 08:38:42 -0700 (PDT)
Message-ID: <48C6987D.2050905@gmail.com>
Date: Tue, 09 Sep 2008 17:38:37 +0200
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: [RFC] [PATCH -mm] cgroup: limit the amount of dirty file pages
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Carl Henrik Lunde <chlunde@ping.uio.no>, Divyesh Shah <dpshah@google.com>, Naveen Gupta <ngupta@google.com>, =?ISO-8859-1?Q?Fernando_Luis_V=E1zquez_Cao?= <fernando@oss.ntt.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Hirokazu Takahashi <taka@valinux.co.jp>, Marco Innocenti <m.innocenti@cineca.it>, Satoshi UCHIDA <s-uchida@ap.jp.nec.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Matt Heaton <matt@bluehost.com>, David Radford <dradford@bluehost.com>, containers@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a totally experimental patch against 2.6.27-rc5-mm1.

It allows to control how much dirty file pages a cgroup can have at any
given time. This feature is supposed to be strictly connected to a
generic cgroup IO controller (see below).

Interface: a new entry "filedirty" is added to the file memory.stat,
reporting the number of dirty file pages (in pages), and a new file
memory.file_dirty_limit_in_pages is added in the cgroup filesystem to
show/set the current limit.

The overall design is the following.

The dirty file pages are accounted for each cgroup using the memory
controller statistics. The memory controller also allows to define an
upper bound on the number of dirty file pages. When this upper bound is
exceeded the tasks in the cgroup are forced to writeback dirty pages to
return within the cgroup limit.

With this functionality a generic cgroup IO controller can apply any
kind of limitation or shaping policy directly to the IO requests
(elevator, IO scheduler, ...) and it shouldn't care about how fast the
userspace apps are dirtying pages in memory generating a lot of
hard/slow to reclaim pages (or even potential OOM conditions), because
the apps will be actually throttled by the IO controller when they'll
start to writeback pages.

[ Honestly, I don't like this implementation in memcgroup. I'm using the
memcgroup statistics to account the dirty file pages, but I'm also
adding a variable to struct mem_cgroup to implement the dirty file pages
limit. So it seems it would be more appropriate a struct res_counter,
but I can't use res_counter_[un]charge() interface, because the dirty
file pages limit is a soft-limit and can be exceeded without any
problem; if it's exceeded the task is simply forced to perform a
writeback of the dirty pages to return back to the allowed dirty limit.
Suggestions are welcome. ]

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
---
 fs/buffer.c                |    1 +
 fs/reiser4/as_ops.c        |    4 ++-
 fs/reiser4/page_cache.c    |    4 ++-
 include/linux/memcontrol.h |   12 ++++++
 mm/filemap.c               |    1 +
 mm/memcontrol.c            |   83 ++++++++++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c        |   37 +++++++++++++++++++
 mm/truncate.c              |    2 +
 8 files changed, 142 insertions(+), 2 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 8274f5e..9c40a16 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -718,6 +718,7 @@ static int __set_page_dirty(struct page *page,
 		WARN_ON_ONCE(warn && !PageUptodate(page));
 
 		if (mapping_cap_account_dirty(mapping)) {
+			mem_cgroup_charge_file_dirty(page, 1);
 			__inc_zone_page_state(page, NR_FILE_DIRTY);
 			__inc_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
diff --git a/fs/reiser4/as_ops.c b/fs/reiser4/as_ops.c
index decb9eb..671432a 100644
--- a/fs/reiser4/as_ops.c
+++ b/fs/reiser4/as_ops.c
@@ -82,9 +82,11 @@ int reiser4_set_page_dirty(struct page *page)
 			/* check for race with truncate */
 			if (page->mapping) {
 				assert("vs-1652", page->mapping == mapping);
-				if (mapping_cap_account_dirty(mapping))
+				if (mapping_cap_account_dirty(mapping)) {
+					mem_cgroup_charge_file_dirty(page, 1);
 					inc_zone_page_state(page,
 							NR_FILE_DIRTY);
+				}
 				radix_tree_tag_set(&mapping->page_tree,
 						   page->index,
 						   PAGECACHE_TAG_REISER4_MOVED);
diff --git a/fs/reiser4/page_cache.c b/fs/reiser4/page_cache.c
index 654e7ae..2d5dfac 100644
--- a/fs/reiser4/page_cache.c
+++ b/fs/reiser4/page_cache.c
@@ -467,8 +467,10 @@ int reiser4_set_page_dirty_internal(struct page *page)
 	BUG_ON(mapping == NULL);
 
 	if (!TestSetPageDirty(page)) {
-		if (mapping_cap_account_dirty(mapping))
+		if (mapping_cap_account_dirty(mapping)) {
+			mem_cgroup_charge_file_dirty(page, 1);
 			inc_zone_page_state(page, NR_FILE_DIRTY);
+		}
 
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 	}
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ee1b2fc..6677097 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -29,6 +29,9 @@ struct mm_struct;
 
 #define page_reset_bad_cgroup(page)	((page)->page_cgroup = 0)
 
+extern void mem_cgroup_charge_file_dirty(struct page *page, int charge);
+extern s64 mem_cgroup_check_file_dirty(void);
+
 extern struct page_cgroup *page_get_page_cgroup(struct page *page);
 extern int mem_cgroup_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask);
@@ -132,6 +135,15 @@ static inline void mem_cgroup_end_migration(struct page *page)
 {
 }
 
+static inline void mem_cgroup_charge_file_dirty(struct page *page, int charge)
+{
+}
+
+static inline s64 mem_cgroup_check_file_dirty(void)
+{
+	return 0;
+}
+
 static inline int mem_cgroup_calc_mapped_ratio(struct mem_cgroup *mem)
 {
 	return 0;
diff --git a/mm/filemap.c b/mm/filemap.c
index 0df6e1f..ca20f51 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -131,6 +131,7 @@ void __remove_from_page_cache(struct page *page)
 	 * having removed the page entirely.
 	 */
 	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
+		mem_cgroup_charge_file_dirty(page, -1);
 		dec_zone_page_state(page, NR_FILE_DIRTY);
 		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 	}
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2979d22..55eb445 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -49,6 +49,7 @@ enum mem_cgroup_stat_index {
 	 */
 	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
 	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as rss */
+	MEM_CGROUP_STAT_FILE_DIRTY,	/* # of dirty pages in page cache */
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
@@ -133,6 +142,9 @@ struct mem_cgroup {
 	 * statistics.
 	 */
 	struct mem_cgroup_stat stat;
+
+	/* file dirty limit */
+	s64 file_dirty_limit;
 };
 static struct mem_cgroup init_mem_cgroup;
 
@@ -358,6 +370,52 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
 	return ret;
 }
 
+static struct mem_cgroup *get_mem_cgroup_from_page(struct page *page)
+{
+	struct page_cgroup *pc;
+	struct mem_cgroup *mem = NULL;
+
+	lock_page_cgroup(page);
+	pc = page_get_page_cgroup(page);
+	if (pc) {
+		css_get(&pc->mem_cgroup->css);
+		mem = pc->mem_cgroup;
+	}
+	unlock_page_cgroup(page);
+	return mem;
+}
+
+void mem_cgroup_charge_file_dirty(struct page *page, int charge)
+{
+	struct mem_cgroup *mem;
+
+	mem = get_mem_cgroup_from_page(page);
+	if (mem) {
+		__mem_cgroup_stat_add(&mem->stat, MEM_CGROUP_STAT_FILE_DIRTY,
+					charge);
+		css_put(&mem->css);
+	}
+}
+
+s64 mem_cgroup_check_file_dirty(void)
+{
+	struct mem_cgroup *mem;
+	s64 ret = 0;
+
+	rcu_read_lock();
+	mem = mem_cgroup_from_task(current);
+	if (likely(mem)) {
+		css_get(&mem->css);
+		ret = mem_cgroup_read_stat(&mem->stat,
+				MEM_CGROUP_STAT_FILE_DIRTY);
+		ret -= mem->file_dirty_limit;
+		css_put(&mem->css);
+	}
+	rcu_read_unlock();
+
+	return (ret > 0) ? ret : 0;
+}
+
 /*
  * This routine assumes that the appropriate zone's lru lock is already held
  */
@@ -953,12 +1011,31 @@ static int mem_force_empty_write(struct cgroup *cont, unsigned int event)
 	return mem_cgroup_force_empty(mem_cgroup_from_cont(cont));
 }
 
+static s64 mem_cgroup_file_dirty_read(struct cgroup *cont, struct cftype *cft)
+{
+	return mem_cgroup_from_cont(cont)->file_dirty_limit;
+}
+
+static int mem_cgroup_file_dirty_write(struct cgroup *cont, struct cftype *cft,
+			const char *buffer)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	long long val;
+	int ret;
+
+	ret = strict_strtoll(buffer, 10, &val);
+	if (!ret)
+		mem->file_dirty_limit = val;
+	return ret;
+}
+
 static const struct mem_cgroup_stat_desc {
 	const char *msg;
 	u64 unit;
 } mem_cgroup_stat_desc[] = {
 	[MEM_CGROUP_STAT_CACHE] = { "cache", PAGE_SIZE, },
 	[MEM_CGROUP_STAT_RSS] = { "rss", PAGE_SIZE, },
+	[MEM_CGROUP_STAT_FILE_DIRTY] = { "filedirty", 1, },
 	[MEM_CGROUP_STAT_PGPGIN_COUNT] = {"pgpgin", 1, },
 	[MEM_CGROUP_STAT_PGPGOUT_COUNT] = {"pgpgout", 1, },
 };
@@ -1023,6 +1100,11 @@ static struct cftype mem_cgroup_files[] = {
 		.read_u64 = mem_cgroup_read,
 	},
 	{
+		.name = "file_dirty_limit_in_pages",
+		.write_string = mem_cgroup_file_dirty_write,
+		.read_s64 = mem_cgroup_file_dirty_read,
+	},
+	{
 		.name = "failcnt",
 		.private = RES_FAILCNT,
 		.trigger = mem_cgroup_reset,
@@ -1114,6 +1196,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	}
 
 	res_counter_init(&mem->res);
+	mem->file_dirty_limit = LLONG_MAX;
 
 	for_each_node_state(node, N_POSSIBLE)
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index c6d6088..ae89950 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -25,6 +25,7 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/blkdev.h>
 #include <linux/mpage.h>
+#include <linux/memcontrol.h>
 #include <linux/rmap.h>
 #include <linux/percpu.h>
 #include <linux/notifier.h>
@@ -412,6 +413,34 @@ get_dirty_limits(long *pbackground, long *pdirty, long *pbdi_dirty,
 	}
 }
 
+static void mem_cgroup_balance_dirty_pages(struct address_space *mapping,
+				long long dirty_pages)
+{
+	struct writeback_control wbc = {
+		.bdi		= mapping->backing_dev_info,
+		.sync_mode	= WB_SYNC_NONE,
+		.older_than_this = NULL,
+		.nr_to_write	= 0,
+		.range_cyclic	= 1,
+	};
+	unsigned long write_chunk = sync_writeback_pages();
+
+	while (dirty_pages > 0) {
+		wbc.more_io = 0;
+		wbc.encountered_congestion = 0;
+		wbc.nr_to_write = write_chunk;
+		wbc.pages_skipped = 0;
+		writeback_inodes(&wbc);
+		dirty_pages -= write_chunk - wbc.nr_to_write;
+		if (wbc.nr_to_write > 0 || wbc.pages_skipped > 0) {
+			if (wbc.encountered_congestion || wbc.more_io)
+				congestion_wait(WRITE, HZ/10);
+			else
+				break;
+		}
+	}
+}
+
 /*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
@@ -556,6 +585,12 @@ void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
 	static DEFINE_PER_CPU(unsigned long, ratelimits) = 0;
 	unsigned long ratelimit;
 	unsigned long *p;
+	long long memcg_dirty_pages = mem_cgroup_check_file_dirty();
+
+	if (memcg_dirty_pages) {
+		mem_cgroup_balance_dirty_pages(mapping, memcg_dirty_pages);
+		return;
+	}
 
 	ratelimit = ratelimit_pages;
 	if (mapping->backing_dev_info->dirty_exceeded)
@@ -1090,6 +1125,7 @@ int __set_page_dirty_nobuffers(struct page *page)
 			BUG_ON(mapping2 != mapping);
 			WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
 			if (mapping_cap_account_dirty(mapping)) {
+				mem_cgroup_charge_file_dirty(page, 1);
 				__inc_zone_page_state(page, NR_FILE_DIRTY);
 				__inc_bdi_stat(mapping->backing_dev_info,
 						BDI_RECLAIMABLE);
@@ -1234,6 +1270,7 @@ int clear_page_dirty_for_io(struct page *page)
 		 * for more comments.
 		 */
 		if (TestClearPageDirty(page)) {
+			mem_cgroup_charge_file_dirty(page, -1);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
diff --git a/mm/truncate.c b/mm/truncate.c
index e2bdd70..8ca6893 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -72,7 +72,9 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
 {
 	if (TestClearPageDirty(page)) {
 		struct address_space *mapping = page->mapping;
+
 		if (mapping && mapping_cap_account_dirty(mapping)) {
+			mem_cgroup_charge_file_dirty(page, -1);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
