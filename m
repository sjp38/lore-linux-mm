Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id A20706B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 22:47:29 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 191so13215346pgd.0
        for <linux-mm@kvack.org>; Mon, 23 Oct 2017 19:47:29 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id z12si5763259pgc.582.2017.10.23.19.47.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Oct 2017 19:47:26 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm] mm, swap: Fix false error message in __swp_swapcount()
Date: Tue, 24 Oct 2017 10:47:00 +0800
Message-Id: <20171024024700.23679-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ying Huang <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, stable@vger.kernel.org, Christian Kujau <lists@nerdbynature.de>

From: Ying Huang <ying.huang@intel.com>

__swp_swapcount() is used in __read_swap_cache_async().  Where the
invalid swap entry (offset > max) may be supplied during swap
readahead.  But __swp_swapcount() will print error message for these
expected invalid swap entry as below, which will make the users
confusing.

  swap_info_get: Bad swap offset entry 0200f8a7

So the swap entry checking code in __swp_swapcount() is changed to
avoid printing error message for it.  To avoid to duplicate code with
__swap_duplicate(), a new helper function named
__swap_info_get_silence() is added and invoked in both places.

Cc: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: <stable@vger.kernel.org> # 4.11-4.13
Reported-by: Christian Kujau <lists@nerdbynature.de>
Fixes: e8c26ab60598 ("mm/swap: skip readahead for unreferenced swap slots")
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 mm/swapfile.c | 42 ++++++++++++++++++++++++++++--------------
 1 file changed, 28 insertions(+), 14 deletions(-)

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 3074b02eaa09..3193aa670c90 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1107,6 +1107,30 @@ static struct swap_info_struct *swap_info_get_cont(swp_entry_t entry,
 	return p;
 }
 
+static struct swap_info_struct *__swap_info_get_silence(swp_entry_t entry)
+{
+	struct swap_info_struct *p;
+	unsigned long offset, type;
+
+	if (non_swap_entry(entry))
+		goto out;
+
+	type = swp_type(entry);
+	if (type >= nr_swapfiles)
+		goto bad_file;
+	p = swap_info[type];
+	offset = swp_offset(entry);
+	if (unlikely(offset >= p->max))
+		goto out;
+
+	return p;
+
+bad_file:
+	pr_err("swap_info_get_silence: %s%08lx\n", Bad_file, entry.val);
+out:
+	return NULL;
+}
+
 static unsigned char __swap_entry_free(struct swap_info_struct *p,
 				       swp_entry_t entry, unsigned char usage)
 {
@@ -1357,7 +1381,7 @@ int __swp_swapcount(swp_entry_t entry)
 	int count = 0;
 	struct swap_info_struct *si;
 
-	si = __swap_info_get(entry);
+	si = __swap_info_get_silence(entry);
 	if (si)
 		count = swap_swapcount(si, entry);
 	return count;
@@ -3356,22 +3380,16 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 {
 	struct swap_info_struct *p;
 	struct swap_cluster_info *ci;
-	unsigned long offset, type;
+	unsigned long offset;
 	unsigned char count;
 	unsigned char has_cache;
 	int err = -EINVAL;
 
-	if (non_swap_entry(entry))
+	p = __swap_info_get_silence(entry);
+	if (!p)
 		goto out;
 
-	type = swp_type(entry);
-	if (type >= nr_swapfiles)
-		goto bad_file;
-	p = swap_info[type];
 	offset = swp_offset(entry);
-	if (unlikely(offset >= p->max))
-		goto out;
-
 	ci = lock_cluster_or_swap_info(p, offset);
 
 	count = p->swap_map[offset];
@@ -3418,10 +3436,6 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 	unlock_cluster_or_swap_info(p, ci);
 out:
 	return err;
-
-bad_file:
-	pr_err("swap_dup: %s%08lx\n", Bad_file, entry.val);
-	goto out;
 }
 
 /*
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
