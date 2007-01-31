Date: Wed, 31 Jan 2007 18:02:12 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch] not to disturb page LRU state when unmapping memory
 range
In-Reply-To: <b040c32a0701302041j2a99e2b6p91b0b4bfa065444a@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0701311746230.6135@blonde.wat.veritas.com>
References: <b040c32a0701302041j2a99e2b6p91b0b4bfa065444a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jan 2007, Ken Chen wrote:

> I stomped on another piece of code in zap_pte_range() that is a bit
> questionable: when kernel unmaps an address range, it needs to transfer
> PTE state into page struct. Currently, kernel transfer both dirty bit
> and access bit via set_page_dirty and mark_page_accessed.
> 
> set_page_dirty is necessary and required.  However, transfering access
> bit doesn't look logical.  Kernel usually mark the page accessed at the
> time of fault, for example shmem_nopage() does so.  At unmap, another
> call to mark_page_accessed is called and this causes page LRU state to
> be bumped up one step closer to more recently used state. It is causing
> quite a bit headache in a scenario when a process creates a shmem segment,
> touch a whole bunch of pages, then unmaps it. The unmapping takes a long
> time because mark_page_accessed() will start moving pages from inactive
> to active list.
> 
> I'm not too much concerned with moving the page from one list to another
> in LRU. Sooner or later it might be moved because of multiple mappings
> from various processes.  But it just doesn't look logical that when user
> asks a range to be unmapped, it's his intention that the process is no
> longer interested in these pages. Moving those pages to active list (or
> bumping up a state towards more active) seems to be an over reaction. It
> also prolongs unmapping latency which is the core issue I'm trying to solve.
> 
> Given that the LRU state is maintained properly at fault time, I think we
> should remove it in the unmap path.
> 
> Signed-off-by: Ken Chen <kenchen@google.com>
> 
> ---
> Hugh, would you please review?

I'm sympathetic, but I'm going to chicken out on this one.  It was
me who made that set_page_dirty and mark_page_accessed conditional on
!PageAnon: because I didn't like the waste of time either, and could
see it was pointless in the PageAnon case.  But the situation is much
less clear to me in the file case, and it is very longstanding code.

If we had a large and representative set of test cases, I'd ask you to
run that with and without your change, and report back timings.  If.

Peter and Nick (and Rik and Andrea) are much better people to ask than
me, on such balancing matters - they have a much better feel for how
those LRUs end up working.

Peter's SetPageReferenced compromise seems appealing: I'd feel better
about it if we had other raw uses of SetPageReferenced in the balancing
code, to follow as precedents.  There used to be one in do_anonymous_page,
but Nick and I found that an odd-one-out and conspired to have it removed
in 2.6.16.

Hugh

> 
> diff -Nurp linux-2.6.20-rc6/mm/memory.c linux-2.6.20-rc6.unmap/mm/memory.c
> --- linux-2.6.20-rc6/mm/memory.c	2007-01-30 19:23:45.000000000 -0800
> +++ linux-2.6.20-rc6.unmap/mm/memory.c	2007-01-30 19:25:38.000000000 -0800
> @@ -677,8 +677,6 @@ static unsigned long zap_pte_range(struc
> 			else {
> 				if (pte_dirty(ptent))
> 					set_page_dirty(page);
> -				if (pte_young(ptent))
> -					mark_page_accessed(page);
> 				file_rss--;
> 			}
> 			page_remove_rmap(page, vma);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
