Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id DC93E6B0037
	for <linux-mm@kvack.org>; Mon, 13 May 2013 01:05:57 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc8so2239662pbc.32
        for <linux-mm@kvack.org>; Sun, 12 May 2013 22:05:57 -0700 (PDT)
From: Sha Zhengju <handai.szj@gmail.com>
Subject: [PATCH V2 3/3] memcg: simplify lock of memcg page stat account
Date: Mon, 13 May 2013 13:05:44 +0800
Message-Id: <1368421545-4974-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1368421410-4795-1-git-send-email-handai.szj@taobao.com>
References: <1368421410-4795-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.cz, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, hughd@google.com, gthelen@google.com, Sha Zhengju <handai.szj@taobao.com>

From: Sha Zhengju <handai.szj@taobao.com>

After removing duplicated information like PCG_* flags in
'struct page_cgroup'(commit 2ff76f1193), there's a problem between
"move" and "page stat accounting"(only FILE_MAPPED is supported now
but other stats will be added in future, and here I'd like to take
dirty page as an example):

Assume CPU-A does "page stat accounting" and CPU-B does "move"

CPU-A                        CPU-B
TestSet PG_dirty
(delay)              	move_lock_mem_cgroup()
                        if (PageDirty(page)) {
                             old_memcg->nr_dirty --
                             new_memcg->nr_dirty++
                        }
                        pc->mem_cgroup = new_memcg;
                        move_unlock_mem_cgroup()

move_lock_mem_cgroup()
memcg = pc->mem_cgroup
memcg->nr_dirty++
move_unlock_mem_cgroup()

while accounting information of new_memcg may be double-counted. So we
use a bigger lock to solve this problem:  (commit: 89c06bd52f)

      move_lock_mem_cgroup() <-- mem_cgroup_begin_update_page_stat()
      TestSetPageDirty(page)
      update page stats (without any checks)
      move_unlock_mem_cgroup() <-- mem_cgroup_begin_update_page_stat()


But this method also has its pros and cons: at present we use two layers
of lock avoidance(memcg_moving and memcg->moving_account) then spinlock
on memcg (see mem_cgroup_begin_update_page_stat()), but the lock
granularity is a little bigger that not only the critical section but
also some code logic is in the range of locking which may be deadlock
prone. While trying to add memcg dirty page accounting, it gets into
further difficulty with page cache radix-tree lock and even worse
mem_cgroup_begin_update_page_stat() requires nesting
(https://lkml.org/lkml/2013/1/2/48). However, when the current patch is
preparing, the lock nesting problem is longer possible as s390/mm has
reworked it out(commit:abf09bed), but it should be better
if we can make the lock simpler and recursive safe.

A choice may be:

       CPU-A (stat)                 CPU-B (move)

move_lock_mem_cgroup()
if (PageCgroupUsed(pc)) ---(1)
   needinc = 1;
old_memcg = pc->mem_cgroup
ret = TestSetPageDirty(page)	lock_page_cgroup();
move_unlock_mem_cgroup()     	if (!PageCgroupUsed(pc)) ---(2)
				  return;
                             	move_lock_mem_cgroup()
                             	if (PageDirty) {
                                  old_memcg->nr_dirty --;
                                  new_memcg->nr_dirty ++;
                             	}
                             	pc->mem_cgroup = new_memcg
                             	move_unlock_mem_cgroup()
if (needinc & ret)		unlock_page_cgroup();
   old_memcg->nr_dirty ++


For CPU-A, we save pc->mem_cgroup in a temporary variable just before
TestSetPageDirty inside move_lock and then update stats if the page is set
PG_dirty successfully. But CPU-B may do "moving" in advance that
"old_memcg->nr_dirty --" will make old_memcg->nr_dirty incorrect but
soon CPU-A will do "old_memcg->nr_dirty ++" finally that amend the stats.
Now as only old_memcg saving and TestSetPageDirty is done under move_lock,
the possibility of deadlock or recursion is greatly reduced.

But is it race safe? As we know there're 4 candidates among which exist race
condition: page stat, move account, charge and uncharge. In the previous
illustration, PageCgroupUsed judgment can be different in step (1) and (2)
because of charge or uncharge. But here we don't need additional
synchronization since there's no race between stat & charge or stat & uncharge.
For details please see comments above __mem_cgroup_begin_update_page_stat().


Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
---
 mm/rmap.c |   23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index a03c2a9..7b58576 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -57,6 +57,7 @@
 #include <linux/migrate.h>
 #include <linux/hugetlb.h>
 #include <linux/backing-dev.h>
+#include <linux/page_cgroup.h>
 
 #include <asm/tlbflush.h>
 
@@ -1111,6 +1112,7 @@ void page_add_file_rmap(struct page *page)
 	unsigned long flags;
 	struct page_cgroup *pc;
 	struct mem_cgroup *memcg = NULL;
+	bool ret;
 
 	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
 	pc = lookup_page_cgroup(page);
@@ -1119,15 +1121,15 @@ void page_add_file_rmap(struct page *page)
 	memcg = pc->mem_cgroup;
 	if (unlikely(!PageCgroupUsed(pc)))
 		memcg = NULL;
+	ret = atomic_inc_and_test(&page->_mapcount);
+	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 
-	if (atomic_inc_and_test(&page->_mapcount)) {
+	if (ret) {
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
 		if (memcg)
 			mem_cgroup_inc_page_stat(memcg, MEMCG_NR_FILE_MAPPED);
 	}
 	rcu_read_unlock();
-
-	mem_cgroup_end_update_page_stat(page, &locked, &flags);
 }
 
 /**
@@ -1143,6 +1145,7 @@ void page_remove_rmap(struct page *page)
 	unsigned long flags;
 	struct page_cgroup *pc;
 	struct mem_cgroup *memcg = NULL;
+	bool ret;
 
 	/*
 	 * The anon case has no mem_cgroup page_stat to update; but may
@@ -1158,16 +1161,20 @@ void page_remove_rmap(struct page *page)
 			memcg = NULL;
 	}
 
+	ret = atomic_add_negative(-1, &page->_mapcount);
+	if (!anon)
+		mem_cgroup_end_update_page_stat(page, &locked, &flags);
+
 	/* page still mapped by someone else? */
-	if (!atomic_add_negative(-1, &page->_mapcount))
-		goto out;
+	if (!ret)
+		return;
 
 	/*
 	 * Hugepages are not counted in NR_ANON_PAGES nor NR_FILE_MAPPED
 	 * and not charged by memcg for now.
 	 */
 	if (unlikely(PageHuge(page)))
-		goto out;
+		return;
 	if (anon) {
 		mem_cgroup_uncharge_page(page);
 		if (!PageTransHuge(page))
@@ -1180,7 +1187,6 @@ void page_remove_rmap(struct page *page)
 		if (memcg)
 			mem_cgroup_dec_page_stat(memcg, MEMCG_NR_FILE_MAPPED);
 		rcu_read_unlock();
-		mem_cgroup_end_update_page_stat(page, &locked, &flags);
 	}
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
@@ -1194,9 +1200,6 @@ void page_remove_rmap(struct page *page)
 	 * faster for those pages still in swapcache.
 	 */
 	return;
-out:
-	if (!anon)
-		mem_cgroup_end_update_page_stat(page, &locked, &flags);
 }
 
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
