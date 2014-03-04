Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 791DC6B0031
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 09:56:11 -0500 (EST)
Received: by mail-la0-f48.google.com with SMTP id gf5so5628399lab.21
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 06:56:10 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id q7si19176223lbw.113.2014.03.04.06.56.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Mar 2014 06:56:09 -0800 (PST)
Message-ID: <5315E986.7070608@parallels.com>
Date: Tue, 4 Mar 2014 18:56:06 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 00/12] kmemcg reparenting
References: <cover.1393423762.git.vdavydov@parallels.com>
In-Reply-To: <cover.1393423762.git.vdavydov@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@suse.cz
Cc: akpm@linux-foundation.org, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Hi Johannes, Michal

Could you please take a look at this set when you have time?

Thank you.

On 02/26/2014 07:05 PM, Vladimir Davydov wrote:
> Hi,
>
> During my recent attempt to push kmemcg shrinkers, I was pointed out
> that current kmemcg implementation has a serious design flaw - it lacks
> reparenting. Currently each memcg cache holds a css ref to its memcg and
> does not let it go until the cache is emptied. Although this approach is
> simple, it leads to memcgs hanging around for quite a long time after
> the death, which is ugly. Building something on top of that is
> unacceptable. So this patch set targets on implementing reparenting for
> kmemcg charges.
>
> [ for more details see the discussion thread:
>   https://lkml.org/lkml/2014/2/11/623 ]
>
> It is based on top of 3.14.0-rc4-mmotm and organized as follows:
>  - Patches 1-3 fix some nasty races in kmemcg implementation. I could
>    not let them live any longer, because they touch the code I'm going
>    to modify.
>  - Patches 4-6 prepare memcg_cache_params for reparenting.
>  - Patch 7 rework slab charging making it easier to track and therefore
>    reparent kmem charges, and patches 8-10 kill the old charging code.
>  - Patch 11 introduces kmemcg reparenting.
>  - Patch 12 is for slub. It fixes sysfs naming clashes that can arise
>    due to reparented caches.
>
> Please note that this patch set does not resolve all kmemcg-related
> issues - there are still plenty of them (e.g. "dangling" caches), but it
> is already big enough so I guess I'll address them later when this one
> is committed (if it will be committed at all, of course).
>
> Many thanks to Johannes Weiner, who proposed the idea and kindly
> outlined basic design principles.
>
> Thanks,
>
> Vladimir Davydov (12):
>   memcg: flush cache creation works before memcg cache destruction
>   memcg: fix race in memcg cache destruction path
>   memcg: fix root vs memcg cache destruction race
>   memcg: move slab caches list/mutex init to memcg creation
>   memcg: add pointer from memcg_cache_params to cache
>   memcg: keep all children of each root cache on a list
>   memcg: rework slab charging
>   memcg: do not charge kmalloc_large allocations
>   fork: do not charge thread_info to kmemcg
>   memcg: kill GFP_KMEMCG and stuff
>   memcg: reparent slab on css offline
>   slub: make sure all memcg caches have unique names on sysfs
>
>  include/linux/gfp.h             |    5 -
>  include/linux/memcontrol.h      |  133 ++-------
>  include/linux/slab.h            |   15 +-
>  include/linux/thread_info.h     |    2 -
>  include/trace/events/gfpflags.h |    1 -
>  kernel/fork.c                   |    4 +-
>  mm/memcontrol.c                 |  587 +++++++++++++++++----------------------
>  mm/page_alloc.c                 |   35 ---
>  mm/slab.c                       |   47 ++--
>  mm/slab.h                       |   17 +-
>  mm/slab_common.c                |  100 +++++--
>  mm/slub.c                       |   88 ++++--
>  12 files changed, 470 insertions(+), 564 deletions(-)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
