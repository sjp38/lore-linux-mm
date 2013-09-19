Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 296556B0031
	for <linux-mm@kvack.org>; Thu, 19 Sep 2013 02:57:07 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so9297117pad.14
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 23:57:06 -0700 (PDT)
Received: by mail-ie0-f182.google.com with SMTP id aq17so14718742iec.13
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 23:57:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130918203822.GA4330@dastard>
References: <1379495401-18279-1-git-send-email-daniel.vetter@ffwll.ch>
	<5239829F.4080601@t-online.de>
	<20130918203822.GA4330@dastard>
Date: Thu, 19 Sep 2013 08:57:04 +0200
Message-ID: <CAKMK7uGR7HtMLgu2-tvfTm+W=_gndVJ7QPcf0okFcKX6Htd61Q@mail.gmail.com>
Subject: Re: [Intel-gfx] [PATCH] [RFC] mm/shrinker: Add a shrinker flag to
 always shrink a bit
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Knut Petersen <Knut_Petersen@t-online.de>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, DRI Development <dri-devel@lists.freedesktop.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, Sep 18, 2013 at 10:38 PM, Dave Chinner <david@fromorbit.com> wrote:
> No, that's wrong. ->count_objects should never ass SHRINK_STOP.
> Indeed, it should always return a count of objects in the cache,
> regardless of the context.
>
> SHRINK_STOP is for ->scan_objects to tell the shrinker it can make
> any progress due to the context it is called in. This allows the
> shirnker to defer the work to another call in a different context.
> However, if ->count-objects doesn't return a count, the work that
> was supposed to be done cannot be deferred, and that is what
> ->count_objects should always return the number of objects in the
> cache.

So we should rework the locking in the drm/i915 shrinker to be able to
always count objects? Thus far no one screamed yet that we're not
really able to do that in all call contexts ...

So should I revert 81e49f or will the early return 0; completely upset
the core shrinker logic?
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
