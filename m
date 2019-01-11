Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 42C068E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 11:26:36 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id t22-v6so3881398lji.14
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 08:26:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m10-v6sor44640343lje.8.2019.01.11.08.26.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 08:26:34 -0800 (PST)
Received: from mail-lj1-f170.google.com (mail-lj1-f170.google.com. [209.85.208.170])
        by smtp.gmail.com with ESMTPSA id m4-v6sm15560999ljb.58.2019.01.11.08.26.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 08:26:31 -0800 (PST)
Received: by mail-lj1-f170.google.com with SMTP id v1-v6so13467276ljd.0
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 08:26:31 -0800 (PST)
MIME-Version: 1.0
References: <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <20190111020340.GM27534@dastard> <CAHk-=wgLgAzs42=W0tPrTVpu7H7fQ=BP5gXKnoNxMxh9=9uXag@mail.gmail.com>
 <20190111040434.GN27534@dastard> <CAHk-=wh-kegfnPC_dmw0A72Sdk4B9tvce-cOR=jEfHDU1-4Eew@mail.gmail.com>
 <20190111073606.GP27534@dastard>
In-Reply-To: <20190111073606.GP27534@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 11 Jan 2019 08:26:14 -0800
Message-ID: <CAHk-=wj+xyz_GKjgKpU6SF3qeqouGmRoR8uFxzg_c1VpeGEJMw@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Jan 10, 2019 at 11:36 PM Dave Chinner <david@fromorbit.com> wrote:
>
> > It's only that single page that *matters*. That's the page that the
> > probe reveals the status of - but it's also the page that the probe
> > then *changes* the status of.
>
> It changes the state of it /after/ we've already got the information
> we need from it. It's not up to date, it has to come from disk, we
> return EAGAIN, which means it was not in the cache.

Oh, I see the confusion.

Yes, you get the information about whether something was in the cache
or not, so the side channel does exist to some degree.

But it's actually hugely reduced for a rather important reason: the
_primary_ reason for needing to know whether some page is in the cache
or not is not actually to see if it was ever accessed - it's to see
that the cache has been scrubbed (and to _guide_ the scrubbing), and
*when* it was accessed.

Think of it this way: the buffer cache residency is actually a
horribly bad signal on its own mainly because you generally have a
very high hit-rate. In most normal non-streaming situations with
sufficient amounts of memory you have pretty much everything cached.

So in order to use it as a signal, first you have to first scrub the
cache (because if the page was already there, there's no signal at
all), and then for the signal to be as useful as possible, you're also
going to want to try to get out more than one bit of information: you
are going to try to see the patterns and the timings of how it gets
filled.

And that's actually quite painful. You don't know the initial cache
state, and you're not (in general) controlling the machine entirely,
because there's also that actual other entity that you're trying to
attack and see what it does.

So what you want to do is basically to first make sure the cache is
scrubbed (only for the pages you're interested in!), then trigger
whatever behavior you are looking for, and then look how that affected
the cache.

In other words,  you want *multiple* residency status check - first to
see what the cache state is (because you're going to want that for
scrubbing), then to see that "yes, it's gone" when doing the
scrubbing, and then to see the *pattern* and timings of how things are
brought in.

And then you're likely to want to do this over and over again, so that
you can get real data out of the signal.

This is why something that doesn't perturb what you measure is really
important. If the act of measurement brings the page in, then you
can't use it for that "did I successfully scrub it" phase at all, and
you can't use it for measurement but once, so your view into patterns
and timings is going to be *much* worse.

And notice that this is true even if the act of measurement only
affects the *one* page you're measuring. Sure, any additional noise
around it would likely be annoying too, but it's not really necessary
to make the attack much harder to carry out. In fact, it's almost
irrelevant, since the signal you're trying to *see* is going to be
affected by prefetching etc too, so the patterns and timings you need
to look at are in bigger chunks than the readahead thing.

So yes, you as an attacker can remove the prefetching from *your*
load, but you can't remove it from the target load anyway, so you'll
just have to live with it.

Can you brute-force scrubbing? Yes. For something like an L1 cache,
that's easy (well, QoS domains make it harder). For something like a
disk cache, it's much harder, and makes any attempt to read out state
a lot slower. The paper that started this all uses mincore() not just
to see "is the page now scrubbed", but also to guide the scrubbing
itself (working set estimation etc).

And note that in many ways, the *scrubbing* is really the harder part.
Populating the cache is really easy: just read the data you want to
populate.

So if you are looking for a particular signal, say "did this error
case trigger so that it faulted in *that* piece of information", you'd
want to scrub the target, populate everything else, and then try to
measure at "did I trigger that target". Except you wouldn't want to do
it one page at a time but see as much pattern of "they were touched in
this order" as you can, and you'd like to get timing information of
how the pages you are interested were populated too.

And you'd generally do this over and over and over again because
you're trying to read out some signal.

Notice what the expensive operation was? It's the scrubbing.The "did
the target do IO" you might actually even see other ways for the
trivial cases, like even just look at iostat: just pre-populate
everything but the part you care about, then try to trigger whatever
you're searching for, and see if it caused IO or not.

So it's a bit like a chalkboard: in order to read out the result, you
need to erase it first, and doing that blindly is nasty. And you want
to look at timings, which is also really nasty if every time you look,
you smudge the very place you looked at. It makes it hard to see what
somebody else is writing on the board if you're always overwriting
what you just looked at. Did you get some new information? If not, now
you have to go back and do that scrubbing again, and you'll likely be
missing what *else* the person wrote.

Ans as always: there is no "black and white". There is no "absolute
security", and similarly, there is no "absolute leak proof". It's all
about making it inconvenient enough that it's not really practical.

                 Linus
