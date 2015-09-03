Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 61D8C6B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 02:03:01 -0400 (EDT)
Received: by iofb144 with SMTP id b144so46679425iof.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 23:03:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bz5si39731601pdb.0.2015.09.02.23.03.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 23:03:00 -0700 (PDT)
Date: Thu, 3 Sep 2015 16:02:47 +1000
From: Dave Chinner <dchinner@redhat.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
Message-ID: <20150903060247.GV1933@devil.localdomain>
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
Cc: Mike Snitzer <snitzer@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, Sep 02, 2015 at 06:21:02PM -0700, Linus Torvalds wrote:
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

It makes a lot more sense than you think, Linus.

One of the reasons slab caches exist is to separate objects of
identical characteristics from the heap allocator so that they are
all grouped together in memory and so can be allocated/freed
efficiently.  This helps prevent heap fragmentation, allows objects
to pack as tightly together as possible, gives direct measurement of
the number of objects, the memory usage, the fragmentation factor,
etc. Containment of memory corruption is another historical reason
for slab separation (proof: current memory debugging options always
causes slab separation).

Slab merging is the exact opposite of this - we're taking homogenous
objects and mixing them with other homogneous containing different
objects with different life times. Indeed, we are even mixing them
back into the slabs used for the heap, despite the fact the original
purpose of named slabs was to separate allocation from the heap...

Don't get me wrong - this isn't necessarily bad - but I'm just
pointing out that slab merging is doing the opposite of what slabs
were originally intended for. Indeed, a lot of people use slab
caches just because it's anice encapsulation, not for any specific
performance, visibility or anti-fragmentation purposes.  I have no
problems with automatically merging slabs created like this.

However the fact that we are merging slabs automatically for all
slabs now has made me think a bit deeper about the problems that can
result from this.

> There are absolutely zero reasons this is dm-specific, but it is
> equally true that there are absolutely zero reasons that it is
> xyzzy-specific, for any random value of 'xyzzy'.

Right, it's not xyzzy-specific where 'xyzzy' is a subsystem. The
flag application is actually *object specific*. That is, the use of
the individual objects that determines whether it should be merged
or not.

e.g. Slab fragmentation levels are affected more than anything by
mixing objects with different life times in the same slab.  i.e. if
we free all the short lived objects from a page but there is one
long lived object on the page then that page is pinned and we free
no memory. Do that to enough pages in the slab, and we end up with a
badly fragmented slab.

With slab merging, we have no control over what slabs are merged. We
may be merging slabs with objects that have vastly different life
times. Hence merging may actually be making one of the underlying
cause of slab fragmentation worse rather than better. It really
depends on what slabs get merged together and that's largely random
chance - you don't get to pick the size of your structures....

Another contributor to slab fragmentation is when allocation order
is very different to object freeing order. Pages in the slab get
fill up using an algorithm that optimises for temporal locality.
i.e. it will fill a partial page before moving on to the next
partial page or allocating a new page.  If the freeing of objects
doesn't have the same temporal locality as allocation then when the
slab grows and shrinks we end up with fragmentation. Mixing
different object types into the same pages pretty much guarantees
that we'll be mixing objects of different alloc/freeing order.

Further, rapid growth and shrinking of a slab cache due to memory
demand can cause fragmentation. Caches that have this problem are
usually those that have a shrinker associated with them. The
shrinker causes objects to have a variable, unpredictable lifetime
and hence can break allocation/freeing locality (as per above, even
for single object slabs).

Minmising the effect of this reclaim fragmentation is often held up
as the example of why slab merging is good - the other object types
fill all the holes and hence reduces the overall fragmentation of
the slab. Further, the density of the reclaimable objects is lower,
so the slab doesn't fragment as much.

On the surface, this looks like a big win but it's not - it's
actually a major problem for slab reclaim and it manifests when
there are large bursts of allocation activity followed by sudden
reclaim activity.  When the slab grows rapidly, we get the majority
of objects on a page being of one type, but a couple will be of a
different type. Than under memory pressure, the shrinker can then
only free the majority of objects on a page, guaranteeing the slab
will remain fragmented under memory pressure.  Continuing to run the
shrinker won't result in any more memory being freed from the merged
slab and so we are stuck with unfixable slab fragmentation.

However, if the slab with a shrinker only contains one kind of
object, when it becomes fragmented due to variable object lifetime,
continued memory pressure will cause it to keep shrinking and hence
will eventually correct the fragmentation problem. This is a much
more robust configuration - the system will self correct without
user intervention being necessary.

IOWs, slab merging prevents us from implementing effective active
fragmentation management algorithms and hence prevents us  from
reducing slab fragmentation via improved shrinker reclaim
algorithms.  Simply put: slab merging reduces the effectiveness of
shrinker based slab reclaim.

A key observation I just made: we are extremely lucky that many of
the critical slab caches in the system are not affected by merging.
A slab cache with a constructor will not get merged and that means
inode caches do not get merged. Hence, despite slab merging being
enabled, one of the largest memory consuming slabs in the system
does not get merged and hence it means the shrinker has been able to
do it's job without interference. hence we've avoided the worst
outcome of merging slabs by default by luck rather than good
managment.

Moving on from fragmentation: Slab caches can also back mempools.
mempools ar eused to guarantee forwards progress under memory
pressure, so it's important to have visibility into their behaviour.

Hence it makes sense to ensure these don't get merged with other
slabs so they are accounted accurately and we can see exactly the
demand being placed on these critical slabs under heavy memory
pressure. I've made use of this several times over the past few
years to discover why a system is floundering under heavy memory
pressure (e.g. writeback way slower than it should have been because
the xfs_ioend mempool was operating in 1-in, 1-out mode)...

So, when I said that I could use the SLAB_NO_MERGE for some caches
in XFS and acked the patch, I was refering to exactly this sort of
usage - the slabs that back mempools and the slabs that have a
shrinker for reclaim should have this flag set. 4 of 17 named slabs
in XFS need this flag - the rest I don't really care about because
their memory usage can be inferred from the shrinkable slab cache
sizes.

Managing slab caches and fragmentation is anything but simple and
there is no one right solution. Slab merging in some cases makes
sense, but there are several very good reasons for not merging a
slab.  The right solution is often difficult for people without
object-specific expertise to understand, but that goes for just
about everything in the kernel these days.

BTW, it is trivial to achieve SLAB_NO_MERGE simply by supplying a
dummy constructor to the slab initialisation.  I'd much prefer
SLAB_NO_MERGE or some variant, though.

Cheers,

Dave.
-- 
Dave Chinner
dchinner@redhat.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
