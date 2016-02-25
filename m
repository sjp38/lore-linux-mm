Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id C613F6B0258
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 15:07:34 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id g62so46849089wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 12:07:34 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id in5si11609627wjb.155.2016.02.25.12.07.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 12:07:33 -0800 (PST)
Date: Thu, 25 Feb 2016 15:07:21 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm: scale kswapd watermarks in proportion to memory
Message-ID: <20160225200721.GB3370@cmpxchg.org>
References: <1456184002-15729-1-git-send-email-hannes@cmpxchg.org>
 <20160225003744.GC9723@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160225003744.GC9723@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Hi Joonsoo,

On Thu, Feb 25, 2016 at 09:37:44AM +0900, Joonsoo Kim wrote:
> On Mon, Feb 22, 2016 at 03:33:22PM -0800, Johannes Weiner wrote:
> > In machines with 140G of memory and enterprise flash storage, we have
> > seen read and write bursts routinely exceed the kswapd watermarks and
> > cause thundering herds in direct reclaim. Unfortunately, the only way
> > to tune kswapd aggressiveness is through adjusting min_free_kbytes -
> > the system's emergency reserves - which is entirely unrelated to the
> > system's latency requirements. In order to get kswapd to maintain a
> > 250M buffer of free memory, the emergency reserves need to be set to
> > 1G. That is a lot of memory wasted for no good reason.
> > 
> > On the other hand, it's reasonable to assume that allocation bursts
> > and overall allocation concurrency scale with memory capacity, so it
> > makes sense to make kswapd aggressiveness a function of that as well.
> > 
> > Change the kswapd watermark scale factor from the currently fixed 25%
> > of the tunable emergency reserve to a tunable 0.001% of memory.
> 
> s/0.001%/0.1%

Of course, you are right. Thanks for pointing it out.

Andrew, I'm attaching a drop-in replacement for what you have, since
it includes fixing the changelog. But it might be easier to edit the
patch for these two instances in place.

> > @@ -803,6 +803,24 @@ performance impact. Reclaim code needs to take various locks to find freeable
> >  directory and inode objects. With vfs_cache_pressure=1000, it will look for
> >  ten times more freeable objects than there are.
> >  
> > +=============================================================
> > +
> > +watermark_scale_factor:
> > +
> > +This factor controls the aggressiveness of kswapd. It defines the
> > +amount of memory left in a node/system before kswapd is woken up and
> > +how much memory needs to be free before kswapd goes back to sleep.
> > +
> > +The unit is in fractions of 10,000. The default value of 10 means the
> > +distances between watermarks are 0.001% of the available memory in the
> > +node/system. The maximum value is 1000, or 10% of memory.
> 
> Ditto for 0.001%.
