Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 7CC1D6B0037
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 05:53:32 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id fz6so763054pac.17
        for <linux-mm@kvack.org>; Thu, 22 Aug 2013 02:53:31 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH 3/4] memcg: add per cgroup writeback pages accounting
Date: Thu, 22 Aug 2013 17:53:10 +0800
Message-Id: <1377165190-24143-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <CAFj3OHXy5XkwhxKk=WNywp2pq__FD7BrSQwFkp+NZj15_k6BEQ@mail.gmail.com>
References: <CAFj3OHXy5XkwhxKk=WNywp2pq__FD7BrSQwFkp+NZj15_k6BEQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

This patch is to add memcg routines to count writeback pages, later dirty pages will
also be accounted.

After Kame's commit 89c06bd5(memcg: use new logic for page stat accounting), we can
use 'struct page' flag to test page state instead of per page_cgroup flag. But memcg
has a feature to move a page from a cgroup to another one and may have race between
"move" and "page stat accounting". So in order to avoid the race we have designed a
new lock:

         mem_cgroup_begin_update_page_stat()
         modify page information        -->(a)
         mem_cgroup_update_page_stat()  -->(b)
         mem_cgroup_end_update_page_stat()

It requires both (a) and (b)(writeback pages accounting) to be pretected in
mem_cgroup_{begin/end}_update_page_stat(). It's full no-op for !CONFIG_MEMCG, almost
no-op if memcg is disabled (but compiled in), rcu read lock in the most cases
(no task is moving), and spin_lock_irqsave on top in the slow path.

There're two writeback interfaces to modify: test_{clear/set}_page_writeback().
And the lock order is:
	--> memcg->move_lock
	  --> mapping->tree_lock

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Greg Thelen <gthelen@google.com>
---
 include/linux/memcontrol.h |    1 +
 mm/memcontrol.c            |   30 +++++++++++++++++++++++-------
 mm/page-writeback.c        |   15 +++++++++++++++
 3 files changed, 39 insertions(+), 7 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 630bfa1..1878644 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -42,6 +42,7 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_RSS,		/* # of pages charged as anon rss */
 	MEM_CGROUP_STAT_RSS_HUGE,	/* # of pages charged as anon huge */
 	MEM_CGROUP_STAT_FILE_MAPPED,	/* # of pages charged as file rss */
+	MEM_CGROUP_STAT_WRITEBACK,	/* # of pages under writeback */
 	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
 	MEM_CGROUP_STAT_NSTATS,
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0a50871..869bfaf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -89,6 +89,7 @@ static const char * const mem_cgroup_stat_names[] = {
 	"rss",
 	"rss_huge",
 	"mapped_file",
+	"writeback",
 	"swap",
 };
 
@@ -3675,6 +3676,20 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+static inline
+void mem_cgroup_move_account_page_stat(struct mem_cgroup *from,
+					struct mem_cgroup *to,
+					unsigned int nr_pages,
+					enum mem_cgroup_stat_index idx)
+{
+	/* Update stat data for mem_cgroup */
+	preempt_disable();
+	WARN_ON_ONCE(from->stat->count[idx] < nr_pages);
+	__this_cpu_add(from->stat->count[idx], -nr_pages);
+	__this_cpu_add(to->stat->count[idx], nr_pages);
+	preempt_enable();
+}
+
 /**
  * mem_cgroup_move_account - move account of the page
  * @page: the page
@@ -3720,13 +3735,14 @@ static int mem_cgroup_move_account(struct page *page,
 
 	move_lock_mem_cgroup(from, &flags);
 
-	if (!anon && page_mapped(page)) {
-		/* Update mapped_file data for mem_cgroup */
-		preempt_disable();
-		__this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		__this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
-		preempt_enable();
-	}
+	if (!anon && page_mapped(page))
+		mem_cgroup_move_account_page_stat(from, to, nr_pages,
+			MEM_CGROUP_STAT_FILE_MAPPED);
+
+	if (PageWriteback(page))
+		mem_cgroup_move_account_page_stat(from, to, nr_pages,
+			MEM_CGROUP_STAT_WRITEBACK);
+
 	mem_cgroup_charge_statistics(from, page, anon, -nr_pages);
 
 	/* caller should have done css_get */
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index ddc56fc..b6ecbc6 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1999,11 +1999,17 @@ EXPORT_SYMBOL(account_page_dirtied);
 
 /*
  * Helper function for set_page_writeback family.
+ *
+ * The caller must hold mem_cgroup_begin/end_update_page_stat() lock
+ * while calling this function.
+ * See test_set_page_writeback for example.
+ *
  * NOTE: Unlike account_page_dirtied this does not rely on being atomic
  * wrt interrupts.
  */
 void account_page_writeback(struct page *page)
 {
+	mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
 	inc_zone_page_state(page, NR_WRITEBACK);
 }
 EXPORT_SYMBOL(account_page_writeback);
@@ -2220,7 +2226,10 @@ int test_clear_page_writeback(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 	int ret;
+	bool locked;
+	unsigned long memcg_flags;
 
+	mem_cgroup_begin_update_page_stat(page, &locked, &memcg_flags);
 	if (mapping) {
 		struct backing_dev_info *bdi = mapping->backing_dev_info;
 		unsigned long flags;
@@ -2241,9 +2250,11 @@ int test_clear_page_writeback(struct page *page)
 		ret = TestClearPageWriteback(page);
 	}
 	if (ret) {
+		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
 		dec_zone_page_state(page, NR_WRITEBACK);
 		inc_zone_page_state(page, NR_WRITTEN);
 	}
+	mem_cgroup_end_update_page_stat(page, &locked, &memcg_flags);
 	return ret;
 }
 
@@ -2251,7 +2262,10 @@ int test_set_page_writeback(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 	int ret;
+	bool locked;
+	unsigned long memcg_flags;
 
+	mem_cgroup_begin_update_page_stat(page, &locked, &memcg_flags);
 	if (mapping) {
 		struct backing_dev_info *bdi = mapping->backing_dev_info;
 		unsigned long flags;
@@ -2278,6 +2292,7 @@ int test_set_page_writeback(struct page *page)
 	}
 	if (!ret)
 		account_page_writeback(page);
+	mem_cgroup_end_update_page_stat(page, &locked, &memcg_flags);
 	return ret;
 
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
