Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2C46B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 17:05:21 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so11688563pad.41
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 14:05:21 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id y10si4844358pdo.10.2014.08.11.14.05.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 Aug 2014 14:05:20 -0700 (PDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so11365653pdj.36
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 14:05:20 -0700 (PDT)
Date: Mon, 11 Aug 2014 14:05:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm] slab: fix cpuset check in fallback_alloc
In-Reply-To: <20140811121739.GB18709@esperanza>
Message-ID: <alpine.DEB.2.02.1408111354330.24240@chino.kir.corp.google.com>
References: <1407692891-24312-1-git-send-email-vdavydov@parallels.com> <alpine.DEB.2.02.1408101512500.706@chino.kir.corp.google.com> <20140811071315.GA18709@esperanza> <alpine.DEB.2.02.1408110433140.15519@chino.kir.corp.google.com>
 <20140811121739.GB18709@esperanza>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, 11 Aug 2014, Vladimir Davydov wrote:

> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1963,7 +1963,7 @@ zonelist_scan:
> >  
> >  	/*
> >  	 * Scan zonelist, looking for a zone with enough free.
> > -	 * See also __cpuset_node_allowed_softwall() comment in kernel/cpuset.c.
> > +	 * See __cpuset_node_allowed() comment in kernel/cpuset.c.
> >  	 */
> >  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> >  						high_zoneidx, nodemask) {
> > @@ -1974,7 +1974,7 @@ zonelist_scan:
> >  				continue;
> >  		if (cpusets_enabled() &&
> >  			(alloc_flags & ALLOC_CPUSET) &&
> > -			!cpuset_zone_allowed_softwall(zone, gfp_mask))
> > +			!cpuset_zone_allowed(zone, gfp_mask))
> >  				continue;
> 
> So, this is get_page_from_freelist. It's called from
> __alloc_pages_nodemask with alloc_flags always having ALLOC_CPUSET bit
> set and from __alloc_pages_slowpath with alloc_flags having ALLOC_CPUSET
> bit set only for __GFP_WAIT allocations. That said, w/o your patch we
> try to respect cpusets for all allocations, including atomic, and only
> ignore cpusets if tight on memory (freelist's empty) for !__GFP_WAIT
> allocations, while with your patch we always ignore cpusets for
> !__GFP_WAIT allocations. Not sure if it really matters though, because
> usually one uses cpuset.mems in conjunction with cpuset.cpus and it
> won't make any difference then. It also doesn't conflict with any cpuset
> documentation.
> 

Yeah, that's why I'm asking Li, the cpuset maintainer, if we can do this.  
The only thing that we get by falling back to the page allocator slowpath 
is that kswapd gets woken up before the allocation is attempted without 
ALLOC_CPUSET.  It seems pointless to wakeup kswapd when the allocation can 
succeed on any node.  Even with the patch, if the allocation fails because 
all nodes are below their min watermark, then we still fallback to the 
slowpath and wake up kswapd but there's nothing much else we can do 
because it's !__GFP_WAIT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
