Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 82F416B00FC
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 11:18:47 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id hz20so3917207lab.33
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 08:18:46 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id x7si21696485lal.100.2014.06.10.08.18.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jun 2014 08:18:45 -0700 (PDT)
Date: Tue, 10 Jun 2014 19:18:34 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v2 8/8] slab: make dead memcg caches discard free
 slabs immediately
Message-ID: <20140610151830.GA8692@esperanza>
References: <cover.1402060096.git.vdavydov@parallels.com>
 <27a202c6084d6bb19cc3e417793f05104b908ded.1402060096.git.vdavydov@parallels.com>
 <20140610074317.GE19036@js1304-P5Q-DELUXE>
 <20140610100313.GA6293@esperanza>
 <alpine.DEB.2.10.1406100925270.17142@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1406100925270.17142@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linux-foundation.org, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 10, 2014 at 09:26:19AM -0500, Christoph Lameter wrote:
> On Tue, 10 Jun 2014, Vladimir Davydov wrote:
> 
> > Frankly, I incline to shrinking dead SLAB caches periodically from
> > cache_reap too, because it looks neater and less intrusive to me. Also
> > it has zero performance impact, which is nice.
> >
> > However, Christoph proposed to disable per cpu arrays for dead caches,
> > similarly to SLUB, and I decided to give it a try, just to see the end
> > code we'd have with it.
> >
> > I'm still not quite sure which way we should choose though...
> 
> Which one is cleaner?

To shrink dead caches aggressively, we only need to modify cache_reap
(see https://lkml.org/lkml/2014/5/30/271).

To zap object arrays for dead caches (this is what this patch does), we
have to:
 - set array_cache->limit to 0 for each per cpu, shared, and alien array
   caches on kmem_cache_shrink;
 - make cpu/node hotplug paths init new array cache sizes to 0;
 - make free paths (__cache_free, cache_free_alien) handle zero array
   cache size properly, because currently they doesn't.

So IMO the first one (reaping dead caches periodically) requires less
modifications and therefore is cleaner.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
