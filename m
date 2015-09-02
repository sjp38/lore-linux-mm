Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id EA2FD6B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 19:13:45 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so38646760ioi.2
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 16:13:45 -0700 (PDT)
Received: from mail-io0-x232.google.com (mail-io0-x232.google.com. [2607:f8b0:4001:c06::232])
        by mx.google.com with ESMTPS id ri1si3619370igc.93.2015.09.02.16.13.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 16:13:45 -0700 (PDT)
Received: by iofb144 with SMTP id b144so38889239iof.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 16:13:45 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 2 Sep 2015 16:13:44 -0700
Message-ID: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
Subject: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>, Dave Chinner <dchinner@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, Sep 2, 2015 at 10:39 AM, Mike Snitzer <snitzer@redhat.com> wrote:
>
> - last but not least: add SLAB_NO_MERGE flag to mm/slab_common and
>   disable slab merging for all of DM's slabs (XFS will also use
>   SLAB_NO_MERGE once merged).

So I'm not at all convinced this is the right thing to do. In fact,
I'm pretty convinced it shouldn't be done this way. Since those
commits were at the top of your tree, I just didn't pull them, but
took the rest..

You are basically making this one-sided decision based on your notion
of convenience, and just forcing that thing unconditionally on people.

Your rationale seems _totally_ bogus: you say that it's to be able to
observe the sizes of the dm slabs without using slab debugging.

First off, you don't have to enable slab debugging. You can just
disable slab merging.  It's called "slab_nomerge". It does exactly
what you would think it does.

And what is it that makes dm slabs such a special little princess?
What makes you think that the fact that _you_ want to look at slab
statistics means that everybody else suddenly must have separate slabs
for dm, and dm only? Or xfs?

The other "rationale" was that not merging slabs limits
cross-subsystem memory corruption. Again, what the _hell_ is special
about device mapper that dm - and only dm - would make this a special
thing? That is just pure and utter garbage. Again, we already have
that "slab_nomerge" option, exactly so that when odd slab corruption
issues happen (they are rare, but they do occasionally happen), you
can try that to see if that pinpoints the problem more. And it is
*not* limited to some random set of subsystems. Which makes it clearly
superior to your broken approach, wouldn't you agree?

The only possible true rationale for why dm is special is "because dm
is such a buggy piece of sh*t that it's much more likely to have these
slab corruption bugs than anything else, so I'm just protecting the
rest of the system".

Is that really your rationale? Somehow I doubt it. But if it is, you
really should have said so. At least then it would make sense why this
thing came in through the dm tree, and why dm is so special than it -
and only it - would disable slab merging.

So I'm not pulling things like this from the device mapper tree. There
is just no excuse that I can see for something like SLAB_NO_MERGE to
go through the dm tree in the first place, but that's doubly true when
the rationale for these things were bogus and had nothing what-so-ever
to do with dm.

Things like this aren't supposed to come in through random irrelevant
trees like this, and with no discussion (at least judging by the
commits) with the maintainers of the other pieces of code.

If you have issues with slab merging, then those should be discussed
as such, not as some magical and bogus dm or xfs special case when
they damn well aren't, and damn well will never be.

Yes, I'm annoyed. This was not done well. I realize that everybody
thinks that _their_ code is so special and exceptional that
"obviously" they should be treated specially, but I don't see that
that is the case at all in this case.

If you want to argue that slab merging should be disabled by default,
then that is an argument that I'm willing to believe might be valid
("the downsides are bigger than the upsides").  Or if you are able to
explain why dm really _is_ special, that's an option too. But this
kind of "random subsystems decide unilaterally to not follow the
normal rules" is not acceptable. Not when the "arguments" for it have
absolutely nothing in particular to do with that subsystem.

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
