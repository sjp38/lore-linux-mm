Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5267B6B006E
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 15:16:14 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id y10so13915239pdj.7
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 12:16:14 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ln8si13501138pab.120.2015.01.26.12.16.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 12:16:13 -0800 (PST)
Date: Mon, 26 Jan 2015 23:16:02 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 2/3] slab: zap kmem_cache_shrink return value
Message-ID: <20150126201602.GA3317@esperanza>
References: <cover.1422275084.git.vdavydov@parallels.com>
 <b89d28384f8ec7865c3fefc2f025955d55798b78.1422275084.git.vdavydov@parallels.com>
 <alpine.DEB.2.11.1501260949150.15849@gentwo.org>
 <20150126170418.GC28978@esperanza>
 <alpine.DEB.2.11.1501261226250.16638@gentwo.org>
 <20150126194838.GB2660@esperanza>
 <alpine.DEB.2.11.1501261353480.16786@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1501261353480.16786@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 26, 2015 at 01:55:14PM -0600, Christoph Lameter wrote:
> On Mon, 26 Jan 2015, Vladimir Davydov wrote:
> 
> > Hmm, why? The return value has existed since this function was
> > introduced, but nobody seems to have ever used it outside the slab core.
> > Besides, this check is racy, so IMO we shouldn't encourage users of the
> > API to rely on it. That said, I believe we should drop the return value
> > for now. If anybody ever needs it, we can reintroduce it.
> 
> The check is only racy if you have concurrent users. It is not racy if a
> subsystem shuts down access to the slabs and then checks if everything is
> clean before closing the cache.
>
> Slab creation and destruction are not serialized. It is the responsibility
> of the subsystem to make sure that there are no concurrent users and that
> there are no objects remaining before destroying a slab.

Right, but I just don't see why a subsystem using a kmem_cache would
need to check whether there are any objects left in the cache. I mean,
it should somehow keep track of the objects it's allocated anyway, e.g.
by linking them in a list. That means it must already have a way to
check if it is safe to destroy its cache or not.

Suppose we leave the return value as is. A subsystem, right before going
to destroy a cache, calls kmem_cache_shrink, which returns 1 (slab is
not empty). What is it supposed to do then?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
