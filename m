Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id A918A6B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 03:46:21 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id u10so6666409lbd.36
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 00:46:20 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id eq2si19078481lac.127.2014.07.01.00.46.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jul 2014 00:46:20 -0700 (PDT)
Date: Tue, 1 Jul 2014 11:46:02 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v3 8/8] slab: do not keep free objects/slabs on dead
 memcg caches
Message-ID: <20140701074602.GC7365@esperanza>
References: <cover.1402602126.git.vdavydov@parallels.com>
 <a985aec824cd35df381692fca83f7a8debc80305.1402602126.git.vdavydov@parallels.com>
 <20140624073840.GC4836@js1304-P5Q-DELUXE>
 <20140625134545.GB22340@esperanza>
 <20140627060534.GC9511@js1304-P5Q-DELUXE>
 <alpine.DEB.2.11.1406301048070.19422@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1406301048070.19422@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 30, 2014 at 10:49:03AM -0500, Christoph Lameter wrote:
> On Fri, 27 Jun 2014, Joonsoo Kim wrote:
> 
> > Christoph,
> > Is it tolerable result for large scale system? Or do we need to find
> > another solution?
> 
> 
> The overhead is pretty intense but then this is a rare event I guess?

Yes, provided cgroups are created/destroyed rarely.

> It seems that it is much easier on the code and much faster to do the
> periodic reaping. Why not simply go with that?

A bad thing about the periodic reaping is that the time it may take
isn't predictable, because the number of dead caches is, in fact, only
limited by the amount of RAM.

We can have hundreds, if not thousands, copies of dcaches/icaches left
from cgroups destroyed some time ago. The dead caches will hang around
until memory pressure evicts all the objects they host, which may take
quite long on systems with a lot of memory.

With periodic reaping, we will have to iterate over all dead caches
trying to drain per cpu/node arrays each time, which might therefore
result in slowing down the whole system unexpectedly.

I'm not quite sure if such slowdowns are really a threat though.
Actually, cache_reap will only do something (take locks, drain
arrays/lists) only if there are free objects on the cache. Otherwise it
will, in fact, only check cpu_cache->avail, alien->avail, shared->avail,
and node->free_list, which shouldn't take much time, should it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
