Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 07BA26B0279
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:28 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id i21so898359qtp.10
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:28 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q21si6946148qta.358.2018.04.04.12.19.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:27 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 65/79] mm/swap: add struct swap_info_struct swap_readpage() arguments
Date: Wed,  4 Apr 2018 15:18:19 -0400
Message-Id: <20180404191831.5378-30-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Add struct swap_info_struct swap_readpage() arguments. One step toward
dropping reliance on page->private during swap read back.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/swap.h |  6 ++++--
 mm/memory.c          |  2 +-
 mm/page_io.c         |  4 ++--
 mm/swap_state.c      | 12 ++++++++----
 4 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 2f6abe9652f6..90c26ec2997c 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -383,7 +383,8 @@ extern void kswapd_stop(int nid);
 #include <linux/blk_types.h> /* for bio_end_io_t */
 
 /* linux/mm/page_io.c */
-extern int swap_readpage(struct page *page, bool do_poll);
+extern int swap_readpage(struct swap_info_struct *sis, struct page *page,
+			 bool do_poll);
 extern int swap_writepage(struct address_space *mapping, struct page *page,
 			  struct writeback_control *wbc);
 extern void end_swap_bio_write(struct bio *bio);
@@ -486,7 +487,8 @@ extern void exit_swap_address_space(unsigned int type);
 
 #else /* CONFIG_SWAP */
 
-static inline int swap_readpage(struct page *page, bool do_poll)
+static inline int swap_readpage(struct swap_info_struct *sis, struct page *page,
+				bool do_poll)
 {
 	return 0;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 1311599a164b..6ffd76528e7b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2949,7 +2949,7 @@ int do_swap_page(struct vm_fault *vmf)
 				__SetPageSwapBacked(page);
 				set_page_private(page, entry.val);
 				lru_cache_add_anon(page);
-				swap_readpage(page, true);
+				swap_readpage(si, page, true);
 			}
 		} else {
 			if (vma_readahead)
diff --git a/mm/page_io.c b/mm/page_io.c
index 6e548b588490..f4e05c90c87e 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -349,11 +349,11 @@ int __swap_writepage(struct page *page, struct writeback_control *wbc,
 	return ret;
 }
 
-int swap_readpage(struct page *page, bool synchronous)
+int swap_readpage(struct swap_info_struct *sis, struct page *page,
+		  bool synchronous)
 {
 	struct bio *bio;
 	int ret = 0;
-	struct swap_info_struct *sis = page_swap_info(page);
 	blk_qc_t qc;
 	struct gendisk *disk;
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 39ae7cfad90f..40a2437e3c34 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -466,8 +466,10 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 	struct page *retpage = __read_swap_cache_async(entry, gfp_mask,
 			vma, addr, &page_was_allocated);
 
-	if (page_was_allocated)
-		swap_readpage(retpage, do_poll);
+	if (page_was_allocated) {
+		struct swap_info_struct *sis = swp_swap_info(entry);
+		swap_readpage(sis, retpage, do_poll);
+	}
 
 	return retpage;
 }
@@ -585,7 +587,8 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 		if (!page)
 			continue;
 		if (page_allocated) {
-			swap_readpage(page, false);
+			struct swap_info_struct *sis = swp_swap_info(entry);
+			swap_readpage(sis, page, false);
 			if (offset != entry_offset &&
 			    likely(!PageTransCompound(page))) {
 				SetPageReadahead(page);
@@ -748,7 +751,8 @@ struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 		if (!page)
 			continue;
 		if (page_allocated) {
-			swap_readpage(page, false);
+			struct swap_info_struct *sis = swp_swap_info(entry);
+			swap_readpage(sis, page, false);
 			if (i != swap_ra->offset &&
 			    likely(!PageTransCompound(page))) {
 				SetPageReadahead(page);
-- 
2.14.3
