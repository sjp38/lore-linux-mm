Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id D4D1E6B0044
	for <linux-mm@kvack.org>; Sat,  1 Dec 2012 13:30:55 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so1105478eek.14
        for <linux-mm@kvack.org>; Sat, 01 Dec 2012 10:30:54 -0800 (PST)
Date: Sat, 1 Dec 2012 19:30:50 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC PATCH] mm/migration: Don't lock anon vmas in
 rmap_walk_anon()
Message-ID: <20121201183050.GA32102@gmail.com>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
 <CA+55aFwjxm7OYuucHeE2WFr4p+jwr63t=kSdHndta_QkyFbyBQ@mail.gmail.com>
 <20121201094927.GA12366@gmail.com>
 <CA+55aFymM2MjEhRUmd-T_3ZJRTa9t5NzBuWgcbcdZmbUJv6dcQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFymM2MjEhRUmd-T_3ZJRTa9t5NzBuWgcbcdZmbUJv6dcQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Sat, Dec 1, 2012 at 1:49 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> > I *think* you are right that for this type of migration that 
> > we are using here we indeed don't need to take an exclusive 
> > vma lock - in fact I think we don't need to take it at all:
> 
> I'm pretty sure we do need at least a read-side reference.

Ok.

> Even if no other MM can contain that particular pte, the vma 
> lock protects the chain that is created by fork and exit and 
> vma splitting etc.
> 
> So it's enough that another thread does a fork() at the same 
> time. Or a partial unmap of the vma (that splits it in two), 
> for the rmap chain to be modified.
> 
> Besides, there's absolutely nothing that protects that vma to 
> be part of the same vma chain in entirely unrelated processes. 
> The vma chain can get quite long over multiple forks (it's 
> even a performance problem under some extreme loads).
> 
> And we do walk the rmap chain - so we need the lock.
> 
> But we walk it read-only afaik, which is why I think the 
> semaphore could be an rwsem.
> 
> Now, there *are* likely cases where we could avoid anon_vma 
> locking entirely, but they are very specialized. They'd be 
> along the lines of
> 
>  - we hold the page table lock
>  - we see that vma->anon_vma == vma->anon_vma->root
>  - we see that vma->anon_vma->refcount == 1
> 
> or similar, because then we can guarantee that the anon-vma 
> chain has a length of one without even locking, and holding 
> the page table lock means that any concurrent fork or 
> mmap/munmap from another thread will block on this particular 
> pte.

Hm. These conditions may be true for some pretty common cases, 
but it's difficult to discover that information from the 
migration code due to the way we discover all anon vmas and walk 
the anon vma list: we first lock the anon vma then do we get to 
iterate over the individual vmas and do the pte changes.

So it's the wrong way around.

I think your rwsem suggestion is a lot more generic and more 
robust as well.

> So I suspect that in the above kind of special case (which 
> might be a somewhat common case for normal page faults, for 
> example) we could make a "we have exclusive pte access to this 
> page" argument. But quite frankly, I completely made the above 
> rules up in my head, they may be bogus too.
> 
> For the general migration case, it's definitely not possible 
> to just drop the anon_vma lock.

Ok, I see - I'll redo this part then and try out how an rwsem 
fares. I suspect it would give a small speedup to a fair number 
of workloads, so it's worthwile to spend some time on it.

Thanks for the suggestions!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
