Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9A7216B0256
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 15:12:28 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so184922635pac.3
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 12:12:28 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id pp8si24395059pbc.2.2015.11.09.12.12.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 12:12:27 -0800 (PST)
Date: Mon, 9 Nov 2015 23:12:18 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 0/5] memcg/kmem: switch to white list policy
Message-ID: <20151109201218.GP31308@esperanza>
References: <cover.1446924358.git.vdavydov@virtuozzo.com>
 <20151109140832.GE8916@dhcp22.suse.cz>
 <20151109182840.GJ31308@esperanza>
 <20151109185401.GB28507@mtj.duckdns.org>
 <20151109192747.GN31308@esperanza>
 <20151109193253.GC28507@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151109193253.GC28507@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Nov 09, 2015 at 02:32:53PM -0500, Tejun Heo wrote:
> On Mon, Nov 09, 2015 at 10:27:47PM +0300, Vladimir Davydov wrote:
> > Of course, we could rework slab merging so that kmem_cache_create
> > returned a new dummy cache even if it was actually merged. Such a cache
> > would point to the real cache, which would be used for allocations. This
> > wouldn't limit slab merging, but this would add one more dereference to
> > alloc path, which is even worse.
> 
> Hmmm, this could be me not really understanding but why can't we let
> all slabs to be merged regardless of SLAB_ACCOUNT flag for root memcg
> and point to per-memcg slabs (may be merged among them but most likely

Because we won't be able to distinguish kmem_cache_alloc calls that
should be accounted from those that shouldn't. The problem is if two
caches

	A = kmem_cache_create(...)

and

	B = kmem_cache_create(...)

happen to be merged, A and B will point to the same kmem_cache struct.
As a result, there is no way to distinguish

	kmem_cache_alloc(A)

which we want to account from

	kmem_cache_alloc(B)

which we don't.

> won't matter) for !root.  We're indirecting once anyway, no?

If kmem accounting is not used, we aren't indirecting. That's why I
don't think we can use dummy kmem_cache struct for merged caches, where
we could store __GFP_ACCOUNT flag.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
