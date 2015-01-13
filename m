Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8416B006E
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 11:28:17 -0500 (EST)
Received: by mail-we0-f172.google.com with SMTP id k11so3908661wes.3
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 08:28:17 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id mw9si21075768wib.47.2015.01.13.08.28.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jan 2015 08:28:16 -0800 (PST)
Date: Tue, 13 Jan 2015 11:28:11 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC] A question about memcg/kmem
Message-ID: <20150113162811.GA10372@phnom.home.cmpxchg.org>
References: <20150113092424.GJ2110@esperanza>
 <20150113142544.GB8180@phnom.home.cmpxchg.org>
 <20150113152009.GA11264@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150113152009.GA11264@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 13, 2015 at 06:20:09PM +0300, Vladimir Davydov wrote:
> On Tue, Jan 13, 2015 at 09:25:44AM -0500, Johannes Weiner wrote:
> > On Tue, Jan 13, 2015 at 12:24:24PM +0300, Vladimir Davydov wrote:
> > > 2. On css offline, empty all list_lru's corresponding to the dying
> > >    cgroup by moving items to the parent. Then, we could free kmemcg_id
> > >    immediately on offline, and the arrays would store entries for online
> > >    cgroups only, which is fine. This looks as a kind of reparenting, but
> > >    it doesn't move charges, only list_lru elements, which is much easier
> > >    to do.
> > > 
> > >    This does not conform to how we treat other charges though.
> > 
> > This seems like the best way to do it to me.  It shouldn't result in a
> > user-visible difference in behavior and we get to keep the O(1) lookup
> > during the allocation hotpath.  Could even the reparenting be constant
> > by using list_splice()?
> 
> Unfortunately, list_splice() doesn't seem to be an option with the
> list_lru API we have right now, because there's LRU_REMOVED_RETRY. It
> indicates that list_lru_walk callback removed an element, then dropped
> and reacquired the list_lru lock. In this case we first decrement
> nr_items to reflect an item removal, and then restart the loop. If we do
> list_splice() between the item removal and nr_items fix-up (when the
> lock was released) we'll end up with screwed nr_items. So we have to
> move elements one by one.
> 
> Come to think of it, I believe we could change the list_lru API so that
> callbacks would fix nr_items by themselves. May be, we could add a
> special helper for walkers to remove items, say list_lru_isolate, that
> would fix nr_items? Anyway, I'll take a closer look in this direction.

The API is not set in stone.  We should be able to add a function that
can move pages in bulk, no?

> > What aspects of #2 do you think are nasty?
> 
> We wouldn't be able to reclaim dentries/inodes accounted to an offline
> css w/o reclaiming objects accounted to its online ancestor. I'm not
> sure if we will ever want to do it though, so it isn't necessarily bad.

I don't think it is bad.  Conceptually, the pages in any given cgroup
belong to all its ancestors as well.  Whether we reparent them or not,
they get reclaimed during memory pressure on the hierarchy.  Purging
them from any other avenue besides parent pressure is unexpected, so I
would like to avoid that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
