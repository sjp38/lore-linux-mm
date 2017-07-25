Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 16D246B0292
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 03:37:52 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q87so150223241pfk.15
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 00:37:52 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id t17si1105871pfg.662.2017.07.25.00.37.50
        for <linux-mm@kvack.org>;
        Tue, 25 Jul 2017 00:37:50 -0700 (PDT)
Date: Tue, 25 Jul 2017 16:37:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170725073748.GB22652@bbox>
References: <E9EE838F-F1E3-43A8-BB87-8B5B8388FF61@gmail.com>
 <20170719195820.drtfmweuhdc4eca6@suse.de>
 <4BD983A1-724B-4FD7-B502-55351717BC5F@gmail.com>
 <20170719214708.wuzq3di6rt43txtn@suse.de>
 <3D1386AD-7875-40B9-8C6F-DE02CF8A45A1@gmail.com>
 <20170719225950.wfpfzpc6llwlyxdo@suse.de>
 <4DC97890-9FFA-4BA4-B300-B679BAB2136D@gmail.com>
 <20170720074342.otez35bme5gytnxl@suse.de>
 <BD3A0EBE-ECF4-41D4-87FA-C755EA9AB6BD@gmail.com>
 <20170724095832.vgvku6vlxkv75r3k@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724095832.vgvku6vlxkv75r3k@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Hi Mel,

On Mon, Jul 24, 2017 at 10:58:32AM +0100, Mel Gorman wrote:
> On Fri, Jul 21, 2017 at 06:19:22PM -0700, Nadav Amit wrote:
> > > At the time of the unlock_page on the reclaim side, any unmapping that
> > > will happen before the flush has taken place. If KSM starts between the
> > > unlock_page and the tlb flush then it'll skip any of the PTEs that were
> > > previously unmapped with stale entries so there is no relevant stale TLB
> > > entry to work with.
> > 
> > I don???t see where this skipping happens, but let???s put this scenario aside
> > for a second. Here is a similar scenario that causes memory corruption. I
> > actually created and tested it (although I needed to hack the kernel to add
> > some artificial latency before the actual flushes and before the actual
> > dedupliaction of KSM).
> > 
> > We are going to cause KSM to deduplicate a page, and after page comparison
> > but before the page is actually replaced, to use a stale PTE entry to 
> > overwrite the page. As a result KSM will lose a write, causing memory
> > corruption.
> > 
> > For this race we need 4 CPUs:
> > 
> > CPU0: Caches a writable and dirty PTE entry, and uses the stale value for
> > write later.
> > 
> > CPU1: Runs madvise_free on the range that includes the PTE. It would clear
> > the dirty-bit. It batches TLB flushes.
> > 
> > CPU2: Writes 4 to /proc/PID/clear_refs , clearing the PTEs soft-dirty. We
> > care about the fact that it clears the PTE write-bit, and of course, batches
> > TLB flushes.
> > 
> > CPU3: Runs KSM. Our purpose is to pass the following test in
> > write_protect_page():
> > 
> > 	if (pte_write(*pvmw.pte) || pte_dirty(*pvmw.pte) ||
> > 	    (pte_protnone(*pvmw.pte) && pte_savedwrite(*pvmw.pte)))
> > 
> > Since it will avoid TLB flush. And we want to do it while the PTE is stale.
> > Later, and before replacing the page, we would be able to change the page.
> > 
> > Note that all the operations the CPU1-3 perform canhappen in parallel since
> > they only acquire mmap_sem for read.
> > 
> > We start with two identical pages. Everything below regards the same
> > page/PTE.
> > 
> > CPU0		CPU1		CPU2		CPU3
> > ----		----		----		----
> > Write the same
> > value on page
> > 
> > [cache PTE as
> >  dirty in TLB]
> > 
> > 		MADV_FREE
> > 		pte_mkclean()
> > 							
> > 				4 > clear_refs
> > 				pte_wrprotect()
> > 
> > 						write_protect_page()
> > 						[ success, no flush ]
> > 
> > 						pages_indentical()
> > 						[ ok ]
> > 
> > Write to page
> > different value
> > 
> > [Ok, using stale
> >  PTE]
> > 
> > 						replace_page()
> > 
> > 
> > Later, CPU1, CPU2 and CPU3 would flush the TLB, but that is too late. CPU0
> > already wrote on the page, but KSM ignored this write, and it got lost.
> > 
> 
> Ok, as you say you have reproduced this with corruption, I would suggest
> one path for dealing with it although you'll need to pass it by the
> original authors.
> 
> When unmapping ranges, there is a check for dirty PTEs in
> zap_pte_range() that forces a flush for dirty PTEs which aims to avoid
> writable stale PTEs from CPU0 in a scenario like you laid out above.
> 
> madvise_free misses a similar class of check so I'm adding Minchan Kim
> to the cc as the original author of much of that code. Minchan Kim will
> need to confirm but it appears that two modifications would be required.
> The first should pass in the mmu_gather structure to
> madvise_free_pte_range (at minimum) and force flush the TLB under the
> PTL if a dirty PTE is encountered. The second is that it should consider

OTL: I couldn't read this lengthy discussion so I miss miss something.

About MADV_FREE, I do not understand why it should flush TLB in MADV_FREE
context. MADV_FREE's semantic allows "write(ie, dirty)" so if other thread
in parallel which has stale pte does "store" to make the pte dirty,
it's okay since try_to_unmap_one in shrink_page_list catches the dirty.

In above example, I think KSM should flush the TLB, not MADV_FREE and
soft dirty page hander.

Maybe, I miss something clear, Could you explain it in detail?

> flushing the full affected range as madvise_free holds mmap_sem for
> read-only to avoid problems with two parallel madv_free operations. The
> second is optional because there are other ways it could also be handled
> that may have lower overhead.

Ditto. I cannot understand. Why does two parallel MADV_FREE have a problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
