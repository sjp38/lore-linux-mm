Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 9EA5B6B0033
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 11:03:08 -0400 (EDT)
Date: Mon, 19 Aug 2013 15:48:53 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 2/7] mm: munlock: remove unnecessary call to
 lru_add_drain()
Message-ID: <20130819144853.GB23002@suse.de>
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
 <1376915022-12741-3-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1376915022-12741-3-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, J?rn Engel <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Mon, Aug 19, 2013 at 02:23:37PM +0200, Vlastimil Babka wrote:
> In munlock_vma_range(), lru_add_drain() is currently called in a loop before
> each munlock_vma_page() call.
> This is suboptimal for performance when munlocking many pages. The benefits
> of per-cpu pagevec for batching the LRU putback are removed since the pagevec
> only holds at most one page from the previous loop's iteration.
> 
> The lru_add_drain() call also does not serve any purposes for correctness - it
> does not even drain pagavecs of all cpu's. The munlock code already expects
> and handles situations where a page cannot be isolated from the LRU (e.g.
> because it is on some per-cpu pagevec).
> 
> The history of the (not commented) call also suggest that it appears there as
> an oversight rather than intentionally. Before commit ff6a6da6 ("mm: accelerate
> munlock() treatment of THP pages") the call happened only once upon entering the
> function. The commit has moved the call into the while loope. So while the
> other changes in the commit improved munlock performance for THP pages, it
> introduced the abovementioned suboptimal per-cpu pagevec usage.
> 
> Further in history, before commit 408e82b7 ("mm: munlock use follow_page"),
> munlock_vma_pages_range() was just a wrapper around __mlock_vma_pages_range
> which performed both mlock and munlock depending on a flag. However, before
> ba470de4 ("mmap: handle mlocked pages during map, remap, unmap") the function
> handled only mlock, not munlock. The lru_add_drain call thus comes from the
> implementation in commit b291f000 ("mlock: mlocked pages are unevictable" and
> was intended only for mlocking, not munlocking. The original intention of
> draining the LRU pagevec at mlock time was to ensure the pages were on the LRU
> before the lock operation so that they could be placed on the unevictable list
> immediately. There is very little motivation to do the same in the munlock path
> this, particularly for every single page.
> 
> This patch therefore removes the call completely. After removing the call, a
> 10% speedup was measured for munlock() of a 56GB large memory area with THP
> disabled.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Reviewed-by: Jorn Engel <joern@logfs.org>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
