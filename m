Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id BB2026B004D
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 13:35:37 -0500 (EST)
Received: by mail-ie0-f171.google.com with SMTP id to1so718436ieb.16
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 10:35:37 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id k1si39542776igj.22.2014.02.25.10.35.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Feb 2014 10:35:35 -0800 (PST)
Date: Tue, 25 Feb 2014 19:35:22 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2] mm: per-thread vma caching
Message-ID: <20140225183522.GU6835@laptop.programming.kicks-ass.net>
References: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1393352206.2577.36.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 25, 2014 at 10:16:46AM -0800, Davidlohr Bueso wrote:
> +void vmacache_update(struct mm_struct *mm, unsigned long addr,
> +		     struct vm_area_struct *newvma)
> +{
> +	/*
> +	 * Hash based on the page number. Provides a good
> +	 * hit rate for workloads with good locality and
> +	 * those with random accesses as well.
> +	 */
> +	int idx = (addr >> PAGE_SHIFT) & 3;

 % VMACACHE_SIZE

perhaps? GCC should turn that into a mask for all sensible values I
would think.

Barring that I think something like:

#define VMACACHE_BITS	2
#define VMACACHE_SIZE	(1U << VMACACHE_BITS)
#define VMACACHE_MASK	(VMACACHE_SIZE - 1)

Might do I suppose.

> +	current->vmacache[idx] = newvma;
> +}
> -- 
> 1.8.1.4
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
