Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3173D8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 23:52:08 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id y24so986752lfh.4
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 20:52:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s74-v6sor249882lje.7.2019.01.16.20.52.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 20:52:05 -0800 (PST)
Received: from mail-lj1-f170.google.com (mail-lj1-f170.google.com. [209.85.208.170])
        by smtp.gmail.com with ESMTPSA id x11sm83212lfd.81.2019.01.16.20.52.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 20:52:03 -0800 (PST)
Received: by mail-lj1-f170.google.com with SMTP id g11-v6so7423803ljk.3
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 20:52:02 -0800 (PST)
MIME-Version: 1.0
References: <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net> <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
 <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm> <CAHk-=wgsnWvSsMfoEYzOq6fpahkHWxF3aSJBbVqywLa34OXnLg@mail.gmail.com>
 <nycvar.YFH.7.76.1901162120000.6626@cbobk.fhfr.pm> <20190116213708.GN6310@bombadil.infradead.org>
In-Reply-To: <20190116213708.GN6310@bombadil.infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 17 Jan 2019 16:51:44 +1200
Message-ID: <CAHk-=wjciBwJo5JHcvUO+JAC13TUME1PH=ftsaNt+0RC-3PCSw@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jiri Kosina <jikos@kernel.org>, Dominique Martinet <asmadeus@codewreck.org>, Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 17, 2019 at 9:37 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> Your patch 3/3 just removes the test.  Am I right in thinking that it
> doesn't need to be *moved* because the existing test after !PageUptodate
> catches it?

That's the _hope_.

That's the simplest patch I can come up with as a potential solution.
But it's possible that there's some nasty performance regression
because somebody really relies on not even triggering read-ahead, and
we might need to do some totally different thing.

So it may be that somebody has a case that really wants something
else, and we'd need to move the RWF_NOWAIT test elsewhere and do
something slightly more complicated. As with the mincore() change,
maybe reality doesn't like the simplest fix...

> Of course, there aren't any tests for RWF_NOWAIT in xfstests.  Are there
> any in LTP?

RWF_NOWAIT is actually _fairly_ new.  It was introduced "only" about
18 months ago and made it into 4.13.

Which makes me hopeful there aren't a lot of people who care deeply.

And starting readahead *may* actually be what a RWF_NOWAIT read user
generally wants, so for all we know it might even improve performance
and/or allow new uses. With the "start readahead but don't wait for
it" semantics, you can have a model where you try to handle all the
requests that can be handled out of cache first (using RWF_NOWAIT) and
then when you've run out of cached cases you clear the RWF_NOWAIT
flag, but now the IO has been started early (and could overlap with
the cached request handling), so then when you actually do a blocking
version, you get much better performance.

So there is an argument that removing that one RWF_NOWAIT case might
actually be a good thing in general, outside of  the "don't allow
probing the cache without changing the state of it" issue.

But that's handwavy and optimistic. Reality is often not as accomodating ;)

                   Linus
