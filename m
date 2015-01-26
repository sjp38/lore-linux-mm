Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id BE89C6B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 15:43:32 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id kq14so13962234pab.0
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 12:43:32 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ci2si5703738pdb.192.2015.01.26.12.43.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 12:43:31 -0800 (PST)
Date: Mon, 26 Jan 2015 23:43:18 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 2/3] slab: zap kmem_cache_shrink return value
Message-ID: <20150126204318.GB3317@esperanza>
References: <cover.1422275084.git.vdavydov@parallels.com>
 <b89d28384f8ec7865c3fefc2f025955d55798b78.1422275084.git.vdavydov@parallels.com>
 <alpine.DEB.2.11.1501260949150.15849@gentwo.org>
 <20150126170418.GC28978@esperanza>
 <alpine.DEB.2.11.1501261226250.16638@gentwo.org>
 <20150126194838.GB2660@esperanza>
 <alpine.DEB.2.11.1501261353480.16786@gentwo.org>
 <20150126201602.GA3317@esperanza>
 <alpine.DEB.2.11.1501261427310.17468@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1501261427310.17468@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 26, 2015 at 02:28:33PM -0600, Christoph Lameter wrote:
> On Mon, 26 Jan 2015, Vladimir Davydov wrote:
> 
> > Right, but I just don't see why a subsystem using a kmem_cache would
> > need to check whether there are any objects left in the cache. I mean,
> > it should somehow keep track of the objects it's allocated anyway, e.g.
> > by linking them in a list. That means it must already have a way to
> > check if it is safe to destroy its cache or not.
> 
> The acpi subsystem did that at some point.
> 
> > Suppose we leave the return value as is. A subsystem, right before going
> > to destroy a cache, calls kmem_cache_shrink, which returns 1 (slab is
> > not empty). What is it supposed to do then?
> 
> That is up to the subsystem. If it has a means of tracking down the
> missing object then it can deal with it. If not then it cannot shutdown
> the cache and do a proper recovery action.

Hmm, we could make kmem_cache_destroy return EBUSY for the purpose.
However, since it spits warnings on failure, which is reasonable, we
have this check in kmem_cache_shrink...

Anyways, I see your point now, thank you for pointing it out. I will fix
SLUB's __kmem_cache_shrink retval instead of removing it altogether in
the next iteration.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
