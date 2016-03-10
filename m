Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8FDEF6B0254
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 12:22:53 -0500 (EST)
Received: by mail-qg0-f54.google.com with SMTP id u110so76204574qge.3
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 09:22:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c68si4488240qge.29.2016.03.10.09.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 09:22:52 -0800 (PST)
Date: Thu, 10 Mar 2016 18:22:49 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp, mm: remove comments on serializion of THP split vs.
 gup_fast
Message-ID: <20160310172249.GG30716@redhat.com>
References: <1456329561-4319-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160224185025.65711ed6@thinkpad>
 <20160225150744.GA19707@node.shutemov.name>
 <alpine.LSU.2.11.1602252233280.9793@eggly.anvils>
 <20160310161035.GD30716@redhat.com>
 <20160310163439.GS6356@twins.programming.kicks-ass.net>
 <20160310170406.GF30716@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160310170406.GF30716@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, Mar 10, 2016 at 06:04:06PM +0100, Andrea Arcangeli wrote:
> that costs memory in the mm unless we're lucky with the slab hw
> alignment), then I think synchronize_srcu may actually be preferable
> than a full synchronize_sched that affects the entire system with
> thousand of CPUs. A per-cpu inc wouldn't be a big deal and it would at
> least avoid to stall for the whole system if a stall eventually has to
> happen (unless every cpu is actually running gup_fast but that's ok in
> such case).

Thinking more about this, it'd be ok if the pgtable freeing srcu
context was global, no need of mess with the mm. A __percpu inside mm
wouldn't fly anyway. With srcu we'd wait only for those CPUs that are
effectively inside gup_fast, most of the time none or a few.

The main worry about synchronize_sched for x86 is that it doesn't
scale as CPU number increases and there can be thousands of
those. srcu has much a smaller issue as checking those per-cpu
variables is almost instantaneous even if there are thousand of CPUs
and while local_irq_disable may hurt in gup_fast, srcu_read_lock is
unlikely to be measurable. __gup_fast would also be still ok to be
called within irqs. If srcu causes problem for preempt-RT you could
use synchronize_sched there and the model would remain the same.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
