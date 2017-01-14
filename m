Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id C26916B0253
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 10:53:50 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 67so96570684ioh.1
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 07:53:50 -0800 (PST)
Received: from mail-io0-x243.google.com (mail-io0-x243.google.com. [2607:f8b0:4001:c06::243])
        by mx.google.com with ESMTPS id b131si4327922itb.34.2017.01.14.07.53.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 07:53:50 -0800 (PST)
Received: by mail-io0-x243.google.com with SMTP id q20so8454397ioi.3
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 07:53:50 -0800 (PST)
Date: Sat, 14 Jan 2017 10:53:43 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/9] slab: simplify shutdown_memcg_caches()
Message-ID: <20170114155343.GA13589@mtj.duckdns.org>
References: <20170114055449.11044-1-tj@kernel.org>
 <20170114055449.11044-4-tj@kernel.org>
 <20170114132722.GB2668@esperanza>
 <20170114153801.GB32693@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170114153801.GB32693@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@tarantool.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Sat, Jan 14, 2017 at 10:38:01AM -0500, Tejun Heo wrote:
> On Sat, Jan 14, 2017 at 04:27:22PM +0300, Vladimir Davydov wrote:
> > > -	 * Second, shutdown all caches left from memory cgroups that are now
> > > -	 * offline.
> > > +	 * Shutdown all caches.
> > >  	 */
> > >  	list_for_each_entry_safe(c, c2, &s->memcg_params.list,
> > >  				 memcg_params.list)
> > >  		shutdown_cache(c);
> > 
> > The point of this complexity was to leave caches that happen to have
> > objects when kmem_cache_destroy() is called on the list, so that they
> > could be reused later. This behavior was inherited from the global
> 
> Ah, right, I misread the branch.  I don't quite get how the cache can
> be reused later tho?  This is called when the memcg gets released and
> a clear error condition - the caller, kmem_cache_destroy(), handles it
> as an error condition too.

I think I understand it now.  This is the alias being able to find and
reuse the cache.  Heh, that's a weird optimization for a corner error
case.  Anyways, I'll drop this patch.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
