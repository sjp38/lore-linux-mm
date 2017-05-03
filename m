Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 95CB86B02EE
	for <linux-mm@kvack.org>; Wed,  3 May 2017 14:38:18 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f53so44326619qte.15
        for <linux-mm@kvack.org>; Wed, 03 May 2017 11:38:18 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id 34si19565686qtg.309.2017.05.03.11.38.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 May 2017 11:38:17 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id o4so4081754qkb.3
        for <linux-mm@kvack.org>; Wed, 03 May 2017 11:38:17 -0700 (PDT)
Date: Wed, 3 May 2017 14:38:15 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH][RFC] mm: make kswapd try harder to keep active pages in
 cache
Message-ID: <20170503183814.GA11572@destiny>
References: <1493760444-18250-1-git-send-email-jbacik@fb.com>
 <1493835888.20270.4.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1493835888.20270.4.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Josef Bacik <josef@toxicpanda.com>, linux-mm@kvack.org, hannes@cmpxchg.org, kernel-team@fb.com

On Wed, May 03, 2017 at 02:24:48PM -0400, Rik van Riel wrote:
> On Tue, 2017-05-02 at 17:27 -0400, Josef Bacik wrote:
> 
> > +	/*
> > +	 * If we don't have a lot of inactive or slab pages then
> > there's no
> > +	 * point in trying to free them exclusively, do the normal
> > scan stuff.
> > +	 */
> > +	if (nr_inactive < total_high_wmark && nr_slab <
> > total_high_wmark)
> > +		sc->inactive_only = 0;
> 
> This part looks good. Below this point, there is obviously no
> point in skipping the active list.
> 
> > +	if (!global_reclaim(sc))
> > +		sc->inactive_only = 0;
> 
> Why the different behaviour with and without cgroups?
> 
> Have you tested both of these?
> 

Huh oops I thought I deleted that, sorry I'll kill that part.

> > +	/*
> > +	 * We still want to slightly prefer slab over inactive, so
> > if inactive
> > +	 * is large enough just skip slab shrinking for now.  If we
> > aren't able
> > +	 * to reclaim enough exclusively from the inactive lists
> > then we'll
> > +	 * reset this on the first loop and dip into slab.
> > +	 */
> > +	if (nr_inactive > total_high_wmark && nr_inactive > nr_slab)
> > +		skip_slab = true;
> 
> I worry that this may be a little too aggressive,
> and result in the slab cache growing much larger
> than it should be on some systems.
> 
> I wonder if it may make more sense to have the
> aggressiveness of slab scanning depend on the
> ratio of inactive to reclaimable slab pages, rather
> than having a hard cut-off like this?
>  

So I originally had a thing that kept track of the rate of change of inactive vs
slab between kswapd runs, but this worked fine so I figured simpler was better.
Keep in mind that we only skip slab the first loop through, so if we fail to
free enough on the inactive list the first time through then we start evicting
slab as well.  The idea is (and my testing bore this out) that with the new size
ratio way of shrinking slab we would sometimes be over zealous and evict slab
that we were actively using, even though we had reclaimed plenty of pages from
our inactive list to satisfy our sc->nr_to_reclaim.

I could probably change the ratio in the sc->inactive_only case to be based on
the slab to inactive ratio and see how that turns out, I'll get that wired up
and let you know how it goes.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
