Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4C61F6B02D5
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 11:49:16 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id y143so34410092oie.3
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 08:49:16 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id b205si5517636oia.59.2016.11.03.08.49.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 08:49:15 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id 62so7317749oif.1
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 08:49:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161103144650.70c46063@roar.ozlabs.ibm.com>
References: <20161102070346.12489-1-npiggin@gmail.com> <20161102070346.12489-3-npiggin@gmail.com>
 <CA+55aFxhxfevU1uKwHmPheoU7co4zxxcri+AiTpKz=1_Nd0_ig@mail.gmail.com> <20161103144650.70c46063@roar.ozlabs.ibm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 3 Nov 2016 08:49:14 -0700
Message-ID: <CA+55aFyzf8r2q-HLfADcz74H-My_GY-z15yLrwH-KUqd486Q0A@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add PageWaiters bit to indicate waitqueue should
 be checked
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Wed, Nov 2, 2016 at 8:46 PM, Nicholas Piggin <npiggin@gmail.com> wrote:
>
> If you don't have that, then a long-waiting waiter for some
> unrelated page can prevent other pages from getting back to
> the fastpath.
>
> Contention bit is already explicitly not precise with this patch
> (false positive possible), but in general the next wakeup will
> clean it up. Without page_match, that's not always possible.

Do we care?

The point is, it's rare, and if there are no numbers to say that it's
an issue, we shouldn't create the complication. Numbers talk,
handwaving "this might be an issue" walks.

That said, at least it isn't a big complexity that will hurt, and it's
very localized.

>> Also, it would be lovely to get numbers against the plain 4.8
>> situation with the per-zone waitqueues. Maybe that used to help your
>> workload, so the 2.2% improvement might be partly due to me breaking
>> performance on your machine.
>
> Oh yeah that'll hurt a bit. The hash will get spread over non-local
> nodes now. I think it was only a 2 socket system, but remote memory
> still takes a latency hit. Hmm, I think keeping the zone waitqueue
> just for pages would be reasonable, because they're a special case?

HELL NO!

Christ. That zone crap may have helped some very few NUMA machines,
but it *hurt* normal machines.

So no way in hell are we re-introducing that ugly, complex, fragile
crap that actually slows down the normal case on real loads (not
microbenchmarks). It was a mistake from the very beginning.

No, the reason I'd like to hear about numbers is that while I *know*
that removing the crazy zone code helped on normal machines (since I
could test that case myself), I still am interested in whether the
zone removal hurt on some machines (probably not two-node ones,
though: Mel already tested that on x86), I'd like to know what the
situation is with the contention bit.

I'm pretty sure that with the contention bit, the zone crud is
entirely immaterial (since we no longer actually hit the waitqueue
outside of IO), but my "I'm pretty sure" comes back to the "handwaving
walks" issue.

So numbers would be really good.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
