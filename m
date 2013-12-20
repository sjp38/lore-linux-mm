Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 804236B0031
	for <linux-mm@kvack.org>; Fri, 20 Dec 2013 12:42:24 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id x12so2741080wgg.4
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 09:42:23 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ux10si3429400wjc.81.2013.12.20.09.42.22
        for <linux-mm@kvack.org>;
        Fri, 20 Dec 2013 09:42:23 -0800 (PST)
Date: Fri, 20 Dec 2013 18:42:10 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 019/154] mm: make madvise(MADV_WILLNEED) support swap
 file prefetch
Message-ID: <20131220174210.GB727@redhat.com>
References: <52AA0613.2000908@oracle.com>
 <CA+55aFw3_0_Et9bbfWgGLXEUaGQW1HE8j=oGBqFG_8j+h6jmvQ@mail.gmail.com>
 <CA+55aFyRZW=Uy9w+bZR0vMOFNPqV-yW2Xs9N42qEwTQ3AY0fDw@mail.gmail.com>
 <52AE271C.4040805@oracle.com>
 <CA+55aFw+-EB0J5v-1LMg1aiDZQJ-Mm0fzdbN312_nyBCVs+Fvw@mail.gmail.com>
 <20131216124754.29063E0090@blue.fi.intel.com>
 <52AF19CF.2060102@oracle.com>
 <20131216205244.GG21218@redhat.com>
 <20131220131003.93C9AE0090@blue.fi.intel.com>
 <20131220133619.4980AE0090@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131220133619.4980AE0090@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>, Sasha Levin <sasha.levin@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, shli@kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@fusionio.com>, linux-mm <linux-mm@kvack.org>

On Fri, Dec 20, 2013 at 03:36:19PM +0200, Kirill A. Shutemov wrote:
> Kirill A. Shutemov wrote:
> > Andrea Arcangeli wrote:
> > > Hi,
> > > 
> > > On Mon, Dec 16, 2013 at 10:18:39AM -0500, Sasha Levin wrote:
> > > > On 12/16/2013 07:47 AM, Kirill A. Shutemov wrote:
> > > > > I probably miss some context here. Do you have crash on some use-case or
> > > > > what? Could you point me to start of discussion.
> > > > 
> > > > Yes, Sorry, here's the crash that started this discussion originally:
> > > > 
> > > > The code points to:
> > > > 
> > > 
> > > At this point pmd_none_or_trans_huge_or_clear_bad guaranteed us the
> > > pmd points to a regular pte.
> > 
> > It took too long, but I finally found a way to reproduce the bug easily:
> > 
> > 	#define _GNU_SOURCE
> > 	#include <sys/mman.h>
> > 
> > 	#define MB (1024 * 1024)
> > 
> > 	int main(int argc, char **argv)
> > 	{
> > 		void *p;
> > 
> > 		p = mmap(0, 10 * MB, PROT_READ,
> > 				MAP_PRIVATE | MAP_ANONYMOUS | MAP_POPULATE,
> > 				-1, 0);
> > 		mprotect(p, 10 * MB, PROT_NONE);
> > 		madvise(p, 10 * MB, MADV_WILLNEED);
> > 		return 0;
> > 	}
> > 
> > And I track it down to pmd_none_or_trans_huge_or_clear_bad().
> > 
> > It seems it doesn't guarantee to return 1 for pmd_trans_huge() page and I
> > don't know how it suppose to do this for non-bad page.
> > 
> > I've fixed this with patch below.
> > 
> > Andrea, do I miss something important here or
> > pmd_none_or_trans_huge_or_clear_bad() is broken from day 1?
> 
> [ resend with fixed mail headers. ]
> 
> Oh.. It seems it cased by change pmd_bad() behaviour by commit be3a728427a6, so
> pmd_none_or_trans_huge_or_clear_bad() misses THP pmds if they are pmd_numa().
> 
> Other way to get it work is below. I'm not sure which is more correct (if any).

Yes sorry, it was the addition to the pte_numa that caused this
problem and it can only happen if booted on real NUMA hardware as
otherwise the _PAGE_NUMA wouldn't be armed.

This is further confirmed by the:

CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
CONFIG_NUMA_BALANCING=y

This is why it went unnoticed as it cannot happen on non NUMA hardware
no matter what.

Clearly the lockptr was zero beacuse the pmd was actually pointing to
a hugepage, not to a pte, otherwise the pmd_page(*pmd) wouldn't have
been allocated in huge_memory.c cow.

> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index f330d28e4d0e..1f8bc7881bdb 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -558,6 +558,14 @@ static inline pmd_t pmd_read_atomic(pmd_t *pmdp)
>  }
>  #endif
>  
> +#ifndef pmd_numa
> +static inline int pmd_numa(pmd_t pmd)
> +{
> +	return (pmd_flags(pmd) &
> +		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
> +}
> +#endif
> +
>  /*
>   * This function is meant to be used by sites walking pagetables with
>   * the mmap_sem hold in read mode to protect against MADV_DONTNEED and
> @@ -601,7 +609,7 @@ static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)
>  #endif
>  	if (pmd_none(pmdval))
>  		return 1;
> -	if (unlikely(pmd_bad(pmdval))) {
> +	if (unlikely(pmd_bad(pmdval) || pmd_numa(pmdval))) {
>  		if (!pmd_trans_huge(pmdval))
>  			pmd_clear_bad(pmd);
>  		return 1;
> @@ -650,14 +658,6 @@ static inline int pte_numa(pte_t pte)
>  }
>  #endif
>  
> -#ifndef pmd_numa
> -static inline int pmd_numa(pmd_t pmd)
> -{
> -	return (pmd_flags(pmd) &
> -		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
> -}
> -#endif
> -

If we should do the below I would suggest Mel to decide.

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 3d19994..d70235b 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -532,8 +532,10 @@ static inline int pmd_bad(pmd_t pmd)
 {
 #ifdef CONFIG_NUMA_BALANCING
 	/* pmd_numa check */
-	if ((pmd_flags(pmd) & (_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA)
-		return 0;
+	if ((pmd_flags(pmd) & (_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA) {
+		pmd_clear_flags(pmd, _PAGE_NUMA);
+		pmd_set_flags(pmd, _PAGE_PRESENT);
+	}
 #endif
 	return (pmd_flags(pmd) & ~_PAGE_USER) != _KERNPG_TABLE;
 }


The reason for not doing this was that it felt slow to have that kind
of mangling in a fast path bad check. But maybe it's no problem to do
it. The above should also avoid the bug.

However I would suggest the below, it was overkill strict to depend on
pmd_bad to fail, and overall it made it weaker to depend on debug
checks that may change in the future and that can provide false
negatives (they only should never provide false positives). No need to
check pmd_trans_huge inside the branch, the pmdval is stable there.

If in a later patch I'd suggest you to cleanup the barrier with a
ACCESS_ONCE (ACCESS_ONCE conditional only to
CONFIG_TRANSPARENT_HUGEPAGE, no need of it if that's not configured
in) that could give gcc more room for optimizations in this function.

If CONFIG_TRANSPARENT_HUGEPAGE is not set, if pmd_none fails, the pmd
cannot change at all.

Again for the pmd_bad change above it's up to you... it's purely a
performance/reliability tradeoff.
