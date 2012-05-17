Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 1C0906B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 15:35:33 -0400 (EDT)
Date: Thu, 17 May 2012 12:35:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: read_pmd_atomic: fix 32bit PAE pmd walk vs
 pmd_populate SMP race condition
Message-Id: <20120517123531.0c221023.akpm@linux-foundation.org>
In-Reply-To: <1337264036-28971-1-git-send-email-aarcange@redhat.com>
References: <1337264036-28971-1-git-send-email-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Larry Woodman <lwoodman@redhat.com>, Petr Matousek <pmatouse@redhat.com>, Ulrich Obergfell <uobergfe@redhat.com>, Rik van Riel <riel@redhat.com>

On Thu, 17 May 2012 16:13:56 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> When holding the mmap_sem for reading, pmd_offset_map_lock should only
> run on a pmd_t that has been read atomically from the pmdp
> pointer, otherwise we may read only half of it leading to this crash.

Do you think this is serious enough to warrant backporting the fix into
-stable?  The patch is pretty simple..

>
> ...
>
> --- a/arch/x86/include/asm/pgtable-3level.h
> +++ b/arch/x86/include/asm/pgtable-3level.h
> @@ -31,6 +31,56 @@ static inline void native_set_pte(pte_t *ptep, pte_t pte)
>  	ptep->pte_low = pte.pte_low;
>  }
>  
> +#define  __HAVE_ARCH_READ_PMD_ATOMIC

A couple of nits:

- read_pmd_atomic() should be called pmd_read_atomic() - check out
  "grep pmd include/asm-generic/pgtable.h".

- A somewhat neat convention we use is to do

	static inline void foo(...)
	{
		...
	}
	#define foo foo

  so then other code can do

	#ifndef foo
	...
	#endif

  This avoids having to create (and remember!) a second identifier.

> +/*
> + * pte_offset_map_lock on 32bit PAE kernels was reading the pmd_t with
> + * a "*pmdp" dereference done by gcc.

I spent some time trying to find exactly where pte_offset_map_lock does
this dereference then gave up, because it shouldn't have been this
hard!

Can we be specific here, so that others can more easily work out what's
going on?

> Problem is, in certain places
> + * where pte_offset_map_lock is called, concurrent page faults are
> + * allowed, if the mmap_sem is hold for reading. An example is mincore
> + * vs page faults vs MADV_DONTNEED. On the page fault side
> + * pmd_populate rightfully does a set_64bit, but if we're reading the
> + * pmd_t with a "*pmdp" on the mincore side, a SMP race can happen
> + * because gcc will not read the 64bit of the pmd atomically. To fix
> + * this all places running pmd_offset_map_lock() while holding the
> + * mmap_sem in read mode, shall read the pmdp pointer using this
> + * function to know if the pmd is null nor not, and in turn to know if
> + * they can run pmd_offset_map_lock or pmd_trans_huge or other pmd
> + * operations.
> + *
> + * Without THP if the mmap_sem is hold for reading, the
> + * pmd can only transition from null to not null while read_pmd_atomic runs.
> + * So there's no need of literally reading it atomically.
> + *
> + * With THP if the mmap_sem is hold for reading, the pmd can become
> + * THP or null or point to a pte (and in turn become "stable") at any
> + * time under read_pmd_atomic, so it's mandatory to read it atomically
> + * with cmpxchg8b.

This all seems terribly subtle and fragile.

> + */
> +#ifndef CONFIG_TRANSPARENT_HUGEPAGE
> +static inline pmd_t read_pmd_atomic(pmd_t *pmdp)
> +{
> +	pmdval_t ret;
> +	u32 *tmp = (u32 *)pmdp;
> +
> +	ret = (pmdval_t) (*tmp);
> +	if (ret) {
> +		/*
> +		 * If the low part is null, we must not read the high part
> +		 * or we can end up with a partial pmd.

This is the core part of the fix, and I don't understand it :( What is
the significance of the zeroness of the lower half of the pmdval_t? 
How, exactly, does this prevent races?

At a guess, I'd say that we're making three assumptions here:

a) that gcc will write lower-word-first when doing a 64-bit write

b) that a valid pmdval_t never has all zeroes in the lower 32 bits and

c) that any code which this function is racing against will only
   ever be writing to a pmdval_t which has the all-zeroes pattern.  ie:
   that we never can race against code which is modifying an existing
   pmdval_t.

Can we spell out and justify all the assumptions here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
