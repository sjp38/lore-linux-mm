Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 33AB96B006C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 13:49:17 -0500 (EST)
Received: by mail-lb0-f181.google.com with SMTP id u14so5339192lbd.12
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 10:49:16 -0800 (PST)
Received: from forward-corp1m.cmail.yandex.net (forward-corp1m.cmail.yandex.net. [2a02:6b8:b030::69])
        by mx.google.com with ESMTPS id v2si2198688laj.133.2015.01.15.10.49.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 10:49:16 -0800 (PST)
Subject: [PATCH 1/6] memcg: inode-based dirty and writeback pages accounting
From: Konstantin Khebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 15 Jan 2015 21:49:11 +0300
Message-ID: <20150115184911.10450.62353.stgit@buzz>
In-Reply-To: <20150115180242.10450.92.stgit@buzz>
References: <20150115180242.10450.92.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: Roman Gushchin <klamm@yandex-team.ru>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org, koct9i@gmail.com

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

This patch links memory cgroup into vfs layer and assigns owner
memcg for each inode which has dirty or writeback pages within.
The main goal of this is controlling dirty memory size.

Accounting dirty memory in per-inode manner is much easier (we've
got locking for free) and more effective because we could use this
information in in writeback and writeout only inodes which belongs
to cgroup where amount of dirty memory is beyond of thresholds.

Interface: fs_dirty and fs_writeback in memory.stat attribute.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 fs/inode.c                 |    1 
 include/linux/fs.h         |   11 ++++
 include/linux/memcontrol.h |   13 +++++
 mm/memcontrol.c            |  118 ++++++++++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c        |    7 ++-
 mm/truncate.c              |    1 
 6 files changed, 150 insertions(+), 1 deletion(-)

diff --git a/fs/inode.c b/fs/inode.c
index aa149e7..979a548 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -559,6 +559,7 @@ static void evict(struct inode *inode)
 		bd_forget(inode);
 	if (S_ISCHR(inode->i_mode) && inode->i_cdev)
 		cd_forget(inode);
+	mem_cgroup_forget_mapping(&inode->i_data);
 
 	remove_inode_hash(inode);
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 42efe13..ee2e3c0 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -413,6 +413,9 @@ struct address_space {
 	spinlock_t		private_lock;	/* for use by the address_space */
 	struct list_head	private_list;	/* ditto */
 	void			*private_data;	/* ditto */
+#ifdef CONFIG_MEMCG
+	struct mem_cgroup __rcu	*i_memcg;	/* protected by ->tree_lock */
+#endif
 } __attribute__((aligned(sizeof(long))));
 	/*
 	 * On most architectures that alignment is already the case; but
@@ -489,6 +492,14 @@ static inline void i_mmap_unlock_read(struct address_space *mapping)
 }
 
 /*
+ * Returns bitmap with all page-cache radix-tree tags
+ */
+static inline unsigned mapping_tags(struct address_space *mapping)
+{
+	return (__force unsigned)mapping->page_tree.gfp_mask >> __GFP_BITS_SHIFT;
+}
+
+/*
  * Might pages of this file be mapped into userspace?
  */
 static inline int mapping_mapped(struct address_space *mapping)
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 7c95af8..b281333 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -173,6 +173,12 @@ static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
 void mem_cgroup_split_huge_fixup(struct page *head);
 #endif
 
+void mem_cgroup_inc_page_dirty(struct address_space *mapping);
+void mem_cgroup_dec_page_dirty(struct address_space *mapping);
+void mem_cgroup_inc_page_writeback(struct address_space *mapping);
+void mem_cgroup_dec_page_writeback(struct address_space *mapping);
+void mem_cgroup_forget_mapping(struct address_space *mapping);
+
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
 
@@ -340,6 +346,13 @@ static inline
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
 }
+
+static inline void mem_cgroup_inc_page_dirty(struct address_space *mapping) {}
+static inline void mem_cgroup_dec_page_dirty(struct address_space *mapping) {}
+static inline void mem_cgroup_inc_page_writeback(struct address_space *mapping) {}
+static inline void mem_cgroup_dec_page_writeback(struct address_space *mapping) {}
+static inline void mem_cgroup_forget_mapping(struct address_space *mapping) {}
+
 #endif /* CONFIG_MEMCG */
 
 enum {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 851924f..c5655f1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -361,6 +361,9 @@ struct mem_cgroup {
 	struct list_head event_list;
 	spinlock_t event_list_lock;
 
+	struct percpu_counter nr_dirty;
+	struct percpu_counter nr_writeback;
+
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
 };
@@ -3743,6 +3746,11 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 		seq_printf(m, "total_%s %llu\n", mem_cgroup_lru_names[i], val);
 	}
 
+	seq_printf(m, "fs_dirty %llu\n", PAGE_SIZE *
+			percpu_counter_sum_positive(&memcg->nr_dirty));
+	seq_printf(m, "fs_writeback %llu\n", PAGE_SIZE *
+			percpu_counter_sum_positive(&memcg->nr_writeback));
+
 #ifdef CONFIG_DEBUG_VM
 	{
 		int nid, zid;
@@ -4577,6 +4585,10 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	if (!memcg)
 		return NULL;
 
+	if (percpu_counter_init(&memcg->nr_dirty, 0, GFP_KERNEL) ||
+	    percpu_counter_init(&memcg->nr_writeback, 0, GFP_KERNEL))
+		goto out_free;
+
 	memcg->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
 	if (!memcg->stat)
 		goto out_free;
@@ -4584,6 +4596,8 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
 	return memcg;
 
 out_free:
+	percpu_counter_destroy(&memcg->nr_dirty);
+	percpu_counter_destroy(&memcg->nr_writeback);
 	kfree(memcg);
 	return NULL;
 }
@@ -4608,6 +4622,8 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 	for_each_node(node)
 		free_mem_cgroup_per_zone_info(memcg, node);
 
+	percpu_counter_destroy(&memcg->nr_dirty);
+	percpu_counter_destroy(&memcg->nr_writeback);
 	free_percpu(memcg->stat);
 
 	disarm_static_keys(memcg);
@@ -4750,6 +4766,31 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	return 0;
 }
 
+static void mem_cgroup_switch_one_sb(struct super_block *sb, void *_memcg)
+{
+	struct mem_cgroup *memcg = _memcg;
+	struct mem_cgroup *target = parent_mem_cgroup(memcg);
+	struct address_space *mapping;
+	struct inode *inode;
+	extern spinlock_t inode_sb_list_lock;
+
+	spin_lock(&inode_sb_list_lock);
+	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
+		mapping = inode->i_mapping;
+		if (likely(rcu_access_pointer(mapping->i_memcg) != memcg))
+			continue;
+		spin_lock_irq(&mapping->tree_lock);
+		if (rcu_access_pointer(mapping->i_memcg) == memcg) {
+			rcu_assign_pointer(mapping->i_memcg, target);
+			if (target)
+				css_get(&target->css);
+			css_put(&memcg->css);
+		}
+		spin_unlock_irq(&mapping->tree_lock);
+	}
+	spin_unlock(&inode_sb_list_lock);
+}
+
 static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
@@ -4767,6 +4808,9 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	}
 	spin_unlock(&memcg->event_list_lock);
 
+	/* Switch all ->i_memcg references to the parent cgroup */
+	iterate_supers(mem_cgroup_switch_one_sb, memcg);
+
 	vmpressure_cleanup(&memcg->vmpressure);
 }
 
@@ -5821,6 +5865,80 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 	commit_charge(newpage, memcg, lrucare);
 }
 
+static inline struct mem_cgroup *
+mem_cgroup_from_mapping(struct address_space *mapping)
+{
+	return rcu_dereference_check(mapping->i_memcg,
+			lockdep_is_held(&mapping->tree_lock));
+}
+
+void mem_cgroup_inc_page_dirty(struct address_space *mapping)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_mapping(mapping);
+
+	if (mem_cgroup_disabled())
+		return;
+
+	/* Remember context at dirtying first page in the mapping */
+	if (unlikely(!(mapping_tags(mapping) &
+	    (BIT(PAGECACHE_TAG_DIRTY) | BIT(PAGECACHE_TAG_WRITEBACK))))) {
+		struct mem_cgroup *task_memcg;
+
+		rcu_read_lock();
+		task_memcg = mem_cgroup_from_task(current);
+		if (task_memcg != memcg) {
+			if (memcg)
+				css_put(&memcg->css);
+			css_get(&task_memcg->css);
+			memcg = task_memcg;
+			lockdep_assert_held(&mapping->tree_lock);
+			rcu_assign_pointer(mapping->i_memcg, memcg);
+		}
+		rcu_read_unlock();
+	}
+
+	for (; memcg; memcg = parent_mem_cgroup(memcg))
+		percpu_counter_inc(&memcg->nr_dirty);
+}
+
+void mem_cgroup_dec_page_dirty(struct address_space *mapping)
+{
+	struct mem_cgroup *memcg;
+
+	rcu_read_lock();
+	memcg = mem_cgroup_from_mapping(mapping);
+	for (; memcg; memcg = parent_mem_cgroup(memcg))
+		percpu_counter_dec(&memcg->nr_dirty);
+	rcu_read_unlock();
+}
+
+void mem_cgroup_inc_page_writeback(struct address_space *mapping)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_mapping(mapping);
+
+	for (; memcg; memcg = parent_mem_cgroup(memcg))
+		percpu_counter_inc(&memcg->nr_writeback);
+}
+
+void mem_cgroup_dec_page_writeback(struct address_space *mapping)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_mapping(mapping);
+
+	for (; memcg; memcg = parent_mem_cgroup(memcg))
+		percpu_counter_dec(&memcg->nr_writeback);
+}
+
+void mem_cgroup_forget_mapping(struct address_space *mapping)
+{
+	struct mem_cgroup *memcg;
+
+	memcg = rcu_dereference_protected(mapping->i_memcg, 1);
+	if (memcg) {
+		css_put(&memcg->css);
+		RCU_INIT_POINTER(mapping->i_memcg, NULL);
+	}
+}
+
 /*
  * subsys_initcall() for memory controller.
  *
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 6f43352..afaf263 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2098,6 +2098,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTIED);
+		mem_cgroup_inc_page_dirty(mapping);
 		task_io_account_write(PAGE_CACHE_SIZE);
 		current->nr_dirtied++;
 		this_cpu_inc(bdp_ratelimits);
@@ -2297,6 +2298,7 @@ int clear_page_dirty_for_io(struct page *page)
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
+			mem_cgroup_dec_page_dirty(mapping);
 			return 1;
 		}
 		return 0;
@@ -2327,6 +2329,7 @@ int test_clear_page_writeback(struct page *page)
 			if (bdi_cap_account_writeback(bdi)) {
 				__dec_bdi_stat(bdi, BDI_WRITEBACK);
 				__bdi_writeout_inc(bdi);
+				mem_cgroup_dec_page_writeback(mapping);
 			}
 		}
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
@@ -2361,8 +2364,10 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 			radix_tree_tag_set(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
-			if (bdi_cap_account_writeback(bdi))
+			if (bdi_cap_account_writeback(bdi)) {
 				__inc_bdi_stat(bdi, BDI_WRITEBACK);
+				mem_cgroup_inc_page_writeback(mapping);
+			}
 		}
 		if (!PageDirty(page))
 			radix_tree_tag_clear(&mapping->page_tree,
diff --git a/mm/truncate.c b/mm/truncate.c
index f1e4d60..37915fe 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -114,6 +114,7 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
+			mem_cgroup_dec_page_dirty(mapping);
 			if (account_size)
 				task_io_account_cancelled_write(account_size);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
