Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 070856B0266
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:14:05 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id m6so618901wrf.1
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 06:14:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x4si1881770edd.371.2017.11.29.06.13.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Nov 2017 06:13:55 -0800 (PST)
Date: Wed, 29 Nov 2017 14:13:52 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm, compaction: direct freepage allocation for async
 direct compaction
Message-ID: <20171129141352.rguu6fgjll6bxrsh@suse.de>
References: <20171122143321.29501-1-hannes@cmpxchg.org>
 <20171123140843.is7cqatrdijkjqql@suse.de>
 <20171129063208.GC8125@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171129063208.GC8125@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Nov 29, 2017 at 03:32:08PM +0900, Joonsoo Kim wrote:
> On Thu, Nov 23, 2017 at 02:08:43PM +0000, Mel Gorman wrote:
> 
> > 3. Another reason a linear scanner was used was because we wanted to
> >    clear entire pageblocks we were migrating from and pack the target
> >    pageblocks as much as possible. This was to reduce the amount of
> >    migration required overall even though the scanning hurts. This patch
> >    takes MIGRATE_MOVABLE pages from anywhere that is "not this pageblock".
> >    Those potentially have to be moved again and again trying to randomly
> >    fill a MIGRATE_MOVABLE block. Have you considered using the freelists
> >    as a hint? i.e. take a page from the freelist, then isolate all free
> >    pages in the same pageblock as migration targets? That would preserve
> >    the "packing property" of the linear scanner.
> > 
> >    This would increase the amount of scanning but that *might* be offset by
> >    the number of migrations the workload does overall. Note that migrations
> >    potentially are minor faults so if we do too many migrations, your
> >    workload may suffer.
> > 
> > 4. One problem the linear scanner avoids is that a migration target is
> >    subsequently used as a migration source and leads to a ping-pong effect.
> >    I don't know how bad this is in practice or even if it's a problem at
> >    all but it was a concern at the time
> 
> IIUC, this potential advantage for a linear scanner would not be the
> actual advantage in the *running* system.
> 
> Consider about following worst case scenario for "direct freepage
> allocation" that "moved again" happens.
> 

The immediate case should be ok as long as the migration source and the
pageblock a freepage is taken from is not the same pageblock. That might
mean that more pages from the freelist would need to be examined until
another pageblock was found.

> 
> So, I think that "direct freepage allocation" doesn't suffer from such
> a ping-poing effect. Am I missing something?
> 

The ping-pong effect I'm concerned with is that a previous migration
target is used as a migration source in the future. It's hard for that
situation to occur with two linear scanners but care is needed when
using direct freepage allocation.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
