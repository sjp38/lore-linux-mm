Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 344516B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 19:20:30 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so9961778pad.30
        for <linux-mm@kvack.org>; Tue, 27 May 2014 16:20:29 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id ic8si21109845pad.95.2014.05.27.16.20.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 May 2014 16:20:29 -0700 (PDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so10012662pab.10
        for <linux-mm@kvack.org>; Tue, 27 May 2014 16:20:29 -0700 (PDT)
Date: Tue, 27 May 2014 16:19:12 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 0/3] Shrinkers and proportional reclaim
In-Reply-To: <CALYGNiPZXnTG+vxg5tr+jnaDSvHRArJq=fmQ4bPD-m-iJU9jqA@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1405271618360.5019@eggly.anvils>
References: <1400749779-24879-1-git-send-email-mgorman@suse.de> <alpine.LSU.2.11.1405261441320.7154@eggly.anvils> <20140527023751.GB8554@dastard> <alpine.LSU.2.11.1405271406520.4317@eggly.anvils>
 <CALYGNiPZXnTG+vxg5tr+jnaDSvHRArJq=fmQ4bPD-m-iJU9jqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Yuanhan Liu <yuanhan.liu@linux.intel.com>, Bob Liu <bob.liu@oracle.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Wed, 28 May 2014, Konstantin Khlebnikov wrote:
> On Wed, May 28, 2014 at 1:17 AM, Hugh Dickins <hughd@google.com> wrote:
> > On Tue, 27 May 2014, Dave Chinner wrote:
> >> On Mon, May 26, 2014 at 02:44:29PM -0700, Hugh Dickins wrote:
> >> >
> >> > [PATCH 4/3] fs/superblock: Avoid counting without __GFP_FS
> >> >
> >> > Don't waste time counting objects in super_cache_count() if no __GFP_FS:
> >> > super_cache_scan() would only back out with SHRINK_STOP in that case.
> >> >
> >> > Signed-off-by: Hugh Dickins <hughd@google.com>
> >>
> >> While you might think that's a good thing, it's not.  The act of
> >> shrinking is kept separate from the accounting of how much shrinking
> >> needs to take place.  The amount of work the shrinker can't do due
> >> to the reclaim context is deferred until the shrinker is called in a
> >> context where it can do work (eg. kswapd)
> >>
> >> Hence not accounting for work that can't be done immediately will
> >> adversely impact the balance of the system under memory intensive
> >> filesystem workloads. In these worklaods, almost all allocations are
> >> done in the GFP_NOFS or GFP_NOIO contexts so not deferring the work
> >> will will effectively stop superblock cache reclaim entirely....
> >
> > Thanks for filling me in on that.  At first I misunderstood you,
> > and went off looking in the wrong direction.  Now I see what you're
> > referring to: the quantity that shrink_slab_node() accumulates in
> > and withdraws from shrinker->nr_deferred[nid].
> 
> Maybe shrinker could accumulate fraction nr_pages_scanned / lru_pages
> instead of exact amount of required work? Count of shrinkable objects
> might be calculated later, when shrinker is called from a suitable context
> and can actualy do something.

Good idea, probably a worthwhile optimization to think through further.
(Though experience says that Dave will explain how that can never work.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
