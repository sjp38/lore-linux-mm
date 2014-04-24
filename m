Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4B93C6B0036
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 11:39:20 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id b57so1993100eek.7
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 08:39:19 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si8831616eef.352.2014.04.24.08.39.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 08:39:18 -0700 (PDT)
Date: Thu, 24 Apr 2014 16:39:14 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: numa: Add migrated transhuge pages to LRU the same way
 as base pages
Message-ID: <20140424153914.GW23991@suse.de>
References: <1396235259-2394-1-git-send-email-bob.liu@oracle.com>
 <alpine.LSU.2.11.1404042358030.12542@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1404042358030.12542@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: riel@redhat.com, sasha.levin@oracle.com, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <lkml@vger.kernel.org>

Migration of misplaced transhuge pages uses page_add_new_anon_rmap() when
putting the page back as it avoided an atomic operations and added the
new page to the correct LRU. A side-effect is that the page gets marked
activated as part of the migration meaning that transhuge and base pages
are treated differently from an aging perspective than base page migration.

This patch uses page_add_anon_rmap() and putback_lru_page() on completion of
a transhuge migration similar to base page migration. It would fewer atomic
operations to use lru_cache_add without taking an additional reference to the
page. The downside would be that it's still different to base page migration
and unevictable pages may be added to the wrong LRU for cleaning up later.
Testing of the usual workloads did not show any adverse impact to the
change.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/migrate.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index bed4880..6247be7 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1852,7 +1852,7 @@ fail_putback:
 	 * guarantee the copy is visible before the pagetable update.
 	 */
 	flush_cache_range(vma, mmun_start, mmun_end);
-	page_add_new_anon_rmap(new_page, vma, mmun_start);
+	page_add_anon_rmap(new_page, vma, mmun_start);
 	pmdp_clear_flush(vma, mmun_start, pmd);
 	set_pmd_at(mm, mmun_start, pmd, entry);
 	flush_tlb_range(vma, mmun_start, mmun_end);
@@ -1877,6 +1877,10 @@ fail_putback:
 	spin_unlock(ptl);
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
+	/* Take an "isolate" reference and put new page on the LRU. */
+	get_page(new_page);
+	putback_lru_page(new_page);
+
 	unlock_page(new_page);
 	unlock_page(page);
 	put_page(page);			/* Drop the rmap reference */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
