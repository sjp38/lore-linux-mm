Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id BBD696B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 21:21:03 -0400 (EDT)
Received: by igcrk20 with SMTP id rk20so38618034igc.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 18:21:03 -0700 (PDT)
Received: from mail-io0-x22f.google.com (mail-io0-x22f.google.com. [2607:f8b0:4001:c06::22f])
        by mx.google.com with ESMTPS id vk4si3889147igb.97.2015.09.02.18.21.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 18:21:03 -0700 (PDT)
Received: by iofb144 with SMTP id b144so41477845iof.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 18:21:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150903005115.GA27804@redhat.com>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
	<20150903005115.GA27804@redhat.com>
Date: Wed, 2 Sep 2015 18:21:02 -0700
Message-ID: <CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>
Cc: Dave Chinner <dchinner@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, Sep 2, 2015 at 5:51 PM, Mike Snitzer <snitzer@redhat.com> wrote:
>
> What I made possible with SLAB_NO_MERGE is for each subsystem to decide
> if they would prefer to not allow slab merging.

.. and why is that a choice that even makes sense at that level?

Seriously.

THAT is the fundamental issue here.

There are absolutely zero reasons this is dm-specific, but it is
equally true that there are absolutely zero reasons that it is
xyzzy-specific, for any random value of 'xyzzy'.

And THAT is why I'm fairly convinced that the whole approach is bogus
and broken.

And note that that bogosity is separate from how this was done. It's a
broken approach, but it was also done wrong. Two totally separate
issues, but together it sure is annoying.

> From where I sit it is much more useful to have separate slabs.  Could
> be if a case was actually made for slab merging I'd change my view.  But
> as of now these trump the stated benefits of slab merging:
> 1) useful slab usage stats
> 2) fault isolation from other subsystems

.. and again, absolutely NEITHER of those have anything to do with
"subsystem X".

Can you really not see how *illogical* it is to make this a subsystem choice?

So explain to me why you made it so?

> The 3 lines that added SLAB_NO_MERGE were pretty damn clean.

No. It really seriously wasn't.

The code may be simple, but it sure isn't "pretty damn clean", exactly
because I think the whole concept is fundamentally illogical. See
above.

As I mentioned in my email: if your point is that "slab_nomerge" has
the wrong default value, then that is a different discussion, and one
that may well be valid.

But the whole concept of "random slabs can mark themselves no-merge
for no obvious reasons" is broken. That was my argument, and you don't
seem to get it.

And even if it turns out not to be broken (please explain), it still
should have been discussed.

> SLAB_NO_MERGE gives subsystems a choice they didn't have before and they
> frankly probably never knew they had to care about it because they didn't
> know slabs were being merged.  I asked around enough to know I'm not an
> idiot for having missed the memo on slab merging.

Put another way: things have been merged for years, and you didn't even notice.

Seriously. I'm not exaggerating about "for years". At least for slub,
it's been that way since it was initially  merged, back in 2007.
Yeah, it may have taken a while for slub to then become one of the
major allocators, but it's been the default in at least Fedora for
years and years too, afaik, so it's not like slub is something odd and
unusual.

You seem to argue that "not being aware of it" means that it's
surprising and should be disabled. But quite frankly, wouldn't you say
that "it hasn't caused any obvious problems" is at _least_ as likely
an explanation for you not being aware of it?

Because clearly, that lack of statistics and the possible
cross-subsystem corruption hasn't actually been a pressing concern in
reality.

But suddenly it became such a big issue that you just _had_ to fix it,
right? After seven years it's suddenly *so* important that dm
absolutely has to disable it. And it really had to be dm that did it
for its caches, rather than just use "slab_nomerge".

Despite there not being anything dm-specific about that choice.

Now tell me, what was the rationale for this all again?

Because really, I'm not seeing it. And I'm _particularly_ not seeing
why it then had to be sneaked in like this.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
