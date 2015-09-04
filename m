Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id E75F46B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 23:26:22 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so3927278qkc.3
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 20:26:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b9si1348064qgb.45.2015.09.03.20.26.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 20:26:21 -0700 (PDT)
Date: Fri, 4 Sep 2015 13:26:07 +1000
From: Dave Chinner <dchinner@redhat.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
Message-ID: <20150904032607.GX1933@devil.localdomain>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
 <20150903005115.GA27804@redhat.com>
 <CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
 <20150903060247.GV1933@devil.localdomain>
 <CA+55aFxftNVWVD7ujseqUDNgbVamrFWf0PVM+hPnrfmmACgE0Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxftNVWVD7ujseqUDNgbVamrFWf0PVM+hPnrfmmACgE0Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mike Snitzer <snitzer@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>

On Thu, Sep 03, 2015 at 08:02:40AM -0700, Linus Torvalds wrote:
> On Wed, Sep 2, 2015 at 11:02 PM, Dave Chinner <dchinner@redhat.com> wrote:
> > On Wed, Sep 02, 2015 at 06:21:02PM -0700, Linus Torvalds wrote:
> > Right, it's not xyzzy-specific where 'xyzzy' is a subsystem. The
> > flag application is actually *object specific*. That is, the use of
> > the individual objects that determines whether it should be merged
> > or not.
> 
> Yes.
> 
> I do agree that something like SLAB_NO_MERGE can make sense on an
> actual object-specific level, if you have very specific allocation
> pattern knowledge and can show that the merging actually hurts.

There are generic cases where it hurts, so no justification should
be needed for those cases...

> > e.g. Slab fragmentation levels are affected more than anything by
> > mixing objects with different life times in the same slab.  i.e. if
> > we free all the short lived objects from a page but there is one
> > long lived object on the page then that page is pinned and we free
> > no memory. Do that to enough pages in the slab, and we end up with a
> > badly fragmented slab.
> 
> The thing is, *if* you can show that kind of behavior for a particular
> slab, and have numbers for it, then mark that slab as no-merge, and
> document why you did it.

The double standard is the problem here. No notification, proof,
discussion or review was needed to turn on slab merging for
everyone, but you're setting a very high bar to jump if anyone wants
to turn it off in their code.

> And quite frankly, I don't actually think you have the numbers to show
> that theoretical bad behavior.

I don't keep numbers close handy. I've been dealing with these
problems for ten years, to I just know what workloads demonstrate
this "theoretical bad behaviour" within specific slabs and test them
when relevant. I'll do a couple of quick "merging is better"
verification tests this afternoon, but other than that I don't have
time in the next couple of weeks...

But speaking of workloads, internal inode cache slab fragmentation
is simple to reproduce on any filesystem. XFS just happens to be the
only one that really actively manages it as a result of long term
developer awareness of the problem. I first tripped over it in early
2005 with SpecSFS, and then with other similar NFS benchmarks like
filebench.  That's where Christoph Lameter was introduced to the
problem, too:

https://lwn.net/Articles/371892/

" The problem is that sparse use of objects in slab caches can cause
large amounts of memory to become unusable. The first ideas to
address this were developed in 2005 by various people."

FYI, with appropriate manual "drop slab" hacks during the benchmark,
we could get 20-25% higher throughput from the NFS server because
dropping the entire slab cache before the measurement phase meant we
avoided the slab fragmentation issue and had ~50% more free memory
to use for the page cache during the measurement period...

Similar problems have been reported over the years by users with
backup programs or scripts that used find, rsync and/or 'cp -R' on
large filesystems. It used to be easy to cause these sorts of
problems in the XFS inode cache. There's quite a few other
workloads, but it easily to reproduce inode slab fragmetnation with
find, bulkstat and cp. Basically all you need to do is populate the
inode cache, randomise the LRU order, then trigger combined inode
cache and memory demand.  It's that simple.

The biggest problem with using a workload like this to "prove" that
slab merging degrades behaviour is that we don't know what slabs
have been merged. Hence it's extremely hard to generate a workload
definition that demonstrates it. Indeed, change kernel config
options, structures change size and the slab is merged with
different objects, so the workload that generates problems has to be
changed, too.  And it doesn't even need to be a kernel with a
different config - just a different set of modules loaded because
the hardware and software config is different will change what slabs
are merged.

IOWs, what produces a problem on one kernel on one machine will not
reproduce the same problem on a different kernel or machine. Numbers
are a crapshoot here, especially as the cause of the problem is
trivially easy to understand.

Linus, you always say that at some point you've just got to step
back, read the code and understand the underlying issue that is
being dealt with because some things are way too complex to
reproduce reliably. This is one of those cases - it's obvious that
slab merging does not fix or prevent internal slab cache
fragmentation and that it only serves to minimise the impact of
fragmentation by amortising it across multiple similar slabs.
Really, this is the best we can do with passive slab caches where
you can't control freeing patterns.

However, we also have actively managed slab caches, and they can and
do work to prevent fragmetnation and clear it quickly when it
happens. Merging these actively managed slabs with other passive
slab is just a bad idea because the passive slab objects can only
reduce the effectiveness of the active management algorithms. We
don't need numbers to understand this - it's clear and obvious from
an algorithmic point of view.

> In contrast, there really *are*
> numbers to show the advantages of merging.

I have never denied that. Please listen to what I'm saying.

> So the fragmentation argument has been shown to generally be in favor
> of merging, _not_ in favor of that "no-merge" behavior.

Yes, all the numbers and research I've seen has been on passive
slab cache behaviour. I *agree* that passive slab caches should be
merged, but I don't recall anyone documenting the behavioural
distinction between active/passive slabs before now, even though
it's been something I've had in my head for several years. Actively
managed slabs are very different in their behaviour to passive
slabs, and so what holds true for passive slabs is not necessarily
true for actively managed slabs.

Really, we don't need some stupidly high bar to jump over here -
whether merging should be allowed can easily be answered with a
simple question: "Does the slab have a shrinker or does it back a
mempool?" If the answer is yes then using SLAB_SHRINKER or
SLAB_MEMPOOL to trigger the no-merge case doesn't need any more
justification from subsystem maintainers at all.

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
