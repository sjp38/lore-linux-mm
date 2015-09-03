Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8196B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 23:12:00 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so43388293ioi.2
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 20:12:00 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id q77si20314233ioe.201.2015.09.02.20.11.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 20:11:59 -0700 (PDT)
Received: by igcrk20 with SMTP id rk20so39999462igc.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 20:11:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150903023125.GC27804@redhat.com>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
	<20150903005115.GA27804@redhat.com>
	<CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
	<20150903023125.GC27804@redhat.com>
Date: Wed, 2 Sep 2015 20:11:59 -0700
Message-ID: <CA+55aFyF1NVLqAGPJefkh8Th_veni1c9NZaS0ZSup0kBR-pw7A@mail.gmail.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>
Cc: Heinz Mauelshagen <heinzm@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Viresh Kumar <viresh.kumar@linaro.org>, Dave Chinner <dchinner@redhat.com>, Joe Thornber <ejt@redhat.com>, Pekka Enberg <penberg@kernel.org>, linux-mm <linux-mm@kvack.org>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Alasdair G Kergon <agk@redhat.com>

On Wed, Sep 2, 2015 at 7:31 PM, Mike Snitzer <snitzer@redhat.com> wrote:
>
> Why do we even have slab creation flags?

Ehh? Because they are meaningful?

Things like SLAB_DESTROY_BY_RCU have real semantic meaning. The
subsystem that creates the slab *cares*, and it makes sense because
that kind of choice really fundamentally is a per-slab choice.

>> .. and again, absolutely NEITHER of those have anything to do
>> "subsystem X".
>
> OK, I get that I'm unimportant.  You can stop beating me over my
> irrelevant subsystem maintainer head now...

What the hell is your problem?

At no point did I state that you are any less important than anything
else. But this isssue is simply not in any way specific to dm. dm is
not any less important than anything else, but dm is also not
magically *more* important than everything else.

Really.

Then you seem to take it personally, but please realize that that is
*your* issue, not mine.

> But when longstanding isolation and functionality is removed in the name
> of microoptimizations its difficult to accept -- even if the realization
> occurs years after the fact.

Bullshit.

You didn't notice. For years. It just wasn't important. Just admit it.
Those things you now tout as so important are complete non-issues.

But more importantly, and this is what you seem to not really get at
all, is that it's STILL not dm-specific.

If you think that isolation is so important, then tell me why
isolation is only important for dm? Why isn't it important for
everything else? What makes dm so special?

Really. I've asked you three times now, and you seem to not get it,
you just think I'm trying to put you in your place. I'm not. I'm
asking a serious question: what makes dm so special that it has to
have different allocation logic from everything else.

And *THAT* is why SLAB_DESTROY_BY_RCU is different from your
SLAB_NO_MERGE. Because I can actually answer the question:

   "What makes sighand_cachep need SLAB_DESTROY_BY_RCU but not other users?"

with a real technical reason.

> I'm not getting it because I don't understand why you really care.  What
> implied benefits come with slab merging that I'm painfully unaware of?

It does actually have less overhead, for one thing. The separation of
slabs doesn't cost you just in the slab data structure itself, but in
the memory fragmentation. Having multiple slabs share the backing pool
of pages uses less memory.

> You're also coming at this from a position that shared slabs are
> automatically good because they have been around for years.

No, I'm really not.

Christ, have you read anything I wrote?

I'm ok with discussing the "the defaults should be turned around". But
at least we *have* an option to turn that default around, so when
people care (because they are trying to chase down a slab corruption
issue, for example), they can do so.

Your patch actually gets rid of that choice, and forces things the
other way around.

So I would argue that your patch actually makes things *worse*.  It
hardcodes an arbitrary choice, and it's not even a choice that makes
obvious sense.

And no, the memory fragmentation issue isn't just made up. One of the
downsides of slab was historically that it used a lot of memory, and
to be honest, I suspect the percpu queues have made things worse. At
least sharing the backing store minimizes the effect of that somewhat.
We used to have numbers for this all, but it's really approaching a
decade since the whole initial SLUB vs SLAB things, so I don't know
where to point you.

But the reason I say "it's not a choice that makes obvious sense"
isn't even because I'm convinced that the merging is always the best
option. I *am* convinced that it has real upsides, but I also agree
that it has downsides. But at least as it is right now, the system
admin can make a choice.

You arbitrarily wanted to take that choice away for dm, without
apparently even knowing what the upsides of merging might be.

But the *real* issue I have with it is the completely random "dm is
different from everything else" thing. Which is bogus. That's what I
wanted to know: what makes dm so special that it should be different
from everything else?

And apparently you don't have an answer to that. You just took my
repeated questioning to mean that you're worthless. That wasn't the
intent. It was very much a literal "what's so different about dm that
it would act differently from everything else"?

> The ship sailed on disabling it for everyone.  It is the new norm.  I
> cannot push RHEL to flip-flop slab characteristics (at least not until
> the next major release).

But you can. Today. Put "slab_nomerge" on the kernel command line.

Really. If you care, you can do that. And if you _don't_ care, then
clearly not doing that doesn't hurt either.

> I was the first to want the option to opt-out on a per slab basis.  And
> you're shooting the messenger.  Calling me illogical.

But the opt-in shouldn't be *you*, it should be the system maintainer
who can actually tune for his load, or cares about memory use, or
wants to debug, or any number of issues.

See?

Btw, I do agree that the "all or nothing" approach of "slab_nomerge"
isn't optimal. But you made things *worse*. You took a tunable, and
made it non-tunable, without apparently even knowing what it tuned
for. Sure, it was a damn coarse-grained tunable, but you made *that*
worse too, since with your code it's not tunable at all for dm. So
your version isn't actually any more "fine-grained".

Now, what might be interesting - *if* people actually want to tune
just one set of slabs and not another - migth be to extend the
"slab_nomerge" option to actually take a pattern of slab names, and
match that way.

So then you could say "slab_nomerge=dm_* slab_nomerge=xfs*", and you'd
not merge dm or xfs slabs. I wouldn't mind that kind of approach at
all.

But please understand _why_ I wouldn't mind it: I wouldn't mind it
exactly because you didn't take tuning choice away from people, but
because such a patch would actually give people control of it. And it
*wouldn't* be dm-specific, because other people might ask to not merge
ext4 slabs or whatever.

And for a similar reason, I actually wouldn't mind switching the
default around for merging. I'm *not* married to the "we have to merge
slab caches by default" model. It used to make sense, and I know I've
seen numbers (I'm pretty sure Christoph Lameter had several talks
about it back in the days), but things can change.

But what doesn't make sense is to make random willy-nilly decisions on
a basis that makes no sense. And I do claim that random subsystems
just unilaterally deciding that they don't care about system default
memory management falls under that "makes no sense" heading.

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
