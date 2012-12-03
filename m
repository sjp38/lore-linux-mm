Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id BBFBD6B0068
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 08:41:16 -0500 (EST)
Date: Mon, 3 Dec 2012 13:41:10 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/10] Latest numa/core release, v18
Message-ID: <20121203134110.GL8218@suse.de>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
 <CA+55aFwjxm7OYuucHeE2WFr4p+jwr63t=kSdHndta_QkyFbyBQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFwjxm7OYuucHeE2WFr4p+jwr63t=kSdHndta_QkyFbyBQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Fri, Nov 30, 2012 at 12:37:49PM -0800, Linus Torvalds wrote:
> On Fri, Nov 30, 2012 at 11:58 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> > When pushed hard enough via threaded workloads (for example via the
> > numa02 test) then the upstream page migration code in mm/migration.c
> > becomes unscalable, resulting in lot of scheduling on the anon vma
> > mutex and a subsequent drop in performance.
> 
> Ugh.
> 
> I wonder if migration really needs that thing to be a mutex? I may be
> wrong, but the anon_vma lock only protects the actual rmap chains, and
> migration only ever changes the pte *contents*, not the actual chains
> of pte's themselves, right?
> 

Pretty much. As far as migration is concerned all that is critical is
that it find all the old migration ptes and restore them. If any of them
are missed then it will likely BUG later when the page is faulted. If a
process happened to exit while the anon_vma mutex was not held and the
migration pte and anon_vma disappeared during migration, it would not
matter as such. If the protection was a rwsem then migration might cause
delays in a parallel unmap or exit until the migration completed but I
doubt it would ever be noticed.

> So if this is a migration-specific scalability issue, then it might be
> possible to solve by making the mutex be a rwsem instead, and have
> migration only take it for reading.
> 
> Of course, I'm quite possibly wrong, and the code depends on full
> mutual exclusion.
> 
> Just a thought, in case it makes somebody go "Hmm.."
> 

Offhand, I cannot think of a reason why a rwsem would not work. This
thing originally became a mutex because the RT people (Peter in
particular) cared about being able to preempt faster. It'd be nice if
they confirmed that rwsem is not be a problem for them.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
