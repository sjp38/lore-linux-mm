Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6EDA36B0254
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 06:06:56 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id g62so67987987wme.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 03:06:56 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id c1si3439900wmh.112.2016.02.26.03.06.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 03:06:55 -0800 (PST)
Date: Fri, 26 Feb 2016 12:06:50 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] thp, mm: remove comments on serializion of THP split vs.
 gup_fast
Message-ID: <20160226110650.GY6356@twins.programming.kicks-ass.net>
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
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, Feb 25, 2016 at 10:50:14PM -0800, Hugh Dickins wrote:

> For example, see the fallback tlb_remove_table_one() in mm/memory.c:
> that one uses smp_call_function() sending IPI to all CPUs concerned,
> without waiting an RCU grace period at all.

The better comment is with mmu_table_batch.

Its been too long for me to fully remember, nor have I really paid much
attention to this code in the past few years, so any memory I might have
had might be totally wrong.

But relying on rcu_read_lock_sched() and friends would mean replacing
that smp_call_function() with synchronize_sched().

A real quick look at the current code seems to suggest that _might_ just
work, but note that that will be slower, RT and HPC people will like you
for it though.

So it depends on how hard we hit that special, totally out of memory,
case, and if we care about some performance if we do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
