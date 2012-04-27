Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id EA2DA6B010F
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 17:32:05 -0400 (EDT)
Date: Fri, 27 Apr 2012 14:32:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: Warn once when a page is freed with PG_mlocked
Message-Id: <20120427143203.06b901b5.akpm@linux-foundation.org>
In-Reply-To: <1335548546-25040-1-git-send-email-yinghan@google.com>
References: <1335548546-25040-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>

On Fri, 27 Apr 2012 10:42:26 -0700
Ying Han <yinghan@google.com> wrote:

> I am resending this patch orginally from Mel, and the reason we spotted this
> is due to the next patch where I am adding the mlock stat into per-memcg
> meminfo. We found out that it is impossible to update the counter if the page
> is in the freeing patch w/ mlocked bit set.
> 
> Then we started wondering if it is possible at all. It shouldn't happen that
> freeing a mlocked page without going through munlock_vma_pages_all(). Looks
> like it did happen few years ago, and here is the patch introduced it
> 
> commit 985737cf2ea096ea946aed82c7484d40defc71a8
> Author: Lee Schermerhorn <lee.schermerhorn@hp.com>
> Date:   Sat Oct 18 20:26:53 2008 -0700
> 
>     mlock: count attempts to free mlocked page
> 
> There are two ways to persue and I would like to ask people's opinion:
> 
> 1. revert the patch totally and the page will get into bad_page(). Then we
> get the report as well.
> 
> 2. fix up the page like the patch does but put on warn_once() to report the
> problem.
> 
> People might feel more confident by doing step by step which adding the
> warn_on() first and then revert it later. So I resend the patch from Mel and
> here is the patch:
> 
> When a page is freed with the PG_mlocked set, it is considered an unexpected
> but recoverable situation. A counter records how often this event happens
> but it is easy to miss that this event has occured at all. This patch warns
> once when PG_mlocked is set to prompt debuggers to check the counter to
> see how often it is happening.

The changelog is kinda confusing and tl;dr, but the idea seems good ;)

> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -599,6 +599,11 @@ out:
>   */
>  static inline void free_page_mlock(struct page *page)
>  {
> +	WARN_ONCE(1, KERN_WARNING
> +		"Page flag mlocked set for process %s at pfn:%05lx\n"
> +		"page:%p flags:%#lx\n",
> +		current->comm, page_to_pfn(page),
> +		page, page->flags|__PG_MLOCKED);
>  	__dec_zone_page_state(page, NR_MLOCK);
>  	__count_vm_event(UNEVICTABLE_MLOCKFREED);
>  }

KERN_WARNING seems wimpy: we want to shout about this, so KERN_ERR.  Or
just leave it empty.

Also, the patch duplicates bad_page()/dump_page().  Can we use them?
They use KERN_ALERT, btw.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
