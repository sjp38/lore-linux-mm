Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 989EC6B0035
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 03:24:07 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so2478072eek.17
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 00:24:06 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id n7si11840055eeu.229.2014.04.25.00.24.05
        for <linux-mm@kvack.org>;
        Fri, 25 Apr 2014 00:24:05 -0700 (PDT)
Date: Fri, 25 Apr 2014 08:23:25 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH] mm: Throttle shrinkers harder
Message-ID: <20140425072325.GO31221@nuc-i3427.alporthouse.com>
References: <1397113506-9177-1-git-send-email-chris@chris-wilson.co.uk>
 <20140418121416.c022eca055da1b6d81b2cf1b@linux-foundation.org>
 <20140422193041.GD10722@phenom.ffwll.local>
 <53582D3C.1010509@intel.com>
 <20140424055836.GB31221@nuc-i3427.alporthouse.com>
 <53592C16.8000906@intel.com>
 <20140424153920.GM31221@nuc-i3427.alporthouse.com>
 <535991C3.9080808@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <535991C3.9080808@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>

On Thu, Apr 24, 2014 at 03:35:47PM -0700, Dave Hansen wrote:
> On 04/24/2014 08:39 AM, Chris Wilson wrote:
> > On Thu, Apr 24, 2014 at 08:21:58AM -0700, Dave Hansen wrote:
> >> Is it possible that there's still a get_page() reference that's holding
> >> those pages in place from the graphics code?
> > 
> > Not from i915.ko. The last resort of our shrinker is to drop all page
> > refs held by the GPU, which is invoked if we are asked to free memory
> > and we have no inactive objects left.
> 
> How sure are we that this was performed before the OOM?

Only by virtue of how shrink_slabs() works. Thanks for the pointer to
register_oom_notifier(), I can use that to make sure that we do purge
everything from the GPU, and do a sanity check at the same time, before
we start killing processes.
 
> Also, forgive me for being an idiot wrt the way graphics work, but are
> there any good candidates that you can think of that could be holding a
> reference?  I've honestly never seen an OOM like this.

Here the only place that we take a page reference is in
i915_gem_object_get_pages(). We do this when we first bind the pages
into the GPU's translation table, but we only release the pages once the
object is destroyed or the system experiences memory pressure. (Once the
GPU touches the pages, we no longer consider them to be cache coherent
with the CPU and so migrating them between the GPU and CPU requires
clflushing, which is expensive.)

Aside from CPU mmaps of the shmemfs filp, all operations on our
graphical objects should lead to i915_gem_object_get_pages(). However
not all objects are recoverable as some may be pinned due to hardware
access.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
