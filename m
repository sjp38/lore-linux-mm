Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1F185829A8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 17:14:18 -0400 (EDT)
Received: by qkx62 with SMTP id 62so22130355qkx.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:14:18 -0700 (PDT)
Received: from mail-qk0-x22e.google.com (mail-qk0-x22e.google.com. [2607:f8b0:400d:c09::22e])
        by mx.google.com with ESMTPS id 91si2849620qks.92.2015.05.22.14.14.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 14:14:16 -0700 (PDT)
Received: by qkx62 with SMTP id 62so22129851qkx.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 14:14:16 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 02/51] memcg: add per cgroup dirty page accounting
Date: Fri, 22 May 2015 17:13:16 -0400
Message-Id: <1432329245-5844-3-git-send-email-tj@kernel.org>
In-Reply-To: <1432329245-5844-1-git-send-email-tj@kernel.org>
References: <1432329245-5844-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, khlebnikov@yandex-team.ru, Sha Zhengju <handai.szj@gmail.com>, Tejun Heo <tj@kernel.org>

From: Greg Thelen <gthelen@google.com>

When modifying PG_Dirty on cached file pages, update the new
MEM_CGROUP_STAT_DIRTY counter.  This is done in the same places where
global NR_FILE_DIRTY is managed.  The new memcg stat is visible in the
per memcg memory.stat cgroupfs file.  The most recent past attempt at
this was http://thread.gmane.org/gmane.linux.kernel.cgroups/8632

The new accounting supports future efforts to add per cgroup dirty
page throttling and writeback.  It also helps an administrator break
down a container's memory usage and provides evidence to understand
memcg oom kills (the new dirty count is included in memcg oom kill
messages).

The ability to move page accounting between memcg
(memory.move_charge_at_immigrate) makes this accounting more
complicated than the global counter.  The existing
mem_cgroup_{begin,end}_page_stat() lock is used to serialize move
accounting with stat updates.
Typical update operation:
	memcg = mem_cgroup_begin_page_stat(page)
	if (TestSetPageDirty()) {
		[...]
		mem_cgroup_update_page_stat(memcg)
	}
	mem_cgroup_end_page_stat(memcg)

Summary of mem_cgroup_end_page_stat() overhead:
- Without CONFIG_MEMCG it's a no-op
- With CONFIG_MEMCG and no inter memcg task movement, it's just
  rcu_read_lock()
- With CONFIG_MEMCG and inter memcg  task movement, it's
  rcu_read_lock() + spin_lock_irqsave()

A memcg parameter is added to several routines because their callers
now grab mem_cgroup_begin_page_stat() which returns the memcg later
needed by for mem_cgroup_update_page_stat().

Because mem_cgroup_begin_page_stat() may disable interrupts, some
adjustments are needed:
- move __mark_inode_dirty() from __set_page_dirty() to its caller.
  __mark_inode_dirty() locking does not want interrupts disabled.
- use spin_lock_irqsave(tree_lock) rather than spin_lock_irq() in
  __delete_from_page_cache(), replace_page_cache_page(),
  invalidate_complete_page2(), and __remove_mapping().

   text    data     bss      dec    hex filename
8925147 1774832 1785856 12485835 be84cb vmlinux-!CONFIG_MEMCG-before
8925339 1774832 1785856 12486027 be858b vmlinux-!CONFIG_MEMCG-after
                            +192 text bytes
8965977 1784992 1785856 12536825 bf4bf9 vmlinux-CONFIG_MEMCG-before
8966750 1784992 1785856 12537598 bf4efe vmlinux-CONFIG_MEMCG-after
                            +773 text bytes

Performance tests run on v4.0-rc1-36-g4f671fe2f952.  Lower is better for
all metrics, they're all wall clock or cycle counts.  The read and write
fault benchmarks just measure fault time, they do not include I/O time.

* CONFIG_MEMCG not set:
                            baseline                              patched
  kbuild                 1m25.030000(+-0.088% 3 samples)       1m25.426667(+-0.120% 3 samples)
  dd write 100 MiB          0.859211561 +-15.10%                  0.874162885 +-15.03%
  dd write 200 MiB          1.670653105 +-17.87%                  1.669384764 +-11.99%
  dd write 1000 MiB         8.434691190 +-14.15%                  8.474733215 +-14.77%
  read fault cycles       254.0(+-0.000% 10 samples)            253.0(+-0.000% 10 samples)
  write fault cycles     2021.2(+-3.070% 10 samples)           1984.5(+-1.036% 10 samples)

* CONFIG_MEMCG=y root_memcg:
                            baseline                              patched
  kbuild                 1m25.716667(+-0.105% 3 samples)       1m25.686667(+-0.153% 3 samples)
  dd write 100 MiB          0.855650830 +-14.90%                  0.887557919 +-14.90%
  dd write 200 MiB          1.688322953 +-12.72%                  1.667682724 +-13.33%
  dd write 1000 MiB         8.418601605 +-14.30%                  8.673532299 +-15.00%
  read fault cycles       266.0(+-0.000% 10 samples)            266.0(+-0.000% 10 samples)
  write fault cycles     2051.7(+-1.349% 10 samples)           2049.6(+-1.686% 10 samples)

* CONFIG_MEMCG=y non-root_memcg:
                            baseline                              patched
  kbuild                 1m26.120000(+-0.273% 3 samples)       1m25.763333(+-0.127% 3 samples)
  dd write 100 MiB          0.861723964 +-15.25%                  0.818129350 +-14.82%
  dd write 200 MiB          1.669887569 +-13.30%                  1.698645885 +-13.27%
  dd write 1000 MiB         8.383191730 +-14.65%                  8.351742280 +-14.52%
  read fault cycles       265.7(+-0.172% 10 samples)            267.0(+-0.000% 10 samples)
  write fault cycles     2070.6(+-1.512% 10 samples)           2084.4(+-2.148% 10 samples)

As expected anon page faults are not affected by this patch.

tj: Updated to apply on top of the recent cancel_dirty_page() changes.

Signed-off-by: Sha Zhengju <handai.szj@gmail.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Tejun Heo <tj@kernel.org>
---
 Documentation/cgroups/memory.txt |  1 +
 fs/buffer.c                      | 34 +++++++++++++++++++++------
 fs/xfs/xfs_aops.c                | 12 ++++++++--
 include/linux/memcontrol.h       |  1 +
 include/linux/mm.h               |  6 +++--
 include/linux/pagemap.h          |  3 ++-
 mm/filemap.c                     | 31 +++++++++++++++++--------
 mm/memcontrol.c                  | 24 ++++++++++++++++++-
 mm/page-writeback.c              | 50 +++++++++++++++++++++++++++++++++-------
 mm/rmap.c                        |  2 ++
 mm/truncate.c                    | 14 +++++++----
 mm/vmscan.c                      | 17 ++++++++++----
 12 files changed, 156 insertions(+), 39 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index f456b43..ff71e16 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -493,6 +493,7 @@ pgpgin		- # of charging events to the memory cgroup. The charging
 pgpgout		- # of uncharging events to the memory cgroup. The uncharging
 		event happens each time a page is unaccounted from the cgroup.
 swap		- # of bytes of swap usage
+dirty		- # of bytes that are waiting to get written back to the disk.
 writeback	- # of bytes of file/anon cache that are queued for syncing to
 		disk.
 inactive_anon	- # of bytes of anonymous and swap cache memory on inactive
diff --git a/fs/buffer.c b/fs/buffer.c
index e776bec..c8aecf5 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -623,21 +623,22 @@ EXPORT_SYMBOL(mark_buffer_dirty_inode);
  *
  * If warn is true, then emit a warning if the page is not uptodate and has
  * not been truncated.
+ *
+ * The caller must hold mem_cgroup_begin_page_stat() lock.
  */
-static void __set_page_dirty(struct page *page,
-		struct address_space *mapping, int warn)
+static void __set_page_dirty(struct page *page, struct address_space *mapping,
+			     struct mem_cgroup *memcg, int warn)
 {
 	unsigned long flags;
 
 	spin_lock_irqsave(&mapping->tree_lock, flags);
 	if (page->mapping) {	/* Race with truncate? */
 		WARN_ON_ONCE(warn && !PageUptodate(page));
-		account_page_dirtied(page, mapping);
+		account_page_dirtied(page, mapping, memcg);
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 	}
 	spin_unlock_irqrestore(&mapping->tree_lock, flags);
-	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 }
 
 /*
@@ -668,6 +669,7 @@ static void __set_page_dirty(struct page *page,
 int __set_page_dirty_buffers(struct page *page)
 {
 	int newly_dirty;
+	struct mem_cgroup *memcg;
 	struct address_space *mapping = page_mapping(page);
 
 	if (unlikely(!mapping))
@@ -683,11 +685,22 @@ int __set_page_dirty_buffers(struct page *page)
 			bh = bh->b_this_page;
 		} while (bh != head);
 	}
+	/*
+	 * Use mem_group_begin_page_stat() to keep PageDirty synchronized with
+	 * per-memcg dirty page counters.
+	 */
+	memcg = mem_cgroup_begin_page_stat(page);
 	newly_dirty = !TestSetPageDirty(page);
 	spin_unlock(&mapping->private_lock);
 
 	if (newly_dirty)
-		__set_page_dirty(page, mapping, 1);
+		__set_page_dirty(page, mapping, memcg, 1);
+
+	mem_cgroup_end_page_stat(memcg);
+
+	if (newly_dirty)
+		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
+
 	return newly_dirty;
 }
 EXPORT_SYMBOL(__set_page_dirty_buffers);
@@ -1158,11 +1171,18 @@ void mark_buffer_dirty(struct buffer_head *bh)
 
 	if (!test_set_buffer_dirty(bh)) {
 		struct page *page = bh->b_page;
+		struct address_space *mapping = NULL;
+		struct mem_cgroup *memcg;
+
+		memcg = mem_cgroup_begin_page_stat(page);
 		if (!TestSetPageDirty(page)) {
-			struct address_space *mapping = page_mapping(page);
+			mapping = page_mapping(page);
 			if (mapping)
-				__set_page_dirty(page, mapping, 0);
+				__set_page_dirty(page, mapping, memcg, 0);
 		}
+		mem_cgroup_end_page_stat(memcg);
+		if (mapping)
+			__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 	}
 }
 EXPORT_SYMBOL(mark_buffer_dirty);
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 095f94c..e5099f2 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1873,6 +1873,7 @@ xfs_vm_set_page_dirty(
 	loff_t			end_offset;
 	loff_t			offset;
 	int			newly_dirty;
+	struct mem_cgroup	*memcg;
 
 	if (unlikely(!mapping))
 		return !TestSetPageDirty(page);
@@ -1892,6 +1893,11 @@ xfs_vm_set_page_dirty(
 			offset += 1 << inode->i_blkbits;
 		} while (bh != head);
 	}
+	/*
+	 * Use mem_group_begin_page_stat() to keep PageDirty synchronized with
+	 * per-memcg dirty page counters.
+	 */
+	memcg = mem_cgroup_begin_page_stat(page);
 	newly_dirty = !TestSetPageDirty(page);
 	spin_unlock(&mapping->private_lock);
 
@@ -1902,13 +1908,15 @@ xfs_vm_set_page_dirty(
 		spin_lock_irqsave(&mapping->tree_lock, flags);
 		if (page->mapping) {	/* Race with truncate? */
 			WARN_ON_ONCE(!PageUptodate(page));
-			account_page_dirtied(page, mapping);
+			account_page_dirtied(page, mapping, memcg);
 			radix_tree_tag_set(&mapping->page_tree,
 					page_index(page), PAGECACHE_TAG_DIRTY);
 		}
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
-		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 	}
+	mem_cgroup_end_page_stat(memcg);
+	if (newly_dirty)
+		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 	return newly_dirty;
 }
 
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 72dff5f..5fe6411 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -41,6 +41,7 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_RSS,		/* # of pages charged as anon rss */
 	MEM_CGROUP_STAT_RSS_HUGE,	/* # of pages charged as anon huge */
 	MEM_CGROUP_STAT_FILE_MAPPED,	/* # of pages charged as file rss */
+	MEM_CGROUP_STAT_DIRTY,          /* # of dirty pages in page cache */
 	MEM_CGROUP_STAT_WRITEBACK,	/* # of pages under writeback */
 	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
 	MEM_CGROUP_STAT_NSTATS,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a83cf3a..f48d979 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1211,8 +1211,10 @@ int __set_page_dirty_nobuffers(struct page *page);
 int __set_page_dirty_no_writeback(struct page *page);
 int redirty_page_for_writepage(struct writeback_control *wbc,
 				struct page *page);
-void account_page_dirtied(struct page *page, struct address_space *mapping);
-void account_page_cleaned(struct page *page, struct address_space *mapping);
+void account_page_dirtied(struct page *page, struct address_space *mapping,
+			  struct mem_cgroup *memcg);
+void account_page_cleaned(struct page *page, struct address_space *mapping,
+			  struct mem_cgroup *memcg);
 int set_page_dirty(struct page *page);
 int set_page_dirty_lock(struct page *page);
 void cancel_dirty_page(struct page *page);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 4b3736f..fb0814c 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -651,7 +651,8 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 				pgoff_t index, gfp_t gfp_mask);
 extern void delete_from_page_cache(struct page *page);
-extern void __delete_from_page_cache(struct page *page, void *shadow);
+extern void __delete_from_page_cache(struct page *page, void *shadow,
+				     struct mem_cgroup *memcg);
 int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask);
 
 /*
diff --git a/mm/filemap.c b/mm/filemap.c
index 6bf5e42..7b1443d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -100,6 +100,7 @@
  *    ->tree_lock		(page_remove_rmap->set_page_dirty)
  *    bdi.wb->list_lock		(page_remove_rmap->set_page_dirty)
  *    ->inode->i_lock		(page_remove_rmap->set_page_dirty)
+ *    ->memcg->move_lock	(page_remove_rmap->mem_cgroup_begin_page_stat)
  *    bdi.wb->list_lock		(zap_pte_range->set_page_dirty)
  *    ->inode->i_lock		(zap_pte_range->set_page_dirty)
  *    ->private_lock		(zap_pte_range->__set_page_dirty_buffers)
@@ -174,9 +175,11 @@ static void page_cache_tree_delete(struct address_space *mapping,
 /*
  * Delete a page from the page cache and free it. Caller has to make
  * sure the page is locked and that nobody else uses it - or that usage
- * is safe.  The caller must hold the mapping's tree_lock.
+ * is safe.  The caller must hold the mapping's tree_lock and
+ * mem_cgroup_begin_page_stat().
  */
-void __delete_from_page_cache(struct page *page, void *shadow)
+void __delete_from_page_cache(struct page *page, void *shadow,
+			      struct mem_cgroup *memcg)
 {
 	struct address_space *mapping = page->mapping;
 
@@ -210,7 +213,7 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 	 * anyway will be cleared before returning page into buddy allocator.
 	 */
 	if (WARN_ON_ONCE(PageDirty(page)))
-		account_page_cleaned(page, mapping);
+		account_page_cleaned(page, mapping, memcg);
 }
 
 /**
@@ -224,14 +227,20 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 void delete_from_page_cache(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
+	struct mem_cgroup *memcg;
+	unsigned long flags;
+
 	void (*freepage)(struct page *);
 
 	BUG_ON(!PageLocked(page));
 
 	freepage = mapping->a_ops->freepage;
-	spin_lock_irq(&mapping->tree_lock);
-	__delete_from_page_cache(page, NULL);
-	spin_unlock_irq(&mapping->tree_lock);
+
+	memcg = mem_cgroup_begin_page_stat(page);
+	spin_lock_irqsave(&mapping->tree_lock, flags);
+	__delete_from_page_cache(page, NULL, memcg);
+	spin_unlock_irqrestore(&mapping->tree_lock, flags);
+	mem_cgroup_end_page_stat(memcg);
 
 	if (freepage)
 		freepage(page);
@@ -470,6 +479,8 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 	if (!error) {
 		struct address_space *mapping = old->mapping;
 		void (*freepage)(struct page *);
+		struct mem_cgroup *memcg;
+		unsigned long flags;
 
 		pgoff_t offset = old->index;
 		freepage = mapping->a_ops->freepage;
@@ -478,15 +489,17 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		new->mapping = mapping;
 		new->index = offset;
 
-		spin_lock_irq(&mapping->tree_lock);
-		__delete_from_page_cache(old, NULL);
+		memcg = mem_cgroup_begin_page_stat(old);
+		spin_lock_irqsave(&mapping->tree_lock, flags);
+		__delete_from_page_cache(old, NULL, memcg);
 		error = radix_tree_insert(&mapping->page_tree, offset, new);
 		BUG_ON(error);
 		mapping->nrpages++;
 		__inc_zone_page_state(new, NR_FILE_PAGES);
 		if (PageSwapBacked(new))
 			__inc_zone_page_state(new, NR_SHMEM);
-		spin_unlock_irq(&mapping->tree_lock);
+		spin_unlock_irqrestore(&mapping->tree_lock, flags);
+		mem_cgroup_end_page_stat(memcg);
 		mem_cgroup_migrate(old, new, true);
 		radix_tree_preload_end();
 		if (freepage)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 14c2f20..c23c1a3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -90,6 +90,7 @@ static const char * const mem_cgroup_stat_names[] = {
 	"rss",
 	"rss_huge",
 	"mapped_file",
+	"dirty",
 	"writeback",
 	"swap",
 };
@@ -2011,6 +2012,7 @@ struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page)
 
 	return memcg;
 }
+EXPORT_SYMBOL(mem_cgroup_begin_page_stat);
 
 /**
  * mem_cgroup_end_page_stat - finish a page state statistics transaction
@@ -2029,6 +2031,7 @@ void mem_cgroup_end_page_stat(struct mem_cgroup *memcg)
 
 	rcu_read_unlock();
 }
+EXPORT_SYMBOL(mem_cgroup_end_page_stat);
 
 /**
  * mem_cgroup_update_page_stat - update page state statistics
@@ -4746,6 +4749,7 @@ static int mem_cgroup_move_account(struct page *page,
 {
 	unsigned long flags;
 	int ret;
+	bool anon;
 
 	VM_BUG_ON(from == to);
 	VM_BUG_ON_PAGE(PageLRU(page), page);
@@ -4771,15 +4775,33 @@ static int mem_cgroup_move_account(struct page *page,
 	if (page->mem_cgroup != from)
 		goto out_unlock;
 
+	anon = PageAnon(page);
+
 	spin_lock_irqsave(&from->move_lock, flags);
 
-	if (!PageAnon(page) && page_mapped(page)) {
+	if (!anon && page_mapped(page)) {
 		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
 			       nr_pages);
 		__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED],
 			       nr_pages);
 	}
 
+	/*
+	 * move_lock grabbed above and caller set from->moving_account, so
+	 * mem_cgroup_update_page_stat() will serialize updates to PageDirty.
+	 * So mapping should be stable for dirty pages.
+	 */
+	if (!anon && PageDirty(page)) {
+		struct address_space *mapping = page_mapping(page);
+
+		if (mapping_cap_account_dirty(mapping)) {
+			__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_DIRTY],
+				       nr_pages);
+			__this_cpu_add(to->stat->count[MEM_CGROUP_STAT_DIRTY],
+				       nr_pages);
+		}
+	}
+
 	if (PageWriteback(page)) {
 		__this_cpu_sub(from->stat->count[MEM_CGROUP_STAT_WRITEBACK],
 			       nr_pages);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 227b867..bdeecad 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2090,15 +2090,20 @@ int __set_page_dirty_no_writeback(struct page *page)
 
 /*
  * Helper function for set_page_dirty family.
+ *
+ * Caller must hold mem_cgroup_begin_page_stat().
+ *
  * NOTE: This relies on being atomic wrt interrupts.
  */
-void account_page_dirtied(struct page *page, struct address_space *mapping)
+void account_page_dirtied(struct page *page, struct address_space *mapping,
+			  struct mem_cgroup *memcg)
 {
 	trace_writeback_dirty_page(page, mapping);
 
 	if (mapping_cap_account_dirty(mapping)) {
 		struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
 
+		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_bdi_stat(bdi, BDI_RECLAIMABLE);
@@ -2112,10 +2117,14 @@ EXPORT_SYMBOL(account_page_dirtied);
 
 /*
  * Helper function for deaccounting dirty page without writeback.
+ *
+ * Caller must hold mem_cgroup_begin_page_stat().
  */
-void account_page_cleaned(struct page *page, struct address_space *mapping)
+void account_page_cleaned(struct page *page, struct address_space *mapping,
+			  struct mem_cgroup *memcg)
 {
 	if (mapping_cap_account_dirty(mapping)) {
+		mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
 		dec_zone_page_state(page, NR_FILE_DIRTY);
 		dec_bdi_stat(inode_to_bdi(mapping->host), BDI_RECLAIMABLE);
 		task_io_account_cancelled_write(PAGE_CACHE_SIZE);
@@ -2136,26 +2145,34 @@ void account_page_cleaned(struct page *page, struct address_space *mapping)
  */
 int __set_page_dirty_nobuffers(struct page *page)
 {
+	struct mem_cgroup *memcg;
+
+	memcg = mem_cgroup_begin_page_stat(page);
 	if (!TestSetPageDirty(page)) {
 		struct address_space *mapping = page_mapping(page);
 		unsigned long flags;
 
-		if (!mapping)
+		if (!mapping) {
+			mem_cgroup_end_page_stat(memcg);
 			return 1;
+		}
 
 		spin_lock_irqsave(&mapping->tree_lock, flags);
 		BUG_ON(page_mapping(page) != mapping);
 		WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
-		account_page_dirtied(page, mapping);
+		account_page_dirtied(page, mapping, memcg);
 		radix_tree_tag_set(&mapping->page_tree, page_index(page),
 				   PAGECACHE_TAG_DIRTY);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
+		mem_cgroup_end_page_stat(memcg);
+
 		if (mapping->host) {
 			/* !PageAnon && !swapper_space */
 			__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 		}
 		return 1;
 	}
+	mem_cgroup_end_page_stat(memcg);
 	return 0;
 }
 EXPORT_SYMBOL(__set_page_dirty_nobuffers);
@@ -2273,8 +2290,20 @@ EXPORT_SYMBOL(set_page_dirty_lock);
  */
 void cancel_dirty_page(struct page *page)
 {
-	if (TestClearPageDirty(page))
-		account_page_cleaned(page, page_mapping(page));
+	struct address_space *mapping = page_mapping(page);
+
+	if (mapping_cap_account_dirty(mapping)) {
+		struct mem_cgroup *memcg;
+
+		memcg = mem_cgroup_begin_page_stat(page);
+
+		if (TestClearPageDirty(page))
+			account_page_cleaned(page, mapping, memcg);
+
+		mem_cgroup_end_page_stat(memcg);
+	} else {
+		ClearPageDirty(page);
+	}
 }
 EXPORT_SYMBOL(cancel_dirty_page);
 
@@ -2295,6 +2324,8 @@ EXPORT_SYMBOL(cancel_dirty_page);
 int clear_page_dirty_for_io(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
+	struct mem_cgroup *memcg;
+	int ret = 0;
 
 	BUG_ON(!PageLocked(page));
 
@@ -2334,13 +2365,16 @@ int clear_page_dirty_for_io(struct page *page)
 		 * always locked coming in here, so we get the desired
 		 * exclusion.
 		 */
+		memcg = mem_cgroup_begin_page_stat(page);
 		if (TestClearPageDirty(page)) {
+			mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(inode_to_bdi(mapping->host),
 					BDI_RECLAIMABLE);
-			return 1;
+			ret = 1;
 		}
-		return 0;
+		mem_cgroup_end_page_stat(memcg);
+		return ret;
 	}
 	return TestClearPageDirty(page);
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index 24dd3f9..8fc556c 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -30,6 +30,8 @@
  *             swap_lock (in swap_duplicate, swap_info_get)
  *               mmlist_lock (in mmput, drain_mmlist and others)
  *               mapping->private_lock (in __set_page_dirty_buffers)
+ *                 mem_cgroup_{begin,end}_page_stat (memcg->move_lock)
+ *                   mapping->tree_lock (widely used)
  *               inode->i_lock (in set_page_dirty's __mark_inode_dirty)
  *               bdi.wb->list_lock (in set_page_dirty's __mark_inode_dirty)
  *                 sb_lock (within inode_lock in fs/fs-writeback.c)
diff --git a/mm/truncate.c b/mm/truncate.c
index 0c36025..76e35ad 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -510,19 +510,24 @@ EXPORT_SYMBOL(invalidate_mapping_pages);
 static int
 invalidate_complete_page2(struct address_space *mapping, struct page *page)
 {
+	struct mem_cgroup *memcg;
+	unsigned long flags;
+
 	if (page->mapping != mapping)
 		return 0;
 
 	if (page_has_private(page) && !try_to_release_page(page, GFP_KERNEL))
 		return 0;
 
-	spin_lock_irq(&mapping->tree_lock);
+	memcg = mem_cgroup_begin_page_stat(page);
+	spin_lock_irqsave(&mapping->tree_lock, flags);
 	if (PageDirty(page))
 		goto failed;
 
 	BUG_ON(page_has_private(page));
-	__delete_from_page_cache(page, NULL);
-	spin_unlock_irq(&mapping->tree_lock);
+	__delete_from_page_cache(page, NULL, memcg);
+	spin_unlock_irqrestore(&mapping->tree_lock, flags);
+	mem_cgroup_end_page_stat(memcg);
 
 	if (mapping->a_ops->freepage)
 		mapping->a_ops->freepage(page);
@@ -530,7 +535,8 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 	page_cache_release(page);	/* pagecache ref */
 	return 1;
 failed:
-	spin_unlock_irq(&mapping->tree_lock);
+	spin_unlock_irqrestore(&mapping->tree_lock, flags);
+	mem_cgroup_end_page_stat(memcg);
 	return 0;
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e8eadd..7582f9f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -579,10 +579,14 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 static int __remove_mapping(struct address_space *mapping, struct page *page,
 			    bool reclaimed)
 {
+	unsigned long flags;
+	struct mem_cgroup *memcg;
+
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
 
-	spin_lock_irq(&mapping->tree_lock);
+	memcg = mem_cgroup_begin_page_stat(page);
+	spin_lock_irqsave(&mapping->tree_lock, flags);
 	/*
 	 * The non racy check for a busy page.
 	 *
@@ -620,7 +624,8 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 		swp_entry_t swap = { .val = page_private(page) };
 		mem_cgroup_swapout(page, swap);
 		__delete_from_swap_cache(page);
-		spin_unlock_irq(&mapping->tree_lock);
+		spin_unlock_irqrestore(&mapping->tree_lock, flags);
+		mem_cgroup_end_page_stat(memcg);
 		swapcache_free(swap);
 	} else {
 		void (*freepage)(struct page *);
@@ -640,8 +645,9 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 		if (reclaimed && page_is_file_cache(page) &&
 		    !mapping_exiting(mapping))
 			shadow = workingset_eviction(mapping, page);
-		__delete_from_page_cache(page, shadow);
-		spin_unlock_irq(&mapping->tree_lock);
+		__delete_from_page_cache(page, shadow, memcg);
+		spin_unlock_irqrestore(&mapping->tree_lock, flags);
+		mem_cgroup_end_page_stat(memcg);
 
 		if (freepage != NULL)
 			freepage(page);
@@ -650,7 +656,8 @@ static int __remove_mapping(struct address_space *mapping, struct page *page,
 	return 1;
 
 cannot_free:
-	spin_unlock_irq(&mapping->tree_lock);
+	spin_unlock_irqrestore(&mapping->tree_lock, flags);
+	mem_cgroup_end_page_stat(memcg);
 	return 0;
 }
 
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
