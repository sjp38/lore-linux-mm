Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C29D66B025F
	for <linux-mm@kvack.org>; Sun, 13 Aug 2017 21:26:20 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u199so108689350pgb.13
        for <linux-mm@kvack.org>; Sun, 13 Aug 2017 18:26:20 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id j10si3925944plg.38.2017.08.13.18.26.18
        for <linux-mm@kvack.org>;
        Sun, 13 Aug 2017 18:26:19 -0700 (PDT)
Date: Mon, 14 Aug 2017 10:26:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 6/7] mm: fix MADV_[FREE|DONTNEED] TLB flush miss
 problem
Message-ID: <20170814012617.GB25427@bbox>
References: <20170802000818.4760-1-namit@vmware.com>
 <20170802000818.4760-7-namit@vmware.com>
 <20170811133020.zozuuhbw72lzolj5@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170811133020.zozuuhbw72lzolj5@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nadav Amit <namit@vmware.com>, linux-mm@kvack.org, nadav.amit@gmail.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, linux-arch@vger.kernel.org

Hi Peter,

On Fri, Aug 11, 2017 at 03:30:20PM +0200, Peter Zijlstra wrote:
> On Tue, Aug 01, 2017 at 05:08:17PM -0700, Nadav Amit wrote:
> >  void tlb_finish_mmu(struct mmu_gather *tlb,
> >  		unsigned long start, unsigned long end)
> >  {
> > -	arch_tlb_finish_mmu(tlb, start, end);
> > +	/*
> > +	 * If there are parallel threads are doing PTE changes on same range
> > +	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
> > +	 * flush by batching, a thread has stable TLB entry can fail to flush
> > +	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
> > +	 * forcefully if we detect parallel PTE batching threads.
> > +	 */
> > +	bool force = mm_tlb_flush_nested(tlb->mm);
> > +
> > +	arch_tlb_finish_mmu(tlb, start, end, force);
> >  }
> 
> I don't understand the comment nor the ordering. What guarantees we see
> the increment if we need to?

How about this about commenting part?
