Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1FC0B6B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 04:45:29 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id c41so342617eek.8
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 01:45:28 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a9si3541976eew.75.2013.12.19.01.45.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 01:45:28 -0800 (PST)
Date: Thu, 19 Dec 2013 10:45:27 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [Devel] [PATCH 1/6] slab: cleanup kmem_cache_create_memcg()
Message-ID: <20131219094527.GC10855@dhcp22.suse.cz>
References: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com>
 <52B2AB7C.1010803@parallels.com>
 <52B2B0A4.8050009@parallels.com>
 <52B2BBB4.3090209@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52B2BBB4.3090209@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasily Averin <vvs@parallels.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Glauber Costa <glommer@gmail.com>, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, devel@openvz.org

On Thu 19-12-13 13:26:12, Vasily Averin wrote:
> On 12/19/2013 12:39 PM, Vladimir Davydov wrote:
> > On 12/19/2013 12:17 PM, Vasily Averin wrote:
> >> On 12/18/2013 05:16 PM, Vladimir Davydov wrote:
> >>> --- a/mm/slab_common.c
> >>> +++ b/mm/slab_common.c
> >>> @@ -176,8 +176,9 @@ kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size_t size,
> >>>  	get_online_cpus();
> >>>  	mutex_lock(&slab_mutex);
> >>>  
> >>> -	if (!kmem_cache_sanity_check(memcg, name, size) == 0)
> >>> -		goto out_locked;
> >>> +	err = kmem_cache_sanity_check(memcg, name, size);
> >>> +	if (err)
> >>> +		goto out_unlock;
> >>>  
> >>>  	/*
> >>>  	 * Some allocators will constraint the set of valid flags to a subset
> >> Theoretically in future kmem_cache_sanity_check() can return positive value.
> >> Probably it's better to check (err < 0) in caller ?
> > 
> > Hmm, why? What information could positive retval carry here? We have
> > plenty of places throughout the code where we check for (err), not
> > (err<0), simply because it looks clearer, e.g. look at
> > __kmem_cache_create() calls. If it returns a positive value one day, we
> > will have to parse every place where it's called. Anyway, if someone
> > wants to change a function behavior, he must check every place where
> > this function is called and fix them accordingly.
> 
> I believe expected semantic of function -- return negative in case of error.
> So correct error cheek should be (err < 0).
> (err) check is semantically incorrect, and it can lead to troubles in future.

No, this function returns -ERRNO or 0 on success.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
