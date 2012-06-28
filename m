Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 68CD96B006E
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 07:06:11 -0400 (EDT)
Received: by dakp5 with SMTP id p5so3338359dak.14
        for <linux-mm@kvack.org>; Thu, 28 Jun 2012 04:06:09 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH 6/7] memcg: add per cgroup writeback pages accounting
Date: Thu, 28 Jun 2012 19:06:02 +0800
Message-Id: <1340881562-5900-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1340880885-5427-1-git-send-email-handai.szj@taobao.com>
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

Similar to dirty page, we add per cgroup writeback pages accounting. The lock
rule still is:
	mem_cgroup_begin_update_page_stat()
	modify page WRITEBACK stat
	mem_cgroup_update_page_stat()
	mem_cgroup_end_update_page_stat()

There're two writeback interface to modify: test_clear/set_page_writeback.

Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
---
 include/linux/memcontrol.h |    1 +
 mm/memcontrol.c            |    5 +++++
 mm/page-writeback.c        |   12 ++++++++++++
 3 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index ad37b59..9193d93 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -39,6 +39,7 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
 	MEM_CGROUP_STAT_SWAP, /* # of pages, swapped out */
 	MEM_CGROUP_STAT_FILE_DIRTY,  /* # of dirty pages in page cache */
+	MEM_CGROUP_STAT_FILE_WRITEBACK,  /* # of pages under writeback */
 	MEM_CGROUP_STAT_NSTATS,
 };
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 90e2946..8493119 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -83,6 +83,7 @@ static const char * const mem_cgroup_stat_names[] = {
 	"mapped_file",
 	"swap",
 	"dirty",
+	"writeback",
 };
 
 enum mem_cgroup_events_index {
@@ -2604,6 +2605,10 @@ static int mem_cgroup_move_account(struct page *page,
 		mem_cgroup_move_account_page_stat(from, to,
 				MEM_CGROUP_STAT_FILE_DIRTY);
 
+	if (PageWriteback(page))
+		mem_cgroup_move_account_page_stat(from, to,
+				MEM_CGROUP_STAT_FILE_WRITEBACK);
+
 	mem_cgroup_charge_statistics(from, anon, -nr_pages);
 
 	/* caller should have done css_get */
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index e79a2f7..7398836 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1981,6 +1981,7 @@ EXPORT_SYMBOL(account_page_dirtied);
  */
 void account_page_writeback(struct page *page)
 {
+	mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_WRITEBACK);
 	inc_zone_page_state(page, NR_WRITEBACK);
 }
 EXPORT_SYMBOL(account_page_writeback);
@@ -2214,7 +2215,10 @@ int test_clear_page_writeback(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 	int ret;
+	bool locked;
+	unsigned long flags;
 
+	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 	if (mapping) {
 		struct backing_dev_info *bdi = mapping->backing_dev_info;
 		unsigned long flags;
@@ -2235,9 +2239,12 @@ int test_clear_page_writeback(struct page *page)
 		ret = TestClearPageWriteback(page);
 	}
 	if (ret) {
+		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_WRITEBACK);
 		dec_zone_page_state(page, NR_WRITEBACK);
 		inc_zone_page_state(page, NR_WRITTEN);
 	}
+
+	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 	return ret;
 }
 
@@ -2245,7 +2252,10 @@ int test_set_page_writeback(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 	int ret;
+	bool locked;
+	unsigned long flags;
 
+	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 	if (mapping) {
 		struct backing_dev_info *bdi = mapping->backing_dev_info;
 		unsigned long flags;
@@ -2272,6 +2282,8 @@ int test_set_page_writeback(struct page *page)
 	}
 	if (!ret)
 		account_page_writeback(page);
+
+	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 	return ret;
 
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
