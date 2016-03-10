Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 08EE46B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 11:10:39 -0500 (EST)
Received: by mail-qg0-f43.google.com with SMTP id u110so74287949qge.3
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 08:10:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x4si4249967qkx.21.2016.03.10.08.10.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 08:10:38 -0800 (PST)
Date: Thu, 10 Mar 2016 17:10:35 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp, mm: remove comments on serializion of THP split vs.
 gup_fast
Message-ID: <20160310161035.GD30716@redhat.com>
References: <1456329561-4319-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160224185025.65711ed6@thinkpad>
 <20160225150744.GA19707@node.shutemov.name>
 <alpine.LSU.2.11.1602252233280.9793@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1602252233280.9793@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, Feb 25, 2016 at 10:50:14PM -0800, Hugh Dickins wrote:
> It's a useful suggestion from Gerald, and your THP rework may have
> brought us closer to being able to rely on RCU locking rather than
> IRQ disablement there; but you were right just to delete the comment,
> there are other reasons why fast GUP still depends on IRQs disabled.
> 
> For example, see the fallback tlb_remove_table_one() in mm/memory.c:
> that one uses smp_call_function() sending IPI to all CPUs concerned,
> without waiting an RCU grace period at all.

I full agree, the refcounting change just drops the THP splitting from
the equation, but everything else remains. It's not like x86 is using
RCU for gup_fast when CONFIG_TRANSPARENT_HUGEPAGE=n.

The main issue Peter also pointed out is how it can be faster to wait
a RCU grace period than sending an IPI to only the CPU that have an
active_mm matching the one the page belongs to and I'm not exactly
sure the cost of disabling irqs in gup_fast is going to pay off. It's
not just swap, large munmap should be able to free up pagetables or
pagetables would get a footprint out of proportion with the Rss of the
process, and in turn it'll have to either block synchronously for long
before returning to userland, or return to userland when the pagetable
memory is still not free, and userland may mmap again and munmap again
in a loop and being legit doing so too, with unclear side effects with
regard to false positive OOM.

Then there's another issue with synchronize_sched(),
__get_user_pages_fast has to safe to run from irq (note the
local_irq_save instead of local_irq_disable) and KVM leverages it. KVM
just requires it to be atomic so it can run from inside a preempt
disabled section (i.e. inside a spinlock), I'm fairly certain the
irq-safe guarantee could be dropped without pain and
rcu_read_lock_sched() would be enough, but the documentation of the
IRQ-safe guarantees provided by __get_user_pages_fast should be also
altered if we were to use synchronize_sched() and that's a symbol
exported to GPL modules too.

Overall my main concern in switching x86 to RCU gup-fast is the
performance of synchronize_sched in large munmap pagetable teardown.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
