Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1535F6B0253
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 07:14:43 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k200so66179633lfg.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 04:14:43 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id gb1si25807200wjb.45.2016.04.15.04.14.41
        for <linux-mm@kvack.org>;
        Fri, 15 Apr 2016 04:14:41 -0700 (PDT)
Date: Fri, 15 Apr 2016 12:14:31 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH] mm/vmalloc: Keep a separate lazy-free list
Message-ID: <20160415111431.GL19990@nuc-i3427.alporthouse.com>
References: <1460444239-22475-1-git-send-email-chris@chris-wilson.co.uk>
 <CACZ9PQV+H+i11E-GEfFeMD3cXWXOF1yPGJH8j7BLXQVqFB3oGw@mail.gmail.com>
 <20160414134926.GD19990@nuc-i3427.alporthouse.com>
 <CACZ9PQXCHRC5bFqQKmtOv+GyuEmEaXDVPJdQhBt0sXPfomFTNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACZ9PQXCHRC5bFqQKmtOv+GyuEmEaXDVPJdQhBt0sXPfomFTNw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Peniaev <r.peniaev@gmail.com>
Cc: intel-gfx@lists.freedesktop.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Tvrtko Ursulin <tvrtko.ursulin@linux.intel.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Toshi Kani <toshi.kani@hp.com>, Shawn Lin <shawn.lin@rock-chips.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Apr 14, 2016 at 04:44:48PM +0200, Roman Peniaev wrote:
> On Thu, Apr 14, 2016 at 3:49 PM, Chris Wilson <chris@chris-wilson.co.uk> wrote:
> > On Thu, Apr 14, 2016 at 03:13:26PM +0200, Roman Peniaev wrote:
> >> Hi, Chris.
> >>
> >> Is it made on purpose not to drop VM_LAZY_FREE flag in
> >> __purge_vmap_area_lazy()?  With your patch va->flags
> >> will have two bits set: VM_LAZY_FREE | VM_LAZY_FREEING.
> >> Seems it is not that bad, because all other code paths
> >> do not care, but still the change is not clear.
> >
> > Oh, that was just a bad deletion.
> >
> >> Also, did you consider to avoid taking static purge_lock
> >> in __purge_vmap_area_lazy() ? Because, with your change
> >> it seems that you can avoid taking this lock at all.
> >> Just be careful when you observe llist as empty, i.e.
> >> nr == 0.
> >
> > I admit I only briefly looked at the lock. I will be honest and say I
> > do not fully understand the requirements of the sync/force_flush
> > parameters.
> 
> if sync:
>    o I can wait for other purge in progress
>       (do not care if purge_lock is dropped)
> 
>    o purge fragmented blocks
> 
> if force_flush:
>    o even nothing to purge, flush TLB, which is costly.
>     (again sync-like is implied)
> 
> > purge_fragmented_blocks() manages per-cpu lists, so that looks safe
> > under its own rcu_read_lock.
> >
> > Yes, it looks feasible to remove the purge_lock if we can relax sync.
> 
> what is still left is waiting on vmap_area_lock for !sync mode.
> but probably is not that bad.

Ok, that's bit beyond my comfort zone with a patch to change the free
list handling. I'll chicken out for the time being, atm I am more
concerned that i915.ko may call set_page_wb() frequently on individual
pages.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
