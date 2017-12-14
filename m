Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 618706B026B
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 07:41:29 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id a6so4600193pff.17
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 04:41:29 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id d25si3152688plj.693.2017.12.14.04.41.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 04:41:28 -0800 (PST)
Date: Thu, 14 Dec 2017 13:41:17 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
Message-ID: <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
References: <20171214112726.742649793@infradead.org>
 <20171214113851.146259969@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171214113851.146259969@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

On Thu, Dec 14, 2017 at 12:27:27PM +0100, Peter Zijlstra wrote:
> The gup_*_range() functions which implement __get_user_pages_fast() do
> a p*_access_permitted() test to see if the memory is at all accessible
> (tests both _PAGE_USER|_PAGE_RW as well as architectural things like
> pkeys).
> 
> But the follow_*() functions which implement __get_user_pages() do not
> have this test. Recently, commit:
> 
>   5c9d2d5c269c ("mm: replace pte_write with pte_access_permitted in fault + gup paths")
> 
> added it to a few specific write paths, but it failed to consistently
> apply it (I've not audited anything outside of gup).
> 
> Revert the change from that patch and insert the tests in the right
> locations such that they cover all READ / WRITE accesses for all
> pte/pmd/pud levels.
> 
> In particular I care about the _PAGE_USER test, we should not ever,
> allow access to pages not marked with it, but it also makes the pkey
> accesses more consistent.

This should probably go on top. These are now all superfluous and
slightly wrong.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2f2f5e774902..1797368cc83a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -870,9 +870,6 @@ struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
 	 */
 	WARN_ONCE(flags & FOLL_COW, "mm: In follow_devmap_pmd with FOLL_COW set");
 
-	if (!pmd_access_permitted(*pmd, flags & FOLL_WRITE))
-		return NULL;
-
 	if (pmd_present(*pmd) && pmd_devmap(*pmd))
 		/* pass */;
 	else
@@ -1012,9 +1009,6 @@ struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
 
 	assert_spin_locked(pud_lockptr(mm, pud));
 
-	if (!pud_access_permitted(*pud, flags & FOLL_WRITE))
-		return NULL;
-
 	if (pud_present(*pud) && pud_devmap(*pud))
 		/* pass */;
 	else
@@ -1386,7 +1380,7 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
  */
 static inline bool can_follow_write_pmd(pmd_t pmd, unsigned int flags)
 {
-	return pmd_access_permitted(pmd, WRITE) ||
+	return pmd_write(pmd) ||
 	       ((flags & FOLL_FORCE) && (flags & FOLL_COW) && pmd_dirty(pmd));
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
