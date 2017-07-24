Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3C796B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 05:58:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z48so22060665wrc.4
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 02:58:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n202si5319754wmd.152.2017.07.24.02.58.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 02:58:34 -0700 (PDT)
Date: Mon, 24 Jul 2017 10:58:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170724095832.vgvku6vlxkv75r3k@suse.de>
References: <20170719074131.75wexoal3fiyoxw5@suse.de>
 <E9EE838F-F1E3-43A8-BB87-8B5B8388FF61@gmail.com>
 <20170719195820.drtfmweuhdc4eca6@suse.de>
 <4BD983A1-724B-4FD7-B502-55351717BC5F@gmail.com>
 <20170719214708.wuzq3di6rt43txtn@suse.de>
 <3D1386AD-7875-40B9-8C6F-DE02CF8A45A1@gmail.com>
 <20170719225950.wfpfzpc6llwlyxdo@suse.de>
 <4DC97890-9FFA-4BA4-B300-B679BAB2136D@gmail.com>
 <20170720074342.otez35bme5gytnxl@suse.de>
 <BD3A0EBE-ECF4-41D4-87FA-C755EA9AB6BD@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <BD3A0EBE-ECF4-41D4-87FA-C755EA9AB6BD@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, Minchan Kim <minchan@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Fri, Jul 21, 2017 at 06:19:22PM -0700, Nadav Amit wrote:
> > At the time of the unlock_page on the reclaim side, any unmapping that
> > will happen before the flush has taken place. If KSM starts between the
> > unlock_page and the tlb flush then it'll skip any of the PTEs that were
> > previously unmapped with stale entries so there is no relevant stale TLB
> > entry to work with.
> 
> I don???t see where this skipping happens, but let???s put this scenario aside
> for a second. Here is a similar scenario that causes memory corruption. I
> actually created and tested it (although I needed to hack the kernel to add
> some artificial latency before the actual flushes and before the actual
> dedupliaction of KSM).
> 
> We are going to cause KSM to deduplicate a page, and after page comparison
> but before the page is actually replaced, to use a stale PTE entry to 
> overwrite the page. As a result KSM will lose a write, causing memory
> corruption.
> 
> For this race we need 4 CPUs:
> 
> CPU0: Caches a writable and dirty PTE entry, and uses the stale value for
> write later.
> 
> CPU1: Runs madvise_free on the range that includes the PTE. It would clear
> the dirty-bit. It batches TLB flushes.
> 
> CPU2: Writes 4 to /proc/PID/clear_refs , clearing the PTEs soft-dirty. We
> care about the fact that it clears the PTE write-bit, and of course, batches
> TLB flushes.
> 
> CPU3: Runs KSM. Our purpose is to pass the following test in
> write_protect_page():
> 
> 	if (pte_write(*pvmw.pte) || pte_dirty(*pvmw.pte) ||
> 	    (pte_protnone(*pvmw.pte) && pte_savedwrite(*pvmw.pte)))
> 
> Since it will avoid TLB flush. And we want to do it while the PTE is stale.
> Later, and before replacing the page, we would be able to change the page.
> 
> Note that all the operations the CPU1-3 perform canhappen in parallel since
> they only acquire mmap_sem for read.
> 
> We start with two identical pages. Everything below regards the same
> page/PTE.
> 
> CPU0		CPU1		CPU2		CPU3
> ----		----		----		----
> Write the same
> value on page
> 
> [cache PTE as
>  dirty in TLB]
> 
> 		MADV_FREE
> 		pte_mkclean()
> 							
> 				4 > clear_refs
> 				pte_wrprotect()
> 
> 						write_protect_page()
> 						[ success, no flush ]
> 
> 						pages_indentical()
> 						[ ok ]
> 
> Write to page
> different value
> 
> [Ok, using stale
>  PTE]
> 
> 						replace_page()
> 
> 
> Later, CPU1, CPU2 and CPU3 would flush the TLB, but that is too late. CPU0
> already wrote on the page, but KSM ignored this write, and it got lost.
> 

Ok, as you say you have reproduced this with corruption, I would suggest
one path for dealing with it although you'll need to pass it by the
original authors.

When unmapping ranges, there is a check for dirty PTEs in
zap_pte_range() that forces a flush for dirty PTEs which aims to avoid
writable stale PTEs from CPU0 in a scenario like you laid out above.

madvise_free misses a similar class of check so I'm adding Minchan Kim
to the cc as the original author of much of that code. Minchan Kim will
need to confirm but it appears that two modifications would be required.
The first should pass in the mmu_gather structure to
madvise_free_pte_range (at minimum) and force flush the TLB under the
PTL if a dirty PTE is encountered. The second is that it should consider
flushing the full affected range as madvise_free holds mmap_sem for
read-only to avoid problems with two parallel madv_free operations. The
second is optional because there are other ways it could also be handled
that may have lower overhead.

Soft dirty page handling may need similar protections.

> Now to reiterate my point: It is really hard to get TLB batching right
> without some clear policy. And it should be important, since such issues can
> cause memory corruption and have security implications (if somebody manages
> to get the timing right).
> 

Basically it comes down to when batching TLB flushes, care must be taken
when dealing with dirty PTEs that writable TLB entries do not leak data. The
reclaim TLB batching *should* still be ok as it allows stale entries to exist
but only up until the point where IO is queued to prevent data being
lost. I'm not aware of this being formally documented in the past. It's
possible that you could extent the mmu_gather API to track that state
and handle it properly in the general case so as long as someone uses
that API properly that they'll be protected.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
