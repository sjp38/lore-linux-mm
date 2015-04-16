Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 439BC6B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 04:46:34 -0400 (EDT)
Received: by wgso17 with SMTP id o17so73058467wgs.1
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 01:46:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w9si14659847wif.30.2015.04.16.01.46.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Apr 2015 01:46:32 -0700 (PDT)
Date: Thu, 16 Apr 2015 09:46:09 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/14] Parallel memory initialisation
Message-ID: <20150416084609.GM14842@suse.de>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
 <20150416002501.e9615db6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150416002501.e9615db6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Apr 16, 2015 at 12:25:01AM -0700, Andrew Morton wrote:
> On Mon, 13 Apr 2015 11:16:52 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > Memory initialisation
> 
> I wish we didn't call this "memory initialization".  Because memory
> initialization is memset(), and that isn't what we're doing here.
> 
> Installation?  Bringup?
> 

It's about linking the struct pages to their physical page frame so
"Parallel struct page initialisation"?

> > had been identified as one of the reasons why large
> > machines take a long time to boot. Patches were posted a long time ago
> > that attempted to move deferred initialisation into the page allocator
> > paths. This was rejected on the grounds it should not be necessary to hurt
> > the fast paths to parallelise initialisation. This series reuses much of
> > the work from that time but defers the initialisation of memory to kswapd
> > so that one thread per node initialises memory local to that node. The
> > issue is that on the machines I tested with, memory initialisation was not
> > a major contributor to boot times. I'm posting the RFC to both review the
> > series and see if it actually helps users of very large machines.
> > 
> > ...
> >
> >  15 files changed, 507 insertions(+), 98 deletions(-)
> 
> Sadface at how large and complex this is. 

The vast bulk of the complexity is in one patch "mm: meminit: Initialise
remaining memory in parallel with kswapd" which is

 mm/internal.h   |   6 +++++
 mm/mm_init.c    |   1 +
 mm/page_alloc.c | 116 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 mm/vmscan.c     |   6 +++--
 4 files changed, 123 insertions(+), 6 deletions(-)

Most of that is a fairly straight-forward walk through zones and pfns with
bounds checking. A lot of the rest of the complexity is helpers which are
very similar to existing helpers (but not suitable for sharing code) and
optimisations. The optimisations in later patches cut the parallel struct
page initialisation time by 80%.

> I'd hoped the way we were
> going to do this was by bringing up a bit of memory to get booted up,
> then later on we just fake a bunch of memory hot-add operations.  So
> the new code would be pretty small and quite high-level.

That ends up being very complex but of a very different shape. We would
still have to prevent the sections being initialised similar to what this
series does already except the zone boundaries are lower. It's not as
simple as faking mem= because we want local memory on each node during
initialisation.

Later after device_init when sysfs is setup we would then have to walk all
possible sections to discover pluggable memory and hot-add them. However,
when doing it, we would want to first discover what node that section is
local to and ideally skip over the ones that are not local to the thread
doing the work. This means all threads have to scan all sections instead
of this approach which can walk within its own PFN. It then adds pages
one at a time which is slow although obviously that part could be addressed.

This would be harder to co-ordinate as kswapd is up and running before
the memory hot-add structures are finalised so it would need either a
semaphore or different threads to do the initialisation. The user-visible
impact is then that early in boot, the total amount of memory appears to
be rapidly increasing instead of this approach where the amount of free
memory is increasing.

Conceptually it's straight forward but the details end up being a lot
more complex than this approach.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
