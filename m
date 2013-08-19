Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 06E666B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 11:12:58 -0400 (EDT)
Date: Mon, 19 Aug 2013 15:58:43 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 3/7] mm: munlock: batch non-THP page isolation and
 munlock+putback using pagevec
Message-ID: <20130819145843.GC23002@suse.de>
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
 <1376915022-12741-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1376915022-12741-4-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, J?rn Engel <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Mon, Aug 19, 2013 at 02:23:38PM +0200, Vlastimil Babka wrote:
> Currently, munlock_vma_range() calls munlock_vma_page on each page in a loop,
> which results in repeated taking and releasing of the lru_lock spinlock for
> isolating pages one by one. This patch batches the munlock operations using
> an on-stack pagevec, so that isolation is done under single lru_lock. For THP
> pages, the old behavior is preserved as they might be split while putting them
> into the pagevec. After this patch, a 9% speedup was measured for munlocking
> a 56GB large memory area with THP disabled.
> 
> A new function __munlock_pagevec() is introduced that takes a pagevec and:
> 1) It clears PageMlocked and isolates all pages under lru_lock. Zone page stats
> can be also updated using the variant which assumes disabled interrupts.
> 2) It finishes the munlock and lru putback on all pages under their lock_page.
> Note that previously, lock_page covered also the PageMlocked clearing and page
> isolation, but it is not needed for those operations.
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
