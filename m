Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f179.google.com (mail-ea0-f179.google.com [209.85.215.179])
	by kanga.kvack.org (Postfix) with ESMTP id 497D56B0035
	for <linux-mm@kvack.org>; Mon, 23 Dec 2013 05:25:30 -0500 (EST)
Received: by mail-ea0-f179.google.com with SMTP id r15so2274451ead.10
        for <linux-mm@kvack.org>; Mon, 23 Dec 2013 02:25:29 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u49si19385824eep.1.2013.12.23.02.25.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Dec 2013 02:25:29 -0800 (PST)
Date: Mon, 23 Dec 2013 10:25:24 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 019/154] mm: make madvise(MADV_WILLNEED) support swap
 file prefetch
Message-ID: <20131223102524.GE11295@suse.de>
References: <CA+55aFw3_0_Et9bbfWgGLXEUaGQW1HE8j=oGBqFG_8j+h6jmvQ@mail.gmail.com>
 <CA+55aFyRZW=Uy9w+bZR0vMOFNPqV-yW2Xs9N42qEwTQ3AY0fDw@mail.gmail.com>
 <52AE271C.4040805@oracle.com>
 <CA+55aFw+-EB0J5v-1LMg1aiDZQJ-Mm0fzdbN312_nyBCVs+Fvw@mail.gmail.com>
 <20131216124754.29063E0090@blue.fi.intel.com>
 <52AF19CF.2060102@oracle.com>
 <20131216205244.GG21218@redhat.com>
 <20131220131003.93C9AE0090@blue.fi.intel.com>
 <20131220133619.4980AE0090@blue.fi.intel.com>
 <20131220174210.GB727@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131220174210.GB727@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, shli@kernel.org, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@fusionio.com>, linux-mm <linux-mm@kvack.org>

On Fri, Dec 20, 2013 at 06:42:10PM +0100, Andrea Arcangeli wrote:
> > <SNIP>
> > diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> > index f330d28e4d0e..1f8bc7881bdb 100644
> > --- a/include/asm-generic/pgtable.h
> > +++ b/include/asm-generic/pgtable.h
> > @@ -558,6 +558,14 @@ static inline pmd_t pmd_read_atomic(pmd_t *pmdp)
> >  }
> >  #endif
> >  
> > +#ifndef pmd_numa
> > +static inline int pmd_numa(pmd_t pmd)
> > +{
> > +	return (pmd_flags(pmd) &
> > +		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
> > +}
> > +#endif
> > +
> >  /*
> >   * This function is meant to be used by sites walking pagetables with
> >   * the mmap_sem hold in read mode to protect against MADV_DONTNEED and
> > @@ -601,7 +609,7 @@ static inline int pmd_none_or_trans_huge_or_clear_bad(pmd_t *pmd)
> >  #endif
> >  	if (pmd_none(pmdval))
> >  		return 1;
> > -	if (unlikely(pmd_bad(pmdval))) {
> > +	if (unlikely(pmd_bad(pmdval) || pmd_numa(pmdval))) {
> >  		if (!pmd_trans_huge(pmdval))
> >  			pmd_clear_bad(pmd);
> >  		return 1;
> > @@ -650,14 +658,6 @@ static inline int pte_numa(pte_t pte)
> >  }
> >  #endif
> >  
> > -#ifndef pmd_numa
> > -static inline int pmd_numa(pmd_t pmd)
> > -{
> > -	return (pmd_flags(pmd) &
> > -		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
> > -}
> > -#endif
> > -
> 
> If we should do the below I would suggest Mel to decide.
> 
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index 3d19994..d70235b 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -532,8 +532,10 @@ static inline int pmd_bad(pmd_t pmd)
>  {
>  #ifdef CONFIG_NUMA_BALANCING
>  	/* pmd_numa check */
> -	if ((pmd_flags(pmd) & (_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA)
> -		return 0;
> +	if ((pmd_flags(pmd) & (_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA) {
> +		pmd_clear_flags(pmd, _PAGE_NUMA);
> +		pmd_set_flags(pmd, _PAGE_PRESENT);
> +	}
>  #endif
>  	return (pmd_flags(pmd) & ~_PAGE_USER) != _KERNPG_TABLE;
>  }
> 

I'm not keen on pmd_bad clearing NUMA hinting information. The name
implies it's a check only and this patch transforms the pmd. It also
puts a new burden on the architecture side that may be easily missed in
the future.

> 
> The reason for not doing this was that it felt slow to have that kind
> of mangling in a fast path bad check. But maybe it's no problem to do
> it. The above should also avoid the bug.
> 

If this bug is related to mprotect then it should also have been fixed
indirectly by commit 1667918b ("mm: numa: clear numa hinting information
on mprotect") although for the wrong reasons. Applying cleanly requires

 mm: clear pmd_numa before invalidating
 mm: numa: do not clear PMD during PTE update scan
 mm: numa: do not clear PTE for pte_numa update
 mm: numa: clear numa hinting information on mprotect

Is this bug reproducible in 3.13-rc5?

> However I would suggest the below, it was overkill strict to depend on
> pmd_bad to fail, and overall it made it weaker to depend on debug
> checks that may change in the future and that can provide false
> negatives (they only should never provide false positives). No need to
> check pmd_trans_huge inside the branch, the pmdval is stable there.
> 
> If in a later patch I'd suggest you to cleanup the barrier with a
> ACCESS_ONCE (ACCESS_ONCE conditional only to
> CONFIG_TRANSPARENT_HUGEPAGE, no need of it if that's not configured
> in) that could give gcc more room for optimizations in this function.
> 
> If CONFIG_TRANSPARENT_HUGEPAGE is not set, if pmd_none fails, the pmd
> cannot change at all.
> 
> Again for the pmd_bad change above it's up to you... it's purely a
> performance/reliability tradeoff.
> 
> From 238436f53937ed0a6821aa380b85366e4f6ad166 Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Fri, 20 Dec 2013 18:24:49 +0100
> Subject: [PATCH] mm: thp: don't depend on pmd_bad to fail on transhuge pmds
> 
> pmd_bad stopped failing on transhuge pmds if the pmd_numa is
> armed. Don't depend on that invariant anymore as it has been broken.
> 
> pmd_bad doesn't actually check if the pmd is bad if the pmd_numa is
> set. An alternative could be to teach it to mangle the local pmd to
> convert it from pmd_numa to non-pmd_numa and then issue a real check
> on it. However that would likely be slower, and keeping the
> pmd_trans_huge check in pmd_none_or_trans_huge_or_clear_bad in an
> unlikely pmd_bad branch was also not optimal.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

I prefer this patch

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
