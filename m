Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0316B0035
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 06:34:40 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y13so4661960pdi.11
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 03:34:39 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id kb1si11397412pbd.171.2014.07.15.03.34.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 03:34:39 -0700 (PDT)
Received: by mail-pd0-f181.google.com with SMTP id v10so6874497pde.40
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 03:34:39 -0700 (PDT)
Date: Tue, 15 Jul 2014 03:33:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/2] shmem: fix splicing from a hole while it's punched
In-Reply-To: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1407150331170.2584@eggly.anvils>
References: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

shmem_fault() is the actual culprit in trinity's hole-punch starvation,
and the most significant cause of such problems: since a page faulted is
one that then appears page_mapped(), needing unmap_mapping_range() and
i_mmap_mutex to be unmapped again.

But it is not the only way in which a page can be brought into a hole in
the radix_tree while that hole is being punched; and Vlastimil's testing
implies that if enough other processors are busy filling in the hole,
then shmem_undo_range() can be kept from completing indefinitely.

shmem_file_splice_read() is the main other user of SGP_CACHE, which
can instantiate shmem pagecache pages in the read-only case (without
holding i_mutex, so perhaps concurrently with a hole-punch).  Probably
it's silly not to use SGP_READ already (using the ZERO_PAGE for holes):
which ought to be safe, but might bring surprises - not a change to be
rushed.

shmem_read_mapping_page_gfp() is an internal interface used by
drivers/gpu/drm GEM (and next by uprobes): it should be okay.  And
shmem_file_read_iter() uses the SGP_DIRTY variant of SGP_CACHE, when
called internally by the kernel (perhaps for a stacking filesystem,
which might rely on holes to be reserved): it's unclear whether it
could be provoked to keep hole-punch busy or not.

We could apply the same umbrella as now used in shmem_fault() to
shmem_file_splice_read() and the others; but it looks ugly, and use
over a range raises questions - should it actually be per page?  can
these get starved themselves?

The origin of this part of the problem is my v3.1 commit d0823576bf4b
("mm: pincer in truncate_inode_pages_range"), once it was duplicated
into shmem.c.  It seemed like a nice idea at the time, to ensure
(barring RCU lookup fuzziness) that there's an instant when the entire
hole is empty; but the indefinitely repeated scans to ensure that make
it vulnerable.

Revert that "enhancement" to hole-punch from shmem_undo_range(), but
retain the unproblematic rescanning when it's truncating; add a couple
of comments there.

Remove the "indices[0] >= end" test: that is now handled satisfactorily
by the inner loop, and mem_cgroup_uncharge_start()/end() are too light
to be worth avoiding here.

But if we do not always loop indefinitely, we do need to handle the case
of swap swizzled back to page before shmem_free_swap() gets it: add a
retry for that case, as suggested by Konstantin Khlebnikov; and for the
case of page swizzled back to swap, as suggested by Johannes Weiner.

Signed-off-by: Hugh Dickins <hughd@google.com>
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Suggested-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Lukas Czerner <lczerner@redhat.com>
Cc: Dave Jones <davej@redhat.com>
Cc: <stable@vger.kernel.org>	[3.1+]
---
Please replace mmotm's
shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
by this patch: which is substantially the same as that, but with
updated commit comment, and a page retry as indicated by Hannes.

 mm/shmem.c |   24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)

--- 3.16-rc5+/mm/shmem.c	2014-07-14 20:34:28.196153828 -0700
+++ 3.16-rc5++/mm/shmem.c	2014-07-14 20:35:14.156154916 -0700
@@ -468,23 +468,20 @@ static void shmem_undo_range(struct inod
 		return;
 
 	index = start;
-	for ( ; ; ) {
+	while (index < end) {
 		cond_resched();
 
 		pvec.nr = find_get_entries(mapping, index,
 				min(end - index, (pgoff_t)PAGEVEC_SIZE),
 				pvec.pages, indices);
 		if (!pvec.nr) {
-			if (index == start || unfalloc)
+			/* If all gone or hole-punch or unfalloc, we're done */
+			if (index == start || end != -1)
 				break;
+			/* But if truncating, restart to make sure all gone */
 			index = start;
 			continue;
 		}
-		if ((index == start || unfalloc) && indices[0] >= end) {
-			pagevec_remove_exceptionals(&pvec);
-			pagevec_release(&pvec);
-			break;
-		}
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
@@ -496,8 +493,12 @@ static void shmem_undo_range(struct inod
 			if (radix_tree_exceptional_entry(page)) {
 				if (unfalloc)
 					continue;
-				nr_swaps_freed += !shmem_free_swap(mapping,
-								index, page);
+				if (shmem_free_swap(mapping, index, page)) {
+					/* Swap was replaced by page: retry */
+					index--;
+					break;
+				}
+				nr_swaps_freed++;
 				continue;
 			}
 
@@ -506,6 +507,11 @@ static void shmem_undo_range(struct inod
 				if (page->mapping == mapping) {
 					VM_BUG_ON_PAGE(PageWriteback(page), page);
 					truncate_inode_page(mapping, page);
+				} else {
+					/* Page was replaced by swap: retry */
+					unlock_page(page);
+					index--;
+					break;
 				}
 			}
 			unlock_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
