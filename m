Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id AA5AC6B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 04:53:27 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so41253154pac.2
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 01:53:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bx12si40348267pdb.198.2015.09.03.01.53.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 01:53:26 -0700 (PDT)
Date: Thu, 3 Sep 2015 18:53:14 +1000
From: Dave Chinner <dchinner@redhat.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for 4.3)
Message-ID: <20150903085314.GW1933@devil.localdomain>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com>
 <20150903005115.GA27804@redhat.com>
 <CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com>
 <20150903023125.GC27804@redhat.com>
 <alpine.DEB.2.11.1509022152470.18064@east.gentwo.org>
 <20150902215512.9d0d62e74fa2f0a460a42af9@linux-foundation.org>
 <CAOJsxLGa9fLWUrdjnm-A-Frxr1bzBvfNZRsmFFcjQSvGX48a4w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOJsxLGa9fLWUrdjnm-A-Frxr1bzBvfNZRsmFFcjQSvGX48a4w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Mike Snitzer <snitzer@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Heinz Mauelshagen <heinzm@redhat.com>, Viresh Kumar <viresh.kumar@linaro.org>, Joe Thornber <ejt@redhat.com>, linux-mm <linux-mm@kvack.org>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alasdair G Kergon <agk@redhat.com>

On Thu, Sep 03, 2015 at 09:09:24AM +0300, Pekka Enberg wrote:
> Hi Andrew,
> 
> On Wed, 2 Sep 2015 22:10:12 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:
> >> > But I'd still like some pointers/help on what makes slab merging so
> >> > beneficial.  I'm sure Christoph and others have justification.  But if
> >> > not then yes the default to slab merging probably should be revisited.
> >>
> >> ...
> >>
> >> Check out the linux-mm archives for these dissussions.
> 
> On Thu, Sep 3, 2015 at 7:55 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > Somewhat OT, but...  The question Mike asks should be comprehensively
> > answered right there in the switch-to-merging patch's changelog.
> >
> > The fact that it is not answered in the appropriate place and that
> > we're reduced to vaguely waving at the list archives is a fail.  And a
> > lesson!
> 
> Slab merging is a technique to reduce memory footprint and memory
> fragmentation. Joonsoo reports 3% slab memory reduction after boot
> when he added the feature to SLAB:

I'm not sure whether you are trying to indicate that it was
justified inteh commit message or indicate how little justification
there was...

> commit 12220dea07f1ac6ac717707104773d771c3f3077
> Author: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date:   Thu Oct 9 15:26:24 2014 -0700
> 
>     mm/slab: support slab merge
> 
>     Slab merge is good feature to reduce fragmentation.  If new creating slab
>     have similar size and property with exsitent slab, this feature reuse it
>     rather than creating new one.  As a result, objects are packed into fewer
>     slabs so that fragmentation is reduced.

A partial page or two in a newly allocated slab in not
"fragmentation". They are simply free objects in the cache that
haven't been allocated yet. Fragmentation occurs when large numbers
of objects are freed so the pages end up mostly empty but
cannot be freed because there is still 1 or 2 objects in use of
them. As such, if there was fragementation and slab merging fixed
it, I'd expect to be seeing a much larger reduction in memory
usage....

>     Below is result of my testing.
> 
>     * After boot, sleep 20; cat /proc/meminfo | grep Slab
> 
>     <Before>
>     Slab: 25136 kB
> 
>     <After>
>     Slab: 24364 kB
> 
>     We can save 3% memory used by slab.

The numbers don't support the conclusion. Memory used from boot to
boot always varies by a small amount - a slight difference in the
number of files accessed by the boot process can account for this.
Also, you can't 't measure slab fragmentation by measuring the
amount of memory used. You have to look at object counts in each
slab and work out the percentage of free vs allocated objects. So
there's no evidence that this 772kb difference in memory footprint
can even be attributed to slab merging.

What about the rest of the slab fragmentation problem space?  It's
not even mentioned in the commit, but that's really what is
important to long running machines.

IOWs, where's description of the problem that needs fixing? What's
the example workload that demonstrates the problem? What's the
before and after measurements of the workloads that generate
significant slab fragmentation?  What's the long term impact of the
change (e.g.  a busy server with a uptime of several weeks)? is the
fragmentation level reduced?  increased? not significant?  What
impact does this have on subsystems with shrinkers that are now
operating on shared slabs? Do the shrinkers still work as
effectively as they used to?  Do they now cause slab fragmentation,
and if they do, does it self correct under continued memory
pressure?

And with the patch being merged without a single reviewed-by or
acked-by, I'm sitting here wondering how we managed to fail software
engineering 101 so badly here?

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
