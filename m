Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4566B6B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 18:05:33 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id f8so1264100wiw.4
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 15:05:32 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id t19si4937744wij.96.2014.07.08.15.05.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 15:05:32 -0700 (PDT)
Date: Tue, 8 Jul 2014 18:05:19 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm 0/8] memcg: reparent kmem on css offline
Message-ID: <20140708220519.GB29639@cmpxchg.org>
References: <cover.1404733720.git.vdavydov@parallels.com>
 <20140707142506.GB1149@cmpxchg.org>
 <20140707154008.GH13827@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140707154008.GH13827@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 07, 2014 at 07:40:08PM +0400, Vladimir Davydov wrote:
> On Mon, Jul 07, 2014 at 10:25:06AM -0400, Johannes Weiner wrote:
> > You could then reap dead slab caches as part of the regular per-memcg
> > slab scanning in reclaim, without having to resort to auxiliary lists,
> > vmpressure events etc.
> 
> Do you mean adding a per memcg shrinker that will call kmem_cache_shrink
> for all memcg caches on memcg/global pressure?
> 
> Actually I recently made dead caches self-destructive at the cost of
> slowing down kfrees to dead caches (see
> https://www.lwn.net/Articles/602330/, it's already in the mmotm tree) so
> no dead cache reaping is necessary. Do you think if we need it now?
>
> > I think it would save us a lot of code and complexity.  You want
> > per-memcg slab scanning *anyway*, all we'd have to change in the
> > existing code would be to pin the css until the LRUs and kmem caches
> > are truly empty, and switch mem_cgroup_iter() to css_tryget().
> > 
> > Would this make sense to you?
> 
> Hmm, interesting. Thank you for such a thorough explanation.
> 
> One question. Do we still need to free mem_cgroup->kmemcg_id on css
> offline so that it can be reused by new kmem-active cgroups (currently
> we don't)?
> 
> If we won't free it the root_cache->memcg_params->memcg_arrays may
> become really huge due to lots of dead css holding the id.

We only need the O(1) access of the array for allocation - not frees
and reclaim, right?

So with your self-destruct code, can we prune caches of dead css and
then just remove them from the array?  Or move them from the array to
a per-memcg linked list that can be scanned on memcg memory pressure?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
