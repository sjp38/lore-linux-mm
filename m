Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 17B656B005A
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 15:36:02 -0500 (EST)
Date: Fri, 21 Dec 2012 20:35:56 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: migrate_misplaced_transhuge_page: no page_count check?
Message-ID: <20121221203556.GF13367@suse.de>
References: <alpine.LNX.2.00.1212192011320.25992@eggly.anvils>
 <20121220164923.GB13367@suse.de>
 <alpine.LNX.2.00.1212211030540.1893@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1212211030540.1893@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Dec 21, 2012 at 10:38:45AM -0800, Hugh Dickins wrote:
> > While we happen to be ok for THP migration versus GUP it is shoddy to
> > depend on such "safety" so this patch checks the page count similar to
> > anonymous pages. Note that this does not mean that the page_mapcount()
> > check can go away. If we were to remove the page_mapcount() check then
> > the THP would have to be unmapped from all referencing PTEs, replaced with
> > migration PTEs and restored properly afterwards.
> > 
> > Reported-by: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> 
> Thanks very much for responding so quickly on this, Mel.  It pains
> me that I cannot yet say acked-by, because I need to spend more time
> checking it, and cannot do so today.
> 
> I like where you've placed the check, that's just right.  But I'm
> worried that perhaps there's a putback_lru_page missing, and wonder
> if it's missing even without this additional patch. 

*hangs head*

Failing to migrate due to GUP needs to put the page back on
the LRU. After this patch;

1. fail to isolate from LRU, old page is still on LRU
2. fail due to GUP or parallel fault, old page is put back on LRU
3. fail because PMD changed while PTL was released, old page put back on LRU
4. Successful migration, new page added to LRU by
   page_add_new_anon_rmap()->lru_cache_add_lru()

---8<---
mm: migrate: Check page_count of THP before migrating

Hugh Dickins poined out that migrate_misplaced_transhuge_page() does not
check page_count before migrating like base page migration and khugepage. He
could not see why this was safe and he is right.

It happens to work for the most part. The page_mapcount() check ensures that
only a single address space is using this page and as THPs are typically
private it should not be possible for another address space to fault it in
parallel. If the address space has one associated task then it's difficult to
have both a GUP pin and be referencing the page at the same time. If there
are multiple tasks then a buggy scenario requires that another thread be
accessing the page while the direct IO is in flight. This is dodgy behaviour
as there is a possibility of corruption with or without THP migration. It
would be difficult to identify the corruption as being a migration bug.

While we happen to be ok for THP migration versus GUP it is shoddy to
depend on such "safety" so this patch checks the page count similar to
anonymous pages. Note that this does not mean that the page_mapcount()
check can go away. If we were to remove the page_mapcount() check the the
THP would have to be unmapped from all referencing PTEs, replaced with
migration PTEs and restored properly afterwards.

Reported-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/migrate.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 3b676b0..f466827 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1679,9 +1679,18 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	page_xchg_last_nid(new_page, page_last_nid(page));
 
 	isolated = numamigrate_isolate_page(pgdat, page);
-	if (!isolated) {
+
+	/*
+	 * Failing to isolate or a GUP pin prevents migration. The expected
+	 * page count is 2. 1 for anonymous pages without a mapping and 1
+	 * for the callers pin. If the page was isolated, the page will
+	 * need to be put back on the LRU.
+	 */
+	if (!isolated || page_count(page) != 2) {
 		count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
 		put_page(new_page);
+		if (isolated)
+			putback_lru_page(page);
 		goto out_keep_locked;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
