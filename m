Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9F2086B0036
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 03:26:12 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id c11so4782396lbj.3
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 00:26:11 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id h5si39417166lab.33.2014.07.09.00.26.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jul 2014 00:26:10 -0700 (PDT)
Date: Wed, 9 Jul 2014 11:25:59 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 0/8] memcg: reparent kmem on css offline
Message-ID: <20140709072559.GE6685@esperanza>
References: <cover.1404733720.git.vdavydov@parallels.com>
 <20140707142506.GB1149@cmpxchg.org>
 <20140707154008.GH13827@esperanza>
 <20140708220519.GB29639@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140708220519.GB29639@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 08, 2014 at 06:05:19PM -0400, Johannes Weiner wrote:
> On Mon, Jul 07, 2014 at 07:40:08PM +0400, Vladimir Davydov wrote:
> > On Mon, Jul 07, 2014 at 10:25:06AM -0400, Johannes Weiner wrote:
> > > You could then reap dead slab caches as part of the regular per-memcg
> > > slab scanning in reclaim, without having to resort to auxiliary lists,
> > > vmpressure events etc.
> > 
> > Do you mean adding a per memcg shrinker that will call kmem_cache_shrink
> > for all memcg caches on memcg/global pressure?
> > 
> > Actually I recently made dead caches self-destructive at the cost of
> > slowing down kfrees to dead caches (see
> > https://www.lwn.net/Articles/602330/, it's already in the mmotm tree) so
> > no dead cache reaping is necessary. Do you think if we need it now?
> >
> > > I think it would save us a lot of code and complexity.  You want
> > > per-memcg slab scanning *anyway*, all we'd have to change in the
> > > existing code would be to pin the css until the LRUs and kmem caches
> > > are truly empty, and switch mem_cgroup_iter() to css_tryget().
> > > 
> > > Would this make sense to you?
> > 
> > Hmm, interesting. Thank you for such a thorough explanation.
> > 
> > One question. Do we still need to free mem_cgroup->kmemcg_id on css
> > offline so that it can be reused by new kmem-active cgroups (currently
> > we don't)?
> > 
> > If we won't free it the root_cache->memcg_params->memcg_arrays may
> > become really huge due to lots of dead css holding the id.
> 
> We only need the O(1) access of the array for allocation - not frees
> and reclaim, right?

Yes.

> So with your self-destruct code, can we prune caches of dead css and
> then just remove them from the array?  Or move them from the array to
> a per-memcg linked list that can be scanned on memcg memory pressure?

This shouldn't be a problem. Will do that.

Actually, I now doubt if we need self-destruct at all. I don't really
like it, because its implementations is rather ugly, and, what is worse,
it slows down kfree for dead caches noticeably. SLAB maintainers doesn't
seem to be fond of it either. May be, we'd better drop this in favour of
shrinking dead caches on memory pressure?

Then *empty* dead caches will be pending until memory pressure reaps
them, which looks a bit strange, because there's absolutely no reason to
keep them for so long. However, the code will be simpler then, and
kfrees to dead caches will proceed at the same speed as to active
caches.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
