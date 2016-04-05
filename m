Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id D8F3E6B02A7
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:51:41 -0400 (EDT)
Received: by mail-pf0-f182.google.com with SMTP id 184so18918558pff.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:51:41 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id gc5si10123041pac.224.2016.04.05.14.51.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:51:40 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id n1so18859982pfn.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:51:40 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:51:38 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 22/31] huge tmpfs: /proc/<pid>/smaps show ShmemHugePages
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051449540.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

We have been relying on the AnonHugePages line of /proc/<pid>/smaps
for informal visibility of huge tmpfs mappings by a process.  It's
been good enough, but rather tacky, and best fixed before wider use.

Now reserve AnonHugePages for anonymous THP, and use ShmemHugePages
for huge tmpfs.  There is a good argument for calling it ShmemPmdMapped
instead (pte mappings of team pages won't be included in this count),
and I wouldn't mind changing to that; but smaps is all about the mapped,
and I think ShmemHugePages is more what people would expect to see here.

Add a team_page_mapcount() function to help get the PSS accounting right,
now that compound pages are accounting correctly for ptes inside pmds;
but nothing else needs that function, so keep it out of page_mapcount().

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 Documentation/filesystems/proc.txt  |   10 +++++---
 Documentation/filesystems/tmpfs.txt |    4 +++
 fs/proc/task_mmu.c                  |   28 ++++++++++++++++--------
 include/linux/pageteam.h            |   30 ++++++++++++++++++++++++++
 4 files changed, 59 insertions(+), 13 deletions(-)

--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -435,6 +435,7 @@ Private_Dirty:         0 kB
 Referenced:          892 kB
 Anonymous:             0 kB
 AnonHugePages:         0 kB
+ShmemHugePages:        0 kB
 Shared_Hugetlb:        0 kB
 Private_Hugetlb:       0 kB
 Swap:                  0 kB
@@ -462,10 +463,11 @@ accessed.
 "Anonymous" shows the amount of memory that does not belong to any file.  Even
 a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
 and a page is modified, the file page is replaced by a private anonymous copy.
-"AnonHugePages" shows the ammount of memory backed by transparent hugepage.
-"Shared_Hugetlb" and "Private_Hugetlb" show the ammounts of memory backed by
-hugetlbfs page which is *not* counted in "RSS" or "PSS" field for historical
-reasons. And these are not included in {Shared,Private}_{Clean,Dirty} field.
+"AnonHugePages" shows how much of Anonymous is in Transparent Huge Pages, and
+"ShmemHugePages" shows how much of Rss is from huge tmpfs pages mapped by pmd.
+"Shared_Hugetlb" and "Private_Hugetlb" show the amounts of memory backed by
+hugetlbfs pages: which are not counted in "Rss" or "Pss" fields for historical
+reasons; nor are they included in the {Shared,Private}_{Clean,Dirty} fields.
 "Swap" shows how much would-be-anonymous memory is also used, but out on swap.
 For shmem mappings, "Swap" includes also the size of the mapped (and not
 replaced by copy-on-write) part of the underlying shmem object out on swap.
--- a/Documentation/filesystems/tmpfs.txt
+++ b/Documentation/filesystems/tmpfs.txt
@@ -186,6 +186,10 @@ In addition to 0 and 1, it also accepts
 automatically on for all tmpfs mounts (intended for testing), or -1
 to force huge off for all (intended for safety if bugs appeared).
 
+/proc/<pid>/smaps shows:
+
+ShmemHugePages:    10240 kB   tmpfs hugepages mapped by pmd into this region
+
 /proc/meminfo, /sys/devices/system/node/nodeN/meminfo show:
 
 Shmem:             35016 kB   total shmem/tmpfs memory (subset of Cached)
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -14,6 +14,7 @@
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
 #include <linux/page_idle.h>
+#include <linux/pageteam.h>
 #include <linux/shmem_fs.h>
 
 #include <asm/elf.h>
@@ -448,6 +449,7 @@ struct mem_size_stats {
 	unsigned long referenced;
 	unsigned long anonymous;
 	unsigned long anonymous_thp;
+	unsigned long shmem_huge;
 	unsigned long swap;
 	unsigned long shared_hugetlb;
 	unsigned long private_hugetlb;
@@ -457,13 +459,19 @@ struct mem_size_stats {
 };
 
 static void smaps_account(struct mem_size_stats *mss, struct page *page,
-		bool compound, bool young, bool dirty)
+		unsigned long size, bool young, bool dirty)
 {
-	int i, nr = compound ? 1 << compound_order(page) : 1;
-	unsigned long size = nr * PAGE_SIZE;
+	int nr = size / PAGE_SIZE;
+	int i;
 
-	if (PageAnon(page))
+	if (PageAnon(page)) {
 		mss->anonymous += size;
+		if (size > PAGE_SIZE)
+			mss->anonymous_thp += size;
+	} else {
+		if (size > PAGE_SIZE)
+			mss->shmem_huge += size;
+	}
 
 	mss->resident += size;
 	/* Accumulate the size in pages that have been accessed. */
@@ -473,7 +481,7 @@ static void smaps_account(struct mem_siz
 	/*
 	 * page_count(page) == 1 guarantees the page is mapped exactly once.
 	 * If any subpage of the compound page mapped with PTE it would elevate
-	 * page_count().
+	 * page_count().  (This condition is never true of mapped pagecache.)
 	 */
 	if (page_count(page) == 1) {
 		if (dirty || PageDirty(page))
@@ -485,7 +493,7 @@ static void smaps_account(struct mem_siz
 	}
 
 	for (i = 0; i < nr; i++, page++) {
-		int mapcount = page_mapcount(page);
+		int mapcount = team_page_mapcount(page);
 
 		if (mapcount >= 2) {
 			if (dirty || PageDirty(page))
@@ -561,7 +569,7 @@ static void smaps_pte_entry(pte_t *pte,
 	if (!page)
 		return;
 
-	smaps_account(mss, page, false, pte_young(*pte), pte_dirty(*pte));
+	smaps_account(mss, page, PAGE_SIZE, pte_young(*pte), pte_dirty(*pte));
 }
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -576,8 +584,8 @@ static void smaps_pmd_entry(pmd_t *pmd,
 	page = follow_trans_huge_pmd(vma, addr, pmd, FOLL_DUMP);
 	if (IS_ERR_OR_NULL(page))
 		return;
-	mss->anonymous_thp += HPAGE_PMD_SIZE;
-	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd));
+	smaps_account(mss, page, HPAGE_PMD_SIZE,
+			pmd_young(*pmd), pmd_dirty(*pmd));
 }
 #else
 static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
@@ -770,6 +778,7 @@ static int show_smap(struct seq_file *m,
 		   "Referenced:     %8lu kB\n"
 		   "Anonymous:      %8lu kB\n"
 		   "AnonHugePages:  %8lu kB\n"
+		   "ShmemHugePages: %8lu kB\n"
 		   "Shared_Hugetlb: %8lu kB\n"
 		   "Private_Hugetlb: %7lu kB\n"
 		   "Swap:           %8lu kB\n"
@@ -787,6 +796,7 @@ static int show_smap(struct seq_file *m,
 		   mss.referenced >> 10,
 		   mss.anonymous >> 10,
 		   mss.anonymous_thp >> 10,
+		   mss.shmem_huge >> 10,
 		   mss.shared_hugetlb >> 10,
 		   mss.private_hugetlb >> 10,
 		   mss.swap >> 10,
--- a/include/linux/pageteam.h
+++ b/include/linux/pageteam.h
@@ -152,6 +152,36 @@ static inline void count_team_pmd_mapped
 }
 
 /*
+ * Slightly misnamed, team_page_mapcount() returns the number of times
+ * any page is mapped into userspace, either by pte or covered by pmd:
+ * it is a generalization of page_mapcount() to include the case of a
+ * team page.  We don't complicate page_mapcount() itself in this way,
+ * because almost nothing needs this number: only smaps accounting PSS.
+ * If something else wants it, we might have to worry more about races.
+ */
+static inline int team_page_mapcount(struct page *page)
+{
+	struct page *head;
+	long team_usage;
+	int mapcount;
+
+	mapcount = page_mapcount(page);
+	if (!PageTeam(page))
+		return mapcount;
+	head = team_head(page);
+	/* We always page_add_file_rmap to head when we page_add_team_rmap */
+	if (page == head)
+		return mapcount;
+
+	team_usage = atomic_long_read(&head->team_usage) - TEAM_COMPLETE;
+	/* Beware racing shmem_disband_hugehead() and add_to_swap_cache() */
+	smp_rmb();
+	if (PageTeam(head) && team_usage > 0)
+		mapcount += team_usage / TEAM_MAPPING_COUNTER;
+	return mapcount;
+}
+
+/*
  * Returns true if this pte mapping is of a non-team page, or of a team page not
  * covered by an existing huge pmd mapping: whereupon stats need to be updated.
  * Only called when mapcount goes up from 0 to 1 i.e. _mapcount from -1 to 0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
