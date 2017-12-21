Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 46A116B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 02:25:35 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id z3so10992821plh.18
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 23:25:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i3si12391488pli.682.2017.12.20.23.25.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Dec 2017 23:25:33 -0800 (PST)
Date: Thu, 21 Dec 2017 08:25:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/zsmalloc: simplify shrinker init/destroy
Message-ID: <20171221072530.GX4831@dhcp22.suse.cz>
References: <20171220071500.GA11774@jagdpanzerIV>
 <04faff62-0944-3c7d-15b0-9dc60054a830@gmail.com>
 <20171220083403.GC11774@jagdpanzerIV>
 <20171220090828.GB4831@dhcp22.suse.cz>
 <20171220091653.GE11774@jagdpanzerIV>
 <20171220092513.GF4831@dhcp22.suse.cz>
 <ad885766-69b8-940a-c69a-4c23779eb228@I-love.SAKURA.ne.jp>
 <20171220113835.GO4831@dhcp22.suse.cz>
 <20171220115751.GP4831@dhcp22.suse.cz>
 <ece75ffc-7960-5551-aa10-4dced24bc0b2@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ece75ffc-7960-5551-aa10-4dced24bc0b2@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aliaksei Karaliou <akaraliou.dev@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, minchan@kernel.org, ngupta@vflare.org, linux-mm@kvack.org

On Thu 21-12-17 00:20:44, Aliaksei Karaliou wrote:
> 
> 
> On 12/20/2017 02:57 PM, Michal Hocko wrote:
> > On Wed 20-12-17 12:38:35, Michal Hocko wrote:
> > > On Wed 20-12-17 20:05:35, Tetsuo Handa wrote:
> > > > On 2017/12/20 18:25, Michal Hocko wrote:
> > > > > On Wed 20-12-17 18:16:53, Sergey Senozhatsky wrote:
> > > > > > On (12/20/17 10:08), Michal Hocko wrote:
> > > > > > [..]
> > > > > > > > let's keep void zs_register_shrinker() and just suppress the
> > > > > > > > register_shrinker() must_check warning.
> > > > > > > I would just hope we simply drop the must_check nonsense.
> > > > > > agreed. given that unregister_shrinker() does not oops anymore,
> > > > > > enforcing that check does not make that much sense.
> > > > > Well, the registration failure is a failure like any others. Ignoring
> > > > > the failure can have bad influence on the overal system behavior but
> > > > > that is no different from thousands of other functions. must_check is an
> > > > > overreaction here IMHO.
> > > > > 
> > > > I don't think that must_check is an overreaction.
> > > > As of linux-next-20171218, no patch is available for 10 locations.
> > > > 
> > > > drivers/staging/android/ion/ion_heap.c:306:     register_shrinker(&heap->shrinker);
> > > > drivers/staging/android/ashmem.c:857:   register_shrinker(&ashmem_shrinker);
> > > > drivers/gpu/drm/ttm/ttm_page_alloc_dma.c:1185:  register_shrinker(&manager->mm_shrink);
> > > > drivers/gpu/drm/ttm/ttm_page_alloc.c:484:       register_shrinker(&manager->mm_shrink);
> > > > drivers/gpu/drm/i915/i915_gem_shrinker.c:508:   WARN_ON(register_shrinker(&i915->mm.shrinker));
> > > > drivers/gpu/drm/msm/msm_gem_shrinker.c:154:     WARN_ON(register_shrinker(&priv->shrinker));
> > > > drivers/md/dm-bufio.c:1756:     register_shrinker(&c->shrinker);
> > > > drivers/android/binder_alloc.c:1012:    register_shrinker(&binder_shrinker);
> > > > arch/x86/kvm/mmu.c:5485:        register_shrinker(&mmu_shrinker);
> > > > fs/xfs/xfs_qm.c:698:    register_shrinker(&qinf->qi_shrinker);
> > > And how exactly has the must_check helped for those? Come on, start
> > > being serious finally. This is a matter of fixing those. You have done
> > > a good deal of work for some, it just takes to finish the rest. The
> > > warning doesn't help on its own, it just makes people ignore it after
> > > some time or make it silent in some way.
> > Also have a look at how WARN_ON simply papers over the wrong code and
> > must_check will not help you the slightest.
> 
> Regarding the other locations where return code is ignored, I think I will
> try to fix them as I did in Lustre code recently.

That would be really appreciated!

> However, it might be not straightforward and zsmalloc is good example -
> we understand that failure is not critical and we can live without shrinker.
> 
> Locations specified by Michal are also different, for example:
> 
> drivers/gpu/drm/i915/i915_gem_shrinker.c:508:   WARN_ON(register_shrinker(&i915->mm.shrinker));
> - this change is intentional.

I would be careful here. I believe that the WARN_ON is not a solution
here. i915 can allocated _a lot_ of memory IIRC so a missing shrinker can
be really problematic. Talk to i915 people.

> arch/x86/kvm/mmu.c:5485:        register_shrinker(&mmu_shrinker);
> - was made before register_shrinker() became non-void.

Yes this would be the case for the most shrinkers. Glauber simply didn't
bother to handle those because failing registration is basically
impossible.

> and so on. The question is what to do in each particular case ?

Bail out unless the shrinker is along the zsmalloc case.

> Some people may consider wrapping it with WARN_ON to be rather good option too
> while the others will prefer to consider it as a critical failure or at least
> do their own logging, with still looks similar with WARN_ON for me imho.

Talk to respective maintainers and they will give hints.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
