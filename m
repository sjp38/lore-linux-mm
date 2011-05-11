Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0E96B0024
	for <linux-mm@kvack.org>; Wed, 11 May 2011 18:53:35 -0400 (EDT)
Date: Wed, 11 May 2011 15:53:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2011-04-29 - wonky VmRSS and VmHWM values after swapping
Message-Id: <20110511155324.5c366900.akpm@linux-foundation.org>
In-Reply-To: <1305043485.2914.110.camel@laptop>
References: <201104300002.p3U02Ma2026266@imap1.linux-foundation.org>
	<49683.1304296014@localhost>
	<8185.1304347042@localhost>
	<20110502164430.eb7d451d.akpm@linux-foundation.org>
	<1305043485.2914.110.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Valdis.Kletnieks@vt.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 10 May 2011 18:04:45 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> > hm, me too.  After boot, hald has a get_mm_counter(mm, MM_ANONPAGES) of
> > 0xffffffffffff3c27.  Bisected to Pater's
> > mm-extended-batches-for-generic-mmu_gather.patch, can't see how it did
> > that.
> > 
> 
> I haven't quite figured out how to reproduce, but does the below cure
> things? If so, it should probably be folded into the first patch
> (mm-mmu_gather-rework.patch?) since that is the one introducing this.
> 
> ---
> Subject: mm: Fix RSS zap_pte_range() accounting
> 
> Since we update the RSS counters when breaking out of the loop and
> release the PTE lock, we should start with fresh deltas when we
> restart the gather loop.
> 
> Reported-by: Valdis.Kletnieks@vt.edu
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c
> +++ linux-2.6/mm/memory.c
> @@ -1120,8 +1120,8 @@ static unsigned long zap_pte_range(struc
>  	spinlock_t *ptl;
>  	pte_t *pte;
>  
> -	init_rss_vec(rss);
>  again:
> +	init_rss_vec(rss);
>  	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
>  	arch_enter_lazy_mmu_mode();
>  	do {

That fixed the negative hald VmHWM output on my test box.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
