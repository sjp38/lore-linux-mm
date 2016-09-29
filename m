Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 50DCB6B0253
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 12:14:15 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w84so79072833wmg.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 09:14:15 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id c2si15409158wjd.229.2016.09.29.09.14.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 09:14:13 -0700 (PDT)
Date: Thu, 29 Sep 2016 12:14:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Regression in mobility grouping?
Message-ID: <20160929161402.GA29091@cmpxchg.org>
References: <20160928014148.GA21007@cmpxchg.org>
 <8c3b7dd8-ef6f-6666-2f60-8168d41202cf@suse.cz>
 <20160928153925.GA24966@cmpxchg.org>
 <20160929022540.GA30883@cmpxchg.org>
 <20160929061433.GF29250@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160929061433.GF29250@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Sep 29, 2016 at 03:14:33PM +0900, Joonsoo Kim wrote:
> On Wed, Sep 28, 2016 at 10:25:40PM -0400, Johannes Weiner wrote:
> > On Wed, Sep 28, 2016 at 11:39:25AM -0400, Johannes Weiner wrote:
> > > On Wed, Sep 28, 2016 at 11:00:15AM +0200, Vlastimil Babka wrote:
> > > > I guess testing revert of 9c0415e could give us some idea. Commit
> > > > 3a1086f shouldn't result in pageblock marking differences and as I said
> > > > above, 99592d5 should be just restoring to what 3.10 did.
> > > 
> > > I can give this a shot, but note that this commit makes only unmovable
> > > stealing more aggressive. We see reclaimable blocks up as well.
> > 
> > Quick update, I reverted back to stealing eagerly only on behalf of
> > MIGRATE_RECLAIMABLE allocations in a 4.6 kernel:
> 
> Hello, Johannes.
> 
> I think that it would be better to check 3.10 with above patches.
> Fragmentation depends on not only policy itself but also
> allocation/free pattern. There might be a large probability that
> allocation/free pattern is changed in this large kernel version
> difference.

You mean backport suspicious patches to 3.10 until I can reproduce it
there? I'm not sure. You're correct, the patterns very likely *have*
changed. But that alone cannot explain mobility grouping breaking that
badly. There is a reproducable bad behavior. It should be easier to
track down than to try to recreate it in the last-known-good kernel.

> > This is an UNMOVABLE order-3 allocation falling back to RECLAIMABLE.
> > According to can_steal_fallback(), this allocation shouldn't steal the
> > pageblock, yet change_ownership=1 indicates the block is UNMOVABLE.
> > 
> > Who converted it? I wonder if there is a bug in ownership management,
> > and there was an UNMOVABLE block on the RECLAIMABLE freelist from the
> > beginning. AFAICS we never validate list/mt consistency anywhere.
> 
> According to my code review, it would be possible. When stealing
> happens, we moved those buddy pages to current requested migratetype
> buddy list. If the other migratetype allocation request comes and
> stealing from the buddy list of previous requested migratetype
> happens, change_ownership will show '1' even if there is no ownership
> changing.

These two paths should exclude each other through the zone->lock, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
