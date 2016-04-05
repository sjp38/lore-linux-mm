Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 22F4B6B02A0
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:37:07 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id c20so18695627pfc.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:37:07 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id ku9si10091242pab.99.2016.04.05.14.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:37:05 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id bx7so2228439pad.3
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:37:05 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:37:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 15/31] huge tmpfs: fix Mapped meminfo, track huge & unhuge
 mappings
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051435460.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Maintaining Mlocked was the difficult one, but now that it is correctly
tracked, without duplication between the 4kB and 2MB amounts, I think
we have to make a similar effort with Mapped.

But whereas mlock and munlock were already rare and slow operations,
to which we could fairly add a little more overhead in the huge tmpfs
case, ordinary mmap is not something we want to slow down further,
relative to hugetlbfs.

In the Mapped case, I think we can take small or misaligned mmaps of
huge tmpfs files as the exceptional operation, and add a little more
overhead to those, by maintaining another count for them in the head;
and by keeping both hugely and unhugely mapped counts in the one long,
can rely on cmpxchg to manage their racing transitions atomically.

That's good on 64-bit, but there are not enough free bits in a 32-bit
atomic_long_t team_usage to support this: I think we should continue
to permit huge tmpfs on 32-bit, but accept that Mapped may be doubly
counted there.  (A more serious problem on 32-bit is that it would,
I think, be possible to overflow the huge mapping counter: protection
against that will need to be added.)

Now that we are maintaining NR_FILE_MAPPED correctly for huge
tmpfs, adjust vmscan's zone_unmapped_file_pages() to exclude
NR_SHMEM_PMDMAPPED, which it clearly would not want included.
Whereas minimum_image_size() in kernel/power/snapshot.c?  I have
not grasped the basis for that calculation, so leaving untouched.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/memcontrol.h |    5 +
 include/linux/pageteam.h   |  144 ++++++++++++++++++++++++++++++++---
 mm/huge_memory.c           |   34 +++++++-
 mm/rmap.c                  |   10 +-
 mm/vmscan.c                |    6 +
 5 files changed, 180 insertions(+), 19 deletions(-)

--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -700,6 +700,11 @@ static inline bool mem_cgroup_oom_synchr
 	return false;
 }
 
+static inline void mem_cgroup_update_page_stat(struct page *page,
+				enum mem_cgroup_stat_index idx, int val)
+{
+}
+
 static inline void mem_cgroup_inc_page_stat(struct page *page,
 					    enum mem_cgroup_stat_index idx)
 {
--- a/include/linux/pageteam.h
+++ b/include/linux/pageteam.h
@@ -30,6 +30,30 @@ static inline struct page *team_head(str
 }
 
 /*
+ * Layout of team head's page->team_usage field, as on x86_64 and arm64_4K:
+ *
+ *  63        32 31          22 21      12     11         10    9          0
+ * +------------+--------------+----------+----------+---------+------------+
+ * | pmd_mapped & instantiated |pte_mapped| reserved | mlocked | lru_weight |
+ * |   42 bits       10 bits   |  10 bits |  1 bit   |  1 bit  |   10 bits  |
+ * +------------+--------------+----------+----------+---------+------------+
+ *
+ * TEAM_LRU_WEIGHT_ONE               1  (1<<0)
+ * TEAM_LRU_WEIGHT_MASK            3ff  (1<<10)-1
+ * TEAM_PMD_MLOCKED                400  (1<<10)
+ * TEAM_RESERVED_FLAG              800  (1<<11)
+ * TEAM_PTE_COUNTER               1000  (1<<12)
+ * TEAM_PTE_MASK                3ff000  (1<<22)-(1<<12)
+ * TEAM_PAGE_COUNTER            400000  (1<<22)
+ * TEAM_COMPLETE              80000000  (1<<31)
+ * TEAM_MAPPING_COUNTER         400000  (1<<22)
+ * TEAM_PMD_MAPPED            80400000  (1<<31)
+ *
+ * The upper bits count up to TEAM_COMPLETE as pages are instantiated,
+ * and then, above TEAM_COMPLETE, they count huge mappings of the team.
+ * Team tails have team_usage either 1 (lru_weight 1) or 0 (lru_weight 0).
+ */
+/*
  * Mask for lower bits of team_usage, giving the weight 0..HPAGE_PMD_NR of the
  * page on its LRU: normal pages have weight 1, tails held unevictable until
  * head is evicted have weight 0, and the head gathers weight 1..HPAGE_PMD_NR.
@@ -42,8 +66,22 @@ static inline struct page *team_head(str
  */
 #define TEAM_PMD_MLOCKED	(1L << (HPAGE_PMD_ORDER + 1))
 #define TEAM_RESERVED_FLAG	(1L << (HPAGE_PMD_ORDER + 2))
-
+#ifdef CONFIG_64BIT
+/*
+ * Count how many pages of team are individually mapped into userspace.
+ */
+#define TEAM_PTE_COUNTER	(1L << (HPAGE_PMD_ORDER + 3))
+#define TEAM_HIGH_COUNTER	(1L << (2*HPAGE_PMD_ORDER + 4))
+#define TEAM_PTE_MASK		(TEAM_HIGH_COUNTER - TEAM_PTE_COUNTER)
+#define team_pte_count(usage)	(((usage) & TEAM_PTE_MASK) / TEAM_PTE_COUNTER)
+#else /* 32-bit */
+/*
+ * Not enough bits in atomic_long_t: we prefer not to bloat struct page just to
+ * avoid duplication in Mapped, when a page is mapped both hugely and unhugely.
+ */
 #define TEAM_HIGH_COUNTER	(1L << (HPAGE_PMD_ORDER + 3))
+#define team_pte_count(usage)	1 /* allows for the extra page_add_file_rmap */
+#endif /* CONFIG_64BIT */
 /*
  * Count how many pages of team are instantiated, as it is built up.
  */
@@ -66,22 +104,110 @@ static inline bool team_pmd_mapped(struc
 
 /*
  * Returns true if this was the first mapping by pmd, whereupon mapped stats
- * need to be updated.
+ * need to be updated.  Together with the number of pages which then need
+ * to be accounted (can be ignored when false returned): because some team
+ * members may have been mapped unhugely by pte, so already counted as Mapped.
  */
-static inline bool inc_team_pmd_mapped(struct page *head)
+static inline bool inc_team_pmd_mapped(struct page *head, int *nr_pages)
 {
-	return atomic_long_add_return(TEAM_MAPPING_COUNTER, &head->team_usage)
-		< TEAM_PMD_MAPPED + TEAM_MAPPING_COUNTER;
+	long team_usage;
+
+	team_usage = atomic_long_add_return(TEAM_MAPPING_COUNTER,
+					    &head->team_usage);
+	*nr_pages = HPAGE_PMD_NR - team_pte_count(team_usage);
+	return team_usage < TEAM_PMD_MAPPED + TEAM_MAPPING_COUNTER;
 }
 
 /*
  * Returns true if this was the last mapping by pmd, whereupon mapped stats
- * need to be updated.
+ * need to be updated.  Together with the number of pages which then need
+ * to be accounted (can be ignored when false returned): because some team
+ * members may still be mapped unhugely by pte, so remain counted as Mapped.
+ */
+static inline bool dec_team_pmd_mapped(struct page *head, int *nr_pages)
+{
+	long team_usage;
+
+	team_usage = atomic_long_sub_return(TEAM_MAPPING_COUNTER,
+					    &head->team_usage);
+	*nr_pages = HPAGE_PMD_NR - team_pte_count(team_usage);
+	return team_usage < TEAM_PMD_MAPPED;
+}
+
+/*
+ * Returns true if this pte mapping is of a non-team page, or of a team page not
+ * covered by an existing huge pmd mapping: whereupon stats need to be updated.
+ * Only called when mapcount goes up from 0 to 1 i.e. _mapcount from -1 to 0.
+ */
+static inline bool inc_team_pte_mapped(struct page *page)
+{
+#ifdef CONFIG_64BIT
+	struct page *head;
+	long team_usage;
+	long old;
+
+	if (likely(!PageTeam(page)))
+		return true;
+	head = team_head(page);
+	team_usage = atomic_long_read(&head->team_usage);
+	for (;;) {
+		/* Is team now being disbanded? Stop once team_usage is reset */
+		if (unlikely(!PageTeam(head) ||
+			     team_usage / TEAM_PAGE_COUNTER == 0))
+			return true;
+		/*
+		 * XXX: but despite the impressive-looking cmpxchg, gthelen
+		 * points out that head might be freed and reused and assigned
+		 * a matching value in ->private now: tiny chance, must revisit.
+		 */
+		old = atomic_long_cmpxchg(&head->team_usage,
+			team_usage, team_usage + TEAM_PTE_COUNTER);
+		if (likely(old == team_usage))
+			break;
+		team_usage = old;
+	}
+	return team_usage < TEAM_PMD_MAPPED;
+#else /* 32-bit */
+	return true;
+#endif
+}
+
+/*
+ * Returns true if this pte mapping is of a non-team page, or of a team page not
+ * covered by a remaining huge pmd mapping: whereupon stats need to be updated.
+ * Only called when mapcount goes down from 1 to 0 i.e. _mapcount from 0 to -1.
  */
-static inline bool dec_team_pmd_mapped(struct page *head)
+static inline bool dec_team_pte_mapped(struct page *page)
 {
-	return atomic_long_sub_return(TEAM_MAPPING_COUNTER, &head->team_usage)
-		< TEAM_PMD_MAPPED;
+#ifdef CONFIG_64BIT
+	struct page *head;
+	long team_usage;
+	long old;
+
+	if (likely(!PageTeam(page)))
+		return true;
+	head = team_head(page);
+	team_usage = atomic_long_read(&head->team_usage);
+	for (;;) {
+		/* Is team now being disbanded? Stop once team_usage is reset */
+		if (unlikely(!PageTeam(head) ||
+			     team_usage / TEAM_PAGE_COUNTER == 0))
+			return true;
+		/*
+		 * XXX: but despite the impressive-looking cmpxchg, gthelen
+		 * points out that head might be freed and reused and assigned
+		 * a matching value in ->private now: tiny chance, must revisit.
+		 */
+		old = atomic_long_cmpxchg(&head->team_usage,
+			team_usage, team_usage - TEAM_PTE_COUNTER);
+		if (likely(old == team_usage))
+			break;
+		team_usage = old;
+	}
+	return team_usage < TEAM_PMD_MAPPED;
+#else /* 32-bit */
+	return true;
+#endif
 }
 
 static inline void inc_lru_weight(struct page *head)
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1130,9 +1130,11 @@ int copy_huge_pmd(struct mm_struct *dst_
 			pmdp_set_wrprotect(src_mm, addr, src_pmd);
 			pmd = pmd_wrprotect(pmd);
 		} else {
+			int nr_pages;	/* not interesting here */
+
 			VM_BUG_ON_PAGE(!PageTeam(src_page), src_page);
 			page_dup_rmap(src_page, false);
-			inc_team_pmd_mapped(src_page);
+			inc_team_pmd_mapped(src_page, &nr_pages);
 		}
 		add_mm_counter(dst_mm, mm_counter(src_page), HPAGE_PMD_NR);
 		atomic_long_inc(&dst_mm->nr_ptes);
@@ -3499,18 +3501,40 @@ late_initcall(split_huge_pages_debugfs);
 
 static void page_add_team_rmap(struct page *page)
 {
+	int nr_pages;
+
 	VM_BUG_ON_PAGE(PageAnon(page), page);
 	VM_BUG_ON_PAGE(!PageTeam(page), page);
-	if (inc_team_pmd_mapped(page))
-		__inc_zone_page_state(page, NR_SHMEM_PMDMAPPED);
+
+	lock_page_memcg(page);
+	if (inc_team_pmd_mapped(page, &nr_pages)) {
+		struct zone *zone = page_zone(page);
+
+		__inc_zone_state(zone, NR_SHMEM_PMDMAPPED);
+		__mod_zone_page_state(zone, NR_FILE_MAPPED, nr_pages);
+		mem_cgroup_update_page_stat(page,
+				MEM_CGROUP_STAT_FILE_MAPPED, nr_pages);
+	}
+	unlock_page_memcg(page);
 }
 
 static void page_remove_team_rmap(struct page *page)
 {
+	int nr_pages;
+
 	VM_BUG_ON_PAGE(PageAnon(page), page);
 	VM_BUG_ON_PAGE(!PageTeam(page), page);
-	if (dec_team_pmd_mapped(page))
-		__dec_zone_page_state(page, NR_SHMEM_PMDMAPPED);
+
+	lock_page_memcg(page);
+	if (dec_team_pmd_mapped(page, &nr_pages)) {
+		struct zone *zone = page_zone(page);
+
+		__dec_zone_state(zone, NR_SHMEM_PMDMAPPED);
+		__mod_zone_page_state(zone, NR_FILE_MAPPED, -nr_pages);
+		mem_cgroup_update_page_stat(page,
+				MEM_CGROUP_STAT_FILE_MAPPED, -nr_pages);
+	}
+	unlock_page_memcg(page);
 }
 
 int map_team_by_pmd(struct vm_area_struct *vma, unsigned long addr,
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1272,7 +1272,8 @@ void page_add_new_anon_rmap(struct page
 void page_add_file_rmap(struct page *page)
 {
 	lock_page_memcg(page);
-	if (atomic_inc_and_test(&page->_mapcount)) {
+	if (atomic_inc_and_test(&page->_mapcount) &&
+	    inc_team_pte_mapped(page)) {
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
 		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
 	}
@@ -1299,9 +1300,10 @@ static void page_remove_file_rmap(struct
 	 * these counters are not modified in interrupt context, and
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
-	__dec_zone_page_state(page, NR_FILE_MAPPED);
-	mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
-
+	if (dec_team_pte_mapped(page)) {
+		__dec_zone_page_state(page, NR_FILE_MAPPED);
+		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
+	}
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
 out:
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3685,8 +3685,12 @@ static inline unsigned long zone_unmappe
 	/*
 	 * It's possible for there to be more file mapped pages than
 	 * accounted for by the pages on the file LRU lists because
-	 * tmpfs pages accounted for as ANON can also be FILE_MAPPED
+	 * tmpfs pages accounted for as ANON can also be FILE_MAPPED.
+	 * We don't know how many, beyond the PMDMAPPED excluded below.
 	 */
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
+		file_mapped -= zone_page_state(zone, NR_SHMEM_PMDMAPPED) <<
+							HPAGE_PMD_ORDER;
 	return (file_lru > file_mapped) ? (file_lru - file_mapped) : 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
