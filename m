Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 971738E0038
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 06:47:22 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id t22-v6so2690188lji.14
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 03:47:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 65-v6sor36279409ljs.15.2019.01.10.03.47.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 03:47:20 -0800 (PST)
Received: from mail-lj1-f174.google.com (mail-lj1-f174.google.com. [209.85.208.174])
        by smtp.gmail.com with ESMTPSA id g17sm15261877lfj.36.2019.01.10.03.47.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 03:47:17 -0800 (PST)
Received: by mail-lj1-f174.google.com with SMTP id q2-v6so9396575lji.10
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 03:47:17 -0800 (PST)
MIME-Version: 1.0
References: <CAHk-=wg1A44Roa8C4dmfdXLRLmNysEW36=3R7f+tzZzbcJ2d2g@mail.gmail.com>
 <CAHk-=wiqbKEC5jUXr3ax+oUuiRrp=QMv_ZnUfO-SPv=UNJ-OTw@mail.gmail.com>
 <20190108044336.GB27534@dastard> <CAHk-=wjvzEFQcTGJFh9cyV_MPQftNrjOLon8YMMxaX0G1TLqkg@mail.gmail.com>
 <20190109022430.GE27534@dastard> <nycvar.YFH.7.76.1901090326460.16954@cbobk.fhfr.pm>
 <20190109043906.GF27534@dastard> <CAHk-=wic28fSkwmPbBHZcJ3BGbiftprNy861M53k+=OAB9n0=w@mail.gmail.com>
 <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard>
In-Reply-To: <20190110070355.GJ27534@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 10 Jan 2019 03:47:00 -0800
Message-ID: <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed, Jan 9, 2019 at 11:04 PM Dave Chinner <david@fromorbit.com> wrote:
>
> Sorry, what hacks did I just admit to making? This O_DIRECT
> behaviour long predates me - I'm just the messenger and you are
> shooting from the hip.

Sure, sorry. I find this whole thing annoying.

> Linus, the point I was making is that there are many, many ways to
> control page cache invalidation and measure page cache residency,
> and that trying to address them one-by-one is just a game of
> whack-a-mole.

.. and I agree. But let's a step back.Because there are different issues.

First off, the whole page cache attack is not necessarily something
many people will care about. As has been pointed out, it's often a
matter of convenience and (relative) portability.

And no, we're *never* going to stop all side channel leaks. Some parts
of caching (notably the timing effects of it) are pretty fundamental.

So at no point is this going to be some kind of absolute line in the
sand _anyway_. There is no black-and-white "you're protected", there's
only levels of convenience.

A remote attacker is hopefully going to be limited by the interfaces
to just timing attacks, although who knows what something like JS
might expose. Presumably neither mincore() nor arbitrary O_DIRECT or
pread2() flags.

Anyway, the reason I was trying to plug mincore() is largely that that
code didn't make much sense to begin with, and simply this:

 mm/mincore.c | 94 +++++++++---------------------------------------------------
 1 file changed, 13 insertions(+), 81 deletions(-)

if we can make people happier by removing lines of code and making the
semantics more clear anyway, it's worth trying.

No?

Is that everything? No. As mentioned, you'll never get to that "ok, we
plugged everything" point anyway. But removing a fairly easy way to
probe the cache that has no real upsides should be fairly
non-controversial.

But I do have to say that in many ways the page cache is *not* a great
attack vector because there's often lots of it, and it's fairly hard
to control. Once something is in the page cache for whatever reason,
it tends to be pretty sticky, and flushing it tends to be fairly hard
to predict.

And a cheap and residency (whether a simple probe like mincore of or a
NOWAIT flag) check is actually important just to try to control the
flushing part. Brute-forcing the flushing is generally very expensive,
but if you can't even see if you flushed it, it's way more so.

If there's a way to control the cache residency directly, that's
actually a much bigger hole than any residency check ever were.

Because once you can flush caches by reading, at that point you can
just flush a particular page and look at the IO stats for the root
partition or something. No residency check even needed.

So I do think that yes, as long as you can do a directed cache flush,
mincore is *entirely* immaterial.

Still, giving mincore clearer semantics and simpler code? Win-win.

(Except, of course, if somebody actually notices outside of tests.
Which may well happen and just force us to revert that commit. But
that's a separate issue entirely).

But I do think that we should strive to *never* invalidate caches on
read accesses. I don't actually see where you are doing that,
honestly: at least dio_complete() only does it for writes.

So I'm actually hoping that you are mis-remembering this and it turns
out that O_DIRECT reads don't invalidate caches.

                Linus
