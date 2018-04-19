Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1589F6B0008
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 02:40:28 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id h1-v6so4093632wre.0
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 23:40:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g59si2748709ede.132.2018.04.18.23.40.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Apr 2018 23:40:26 -0700 (PDT)
Date: Thu, 19 Apr 2018 08:40:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm:memcg: add __GFP_NOWARN in
 __memcg_schedule_kmem_cache_create
Message-ID: <20180419064005.GL17484@dhcp22.suse.cz>
References: <20180418022912.248417-1-minchan@kernel.org>
 <20180418072002.GN17484@dhcp22.suse.cz>
 <20180418074117.GA210164@rodete-desktop-imager.corp.google.com>
 <20180418075437.GP17484@dhcp22.suse.cz>
 <20180418132328.GB210164@rodete-desktop-imager.corp.google.com>
 <20180418132715.GD17484@dhcp22.suse.cz>
 <alpine.DEB.2.21.1804181152240.227784@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1804181152240.227784@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Wed 18-04-18 11:58:00, David Rientjes wrote:
> On Wed, 18 Apr 2018, Michal Hocko wrote:
> 
> > > Okay, no problem. However, I don't feel we need ratelimit at this moment.
> > > We can do when we got real report. Let's add just one line warning.
> > > However, I have no talent to write a poem to express with one line.
> > > Could you help me?
> > 
> > What about
> > 	pr_info("Failed to create memcg slab cache. Report if you see floods of these\n");
> >  
> 
> Um, there's nothing actionable here for the user.  Even if the message 
> directed them to a specific email address, what would you ask the user for 
> in response if they show a kernel log with 100 of these?

We would have to think of a better way to create shaddow memcg caches.

> Probably ask 
> them to use sysrq at the time it happens to get meminfo.  But any user 
> initiated sysrq is going to reveal very different state of memory compared 
> to when the kmalloc() actually failed.

Not really.

> If this really needs a warning, I think it only needs to be done once and 
> reveal the state of memory similar to how slub emits oom warnings.  But as 
> the changelog indicates, the system is oom and we couldn't reclaim.  We 
> can expect this happens a lot on systems with memory pressure.  What is 
> the warning revealing that would be actionable?

That it actually happens in real workloads and we want to know what
those workloads are. This code is quite old and yet this is the first
some somebody complains. So it is most probably rare. Maybe because most
workloads doesn't create many memcgs dynamically while low on memory.
And maybe that will change in future. In any case, having a large splat
of meminfo for GFP_NOWAIT is not really helpful. It will tell us what we
know already - the memory is low and the reclaim was prohibited. We just
need to know that this happens out there.

-- 
Michal Hocko
SUSE Labs
