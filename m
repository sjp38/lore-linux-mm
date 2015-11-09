Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7536B0257
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 14:27:57 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so183864284pac.3
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 11:27:57 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id uv3si24118339pac.101.2015.11.09.11.27.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 11:27:56 -0800 (PST)
Date: Mon, 9 Nov 2015 22:27:47 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 0/5] memcg/kmem: switch to white list policy
Message-ID: <20151109192747.GN31308@esperanza>
References: <cover.1446924358.git.vdavydov@virtuozzo.com>
 <20151109140832.GE8916@dhcp22.suse.cz>
 <20151109182840.GJ31308@esperanza>
 <20151109185401.GB28507@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151109185401.GB28507@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Nov 09, 2015 at 01:54:01PM -0500, Tejun Heo wrote:
> On Mon, Nov 09, 2015 at 09:28:40PM +0300, Vladimir Davydov wrote:
> > > I am _all_ for this semantic I am just not sure what to do with the
> > > legacy kmem controller. Can we change its semantic? If we cannot do that
> > 
> > I think we can. If somebody reports a "bug" caused by this change, i.e.
> > basically notices that something that used to be accounted is not any
> > longer, it will be trivial to fix by adding __GFP_ACCOUNT where
> > appropriate. If it is not, e.g. if accounting of objects of a particular
> > type leads to intense false-sharing, we would end up disabling
> > accounting for it anyway.
> 
> I agree too, if anything is meaningfully broken by the flip, it just
> indicates that the whitelist needs to be expanded; however, I wonder
> whether this would be done better at slab level rather than per
> allocation site.

I'd like to, but this is not as simple as it seems at first glance. The
problem is that slab caches of the same size are actively merged with
each other. If we just added SLAB_ACCOUNT flag, which would be passed to
kmem_cache_create to enable accounting, we'd divide all caches into two
groups that couldn't be merged with each other even if kmem accounting
was not used at all. This would be a show stopper.

Of course, we could rework slab merging so that kmem_cache_create
returned a new dummy cache even if it was actually merged. Such a cache
would point to the real cache, which would be used for allocations. This
wouldn't limit slab merging, but this would add one more dereference to
alloc path, which is even worse.

That's why I decided to go with marking individual allocations.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
