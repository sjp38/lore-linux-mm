Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C052A28025A
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 22:41:02 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id v84so75853063oie.0
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 19:41:02 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id g9si8803789ioi.151.2016.11.03.19.41.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 19:41:01 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id i88so6454539pfk.2
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 19:41:00 -0700 (PDT)
Date: Fri, 4 Nov 2016 13:40:49 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters bit to indicate waitqueue
 should be checked
Message-ID: <20161104134049.6c7d394b@roar.ozlabs.ibm.com>
In-Reply-To: <CA+55aFyzf8r2q-HLfADcz74H-My_GY-z15yLrwH-KUqd486Q0A@mail.gmail.com>
References: <20161102070346.12489-1-npiggin@gmail.com>
	<20161102070346.12489-3-npiggin@gmail.com>
	<CA+55aFxhxfevU1uKwHmPheoU7co4zxxcri+AiTpKz=1_Nd0_ig@mail.gmail.com>
	<20161103144650.70c46063@roar.ozlabs.ibm.com>
	<CA+55aFyzf8r2q-HLfADcz74H-My_GY-z15yLrwH-KUqd486Q0A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Thu, 3 Nov 2016 08:49:14 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Nov 2, 2016 at 8:46 PM, Nicholas Piggin <npiggin@gmail.com> wrote:
> >
> > If you don't have that, then a long-waiting waiter for some
> > unrelated page can prevent other pages from getting back to
> > the fastpath.
> >
> > Contention bit is already explicitly not precise with this patch
> > (false positive possible), but in general the next wakeup will
> > clean it up. Without page_match, that's not always possible.  
> 
> Do we care?
> 
> The point is, it's rare, and if there are no numbers to say that it's
> an issue, we shouldn't create the complication. Numbers talk,
> handwaving "this might be an issue" walks.

Well you could have hundreds of waiters on pages with highly threaded
IO (say, a file server), which will cause collisions in the hash table.
I can just try to force that to happen and show up that 2.2% again.

Actaully it would be more than 2.2% with my patch as is, because it no
longer does an unlocked waitqueue_active() check if the waiters bit was
set (because with my approach the lock will always be required if only
to clear the bit after checking the waitqueue). If we avoid clearing
dangling bity there, we'll then have to reintroduce that test.

> That said, at least it isn't a big complexity that will hurt, and it's
> very localized.

I thought so :)

> 
> >> Also, it would be lovely to get numbers against the plain 4.8
> >> situation with the per-zone waitqueues. Maybe that used to help your
> >> workload, so the 2.2% improvement might be partly due to me breaking
> >> performance on your machine.  
> >
> > Oh yeah that'll hurt a bit. The hash will get spread over non-local
> > nodes now. I think it was only a 2 socket system, but remote memory
> > still takes a latency hit. Hmm, I think keeping the zone waitqueue
> > just for pages would be reasonable, because they're a special case?  
> 
> HELL NO!
> 
> Christ. That zone crap may have helped some very few NUMA machines,
> but it *hurt* normal machines.

Oh I missed why they hurt small systems -- where did you see that
slowdown? I agree that's a serious concern. I'll go back and read the
thread again.

> So no way in hell are we re-introducing that ugly, complex, fragile
> crap that actually slows down the normal case on real loads (not
> microbenchmarks). It was a mistake from the very beginning.

For the generic bit wait stuff, sure. For page waiters you always
have the page, there's no translation so I don't see the fragility.

> No, the reason I'd like to hear about numbers is that while I *know*
> that removing the crazy zone code helped on normal machines (since I
> could test that case myself), I still am interested in whether the
> zone removal hurt on some machines (probably not two-node ones,
> though: Mel already tested that on x86), I'd like to know what the
> situation is with the contention bit.
> 
> I'm pretty sure that with the contention bit, the zone crud is
> entirely immaterial (since we no longer actually hit the waitqueue
> outside of IO), but my "I'm pretty sure" comes back to the "handwaving
> walks" issue.

I do worry about pushing large amounts of IO, not even on huge NUMA
machines, but 2-4 socket. Then again, it *tends* to be that you don't
wait on every single page, but rather batches of them at a time.

> 
> So numbers would be really good.

I'll try to come up with some.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
