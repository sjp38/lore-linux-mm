Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3FB6B0033
	for <linux-mm@kvack.org>; Fri, 27 Oct 2017 01:53:40 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id w24so4798859pgm.7
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 22:53:40 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id p5si4423815pga.743.2017.10.26.22.53.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Oct 2017 22:53:38 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -V2] mm, swap: Fix false error message in __swp_swapcount()
Date: Fri, 27 Oct 2017 13:53:27 +0800
Message-Id: <20171027055327.5428-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <huang.ying.caritas@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, stable@vger.kernel.org, "Huang, Ying" <ying.huang@intel.com>, Christian Kujau <lists@nerdbynature.de>

From: Huang Ying <huang.ying.caritas@gmail.com>

When a page fault occurs for a swap entry, the physical swap readahead
(not the VMA base swap readahead) may readahead several swap entries
after the fault swap entry.  The readahead algorithm calculates some
of the swap entries to readahead via increasing the offset of the
fault swap entry without checking whether they are beyond the end of
the swap device and it relys on the __swp_swapcount() and
swapcache_prepare() to check it.  Although __swp_swapcount() checks
for the swap entry passed in, it will complain with the error message
as follow for the expected invalid swap entry.  This may make the end
users confused.

  swap_info_get: Bad swap offset entry 0200f8a7

To fix the false error message, the swap entry checking is added in
swap readahead to avoid to pass the out-bound swap entries and the
swap entry reserved for the swap header to __swp_swapcount() and
swapcache_prepare().

Cc: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: <stable@vger.kernel.org> # 4.11-4.13
Reported-by: Christian Kujau <lists@nerdbynature.de>
Fixes: e8c26ab60598 ("mm/swap: skip readahead for unreferenced swap slots")
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/swap.h |  1 +
 mm/swap_state.c      |  6 ++++--
 mm/swapfile.c        | 21 +++++++++++++++++++++
 3 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 84255b3da7c1..43b4b821c805 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -476,6 +476,7 @@ extern int page_swapcount(struct page *);
 extern int __swap_count(struct swap_info_struct *si, swp_entry_t entry);
 extern int __swp_swapcount(swp_entry_t entry);
 extern int swp_swapcount(swp_entry_t entry);
+extern bool swap_entry_check(swp_entry_t entry);
 extern struct swap_info_struct *page_swap_info(struct page *);
 extern struct swap_info_struct *swp_swap_info(swp_entry_t entry);
 extern bool reuse_swap_page(struct page *, int *);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 6c017ced11e6..7dd70e77058d 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -569,11 +569,13 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 	/* Read a page_cluster sized and aligned cluster around offset. */
 	start_offset = offset & ~mask;
 	end_offset = offset | mask;
-	if (!start_offset)	/* First page is swap header. */
-		start_offset++;
 
 	blk_start_plug(&plug);
 	for (offset = start_offset; offset <= end_offset ; offset++) {
+		swp_entry_t ent = swp_entry(swp_type(entry), offset);
+
+		if (!swap_entry_check(ent))
+			continue;
 		/* Ok, do the async read-ahead now */
 		page = __read_swap_cache_async(
 			swp_entry(swp_type(entry), offset),
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 3074b02eaa09..b04cec29c234 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1107,6 +1107,27 @@ static struct swap_info_struct *swap_info_get_cont(swp_entry_t entry,
 	return p;
 }
 
+bool swap_entry_check(swp_entry_t entry)
+{
+	struct swap_info_struct *p;
+	unsigned long offset, type;
+
+	type = swp_type(entry);
+	if (type >= nr_swapfiles)
+		goto bad_file;
+	p = swap_info[type];
+	offset = swp_offset(entry);
+	if (unlikely(!offset || offset >= p->max))
+		goto out;
+
+	return true;
+
+bad_file:
+	pr_err("%s: %s%08lx\n", __func__, Bad_file, entry.val);
+out:
+	return false;
+}
+
 static unsigned char __swap_entry_free(struct swap_info_struct *p,
 				       swp_entry_t entry, unsigned char usage)
 {
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
