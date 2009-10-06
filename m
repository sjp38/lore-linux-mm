Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1B3826B004D
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 21:11:18 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n961BGJs021078
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 6 Oct 2009 10:11:16 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B4F345DE4F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 10:11:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CB1D145DE4E
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 10:11:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9042B1DB803F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 10:11:15 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 455831DB803B
	for <linux-mm@kvack.org>; Tue,  6 Oct 2009 10:11:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [rfc patch 3/3] mm: munlock COW pages on truncation unmap
In-Reply-To: <20091005193200.GA13040@cmpxchg.org>
References: <2f11576a0910030656l73c9811w18e0f224fb3d98af@mail.gmail.com> <20091005193200.GA13040@cmpxchg.org>
Message-Id: <20091006100724.5F97.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  6 Oct 2009 10:11:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: mm: order evictable rescue in LRU putback
> 
> Isolators putting a page back to the LRU do not hold the page lock,
> and if the page is mlocked, another thread might munlock it
> concurrently.
> 
> Expecting this, the putback code re-checks the evictability of a page
> when it just moved it to the unevictable list in order to correct its
> decision.
> 
> The problem, however, is that ordering is not garuanteed between
> setting PG_lru when moving the page to the list and checking
> PG_mlocked afterwards:
> 
> 	#0 putback			#1 munlock
> 
> 	spin_lock()
> 					if (TestClearPageMlocked())
> 					  if (PageLRU())
> 					    move to evictable list
> 	SetPageLRU()
> 	spin_unlock()
> 	if (!PageMlocked())
> 	  move to evictable list
> 
> The PageMlocked() reading may get reordered before SetPageLRU() in #0,
> resulting in #0 not moving the still mlocked page, and in #1 failing
> to isolate and move the page as well.  The evictable page is now
> stranded on the unevictable list.
> 
> TestClearPageMlocked() in #1 already provides full memory barrier
> semantics.
> 
> This patch adds an explicit full barrier to force ordering between
> SetPageLRU() and PageMlocked() in #0 so that either one of the
> competitors rescues the page.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  mm/vmscan.c |   10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -544,6 +544,16 @@ redo:
>  		 */
>  		lru = LRU_UNEVICTABLE;
>  		add_page_to_unevictable_list(page);
> +		/*
> +		 * When racing with an mlock clearing (page is
> +		 * unlocked), make sure that if the other thread does
> +		 * not observe our setting of PG_lru and fails
> +		 * isolation, we see PG_mlocked cleared below and move
> +		 * the page back to the evictable list.
> +		 *
> +		 * The other side is TestClearPageMlocked().
> +		 */
> +		smp_mb();
>  	}

IA64 is most relax cpu reorder architecture. I'm usually test on it
and my test found no problem.
Then, I don't think this issue occur in the real world. but I think
this patch is right.

Hannes, you are great.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
