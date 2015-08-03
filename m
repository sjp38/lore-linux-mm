Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id AB34C9003CD
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 09:52:50 -0400 (EDT)
Received: by labsr2 with SMTP id sr2so11916633lab.2
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 06:52:50 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id kw7si12022620lac.136.2015.08.03.06.52.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 06:52:48 -0700 (PDT)
Date: Mon, 3 Aug 2015 16:52:29 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 2/3] mm: make workingset detection logic memcg aware
Message-ID: <20150803135229.GA11971@esperanza>
References: <cover.1438599199.git.vdavydov@parallels.com>
 <9662034e14549b9e1445684f674063ce8b092cb0.1438599199.git.vdavydov@parallels.com>
 <20150803132358.GA18399@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150803132358.GA18399@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 03, 2015 at 09:23:58AM -0400, Johannes Weiner wrote:
> On Mon, Aug 03, 2015 at 03:04:22PM +0300, Vladimir Davydov wrote:
> > @@ -179,8 +180,9 @@ static void unpack_shadow(void *shadow,
> >  	eviction = entry;
> >  
> >  	*zone = NODE_DATA(nid)->node_zones + zid;
> > +	*lruvec = mem_cgroup_page_lruvec(page, *zone);
> >  
> > -	refault = atomic_long_read(&(*zone)->inactive_age);
> > +	refault = atomic_long_read(&(*lruvec)->inactive_age);
> >  	mask = ~0UL >> (NODES_SHIFT + ZONES_SHIFT +
> >  			RADIX_TREE_EXCEPTIONAL_SHIFT);
> >  	/*
> 
> You can not compare an eviction shadow entry from one lruvec with the
> inactive age of another lruvec. The inactive ages are not related and
> might differ significantly: memcgs are created ad hoc, memory hotplug,
> page allocator fairness drift. In those cases the result will be pure
> noise.

That's true. If a page is evicted in one cgroup and then refaulted in
another, the activation will be random. However, is it a frequent event
when a page used by and evicted from one cgroup is refaulted in another?
If there is no active file sharing (is it common?), this should only
happen to code pages, but those will most likely end up in the cgroup
that has the greatest limit, so they shouldn't be evicted and refaulted
frequently. So the question is can we tolerate some noise here?

> 
> As much as I would like to see a simpler way, I am pessimistic that
> there is a way around storing memcg ids in the shadow entries.

On 32 bit there is too little space for storing memcg id. We can shift
the distance so that it would fit and still contain something meaningful
though, but that would take much more code, so I'm trying to try the
simplest way first.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
