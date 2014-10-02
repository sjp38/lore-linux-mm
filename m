Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8F06B0038
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 08:31:51 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id i50so1781615qgf.35
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 05:31:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 3si6971061qak.110.2014.10.02.05.31.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Oct 2014 05:31:50 -0700 (PDT)
Date: Thu, 2 Oct 2014 14:31:17 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: RFC: get_user_pages_locked|unlocked to leverage VM_FAULT_RETRY
Message-ID: <20141002123117.GB2342@redhat.com>
References: <20140926172535.GC4590@redhat.com>
 <20141001153611.GC2843@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141001153611.GC2843@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andres Lagar-Cavilla <andreslc@google.com>, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

On Wed, Oct 01, 2014 at 05:36:11PM +0200, Peter Zijlstra wrote:
> For all these and the other _fast() users, is there an actual limit to
> the nr_pages passed in? Because we used to have the 64 pages limit from
> DIO, but without that we get rather long IRQ-off latencies.

Ok, I would tend to think this is an issue to solve in gup_fast
implementation, I wouldn't blame or modify the callers for it.

I don't think there's anything that prevents gup_fast to enable irqs
after certain number of pages have been taken, nop; and disable the
irqs again.

If the TLB flush runs in parallel with gup_fast the result is
undefined anyway so there's no point to wait all pages to be taken
before letting the TLB flush go through. All it matters is that
gup_fast don't take pages that have been invalidated after the
tlb_flush returns on the other side. So I don't see issues in
releasing irqs and be latency friendly inside gup_fast fast path loop.

In fact gup_fast should also cond_resched() after releasing irqs, it's
not just an irq latency matter.

I could fix x86-64 for it in the same patchset unless somebody sees a
problem in releasing irqs inside the gup_fast fast path loop.

__gup_fast is an entirely different beast and that needs the callers to
be fixed but I didn't alter its callers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
