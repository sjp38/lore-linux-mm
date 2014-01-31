Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6DD6B0037
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 05:42:28 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id md12so4227201pbc.26
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 02:42:28 -0800 (PST)
Received: from mail-pb0-x233.google.com (mail-pb0-x233.google.com [2607:f8b0:400e:c01::233])
        by mx.google.com with ESMTPS id fl7si10027840pad.26.2014.01.31.02.42.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Jan 2014 02:42:27 -0800 (PST)
Received: by mail-pb0-f51.google.com with SMTP id un15so4241389pbc.24
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 02:42:27 -0800 (PST)
Date: Fri, 31 Jan 2014 02:42:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memcg: fix mutex not unlocked on memcg_create_kmem_cache
 fail path
In-Reply-To: <52EB487B.6040701@parallels.com>
Message-ID: <alpine.DEB.2.02.1401310241080.7183@chino.kir.corp.google.com>
References: <1391097693-31401-1-git-send-email-vdavydov@parallels.com> <20140130130129.6f8bd7fd9da55d17a9338443@linux-foundation.org> <alpine.DEB.2.02.1401301310270.15271@chino.kir.corp.google.com> <20140130132939.96a25a37016a12f9a0093a90@linux-foundation.org>
 <alpine.DEB.2.02.1401301336530.15271@chino.kir.corp.google.com> <20140130135002.22ce1c12b7136f75e5985df6@linux-foundation.org> <alpine.DEB.2.02.1401301403090.15271@chino.kir.corp.google.com> <20140130140902.93d35d866f9ea1c697811f6e@linux-foundation.org>
 <alpine.DEB.2.02.1401301411590.15271@chino.kir.corp.google.com> <20140130141538.a9e3977b5e7b76bdcf59a15f@linux-foundation.org> <alpine.DEB.2.02.1401301438500.12223@chino.kir.corp.google.com> <52EB487B.6040701@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 31 Jan 2014, Vladimir Davydov wrote:

> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -637,6 +637,9 @@ int memcg_limited_groups_array_size;
> >   * better kept as an internal representation in cgroup.c. In any case, the
> >   * cgrp_id space is not getting any smaller, and we don't have to necessarily
> >   * increase ours as well if it increases.
> > + *
> > + * Updates to MAX_SIZE should update the space for the memcg name in
> > + * memcg_create_kmem_cache().
> >   */
> >  #define MEMCG_CACHES_MIN_SIZE 4
> >  #define MEMCG_CACHES_MAX_SIZE MEM_CGROUP_ID_MAX
> > @@ -3400,8 +3403,10 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
> >  static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
> >  						  struct kmem_cache *s)
> >  {
> > -	char *name = NULL;
> >  	struct kmem_cache *new;
> > +	const char *cgrp_name;
> > +	char *name = NULL;
> > +	size_t len;
> >  
> >  	BUG_ON(!memcg_can_account_kmem(memcg));
> >  
> > @@ -3409,9 +3414,22 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
> >  	if (unlikely(!name))
> >  		return NULL;
> >  
> > +	/*
> > +	 * Format of a memcg's kmem cache name:
> > +	 * <cache-name>(<memcg-id>:<cgroup-name>)
> > +	 */
> > +	len = strlen(s->name);
> > +	/* Space for parentheses, colon, terminator */
> > +	len += 4;
> > +	/* MEMCG_CACHES_MAX_SIZE is USHRT_MAX */
> > +	len += 5;
> > +	BUILD_BUG_ON(MEMCG_CACHES_MAX_SIZE > USHRT_MAX);
> > +
> 
> This looks cumbersome, IMO. Let's leave it as is for now. AFAIK,
> cgroup_name() will be reworked soon so that it won't require RCU-context
> (https://lkml.org/lkml/2014/1/28/530). Therefore, it will be possible to
> get rid of this pointless tmp_name allocation by making
> kmem_cache_create_memcg() take not just name, but printf-like format +
> vargs.
> 

You believe it's less cumbersome to do two memory allocations to figure 
out how much memory you really need to allocate rather than just 
calculating the necessary size?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
