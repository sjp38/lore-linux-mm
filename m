Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 88A6F6B0038
	for <linux-mm@kvack.org>; Sun, 21 Sep 2014 11:50:57 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id ft15so2853815pdb.24
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 08:50:57 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id yg2si12180892pab.48.2014.09.21.08.50.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Sep 2014 08:50:56 -0700 (PDT)
Date: Sun, 21 Sep 2014 19:50:43 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch 0/3] mm: memcontrol: eliminate charge reparenting
Message-ID: <20140921155043.GC32416@esperanza>
References: <1411243235-24680-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1411243235-24680-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Johannes,

On Sat, Sep 20, 2014 at 04:00:32PM -0400, Johannes Weiner wrote:
> The decoupling of css from the user-visible cgroup, word-sized per-cpu
> css reference counters, and css iterators that include offlined groups
> means we can take per-charge css references, continue to reclaim from
> offlined groups, and so get rid of the error-prone charge reparenting.

I haven't reviewed this set yet, but I agree that zapping user memory
reparenting sounds like a sane idea, because reparenting won't let the
css go in most cases anyway due to swap and kmem charges.

However, I think we must reparent list_lru items, otherwise per-memcg
arrays (kmem_caches, list_lrus) will grow uncontrollably due to dead
css's, which is unacceptable. Note it isn't the same as the user memory
reparenting, because we don't need to reparent kmem_cache objects or
charges - they can stay where they are pinning the css till they are
freed, because the memcg_cache_id, which I want to free on offline, is
not used for kmem allocations/frees after css offline. Actually we only
need to empty the list_lru corresponding to the dead memory cgroup,
which is relatively easy to implement. This is what patch 13 of the "Per
memcg slab shrinkers" patch set, which I sent recently, does (see
https://lkml.org/lkml/2014/9/21/64).

What do you think about it?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
