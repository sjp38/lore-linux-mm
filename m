Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 65DED6B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 08:45:37 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e49so704790eek.7
        for <linux-mm@kvack.org>; Wed, 07 May 2014 05:45:36 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si16271437eei.145.2014.05.07.05.45.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 05:45:35 -0700 (PDT)
Date: Wed, 7 May 2014 14:45:33 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm 2/2] memcg: cleanup kmem cache creation/destruction
 functions naming
Message-ID: <20140507124533.GF9489@dhcp22.suse.cz>
References: <a4aa62026c10fc709e8bf13542b29cf771381394.1399450112.git.vdavydov@parallels.com>
 <c3bef5d3667668f89a4acabda64eb79d730037ec.1399450112.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c3bef5d3667668f89a4acabda64eb79d730037ec.1399450112.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 07-05-14 12:15:30, Vladimir Davydov wrote:
> Current names are rather inconsistent. Let's try to improve them.

Yes the old names are a giant mess. I am not sure the new ones are
that much better however.
 
> Brief change log:
> 
> ** old name **                          ** new name **
> 
> kmem_cache_create_memcg                 kmem_cache_request_memcg_copy

Both are bad because the first suggests we are creating memcg and the second that
we are requesting a copy of memcg.

memcg_alloc_kmem_cache?

_copy suffix is a bit confusing. E.g. copy_mm and others either to
shallow or deep copy depending on the context. This one always creats a
deep copy. Also why it is imporatant to treat the created caches as
copies?

> memcg_kmem_create_cache                 memcg_copy_kmem_cache

memcg_register_kmem_cache? It also allocates so this name is a bit
awkward as well.

> memcg_kmem_destroy_cache                memcg_destroy_kmem_cache_copy

memcg_unregister_kmem_cache to match the above?

> __kmem_cache_destroy_memcg_children     __kmem_cache_destroy_memcg_copies
> kmem_cache_destroy_memcg_children       kmem_cache_destroy_memcg_copies

_children suffix is really confusing because they have different meaning in
memcg and refer to children groups.

memcg_cleanup_kmem_chache_memcg_params? It doesn't have to live in the
kmem_cache namespace because it only does only memcg kmem specific
stuff.

> mem_cgroup_destroy_all_caches           memcg_destroy_kmem_cache_copies
> 
> create_work                             memcg_kmem_cache_copy_work

memcg_register_cache_work?

> memcg_create_cache_work_func            memcg_kmem_cache_copy_work_func

memcg_register_cache_func?

> memcg_create_cache_enqueue              memcg_schedule_kmem_cache_copy

memcg_schedule_register_cache?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
