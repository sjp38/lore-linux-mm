Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 033F36B0266
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 07:41:35 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fe3so88896702pab.1
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 04:41:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id 25si20884170pfh.120.2016.04.01.04.41.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Apr 2016 04:41:34 -0700 (PDT)
Date: Fri, 1 Apr 2016 13:41:29 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH -mm v2 3/3] slub: make dead caches discard free slabs
 immediately
Message-ID: <20160401114129.GR3430@twins.programming.kicks-ass.net>
References: <cover.1422461573.git.vdavydov@parallels.com>
 <6eecfafdc6c3dcbb98d2176cdebcb65abbc180b4.1422461573.git.vdavydov@parallels.com>
 <20160401090441.GD12845@twins.programming.kicks-ass.net>
 <20160401105539.GA6610@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160401105539.GA6610@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Apr 01, 2016 at 01:55:40PM +0300, Vladimir Davydov wrote:
> > > +	if (deactivate) {
> > > +		/*
> > > +		 * Disable empty slabs caching. Used to avoid pinning offline
> > > +		 * memory cgroups by kmem pages that can be freed.
> > > +		 */
> > > +		s->cpu_partial = 0;
> > > +		s->min_partial = 0;
> > > +
> > > +		/*
> > > +		 * s->cpu_partial is checked locklessly (see put_cpu_partial),
> > > +		 * so we have to make sure the change is visible.
> > > +		 */
> > > +		kick_all_cpus_sync();
> > > +	}
> > 
> > Argh! what the heck! and without a single mention in the changelog.
> 
> This function is only called when a memory cgroup is removed, which is
> rather a rare event. I didn't think it would cause any pain. Sorry.

Suppose you have a bunch of CPUs running HPC/RT code and someone causes
the admin CPUs to create/destroy a few cgroups.

> > Why are you spraying IPIs across the entire machine? Why isn't
> > synchronize_sched() good enough, that would allow you to get rid of the
> > local_irq_save/restore as well.
> 
> synchronize_sched() is slower. Calling it for every per memcg kmem cache
> would slow down cleanup on cgroup removal.

Right, but who cares? cgroup removal isn't a fast path by any standard.

> Regarding local_irq_save/restore - synchronize_sched() wouldn't allow us
> to get rid of them, because unfreeze_partials() must be called with irqs
> disabled.

OK, I figured it was because it needed to be serialized against this
kick_all_cpus_sync() IPI.

> Come to think of it, kick_all_cpus_sync() is used as a memory barrier
> here, so as to make sure that after it's finished all cpus will use the
> new ->cpu_partial value, which makes me wonder if we could replace it
> with a simple smp_mb. I mean, this_cpu_cmpxchg(), which is used by
> put_cpu_partial to add a page to per-cpu partial list, must issue a full
> memory barrier (am I correct?), so we have two possibilities here:

Nope, this_cpu_cmpxchg() does not imply a memory barrier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
