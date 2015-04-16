Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 336676B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 13:38:03 -0400 (EDT)
Received: by wizk4 with SMTP id k4so204074177wiz.1
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 10:38:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wz10si15069904wjc.143.2015.04.16.10.38.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Apr 2015 10:38:01 -0700 (PDT)
Date: Thu, 16 Apr 2015 18:37:56 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/14] Parallel memory initialisation
Message-ID: <20150416173756.GQ14842@suse.de>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
 <20150416002501.e9615db6.akpm@linux-foundation.org>
 <20150416084609.GM14842@suse.de>
 <20150416102635.951994a9e362693cbbc0b440@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150416102635.951994a9e362693cbbc0b440@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Apr 16, 2015 at 10:26:35AM -0700, Andrew Morton wrote:
> On Thu, 16 Apr 2015 09:46:09 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Thu, Apr 16, 2015 at 12:25:01AM -0700, Andrew Morton wrote:
> > > On Mon, 13 Apr 2015 11:16:52 +0100 Mel Gorman <mgorman@suse.de> wrote:
> > > 
> > > > Memory initialisation
> > > 
> > > I wish we didn't call this "memory initialization".  Because memory
> > > initialization is memset(), and that isn't what we're doing here.
> > > 
> > > Installation?  Bringup?
> > > 
> > 
> > It's about linking the struct pages to their physical page frame so
> > "Parallel struct page initialisation"?
> 
> Works for me.
> 
> > > I'd hoped the way we were
> > > going to do this was by bringing up a bit of memory to get booted up,
> > > then later on we just fake a bunch of memory hot-add operations.  So
> > > the new code would be pretty small and quite high-level.
> > 
> > That ends up being very complex but of a very different shape. We would
> > still have to prevent the sections being initialised similar to what this
> > series does already except the zone boundaries are lower. It's not as
> > simple as faking mem= because we want local memory on each node during
> > initialisation.
> 
> Why do "we want..."?
> 

Speed mostly. The memaps are local to a node so if this is going to be
parallelised then it makes sense to use local CPUs. It's why I used
kswapd to do the initialisation -- it's close to the struct pages being
initialised.

> > Later after device_init when sysfs is setup we would then have to walk all
> > possible sections to discover pluggable memory and hot-add them. However,
> > when doing it, we would want to first discover what node that section is
> > local to and ideally skip over the ones that are not local to the thread
> > doing the work. This means all threads have to scan all sections instead
> > of this approach which can walk within its own PFN. It then adds pages
> > one at a time which is slow although obviously that part could be addressed.
> > 
> > This would be harder to co-ordinate as kswapd is up and running before
> > the memory hot-add structures are finalised so it would need either a
> > semaphore or different threads to do the initialisation. The user-visible
> > impact is then that early in boot, the total amount of memory appears to
> > be rapidly increasing instead of this approach where the amount of free
> > memory is increasing.
> > 
> > Conceptually it's straight forward but the details end up being a lot
> > more complex than this approach.
> 
> Could we do most of the think work in userspace, emit a bunch of
> low-level hotplug operations to the kernel?
> 

That makes me wince at lot. The kernel would be depending on userspace
to correctly capture the event and write to the correct sysfs files. We'd
either have to declare a new event or fake an ACPI hotplug event and cross
our fingers that ACPI hotplug is setup correctly and that userspace does
the right thing. There is no guarantee userspace has any clue and it
certainly does not end up being simplier than this series.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
