Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 839176B006E
	for <linux-mm@kvack.org>; Fri, 20 Dec 2013 08:31:48 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id x10so2519444pdj.19
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 05:31:48 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id dv5si5268494pbb.43.2013.12.20.05.31.45
        for <linux-mm@kvack.org>;
        Fri, 20 Dec 2013 05:31:47 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20131220131003.93C9AE0090@blue.fi.intel.com>
References: <20130223003232.4CDDB5A41B6@corp2gmr1-2.hot.corp.google.com>
 <52AA0613.2000908@oracle.com>
 <CA+55aFw3_0_Et9bbfWgGLXEUaGQW1HE8j=oGBqFG_8j+h6jmvQ@mail.gmail.com>
 <CA+55aFyRZW=Uy9w+bZR0vMOFNPqV-yW2Xs9N42qEwTQ3AY0fDw@mail.gmail.com>
 <52AE271C.4040805@oracle.com>
 <CA+55aFw+-EB0J5v-1LMg1aiDZQJ-Mm0fzdbN312_nyBCVs+Fvw@mail.gmail.com>
 <20131216124754.29063E0090@blue.fi.intel.com>
 <52AF19CF.2060102@oracle.com>
 <20131216205244.GG21218@redhat.com>
 <20131220131003.93C9AE0090@blue.fi.intel.com>
Subject: Re: [patch 019/154] mm: make madvise(MADV_WILLNEED) support swap file
 prefetch
Content-Transfer-Encoding: 7bit
Message-Id: <20131220133140.655DEE0090@blue.fi.intel.com>
Date: Fri, 20 Dec 2013 15:31:40 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, shli@kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@fusionio.com>, linux-mm <linux-mm@kvack.org>

Kirill A. Shutemov wrote:
> Andrea Arcangeli wrote:
> > Hi,
> > 
> > On Mon, Dec 16, 2013 at 10:18:39AM -0500, Sasha Levin wrote:
> > > On 12/16/2013 07:47 AM, Kirill A. Shutemov wrote:
> > > > I probably miss some context here. Do you have crash on some use-case or
> > > > what? Could you point me to start of discussion.
> > > 
> > > Yes, Sorry, here's the crash that started this discussion originally:
> > > 
> > > The code points to:
> > > 
> > 
> > At this point pmd_none_or_trans_huge_or_clear_bad guaranteed us the
> > pmd points to a regular pte.
> 
> It took too long, but I finally found a way to reproduce the bug easily:
> 
> 	#define _GNU_SOURCE
> 	#include <sys/mman.h>
> 
> 	#define MB (1024 * 1024)
> 
> 	int main(int argc, char **argv)
> 	{
> 		void *p;
> 
> 		p = mmap(0, 10 * MB, PROT_READ,
> 				MAP_PRIVATE | MAP_ANONYMOUS | MAP_POPULATE,
> 				-1, 0);
> 		mprotect(p, 10 * MB, PROT_NONE);
> 		madvise(p, 10 * MB, MADV_WILLNEED);
> 		return 0;
> 	}
> 
> And I track it down to pmd_none_or_trans_huge_or_clear_bad().
> 
> It seems it doesn't guarantee to return 1 for pmd_trans_huge() page and I
> don't know how it suppose to do this for non-bad page.
> 
> I've fixed this with patch below.
> 
> Andrea, do I miss something important here or
> pmd_none_or_trans_huge_or_clear_bad() is broken from day 1?

Oh.. It seems it cased by change pmd_bad() behaviour by commit be3a728427a6, so
pmd_none_or_trans_huge_or_clear_bad() misses THP pmds if they are pmd_numa().

Other way to get it work is below. I'm not sure which is more correct (if any).

Mel? Andrea?

> 
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index f330d28e4d0e..0694c9bf2a34 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -599,7 +599,7 @@ static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  	barrier();
>  #endif
> -	if (pmd_none(pmdval))
> +	if (pmd_none(pmdval) || pmd_trans_huge(pmdval))
>  		return 1;
>  	if (unlikely(pmd_bad(pmdval))) {
>  		if (!pmd_trans_huge(pmdval))


diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index f330d28e4d0e..1f8bc7881bdb 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -558,6 +558,14 @@ static inline pmd_t pmd_read_atomic(pmd_t *pmdp)
 }
 #endif
 
+#ifndef pmd_numa
+static inline int pmd_numa(pmd_t pmd)
+{
+	return (pmd_flags(pmd) &
+		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
+}
+#endif
+
 /*
  * This function is meant to be used by sites walking pagetables with
  * the mmap_sem hold in read mode to protect against MADV_DONTNEED and
@@ -601,7 +609,7 @@ static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)
 #endif
 	if (pmd_none(pmdval))
 		return 1;
-	if (unlikely(pmd_bad(pmdval))) {
+	if (unlikely(pmd_bad(pmdval) || pmd_numa(pmdval))) {
 		if (!pmd_trans_huge(pmdval))
 			pmd_clear_bad(pmd);
 		return 1;
@@ -650,14 +658,6 @@ static inline int pte_numa(pte_t pte)
 }
 #endif
 
-#ifndef pmd_numa
-static inline int pmd_numa(pmd_t pmd)
-{
-	return (pmd_flags(pmd) &
-		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
-}
-#endif
-
 /*
  * pte/pmd_mknuma sets the _PAGE_ACCESSED bitflag automatically
  * because they're called by the NUMA hinting minor page fault. If we
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
