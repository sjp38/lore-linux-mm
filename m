Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id A97A16B0031
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 02:24:24 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id b8so6569521lan.12
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 23:24:23 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id r10si12208748laj.234.2014.04.14.23.24.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Apr 2014 23:24:22 -0700 (PDT)
Message-ID: <534CD08F.30702@parallels.com>
Date: Tue, 15 Apr 2014 10:24:15 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 1/4] memcg, slab: do not schedule cache destruction
 when last page goes away
References: <cover.1397054470.git.vdavydov@parallels.com> <8ea8b57d5264f16ee33497a4317240648645704a.1397054470.git.vdavydov@parallels.com> <20140415021614.GC7969@cmpxchg.org>
In-Reply-To: <20140415021614.GC7969@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Hi Johannes,

On 04/15/2014 06:16 AM, Johannes Weiner wrote:
> On Wed, Apr 09, 2014 at 07:02:30PM +0400, Vladimir Davydov wrote:
>> After the memcg is offlined, we mark its kmem caches that cannot be
>> deleted right now due to pending objects as dead by setting the
>> memcg_cache_params::dead flag, so that memcg_release_pages will schedule
>> cache destruction (memcg_cache_params::destroy) as soon as the last slab
>> of the cache is freed (memcg_cache_params::nr_pages drops to zero).
>>
>> I guess the idea was to destroy the caches as soon as possible, i.e.
>> immediately after freeing the last object. However, it just doesn't work
>> that way, because kmem caches always preserve some pages for the sake of
>> performance, so that nr_pages never gets to zero unless the cache is
>> shrunk explicitly using kmem_cache_shrink. Of course, we could account
>> the total number of objects on the cache or check if all the slabs
>> allocated for the cache are empty on kmem_cache_free and schedule
>> destruction if so, but that would be too costly.
>>
>> Thus we have a piece of code that works only when we explicitly call
>> kmem_cache_shrink, but complicates the whole picture a lot. Moreover,
>> it's racy in fact. For instance, kmem_cache_shrink may free the last
>> slab and thus schedule cache destruction before it finishes checking
>> that the cache is empty, which can lead to use-after-free.
>>
>> So I propose to remove this async cache destruction from
>> memcg_release_pages, and check if the cache is empty explicitly after
>> calling kmem_cache_shrink instead. This will simplify things a lot w/o
>> introducing any functional changes.
>>
>> And regarding dead memcg caches (i.e. those that are left hanging around
>> after memcg offline for they have objects), I suppose we should reap
>> them either periodically or on vmpressure as Glauber suggested
>> initially. I'm going to implement this later.
> memcg_release_pages() can be called after cgroup destruction, and thus
> it *must* ensure that the now-empty cache is destroyed - or we'll leak
> it.

But the problem is that we already leak *all* per memcg caches that are
not empty by the time memcg is offlined, because even when all objects
of such a cache are freed, it will still have some pages cached
per-cpu/node in both slab and slub implementations. That said, at
present the code scheduling cache destruction from memcg_release_pages
only works when we call kmem_cache_shrink.

I propose to remove this piece of code from memcg_release_pages and
instead call kmem_cache_destroy explicitly after kmem_cache_shrink if
the cache becomes empty. The caches that still have objects after memcg
offline should be shrunk either periodically or on vmpressure. That
would greatly simplify synchronization.

> There is no excuse to downgrade to periodic reaping when we already
> directly hook into the event that makes the cache empty.  If slab
> needs to hold on to the cache for slightly longer than the final
> memcg_release_pages(), then it should grab a refcount to it.

IMO that wouldn't be a downgrade - the code in memcg_release_pages
already does not work as expected, at least it doesn't initiate cache
destruction when the last object goes away.

If we really want to destroy caches as soon as possible we could:

1) Count active objects per cache instead of pages as we do now. That
would be too costly IMO.

2) When freeing an object of a dead memcg cache, initiate thorough check
if the cache is really empty and destroy it then. That could be
implemented by poking the reaping thread on kfree, and actually does not
require the schedule_work in memcg_release_pages IMO.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
