Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id BB6E76B01FF
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 21:16:52 -0500 (EST)
Received: by mail-ee0-f73.google.com with SMTP id e49so82363eek.2
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 18:16:52 -0800 (PST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 2/2] memcg: fix livelock in try charge during readahead
Date: Mon, 12 Dec 2011 18:16:48 -0800
Message-Id: <1323742608-9246-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Fengguang Wu <fengguang.wu@intel.com>, Greg Thelen <gthelen@google.com>
Cc: linux-mm@kvack.org

Couple of kernel dumps are triggered by watchdog timeout. It turns out that two
processes within a memcg livelock on a same page lock. We believe this is not
memcg specific issue and the same livelock exists in non-memcg world as well.

The sequence of triggering the livelock:
1. Task_A enters pagefault (filemap_fault) and then starts readahead
filemap_fault
 -> do_sync_mmap_readahead
    -> ra_submit
       ->__do_page_cache_readahead // here we allocate the readahead pages
         ->read_pages
         ...
           ->add_to_page_cache_locked
             //for each page, we do the try charge and then add the page into
             //radix tree. If one of the try charge failed, it enters per-memcg
             //oom while holding the page lock of previous readahead pages.

            // in the memcg oom killer, it picks a task within the same memcg
            // and mark it TIF_MEMDIE. then it goes back into retry loop and
            // hopes the task exits to free some memory.

2. Task_B enters pagefault (filemap_fault) and finds the page in radix tree (
one of the readahead pages from ProcessA)

filemap_fault
 ->__lock_page // here it is marked as TIF_MEMDIE. but it can not proceed since
               // the page lock is hold by ProcessA looping at OOM.

Since the TIF_MEMDIE task_B is live locked, it ends up blocking other tasks
making forward progress since they are also checking the flag in
select_bad_process. The same issue exists in the non-memcg world. Instead of
entering oom through mem_cgroup_cache_charge(), we might enter it through
radix_tree_preload().

The proposed fix here is to pass __GFP_NORETRY gfp_mask into try charge under
readahead. Then we skip entering memcg OOM kill which eliminates the case where
it OOMs on one page and holds other page locks. It seems to be safe to do that
since both filemap_fault() and do_generic_file_read() handles the fallback case
of "no_cached_page".

Note:
After this patch, we might experience some charge fails for readahead pages
(since we don't enter oom). But this sounds sane compared to letting the system
trying extremely hard to charge a readahead page by doing reclaim and then oom,
the later one also triggers livelock as listed above.

Signed-off-by: Greg Thelen <gthelen@google.com>
Signed-off-by: Ying Han <yinghan@google.com>
---
 fs/mpage.c     |    3 ++-
 mm/readahead.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/mpage.c b/fs/mpage.c
index 643e9f5..90d608e 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -380,7 +380,8 @@ mpage_readpages(struct address_space *mapping, struct list_head *pages,
 		prefetchw(&page->flags);
 		list_del(&page->lru);
 		if (!add_to_page_cache_lru(page, mapping,
-					page->index, GFP_KERNEL)) {
+					page->index,
+					GFP_KERNEL | __GFP_NORETRY)) {
 			bio = do_mpage_readpage(bio, page,
 					nr_pages - page_idx,
 					&last_block_in_bio, &map_bh,
diff --git a/mm/readahead.c b/mm/readahead.c
index cbcbb02..bc9431c 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -126,7 +126,8 @@ static int read_pages(struct address_space *mapping, struct file *filp,
 		struct page *page = list_to_page(pages);
 		list_del(&page->lru);
 		if (!add_to_page_cache_lru(page, mapping,
-					page->index, GFP_KERNEL)) {
+					page->index,
+					GFP_KERNEL | __GFP_NORETRY)) {
 			mapping->a_ops->readpage(filp, page);
 		}
 		page_cache_release(page);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
