Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id CE9506B0579
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 19:52:52 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id t139so324615711ywg.6
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 16:52:52 -0700 (PDT)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id p17si5360917ybd.419.2017.07.28.16.52.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 16:52:51 -0700 (PDT)
Received: by mail-yw0-x244.google.com with SMTP id u207so9183434ywc.0
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 16:52:51 -0700 (PDT)
Date: Fri, 28 Jul 2017 23:52:50 +0000
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 1/2] mm: use sc->priority for slab shrink targets
Message-ID: <20170728235248.GA27897@li70-116.members.linode.com>
References: <1500576331-31214-1-git-send-email-jbacik@fb.com>
 <1500576331-31214-2-git-send-email-jbacik@fb.com>
 <20170727165348.0e23487a9f98c359fbd5bfea@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727165348.0e23487a9f98c359fbd5bfea@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: josef@toxicpanda.com, minchan@kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@redhat.com, david@fromorbit.com, kernel-team@fb.com, Josef Bacik <jbacik@fb.com>

On Thu, Jul 27, 2017 at 04:53:48PM -0700, Andrew Morton wrote:
> On Thu, 20 Jul 2017 14:45:30 -0400 josef@toxicpanda.com wrote:
> 
> > From: Josef Bacik <jbacik@fb.com>
> > 
> > Previously we were using the ratio of the number of lru pages scanned to
> > the number of eligible lru pages to determine the number of slab objects
> > to scan.  The problem with this is that these two things have nothing to
> > do with each other,
> 
> "nothing"?
> 
> > so in slab heavy work loads where there is little to
> > no page cache we can end up with the pages scanned being a very low
> > number.
> 
> In this case the "number of eligible lru pages" will also be low, so
> these things do have something to do with each other?
> 

The problem is scanned doesn't correlate to the scanned count we calculate, but
rather the pages we're able to actually scan.  With almost no page cache we end
up with really low scanned counts to "relatively" high lru count, which makes
the ratio really really low.  Anecdotally we would have 10 million inodes in
cache, but the ratios were such that our scan target was like 8k.

> >  This means that we reclaim next to no slab pages and waste a
> > lot of time reclaiming small amounts of space.
> > 
> > Instead use sc->priority in the same way we use it to determine scan
> > amounts for the lru's.
> 
> That sounds like a good idea.
> 
> Alternatively did you consider hooking into the vmpressure code (or
> hannes's new memdelay code) to determine how hard to scan slab?
> 

Vmpressure requires memcg to be turned on.  As for memdelay that might be a good
direction in the future, but right now it's just per task.  We could probably
use it for direct reclaim, but I really want this to make kswapd better so we
avoid direct reclaim.  If it's expanded to be system wide so we could have an
idea of the effect of memory reclaim on the whole system that would tie in
nicely here.  But for now I think staying consistent with everything else is
good enough.  Thanks,

Josef

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
