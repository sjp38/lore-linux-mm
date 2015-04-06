Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2E80F6B010B
	for <linux-mm@kvack.org>; Mon,  6 Apr 2015 16:18:41 -0400 (EDT)
Received: by qcgx3 with SMTP id x3so15356111qcg.3
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:18:41 -0700 (PDT)
Received: from mail-qg0-x22e.google.com (mail-qg0-x22e.google.com. [2607:f8b0:400d:c04::22e])
        by mx.google.com with ESMTPS id f1si5195039qcd.49.2015.04.06.13.18.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 13:18:40 -0700 (PDT)
Received: by qgeb100 with SMTP id b100so15173409qge.3
        for <linux-mm@kvack.org>; Mon, 06 Apr 2015 13:18:39 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 04/10] truncate: swap the order of conditionals in cancel_dirty_page()
Date: Mon,  6 Apr 2015 16:18:22 -0400
Message-Id: <1428351508-8399-5-git-send-email-tj@kernel.org>
In-Reply-To: <1428351508-8399-1-git-send-email-tj@kernel.org>
References: <1428351508-8399-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, gthelen@google.com, Tejun Heo <tj@kernel.org>

cancel_dirty_page() currently performs TestClearPageDirty() and then
tests whether the mapping exists and has cap_account_dirty.  This
patch swaps the order so that it performs the mapping tests first.

If the mapping tests fail, the dirty is cleared with ClearPageDirty().
The order or the conditionals is swapped but the end result is the
same.  This will help inode foreign cgroup wb switching.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg Thelen <gthelen@google.com>
---
 mm/truncate.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index fe2d769..9d40cd4 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -108,13 +108,13 @@ void do_invalidatepage(struct page *page, unsigned int offset,
  */
 void cancel_dirty_page(struct page *page, unsigned int account_size)
 {
-	struct mem_cgroup *memcg;
+	struct address_space *mapping = page->mapping;
 
-	memcg = mem_cgroup_begin_page_stat(page);
-	if (TestClearPageDirty(page)) {
-		struct address_space *mapping = page->mapping;
+	if (mapping && mapping_cap_account_dirty(mapping)) {
+		struct mem_cgroup *memcg;
 
-		if (mapping && mapping_cap_account_dirty(mapping)) {
+		memcg = mem_cgroup_begin_page_stat(page);
+		if (TestClearPageDirty(page)) {
 			struct bdi_writeback *wb = inode_to_wb(mapping->host);
 
 			mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_DIRTY);
@@ -123,8 +123,10 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
 			if (account_size)
 				task_io_account_cancelled_write(account_size);
 		}
+		mem_cgroup_end_page_stat(memcg);
+	} else {
+		ClearPageDirty(page);
 	}
-	mem_cgroup_end_page_stat(memcg);
 }
 EXPORT_SYMBOL(cancel_dirty_page);
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
