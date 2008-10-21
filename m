From: Johannes Weiner <hannes@saeurebad.de>
Subject: [patch] mm: more likely reclaim MADV_SEQUENTIAL mappings II
References: <87d4hugrwm.fsf@saeurebad.de>
	<20081021104357.GA12329@wotan.suse.de>
Date: Tue, 21 Oct 2008 13:33:45 +0200
In-Reply-To: <20081021104357.GA12329@wotan.suse.de> (Nick Piggin's message of
	"Tue, 21 Oct 2008 12:43:57 +0200")
Message-ID: <878wsigp2e.fsf_-_@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> writes:

>> I'm afraid this is now quite a bit more aggressive than the earlier
>> version.  When the fault path did a mark_page_access(), we wouldn't
>> reclaim a page when it has been faulted into several MADV_SEQUENTIAL
>> mappings but now we ignore *every* activity through such a mapping.
>> 
>> What do you think?
>
> I think it's OK. MADV_SEQUENTIAL man page explicitly states they can
> soon be freed, and we won't DoS anybody else's working set because we
> are only ignoring referenced from MADV_SEQUENTIAL ptes.
>
> It's annoying to put in extra banches especially in the unmap path.
> Oh well... (at least if you can mark them as likely()).

Okay, added those.  Second round:

---
File pages mapped only in sequentially read mappings are perfect
reclaim canditates.

This makes MADV_SEQUENTIAL mappings behave like a weak references,
their pages will be reclaimed unless they have a strong reference from
a normal mapping as well.

The patch changes the reclaim and the unmap path where they check if
the page has been referenced.  In both cases, accesses through
sequentially read mappings will be ignored.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---
II: add likely()s to mitigate the extra branches a bit as to Nick's
    suggestion

 mm/memory.c |    3 ++-
 mm/rmap.c   |   13 +++++++++++--
 2 files changed, 13 insertions(+), 3 deletions(-)

--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -337,8 +337,17 @@ static int page_referenced_one(struct pa
 		goto out_unmap;
 	}
 
-	if (ptep_clear_flush_young_notify(vma, address, pte))
-		referenced++;
+	if (ptep_clear_flush_young_notify(vma, address, pte)) {
+		/*
+		 * Don't treat a reference through a sequentially read
+		 * mapping as such.  If the page has been used in
+		 * another mapping, we will catch it; if this other
+		 * mapping is already gone, the unmap path will have
+		 * set PG_referenced or activated the page.
+		 */
+		if (likely(!VM_SequentialReadHint(vma)))
+			referenced++;
+	}
 
 	/* Pretend the page is referenced if the task has the
 	   swap token and is in the middle of a page fault. */
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -759,7 +759,8 @@ static unsigned long zap_pte_range(struc
 			else {
 				if (pte_dirty(ptent))
 					set_page_dirty(page);
-				if (pte_young(ptent))
+				if (pte_young(ptent) &&
+				    likely(!VM_SequentialReadHint(vma)))
 					mark_page_accessed(page);
 				file_rss--;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
