Subject: Re: [patch] not to disturb page LRU state when unmapping memory
	range
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <b040c32a0701302041j2a99e2b6p91b0b4bfa065444a@mail.gmail.com>
References: <b040c32a0701302041j2a99e2b6p91b0b4bfa065444a@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 31 Jan 2007 13:26:36 +0100
Message-Id: <1170246396.9516.39.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-01-30 at 20:41 -0800, Ken Chen wrote:
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

We do not maintain the accessed state with faults. We might set an
initial ref bit, but thereafter it is up to page reclaim to scan for pte
young pages.

So by blindly removing the mark_page_accessed() call we do lose
information, it might have been recently referenced and it might still
be relevant (think of sliding mmaps and such).

That said, I think mark_page_accessed() does the wrong thing here, if it
were the page scanner that would pass by it would only act as if
PageReferenced() were set.

So may I suggest the following?

It preserves the information, but not more.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
diff --git a/mm/memory.c b/mm/memory.c
index ef09f0a..b1f9129 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -678,7 +678,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 				if (pte_dirty(ptent))
 					set_page_dirty(page);
 				if (pte_young(ptent))
-					mark_page_accessed(page);
+					SetPageReferenced(page);
 				file_rss--;
 			}
 			page_remove_rmap(page, vma);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
