Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id D95E06B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:45:22 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id t10so1192030eei.35
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:45:22 -0800 (PST)
Received: from mail-ee0-x22f.google.com (mail-ee0-x22f.google.com [2a00:1450:4013:c00::22f])
        by mx.google.com with ESMTPS id t5si3431367eeo.169.2014.02.06.10.17.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 10:18:15 -0800 (PST)
Received: by mail-ee0-f47.google.com with SMTP id d49so1062109eek.6
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 10:17:45 -0800 (PST)
Date: Thu, 6 Feb 2014 19:17:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 3/7] memcg, slab: separate memcg vs root cache
 creation paths
Message-ID: <20140206181735.GA2137@dhcp22.suse.cz>
References: <cover.1391441746.git.vdavydov@parallels.com>
 <81a403327163facea2b4c7b720fdc0ef62dd1dbf.1391441746.git.vdavydov@parallels.com>
 <20140204160336.GL4890@dhcp22.suse.cz>
 <52F13D3C.801@parallels.com>
 <20140206164135.GK20269@dhcp22.suse.cz>
 <52F3C293.3060400@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52F3C293.3060400@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org

On Thu 06-02-14 21:12:51, Vladimir Davydov wrote:
> On 02/06/2014 08:41 PM, Michal Hocko wrote:
[...]
> >> +int kmem_cache_create_memcg(struct mem_cgroup *memcg, struct kmem_cache *cachep)
> >>  {
> >> -	return kmem_cache_create_memcg(NULL, name, size, align, flags, ctor, NULL);
> >> +	struct kmem_cache *s;
> >> +	int err;
> >> +
> >> +	get_online_cpus();
> >> +	mutex_lock(&slab_mutex);
> >> +
> >> +	/*
> >> +	 * Since per-memcg caches are created asynchronously on first
> >> +	 * allocation (see memcg_kmem_get_cache()), several threads can try to
> >> +	 * create the same cache, but only one of them may succeed.
> >> +	 */
> >> +	err = -EEXIST;
> > Does it make any sense to report the error here? If we are racing then at
> > least on part wins and the work is done.
> 
> Yeah, you're perfectly right. It's better to return 0 here.

Why not void?

> > We should probably warn about errors which prevent from accounting but
> > I do not think there is much more we can do so returning an error code
> > from this function seems pointless. memcg_create_cache_work_func ignores
> > the return value anyway.
> 
> I do not think warnings are appropriate here, because it is not actually
> an error if we are short on memory and can't do proper memcg accounting
> due to this. Perhaps, we'd better add fail counters for memcg cache
> creations and/or accounting to the root cache instead of memcg's one.
> That would be useful for debugging. I'm not sure though.

warn on once per memcg would be probably sufficient but it would still
be great if an admin could see that a memcg is not accounted although it
is supposed to be. Scanning all the memcgs might be really impractical.
We do not fail allocations needed for those object in the real life now
but we shouldn't rely on that.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
