Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE4E82F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 00:52:56 -0400 (EDT)
Received: by oiev17 with SMTP id v17so44518959oie.2
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 21:52:56 -0700 (PDT)
Received: from mail-ob0-x235.google.com (mail-ob0-x235.google.com. [2607:f8b0:4003:c01::235])
        by mx.google.com with ESMTPS id m130si16205306oif.92.2015.10.18.21.52.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Oct 2015 21:52:55 -0700 (PDT)
Received: by obbwb3 with SMTP id wb3so103814940obb.0
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 21:52:55 -0700 (PDT)
Date: Sun, 18 Oct 2015 21:52:50 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 3/12] mm: page migration fix PageMlocked on migrated pages
In-Reply-To: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1510182150590.2481@eggly.anvils>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org

Commit e6c509f85455 ("mm: use clear_page_mlock() in page_remove_rmap()")
in v3.7 inadvertently made mlock_migrate_page() impotent: page migration
unmaps the page from userspace before migrating, and that commit clears
PageMlocked on the final unmap, leaving mlock_migrate_page() with nothing
to do.  Not a serious bug, the next attempt at reclaiming the page would
fix it up; but a betrayal of page migration's intent - the new page ought
to emerge as PageMlocked.

I don't see how to fix it for mlock_migrate_page() itself; but easily
fixed in remove_migration_pte(), by calling mlock_vma_page() when the
vma is VM_LOCKED - under pte lock as in try_to_unmap_one().

Delete mlock_migrate_page()?  Not quite, it does still serve a purpose
for migrate_misplaced_transhuge_page(): where we could replace it by a
test, clear_page_mlock(), mlock_vma_page() sequence; but would that be
an improvement?  mlock_migrate_page() is fairly lean, and let's make
it leaner by skipping the irq save/restore now clearly not needed.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/internal.h |    9 ++++-----
 mm/migrate.c  |    6 ++++--
 2 files changed, 8 insertions(+), 7 deletions(-)

--- migrat.orig/mm/internal.h	2015-09-12 18:30:20.841039780 -0700
+++ migrat/mm/internal.h	2015-10-18 17:53:11.061322013 -0700
@@ -271,20 +271,19 @@ extern unsigned int munlock_vma_page(str
 extern void clear_page_mlock(struct page *page);
 
 /*
- * mlock_migrate_page - called only from migrate_page_copy() to
- * migrate the Mlocked page flag; update statistics.
+ * mlock_migrate_page - called only from migrate_misplaced_transhuge_page()
+ * (because that does not go through the full procedure of migration ptes):
+ * to migrate the Mlocked page flag; update statistics.
  */
 static inline void mlock_migrate_page(struct page *newpage, struct page *page)
 {
 	if (TestClearPageMlocked(page)) {
-		unsigned long flags;
 		int nr_pages = hpage_nr_pages(page);
 
-		local_irq_save(flags);
+		/* Holding pmd lock, no change in irq context: __mod is safe */
 		__mod_zone_page_state(page_zone(page), NR_MLOCK, -nr_pages);
 		SetPageMlocked(newpage);
 		__mod_zone_page_state(page_zone(newpage), NR_MLOCK, nr_pages);
-		local_irq_restore(flags);
 	}
 }
 
--- migrat.orig/mm/migrate.c	2015-10-04 10:47:52.469445854 -0700
+++ migrat/mm/migrate.c	2015-10-18 17:53:11.062322014 -0700
@@ -171,6 +171,9 @@ static int remove_migration_pte(struct p
 	else
 		page_add_file_rmap(new);
 
+	if (vma->vm_flags & VM_LOCKED)
+		mlock_vma_page(new);
+
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, addr, ptep);
 unlock:
@@ -537,7 +540,6 @@ void migrate_page_copy(struct page *newp
 	cpupid = page_cpupid_xchg_last(page, -1);
 	page_cpupid_xchg_last(newpage, cpupid);
 
-	mlock_migrate_page(newpage, page);
 	ksm_migrate_page(newpage, page);
 	/*
 	 * Please do not reorder this without considering how mm/ksm.c's
@@ -1786,7 +1788,6 @@ fail_putback:
 			SetPageActive(page);
 		if (TestClearPageUnevictable(new_page))
 			SetPageUnevictable(page);
-		mlock_migrate_page(page, new_page);
 
 		unlock_page(new_page);
 		put_page(new_page);		/* Free it */
@@ -1828,6 +1829,7 @@ fail_putback:
 		goto fail_putback;
 	}
 
+	mlock_migrate_page(new_page, page);
 	mem_cgroup_migrate(page, new_page, false);
 
 	page_remove_rmap(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
