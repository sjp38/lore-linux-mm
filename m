Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 869008309E
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 01:24:11 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id p63so101210101wmp.1
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 22:24:11 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id x189si14660498wmg.13.2016.02.07.22.24.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Feb 2016 22:24:10 -0800 (PST)
Date: Mon, 8 Feb 2016 01:23:53 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/5] mm: workingset: make shadow node shrinker memcg aware
Message-ID: <20160208062353.GE22202@cmpxchg.org>
References: <cover.1454864628.git.vdavydov@virtuozzo.com>
 <934ce4e1cfe42b57e8114c72a447656fe5a01267.1454864628.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <934ce4e1cfe42b57e8114c72a447656fe5a01267.1454864628.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Feb 07, 2016 at 08:27:35PM +0300, Vladimir Davydov wrote:
> Workingset code was recently made memcg aware, but shadow node shrinker
> is still global. As a result, one small cgroup can consume all memory
> available for shadow nodes, possibly hurting other cgroups by reclaiming
> their shadow nodes, even though reclaim distances stored in its shadow
> nodes have no effect. To avoid this, we need to make shadow node
> shrinker memcg aware.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

This patch is straight forward, but there is one tiny thing that bugs
me about it, and that is switching from available memory to the size
of the active list. Because the active list can shrink drastically at
runtime.

It's true that both the shrinking of the active list and subsequent
activations to regrow it will reduce the number of actionable
refaults, and so it wouldn't be unreasonable to also shrink shadow
nodes when the active list shrinks.

However, I think these are too many assumptions to encode in the
shrinker, because it is only meant to prevent a worst-case explosion
of radix tree nodes. I'd prefer it to be dumb and conservative.

Could we instead go with the current usage of the memcg? Whether
reclaim happens globally or due to the memory limit, the usage at the
time of reclaim gives a good idea of the memory is available to the
group. But it's making less assumptions about the internal composition
of the memcg's memory, and the consequences associated with that.

What do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
