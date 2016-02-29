Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2440B6B0005
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 21:38:57 -0500 (EST)
Received: by mail-oi0-f41.google.com with SMTP id c203so3864147oia.2
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 18:38:57 -0800 (PST)
Received: from mail-ob0-x230.google.com (mail-ob0-x230.google.com. [2607:f8b0:4003:c01::230])
        by mx.google.com with ESMTPS id h3si19713005obe.83.2016.02.28.18.38.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Feb 2016 18:38:56 -0800 (PST)
Received: by mail-ob0-x230.google.com with SMTP id s6so72518595obg.3
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 18:38:56 -0800 (PST)
Date: Sun, 28 Feb 2016 18:38:46 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] thp, mm: remove comments on serializion of THP split
 vs. gup_fast
In-Reply-To: <20160226124118.41ad93a2@mschwide>
Message-ID: <alpine.LSU.2.11.1602281815210.3879@eggly.anvils>
References: <1456329561-4319-1-git-send-email-kirill.shutemov@linux.intel.com> <20160224185025.65711ed6@thinkpad> <20160225150744.GA19707@node.shutemov.name> <alpine.LSU.2.11.1602252233280.9793@eggly.anvils> <20160226110650.GY6356@twins.programming.kicks-ass.net>
 <20160226124118.41ad93a2@mschwide>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Fri, 26 Feb 2016, Martin Schwidefsky wrote:
> On Fri, 26 Feb 2016 12:06:50 +0100
> Peter Zijlstra <peterz@infradead.org> wrote:
> > On Thu, Feb 25, 2016 at 10:50:14PM -0800, Hugh Dickins wrote:
> > 
> > > For example, see the fallback tlb_remove_table_one() in mm/memory.c:
> > > that one uses smp_call_function() sending IPI to all CPUs concerned,
> > > without waiting an RCU grace period at all.
> > 
> > The better comment is with mmu_table_batch.
> > 
> > Its been too long for me to fully remember, nor have I really paid much
> > attention to this code in the past few years, so any memory I might have
> > had might be totally wrong.
> > 
> > But relying on rcu_read_lock_sched() and friends would mean replacing
> > that smp_call_function() with synchronize_sched().
> 
> That makes sense, just tried that together with a big fat printk to see if
> we hit that out-of-memory condition in the page table freeing code.
> The system is swapping like mad but no message so far.
>  
> > A real quick look at the current code seems to suggest that _might_ just
> > work, but note that that will be slower, RT and HPC people will like you
> > for it though.

Thanks for looking, Peter.

Just to make clear, "you" will not be me: apparently simple enough,
but needs a lot more careful testing than I have time to give it.

And here we are just talking about the HAVE_GENERIC_RCU_GUP,
HAVE_RCU_TABLE_FREE architectures (arm, arm64, powerpc, perhaps sparc).

Whether x86 would like to be converted over to the generic RCU GUP,
and give up on its IRQ disabling, is another matter.  Not an argument
I'll get into.  Could be a Kconfig choice I suppose, but that wouldn't
help the distros.

And, for OOM reasons, I do dislike adding any further delay to
freeing pages from exit (or if there's to be an OOM reaper, from zap).

> > 
> > So it depends on how hard we hit that special, totally out of memory,
> > case, and if we care about some performance if we do.
> 
> If the system is out of memory bad enough for the page allocation to fail
> an additional synchronize_sched() call probably won't hurt too much. Most
> of the time we'll be waiting for I/O anyway.

I agree, that case should be too uncommon, and already too slowed, to
worry about any slowdown there - unless it provides an expedited way
out of OOM in some cases - that might be a consideration.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
