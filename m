Date: Fri, 20 Oct 2000 01:44:11 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: oopses in test10-pre4 (was Re: [RFC] atomic pte updates and pae
 changes, take 3)
In-Reply-To: <Pine.LNX.4.10.10010191301270.1350-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0010200046480.22300-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Oct 2000, Linus Torvalds wrote:

....
> I think you overlooked the fact that SHM mappings use the page cache, and
> it's ok if such pages are dirty and writable - they will get written out
> by the shm_swap() logic once there are no mappings active any more.
> 
> I like the test per se, because I think it's correct for the "normal"
> case of a private page, but I really think those two BUG()'s are not bugs
> at all in general, and we should just remove the two tests.
> 
> Comments? Anything I've overlooked?

The primary reason I added the BUG was that if this is valid, it means
that the pte has to be removed from the page tables first with
pte_get_and_clear since it can be modified by the other CPU.  Although
this may be safe for shm, I think it's very ugly and inconsistent.  I'd
rather make the code transfer the dirty bit to the page struct so that we
*know* there is no information loss.

If the above is correct, then the following patch should do (untested).  
Oh, I think I missed adding pte_same in the generic pgtable.h macros, too.
<doh!>  I'm willing to take a closer look if you think it's needed.

		-ben

diff -urN v2.4.0-test10-pre4/include/asm-generic/pgtable.h work-foo/include/asm-generic/pgtable.h
--- v2.4.0-test10-pre4/include/asm-generic/pgtable.h	Fri Oct 20 00:58:03 2000
+++ work-foo/include/asm-generic/pgtable.h	Fri Oct 20 01:42:24 2000
@@ -38,4 +38,6 @@
 	set_pte(ptep, pte_mkdirty(old_pte));
 }
 
+#define pte_same(left,right)	(pte_val(left) == pte_val(right))
+
 #endif /* _ASM_GENERIC_PGTABLE_H */
diff -urN v2.4.0-test10-pre4/mm/vmscan.c work-foo/mm/vmscan.c
--- v2.4.0-test10-pre4/mm/vmscan.c	Fri Oct 20 00:58:04 2000
+++ work-foo/mm/vmscan.c	Fri Oct 20 01:43:54 2000
@@ -87,6 +87,13 @@
 	if (TryLockPage(page))
 		goto out_failed;
 
+	/* From this point on, the odds are that we're going to
+	 * nuke this pte, so read and clear the pte.  This hook
+	 * is needed on CPUs which update the accessed and dirty
+	 * bits in hardware.
+	 */
+	pte = ptep_get_and_clear(page_table);
+
 	/*
 	 * Is the page already in the swap cache? If so, then
 	 * we can just drop our reference to it without doing
@@ -98,10 +105,6 @@
 	if (PageSwapCache(page)) {
 		entry.val = page->index;
 		swap_duplicate(entry);
-		if (pte_dirty(pte))
-			BUG();
-		if (pte_write(pte))
-			BUG();
 		set_pte(page_table, swp_entry_to_pte(entry));
 drop_pte:
 		UnlockPage(page);
@@ -111,13 +114,6 @@
 		page_cache_release(page);
 		goto out_failed;
 	}
-
-	/* From this point on, the odds are that we're going to
-	 * nuke this pte, so read and clear the pte.  This hook
-	 * is needed on CPUs which update the accessed and dirty
-	 * bits in hardware.
-	 */
-	pte = ptep_get_and_clear(page_table);
 
 	/*
 	 * Is it a clean page? Then it must be recoverable

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
