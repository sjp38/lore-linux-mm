Message-ID: <45185B33.6060109@yahoo.com.au>
Date: Tue, 26 Sep 2006 08:41:55 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 3/9] mm: speculative get page
References: <20060922172042.22370.62513.sendpatchset@linux.site>	 <20060922172110.22370.33715.sendpatchset@linux.site>	 <Pine.LNX.4.64.0609241802400.7935@blonde.wat.veritas.com>	 <4517382E.8010308@yahoo.com.au>  <20060925114739.GA31148@wotan.suse.de> <1159189453.5018.25.camel@lappy>
In-Reply-To: <1159189453.5018.25.camel@lappy>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:

>On Mon, 2006-09-25 at 13:47 +0200, Nick Piggin wrote:
>
>
>>+/*
>>+ * speculatively take a reference to a page.
>>+ * If the page is free (_count == 0), then _count is untouched, and 0
>>+ * is returned. Otherwise, _count is incremented by 1 and 1 is returned.
>>+ *
>>+ * This function must be run in the same rcu_read_lock() section as has
>>+ * been used to lookup the page in the pagecache radix-tree: this allows
>>+ * allocators to use a synchronize_rcu() to stabilize _count.
>>+ *
>>+ * Unless an RCU grace period has passed, the count of all pages coming out
>>+ * of the allocator must be considered unstable. page_count may return higher
>>+ * than expected, and put_page must be able to do the right thing when the
>>+ * page has been finished with (because put_page is what is used to drop an
>>+ * invalid speculative reference).
>>+ *
>>+ * This forms the core of the lockless pagecache locking protocol, where
>>+ * the lookup-side (eg. find_get_page) has the following pattern:
>>+ * 1. find page in radix tree
>>+ * 2. conditionally increment refcount
>>+ * 3. check the page is still in pagecache (if no, goto 1)
>>+ *
>>+ * Remove-side that cares about stability of _count (eg. reclaim) has the
>>
>                                   ^^^^^^^^^^^^^^^^^^^
>is that the reason that the following two code paths are good without
>change:
>
>  truncate_inode_page_range()
>   truncate_complete_page()
>     remove_from_page_cache()
>       radix_tree_delete()
>

^^^ Yes.

>and
>
>  zap_pte_range()
>    free_swap_and_cache()  <-- does check page_count()
>      delete_from_swap_cache()
>        __delete_from_swap_cache()
>          radix_tree_delete()
>
>>From the comments around the truncate bit it seems to be ok with keeping
>the page as anonymous, however the zap_pte_range() thing does seem to
>want to have a stable page_count().
>

However when I last looked at it, it count can be elevated there for other
reasons (I think it was swap IO or get_user_pages or something). Anyway,
those pages will remain on the LRU and eventually get reclaimed.

I did initially change that code around a little bit, but I remember
working through it with Hugh and we decided that it would be OK as it was.
It should indeed be commented though.

>>+ * following (with tree_lock held for write):
>>+ * A. atomically check refcount is correct and set it to 0 (atomic_cmpxchg)
>>+ * B. remove page from pagecache
>>+ * C. free the page
>>+ *
>>+ * There are 2 critical interleavings that matter:
>>+ * - 2 runs before A: in this case, A sees elevated refcount and bails out
>>+ * - A runs before 2: in this case, 2 sees zero refcount and retries;
>>+ *   subsequently, B will complete and 1 will find no page, causing the
>>+ *   lookup to return NULL.
>>+ *
>>+ * It is possible that between 1 and 2, the page is removed then the exact same
>>+ * page is inserted into the same position in pagecache. That's OK: the
>>+ * old find_get_page using tree_lock could equally have run before or after
>>+ * such a re-insertion, depending on order that locks are granted.
>>+ *
>>+ * Lookups racing against pagecache insertion isn't a big problem: either 1
>>+ * will find the page or it will not. Likewise, the old find_get_page could run
>>+ * either before the insertion or afterwards, depending on timing.
>>+ */
>>
>
>Awesome code ;-)
>

Thanks :) Well, thank Hugh.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
