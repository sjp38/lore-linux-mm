From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 19 Jun 2006 19:53:47 +0200
Message-Id: <20060619175347.24655.67680.sendpatchset@lappy>
In-Reply-To: <20060619175243.24655.76005.sendpatchset@lappy>
References: <20060619175243.24655.76005.sendpatchset@lappy>
Subject: [PATCH 6/6] mm: remove some update_mmu_cache() calls
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <christoph@lameter.com>, Martin Bligh <mbligh@google.com>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

From: Christoph Lameter <clameter@sgi.com>

This may be a bit controversial but it does not seem to
make sense to use the update_mmu_cache macro when we reuse
the page. We are only fiddling around with the protections,
the dirty and accessed bits.

With the call to update_mmu_cache the way of using the macros
would be different from mprotect() and page_mkclean(). I'd
rather have everything work the same way. If this breaks on some
arches then also mprotect and page_mkclean() are broken.
The use of mprotect() is rare, we may have breakage in some
arches that we just have not seen yet.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/memory.c |    2 --
 1 file changed, 2 deletions(-)

Index: 2.6-mm/mm/memory.c
===================================================================
--- 2.6-mm.orig/mm/memory.c	2006-06-19 16:21:16.000000000 +0200
+++ 2.6-mm/mm/memory.c	2006-06-19 16:21:25.000000000 +0200
@@ -1514,7 +1514,6 @@ static int do_wp_page(struct mm_struct *
 		entry = pte_mkyoung(orig_pte);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		ptep_set_access_flags(vma, address, page_table, entry, 1);
-		update_mmu_cache(vma, address, entry);
 		lazy_mmu_prot_update(entry);
 		ret |= VM_FAULT_WRITE;
 		goto unlock;
@@ -2317,7 +2316,6 @@ static inline int handle_pte_fault(struc
 	entry = pte_mkyoung(entry);
 	if (!pte_same(old_entry, entry)) {
 		ptep_set_access_flags(vma, address, pte, entry, write_access);
-		update_mmu_cache(vma, address, entry);
 		lazy_mmu_prot_update(entry);
 	} else {
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
