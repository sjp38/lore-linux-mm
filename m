Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id E675C6B0033
	for <linux-mm@kvack.org>; Fri, 17 May 2013 16:39:14 -0400 (EDT)
Date: Fri, 17 May 2013 16:39:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/5] mm: Activate !PageLRU pages on mark_page_accessed if
 page is on local pagevec
Message-ID: <20130517203902.GB15721@cmpxchg.org>
References: <1368784087-956-1-git-send-email-mgorman@suse.de>
 <1368784087-956-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368784087-956-4-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>, Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>

On Fri, May 17, 2013 at 10:48:05AM +0100, Mel Gorman wrote:
> If a page is on a pagevec then it is !PageLRU and mark_page_accessed()
> may fail to move a page to the active list as expected. Now that the LRU
> is selected at LRU drain time, mark pages PageActive if they are on the
> local pagevec so it gets moved to the correct list at LRU drain time.
> Using a debugging patch it was found that for a simple git checkout based
> workload that pages were never added to the active file list in practice
> but with this patch applied they are.
> 
> 				before   after
> LRU Add Active File                  0      750583
> LRU Add Active Anon            2640587     2702818
> LRU Add Inactive File          8833662     8068353
> LRU Add Inactive Anon              207         200
> 
> Note that only pages on the local pagevec are considered on purpose. A
> !PageLRU page could be in the process of being released, reclaimed, migrated
> or on a remote pagevec that is currently being drained. Marking it PageActive
> is vunerable to races where PageLRU and Active bits are checked at the
> wrong time. Page reclaim will trigger VM_BUG_ONs but depending on when the
> race hits, it could also free a PageActive page to the page allocator and
> trigger a bad_page warning. Similarly a potential race exists between a
> per-cpu drain on a pagevec list and an activation on a remote CPU.
> 
> 				lru_add_drain_cpu
> 				__pagevec_lru_add
> 				  lru = page_lru(page);
> mark_page_accessed
>   if (PageLRU(page))
>     activate_page
>   else
>     SetPageActive
> 				  SetPageLRU(page);
> 				  add_page_to_lru_list(page, lruvec, lru);
> 
> In this case a PageActive page is added to the inactivate list and later the
> inactive/active stats will get skewed. While the PageActive checks in vmscan
> could be removed and potentially dealt with, a skew in the statistics would
> be very difficult to detect. Hence this patch deals just with the common case
> where a page being marked accessed has just been added to the local pagevec.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
