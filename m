Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 118916B0296
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 00:51:29 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id gt1so59152674wjc.0
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:29 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u43si15124571wrb.327.2017.01.29.21.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 21:51:28 -0800 (PST)
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U5lWS9023125
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:26 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 288t0hmxde-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 21:51:26 -0800
Received: from facebook.com (2401:db00:21:603d:face:0:19:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 21e4cd98e6b011e6b1c90002c95209d8-e3bf5a50 for <linux-mm@kvack.org>;	Sun, 29
 Jan 2017 21:51:24 -0800
From: Shaohua Li <shli@fb.com>
Subject: [RFC 2/6] mm: add lazyfree page flag
Date: Sun, 29 Jan 2017 21:51:19 -0800
Message-ID: <07e197009e2be8f63dfa0510cce28b38f8a82fe7.1485748619.git.shli@fb.com>
In-Reply-To: <cover.1485748619.git.shli@fb.com>
References: <cover.1485748619.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net

We are going to add MADV_FREE pages into a new LRU list. Add a new flag
to indicate such pages. Note, we are reusing PG_mappedtodisk for the new
flag. This is ok because no anonymous pages have this flag set.

The patch is based on Minchan's previous patch.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Shaohua Li<shli@fb.com>
---
 fs/proc/task_mmu.c         | 8 +++++++-
 include/linux/mm_inline.h  | 5 +++++
 include/linux/page-flags.h | 6 ++++++
 mm/huge_memory.c           | 1 +
 mm/migrate.c               | 2 ++
 5 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index ee3efb2..813d3aa 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -440,6 +440,7 @@ struct mem_size_stats {
 	unsigned long private_dirty;
 	unsigned long referenced;
 	unsigned long anonymous;
+	unsigned long lazyfree;
 	unsigned long anonymous_thp;
 	unsigned long shmem_thp;
 	unsigned long swap;
@@ -456,8 +457,11 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 	int i, nr = compound ? 1 << compound_order(page) : 1;
 	unsigned long size = nr * PAGE_SIZE;
 
-	if (PageAnon(page))
+	if (PageAnon(page)) {
 		mss->anonymous += size;
+		if (PageLazyFree(page))
+			mss->lazyfree += size;
+	}
 
 	mss->resident += size;
 	/* Accumulate the size in pages that have been accessed. */
@@ -770,6 +774,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   "Private_Dirty:  %8lu kB\n"
 		   "Referenced:     %8lu kB\n"
 		   "Anonymous:      %8lu kB\n"
+		   "LazyFree:       %8lu kB\n"
 		   "AnonHugePages:  %8lu kB\n"
 		   "ShmemPmdMapped: %8lu kB\n"
 		   "Shared_Hugetlb: %8lu kB\n"
@@ -788,6 +793,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   mss.private_dirty >> 10,
 		   mss.referenced >> 10,
 		   mss.anonymous >> 10,
+		   mss.lazyfree >> 10,
 		   mss.anonymous_thp >> 10,
 		   mss.shmem_thp >> 10,
 		   mss.shared_hugetlb >> 10,
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 0dddc2c..828e813 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -22,6 +22,11 @@ static inline int page_is_file_cache(struct page *page)
 	return !PageSwapBacked(page);
 }
 
+static inline bool page_is_lazyfree(struct page *page)
+{
+	return PageSwapBacked(page) && PageLazyFree(page);
+}
+
 static __always_inline void __update_lru_size(struct lruvec *lruvec,
 				enum lru_list lru, enum zone_type zid,
 				int nr_pages)
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6b5818d..e8ea378 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -107,6 +107,9 @@ enum pageflags {
 #endif
 	__NR_PAGEFLAGS,
 
+	/* MADV_FREE */
+	PG_lazyfree = PG_mappedtodisk,
+
 	/* Filesystems */
 	PG_checked = PG_owner_priv_1,
 
@@ -428,6 +431,9 @@ TESTPAGEFLAG_FALSE(Ksm)
 
 u64 stable_page_flags(struct page *page);
 
+PAGEFLAG(LazyFree, lazyfree, PF_ANY)
+	__CLEARPAGEFLAG(LazyFree, lazyfree, PF_ANY)
+
 static inline int PageUptodate(struct page *page)
 {
 	int ret;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 40bd376..ffa7ed5 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1918,6 +1918,7 @@ static void __split_huge_page_tail(struct page *head, int tail,
 			 (1L << PG_swapbacked) |
 			 (1L << PG_mlocked) |
 			 (1L << PG_uptodate) |
+			 (1L << PG_lazyfree) |
 			 (1L << PG_active) |
 			 (1L << PG_locked) |
 			 (1L << PG_unevictable) |
diff --git a/mm/migrate.c b/mm/migrate.c
index 502ebea..496105c 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -641,6 +641,8 @@ void migrate_page_copy(struct page *newpage, struct page *page)
 		SetPageChecked(newpage);
 	if (PageMappedToDisk(page))
 		SetPageMappedToDisk(newpage);
+	if (PageLazyFree(page))
+		SetPageLazyFree(newpage);
 
 	/* Move dirty on pages not done by migrate_page_move_mapping() */
 	if (PageDirty(page))
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
