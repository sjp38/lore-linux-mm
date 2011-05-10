Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 75AAA90010C
	for <linux-mm@kvack.org>; Tue, 10 May 2011 12:01:49 -0400 (EDT)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by bombadil.infradead.org with esmtps (Exim 4.72 #1 (Red Hat Linux))
	id 1QJpNa-0000DQ-CT
	for linux-mm@kvack.org; Tue, 10 May 2011 16:01:46 +0000
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1QJpNZ-0002T0-1B
	for linux-mm@kvack.org; Tue, 10 May 2011 16:01:45 +0000
Subject: Re: mmotm 2011-04-29 - wonky VmRSS and VmHWM values after swapping
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110502164430.eb7d451d.akpm@linux-foundation.org>
References: <201104300002.p3U02Ma2026266@imap1.linux-foundation.org>
	 <49683.1304296014@localhost> <8185.1304347042@localhost>
	 <20110502164430.eb7d451d.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 10 May 2011 18:04:45 +0200
Message-ID: <1305043485.2914.110.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Valdis.Kletnieks@vt.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2011-05-02 at 16:44 -0700, Andrew Morton wrote:
> On Mon, 02 May 2011 10:37:22 -0400
> Valdis.Kletnieks@vt.edu wrote:
> 
> > On Sun, 01 May 2011 20:26:54 EDT, Valdis.Kletnieks@vt.edu said:
> > > On Fri, 29 Apr 2011 16:26:16 PDT, akpm@linux-foundation.org said:
> > > > The mm-of-the-moment snapshot 2011-04-29-16-25 has been uploaded to
> > > > 
> > > >    http://userweb.kernel.org/~akpm/mmotm/
> > >  
> > > Dell Latitude E6500 laptop, Core2 Due P8700, 4G RAM, 2G swap.Z86_64 kernel.
> > > 
> > > I was running a backup of the system to an external USB hard drive.
> > 
> > Is a red herring.  Am seeing it again, after only 20 minutes of uptime, and so
> > far I've only gotten 1.2G or so into the 4G ram (2.5G still free), and never
> > touched swap yet.
> > 
> > Aha! I have a reproducer (found while composing this note).  /bin/su will
> > reliably trigger it (4 tries out of 4, launching from a bash shell that itself
> > has sane VmRSS and VmHWM values).  So it's a specific code sequence doing it
> > (probably one syscall doing something quirky).
> > 
> > Now if I could figure out how to make strace look at the VmRSS after each
> > syscall, or get gdb to do similar.  Any suggestions?  Am open to perf/other
> > solutions as well, if anybody has one handy...
> > 
> 
> hm, me too.  After boot, hald has a get_mm_counter(mm, MM_ANONPAGES) of
> 0xffffffffffff3c27.  Bisected to Pater's
> mm-extended-batches-for-generic-mmu_gather.patch, can't see how it did
> that.
> 

I haven't quite figured out how to reproduce, but does the below cure
things? If so, it should probably be folded into the first patch
(mm-mmu_gather-rework.patch?) since that is the one introducing this.

---
Subject: mm: Fix RSS zap_pte_range() accounting

Since we update the RSS counters when breaking out of the loop and
release the PTE lock, we should start with fresh deltas when we
restart the gather loop.

Reported-by: Valdis.Kletnieks@vt.edu
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1120,8 +1120,8 @@ static unsigned long zap_pte_range(struc
 	spinlock_t *ptl;
 	pte_t *pte;
 
-	init_rss_vec(rss);
 again:
+	init_rss_vec(rss);
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
 	do {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
