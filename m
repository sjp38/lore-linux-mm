Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 15F696B0036
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 10:51:18 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id z12so6838100lbi.22
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 07:51:18 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f8si14745604laa.92.2014.09.22.07.51.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Sep 2014 07:51:16 -0700 (PDT)
Date: Mon, 22 Sep 2014 16:51:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] memcg: move memcg_{alloc,free}_cache_params to
 slab_common.c
Message-ID: <20140922145115.GI336@dhcp22.suse.cz>
References: <e768785511927d65bd3e6d9f65ab2a9851a3d73d.1411054735.git.vdavydov@parallels.com>
 <20140922135245.GE336@dhcp22.suse.cz>
 <20140922141420.GD18526@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140922141420.GD18526@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>

On Mon 22-09-14 18:14:20, Vladimir Davydov wrote:
> On Mon, Sep 22, 2014 at 03:52:45PM +0200, Michal Hocko wrote:
> > On Thu 18-09-14 19:50:19, Vladimir Davydov wrote:
> > > The only reason why they live in memcontrol.c is that we get/put css
> > > reference to the owner memory cgroup in them. However, we can do that in
> > > memcg_{un,}register_cache.
> > > 
> > > So let's move them to slab_common.c and make them static.
> > 
> > Why is it better?
> 
> First, I think that the less public interface functions we have in
> memcontrol.h the better. Since the functions I move don't depend on
> memcontrol, I think it's worth making them private to slab, especially
> taking into account that the arrays are defined on the slab's side too.
> 
> Second, the way how per-memcg arrays are updated looks rather awkward:
> it proceeds from memcontrol.c (__memcg_activate_kmem) to slab_common.c
> (memcg_update_all_caches) and back to memcontrol.c again
> (memcg_update_array_size). In the next patch I move the function
> relocating the arrays (memcg_update_array_size) to slab_common.c and
> therefore get rid this circular call path. I think we should have the
> cache allocation stuff in the same place where we have relocation,
> because it's easier to follow the code then. So I move arrays alloc/free
> functions to slab_common.c too.
> 
> The third point isn't obvious. In the "Per memcg slab shrinkers" patch
> set, which I sent recently, I have to update per-memcg list_lrus arrays
> too. And it's much easier and cleaner to do it in list_lru.c rather than
> in memcontrol.c. The current patchset makes cache arrays allocation path
> conform that of the upcoming list_lru.

Exactly what I would love to have in the changelog...

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
