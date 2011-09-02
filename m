Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC586B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 20:09:04 -0400 (EDT)
Date: Thu, 1 Sep 2011 17:03:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] thp: tail page refcounting fix #5
Message-Id: <20110901170353.6f92b50f.akpm@linux-foundation.org>
In-Reply-To: <20110901152417.GF10779@redhat.com>
References: <CANN689HE=TKyr-0yDQgXEoothGJ0Cw0HLB2iOvCKrOXVF2DNww@mail.gmail.com>
	<20110824000914.GH23870@redhat.com>
	<20110824002717.GI23870@redhat.com>
	<20110824133459.GP23870@redhat.com>
	<20110826062436.GA5847@google.com>
	<20110826161048.GE23870@redhat.com>
	<20110826185430.GA2854@redhat.com>
	<20110827094152.GA16402@google.com>
	<20110827173421.GA2967@redhat.com>
	<CAEwNFnDk0bQZKReKccuQMPEw_6EA2DxN4dm9cmjr01BVT4A7Dw@mail.gmail.com>
	<20110901152417.GF10779@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, 1 Sep 2011 17:24:17 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Michel while working on the working set estimation code, noticed that calling
> get_page_unless_zero() on a random pfn_to_page(random_pfn) wasn't safe, if the
> pfn ended up being a tail page of a transparent hugepage under splitting by
> __split_huge_page_refcount(). He then found the problem could also
> theoretically materialize with page_cache_get_speculative() during the
> speculative radix tree lookups that uses get_page_unless_zero() in SMP if the
> radix tree page is freed and reallocated and get_user_pages is called on it
> before page_cache_get_speculative has a chance to call get_page_unless_zero().
> 
> So the best way to fix the problem is to keep page_tail->_count zero at all
> times. This will guarantee that get_page_unless_zero() can never succeed on any
> tail page. page_tail->_mapcount is guaranteed zero and is unused for all tail
> pages of a compound page, so we can simply account the tail page references
> there and transfer them to tail_page->_count in __split_huge_page_refcount() (in
> addition to the head_page->_mapcount).
> 
> While debugging this s/_count/_mapcount/ change I also noticed get_page is
> called by direct-io.c on pages returned by get_user_pages. That wasn't entirely
> safe because the two atomic_inc in get_page weren't atomic. As opposed other
> get_user_page users like secondary-MMU page fault to establish the shadow
> pagetables would never call any superflous get_page after get_user_page
> returns. It's safer to make get_page universally safe for tail pages and to use
> get_page_foll() within follow_page (inside get_user_pages()). get_page_foll()
> is safe to do the refcounting for tail pages without taking any locks because
> it is run within PT lock protected critical sections (PT lock for pte and
> page_table_lock for pmd_trans_huge). The standard get_page() as invoked by
> direct-io instead will now take the compound_lock but still only for tail
> pages. The direct-io paths are usually I/O bound and the compound_lock is per
> THP so very finegrined, so there's no risk of scalability issues with it. A
> simple direct-io benchmarks with all lockdep prove locking and spinlock
> debugging infrastructure enabled shows identical performance and no overhead.
> So it's worth it. Ideally direct-io should stop calling get_page() on pages
> returned by get_user_pages(). The spinlock in get_page() is already optimized
> away for no-THP builds but doing get_page() on tail pages returned by GUP is
> generally a rare operation and usually only run in I/O paths.
> 
> This new refcounting on page_tail->_mapcount in addition to avoiding new RCU
> critical sections will also allow the working set estimation code to work
> without any further complexity associated to the tail page refcounting
> with THP.
> 

The patch overall takes the x86_64 allmodconfig text size of
arch/x86/mm/gup.o, mm/huge_memory.o, mm/memory.o and mm/swap.o from a
total of 85059 bytes up to 85973.  That's quite a lot of bloat for a
pretty small patch.

I'm suspecting that most of this is due to the new inlined
get_page_foll(), which is large enough to squish an elephant.  Could
you please take a look at reducing this impact?

>
> ...
>
> +/*
> + * The atomic page->_mapcount, starts from -1: so that transitions
> + * both from it and to it can be tracked, using atomic_inc_and_test
> + * and atomic_add_negative(-1).
> + */
> +static inline void reset_page_mapcount(struct page *page)

I think we should have originally named this page_mapcount_reset() This
is extra unimportant as it's a static symbol.

>
> ...
>
>  static inline void get_page(struct page *page)
>  {
> +	if (unlikely(PageTail(page)))
> +		if (likely(__get_page_tail(page)))
> +			return;

OK so we still have approximately one test-n-branch in the non-debug
get_page().

>  	/*
>  	 * Getting a normal page or the head of a compound page
> -	 * requires to already have an elevated page->_count. Only if
> -	 * we're getting a tail page, the elevated page->_count is
> -	 * required only in the head page, so for tail pages the
> -	 * bugcheck only verifies that the page->_count isn't
> -	 * negative.
> +	 * requires to already have an elevated page->_count.
>  	 */
> -	VM_BUG_ON(atomic_read(&page->_count) < !PageTail(page));
> +	VM_BUG_ON(atomic_read(&page->_count) <= 0);

I wonder how many people enable VM_BUG_ON().  We're pretty profligate
with those things in hot paths.

>  	atomic_inc(&page->_count);
> -	/*
> -	 * Getting a tail page will elevate both the head and tail
> -	 * page->_count(s).
> -	 */
> -	if (unlikely(PageTail(page))) {
> -		/*
> -		 * This is safe only because
> -		 * __split_huge_page_refcount can't run under
> -		 * get_page().
> -		 */
> -		VM_BUG_ON(atomic_read(&page->first_page->_count) <= 0);
> -		atomic_inc(&page->first_page->_count);
> -	}
>  }
>  
>  static inline struct page *virt_to_head_page(const void *x)
>
> ...
>
> +int __get_page_tail(struct page *page)
> +{
> +	/*
> +	 * This takes care of get_page() if run on a tail page
> +	 * returned by one of the get_user_pages/follow_page variants.
> +	 * get_user_pages/follow_page itself doesn't need the compound
> +	 * lock because it runs __get_page_tail_foll() under the
> +	 * proper PT lock that already serializes against
> +	 * split_huge_page().
> +	 */
> +	unsigned long flags;
> +	int got = 0;

Could be a bool if you like that sort of thing..

> +	struct page *page_head = compound_trans_head(page);

Missing newline here

> +	if (likely(page != page_head && get_page_unless_zero(page_head))) {
> +		/*
> +		 * page_head wasn't a dangling pointer but it
> +		 * may not be a head page anymore by the time
> +		 * we obtain the lock. That is ok as long as it
> +		 * can't be freed from under us.
> +		 */
> +		flags = compound_lock_irqsave(page_head);
> +		/* here __split_huge_page_refcount won't run anymore */
> +		if (likely(PageTail(page))) {
> +			__get_page_tail_foll(page, false);
> +			got = 1;
> +		}
> +		compound_unlock_irqrestore(page_head, flags);
> +		if (unlikely(!got))
> +			put_page(page_head);
> +	}
> +	return got;
> +}
> +EXPORT_SYMBOL(__get_page_tail);

Ordinarily I'd squeak about a global, exported-to-modules function
which is undocumented.  But this one is internal to get_page(), so it's
less necessary.

Still, documenting at least the return value (the "why" rather than the
"what") would make get_page() more understandable.

>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
