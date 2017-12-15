Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 84AC96B0253
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 03:00:55 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y62so7163676pfd.3
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 00:00:55 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id w5si4164088pgm.49.2017.12.15.00.00.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 00:00:54 -0800 (PST)
Date: Fri, 15 Dec 2017 09:00:41 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
Message-ID: <20171215080041.zftzuxdonxrtmssq@hirez.programming.kicks-ass.net>
References: <20171214112726.742649793@infradead.org>
 <20171214113851.146259969@infradead.org>
 <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
 <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
 <f0244eb7-bd9f-dce4-68a5-cf5f8b43652e@intel.com>
 <20171214205450.GI3326@worktop>
 <8eedb9a3-0ba2-52df-58f6-3ed869d18ca3@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8eedb9a3-0ba2-52df-58f6-3ed869d18ca3@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, x86@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, hughd@google.com, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com

On Thu, Dec 14, 2017 at 09:04:56PM -0800, Dave Hansen wrote:
> 
> I've got some additions to the selftests and a fix where we pass FOLL_*
> flags around a bit more instead of just 'write'.  I'll get those out as
> soon as I do a bit more testing.

Try the below; I have more in the works, but this already fixes a whole
bunch of obvious fail and should fix the case I described.

The thing is, you should _never_ return NULL for an access error, that's
complete crap.

You should also not blindly change every pte_write() test to
pte_access_permitted(), that's also wrong, because then you're missing
the read-access tests.

Basically you need to very carefully audit each and every
p??_access_permitted() call; they're currently mostly wrong.

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
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -870,9 +870,6 @@ struct page *follow_devmap_pmd(struct vm
 	 */
 	WARN_ONCE(flags & FOLL_COW, "mm: In follow_devmap_pmd with FOLL_COW set");
 
-	if (!pmd_access_permitted(*pmd, flags & FOLL_WRITE))
-		return NULL;
-
 	if (pmd_present(*pmd) && pmd_devmap(*pmd))
 		/* pass */;
 	else
@@ -1012,9 +1009,6 @@ struct page *follow_devmap_pud(struct vm
 
 	assert_spin_locked(pud_lockptr(mm, pud));
 
-	if (!pud_access_permitted(*pud, flags & FOLL_WRITE))
-		return NULL;
-
 	if (pud_present(*pud) && pud_devmap(*pud))
 		/* pass */;
 	else
@@ -1386,7 +1380,7 @@ int do_huge_pmd_wp_page(struct vm_fault
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
