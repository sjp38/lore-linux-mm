Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8CAD26B0038
	for <linux-mm@kvack.org>; Sun, 20 Apr 2014 06:32:46 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id p9so2449575lbv.4
        for <linux-mm@kvack.org>; Sun, 20 Apr 2014 03:32:45 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id qs7si22119042lbb.195.2014.04.20.03.32.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Apr 2014 03:32:44 -0700 (PDT)
Message-ID: <5353A23F.4080303@parallels.com>
Date: Sun, 20 Apr 2014 14:32:31 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC -mm v2 0/3] kmemcg: simplify work-flow (was "memcg-vs-slab
 cleanup")
References: <cover.1397804745.git.vdavydov@parallels.com>
In-Reply-To: <cover.1397804745.git.vdavydov@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, glommer@gmail.com, cl@linux-foundation.org, penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

Hi Andrew,

Please do not apply this set for the time being, because I still have
doubts about the end picture I had in mind when submitting it.

Besides, it won't apply cleanly on top of the mm tree after "slab:
get_online_mems for kmem_cache_{create,destroy,shrink}" has been merged.

I'm going to have a bit more thinking/discussing on the problem and then
will either rework or just rebase the patch set and resend.

Thanks.

On 04/18/2014 12:04 PM, Vladimir Davydov wrote:
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
> 
> Second, it substitutes per memcg slab_caches_mutex's with the global
> memcg_slab_mutex, which should be taken during the whole per memcg cache
> creation/destruction path before the slab_mutex (see patch 3). This
> greatly simplifies synchronization among various per memcg cache
> creation/destruction paths.
> 
> I really need your help, because I'm far not sure if what I'm doing here
> is right. So I would appreciate if you could look through the patches
> and share your thoughts about the design changes they introduce.
> 
> Thanks,
> 
> Vladimir Davydov (3):
>   memcg, slab: do not schedule cache destruction when last page goes
>     away
>   memcg, slab: merge memcg_{bind,release}_pages to
>     memcg_{un}charge_slab
>   memcg, slab: simplify synchronization scheme
> 
>  include/linux/memcontrol.h |   15 +--
>  include/linux/slab.h       |    8 +-
>  mm/memcontrol.c            |  231 +++++++++++++++-----------------------------
>  mm/slab.c                  |    2 -
>  mm/slab.h                  |   28 +-----
>  mm/slab_common.c           |   22 ++---
>  mm/slub.c                  |    2 -
>  7 files changed, 92 insertions(+), 216 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
