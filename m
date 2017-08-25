Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8F74844088B
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 21:43:37 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q68so4319687pgq.11
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 18:43:37 -0700 (PDT)
Received: from ipmail01.adl2.internode.on.net (ipmail01.adl2.internode.on.net. [150.101.137.133])
        by mx.google.com with ESMTP id u5si3979318plm.505.2017.08.24.18.43.33
        for <linux-mm@kvack.org>;
        Thu, 24 Aug 2017 18:43:35 -0700 (PDT)
Date: Fri, 25 Aug 2017 11:40:09 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/2] mm: use sc->priority for slab shrink targets
Message-ID: <20170825014009.GL21024@dastard>
References: <1503430539-2878-1-git-send-email-jbacik@fb.com>
 <a6a68b0b-4138-2563-fa53-ad8406dc6e34@virtuozzo.com>
 <20170824144924.w3inhdnmgfscso7l@destiny>
 <20170824221559.GF21024@dastard>
 <20170824224544.3yrsl36u536fgkhc@destiny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170824224544.3yrsl36u536fgkhc@destiny>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, minchan@kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>

On Thu, Aug 24, 2017 at 06:45:46PM -0400, Josef Bacik wrote:
> On Fri, Aug 25, 2017 at 08:15:59AM +1000, Dave Chinner wrote:
> > On Thu, Aug 24, 2017 at 10:49:25AM -0400, Josef Bacik wrote:
> > > On Thu, Aug 24, 2017 at 05:29:59PM +0300, Andrey Ryabinin wrote:
> > > > 
> > > > 
> > > > On 08/22/2017 10:35 PM, josef@toxicpanda.com wrote:
> > > > > --- a/mm/vmscan.c
> > > > > +++ b/mm/vmscan.c
> > > > > @@ -306,9 +306,7 @@ EXPORT_SYMBOL(unregister_shrinker);
> > > > >  #define SHRINK_BATCH 128
> > > > >  
> > > > >  static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> > > > > -				    struct shrinker *shrinker,
> > > > > -				    unsigned long nr_scanned,
> > > > > -				    unsigned long nr_eligible)
> > > > > +				    struct shrinker *shrinker, int priority)
> > > > >  {
> > > > >  	unsigned long freed = 0;
> > > > >  	unsigned long long delta;
> > > > > @@ -333,9 +331,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> > > > >  	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
> > > > >  
> > > > >  	total_scan = nr;
> > > > > -	delta = (4 * nr_scanned) / shrinker->seeks;
> > > > > -	delta *= freeable;
> > > > > -	do_div(delta, nr_eligible + 1);
> > > > > +	delta = freeable >> priority;
> > > > > +	delta = (4 * freeable) / shrinker->seeks;
> > > > 
> > > > Something is wrong. The first line does nothing.
> > > > 
> > > 
> > > Lol jesus, nice catch, I'll fix this up.  Thanks,
> > 
> > Josef, this bug has been in every patch you've sent. What does
> > fixing it do to the behaviour of the algorithm now? It's going to
> > change it, for sure, so can you run all your behavioural
> > characterisation tests and let us know what the difference between
> > the broken and fixed patches are?
> 
> The bug made it so we were way more agressive with slab reclaim than we should
> be.  My second patch masked this with the inactive/slab diff stuff, but I've
> dropped that patch since its controversial and I don't really care to argue
> about it anymore.  This patch still fixes the issue of us not reclaiming enough
> in slab mostly workloads, I ran my fs_mark test before I sent out the new
> version to verify there still isn't the huge drop in performance once reclaim
> kicks in.  Without any changes we reclaimed basically no slab, with the bug in
> place (without my second patch) we reclaimed all of the slab in one go, and with
> the fixed patch we reclaim a proportional amount each time we enter the
> shrinker.  Thanks,

Cool, thanks for verifying it works as intended now, Josef. :P

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
