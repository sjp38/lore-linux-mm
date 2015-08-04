Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9F16B0253
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 04:13:49 -0400 (EDT)
Received: by labsr2 with SMTP id sr2so1835698lab.2
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 01:13:48 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id n5si149161laf.168.2015.08.04.01.13.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Aug 2015 01:13:47 -0700 (PDT)
Date: Tue, 4 Aug 2015 11:13:29 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 2/3] mm: make workingset detection logic memcg aware
Message-ID: <20150804081329.GB11971@esperanza>
References: <cover.1438599199.git.vdavydov@parallels.com>
 <9662034e14549b9e1445684f674063ce8b092cb0.1438599199.git.vdavydov@parallels.com>
 <20150803132358.GA18399@cmpxchg.org>
 <20150803135229.GA11971@esperanza>
 <20150803205532.GA19478@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150803205532.GA19478@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 03, 2015 at 04:55:32PM -0400, Johannes Weiner wrote:
> On Mon, Aug 03, 2015 at 04:52:29PM +0300, Vladimir Davydov wrote:
> > On Mon, Aug 03, 2015 at 09:23:58AM -0400, Johannes Weiner wrote:
> > > On Mon, Aug 03, 2015 at 03:04:22PM +0300, Vladimir Davydov wrote:
> > > > @@ -179,8 +180,9 @@ static void unpack_shadow(void *shadow,
> > > >  	eviction = entry;
> > > >  
> > > >  	*zone = NODE_DATA(nid)->node_zones + zid;
> > > > +	*lruvec = mem_cgroup_page_lruvec(page, *zone);
> > > >  
> > > > -	refault = atomic_long_read(&(*zone)->inactive_age);
> > > > +	refault = atomic_long_read(&(*lruvec)->inactive_age);
> > > >  	mask = ~0UL >> (NODES_SHIFT + ZONES_SHIFT +
> > > >  			RADIX_TREE_EXCEPTIONAL_SHIFT);
> > > >  	/*
> > > 
> > > You can not compare an eviction shadow entry from one lruvec with the
> > > inactive age of another lruvec. The inactive ages are not related and
> > > might differ significantly: memcgs are created ad hoc, memory hotplug,
> > > page allocator fairness drift. In those cases the result will be pure
> > > noise.
> > 
> > That's true. If a page is evicted in one cgroup and then refaulted in
> > another, the activation will be random. However, is it a frequent event
> > when a page used by and evicted from one cgroup is refaulted in another?
> > If there is no active file sharing (is it common?), this should only
> > happen to code pages, but those will most likely end up in the cgroup
> > that has the greatest limit, so they shouldn't be evicted and refaulted
> > frequently. So the question is can we tolerate some noise here?
> 
> It's not just the memcg, it's also the difference between zones
> themselves.

But I do take into account the difference between zones in this patch -
zone and node ids are still stored in a shadow entry. I only neglect
memcg id. So if a page is refaulted in another zone within the same
cgroup, its refault distance will be calculated correctly. We only get
noise in case of a page refaulted from a different cgroup.

> 
> > > As much as I would like to see a simpler way, I am pessimistic that
> > > there is a way around storing memcg ids in the shadow entries.
> > 
> > On 32 bit there is too little space for storing memcg id. We can shift
> > the distance so that it would fit and still contain something meaningful
> > though, but that would take much more code, so I'm trying to try the
> > simplest way first.
> 
> It should be easy to trim quite a few bits from the timestamp, both in
> terms of available memory as well as in terms of distance granularity.
> We probably don't care if the refault distance is only accurate to say
> 2MB, and how many pages do we have to represent on 32-bit in the first
> place? Once we trim that, we should be able to fit a CSS ID.

NODES_SHIFT <= 10, ZONES_SHIFT == 2, RADIX_TREE_EXCEPTIONAL_SHIFT == 2

And we need 16 bit for storing memcg id, so there are only 2 bits left.
Even with 2MB accuracy, it gives us the maximal refault distance of 6MB
:-(

However, I doubt there is a 32 bit host with 1024 NUMA nodes. Can we
possibly limit this config option on 32 bit architectures?

Or may be we can limit the number of cgroups to say 1024 if running on
32 bit? This would allow us to win 6 more bits, so that the maximal
refault distance would be 512MB with the accuracy of 2MB. But can we be
sure this won't brake anyone's setup, especially counting that cgroups
can be zombieing around for a while after rmdir?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
