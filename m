Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id C64E46B0062
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 06:40:32 -0500 (EST)
Date: Wed, 21 Nov 2012 11:40:26 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH, v2] mm, numa: Turn 4K pte NUMA faults into effective
 hugepage ones
Message-ID: <20121121114025.GY8218@suse.de>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
 <20121119191339.GA11701@gmail.com>
 <20121119211804.GM8218@suse.de>
 <20121119223604.GA13470@gmail.com>
 <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
 <20121120071704.GA14199@gmail.com>
 <20121120152933.GA17996@gmail.com>
 <20121120160918.GA18167@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121120160918.GA18167@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Tue, Nov 20, 2012 at 05:09:18PM +0100, Ingo Molnar wrote:
> 
> Ok, the patch withstood a bit more testing as well. Below is a 
> v2 version of it, with a couple of cleanups (no functional 
> changes).
> 
> Thanks,
> 
> 	Ingo
> 
> ----------------->
> Subject: mm, numa: Turn 4K pte NUMA faults into effective hugepage ones
> From: Ingo Molnar <mingo@kernel.org>
> Date: Tue Nov 20 15:48:26 CET 2012
> 
> Reduce the 4K page fault count by looking around and processing
> nearby pages if possible.
> 
> To keep the logic and cache overhead simple and straightforward
> we do a couple of simplifications:
> 
>  - we only scan in the HPAGE_SIZE range of the faulting address
>  - we only go as far as the vma allows us
> 
> Also simplify the do_numa_page() flow while at it and fix the
> previous double faulting we incurred due to not properly fixing
> up freshly migrated ptes.
> 
> Suggested-by: Mel Gorman <mgorman@suse.de>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> ---
>  mm/memory.c |   99 ++++++++++++++++++++++++++++++++++++++----------------------
>  1 file changed, 64 insertions(+), 35 deletions(-)
> 

This is functionally similar to what balancenuma does but there is one key
difference worth noting. I only mark the PMD pmd_numa if all the pages
pointed to by the updated[*] PTEs underneath are on the same node. The
intention is that if the workload is converged on a PMD boundary then a
migration of all the pages underneath will be remote->local copies. If the
workload is not converged on a PMD boundary and you handle all the faults
then you are potentially incurring remote->remote copies.

It also means that if the workload is not converged on the PMD boundary
then a PTE fault is just one page. With yours, it will be the full PMD
every time, right?

[*] Note I said only the updated ptes are checked. I do not check every
    PTE underneath. I could but felt the benefit would be marginal.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
