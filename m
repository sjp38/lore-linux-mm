Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 498616B0254
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 11:34:48 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id u190so43236969pfb.3
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 08:34:48 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ut6si6948452pac.241.2016.03.10.08.34.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 08:34:47 -0800 (PST)
Date: Thu, 10 Mar 2016 17:34:39 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] thp, mm: remove comments on serializion of THP split vs.
 gup_fast
Message-ID: <20160310163439.GS6356@twins.programming.kicks-ass.net>
References: <1456329561-4319-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160224185025.65711ed6@thinkpad>
 <20160225150744.GA19707@node.shutemov.name>
 <alpine.LSU.2.11.1602252233280.9793@eggly.anvils>
 <20160310161035.GD30716@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160310161035.GD30716@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, Mar 10, 2016 at 05:10:35PM +0100, Andrea Arcangeli wrote:
> On Thu, Feb 25, 2016 at 10:50:14PM -0800, Hugh Dickins wrote:
> > It's a useful suggestion from Gerald, and your THP rework may have
> > brought us closer to being able to rely on RCU locking rather than
> > IRQ disablement there; but you were right just to delete the comment,
> > there are other reasons why fast GUP still depends on IRQs disabled.
> > 
> > For example, see the fallback tlb_remove_table_one() in mm/memory.c:
> > that one uses smp_call_function() sending IPI to all CPUs concerned,
> > without waiting an RCU grace period at all.
> 
> I full agree, the refcounting change just drops the THP splitting from
> the equation, but everything else remains. It's not like x86 is using
> RCU for gup_fast when CONFIG_TRANSPARENT_HUGEPAGE=n.
> 
> The main issue Peter also pointed out is how it can be faster to wait
> a RCU grace period than sending an IPI to only the CPU that have an
> active_mm matching the one the page belongs to 

Typically RCU (sched) grace periods take a relative 'forever' compared
to sending IPIs. That is, synchronize_sched() is typically slower.

But, on the upside, not sending IPIs will not perturb those other
CPUs, which is something HPC/RT people like.

> and I'm not exactly
> sure the cost of disabling irqs in gup_fast is going to pay off.

Entirely depends on the workload of course, but you can do a lot of
gup_fast compared to munmap()s. So making gup_fast, faster, seems like a
potential win. Also, is anybody really interested in munmap()
performance?

> It's
> not just swap, large munmap should be able to free up pagetables or
> pagetables would get a footprint out of proportion with the Rss of the
> process, and in turn it'll have to either block synchronously for long
> before returning to userland, or return to userland when the pagetable
> memory is still not free, and userland may mmap again and munmap again
> in a loop and being legit doing so too, with unclear side effects with
> regard to false positive OOM.

I'm not seeing that, the only point where this matters at all, is if the
batch alloc fails, otherwise the RCU_TABLE_FREE stuff uses
call_rcu_sched() and what you write above is true already.

Now, RCU already has an oom_notifier to push work harder if we approach
that.

> Then there's another issue with synchronize_sched(),
> __get_user_pages_fast has to safe to run from irq (note the
> local_irq_save instead of local_irq_disable) and KVM leverages it.

This is unchanged. synchronize_sched() serialized against anything that
disables preemption, having IRQs disabled is very much included in that.

So there should be no problem running this from IRQ context.

> KVM
> just requires it to be atomic so it can run from inside a preempt
> disabled section (i.e. inside a spinlock), I'm fairly certain the
> irq-safe guarantee could be dropped without pain and
> rcu_read_lock_sched() would be enough, but the documentation of the
> IRQ-safe guarantees provided by __get_user_pages_fast should be also
> altered if we were to use synchronize_sched() and that's a symbol
> exported to GPL modules too.

No changes needed.

> Overall my main concern in switching x86 to RCU gup-fast is the
> performance of synchronize_sched in large munmap pagetable teardown.

Normally, as already established by Martin, you should not actually ever
encounter the sync_sched() call. Only under severe memory pressure, when
the batch alloc in tlb_remove_table() fails is this ever an issue.

And at the point where such allocations fail, performance typically
isn't a concern anymore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
