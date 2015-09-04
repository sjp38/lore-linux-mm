Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 641F46B0038
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 18:46:47 -0400 (EDT)
Received: by pacwi10 with SMTP id wi10so36491371pac.3
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 15:46:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ko10si6399885pbc.208.2015.09.04.15.46.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 15:46:46 -0700 (PDT)
Date: Sat, 5 Sep 2015 08:46:35 +1000
From: Dave Chinner <dchinner@redhat.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
Message-ID: <20150904224635.GA2562@devil.localdomain>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
 <20150903005115.GA27804@redhat.com>
 <CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
 <20150903060247.GV1933@devil.localdomain>
 <CA+55aFxftNVWVD7ujseqUDNgbVamrFWf0PVM+hPnrfmmACgE0Q@mail.gmail.com>
 <20150904032607.GX1933@devil.localdomain>
 <alpine.DEB.2.11.1509040849460.30848@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1509040849460.30848@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mike Snitzer <snitzer@redhat.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>

On Fri, Sep 04, 2015 at 08:55:25AM -0500, Christoph Lameter wrote:
> On Fri, 4 Sep 2015, Dave Chinner wrote:
> 
> > There are generic cases where it hurts, so no justification should
> > be needed for those cases...
> 
> Inodes and dentries have constructors. These slabs are not mergeable and
> will never be because they have cache specific code to be executed on the
> object.

I know - I said as much early on in this discussion. That's one of
the generic cases I'm refering to.

I also said that the fact that they are not merged is really by
chance, not by good management. They are not being merged because of
the constructor, not because they have a shrinker. hell, I even said
that if it comes down to it, we don't even need SLAB_NO_MERGE
because we can create dummy constructors to prevent merging....

> > Really, we don't need some stupidly high bar to jump over here -
> > whether merging should be allowed can easily be answered with a
> > simple question: "Does the slab have a shrinker or does it back a
> > mempool?" If the answer is yes then using SLAB_SHRINKER or
> > SLAB_MEMPOOL to trigger the no-merge case doesn't need any more
> > justification from subsystem maintainers at all.
> 
> The slab shrinkers do not use mergeable slab caches.

Please, go back and read what i've already said.

*Some* shrinkers act on mergable slabs because they have no
constructor. e.g. the xfs_dquot and xfs_buf shrinkers.  I want to
keep them separate just like the inode cache is kept separate
because they have workload based demand peaks in the millions of
objects and LRU based shrinker reclaim, just like inode caches do.

That's what I want SLAB_SHRINKER for - to explicitly tell the slab
cache creation that I have a shrinker on this slab and so it should
not merge it with others. Every slab that has a shrinker should be
marked with this flag - we should not be relying on constructors to
prevent merging of critical slab caches with shrinkers....

I really don't see the issue here - explicitly encoding and
documenting the behaviour we've implicitly been relying on for years
is something we do all the time. Code clarity and documented
behaviour is a *good thing*.

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
