Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9B86B0038
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 19:40:04 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id ma3so4310843pbc.41
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 16:40:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id xn1si12261425pbc.158.2014.03.03.16.40.03
        for <linux-mm@kvack.org>;
        Mon, 03 Mar 2014 16:40:03 -0800 (PST)
Date: Mon, 3 Mar 2014 16:40:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] mm: per-thread vma caching
Message-Id: <20140303164002.02df915e12d05bb98762407f@linux-foundation.org>
In-Reply-To: <1393537704.2899.3.camel@buesod1.americas.hpqcorp.net>
References: <1393537704.2899.3.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 27 Feb 2014 13:48:24 -0800 Davidlohr Bueso <davidlohr@hp.com> wrote:

> From: Davidlohr Bueso <davidlohr@hp.com>
> 
> This patch is a continuation of efforts trying to optimize find_vma(),
> avoiding potentially expensive rbtree walks to locate a vma upon faults.
> The original approach (https://lkml.org/lkml/2013/11/1/410), where the
> largest vma was also cached, ended up being too specific and random, thus
> further comparison with other approaches were needed. There are two things
> to consider when dealing with this, the cache hit rate and the latency of
> find_vma(). Improving the hit-rate does not necessarily translate in finding
> the vma any faster, as the overhead of any fancy caching schemes can be too
> high to consider.
> 
> We currently cache the last used vma for the whole address space, which
> provides a nice optimization, reducing the total cycles in find_vma() by up
> to 250%, for workloads with good locality. On the other hand, this simple
> scheme is pretty much useless for workloads with poor locality. Analyzing
> ebizzy runs shows that, no matter how many threads are running, the
> mmap_cache hit rate is less than 2%, and in many situations below 1%.
> 
> The proposed approach is to replace this scheme with a small per-thread cache,
> maximizing hit rates at a very low maintenance cost. Invalidations are
> performed by simply bumping up a 32-bit sequence number. The only expensive
> operation is in the rare case of a seq number overflow, where all caches that
> share the same address space are flushed. Upon a miss, the proposed replacement
> policy is based on the page number that contains the virtual address in
> question. Concretely, the following results are seen on an 80 core, 8 socket
> x86-64 box:

A second look...

> Please note that kgdb, nommu and unicore32 arch are *untested*. Thanks.

I build tested nommu, fwiw.

>
> ...
>
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -342,9 +342,9 @@ struct mm_rss_stat {
>  
>  struct kioctx_table;
>  struct mm_struct {
> -	struct vm_area_struct * mmap;		/* list of VMAs */
> +	struct vm_area_struct *mmap;		/* list of VMAs */
>  	struct rb_root mm_rb;
> -	struct vm_area_struct * mmap_cache;	/* last find_vma result */
> +	u32 vmacache_seqnum;                   /* per-thread vmacache */

nitpick: in kernelese this is typically "per-task".  If it was in the
mm_struct then it would be "per process".  And I guess if it was in the
thread_struct it would be "per thread", but that isn't a distinction
I've seen made.

> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -23,6 +23,7 @@ struct sched_param {
>  #include <linux/errno.h>
>  #include <linux/nodemask.h>
>  #include <linux/mm_types.h>
> +#include <linux/vmacache.h>

This might be awkward - vmacache.h drags in mm.h and we have had tangly
problems with these major header files in the past.  I'd be inclined to
remove this inclusion and just forward-declare vm_area_struct, but we
still need VMACACHE_SIZE, sigh.  Wait and see what happens, I guess.

>
> ...
>
> --- /dev/null
> +++ b/include/linux/vmacache.h
> @@ -0,0 +1,40 @@
> +#ifndef __LINUX_VMACACHE_H
> +#define __LINUX_VMACACHE_H
> +
> +#include <linux/mm.h>
> +
> +#define VMACACHE_BITS 2
> +#define VMACACHE_SIZE (1U << VMACACHE_BITS)
> +#define VMACACHE_MASK (VMACACHE_SIZE - 1)
> +/*
> + * Hash based on the page number. Provides a good hit rate for
> + * workloads with good locality and those with random accesses as well.
> + */
> +#define VMACACHE_HASH(addr) ((addr >> PAGE_SHIFT) & VMACACHE_MASK)
> +
> +#define vmacache_flush(tsk)					 \
> +	do {							 \
> +		memset(tsk->vmacache, 0, sizeof(tsk->vmacache)); \
> +	} while (0)

There's no particular reason to implement this in cpp.  Using C is
typesafer and nicer.  But then we get into header file issues again. 
More sigh

> +extern void vmacache_flush_all(struct mm_struct *mm);
> +extern void vmacache_update(unsigned long addr, struct vm_area_struct *newvma);
> +extern struct vm_area_struct *vmacache_find(struct mm_struct *mm,
> +						    unsigned long addr);
> +
> +#ifndef CONFIG_MMU
> +extern struct vm_area_struct *vmacache_find_exact(struct mm_struct *mm,
> +						  unsigned long start,
> +						  unsigned long end);
> +#endif

We often omit the ifdefs in this case.  It means that a compile-time
error becomes a link-time error but that's a small cost for unmucking
the header files.  It doesn't matter much in vmacache.h, but some
headers would become a complete maze of ifdefs otherwise.

>
> ...
>
> --- /dev/null
> +++ b/mm/vmacache.c
> @@ -0,0 +1,94 @@
> +/*
> + * Copyright (C) 2014 Davidlohr Bueso.
> + */
> +#include <linux/sched.h>
> +#include <linux/vmacache.h>
> +
> +/*
> + * Flush vma caches for threads that share a given mm.
> + *
> + * The operation is safe because the caller holds the mmap_sem
> + * exclusively and other threads accessing the vma cache will
> + * have mmap_sem held at least for read, so no extra locking
> + * is required to maintain the vma cache.
> + */

Ah, there are our locking rules.

>
> ...
>
> +static bool vmacache_valid(struct mm_struct *mm)
> +{
> +	struct task_struct *curr = current;
> +
> +	if (mm != curr->mm)
> +		return false;

What's going on here?  Handling a task poking around in someone else's
mm?  I'm thinking "__access_remote_vm", but I don't know what you were
thinking ;) An explanatory comment would be revealing.

> +	if (mm->vmacache_seqnum != curr->vmacache_seqnum) {
> +		/*
> +		 * First attempt will always be invalid, initialize
> +		 * the new cache for this task here.
> +		 */
> +		curr->vmacache_seqnum = mm->vmacache_seqnum;
> +		vmacache_flush(curr);
> +		return false;
> +	}
> +	return true;
> +}
> +
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
