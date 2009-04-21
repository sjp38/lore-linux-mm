Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6E5136B004F
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 03:54:20 -0400 (EDT)
Subject: Re: [PATCH 18/25] Do not disable interrupts in free_page_mlock()
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1240266011-11140-19-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie>
	 <1240266011-11140-19-git-send-email-mel@csn.ul.ie>
Date: Tue, 21 Apr 2009 10:55:07 +0300
Message-Id: <1240300507.771.52.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-04-20 at 23:20 +0100, Mel Gorman wrote:
> free_page_mlock() tests and clears PG_mlocked using locked versions of the
> bit operations. If set, it disables interrupts to update counters and this
> happens on every page free even though interrupts are disabled very shortly
> afterwards a second time.  This is wasteful.
> 
> This patch splits what free_page_mlock() does. The bit check is still
> made. However, the update of counters is delayed until the interrupts are
> disabled and the non-lock version for clearing the bit is used. One potential
> weirdness with this split is that the counters do not get updated if the
> bad_page() check is triggered but a system showing bad pages is getting
> screwed already.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

> ---
>  mm/internal.h   |   11 +++--------
>  mm/page_alloc.c |    8 +++++++-
>  2 files changed, 10 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/internal.h b/mm/internal.h
> index 987bb03..58ec1bc 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -157,14 +157,9 @@ static inline void mlock_migrate_page(struct page *newpage, struct page *page)
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

Maybe add a VM_BUG_ON(!PageMlocked(page))?

> +	__ClearPageMlocked(page);
> +	__dec_zone_page_state(page, NR_MLOCK);
> +	__count_vm_event(UNEVICTABLE_MLOCKFREED);
>  }
>  
>  #else /* CONFIG_HAVE_MLOCKED_PAGE_BIT */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
