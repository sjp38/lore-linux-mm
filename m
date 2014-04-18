Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0C86B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 09:23:45 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so1626397eek.38
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 06:23:44 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id 43si40249526eer.87.2014.04.18.06.23.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 18 Apr 2014 06:23:43 -0700 (PDT)
Date: Fri, 18 Apr 2014 09:23:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC -mm v2 0/3] kmemcg: simplify work-flow (was
 "memcg-vs-slab cleanup")
Message-ID: <20140418132331.GA26283@cmpxchg.org>
References: <cover.1397804745.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1397804745.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: mhocko@suse.cz, akpm@linux-foundation.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Hi Vladimir,

On Fri, Apr 18, 2014 at 12:04:46PM +0400, Vladimir Davydov wrote:
> Hi Michal, Johannes,
> 
> This patch-set is a part of preparations for kmemcg re-parenting. It
> targets at simplifying kmemcg work-flows and synchronization.
> 
> First, it removes async per memcg cache destruction (see patches 1, 2).
> Now caches are only destroyed on memcg offline. That means the caches
> that are not empty on memcg offline will be leaked. However, they are
> already leaked, because memcg_cache_params::nr_pages normally never
> drops to 0 so the destruction work is never scheduled except
> kmem_cache_shrink is called explicitly. In the future I'm planning
> reaping such dead caches on vmpressure or periodically.

I like the synchronous handling on css destruction, but the periodical
reaping part still bothers me.  If there is absolutely 0 use for these
caches remaining, they shouldn't hang around until we encounter memory
pressure or a random time interval.

Would it be feasible to implement cache merging in both slub and slab,
so that upon css destruction the child's cache's remaining slabs could
be moved to the parent's cache?  If the parent doesn't have one, just
reparent the whole cache.

> Second, it substitutes per memcg slab_caches_mutex's with the global
> memcg_slab_mutex, which should be taken during the whole per memcg cache
> creation/destruction path before the slab_mutex (see patch 3). This
> greatly simplifies synchronization among various per memcg cache
> creation/destruction paths.

This sounds reasonable.  I'll go look at the code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
