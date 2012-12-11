Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 933FF6B0074
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 22:46:13 -0500 (EST)
Message-ID: <50C6AB45.606@intel.com>
Date: Tue, 11 Dec 2012 11:40:53 +0800
From: xtu4 <xiaobing.tu@intel.com>
MIME-Version: 1.0
Subject: resend--[PATCH]  improve read ahead in kernel
References: <50C4B4E7.60601@intel.com>
In-Reply-To: <50C4B4E7.60601@intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xtu4 <xiaobing.tu@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-tip-commits@vger.kernel.org, linux-mm@kvack.org, di.zhang@intel.com

resend it, due to format error

Subject: [PATCH] when system in low memory scenario, imaging there is a mp3
  play, ora video play, we need to read mp3 or video file
  from memory to page cache,but when system lack of memory,
  page cache of mp3 or video file will be reclaimed.once read
  in memory, then reclaimed, it will cause audio or video
  glitch,and it will increase the io operation at the same
  time.

Signed-off-by: xiaobing tu <xiaobing.tu@intel.com>
---
  include/linux/mm_types.h |    4 ++++
  mm/filemap.c             |    4 ++++
  mm/readahead.c           |   20 +++++++++++++++++---
  mm/vmscan.c              |   10 ++++++++--
  4 files changed, 33 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 5b42f1b..2739995 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -149,6 +149,10 @@ struct page {
       */
      void *shadow;
  #endif
+#ifdef CONFIG_LOWMEMORY_READAHEAD
+    unsigned int ioprio;
+#endif
+
  }
  /*
   * If another subsystem starts using the double word pairing for atomic
diff --git a/mm/filemap.c b/mm/filemap.c
index a0701e6..ca3a3e8 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -129,6 +129,10 @@ void __delete_from_page_cache(struct page *page)
      page->mapping = NULL;
      /* Leave page->index set: truncation lookup relies upon it */
      mapping->nrpages--;
+    #ifdef CONFIG_LOWMEMORY_READAHEAD
+    page->ioprio = 0;
+    #endif
+
      __dec_zone_page_state(page, NR_FILE_PAGES);
      if (PageSwapBacked(page))
          __dec_zone_page_state(page, NR_SHMEM);
diff --git a/mm/readahead.c b/mm/readahead.c
index cbcbb02..5c2d2ff 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -159,6 +159,11 @@ __do_page_cache_readahead(struct address_space 
*mapping, struct file *filp,
      int page_idx;
      int ret = 0;
      loff_t isize = i_size_read(inode);
+#ifdef CONFIG_LOWMEMORY_READAHEAD
+    int class = 0;
+    if (p->io_context)
+    class = IOPRIO_PRIO_CLASS(p->io_context->ioprio);
+#endif

      if (isize == 0)
          goto out;
@@ -177,12 +182,21 @@ __do_page_cache_readahead(struct address_space 
*mapping, struct file *filp,
          rcu_read_lock();
          page = radix_tree_lookup(&mapping->page_tree, page_offset);
          rcu_read_unlock();
-        if (page)
-            continue;
-
+        if (page){
+#ifdef CONFIG_LOWMEMORY_READAHEAD
+            if (class == IOPRIO_CLASS_RT) {
+                page->ioprio = 1;
+#endif
+                continue;
+            }
          page = page_cache_alloc_readahead(mapping);
          if (!page)
              break;
+#ifdef CONFIG_LOWMEMORY_READAHEAD
+        if (class == IOPRIO_CLASS_RT) {
+            page->ioprio = 1;
+#endif
+
          page->index = page_offset;
          list_add(&page->lru, &page_pool);
          if (page_idx == nr_to_read - lookahead_size)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 753a2dc..0a1cae8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -728,8 +728,14 @@ static enum page_references 
page_check_references(struct page *page,
      }

      /* Reclaim if clean, defer dirty pages to writeback */
-    if (referenced_page && !PageSwapBacked(page))
-        return PAGEREF_RECLAIM_CLEAN;
+    if (referenced_page && !PageSwapBacked(page)) {
+#ifdef CONFIG_LOWMEMORY_READAHEAD
+        if (page->ioprio == 1) {
+            return PAGEREF_ACTIVATE;
+        } else
+#endif
+            return PAGEREF_RECLAIM_CLEAN;
+    }

      return PAGEREF_RECLAIM;
  }
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
