Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id E3B7C6B04BF
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 10:49:28 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id p6so3855677ywh.8
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 07:49:28 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id e130si1103821ywc.458.2017.08.24.07.49.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 07:49:27 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id s3so2429060qkd.1
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 07:49:27 -0700 (PDT)
Date: Thu, 24 Aug 2017 10:49:25 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 1/2] mm: use sc->priority for slab shrink targets
Message-ID: <20170824144924.w3inhdnmgfscso7l@destiny>
References: <1503430539-2878-1-git-send-email-jbacik@fb.com>
 <a6a68b0b-4138-2563-fa53-ad8406dc6e34@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a6a68b0b-4138-2563-fa53-ad8406dc6e34@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: josef@toxicpanda.com, minchan@kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>

On Thu, Aug 24, 2017 at 05:29:59PM +0300, Andrey Ryabinin wrote:
> 
> 
> On 08/22/2017 10:35 PM, josef@toxicpanda.com wrote:
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -306,9 +306,7 @@ EXPORT_SYMBOL(unregister_shrinker);
> >  #define SHRINK_BATCH 128
> >  
> >  static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> > -				    struct shrinker *shrinker,
> > -				    unsigned long nr_scanned,
> > -				    unsigned long nr_eligible)
> > +				    struct shrinker *shrinker, int priority)
> >  {
> >  	unsigned long freed = 0;
> >  	unsigned long long delta;
> > @@ -333,9 +331,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
> >  	nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
> >  
> >  	total_scan = nr;
> > -	delta = (4 * nr_scanned) / shrinker->seeks;
> > -	delta *= freeable;
> > -	do_div(delta, nr_eligible + 1);
> > +	delta = freeable >> priority;
> > +	delta = (4 * freeable) / shrinker->seeks;
> 
> Something is wrong. The first line does nothing.
> 

Lol jesus, nice catch, I'll fix this up.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
