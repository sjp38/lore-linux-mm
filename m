Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 929818D0039
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 12:46:58 -0500 (EST)
Date: Fri, 21 Jan 2011 18:44:42 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00/21] mm: Preemptibility -v6
Message-ID: <20110121174442.GI9506@random.random>
References: <20101126143843.801484792@chello.nl>
 <alpine.LSU.2.00.1101172301340.2899@sister.anvils>
 <1295457039.28776.137.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1295457039.28776.137.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@kernel.dk>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 19, 2011 at 06:10:39PM +0100, Peter Zijlstra wrote:
> > 19/21 mm-convert_i_mmap_lock_and_anon_vma-_lock_to_mutexes.patch
> >       I suggest doing the anon_vma lock->mutex conversion separately here.
> >       Acked-by: Hugh Dickins <hughd@google.com>
> >       except that in the past we have renamed a lock when we've done this
> >       kind of conversion, so I'd expect anon_vma->mutex throughout now.
> >       Or am I just out of date?  I don't feel very strongly about it.
> 
> Done.. however:
> 
> Index: linux-2.6/include/linux/huge_mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/huge_mm.h
> +++ linux-2.6/include/linux/huge_mm.h
> @@ -91,12 +91,8 @@ extern void __split_huge_page_pmd(struct
>  #define wait_split_huge_page(__anon_vma, __pmd)				\
>  	do {								\
>  		pmd_t *____pmd = (__pmd);				\
> -		spin_unlock_wait(&(__anon_vma)->root->lock);		\
> -		/*							\
> -		 * spin_unlock_wait() is just a loop in C and so the	\
> -		 * CPU can reorder anything around it.			\
> -		 */							\
> -		smp_mb();						\
> +		anon_vma_lock(__anon_vma);				\
> +		anon_vma_unlock(__anon_vma);				\
>  		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
>  		       pmd_trans_huge(*____pmd));			\
>  	} while (0)
> 
> Andrea, is that smp_mb() simply to avoid us doing anything before the
> lock is free? Why isn't there an mb() before to ensure nothing leaks
> past it from the other end?

The idea would be that by the time we read the pmd set to
pmd_trans_splitting with the page_table_lock hold, we're guaranteed
we'll see the anon-vma locked (if it's still locked). So it's ok if
spin_unlock_wait happens before reading the pmd_trans_splitting check
inside the CPU (all it matters is for it not to happen before the
spin_lock(&page_table_lock) which it can't by the acquire semantics of
the spinlock).

So in short we know we start with the anon_vma locked, and we just
wait as long as needed.

So we only need to protect to the stuff after spin_unlock_wait().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
