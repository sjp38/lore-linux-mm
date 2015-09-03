Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f181.google.com (mail-io0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id B31ED6B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 23:10:16 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so43357487ioi.2
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 20:10:16 -0700 (PDT)
Received: from resqmta-po-09v.sys.comcast.net (resqmta-po-09v.sys.comcast.net. [2001:558:fe16:19:96:114:154:168])
        by mx.google.com with ESMTPS id q76si9064983ioe.102.2015.09.02.20.10.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 02 Sep 2015 20:10:15 -0700 (PDT)
Date: Wed, 2 Sep 2015 22:10:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slab-nomerge (was Re: [git pull] device mapper changes for
 4.3)
In-Reply-To: <20150903023125.GC27804@redhat.com>
Message-ID: <alpine.DEB.2.11.1509022152470.18064@east.gentwo.org>
References: <CA+55aFyepmdpbg9U2Pvp+aHjKmmGCrTK2ywzqfmaOTMXQasYNw@mail.gmail.com> <20150903005115.GA27804@redhat.com> <CA+55aFxpH6-XD97dOsuGvwozyV=28eBsxiKS901h8PFZrxaygw@mail.gmail.com> <20150903023125.GC27804@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Heinz Mauelshagen <heinzm@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Viresh Kumar <viresh.kumar@linaro.org>, Dave Chinner <dchinner@redhat.com>, Joe Thornber <ejt@redhat.com>, Pekka Enberg <penberg@kernel.org>, linux-mm <linux-mm@kvack.org>, "dm-devel@redhat.com" <dm-devel@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Vivek Goyal <vgoyal@redhat.com>, Sami Tolvanen <samitolvanen@google.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alasdair G Kergon <agk@redhat.com>

On Wed, 2 Sep 2015, Mike Snitzer wrote:

> You're also coming at this from a position that shared slabs are
> automatically good because they have been around for years.
>
> For those years I've not had a need to debug a leak in code I maintain;
> so I didn't notice slabs were merged.  I also haven't observed slab
> corruption being the cause of crashes in DM, block or SCSI.

Hmmm... Thats unusual. I have seen numerous leaks and corruptions that
were debugged using the additional debug code in the slab allocators.
Merging and debugging can be switched on at runtime if necessary and then
you will have a clear separation to be able to track down the offending
code as well as detailed problem reports that help to figure out what was
wrong. It is then typically even possible to fix these bugs without
getting the subsystem specialists involved.

> > Because clearly, that lack of statistics and the possible
> > cross-subsystem corruption hasn't actually been a pressing concern in
> > reality.
>
> Agreed.

To the effect now that even SLAB has adopted cache merging.

> But I'd still like some pointers/help on what makes slab merging so
> beneficial.  I'm sure Christoph and others have justification.  But if
> not then yes the default to slab merging probably should be revisited.

Well, we have discussed the pros and cons for merging a couple of times
but the general consensus was that it is beneficial. Performance on modern
cpu is very sensitive to cache footprint and reducing the overhead of meta
data for object allocation is a worthwhile goal. Also objects are more
likely to be kept cache hot if they can be used by multiple subsystems.
Slab merging also helps with reducing fragmentation since the free
objects on one page can be used for other purposes.

Check out the linux-mm archives for these dissussions.

This has been such an advantage that the feature was ported to SLAB (to
much more signficant effect than SLUB since SLAB is a pig with metadata
per node, per cpu and per kmem_cache). And yes sorry the consequence is
now that you do no longer have a choice. Both slab allocators default to
merging. SLAB had some difficulty staying competitive in performance
without that. Joonsoo Kim made SLAB more competitive last year and one of
the optimizations was to also support merging.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
