Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E2F1C8E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 00:26:56 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id p9so6951651pfj.3
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 21:26:56 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id y73si32638733pgd.478.2019.01.09.21.26.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 21:26:55 -0800 (PST)
Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A2F7F2173B
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 05:26:54 +0000 (UTC)
Received: by mail-wr1-f47.google.com with SMTP id z5so9847954wrt.11
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 21:26:54 -0800 (PST)
MIME-Version: 1.0
References: <20190106001138.GW6310@bombadil.infradead.org> <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
 <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
In-Reply-To: <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 9 Jan 2019 21:26:41 -0800
Message-ID: <CALCETrWxwaBUYMg=aLySJByMgXzuzV4gHS0n6O6Oet2Jm6SAbw@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Jan 9, 2019 at 5:18 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Wed, Jan 9, 2019 at 4:44 PM Dave Chinner <david@fromorbit.com> wrote:
> >
> > I wouldn't look at ext4 as an example of a reliable, problem free
> > direct IO implementation because, historically speaking, it's been a
> > series of nasty hacks (*cough* mount -o dioread_nolock *cough*) and
> > been far worse than XFS from data integrity, performance and
> > reliability perspectives.
>
> That's some big words from somebody who just admitted to much worse hacks.
>
> Seriously. XFS is buggy in this regard, ext4 apparently isn't.
>
> Thinking that it's better to just invalidate the cache  for direct IO
> reads is all kinds of odd.
>

This whole discussion seems to have gone a little bit off the rails...

Linus, I think I agree with Dave's overall sentiment, though, and I
think you should consider reverting your patch.  Here's why.  The
basic idea behind the attack is that the authors found efficient ways
to do two things: evict a page from page cache and detect, *without
filling the cache*, whether a page is cached.  The combination lets an
attacker efficiently tell when another process reads a page.  We need
to keep in mind that this attack is a sophisticated attack, and anyone
using it won't have any problem using a nontrivial way to detect
whether a page is in page cache.

So, unless we're going to try for real to make it hard to tell whether
a page is cached without causing that page to become cached, it's not
worth playing whack-a-mole.  And, right now, mincore is whacking a
mole.  RWF_NOWAIT appears to do essentially the same thing at very
little cost.  I haven't really dug in, but I assume that various
prefaulting tricks combined with various pagetable probing tricks can
do similar things, but that's at least a *lot* more complicated.

So unless we're going to lock down RWF_NOWAIT as well, I see no reason
to lock down mincore().  Direct IO is a red herring -- O_DIRECT is
destructive enough that it seems likely to make the attacks a lot less
efficient.


--- begin digression ---

Since direct IO has been brought up, I have a question.  I've wondered
for years why direct IO works the way it does.  If I were implementing
it from scratch, my first inclination would be to use the page cache
instead of fighting it.  To do a single-page direct read, I would look
that page up in the page cache (i.e. i_pages these days).  If the page
is there, I would do a normal buffered read.  If the page is not
there, I would insert a record into i_pages indicating that direct IO
is in progress and then I would do the IO into the destination page.
If any other read, direct or otherwise, sees a record saying "under
direct IO", it would wait.

To do a single-page direct write, I would look it up in i_pages.  If
it's there, I would do a buffered write followed by a sync (because
applications expect a sync).  If it's not there, I would again add a
record saying "under direct IO" and do the IO.

The idea is that this works as much like buffered IO as possible,
except that the pages backing the IO aren't normal sharable page cache
pages.

The multi-page case would be just an optimization on top of the
single-page case.  The idea would be to somehow mark i_pages with
entire extents under direct IO.  It's a radix tree -- this can, at
least in theory, be done efficiently.  As long as all direct IO
operations run in increasing order of offset, there shouldn't be lock
ordering problems.

Other than history and possibly performance, is there any reason that
direct IO doesn't work this way?

P.S. What, if anything, prevents direct writes from causing trouble
when the underlying FS or backing store needs stable pages?
Similarly, what, if anything, prevents direct reads from temporarily
exposing unintended data to user code if the fs or underlying device
transforms the data during the read process (e.g. by decrypting
something)?

--- end digression ---
