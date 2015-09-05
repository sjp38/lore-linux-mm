Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id B603C6B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 20:25:50 -0400 (EDT)
Received: by qkdv1 with SMTP id v1so15315302qkd.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 17:25:50 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id 79si5013399qky.115.2015.09.04.17.25.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 04 Sep 2015 17:25:49 -0700 (PDT)
Date: Fri, 4 Sep 2015 19:25:48 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for
 4.3)
In-Reply-To: <20150904224635.GA2562@devil.localdomain>
Message-ID: <alpine.DEB.2.11.1509041914180.2797@east.gentwo.org>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com> <20150903005115.GA27804@redhat.com> <CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com> <20150903060247.GV1933@devil.localdomain>
 <CA+55aFxftNVWVD7ujseqUDNgbVamrFWf0PVM+hPnrfmmACgE0Q@mail.gmail.com> <20150904032607.GX1933@devil.localdomain> <alpine.DEB.2.11.1509040849460.30848@east.gentwo.org> <20150904224635.GA2562@devil.localdomain>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <dchinner@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mike Snitzer <snitzer@redhat.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>, Joe Thornber <ejt@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, Viresh Kumar <viresh.kumar@linaro.org>, Heinz Mauelshagen <heinzm@redhat.com>, linux-mm <linux-mm@kvack.org>

On Sat, 5 Sep 2015, Dave Chinner wrote:

> > Inodes and dentries have constructors. These slabs are not mergeable and
> > will never be because they have cache specific code to be executed on the
> > object.
>
> I also said that the fact that they are not merged is really by
> chance, not by good management. They are not being merged because of
> the constructor, not because they have a shrinker. hell, I even said
> that if it comes down to it, we don't even need SLAB_NO_MERGE
> because we can create dummy constructors to prevent merging....

Right. There is no chance here though. Its intentional to not merge slab
where we could get into issues.

Would be interested to see how performance changes if the inode/dentries
would become mergeable.

> *Some* shrinkers act on mergable slabs because they have no
> constructor. e.g. the xfs_dquot and xfs_buf shrinkers.  I want to
> keep them separate just like the inode cache is kept separate
> because they have workload based demand peaks in the millions of
> objects and LRU based shrinker reclaim, just like inode caches do.

But then we are not sure why we would do that. Certainly merging can
increases the stress on the per node locks for a slab cache as the example
by Jesper shows (and this can be dealt with by increasing per cpu
resources). On the other hand this also leads to rapid defragmentation
because the free objects from partial pages produced by the frees of
one of the merged slabs can get reused quickly for another purpose.

> I really don't see the issue here - explicitly encoding and
> documenting the behaviour we've implicitly been relying on for years
> is something we do all the time. Code clarity and documented
> behaviour is a *good thing*.

The question first has to be answered why keeping them separate is such a
good thing without also having an explicit way of telling the allocator to
keep certain objects in the same slab page if possible. Otherwise we get
this randomizing effect that nullifies the idea that sequential
freeing/allocation would avoid fragmentation.

I have in the past be in favor of adding such a flag to avoid merging but
I am slowly getting to the point that this may not be wise anymore. There
is too much arguing from gut reactions here and relying on assumptions
about internal operations of slabs (thinking to be able to exploit the
fact that linearly allocated objects come from the same slab page coming
from you is one of these).

Defragmentation IMHO requires a targeted approach were either objects that
are in the way can be moved out of the way or there is some type of
lifetime marker on objects that allows the memory allocators to know that
these objects can be freed all at once when a certain operation is
complete.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
