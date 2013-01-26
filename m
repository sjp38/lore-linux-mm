Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id B96C06B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 21:06:23 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id fa10so582938pad.20
        for <linux-mm@kvack.org>; Fri, 25 Jan 2013 18:06:22 -0800 (PST)
Date: Fri, 25 Jan 2013 18:06:24 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 9/11] ksm: enable KSM page migration
In-Reply-To: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
Message-ID: <alpine.LNX.2.00.1301251805080.29196@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Migration of KSM pages is now safe: remove the PageKsm restrictions from
mempolicy.c and migrate.c.

But keep PageKsm out of __unmap_and_move()'s anon_vma contortions, which
are irrelevant to KSM: it looks as if that code was preventing hotremove
migration of KSM pages, unless they happened to be in swapcache.

There is some question as to whether enforcing a NUMA mempolicy migration
ought to migrate KSM pages, mapped into entirely unrelated processes; but
moving page_mapcount > 1 is only permitted with MPOL_MF_MOVE_ALL anyway,
and it seems reasonable to assume that you wouldn't set MADV_MERGEABLE on
any area where this is a worry.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/mempolicy.c |    3 +--
 mm/migrate.c   |   21 +++------------------
 2 files changed, 4 insertions(+), 20 deletions(-)

--- mmotm.orig/mm/mempolicy.c	2013-01-24 12:28:38.848127553 -0800
+++ mmotm/mm/mempolicy.c	2013-01-25 14:38:49.596208731 -0800
@@ -496,9 +496,8 @@ static int check_pte_range(struct vm_are
 		/*
 		 * vm_normal_page() filters out zero pages, but there might
 		 * still be PageReserved pages to skip, perhaps in a VDSO.
-		 * And we cannot move PageKsm pages sensibly or safely yet.
 		 */
-		if (PageReserved(page) || PageKsm(page))
+		if (PageReserved(page))
 			continue;
 		nid = page_to_nid(page);
 		if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
--- mmotm.orig/mm/migrate.c	2013-01-25 14:37:03.832206218 -0800
+++ mmotm/mm/migrate.c	2013-01-25 14:38:49.596208731 -0800
@@ -731,20 +731,6 @@ static int __unmap_and_move(struct page
 		lock_page(page);
 	}
 
-	/*
-	 * Only memory hotplug's offline_pages() caller has locked out KSM,
-	 * and can safely migrate a KSM page.  The other cases have skipped
-	 * PageKsm along with PageReserved - but it is only now when we have
-	 * the page lock that we can be certain it will not go KSM beneath us
-	 * (KSM will not upgrade a page from PageAnon to PageKsm when it sees
-	 * its pagecount raised, but only here do we take the page lock which
-	 * serializes that).
-	 */
-	if (PageKsm(page) && !offlining) {
-		rc = -EBUSY;
-		goto unlock;
-	}
-
 	/* charge against new page */
 	mem_cgroup_prepare_migration(page, newpage, &mem);
 
@@ -771,7 +757,7 @@ static int __unmap_and_move(struct page
 	 * File Caches may use write_page() or lock_page() in migration, then,
 	 * just care Anon page here.
 	 */
-	if (PageAnon(page)) {
+	if (PageAnon(page) && !PageKsm(page)) {
 		/*
 		 * Only page_lock_anon_vma_read() understands the subtleties of
 		 * getting a hold on an anon_vma from outside one of its mms.
@@ -851,7 +837,6 @@ uncharge:
 	mem_cgroup_end_migration(mem, page, newpage,
 				 (rc == MIGRATEPAGE_SUCCESS ||
 				  rc == MIGRATEPAGE_BALLOON_SUCCESS));
-unlock:
 	unlock_page(page);
 out:
 	return rc;
@@ -1156,7 +1141,7 @@ static int do_move_page_to_node_array(st
 			goto set_status;
 
 		/* Use PageReserved to check for zero page */
-		if (PageReserved(page) || PageKsm(page))
+		if (PageReserved(page))
 			goto put_and_set;
 
 		pp->page = page;
@@ -1318,7 +1303,7 @@ static void do_pages_stat_array(struct m
 
 		err = -ENOENT;
 		/* Use PageReserved to check for zero page */
-		if (!page || PageReserved(page) || PageKsm(page))
+		if (!page || PageReserved(page))
 			goto set_status;
 
 		err = page_to_nid(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
