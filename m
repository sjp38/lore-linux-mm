Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id EA8686B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 09:50:31 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id c4so1287430eek.14
        for <linux-mm@kvack.org>; Fri, 26 Oct 2012 06:50:30 -0700 (PDT)
Date: Fri, 26 Oct 2012 15:50:24 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 26/31] sched, numa, mm: Add fault driven placement and
 migration policy
Message-ID: <20121026135024.GA11640@gmail.com>
References: <20121025121617.617683848@chello.nl>
 <20121025124834.467791319@chello.nl>
 <CA+55aFwJdn8Kz9UByuRfGNtf9Hkv-=8xB+WRd47uHZU1YMagZw@mail.gmail.com>
 <20121026071532.GC8141@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121026071532.GC8141@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Ingo Molnar <mingo@kernel.org> wrote:

> [
>   task_numa_work() performance side note:
> 
>   We are also *very* close to be able to use down_read() instead
>   of down_write() in the sampling-unmap code in 
>   task_numa_work(), as it should be safe in theory to call 
>   change_protection(PROT_NONE) in parallel - but there's one 
>   regression that disagrees with this theory so we use 
>   down_write() at the moment.
> 
>   Maybe you could help us there: can you see a reason why the
>   change_prot_none()->change_protection() call in
>   task_numa_work() can not occur in parallel to a page fault in
>   another thread on another CPU? It should be safe - yet if we 
>   change it I can see occasional corruption of user-space state: 
>   segfaults and register corruption.
> ]

Oh, just found the reason:

the ptep_modify_prot_start()/modify()/commit() sequence is 
SMP-unsafe - it has to be done under the mmap_sem write-locked.

It is safe against *hardware* updates to the PTE, but not safe 
against itself.

This is apparently a hidden cost of paravirt, it is forcing that 
weird sequence and thus the down_write() ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
