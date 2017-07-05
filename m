Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED4F6B0372
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 08:57:28 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id h47so112643356qta.12
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 05:57:28 -0700 (PDT)
Received: from mail-qt0-x232.google.com (mail-qt0-x232.google.com. [2607:f8b0:400d:c0d::232])
        by mx.google.com with ESMTPS id u64si19951135qka.284.2017.07.05.05.57.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 05:57:27 -0700 (PDT)
Received: by mail-qt0-x232.google.com with SMTP id 32so185288171qtv.1
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 05:57:27 -0700 (PDT)
Date: Wed, 5 Jul 2017 08:57:26 -0400
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 2/4][v2] vmscan: bailout of slab reclaim once we reach
 our target
Message-ID: <20170705125725.GA16179@destiny>
References: <1499171620-6746-1-git-send-email-jbacik@fb.com>
 <1499171620-6746-2-git-send-email-jbacik@fb.com>
 <20170705042704.GA20079@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170705042704.GA20079@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: josef@toxicpanda.com, akpm@linux-foundation.org, kernel-team@fb.com, linux-mm@kvack.org, hannes@cmpxchg.org, riel@redhat.com, Josef Bacik <jbacik@fb.com>

On Wed, Jul 05, 2017 at 01:27:04PM +0900, Minchan Kim wrote:
> On Tue, Jul 04, 2017 at 08:33:38AM -0400, josef@toxicpanda.com wrote:
> > From: Josef Bacik <jbacik@fb.com>
> > 
> > Following patches will greatly increase our aggressiveness in slab
> > reclaim, so we need checks in place to make sure we stop trying to
> > reclaim slab once we've hit our reclaim target.
> > 
> > Signed-off-by: Josef Bacik <jbacik@fb.com>
> > ---
> > v1->v2:
> > - Don't bail out in shrink_slab() so that we always scan at least batch_size
> >   objects of every slab regardless of wether we've hit our target or not.
> 
> It's no different with v1 for aging fairness POV.
> 
> Imagine you have 3 shrinkers in shrinker_list and A has a lots of objects.
> 
>         HEAD-> A -> B -> C
> 
> shrink_slab does scan/reclaims from A srhinker a lot until it meets
> sc->nr_to_reclaim. Then, VM does aging B and C with batch_size which is
> rather small. It breaks fairness.
> 
> In next memory pressure, it shrinks A a lot again but B and C
> a little bit.
> 

Oh duh yeah I see what you are saying.  I had a scheme previously to break up
the scanning targets based on overall usage but it meant looping through the
shrinkers twice, as we have to get a total count of objects first to determine
individual ratios.  I suppose since there's relatively low cost to getting
object counts per shrinker and there don't tend to be a lot of shrinkers we
could go with this to make it more fair.  I'll write this up.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
