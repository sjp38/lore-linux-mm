Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6D38E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 18:45:15 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id p4so2666336pgj.21
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 15:45:15 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id j34si4460302pgj.557.2019.01.15.15.45.12
        for <linux-mm@kvack.org>;
        Tue, 15 Jan 2019 15:45:13 -0800 (PST)
Date: Wed, 16 Jan 2019 10:45:10 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190115234510.GA6173@dastard>
References: <20190110070355.GJ27534@dastard>
 <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica>
 <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111020340.GM27534@dastard>
 <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
 <20190111040434.GN27534@dastard>
 <CAHk-=wh-kegfnPC_dmw0A72Sdk4B9tvce-cOR=jEfHDU1-4Eew@mail.gmail.com>
 <20190111073606.GP27534@dastard>
 <CAHk-=wj+xyz_GKjgKpU6SF3qeqouGmRoR8uFxzg_c1VpeGEJMw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wj+xyz_GKjgKpU6SF3qeqouGmRoR8uFxzg_c1VpeGEJMw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Fri, Jan 11, 2019 at 08:26:14AM -0800, Linus Torvalds wrote:
> On Thu, Jan 10, 2019 at 11:36 PM Dave Chinner <david@fromorbit.com> wrote:
> >
> > > It's only that single page that *matters*. That's the page that the
> > > probe reveals the status of - but it's also the page that the probe
> > > then *changes* the status of.
> >
> > It changes the state of it /after/ we've already got the information
> > we need from it. It's not up to date, it has to come from disk, we
> > return EAGAIN, which means it was not in the cache.
> 
> Oh, I see the confusion.
> 
> Yes, you get the information about whether something was in the cache
> or not, so the side channel does exist to some degree.
> 
> But it's actually hugely reduced for a rather important reason: the
> _primary_ reason for needing to know whether some page is in the cache
> or not is not actually to see if it was ever accessed - it's to see
> that the cache has been scrubbed (and to _guide_ the scrubbing), and
> *when* it was accessed.

Oh, you're assuming that you need to probe the page cache to
determine if brute force invalidation has progressed far enough
to invalidate the page in question.

I'm assuming that you can invalidate the page cache reliably by a
means that does not repeated require probing to detect invalidation
has occurred. I've mentioned one method in this discussion
already...

IOWs, just because the specific brute force attack documented in the
paper required repeated probing it doesn't mean all future
invalidation attacks will require repeated probing. Hence a robust
defense mechanism should not rely on the attacker requiring multiple
observations of the page cache to extract the information they are
seeking...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
