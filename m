Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8E39D8309E
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 00:49:12 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id 128so140544600wmz.1
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 21:49:12 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id s12si14474821wmd.100.2016.02.07.21.49.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Feb 2016 21:49:11 -0800 (PST)
Date: Mon, 8 Feb 2016 00:48:57 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/5] mm: memcontrol: zap memcg_kmem_online helper
Message-ID: <20160208054857.GC22202@cmpxchg.org>
References: <cover.1454864628.git.vdavydov@virtuozzo.com>
 <6ae345a21265e07951aa632314dfc610e40ea713.1454864628.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6ae345a21265e07951aa632314dfc610e40ea713.1454864628.git.vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Feb 07, 2016 at 08:27:33PM +0300, Vladimir Davydov wrote:
> As kmem accounting is now either enabled for all cgroups or disabled
> system-wide, there's no point in having memcg_kmem_online() helper -
> instead one can use memcg_kmem_enabled() and mem_cgroup_online(), as
> shrink_slab() now does.
> 
> There are only two places left where this helper is used -
> __memcg_kmem_charge() and memcg_create_kmem_cache(). The former can only
> be called if memcg_kmem_enabled() returned true. Since the cgroup it
> operates on is online, mem_cgroup_is_root() check will be enough.
> 
> memcg_create_kmem_cache() can't use mem_cgroup_online() helper instead
> of memcg_kmem_online(), because it relies on the fact that in
> memcg_offline_kmem() memcg->kmem_state is changed before
> memcg_deactivate_kmem_caches() is called, but there we can just
> open-code the check.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Nice. I like the direct check for the root memcg.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
