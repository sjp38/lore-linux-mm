Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 75E9E6B0254
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 06:41:26 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id b205so68642771wmb.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 03:41:26 -0800 (PST)
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com. [195.75.94.106])
        by mx.google.com with ESMTPS id fy9si15482618wjb.72.2016.02.26.03.41.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 26 Feb 2016 03:41:25 -0800 (PST)
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Fri, 26 Feb 2016 11:41:24 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 599C917D8062
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 11:41:43 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1QBfKrP57802958
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 11:41:20 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1QBfJX6016582
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 06:41:20 -0500
Date: Fri, 26 Feb 2016 12:41:18 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] thp, mm: remove comments on serializion of THP split
 vs. gup_fast
Message-ID: <20160226124118.41ad93a2@mschwide>
In-Reply-To: <20160226110650.GY6356@twins.programming.kicks-ass.net>
References: <1456329561-4319-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20160224185025.65711ed6@thinkpad>
	<20160225150744.GA19707@node.shutemov.name>
	<alpine.LSU.2.11.1602252233280.9793@eggly.anvils>
	<20160226110650.GY6356@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Fri, 26 Feb 2016 12:06:50 +0100
Peter Zijlstra <peterz@infradead.org> wrote:

> On Thu, Feb 25, 2016 at 10:50:14PM -0800, Hugh Dickins wrote:
> 
> > For example, see the fallback tlb_remove_table_one() in mm/memory.c:
> > that one uses smp_call_function() sending IPI to all CPUs concerned,
> > without waiting an RCU grace period at all.
> 
> The better comment is with mmu_table_batch.
> 
> Its been too long for me to fully remember, nor have I really paid much
> attention to this code in the past few years, so any memory I might have
> had might be totally wrong.
> 
> But relying on rcu_read_lock_sched() and friends would mean replacing
> that smp_call_function() with synchronize_sched().

That makes sense, just tried that together with a big fat printk to see if
we hit that out-of-memory condition in the page table freeing code.
The system is swapping like mad but no message so far.
 
> A real quick look at the current code seems to suggest that _might_ just
> work, but note that that will be slower, RT and HPC people will like you
> for it though.
> 
> So it depends on how hard we hit that special, totally out of memory,
> case, and if we care about some performance if we do.

If the system is out of memory bad enough for the page allocation to fail
an additional synchronize_sched() call probably won't hurt too much. Most
of the time we'll be waiting for I/O anyway.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
