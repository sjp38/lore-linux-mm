Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 5B8D86B0022
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 03:24:11 -0500 (EST)
Received: by mail-da0-f50.google.com with SMTP id h15so3962944dan.23
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 00:24:10 -0800 (PST)
Date: Thu, 21 Feb 2013 00:23:29 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 4/7] mm,ksm: FOLL_MIGRATION do migration_entry_wait
In-Reply-To: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils>
Message-ID: <alpine.LNX.2.00.1302210022110.17843@eggly.anvils>
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

In "ksm: remove old stable nodes more thoroughly" I said that I'd never
seen its WARN_ON_ONCE(page_mapped(page)).  True at the time of writing,
but it soon appeared once I tried fuller tests on the whole series.

It turned out to be due to the KSM page migration itself: unmerge_and_
remove_all_rmap_items() failed to locate and replace all the KSM pages,
because of that hiatus in page migration when old pte has been replaced
by migration entry, but not yet by new pte.  follow_page() finds no page
at that instant, but a KSM page reappears shortly after, without a fault.

Add FOLL_MIGRATION flag, so follow_page() can do migration_entry_wait()
for KSM's break_cow().  I'd have preferred to avoid another flag, and do
it every time, in case someone else makes the same easy mistake; but did
not find another transgressor (the common get_user_pages() is of course
safe), and cannot be sure that every follow_page() caller is prepared to
sleep - ia64's xencomm_vtop()?  Now, THP's wait_split_huge_page() can
already sleep there, since anon_vma locking was changed to mutex, but
maybe that's somehow excluded.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/mm.h |    1 +
 mm/ksm.c           |    2 +-
 mm/memory.c        |   20 ++++++++++++++++++--
 3 files changed, 20 insertions(+), 3 deletions(-)

--- mmotm.orig/include/linux/mm.h	2013-02-19 18:51:24.572031860 -0800
+++ mmotm/include/linux/mm.h	2013-02-20 22:42:54.728022096 -0800
@@ -1652,6 +1652,7 @@ static inline struct page *follow_page(s
 #define FOLL_SPLIT	0x80	/* don't return transhuge pages, split them */
 #define FOLL_HWPOISON	0x100	/* check page is hwpoisoned */
 #define FOLL_NUMA	0x200	/* force NUMA hinting page fault */
+#define FOLL_MIGRATION	0x400	/* wait for page to replace migration entry */
 
 typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
--- mmotm.orig/mm/ksm.c	2013-02-20 22:28:29.688001537 -0800
+++ mmotm/mm/ksm.c	2013-02-20 22:50:10.540032454 -0800
@@ -363,7 +363,7 @@ static int break_ksm(struct vm_area_stru
 
 	do {
 		cond_resched();
-		page = follow_page(vma, addr, FOLL_GET);
+		page = follow_page(vma, addr, FOLL_GET | FOLL_MIGRATION);
 		if (IS_ERR_OR_NULL(page))
 			break;
 		if (PageKsm(page))
--- mmotm.orig/mm/memory.c	2013-02-20 22:28:09.168001050 -0800
+++ mmotm/mm/memory.c	2013-02-20 22:43:47.228023344 -0800
@@ -1548,8 +1548,24 @@ split_fallthrough:
 	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
 
 	pte = *ptep;
-	if (!pte_present(pte))
-		goto no_page;
+	if (!pte_present(pte)) {
+		swp_entry_t entry;
+		/*
+		 * KSM's break_ksm() relies upon recognizing a ksm page
+		 * even while it is being migrated, so for that case we
+		 * need migration_entry_wait().
+		 */
+		if (likely(!(flags & FOLL_MIGRATION)))
+			goto no_page;
+		if (pte_none(pte) || pte_file(pte))
+			goto no_page;
+		entry = pte_to_swp_entry(pte);
+		if (!is_migration_entry(entry))
+			goto no_page;
+		pte_unmap_unlock(ptep, ptl);
+		migration_entry_wait(mm, pmd, address);
+		goto split_fallthrough;
+	}
 	if ((flags & FOLL_NUMA) && pte_numa(pte))
 		goto no_page;
 	if ((flags & FOLL_WRITE) && !pte_write(pte))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
