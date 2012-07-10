Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id B52046B0075
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 20:08:58 -0400 (EDT)
Date: Mon, 9 Jul 2012 17:08:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: Warn about costly page allocation
Message-Id: <20120709170856.ca67655a.akpm@linux-foundation.org>
In-Reply-To: <1341878153-10757-1-git-send-email-minchan@kernel.org>
References: <1341878153-10757-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, 10 Jul 2012 08:55:53 +0900
Minchan Kim <minchan@kernel.org> wrote:

> ...
>
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2276,6 +2276,29 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
>  	return alloc_flags;
>  }
>  
> +#if defined(CONFIG_DEBUG_VM) && !defined(CONFIG_COMPACTION)
> +static inline void check_page_alloc_costly_order(unsigned int order, gfp_t flags)
> +{
> +	if (likely(order <= PAGE_ALLOC_COSTLY_ORDER))
> +		return;
> +
> +	if (!printk_ratelimited())
> +		return;
> +
> +	pr_warn("%s: page allocation high-order stupidity: "
> +		"order:%d, mode:0x%x\n", current->comm, order, flags);
> +	pr_warn("Enable compaction if high-order allocations are "
> +		"very few and rare.\n");
> +	pr_warn("If you need regular high-order allocation, "
> +		"compaction wouldn't help it.\n");
> +	dump_stack();
> +}
> +#else
> +static inline void check_page_alloc_costly_order(unsigned int order)
> +{
> +}
> +#endif

Let's remember that plain old "inline" is ignored by the compiler.  If
we really really want to inline something then we should use
__always_inline.

And inlining this function would be a bad thing to do - it causes the
outer function to have an increased cache footprint.  A good way to
optimise this function is probably to move the unlikely stuff
out-of-line:

	if (unlikely(order > PAGE_ALLOC_COSTLY_ORDER))
		check_page_alloc_costly_order(...);

or

static noinline void __check_page_alloc_costly_order(...)
{
}

static __always_inline void check_page_alloc_costly_order(...)
{
	if (unlikely(order > PAGE_ALLOC_COSTLY_ORDER))
		__check_page_alloc_costly_order(...);
}
	

Also, the displayed messages don't seem very, umm, professional.  Who
was stupid - us or the kernel-configurer?  And "Enable
CONFIG_COMPACTION" would be more specific (and hence helpful) than
"Enable compaction").

And how on earth is the user, or the person who is configuring kernels
for customers to determine whether the kernel will be frequently
performing higher-order allocations?


So I dunno, this all looks like we have a kernel problem and we're
throwing our problem onto hopelessly ill-equipped users of that kernel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
