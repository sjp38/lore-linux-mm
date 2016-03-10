Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f181.google.com (mail-yw0-f181.google.com [209.85.161.181])
	by kanga.kvack.org (Postfix) with ESMTP id C82776B0254
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 12:04:09 -0500 (EST)
Received: by mail-yw0-f181.google.com with SMTP id d65so72816571ywb.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 09:04:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d126si1532427ybb.236.2016.03.10.09.04.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 09:04:09 -0800 (PST)
Date: Thu, 10 Mar 2016 18:04:06 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp, mm: remove comments on serializion of THP split vs.
 gup_fast
Message-ID: <20160310170406.GF30716@redhat.com>
References: <1456329561-4319-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160224185025.65711ed6@thinkpad>
 <20160225150744.GA19707@node.shutemov.name>
 <alpine.LSU.2.11.1602252233280.9793@eggly.anvils>
 <20160310161035.GD30716@redhat.com>
 <20160310163439.GS6356@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160310163439.GS6356@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, Mar 10, 2016 at 05:34:39PM +0100, Peter Zijlstra wrote:
> I'm not seeing that, the only point where this matters at all, is if the
> batch alloc fails, otherwise the RCU_TABLE_FREE stuff uses
> call_rcu_sched() and what you write above is true already.

Not on x86, only if HAVE_RCU_TABLE_FREE is selected, which is not the
case for x86:

arch/arm/Kconfig:       select HAVE_RCU_TABLE_FREE if (SMP && ARM_LPAE)
arch/arm64/Kconfig:     select HAVE_RCU_TABLE_FREE
arch/powerpc/Kconfig:   select HAVE_RCU_TABLE_FREE if SMP
arch/sparc/Kconfig:     select HAVE_RCU_TABLE_FREE if SMP

> Normally, as already established by Martin, you should not actually ever
> encounter the sync_sched() call. Only under severe memory pressure, when
> the batch alloc in tlb_remove_table() fails is this ever an issue.

What I mean is that a large mmap/munmap loops may want to be
benchmarked to see if they end up stalling in the synchronize_sched
case through the memory pressure handler, in turn not restricting the
synchronize_sched to a real memory pressure situation but ending up in
the memory pressure just because of it. For example the normal load
running on ARM isn't as diverse as the one on x86 where RCU_TABLE_FREE
has never been exercised at large yet. I doubt anything like that
would ever materialize in light load, light munmap load certainly
would not be affected.

I doubt it'd be ok if munmap end up stalling in synchronize_sched. In
fact I'd feel safer if the srcu context can be added to the mm (but
that costs memory in the mm unless we're lucky with the slab hw
alignment), then I think synchronize_srcu may actually be preferable
than a full synchronize_sched that affects the entire system with
thousand of CPUs. A per-cpu inc wouldn't be a big deal and it would at
least avoid to stall for the whole system if a stall eventually has to
happen (unless every cpu is actually running gup_fast but that's ok in
such case).

About the IRQ safety of synchronize_sched, I was mistaken with sofitrq
which can block never mind sorry, of course local_irq_disable or
preempt_enable are both valid read barriers as schedule can't run.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
