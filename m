Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2FCED6B0037
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 19:00:25 -0500 (EST)
Received: by mail-pb0-f43.google.com with SMTP id um1so4406770pbc.16
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 16:00:24 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id io5si12166621pbc.324.2014.03.03.16.00.23
        for <linux-mm@kvack.org>;
        Mon, 03 Mar 2014 16:00:24 -0800 (PST)
Date: Mon, 3 Mar 2014 16:00:21 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] mm: per-thread vma caching
Message-Id: <20140303160021.3001634fa62781d7b0359158@linux-foundation.org>
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
> 
> ...
> 
> 2) Kernel build: This one is already pretty good with the current approach
> as we're dealing with good locality.
> 
> +----------------+----------+------------------+
> | caching scheme | hit-rate | cycles (billion) |
> +----------------+----------+------------------+
> | baseline       | 75.28%   | 11.03            |
> | patched        | 88.09%   | 9.31             |
> +----------------+----------+------------------+

What is the "cycles" number here?  I'd like to believe we sped up kernel
builds by 10% ;)

Were any overall run time improvements observable?

> ...
>
> @@ -1228,6 +1229,9 @@ struct task_struct {
>  #ifdef CONFIG_COMPAT_BRK
>  	unsigned brk_randomized:1;
>  #endif
> +	/* per-thread vma caching */
> +	u32 vmacache_seqnum;
> +	struct vm_area_struct *vmacache[VMACACHE_SIZE];

So these are implicitly locked by being per-thread.

> +static inline void vmacache_invalidate(struct mm_struct *mm)
> +{
> +	mm->vmacache_seqnum++;
> +
> +	/* deal with overflows */
> +	if (unlikely(mm->vmacache_seqnum == 0))
> +		vmacache_flush_all(mm);
> +}

What's the locking rule for mm->vmacache_seqnum?

>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
