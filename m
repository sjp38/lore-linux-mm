Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 9596E6B0038
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 13:33:22 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id 10so2167103pdi.11
        for <linux-mm@kvack.org>; Fri, 05 Jul 2013 10:33:21 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V4 4/6] memcg: add per cgroup writeback pages accounting
Date: Sat,  6 Jul 2013 01:32:57 +0800
Message-Id: <1373045577-27671-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1373044710-27371-1-git-send-email-handai.szj@taobao.com>
References: <1373044710-27371-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: mhocko@suse.cz, gthelen@google.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, fengguang.wu@intel.com, mgorman@suse.de, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

Similar to dirty page, we add per cgroup writeback pages accounting. The lock
rule still is:
        mem_cgroup_begin_update_page_stat()
        modify page WRITEBACK stat
        mem_cgroup_update_page_stat()
        mem_cgroup_end_update_page_stat()

There're two writeback interfaces to modify: test_{clear/set}_page_writeback().

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
cc: Greg Thelen <gthelen@google.com>
cc: Andrew Morton <akpm@linux-foundation.org>
cc: Fengguang Wu <fengguang.wu@intel.com>
cc: Mel Gorman <mgorman@suse.de>
---
 include/linux/memcontrol.h |    1 +
 mm/memcontrol.c            |    5 +++++
 mm/page-writeback.c        |   15 +++++++++++++++
 3 files changed, 21 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f952be6..ccd35d8 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -43,6 +43,7 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_RSS_HUGE,	/* # of pages charged as anon huge */
 	MEM_CGROUP_STAT_FILE_MAPPED,	/* # of pages charged as file rss */
 	MEM_CGROUP_STAT_FILE_DIRTY,	/* # of dirty pages in page cache */
+	MEM_CGROUP_STAT_WRITEBACK,	/* # of pages under writeback */
 	MEM_CGROUP_STAT_SWAP,		/* # of pages, swapped out */
 	MEM_CGROUP_STAT_NSTATS,
 };
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1d31851..9126abc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -92,6 +92,7 @@ static const char * const mem_cgroup_stat_names[] = {
 	"mapped_file",
 	"swap",
 	"dirty",
+	"writeback",
 };
 
 enum mem_cgroup_events_index {
@@ -3811,6 +3812,10 @@ static int mem_cgroup_move_account(struct page *page,
 		mem_cgroup_move_account_page_stat(from, to, nr_pages,
 			MEM_CGROUP_STAT_FILE_DIRTY);
 
+	if (PageWriteback(page))
+		mem_cgroup_move_account_page_stat(from, to, nr_pages,
+			MEM_CGROUP_STAT_WRITEBACK);
+
 	mem_cgroup_charge_statistics(from, page, anon, -nr_pages);
 
 	/* caller should have done css_get */
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 3900e62..85de9a0 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2008,11 +2008,17 @@ EXPORT_SYMBOL(account_page_dirtied);
 
 /*
  * Helper function for set_page_writeback family.
+ *
+ * The caller must hold mem_cgroup_begin/end_update_page_stat() lock
+ * while modifying struct page state and accounting writeback pages.
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
@@ -2243,7 +2249,10 @@ int test_clear_page_writeback(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 	int ret;
+	bool locked;
+	unsigned long memcg_flags;
 
+	mem_cgroup_begin_update_page_stat(page, &locked, &memcg_flags);
 	if (mapping) {
 		struct backing_dev_info *bdi = mapping->backing_dev_info;
 		unsigned long flags;
@@ -2264,9 +2273,11 @@ int test_clear_page_writeback(struct page *page)
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
 
@@ -2274,7 +2285,10 @@ int test_set_page_writeback(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 	int ret;
+	bool locked;
+	unsigned long flags;
 
+	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 	if (mapping) {
 		struct backing_dev_info *bdi = mapping->backing_dev_info;
 		unsigned long flags;
@@ -2301,6 +2315,7 @@ int test_set_page_writeback(struct page *page)
 	}
 	if (!ret)
 		account_page_writeback(page);
+	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 	return ret;
 
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
