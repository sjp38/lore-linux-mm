Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 277256B0069
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 06:43:37 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id p1so4487136pfp.13
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 03:43:37 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b18si2789719pgs.562.2017.12.14.03.43.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 03:43:35 -0800 (PST)
Message-Id: <20171214113851.146259969@infradead.org>
Date: Thu, 14 Dec 2017 12:27:27 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
References: <20171214112726.742649793@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=peterz-vm-fix-gup.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

The gup_*_range() functions which implement __get_user_pages_fast() do
a p*_access_permitted() test to see if the memory is at all accessible
(tests both _PAGE_USER|_PAGE_RW as well as architectural things like
pkeys).

But the follow_*() functions which implement __get_user_pages() do not
have this test. Recently, commit:

  5c9d2d5c269c ("mm: replace pte_write with pte_access_permitted in fault + gup paths")

added it to a few specific write paths, but it failed to consistently
apply it (I've not audited anything outside of gup).

Revert the change from that patch and insert the tests in the right
locations such that they cover all READ / WRITE accesses for all
pte/pmd/pud levels.

In particular I care about the _PAGE_USER test, we should not ever,
allow access to pages not marked with it, but it also makes the pkey
accesses more consistent.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 mm/gup.c |   25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

--- a/mm/gup.c
+++ b/mm/gup.c
@@ -66,7 +66,7 @@ static int follow_pfn_pte(struct vm_area
  */
 static inline bool can_follow_write_pte(pte_t pte, unsigned int flags)
 {
-	return pte_access_permitted(pte, WRITE) ||
+	return pte_write(pte) ||
 		((flags & FOLL_FORCE) && (flags & FOLL_COW) && pte_dirty(pte));
 }
 
@@ -153,6 +153,11 @@ static struct page *follow_page_pte(stru
 	}
 
 	if (flags & FOLL_GET) {
+		if (!pte_access_permitted(pte, !!(flags & FOLL_WRITE))) {
+			page = ERR_PTR(-EFAULT);
+			goto out;
+		}
+
 		get_page(page);
 
 		/* drop the pgmap reference now that we hold the page */
@@ -244,6 +249,15 @@ static struct page *follow_pmd_mask(stru
 			pmd_migration_entry_wait(mm, pmd);
 		goto retry;
 	}
+
+	if (flags & FOLL_GET) {
+		if (!pmd_access_permitted(*pmd, !!(flags & FOLL_WRITE))) {
+			page = ERR_PTR(-EFAULT);
+			spin_unlock(ptr);
+			return page;
+		}
+	}
+
 	if (pmd_devmap(*pmd)) {
 		ptl = pmd_lock(mm, pmd);
 		page = follow_devmap_pmd(vma, address, pmd, flags);
@@ -326,6 +340,15 @@ static struct page *follow_pud_mask(stru
 			return page;
 		return no_page_table(vma, flags);
 	}
+
+	if (flags & FOLL_GET) {
+		if (!pud_access_permitted(*pud, !!(flags & FOLL_WRITE))) {
+			page = ERR_PTR(-EFAULT);
+			spin_unlock(ptr);
+			return page;
+		}
+	}
+
 	if (pud_devmap(*pud)) {
 		ptl = pud_lock(mm, pud);
 		page = follow_devmap_pud(vma, address, pud, flags);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
