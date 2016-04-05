Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id A2B3E6B028B
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:17:49 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id v188so2502263wme.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:17:49 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id n69si21386772wmd.25.2016.04.05.14.17.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:17:48 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id 184so18435245pff.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:17:48 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:17:45 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 05/31] huge tmpfs: avoid team pages in a few places
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051416460.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

A few functions outside of mm/shmem.c must take care not to damage a
team accidentally.  In particular, although huge tmpfs will make its
own use of page migration, we don't want compaction or other users
of page migration to stomp on teams by mistake: backstop checks in
migrate_page_move_mapping() and unmap_and_move() secure most cases,
and an earlier check in isolate_migratepages_block() saves compaction
from wasting time.

These checks are certainly too strong: we shall want NUMA mempolicy
and balancing, and memory hot-remove, and soft-offline of failing
memory, to work with team pages; but defer those to a later series.

Also send PageTeam the slow route, along with PageTransHuge, in
munlock_vma_pages_range(): because __munlock_pagevec_fill() uses
get_locked_pte(), which expects ptes not a huge pmd; and we don't
want to split up a pmd to munlock it.  This avoids a VM_BUG_ON, or
hang on the non-existent ptlock; but there's much more to do later,
to get mlock+munlock working properly.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/compaction.c |    5 +++++
 mm/memcontrol.c |    4 ++--
 mm/migrate.c    |   15 ++++++++++++++-
 mm/mlock.c      |    2 +-
 mm/truncate.c   |    2 +-
 mm/vmscan.c     |    2 ++
 6 files changed, 25 insertions(+), 5 deletions(-)

--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -701,6 +701,11 @@ isolate_migratepages_block(struct compac
 			continue;
 		}
 
+		if (PageTeam(page)) {
+			low_pfn = round_up(low_pfn + 1, HPAGE_PMD_NR) - 1;
+			continue;
+		}
+
 		/*
 		 * Check may be lockless but that's ok as we recheck later.
 		 * It's possible to migrate LRU pages and balloon pages
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4566,8 +4566,8 @@ static enum mc_target_type get_mctgt_typ
 	enum mc_target_type ret = MC_TARGET_NONE;
 
 	page = pmd_page(pmd);
-	VM_BUG_ON_PAGE(!page || !PageHead(page), page);
-	if (!(mc.flags & MOVE_ANON))
+	/* Don't attempt to move huge tmpfs pages yet: can be enabled later */
+	if (!(mc.flags & MOVE_ANON) || !PageAnon(page))
 		return ret;
 	if (page->mem_cgroup == mc.from) {
 		ret = MC_TARGET_PAGE;
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -346,7 +346,7 @@ int migrate_page_move_mapping(struct add
  					page_index(page));
 
 	expected_count += 1 + page_has_private(page);
-	if (page_count(page) != expected_count ||
+	if (page_count(page) != expected_count || PageTeam(page) ||
 		radix_tree_deref_slot_protected(pslot, &mapping->tree_lock) != page) {
 		spin_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;
@@ -944,6 +944,11 @@ static ICE_noinline int unmap_and_move(n
 	if (!newpage)
 		return -ENOMEM;
 
+	if (PageTeam(page)) {
+		rc = -EBUSY;
+		goto out;
+	}
+
 	if (page_count(page) == 1) {
 		/* page was freed from under us. So we are done. */
 		goto out;
@@ -1757,6 +1762,14 @@ int migrate_misplaced_transhuge_page(str
 	pmd_t orig_entry;
 
 	/*
+	 * Leave support for NUMA balancing on huge tmpfs pages to the future.
+	 * The pmd marking up to this point should work okay, but from here on
+	 * there is work to be done: e.g. anon page->mapping assumption below.
+	 */
+	if (!PageAnon(page))
+		goto out_dropref;
+
+	/*
 	 * Rate-limit the amount of data that is being migrated to a node.
 	 * Optimal placement is no good if the memory bus is saturated and
 	 * all the time is being spent migrating!
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -459,7 +459,7 @@ void munlock_vma_pages_range(struct vm_a
 			if (PageTransTail(page)) {
 				VM_BUG_ON_PAGE(PageMlocked(page), page);
 				put_page(page); /* follow_page_mask() */
-			} else if (PageTransHuge(page)) {
+			} else if (PageTransHuge(page) || PageTeam(page)) {
 				lock_page(page);
 				/*
 				 * Any THP page found by follow_page_mask() may
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -528,7 +528,7 @@ invalidate_complete_page2(struct address
 		return 0;
 
 	spin_lock_irqsave(&mapping->tree_lock, flags);
-	if (PageDirty(page))
+	if (PageDirty(page) || PageTeam(page))
 		goto failed;
 
 	BUG_ON(page_has_private(page));
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -638,6 +638,8 @@ static int __remove_mapping(struct addre
 	 * Note that if SetPageDirty is always performed via set_page_dirty,
 	 * and thus under tree_lock, then this ordering is not required.
 	 */
+	if (unlikely(PageTeam(page)))
+		goto cannot_free;
 	if (!page_ref_freeze(page, 2))
 		goto cannot_free;
 	/* note: atomic_cmpxchg in page_freeze_refs provides the smp_rmb */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
