Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A43036B0254
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 11:40:38 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id fl4so70782310pad.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 08:40:38 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id s202si7049784pfs.76.2016.03.10.08.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 08:40:37 -0800 (PST)
Date: Thu, 10 Mar 2016 17:40:31 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] thp, mm: remove comments on serializion of THP split vs.
 gup_fast
Message-ID: <20160310164031.GM6375@twins.programming.kicks-ass.net>
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
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, Mar 10, 2016 at 05:34:39PM +0100, Peter Zijlstra wrote:
> 
> > Then there's another issue with synchronize_sched(),
> > __get_user_pages_fast has to safe to run from irq (note the
> > local_irq_save instead of local_irq_disable) and KVM leverages it.
> 
> This is unchanged. synchronize_sched() serialized against anything that
> disables preemption, having IRQs disabled is very much included in that.
> 
> So there should be no problem running this from IRQ context.

Think of it this way: synchronize_sched() waits for every cpu to have
called schedule() at least once. If you're inside an IRQ handler, you
cannot call schedule(), therefore the RCU (sched) QS cannot progress and
any dereferences you make must stay valid.

> > Overall my main concern in switching x86 to RCU gup-fast is the
> > performance of synchronize_sched in large munmap pagetable teardown.
> 
> Normally, as already established by Martin, you should not actually ever
> encounter the sync_sched() call. Only under severe memory pressure, when
> the batch alloc in tlb_remove_table() fails is this ever an issue.
> 
> And at the point where such allocations fail, performance typically
> isn't a concern anymore.

Note, I'm not advocating switching x86 over (although it might be an
interested experiment), I just wanted to clarify some points I perceived
you were not entirely clear on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
