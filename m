Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B48866B0253
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 10:38:04 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id z128so187139153pfb.4
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 07:38:04 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id i19si16016919pgk.91.2017.01.14.07.38.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 07:38:03 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id 204so1216942pge.2
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 07:38:03 -0800 (PST)
Date: Sat, 14 Jan 2017 10:38:01 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/9] slab: simplify shutdown_memcg_caches()
Message-ID: <20170114153801.GB32693@mtj.duckdns.org>
References: <20170114055449.11044-1-tj@kernel.org>
 <20170114055449.11044-4-tj@kernel.org>
 <20170114132722.GB2668@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114132722.GB2668@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@tarantool.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Sat, Jan 14, 2017 at 04:27:22PM +0300, Vladimir Davydov wrote:
> > -	 * Second, shutdown all caches left from memory cgroups that are now
> > -	 * offline.
> > +	 * Shutdown all caches.
> >  	 */
> >  	list_for_each_entry_safe(c, c2, &s->memcg_params.list,
> >  				 memcg_params.list)
> >  		shutdown_cache(c);
> 
> The point of this complexity was to leave caches that happen to have
> objects when kmem_cache_destroy() is called on the list, so that they
> could be reused later. This behavior was inherited from the global

Ah, right, I misread the branch.  I don't quite get how the cache can
be reused later tho?  This is called when the memcg gets released and
a clear error condition - the caller, kmem_cache_destroy(), handles it
as an error condition too.

> caches - if kmem_cache_destroy() is called on a cache that still has
> object, we print a warning message and don't destroy the cache. This
> patch changes this behavior.

Hmm... yeah, we're missing the error return propagation.  I think
that's the only meaningful difference tho, right?  Will update the
patch.

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
