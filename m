Message-ID: <430B0662.3060509@yahoo.com.au>
Date: Tue, 23 Aug 2005 21:20:02 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFT][PATCH 2/2] pagefault scalability alternative
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com> <Pine.LNX.4.61.0508222229270.22924@goblin.wat.veritas.com> <430A6D08.1080707@yahoo.com.au> <Pine.LNX.4.61.0508230805040.5224@goblin.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.61.0508230805040.5224@goblin.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Tue, 23 Aug 2005, Nick Piggin wrote:

>>I had preempt_disable() in tlb_gather_mmu which I thought was nice,
>>but maybe you don't?
> 
> 
> I most definitely agree.  tlb_gather_mmu uses smp_processor_id when it
> should be using get_cpu, we don't usually open code the preempt_disable.
> 

Yep.

> But there's a number of things peculiar about tlb_gather_mmu and friends
> (e.g. the rss but not anon_rss asymmetry; and what have those got to do
> with "tlb" anyway?), spread over several arches, I decided to stay away
> for now, go into all that at a later date.  What it should be doing
> about rss depends rather on what Christoph ends up with there.
> 

I agree. I think moving rss accounting out of the tlb operations
and into mm/memory.c is a good idea too. I don't think there are
any problems doing so, either.

But we won't get bogged down on that right now.

> 
>>>+#ifdef CONFIG_SPLIT_PTLOCK
>>>+#define __pte_lockptr(page)	((spinlock_t *)&((page)->private))
>>>+#define pte_lock_init(page)	spin_lock_init(__pte_lockptr(page))
>>>+#define pte_lock_deinit(page)	((page)->mapping = NULL)
>>
>>Do you mean page->private?
> 
> 
> No, it does mean page->mapping: depending on DEBUG options and whatnot,
> the spinlock_t might (currently, I think) be as many as 5 unsigned longs,
> hich happily just happen to fit into the unmodified 32-bit struct page,
> and the only "corruption" which actually matters is that freeing a page
> protests if page->mapping is found set.
> 

OK no worries. Just so long as you don't overwrite ->_count,
the lockless pagecache is happy ;)

Which brings up another issue - this surely conflicts rather
badly with PageReserved removal :( Not that there is anything
wrong with that, but I don't like to create these kinds of
problems for people...

Do we still want to remove PageReserved sooner rather than
later?

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
