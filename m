Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF696B025F
	for <linux-mm@kvack.org>; Sun, 13 Aug 2017 08:08:40 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id c74so83066929iod.4
        for <linux-mm@kvack.org>; Sun, 13 Aug 2017 05:08:40 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id o68si3265858ith.199.2017.08.13.05.08.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Aug 2017 05:08:39 -0700 (PDT)
Date: Sun, 13 Aug 2017 14:08:08 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 6/7] mm: fix MADV_[FREE|DONTNEED] TLB flush miss
 problem
Message-ID: <20170813120808.ph4zlz5u4p2edqev@hirez.programming.kicks-ass.net>
References: <20170802000818.4760-1-namit@vmware.com>
 <20170802000818.4760-7-namit@vmware.com>
 <20170811133020.zozuuhbw72lzolj5@hirez.programming.kicks-ass.net>
 <E340B75B-2830-4E6D-BF0A-2C58A7002CF1@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <E340B75B-2830-4E6D-BF0A-2C58A7002CF1@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>

On Sun, Aug 13, 2017 at 06:14:21AM +0000, Nadav Amit wrote:
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Tue, Aug 01, 2017 at 05:08:17PM -0700, Nadav Amit wrote:
> >> void tlb_finish_mmu(struct mmu_gather *tlb,
> >> 		unsigned long start, unsigned long end)
> >> {
> >> -	arch_tlb_finish_mmu(tlb, start, end);
> >> +	/*
> >> +	 * If there are parallel threads are doing PTE changes on same range
> >> +	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
> >> +	 * flush by batching, a thread has stable TLB entry can fail to flush
> >> +	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
> >> +	 * forcefully if we detect parallel PTE batching threads.
> >> +	 */
> >> +	bool force = mm_tlb_flush_nested(tlb->mm);
> >> +
> >> +	arch_tlb_finish_mmu(tlb, start, end, force);
> >> }
> > 
> > I don't understand the comment nor the ordering. What guarantees we see
> > the increment if we need to?
> 
> The comment regards the problem that is described in the change-log, and a
> long thread that is referenced in it. So the question is whether a??I dona??t
> understanda?? means a??I dona??t understanda?? or a??it is not clear enougha??. Ia??ll
> be glad to address either one - just say which.

I only read the comment, that _should_ be sufficient. Comments that rely
on Changelogs and random threads are useless.

The comment on its own simply doesn't make sense.

> As for the ordering - I tried to clarify it in the thread of the commit. Let
> me know if it is clear now.

Yeah, I'll do a new patch because if it only cares about _the_ PTL, we
can do away with that extra smp_mb__after_atomic().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
