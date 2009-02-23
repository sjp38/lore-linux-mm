Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 23BDF6B008C
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 04:19:09 -0500 (EST)
Subject: Re: [PATCH 15/20] Do not disable interrupts in free_page_mlock()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1235344649-18265-16-git-send-email-mel@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
	 <1235344649-18265-16-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain
Date: Mon, 23 Feb 2009 10:19:00 +0100
Message-Id: <1235380740.4645.2.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Sun, 2009-02-22 at 23:17 +0000, Mel Gorman wrote:
> free_page_mlock() tests and clears PG_mlocked. If set, it disables interrupts
> to update counters and this happens on every page free even though interrupts
> are disabled very shortly afterwards a second time.  This is wasteful.
> 
> This patch splits what free_page_mlock() does. The bit check is still
> made. However, the update of counters is delayed until the interrupts are
> disabled. One potential weirdness with this split is that the counters do
> not get updated if the bad_page() check is triggered but a system showing
> bad pages is getting screwed already.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/internal.h   |   10 ++--------
>  mm/page_alloc.c |    8 +++++++-
>  2 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/internal.h b/mm/internal.h
> index 478223b..b52bf86 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -155,14 +155,8 @@ static inline void mlock_migrate_page(struct page *newpage, struct page *page)
>   */
>  static inline void free_page_mlock(struct page *page)
>  {
> -	if (unlikely(TestClearPageMlocked(page))) {
> -		unsigned long flags;
> -
> -		local_irq_save(flags);
> -		__dec_zone_page_state(page, NR_MLOCK);
> -		__count_vm_event(UNEVICTABLE_MLOCKFREED);
> -		local_irq_restore(flags);
> -	}
> +	__dec_zone_page_state(page, NR_MLOCK);
> +	__count_vm_event(UNEVICTABLE_MLOCKFREED);
>  }

Its not actually clearing PG_mlocked anymore, so the name is now a tad
misleading.

That said, since we're freeing the page, there ought to not be another
reference to the page, in which case it appears to me we could safely
use the unlocked variant of TestClear*().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
