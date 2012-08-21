Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id C05176B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 13:51:12 -0400 (EDT)
Subject: Re: [RFC PATCH 2/2] mm: Batch page_check_references in
 shrink_page_list sharing the same i_mmap_mutex
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20120821132129.GC6960@linux.intel.com>
References: <1345251998.13492.235.camel@schen9-DESK>
	 <1345480982.13492.239.camel@schen9-DESK>
	 <20120821132129.GC6960@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 Aug 2012 10:51:02 -0700
Message-ID: <1345571462.13492.249.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Alex Shi <alex.shi@intel.com>

On Tue, 2012-08-21 at 09:21 -0400, Matthew Wilcox wrote:

> Is there a (performant) way to avoid passing around the
> 'mmap_mutex_locked' state?
> 
> For example, does it hurt to have all the callers hold the i_mmap_mutex()
> over the entire call, or do we rely on being able to execute large chunks
> of this in parallel?
> 
> Here's what I'm thinking:
> 
> 1. Rename the existing page_referenced implementation to __page_referenced().
> 2. Add:
> 
> int needs_page_mmap_mutex(struct page *page)
> {
> 	return page->mapping && page_mapped(page) && page_rmapping(page) &&
> 		!PageKsm(page) && !PageAnon(page);
> }
> 
> int page_referenced(struct page *page, int is_locked, struct mem_cgroup *memcg,
> 						unsigned long *vm_flags)
> {
> 	int result, needs_lock;
> 
> 	needs_lock = needs_page_mmap_mutex(page);
> 	if (needs_lock)
> 		mutex_lock(&page->mapping->i_mmap_mutex);
> 	result = __page_referenced(page, is_locked, memcg, vm_flags);
> 	if (needs_lock)
> 		mutex_unlock(&page->mapping->i_mmap_mutex);
> 	return result;
> }
> 
> 3. Rename the existing try_to_unmap() to __try_to_unmap()
> 4. Add:
> 
> int try_to_unmap(struct page *page, enum ttu_flags flags)
> {
> 	int result, needs_lock;
> 	
> 	needs_lock = needs_page_mmap_mutex(page);
> 	if (needs_lock)
> 		mutex_lock(&page->mapping->i_mmap_mutex);
> 	result = __try_to_unmap(page, is_locked, memcg, vm_flags);
> 	if (needs_lock)
> 		mutex_unlock(&page->mapping->i_mmap_mutex);
> 	return result;
> }
> 
> 5. Change page_check_references to always call __page_referenced (since it
> now always holds the mutex)
> 6. Replace the mutex_lock() calls in page_referenced_file() and
> try_to_unmap_file() with
> 	BUG_ON(!mutex_is_locked(&mapping->i_mmap_mutex));
> 7. I think you can simplify this:

I like your proposal and will try to test with a new patch along your
suggestions.  Though I will be out the rest of the week and may be
delayed a bit getting the testing completed.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
