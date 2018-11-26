Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 65E7D6B3FD9
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 22:29:18 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id u41so6223254otc.10
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 19:29:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s126sor6529596oia.106.2018.11.25.19.29.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Nov 2018 19:29:16 -0800 (PST)
Date: Sun, 25 Nov 2018 19:29:07 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: put_and_wait_on_page_locked() while page is
 migrated
In-Reply-To: <CAHk-=wjeqKYevxGnfCM4UkxX8k8xfArzM6gKkG3BZg1jBYThVQ@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1811251900300.1278@eggly.anvils>
References: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils> <CAHk-=wjeqKYevxGnfCM4UkxX8k8xfArzM6gKkG3BZg1jBYThVQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, bhe@redhat.com, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, david@redhat.com, mgorman@techsingularity.net, dh.herrmann@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, kan.liang@intel.com, Andi Kleen <ak@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, pifang@redhat.com, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sun, 25 Nov 2018, Linus Torvalds wrote:
> On Sat, Nov 24, 2018 at 7:21 PM Hugh Dickins <hughd@google.com> wrote:
> >
> > Linus, I'm addressing this patch to you because I see from Tim Chen's
> > thread that it would interest you, and you were disappointed not to
> > root cause the issue back then.  I'm not pushing for you to fast-track
> > this into 4.20-rc, but I expect Andrew will pick it up for mmotm, and
> > thence linux-next.  Or you may spot a terrible defect, but I hope not.
> 
> The only terrible defect I spot is that I wish the change to the
> 'lock' argument in wait_on_page_bit_common() came with a comment
> explaining the new semantics.o

Thanks a lot for looking through it.

> 
> The old semantics were somewhat obvious (even if not documented): if
> 'lock' was set,  we'd make the wait exclusive, and we'd lock the page
> before returning. That kind of matches the intuitive meaning for the
> function prototype, and it's pretty obvious in the callers too.
> 
> The new semantics don't have the same kind of really intuitive
> meaning, I feel. That "-1" doesn't mean "unlock", it means "drop page
> reference", so there is no longer a fairly intuitive and direct
> mapping between the argument name and type and the behavior of the
> function.
> 
> So I don't hate the concept of the patch at all, but I do ask to:
> 
>  - better documentation.
> 
>    This might not be "documentation" at all, maybe that "lock"
> variable should just be renamed (because it's not about just locking
> any more), and would be better off as a tristate enum called
> "behavior" that has "LOCK, DROP, WAIT" values?

Agreed, an enum should be best. I'll try it out now, and see what
naming fits - I'm not all that keen on "LOCK", since (like many of the
existing comments) it forgets that PG_locked is only one of the flags
that comes here.  Admittedly, the only other is PG_writeback, and
nobody wants exclusive behavior on that one, but...

> 
>  - while it sounds likely that this is indeed the same issue that
> plagues us with the insanely long wait-queues, it would be *really*
> nice to have that actually confirmed.

I echo your words: it would be *really* nice.  We do already know
that this patch is good for many problem loads, but it would be very
satisfying if it could also wrap that discussion from last year.

> 
>    Does somebody still have access to the customer load that triggered
> the horrible scaling issues before?

Kan? Tim?

> 
> In particular, on that second issue: the "fixes" that went in for the
> wait-queues didn't really fix any real scalability problem, it really
> just fixed the excessive irq latency issues due to the long traversal
> holding a lock.
> 
> If this really fixes the fundamental issue, that should show up as an
> actual performance difference, I'd expect..

I guess so, though it might be more convincing to add a hack to suppress
the bookmarking (e.g. #define WAITQUEUE_WALK_BREAK_CNT (INT_MAX - 1))
when trying out the put_and_wait patch - if they can persuade the
customer to go back in time on this, which is asking a lot.

Not that I have any ambitions to do away with the bookmarking myself;
though I do have several reservations about the way it works out (that
I'd rather go into some other time).

> 
> End result: I like and approve of the patch, but I'd like it a lot
> more if the code behavior was clarified a bit, and I'd really like to
> close the loop on that old nasty page wait queue issue...

Thanks!
Hugh
