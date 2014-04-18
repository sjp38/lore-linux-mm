Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id D89696B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 12:04:47 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id 10so1470227lbg.21
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 09:04:46 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id pr4si19266929lbc.135.2014.04.18.09.04.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Apr 2014 09:04:45 -0700 (PDT)
Message-ID: <53514D16.80309@parallels.com>
Date: Fri, 18 Apr 2014 20:04:38 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC -mm v2 0/3] kmemcg: simplify work-flow (was "memcg-vs-slab
 cleanup")
References: <cover.1397804745.git.vdavydov@parallels.com> <20140418132331.GA26283@cmpxchg.org>
In-Reply-To: <20140418132331.GA26283@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: mhocko@suse.cz, akpm@linux-foundation.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On 04/18/2014 05:23 PM, Johannes Weiner wrote:
>> First, it removes async per memcg cache destruction (see patches 1, 2).
>> Now caches are only destroyed on memcg offline. That means the caches
>> that are not empty on memcg offline will be leaked. However, they are
>> already leaked, because memcg_cache_params::nr_pages normally never
>> drops to 0 so the destruction work is never scheduled except
>> kmem_cache_shrink is called explicitly. In the future I'm planning
>> reaping such dead caches on vmpressure or periodically.
>
> I like the synchronous handling on css destruction, but the periodical
> reaping part still bothers me.  If there is absolutely 0 use for these
> caches remaining, they shouldn't hang around until we encounter memory
> pressure or a random time interval.

Agree.

> Would it be feasible to implement cache merging in both slub and slab,
> so that upon css destruction the child's cache's remaining slabs could
> be moved to the parent's cache?  If the parent doesn't have one, just
> reparent the whole cache.

Interesting idea. That would definitely look neater than periodic
reaping. But it's going to be an uneasy thing to do I guess, because
synchronization in sl[au]b is a subtle thing. I'll have a closer look at
slab's internals to understand if it's feasible.

>
>> Second, it substitutes per memcg slab_caches_mutex's with the global
>> memcg_slab_mutex, which should be taken during the whole per memcg cache
>> creation/destruction path before the slab_mutex (see patch 3). This
>> greatly simplifies synchronization among various per memcg cache
>> creation/destruction paths.
>
> This sounds reasonable.  I'll go look at the code.

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
