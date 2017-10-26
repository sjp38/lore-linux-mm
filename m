Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3164E6B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 06:18:40 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 82so2904270oid.11
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 03:18:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y28si1519841oty.487.2017.10.26.03.18.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Oct 2017 03:18:38 -0700 (PDT)
Date: Thu, 26 Oct 2017 12:18:33 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v5 07/22] mm: Protect VMA modifications using VMA
 sequence count
Message-ID: <20171026101833.GF563@redhat.com>
References: <1507729966-10660-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1507729966-10660-8-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1507729966-10660-8-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

Hello Laurent,

Message-ID: <7ca80231-fe02-a3a7-84bc-ce81690ea051@intel.com> shows
significant slowdown even for brk/malloc ops both single and
multi threaded.

The single threaded case I think is the most important because it has
zero chance of getting back any benefit later during page faults.

Could you check if:

1. it's possible change vm_write_begin to be a noop if mm->mm_count is
   <= 1? Hint: clone() will run single threaded so there's no way it can run
   in the middle of a being/end critical section (clone could set an
   MMF flag to possibly keep the sequence counter activated if a child
   thread exits and mm_count drops to 1 while the other cpu is in the
   middle of a critical section in the other thread).

2. Same thing with RCU freeing of vmas. Wouldn't it be nicer if RCU
   freeing happened only once a MMF flag is set? That will at least
   reduce the risk of temporary memory waste until the next RCU grace
   period. The read of the MMF will scale fine. Of course to allow
   point 1 and 2 then the page fault should also take the mmap_sem
   until the MMF flag is set.

Could you also investigate a much bigger change: I wonder if it's
possible to drop the sequence number entirely from the vma and stop
using sequence numbers entirely (which is likely the source of the
single threaded regression in point 1 that may explain the report in
the above message-id), and just call the vma rbtree lookup once again
and check that everything is still the same in the vma and the PT lock
obtained is still a match to finish the anon page fault and fill the
pte?

Then of course we also need to add a method to the read-write
semaphore so it tells us if there's already one user holding the read
mmap_sem and we're the second one.  If we're the second one (or more
than second) only then we should skip taking the down_read mmap_sem.
Even a multithreaded app won't ever skip taking the mmap_sem until
there's sign of runtime contention, and it won't have to run the way
more expensive sequence number-less revalidation during page faults,
unless we get an immediate scalability payoff because we already know
the mmap_sem is already contended and there are multiple nested
threads in the page fault handler of the same mm.

Perhaps we'd need something more advanced than a
down_read_trylock_if_not_hold() (which has to guaranteed not to write
to any cacheline) and we'll have to count the per-thread exponential
backoff of mmap_sem frequency, but starting with
down_read_trylock_if_not_hold() would be good I think.

This is not how the current patch works, the current patch uses a
sequence number because it pretends to go lockless always and in turn
has to slow down all vma updates fast paths or the revalidation
slowsdown performance for page fault too much (as it always
revalidates).

I think it would be much better to go speculative only when there's
"detected" runtime contention on the mmap_sem with
down_read_trylock_if_not_hold() and that will make the revalidation
cost not an issue to worry about because normally we won't have to
revalidate the vma at all during page fault. In turn by making the
revalidation more expensive by starting a vma rbtree lookup from
scratch, we can drop the sequence number entirely and that should
simplify the patch tremendously because all vm_write_begin/end would
disappear from the patch and in turn the mmap/brk slowdown measured by
the message-id above, should disappear as well.
   
Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
