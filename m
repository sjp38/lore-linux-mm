Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 07B8E6B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 20:51:19 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so40606060ioi.2
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 17:51:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j4si13444128pda.206.2015.09.02.17.51.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 17:51:18 -0700 (PDT)
Date: Wed, 2 Sep 2015 20:51:15 -0400
From: Mike Snitzer <snitzer@redhat.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
Message-ID: <20150903005115.GA27804@redhat.com>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <dchinner@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, Sep 02 2015 at  7:13pm -0400,
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Wed, Sep 2, 2015 at 10:39 AM, Mike Snitzer <snitzer@redhat.com> wrote:
> >
> > - last but not least: add SLAB_NO_MERGE flag to mm/slab_common and
> >   disable slab merging for all of DM's slabs (XFS will also use
> >   SLAB_NO_MERGE once merged).
> 
> So I'm not at all convinced this is the right thing to do. In fact,
> I'm pretty convinced it shouldn't be done this way. Since those
> commits were at the top of your tree, I just didn't pull them, but
> took the rest..

OK, thanks.
 
> You are basically making this one-sided decision based on your notion
> of convenience, and just forcing that thing unconditionally on people.

The switch to slab merging was forced on everyone without proper notice.

What I made possible with SLAB_NO_MERGE is for each subsystem to decide
if they would prefer to not allow slab merging.

> Your rationale seems _totally_ bogus: you say that it's to be able to
> observe the sizes of the dm slabs without using slab debugging.
> 
> First off, you don't have to enable slab debugging. You can just
> disable slab merging.  It's called "slab_nomerge". It does exactly
> what you would think it does.

I'm well aware of slab_nomerge.  I called it out in my commit message.

> And what is it that makes dm slabs such a special little princess?
> What makes you think that the fact that _you_ want to look at slab
> statistics means that everybody else suddenly must have separate slabs
> for dm, and dm only? Or xfs?

>From where I sit it is much more useful to have separate slabs.  Could
be if a case was actually made for slab merging I'd change my view.  But
as of now these trump the stated benefits of slab merging:
1) useful slab usage stats
2) fault isolation from other subsystems

> The other "rationale" was that not merging slabs limits
> cross-subsystem memory corruption. Again, what the _hell_ is special
> about device mapper that dm - and only dm - would make this a special
> thing? That is just pure and utter garbage. Again, we already have
> that "slab_nomerge" option, exactly so that when odd slab corruption
> issues happen (they are rare, but they do occasionally happen), you
> can try that to see if that pinpoints the problem more. And it is
> *not* limited to some random set of subsystems. Which makes it clearly
> superior to your broken approach, wouldn't you agree?

I'm not interested in deciding such things for everyone.

I added a flag that enables piecewise enablement of unshared slabs for
subsystems that really don't want shared slabs.

Aside from improved accounting, the point is to not allow other crap
code (e.g. staging or whatever) to impact other subsystems via shared
slabs.

> The only possible true rationale for why dm is special is "because dm
> is such a buggy piece of sh*t that it's much more likely to have these
> slab corruption bugs than anything else, so I'm just protecting the
> rest of the system".
>
> Is that really your rationale? Somehow I doubt it. But if it is, you
> really should have said so. At least then it would make sense why this
> thing came in through the dm tree, and why dm is so special than it -
> and only it - would disable slab merging.

The 3 lines that added SLAB_NO_MERGE were pretty damn clean.
SLAB_NO_MERGE gives subsystems a choice they didn't have before and they
frankly probably never knew they had to care about it because they didn't
know slabs were being merged.  I asked around enough to know I'm not an
idiot for having missed the memo on slab merging.

Lack of awareness aside, nobody ever _convincingly_ detailed why slab
merging was pushed on everyone.  Look at the header for commit 12220de
("mm/slab: support slab merge") -- now that is some seriously weak
justification!

I sought to get more insight on "why slab merging?" and all I found was
this in Documentation/vm/slub.txt:

"
Slab merging
------------

If no debug options are specified then SLUB may merge similar slabs together
in order to reduce overhead and increase cache hotness of objects.
slabinfo -a displays which slabs were merged together."
"

I couldn't even find which package provides slabinfo to run slabinfo -a!

And the hand-wavvy "reduce overhead and increase cache hotness of
objects" frankly sucks.

> So I'm not pulling things like this from the device mapper tree. There
> is just no excuse that I can see for something like SLAB_NO_MERGE to
> go through the dm tree in the first place, but that's doubly true when
> the rationale for these things were bogus and had nothing what-so-ever
> to do with dm.

As DM maintainer I do have a choice about how the subsystem is
architected.

> Things like this aren't supposed to come in through random irrelevant
> trees like this, and with no discussion (at least judging by the
> commits) with the maintainers of the other pieces of code.

DM is irrelevant now?  Because I pissed you off?  Or because you trully
think that?

This is the first and hopefully last time I get flamed by you.  I
shouldn't have pushed for this change so aggressively.  The lack of
feedback from mm people shouldn't have been taken by me as implied "we
forced it on you a year ago, fuck you".  But I'm genuinely _not_
appreciative of this change to shared slabs so I took action to restore
what I hold to be the right way to design system software.

> If you have issues with slab merging, then those should be discussed
> as such, not as some magical and bogus dm or xfs special case when
> they damn well aren't, and damn well will never be.
> 
> Yes, I'm annoyed. This was not done well. I realize that everybody
> thinks that _their_ code is so special and exceptional that
> "obviously" they should be treated specially, but I don't see that
> that is the case at all in this case.
> 
> If you want to argue that slab merging should be disabled by default,
> then that is an argument that I'm willing to believe might be valid
> ("the downsides are bigger than the upsides").  Or if you are able to
> explain why dm really _is_ special, that's an option too. But this
> kind of "random subsystems decide unilaterally to not follow the
> normal rules" is not acceptable. Not when the "arguments" for it have
> absolutely nothing in particular to do with that subsystem.

DM isn't special.  Never intended it to come off like it is.  I don't
want slab merging but as a middle ground I made it so it is left to each
subsystem to decide to use it or not.  I clearly was the first to take
issue with slab merging by calling it out with patches.  In doing so
Dave Chinner said he'd rather avoid using shared slabs in XFS.  Pretty
sure XFS isn't irrelvant yet.

I'd wager there would be a flood of other subsystems opting to use
SLAB_NO_MERGE.  I can appreciate that as something the pro-slab-merge
camp would like to avoid (the more that opt-out the more useless slab
merging becomes).

It is messed up that no _real_ justification was given for slab merging
yet it was pushed on everyone.  Thankfully it hasn't been unstable
(which backs up your point) but I'd still love to understand how it is
so beneficial.   Is it a significant win?  If so where?  Or is it a
microoptimization at the expense of both accounting and fault isolation?

Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
