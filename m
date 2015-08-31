Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB176B0255
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 10:21:10 -0400 (EDT)
Received: by lanb10 with SMTP id b10so36948799lan.2
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 07:21:09 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ra3si13258706lbb.160.2015.08.31.07.21.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 07:21:08 -0700 (PDT)
Date: Mon, 31 Aug 2015 17:20:49 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150831142049.GV9610@esperanza>
References: <cover.1440960578.git.vdavydov@parallels.com>
 <20150831132414.GG29723@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150831132414.GG29723@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 31, 2015 at 03:24:15PM +0200, Michal Hocko wrote:
> On Sun 30-08-15 22:02:16, Vladimir Davydov wrote:

> > Tejun reported that sometimes memcg/memory.high threshold seems to be
> > silently ignored if kmem accounting is enabled:
> > 
> >   http://www.spinics.net/lists/linux-mm/msg93613.html
> > 
> > It turned out that both SLAB and SLUB try to allocate without __GFP_WAIT
> > first. As a result, if there is enough free pages, memcg reclaim will
> > not get invoked on kmem allocations, which will lead to uncontrollable
> > growth of memory usage no matter what memory.high is set to.
> 
> Right but isn't that what the caller explicitly asked for?

No. If the caller of kmalloc() asked for a __GFP_WAIT allocation, we
might ignore that and charge memcg w/o __GFP_WAIT.

> Why should we ignore that for kmem accounting? It seems like a fix at
> a wrong layer to me.

Let's forget about memory.high for a minute.

 1. SLAB. Suppose someone calls kmalloc_node and there is enough free
    memory on the preferred node. W/o memcg limit set, the allocation
    will happen from the preferred node, which is OK. If there is memcg
    limit, we can currently fail to allocate from the preferred node if
    we are near the limit. We issue memcg reclaim and go to fallback
    alloc then, which will most probably allocate from a different node,
    although there is no reason for that. This is a bug.

 2. SLUB. Someone calls kmalloc and there is enough free high order
    pages. If there is no memcg limit, we will allocate a high order
    slab page, which is in accordance with SLUB internal logic. With
    memcg limit set, we are likely to fail to charge high order page
    (because we currently try to charge high order pages w/o __GFP_WAIT)
    and fallback on a low order page. The latter is unexpected and
    unjustified.

That being said, this is the fix at the right layer.

> Either we should start failing GFP_NOWAIT charges when we are above
> high wmark or deploy an additional catchup mechanism as suggested by
> Tejun.

The mechanism proposed by Tejun won't help us to avoid allocation
failures if we are hitting memory.max w/o __GFP_WAIT or __GFP_FS.

To fix GFP_NOFS/GFP_NOWAIT failures we just need to start reclaim when
the gap between limit and usage is getting too small. It may be done
from a workqueue or from task_work, but currently I don't see any reason
why complicate and not just start reclaim directly, just like
memory.high does.

I mean, currently you can protect against GFP_NOWAIT failures by setting
memory.high to be 1-2 MB lower than memory.high and this *will* work,
because GFP_NOWAIT/GFP_NOFS allocations can't go on infinitely - they
will alternate with normal GFP_KERNEL allocations sooner or later. It
does not mean we should encourage users to set memory.high to protect
against such failures, because, as pointed out by Tejun, logic behind
memory.high is currently opaque and can change, but we can introduce
memcg-internal watermarks that would work exactly as memory.high and
hence help us against GFP_NOWAIT/GFP_NOFS failures.

Thanks,
Vladimir

> I like the later more because it allows to better handle GFP_NOFS
> requests as well and there are many sources of these from kmem paths.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
