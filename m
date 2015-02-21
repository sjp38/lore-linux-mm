Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 05CA96B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:27:14 -0500 (EST)
Received: by padbj1 with SMTP id bj1so12954638pad.5
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:27:13 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id pu6si277732pac.220.2015.02.20.20.27.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:27:13 -0800 (PST)
Received: by pablf10 with SMTP id lf10so12869579pab.12
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:27:12 -0800 (PST)
Date: Fri, 20 Feb 2015 20:27:10 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 22/24] huge tmpfs: fix Mapped meminfo, tracking huge and
 unhuge mappings
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202025260.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

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
 include/linux/pageteam.h   |  152 ++++++++++++++++++++++++++++++++---
 mm/huge_memory.c           |   40 ++++++++-
 mm/rmap.c                  |   10 +-
 mm/vmscan.c                |    6 +
 5 files changed, 194 insertions(+), 19 deletions(-)

--- thpfs.orig/include/linux/memcontrol.h	2015-02-20 19:33:31.052085168 -0800
+++ thpfs/include/linux/memcontrol.h	2015-02-20 19:35:15.207847015 -0800
@@ -308,6 +308,11 @@ static inline bool mem_cgroup_oom_synchr
 	return false;
 }
 
+static inline void mem_cgroup_update_page_stat(struct mem_cgroup *memcg,
+				 enum mem_cgroup_stat_index idx, int val)
+{
+}
+
 static inline void mem_cgroup_inc_page_stat(struct mem_cgroup *memcg,
 					    enum mem_cgroup_stat_index idx)
 {
--- thpfs.orig/include/linux/pageteam.h	2015-02-20 19:35:09.991858941 -0800
+++ thpfs/include/linux/pageteam.h	2015-02-20 19:35:15.207847015 -0800
@@ -30,6 +30,30 @@ static inline struct page *team_head(str
 }
 
 /*
+ * Layout of team head's page->team_usage field, as on x86_64 and arm64_4K:
+ *
+ *  63        32 31          22 21      12     11         10    9          0
+ * +------------+--------------+----------+----------+---------+------------+
+ * | pmd_mapped & instantiated | unhugely | reserved | mlocked | lru_weight |
+ * |   42 bits       10 bits   |  10 bits |  1 bit   |  1 bit  |   10 bits  |
+ * +------------+--------------+----------+----------+---------+------------+
+ *
+ * TEAM_LRU_WEIGHT_ONE               1  (1<<0)
+ * TEAM_LRU_WEIGHT_MASK            3ff  (1<<10)-1
+ * TEAM_HUGELY_MLOCKED             400  (1<<10)
+ * TEAM_RESERVED_FLAG              800  (1<<11)
+ * TEAM_UNHUGELY_COUNTER          1000  (1<<12)
+ * TEAM_UNHUGELY_MASK           3ff000  (1<<22)-(1<<12)
+ * TEAM_PAGE_COUNTER            400000  (1<<22)
+ * TEAM_COMPLETE              80000000  (1<<31)
+ * TEAM_MAPPING_COUNTER         400000  (1<<22)
+ * TEAM_HUGELY_MAPPED         80400000  (1<<31)
+ *
+ * The upper bits count up to TEAM_COMPLETE as pages are instantiated,
+ * and then, above TEAM_COMPLETE, they count huge mappings of the team.
+ * Team tails have team_usage either 1 (lru_weight 1) or 0 (lru_weight 0).
+ */
+/*
  * Mask for lower bits of team_usage, giving the weight 0..HPAGE_PMD_NR of the
  * page on its LRU: normal pages have weight 1, tails held unevictable until
  * head is evicted have weight 0, and the head gathers weight 1..HPAGE_PMD_NR.
@@ -42,8 +66,20 @@ static inline struct page *team_head(str
  */
 #define TEAM_HUGELY_MLOCKED	(1L << (HPAGE_PMD_ORDER + 1))
 #define TEAM_RESERVED_FLAG	(1L << (HPAGE_PMD_ORDER + 2))
-
+#ifdef CONFIG_64BIT
+/*
+ * Count how many pages of team are individually mapped into userspace.
+ */
+#define TEAM_UNHUGELY_COUNTER	(1L << (HPAGE_PMD_ORDER + 3))
+#define TEAM_HIGH_COUNTER	(1L << (2*HPAGE_PMD_ORDER + 4))
+#define TEAM_UNHUGELY_MASK	(TEAM_HIGH_COUNTER - TEAM_UNHUGELY_COUNTER)
+#else /* 32-bit */
+/*
+ * Not enough bits in atomic_long_t: we prefer not to bloat struct page just to
+ * avoid duplication in Mapped, when a page is mapped both hugely and unhugely.
+ */
 #define TEAM_HIGH_COUNTER	(1L << (HPAGE_PMD_ORDER + 3))
+#endif /* CONFIG_64BIT */
 /*
  * Count how many pages of team are instantiated, as it is built up.
  */
@@ -66,22 +102,120 @@ static inline bool team_hugely_mapped(st
 
 /*
  * Returns true if this was the first mapping by pmd, whereupon mapped stats
- * need to be updated.
+ * need to be updated.  Together with the number of pages which then need
+ * to be accounted (can be ignored when false returned): because some team
+ * members may have been mapped unhugely by pte, so already counted as Mapped.
  */
-static inline bool inc_hugely_mapped(struct page *head)
+static inline bool inc_hugely_mapped(struct page *head, int *nr_pages)
 {
-	return atomic_long_add_return(TEAM_MAPPING_COUNTER, &head->team_usage)
-		< TEAM_HUGELY_MAPPED + TEAM_MAPPING_COUNTER;
+	long team_usage;
+
+	team_usage = atomic_long_add_return(TEAM_MAPPING_COUNTER,
+					    &head->team_usage);
+	*nr_pages = HPAGE_PMD_NR -
+#ifdef CONFIG_64BIT
+		(team_usage & TEAM_UNHUGELY_MASK) / TEAM_UNHUGELY_COUNTER;
+#else
+		1;	/* 1 allows for the additional page_add_file_rmap() */
+#endif
+	return team_usage < TEAM_HUGELY_MAPPED + TEAM_MAPPING_COUNTER;
 }
 
 /*
  * Returns true if this was the last mapping by pmd, whereupon mapped stats
- * need to be updated.
+ * need to be updated.  Together with the number of pages which then need
+ * to be accounted (can be ignored when false returned): because some team
+ * members may still be mapped unhugely by pte, so remain counted as Mapped.
+ */
+static inline bool dec_hugely_mapped(struct page *head, int *nr_pages)
+{
+	long team_usage;
+
+	team_usage = atomic_long_sub_return(TEAM_MAPPING_COUNTER,
+					    &head->team_usage);
+	*nr_pages = HPAGE_PMD_NR -
+#ifdef CONFIG_64BIT
+		(team_usage & TEAM_UNHUGELY_MASK) / TEAM_UNHUGELY_COUNTER;
+#else
+		1;	/* 1 allows for the additional page_remove_rmap() */
+#endif
+	return team_usage < TEAM_HUGELY_MAPPED;
+}
+
+/*
+ * Returns true if this pte mapping is of a non-team page, or of a team page not
+ * covered by an existing huge pmd mapping: whereupon stats need to be updated.
+ * Only called when mapcount goes up from 0 to 1 i.e. _mapcount from -1 to 0.
+ */
+static inline bool inc_unhugely_mapped(struct page *page)
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
+			team_usage, team_usage + TEAM_UNHUGELY_COUNTER);
+		if (likely(old == team_usage))
+			break;
+		team_usage = old;
+	}
+	return team_usage < TEAM_HUGELY_MAPPED;
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
-static inline bool dec_hugely_mapped(struct page *head)
+static inline bool dec_unhugely_mapped(struct page *page)
 {
-	return atomic_long_sub_return(TEAM_MAPPING_COUNTER, &head->team_usage)
-		< TEAM_HUGELY_MAPPED;
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
+			team_usage, team_usage - TEAM_UNHUGELY_COUNTER);
+		if (likely(old == team_usage))
+			break;
+		team_usage = old;
+	}
+	return team_usage < TEAM_HUGELY_MAPPED + TEAM_MAPPING_COUNTER;
+#else /* 32-bit */
+	return true;
+#endif
 }
 
 static inline void inc_lru_weight(struct page *head)
--- thpfs.orig/mm/huge_memory.c	2015-02-20 19:35:09.991858941 -0800
+++ thpfs/mm/huge_memory.c	2015-02-20 19:35:15.207847015 -0800
@@ -913,8 +913,10 @@ int copy_huge_pmd(struct mm_struct *dst_
 		pmdp_set_wrprotect(src_mm, addr, src_pmd);
 		pmd = pmd_wrprotect(pmd);
 	} else {
+		int nr_pages;	/* not interesting here */
+
 		VM_BUG_ON_PAGE(!PageTeam(src_page), src_page);
-		inc_hugely_mapped(src_page);
+		inc_hugely_mapped(src_page, &nr_pages);
 	}
 	add_mm_counter(dst_mm, PageAnon(src_page) ?
 		MM_ANONPAGES : MM_FILEPAGES, HPAGE_PMD_NR);
@@ -3016,18 +3018,46 @@ void __vma_adjust_trans_huge(struct vm_a
 
 static void page_add_team_rmap(struct page *page)
 {
+	struct mem_cgroup *memcg;
+	unsigned long flags;
+	bool locked;
+	int nr_pages;
+
 	VM_BUG_ON_PAGE(PageAnon(page), page);
 	VM_BUG_ON_PAGE(!PageTeam(page), page);
-	if (inc_hugely_mapped(page))
-		__inc_zone_page_state(page, NR_SHMEM_PMDMAPPED);
+
+	memcg = mem_cgroup_begin_page_stat(page, &locked, &flags);
+	if (inc_hugely_mapped(page, &nr_pages)) {
+		struct zone *zone = page_zone(page);
+
+		__inc_zone_state(zone, NR_SHMEM_PMDMAPPED);
+		__mod_zone_page_state(zone, NR_FILE_MAPPED, nr_pages);
+		mem_cgroup_update_page_stat(memcg,
+				MEM_CGROUP_STAT_FILE_MAPPED, nr_pages);
+	}
+	mem_cgroup_end_page_stat(memcg, &locked, &flags);
 }
 
 static void page_remove_team_rmap(struct page *page)
 {
+	struct mem_cgroup *memcg;
+	unsigned long flags;
+	bool locked;
+	int nr_pages;
+
 	VM_BUG_ON_PAGE(PageAnon(page), page);
 	VM_BUG_ON_PAGE(!PageTeam(page), page);
-	if (dec_hugely_mapped(page))
-		__dec_zone_page_state(page, NR_SHMEM_PMDMAPPED);
+
+	memcg = mem_cgroup_begin_page_stat(page, &locked, &flags);
+	if (dec_hugely_mapped(page, &nr_pages)) {
+		struct zone *zone = page_zone(page);
+
+		__dec_zone_state(zone, NR_SHMEM_PMDMAPPED);
+		__mod_zone_page_state(zone, NR_FILE_MAPPED, -nr_pages);
+		mem_cgroup_update_page_stat(memcg,
+				MEM_CGROUP_STAT_FILE_MAPPED, -nr_pages);
+	}
+	mem_cgroup_end_page_stat(memcg, &locked, &flags);
 }
 
 int map_team_by_pmd(struct vm_area_struct *vma, unsigned long addr,
--- thpfs.orig/mm/rmap.c	2015-02-20 19:35:09.995858933 -0800
+++ thpfs/mm/rmap.c	2015-02-20 19:35:15.207847015 -0800
@@ -1116,7 +1116,8 @@ void page_add_file_rmap(struct page *pag
 	bool locked;
 
 	memcg = mem_cgroup_begin_page_stat(page, &locked, &flags);
-	if (atomic_inc_and_test(&page->_mapcount)) {
+	if (atomic_inc_and_test(&page->_mapcount) &&
+	    inc_unhugely_mapped(page)) {
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
 		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
 	}
@@ -1144,9 +1145,10 @@ static void page_remove_file_rmap(struct
 	 * these counters are not modified in interrupt context, and
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
-	__dec_zone_page_state(page, NR_FILE_MAPPED);
-	mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
-
+	if (dec_unhugely_mapped(page)) {
+		__dec_zone_page_state(page, NR_FILE_MAPPED);
+		mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
+	}
 	if (unlikely(PageMlocked(page)))
 		clear_page_mlock(page);
 out:
--- thpfs.orig/mm/vmscan.c	2015-02-20 19:35:04.307871938 -0800
+++ thpfs/mm/vmscan.c	2015-02-20 19:35:15.211847007 -0800
@@ -3602,8 +3602,12 @@ static inline unsigned long zone_unmappe
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
