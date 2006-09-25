Message-ID: <4517382E.8010308@yahoo.com.au>
Date: Mon, 25 Sep 2006 12:00:14 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 3/9] mm: speculative get page
References: <20060922172042.22370.62513.sendpatchset@linux.site> <20060922172110.22370.33715.sendpatchset@linux.site> <Pine.LNX.4.64.0609241802400.7935@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0609241802400.7935@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:

>On Fri, 22 Sep 2006, Nick Piggin wrote:
>
>>Index: linux-2.6/include/linux/page-flags.h
>>===================================================================
>>--- linux-2.6.orig/include/linux/page-flags.h
>>+++ linux-2.6/include/linux/page-flags.h
>>@@ -86,6 +86,8 @@
>> #define PG_nosave_free		18	/* Free, should not be written */
>> #define PG_buddy		19	/* Page is free, on buddy lists */
>> 
>>+#define PG_nonewrefs		20	/* Block concurrent pagecache lookups
>>+					 * while testing refcount */
>>
>
>Something I didn't get around to mentioning last time: I could well
>be mistaken, but it seemed that you could get along without all the
>PageNoNewRefs stuff, at cost of using something (too expensive?)
>like atomic_cmpxchg(&page->_count, 2, 0) in remove_mapping() and
>migrate_page_move_mapping(); compensated by simplification at the
>other end in page_cache_get_speculative(), which is already
>expected to be the hotter path.
>

Wow. That's amazing, why didn't I think of that? ;) Now that
we have a PG_buddy, this is going to work nicely.

>I find it unaesthetic (suspect you do too) to add that adhoc
>PageNoNewRefs method of freezing the count, when you're already
>demanding that count 0 must be frozen: why not make use of that?
>then since you know it's frozen while 0, you can easily insert
>the proper count at the end of the critical region.
>

Yes, and without using atomic ops, too.

>
>I didn't attempt to work out what memory barriers would be needed,
>but did test a version working that way on i386 - though I seem
>to have tidied those mods away to /dev/null since then.
>

Memory barriers will be reduced, because we're now only operating
on the single variable, rather than 2 (_count and flags), so we
don't need anything to order them (other than normal cache coherency).

Importantly, this will cut the smp_rmb() out of the speculative get,
which I suspect is why ia64 had slightly worse performance there.
Beautiful. (it will also cut out the smp_wmb()s and one atomic op out
of the write side).

>We disagreed over whether PageNoNewRefs usage in add_to_page_cache
>and __add_to_swap_cache was the same as in remove_mapping; but I
>think we agreed it could be avoided completely in those, just by
>being more careful about the ordering of the updates to struct page
>(I think it looked like the SetPageLocked needed to come earlier,
>but I forget the logic right now).
>

That's right. I have that in a followup patch, but in the interests
of keeping things small, I won't submit it for the first iteration.

>
>>+static inline int page_cache_get_speculative(struct page *page)
>>+{
>>+	VM_BUG_ON(in_interrupt());
>>+
>>+#ifndef CONFIG_SMP
>>+# ifdef CONFIG_PREEMPT
>>+	VM_BUG_ON(!in_atomic());
>>+# endif
>>+	/*
>>+	 * Preempt must be disabled here - we rely on rcu_read_lock doing
>>+	 * this for us.
>>+	 *
>>+	 * Pagecache won't be truncated from interrupt context, so if we have
>>+	 * found a page in the radix tree here, we have pinned its refcount by
>>+	 * disabling preempt, and hence no need for the "speculative get" that
>>+	 * SMP requires.
>>+	 */
>>+	VM_BUG_ON(page_count(page) == 0);
>>+	atomic_inc(&page->_count);
>>+
>>+#else
>>+	if (unlikely(!get_page_unless_zero(page)))
>>+		return 0; /* page has been freed */
>>
>
>This is the test which fails nicely whenever count is set to 0,
>whether because the page has been freed or because you wish to
>freeze it.  But if you do make such a change, callers of
>page_cache_get_speculative may need to loop a little differently
>when it fails (the page might not be freed).
>

Yes, they can just retry -- in the case that the page had been freed, 
they'll
find NULL in the radix tree slot on the next iteration: the 'return' here is
just a little shortcut.

>
>>+	VM_BUG_ON(PageCompound(page) && (struct page *)page_private(page) != page);
>>
>
>I found that VM_BUG_ON confusing, because it's only catching a tiny
>proportion of the cases you're interested in ruling out: most high
>order pages aren't PageCompound (but only the PageCompound ones offer
>that kind of check).  If you really want to keep the check, I think
>it needs a comment to explain that; but I'd just delete the line.
>

But it is OK to take a spec ref to a higher order non compound page, because
they follow the same refcounting rules as if they are individual order-0
pages.

Compound pages should be OK, because their constituent pages will have a 
count
of 0 and so will fail the previous test. This check was just for my own
satisfaction but I left it in as a form of commenting, however as you say I
should probably elaborate on that too.

Thank you thank you,
Nick
--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
