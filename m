Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 56ABF6B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 22:31:29 -0400 (EDT)
Received: by pacwi10 with SMTP id wi10so30217923pac.3
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 19:31:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x5si38771934pbt.100.2015.09.02.19.31.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 19:31:28 -0700 (PDT)
Date: Wed, 2 Sep 2015 22:31:25 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
Message-ID: <20150903023125.GC27804@redhat.com>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
 <20150903005115.GA27804@redhat.com>
 <CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Heinz Mauelshagen <heinzm@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Viresh Kumar <viresh.kumar@linaro.org>, Dave Chinner <dchinner@redhat.com>, Joe Thornber <ejt@redhat.com>, Pekka Enberg <penberg@kernel.org>, linux-mm <linux-mm@kvack.org>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Alasdair G Kergon <agk@redhat.com>

On Wed, Sep 02 2015 at  9:21pm -0400,
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Sep 2, 2015 at 5:51 PM, Mike Snitzer <snitzer@redhat.com> wrote:
> >
> > What I made possible with SLAB_NO_MERGE is for each subsystem to decide
> > if they would prefer to not allow slab merging.
> 
> .. and why is that a choice that even makes sense at that level?
> 
> Seriously.
> 
> THAT is the fundamental issue here.
> 
> There are absolutely zero reasons this is dm-specific, but it is
> equally true that there are absolutely zero reasons that it is
> xyzzy-specific, for any random value of 'xyzzy'.
> 
> And THAT is why I'm fairly convinced that the whole approach is bogus
> and broken.

Why do we even have slab creation flags?

Andrew seemed much more reasonable about this.

> And note that that bogosity is separate from how this was done. It's a
> broken approach, but it was also done wrong. Two totally separate
> issues, but together it sure is annoying.
> 
> > From where I sit it is much more useful to have separate slabs.  Could
> > be if a case was actually made for slab merging I'd change my view.  But
> > as of now these trump the stated benefits of slab merging:
> > 1) useful slab usage stats
> > 2) fault isolation from other subsystems
> 
> .. and again, absolutely NEITHER of those have anything to do with
> "subsystem X".

OK, I get that I'm unimportant.  You can stop beating me over my
irrelevant subsystem maintainer head now...

But when longstanding isolation and functionality is removed in the name
of microoptimizations its difficult to accept -- even if the realization
occurs years after the fact.

> Can you really not see how *illogical* it is to make this a subsystem choice?
> 
> So explain to me why you made it so?
> 
> > The 3 lines that added SLAB_NO_MERGE were pretty damn clean.
> 
> No. It really seriously wasn't.
> 
> The code may be simple, but it sure isn't "pretty damn clean", exactly
> because I think the whole concept is fundamentally illogical. See
> above.

Yeah, your circular logic doesn't help me.  You defined your argument in
terms of unsubstantiated claims of me being illogical.

What is illogical about wanting DM to:
1) have useful slab accounting
2) have fault isolation from other slab consumers
3) not impose 1+2 on all other subsystems

?

I guess I'm just supposed to accept that slab merging is or isn't.
There is no in-between (unless I create a slab with SLAB_DESTROY_BY_RCU)

> As I mentioned in my email: if your point is that "slab_nomerge" has
> the wrong default value, then that is a different discussion, and one
> that may well be valid.
> 
> But the whole concept of "random slabs can mark themselves no-merge
> for no obvious reasons" is broken. That was my argument, and you don't
> seem to get it.

I'm not getting it because I don't understand why you really care.  What
implied benefits come with slab merging that I'm painfully unaware of?

Andrew said DM would miss out on performance benefits.  I'd obviously
not want to do that; but said performance benefits haven't been made
apparent.
 
> And even if it turns out not to be broken (please explain), it still
> should have been discussed.

See above ;)

> > SLAB_NO_MERGE gives subsystems a choice they didn't have before and they
> > frankly probably never knew they had to care about it because they didn't
> > know slabs were being merged.  I asked around enough to know I'm not an
> > idiot for having missed the memo on slab merging.
> 
> Put another way: things have been merged for years, and you didn't even notice.
> 
> Seriously. I'm not exaggerating about "for years". At least for slub,
> it's been that way since it was initially  merged, back in 2007.
> Yeah, it may have taken a while for slub to then become one of the
> major allocators, but it's been the default in at least Fedora for
> years and years too, afaik, so it's not like slub is something odd and
> unusual.

You're also coming at this from a position that shared slabs are
automatically good because they have been around for years.

For those years I've not had a need to debug a leak in code I maintain;
so I didn't notice slabs were merged.  I also haven't observed slab
corruption being the cause of crashes in DM, block or SCSI.

> You seem to argue that "not being aware of it" means that it's
> surprising and should be disabled. But quite frankly, wouldn't you say
> that "it hasn't caused any obvious problems" is at _least_ as likely
> an explanation for you not being aware of it?

Sure.

> Because clearly, that lack of statistics and the possible
> cross-subsystem corruption hasn't actually been a pressing concern in
> reality.

Agreed.

> But suddenly it became such a big issue that you just _had_ to fix it,
> right? After seven years it's suddenly *so* important that dm
> absolutely has to disable it. And it really had to be dm that did it
> for its caches, rather than just use "slab_nomerge".

The ship sailed on disabling it for everyone.  It is the new norm.  I
cannot push RHEL to flip-flop slab characteristics (at least not until
the next major release).

> Despite there not being anything dm-specific about that choice.
> 
> Now tell me, what was the rationale for this all again?

I was the first to want the option to opt-out on a per slab basis.  And
you're shooting the messenger.  Calling me illogical.

> Because really, I'm not seeing it. And I'm _particularly_ not seeing
> why it then had to be sneaked in like this.

And I'm a sneaky too... Sneaking isn't what this was.  Apologies if
that's how it came off.  I can appreciate why you might think that.
But like I said to Andrew: won't happen again.

I'm off the next 5 days.  I don't think either of us care _that_
strongly about this particular issue.  I've noted my process flaws.
I'll calm down and this will just be some unfortunate thing that
happened.

But I'd still like some pointers/help on what makes slab merging so
beneficial.  I'm sure Christoph and others have justification.  But if
not then yes the default to slab merging probably should be revisited.

Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
