Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6A60B8309E
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 01:01:54 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id 128so140803087wmz.1
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 22:01:54 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t126si14584464wmf.12.2016.02.07.22.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Feb 2016 22:01:53 -0800 (PST)
Date: Mon, 8 Feb 2016 01:01:36 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/5] radix-tree: account radix_tree_node to memory cgroup
Message-ID: <20160208060136.GD22202@cmpxchg.org>
References: <cover.1454864628.git.vdavydov@virtuozzo.com>
 <886d4b42a50c77c45ece9c0e685fc25f8f7643c9.1454864628.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <886d4b42a50c77c45ece9c0e685fc25f8f7643c9.1454864628.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Feb 07, 2016 at 08:27:34PM +0300, Vladimir Davydov wrote:
> Allocation of radix_tree_node objects can be easily triggered from
> userspace, so we should account them to memory cgroup. Besides, we need
> them accounted for making shadow node shrinker per memcg (see
> mm/workingset.c).
> 
> A tricky thing about accounting radix_tree_node objects is that they are
> mostly allocated through radix_tree_preload(), so we can't just set
> SLAB_ACCOUNT for radix_tree_node_cachep - that would likely result in a
> lot of unrelated cgroups using objects from each other's caches.
> 
> One way to overcome this would be making radix tree preloads per memcg,
> but that would probably look cumbersome and overcomplicated.
> 
> Instead, we make radix_tree_node_alloc() first try to allocate from the
> cache with __GFP_ACCOUNT, no matter if the caller has preloaded or not,
> and only if it fails fall back on using per cpu preloads. This should
> make most allocations accounted.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

I'm not too stoked about the extra slab call. But the preload call
allocates nodes for the worst-case insertion, so you are absolutely
right that charging there would not make sense for cgroup ownership.
And I can't think of anything better to do here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
