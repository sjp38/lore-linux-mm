Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 847A06B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 20:36:30 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so27862778igb.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 17:36:30 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q5si6917490pdb.41.2015.09.04.17.36.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 17:36:29 -0700 (PDT)
Date: Sat, 5 Sep 2015 10:36:18 +1000
From: Dave Chinner <dchinner@redhat.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
Message-ID: <20150905003618.GB2562@devil.localdomain>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
 <20150903005115.GA27804@redhat.com>
 <CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
 <20150903060247.GV1933@devil.localdomain>
 <CA+55aFxftNVWVD7ujseqUDNgbVamrFWf0PVM+hPnrfmmACgE0Q@mail.gmail.com>
 <20150904032607.GX1933@devil.localdomain>
 <CA+55aFzBTL=DnC4zv6yxjk0HxwxWpOhpKDPA8zkTGdgbh08sEg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzBTL=DnC4zv6yxjk0HxwxWpOhpKDPA8zkTGdgbh08sEg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mike Snitzer <snitzer@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>

On Thu, Sep 03, 2015 at 08:51:09PM -0700, Linus Torvalds wrote:
> On Thu, Sep 3, 2015 at 8:26 PM, Dave Chinner <dchinner@redhat.com> wrote:
> >
> > The double standard is the problem here. No notification, proof,
> > discussion or review was needed to turn on slab merging for
> > everyone, but you're setting a very high bar to jump if anyone wants
> > to turn it off in their code.
> 
> Ehh. You realize that almost the only load that is actually seriously
> allocator-limited is networking?

Of course I do - I've been following Jesper's work quite closely
because we might be able to make use of the batch allocation
mechanism in the XFS inode cache in certain workloads where we are
burning through a million inode slab allocations a second...

But again, you're bringing up justifications for a change that were
not documented in the commit message for the change. It didn't even
mention performance (just fragmentation and memory savings). If this
was such a critical factor in making this decision, then why weren't
such workloads and numbers provided with the commit? And why didn't
someone from netowkring actually review the change and ack/test that
it did actually do what it was supposed to?

If you are going to make an assertion, then you damn well better
provide numbers to go along with that assertion. What's you're
phrase, Linus? "Numbers talk and BS walks?" Where are the numbers,
Linus? Hmmmm?

Indeed, with network slabs that hot, mixing them with random other
slab caches could have a negative effect on performance by
increasing contention on the slab over what the network load already
brings. I learnt that lesson 12 years ago when optimisng the mbuf
slab allocator in the Irix network stack to scale to >1Mpps through
16 GbE cards: It worked just fine until we started doing something
with the data that the network was delivering and created more load
on the shared slab....

But, I digress. I've been trying to explain why we shouldn't be merging
slabs with shrinkers and you've shifted the goal posts rather
than addressing the discussion at hand.

> Really, Dave. You have absolutely nothing to back up your points with.
> Merging is *not* some kind of "new" thing that was silently enabled
> recently to take you by surprise.

The key slab tha I monitor for fragmentation behaviour (the XFS
inode slab) does not get merged. Ever. SLAB or SLUB. Because it has
a *constructor*.  Linus, if you bothered to read my previous
comments in this discussion then you'd know this.  I just want to
flag to extend that behaviour to all the slab caches I actively
manage with shrinkers, because slab merging does not benefit them
the same way it does passive slabs. That's not hard to understand,
nor is it a major issue for anyone.

>From my perspective, Linus, you're way out of line. You are not
engaging on a technical level - you're not even reading the
arguments I've been presenting. You're just cherry-picking something
mostly irrelelvant to the problem being discussed and going off at a
tangent ranting and swearing and trying your best to be abusive.
Your behaviour and bluster does not intimidate me, so please try to
be a bit more civil and polite and engage properly on a technical
level.


-Dave.
-- 
Dave Chinner
dchinner@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
