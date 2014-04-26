Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id E82C26B0036
	for <linux-mm@kvack.org>; Sat, 26 Apr 2014 09:11:15 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id b57so3452022eek.35
        for <linux-mm@kvack.org>; Sat, 26 Apr 2014 06:11:15 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id x46si16629922eea.209.2014.04.26.06.11.13
        for <linux-mm@kvack.org>;
        Sat, 26 Apr 2014 06:11:13 -0700 (PDT)
Date: Sat, 26 Apr 2014 14:10:26 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH] mm: Throttle shrinkers harder
Message-ID: <20140426131026.GA4418@nuc-i3427.alporthouse.com>
References: <1397113506-9177-1-git-send-email-chris@chris-wilson.co.uk>
 <20140418121416.c022eca055da1b6d81b2cf1b@linux-foundation.org>
 <20140422193041.GD10722@phenom.ffwll.local>
 <53582D3C.1010509@intel.com>
 <20140424055836.GB31221@nuc-i3427.alporthouse.com>
 <53592C16.8000906@intel.com>
 <20140424153920.GM31221@nuc-i3427.alporthouse.com>
 <535991C3.9080808@intel.com>
 <20140425072325.GO31221@nuc-i3427.alporthouse.com>
 <535A9901.6090607@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <535A9901.6090607@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>

On Fri, Apr 25, 2014 at 10:18:57AM -0700, Dave Hansen wrote:
> On 04/25/2014 12:23 AM, Chris Wilson wrote:
> > On Thu, Apr 24, 2014 at 03:35:47PM -0700, Dave Hansen wrote:
> >> On 04/24/2014 08:39 AM, Chris Wilson wrote:
> >>> On Thu, Apr 24, 2014 at 08:21:58AM -0700, Dave Hansen wrote:
> >>>> Is it possible that there's still a get_page() reference that's holding
> >>>> those pages in place from the graphics code?
> >>>
> >>> Not from i915.ko. The last resort of our shrinker is to drop all page
> >>> refs held by the GPU, which is invoked if we are asked to free memory
> >>> and we have no inactive objects left.
> >>
> >> How sure are we that this was performed before the OOM?
> > 
> > Only by virtue of how shrink_slabs() works.
> 
> Could we try to raise the level of assurance there, please? :)
> 
> So this "last resort" is i915_gem_shrink_all()?  It seems like we might
> have some problems getting down to that part of the code if we have
> problems getting the mutex.

In general, but not in this example where the load is tightly controlled.
 
> We have tracepoints for the shrinkers in here (it says slab, but it's
> all the shrinkers, I checked):
> 
> /sys/kernel/debug/tracing/events/vmscan/mm_shrink_slab_*/enable
> and another for OOMs:
> /sys/kernel/debug/tracing/events/oom/enable
> 
> Could you collect a trace during one of these OOM events and see what
> the i915 shrinker is doing?  Just enable those two and then collect a
> copy of:
> 
> 	/sys/kernel/debug/tracing/trace
> 
> That'll give us some insight about how well the shrinker is working.  If
> the VM gave up on calling in to it, it might reveal why we didn't get
> all the way down in to i915_gem_shrink_all().

I'll add it to the list for QA to try.
 
> > Thanks for the pointer to
> > register_oom_notifier(), I can use that to make sure that we do purge
> > everything from the GPU, and do a sanity check at the same time, before
> > we start killing processes.
> 
> Actually, that one doesn't get called until we're *SURE* we are going to
> OOM.  Any action taken in there won't be taken in to account.

blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
if (freed > 0)
	/* Got some memory back in the last second. */
	return;

That looks like it should abort the oom and so repeat the allocation
attempt? Or is that too hopeful?

> >> Also, forgive me for being an idiot wrt the way graphics work, but are
> >> there any good candidates that you can think of that could be holding a
> >> reference?  I've honestly never seen an OOM like this.
> > 
> > Here the only place that we take a page reference is in
> > i915_gem_object_get_pages(). We do this when we first bind the pages
> > into the GPU's translation table, but we only release the pages once the
> > object is destroyed or the system experiences memory pressure. (Once the
> > GPU touches the pages, we no longer consider them to be cache coherent
> > with the CPU and so migrating them between the GPU and CPU requires
> > clflushing, which is expensive.)
> > 
> > Aside from CPU mmaps of the shmemfs filp, all operations on our
> > graphical objects should lead to i915_gem_object_get_pages(). However
> > not all objects are recoverable as some may be pinned due to hardware
> > access.
> 
> In that oom callback, could you dump out the aggregate number of
> obj->pages_pin_count across all the objects?  That would be a very
> interesting piece of information to have.  It would also be very
> insightful for folks who see OOMs in practice with i915 in their systems.

Indeed.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
