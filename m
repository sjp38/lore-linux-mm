Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED1B76B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 06:38:38 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id z109so7209022wrb.19
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 03:38:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i75si2815402wmg.99.2017.12.20.03.38.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 03:38:37 -0800 (PST)
Date: Wed, 20 Dec 2017 12:38:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
Message-ID: <20171220113835.GO4831@dhcp22.suse.cz>
References: <20171219151341.GC15210@dhcp22.suse.cz>
 <20171219152536.GA591@tigerII.localdomain>
 <20171219155815.GC2787@dhcp22.suse.cz>
 <20171220071500.GA11774@jagdpanzerIV>
 <04faff62-0944-3c7d-15b0-9dc60054a830@gmail.com>
 <20171220083403.GC11774@jagdpanzerIV>
 <20171220090828.GB4831@dhcp22.suse.cz>
 <20171220091653.GE11774@jagdpanzerIV>
 <20171220092513.GF4831@dhcp22.suse.cz>
 <ad885766-69b8-940a-c69a-4c23779eb228@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ad885766-69b8-940a-c69a-4c23779eb228@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, A K <akaraliou.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, minchan@kernel.org, ngupta@vflare.org, linux-mm@kvack.org

On Wed 20-12-17 20:05:35, Tetsuo Handa wrote:
> On 2017/12/20 18:25, Michal Hocko wrote:
> > On Wed 20-12-17 18:16:53, Sergey Senozhatsky wrote:
> >> On (12/20/17 10:08), Michal Hocko wrote:
> >> [..]
> >>>> let's keep void zs_register_shrinker() and just suppress the
> >>>> register_shrinker() must_check warning.
> >>>
> >>> I would just hope we simply drop the must_check nonsense.
> >>
> >> agreed. given that unregister_shrinker() does not oops anymore,
> >> enforcing that check does not make that much sense.
> > 
> > Well, the registration failure is a failure like any others. Ignoring
> > the failure can have bad influence on the overal system behavior but
> > that is no different from thousands of other functions. must_check is an
> > overreaction here IMHO.
> > 
> 
> I don't think that must_check is an overreaction.
> As of linux-next-20171218, no patch is available for 10 locations.
> 
> drivers/staging/android/ion/ion_heap.c:306:     register_shrinker(&heap->shrinker);
> drivers/staging/android/ashmem.c:857:   register_shrinker(&ashmem_shrinker);
> drivers/gpu/drm/ttm/ttm_page_alloc_dma.c:1185:  register_shrinker(&manager->mm_shrink);
> drivers/gpu/drm/ttm/ttm_page_alloc.c:484:       register_shrinker(&manager->mm_shrink);
> drivers/gpu/drm/i915/i915_gem_shrinker.c:508:   WARN_ON(register_shrinker(&i915->mm.shrinker));
> drivers/gpu/drm/msm/msm_gem_shrinker.c:154:     WARN_ON(register_shrinker(&priv->shrinker));
> drivers/md/dm-bufio.c:1756:     register_shrinker(&c->shrinker);
> drivers/android/binder_alloc.c:1012:    register_shrinker(&binder_shrinker);
> arch/x86/kvm/mmu.c:5485:        register_shrinker(&mmu_shrinker);
> fs/xfs/xfs_qm.c:698:    register_shrinker(&qinf->qi_shrinker);

And how exactly has the must_check helped for those? Come on, start
being serious finally. This is a matter of fixing those. You have done
a good deal of work for some, it just takes to finish the rest. The
warning doesn't help on its own, it just makes people ignore it after
some time or make it silent in some way.

> We have out of tree modules. And as a troubleshooting staff at
> a support center, I want to be able to identify the careless module.

I do not care the slightest about those, to be honest. We assume a
certain level of sanity from _any_ code running in the kernel and
handling error paths properly is a part of that assumption.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
