Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id C2BA16B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 10:04:49 -0500 (EST)
Received: by wiwl15 with SMTP id l15so31528685wiw.5
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 07:04:49 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id qc4si8946913wic.21.2015.03.04.07.04.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 07:04:48 -0800 (PST)
Date: Wed, 4 Mar 2015 10:04:36 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150304150436.GA16442@phnom.home.cmpxchg.org>
References: <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150222172930.6586516d.akpm@linux-foundation.org>
 <20150223073235.GT4251@dastard>
 <20150302202228.GA15089@phnom.home.cmpxchg.org>
 <20150302231206.GK18360@dastard>
 <20150303025023.GA22453@phnom.home.cmpxchg.org>
 <20150304065242.GR18360@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150304065242.GR18360@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Wed, Mar 04, 2015 at 05:52:42PM +1100, Dave Chinner wrote:
> I suspect you've completely misunderstood what I've been suggesting.
> 
> By definition, we have the pages we reserved in the reserve pool,
> and unless we've exhausted that reservation with permanent
> allocations we should always be able to allocate from it. If the
> pool got emptied by demand page allocations, then we back off and
> retry reclaim until the reclaimable objects are released back into
> the reserve pool. i.e. reclaim fills reserve pools first, then when
> they are full pages can go back on free lists for normal
> allocations.  This provides the mechanism for forwards progress, and
> it's essentially the same mechanism that mempools use to guarantee
> forwards progess. the only difference is that reserve pool refilling
> comes through reclaim via shrinker invocation...

Yes, I had something else in mind.

In order to rely on replenishing through reclaim, you have to make
sure that all allocations taken out of the pool are guaranteed to come
back in a reasonable time frame.  So once Ted said that the filesystem
will not be able to declare which allocations of a task are allowed to
dip into its reserves, and thus allocations of indefinite lifetime can
enter the picture, my mind went to a one-off reserve pool that doesn't
rely on replenishing in order to make forward progress.  You declare
the worst-case, finish the transaction, and return what is left of the
reserves.  This obviously conflicts with the estimation model that you
are proposing, I hope it's now clear where our misunderstanding lies.

Yes, we can make this work if you can tell us which allocations have
limited/controllable lifetime.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
