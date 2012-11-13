Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 4838E6B0075
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 11:09:26 -0500 (EST)
Message-ID: <50A270AB.5040305@redhat.com>
Date: Tue, 13 Nov 2012 11:09:15 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/8] sched, numa, mm: Add last_cpu to page flags
References: <20121112160451.189715188@chello.nl> <20121112161215.685202629@chello.nl>
In-Reply-To: <20121112161215.685202629@chello.nl>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>

On 11/12/2012 11:04 AM, Peter Zijlstra wrote:
> @@ -706,6 +669,51 @@ static inline int page_to_nid(const stru
>   }
>   #endif
>
> +#ifdef CONFIG_SCHED_NUMA
> +#ifdef LAST_CPU_NOT_IN_PAGE_FLAGS
> +static inline int page_xchg_last_cpu(struct page *page, int cpu)
> +{
> +	return xchg(&page->_last_cpu, cpu);
> +}
> +
> +static inline int page_last_cpu(struct page *page)
> +{
> +	return page->_last_cpu;
> +}
> +#else
> +static inline int page_xchg_last_cpu(struct page *page, int cpu)
> +{
> +	unsigned long old_flags, flags;
> +	int last_cpu;
> +
> +	do {
> +		old_flags = flags = page->flags;
> +		last_cpu = (flags >> LAST_CPU_PGSHIFT) & LAST_CPU_MASK;
> +
> +		flags &= ~(LAST_CPU_MASK << LAST_CPU_PGSHIFT);
> +		flags |= (cpu & LAST_CPU_MASK) << LAST_CPU_PGSHIFT;
> +	} while (unlikely(cmpxchg(&page->flags, old_flags, flags) != old_flags));
> +
> +	return last_cpu;
> +}

These functions, and the accompanying config option, could
use some comments and documentation, explaining why things
are done this way, why it is safe, and what (if any) constraints
it places on other users of page.flags ...

> +static inline int page_last_cpu(struct page *page)
> +{
> +	return (page->flags >> LAST_CPU_PGSHIFT) & LAST_CPU_MASK;
> +}
> +#endif /* LAST_CPU_NOT_IN_PAGE_FLAGS */
> +#else /* CONFIG_SCHED_NUMA */
> +static inline int page_xchg_last_cpu(struct page *page, int cpu)
> +{
> +	return page_to_nid(page);
> +}
> +
> +static inline int page_last_cpu(struct page *page)
> +{
> +	return page_to_nid(page);
> +}
> +#endif /* CONFIG_SCHED_NUMA */
> +


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
