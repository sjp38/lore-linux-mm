Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 629525F0001
	for <linux-mm@kvack.org>; Sun, 19 Apr 2009 08:37:03 -0400 (EDT)
Date: Sun, 19 Apr 2009 21:37:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH v3 1/6] mm: Don't unmap gup()ed page
In-Reply-To: <2f11576a0904150453g4332e0d5h5bcad97fac7af24@mail.gmail.com>
References: <20090415114154.GI9809@random.random> <2f11576a0904150453g4332e0d5h5bcad97fac7af24@mail.gmail.com>
Message-Id: <20090419202328.FFBF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Nick Piggin <nickpiggin@yahoo.com.au>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

> >> Can we assume mmu_notifier is only used by kvm now?
> >> if not, we need to make new notifier.
> >
> > KVM is no fundamentally different from other users in this respect, so
> > I don't see why need a new notifier. If it works for others it'll work
> > for KVM and the other way around is true too.
> >
> > mmu notifier users can or cannot take a page pin. KVM does. GRU
> > doesn't. XPMEM does. All of them releases any pin after
> > mmu_notifier_invalidate_page. All that is important is to run
> > mmu_notifier_invalidate_page _after_ the ptep_clear_young_notify, so
> > that we don't nuke secondary mappings on the pages unless we really go
> > to nuke the pte.
> 
> Thank you kindful explain. I understand it :)

How about this?

---
 mm/rmap.c     |   50 +++++++++++++++++++++++++++++++++++++++++++-------
 mm/swapfile.c |    3 ++-
 2 files changed, 45 insertions(+), 8 deletions(-)

Index: b/mm/swapfile.c
===================================================================
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -547,7 +547,8 @@ int reuse_swap_page(struct page *page)
 			SetPageDirty(page);
 		}
 	}
-	return count == 1;
+
+	return count + page_count(page) == 2;
 }
 
 /*
Index: b/mm/rmap.c
===================================================================
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -772,12 +772,34 @@ static int try_to_unmap_one(struct page 
 	if (!pte)
 		goto out;
 
-	/*
-	 * If the page is mlock()d, we cannot swap it out.
-	 * If it's recently referenced (perhaps page_referenced
-	 * skipped over this mm) then we should reactivate it.
-	 */
+
+	/* Unpinning the page from long time pinning subsystem (e.g. kvm). */
+	mmu_notifier_invalidate_page(vma->vm_mm, address);
+
 	if (!migration) {
+		/*
+		 * Don't pull an anonymous page out from under get_user_pages.
+		 * get_user_pages_fast() silently raises page count without any
+		 * lock. thus, we need twice check here and _after_ pte nuking.
+		 *
+		 * If nuke the pte of pinned pages, do_wp_page() will replace
+		 * it by a copy page, and the user never get to see the data
+		 * GUP was holding the original page for.
+		 *
+		 * note:
+		 *  page_mapcount() + 2 mean pte + swapcache + us
+		 */
+		if (PageAnon(page) &&
+		    (page_count(page) != page_mapcount(page) + 2)) {
+			ret = SWAP_FAIL;
+			goto out_unmap;
+		}
+
+		/*
+		 * If the page is mlock()d, we cannot swap it out.
+		 * If it's recently referenced (perhaps page_referenced
+		 * skipped over this mm) then we should reactivate it.
+		 */
 		if (vma->vm_flags & VM_LOCKED) {
 			ret = SWAP_MLOCK;
 			goto out_unmap;
@@ -786,11 +808,25 @@ static int try_to_unmap_one(struct page 
 			ret = SWAP_FAIL;
 			goto out_unmap;
 		}
-  	}
+	}
 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address, page_to_pfn(page));
-	pteval = ptep_clear_flush_notify(vma, address, pte);
+	pteval = ptep_clear_flush(vma, address, pte);
+
+	if (!migration) {
+		if (PageAnon(page) &&
+		    page_count(page) != page_mapcount(page) + 2) {
+			/*
+			 * We lose the race against get_user_pages_fast().
+			 * set the same pte and give up unmapping.
+			 */
+			set_pte_at(mm, address, pte, pteval);
+			ret = SWAP_FAIL;
+			goto out_unmap;
+		}
+	}
+
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
