Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id E180A6B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 21:16:55 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so36834442pad.1
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 18:16:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id kg8si7068778pab.100.2015.09.04.18.16.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 18:16:55 -0700 (PDT)
Date: Sat, 5 Sep 2015 11:16:14 +1000
From: Dave Chinner <dchinner@redhat.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
Message-ID: <20150905011614.GC2562@devil.localdomain>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
 <20150903005115.GA27804@redhat.com>
 <CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
 <20150903060247.GV1933@devil.localdomain>
 <CA+55aFxftNVWVD7ujseqUDNgbVamrFWf0PVM+hPnrfmmACgE0Q@mail.gmail.com>
 <20150904032607.GX1933@devil.localdomain>
 <alpine.DEB.2.11.1509040849460.30848@east.gentwo.org>
 <20150904224635.GA2562@devil.localdomain>
 <alpine.DEB.2.11.1509041914180.2797@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1509041914180.2797@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mike Snitzer <snitzer@redhat.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>

On Fri, Sep 04, 2015 at 07:25:48PM -0500, Christoph Lameter wrote:
> On Sat, 5 Sep 2015, Dave Chinner wrote:
> 
> > > Inodes and dentries have constructors. These slabs are not mergeable and
> > > will never be because they have cache specific code to be executed on the
> > > object.
> >
> > I also said that the fact that they are not merged is really by
> > chance, not by good management. They are not being merged because of
> > the constructor, not because they have a shrinker. hell, I even said
> > that if it comes down to it, we don't even need SLAB_NO_MERGE
> > because we can create dummy constructors to prevent merging....
> 
> Right. There is no chance here though. Its intentional to not merge slab
> where we could get into issues.

The dentry cache does not have a constructor:

       /* 
         * A constructor could be added for stable state like the lists,
         * but it is probably not worth it because of the cache nature
         * of the dcache. 
         */
        dentry_cache = KMEM_CACHE(dentry,
                SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD);

> Would be interested to see how performance changes if the inode/dentries
> would become mergeable.

On my machines the dentry slab  doesn't merge with any other slabs,
though, because there are no other slabs with the same size object.
That's one of the major crap shoots with slab merging that I want to
fix.


> > *Some* shrinkers act on mergable slabs because they have no
> > constructor. e.g. the xfs_dquot and xfs_buf shrinkers.  I want to
> > keep them separate just like the inode cache is kept separate
> > because they have workload based demand peaks in the millions of
> > objects and LRU based shrinker reclaim, just like inode caches do.
> 
> But then we are not sure why we would do that. Certainly merging can
> increases the stress on the per node locks for a slab cache as the example
> by Jesper shows (and this can be dealt with by increasing per cpu
> resources). On the other hand this also leads to rapid defragmentation
> because the free objects from partial pages produced by the frees of
> one of the merged slabs can get reused quickly for another purpose.

We can't control the freeing of objects from other merged slabs,
unless they are also actively managed by a shrinker. So that page is
pinned until the slab object is freed by whatever subsystem owns it,
and no amount of memory pressure can cause that to happen.

> > I really don't see the issue here - explicitly encoding and
> > documenting the behaviour we've implicitly been relying on for years
> > is something we do all the time. Code clarity and documented
> > behaviour is a *good thing*.
> 
> The question first has to be answered why keeping them separate is such a
> good thing without also having an explicit way of telling the allocator to
> keep certain objects in the same slab page if possible. Otherwise we get
> this randomizing effect that nullifies the idea that sequential
> freeing/allocation would avoid fragmentation.

I don't follow. Sequential alloc/free of objects from an unshared
slab does not alter fragmentation patterns of the slab. If it was
fragmented before the sequntial run, it will be fragmented after.

If you are talking about merging dentry/inode objects into the same
slab and doing sequential allocation of them, that just does not
work. the relationship between detries and inodes is an M:N
relationship, not a 1:1 relationship, so they will never have nice
neat aligned alloc/free patterns.

> I have in the past be in favor of adding such a flag to avoid merging but
> I am slowly getting to the point that this may not be wise anymore. There
> is too much arguing from gut reactions here and relying on assumptions
> about internal operations of slabs (thinking to be able to exploit the
> fact that linearly allocated objects come from the same slab page coming
> from you is one of these).

Wow. The only time I've ever mentioned that we could do some
interesting things if we knew certain objects were on the same
backing page was earlier this year at LCA when we were talking about
the design of the proposed batch allocation interface. You said that
it probably couldn't be guaranteed and so i haven't even thought
about that since.

That's not an argument for preventing us from saying "don't merge
this slab, we actively manage it's contents".

> Defragmentation IMHO requires a targeted approach were either objects that
> are in the way can be moved out of the way or there is some type of
> lifetime marker on objects that allows the memory allocators to know that
> these objects can be freed all at once when a certain operation is
> complete.

Which, if we know that there is only one type of object in the slab,
is relatively easy to do and can be controlled by the subsystem
shrinker.... :)

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
