Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 20F186B0003
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 12:42:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id y26-v6so3452999pfn.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 09:42:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q9-v6si7654945pll.370.2018.06.22.09.42.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jun 2018 09:42:47 -0700 (PDT)
Date: Fri, 22 Jun 2018 18:42:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Intel-gfx] [RFC PATCH] mm, oom: distinguish blockable mode for
 mmu notifiers
Message-ID: <20180622164243.GB23674@dhcp22.suse.cz>
References: <20180622150242.16558-1-mhocko@kernel.org>
 <152968180950.11773.3374981930722769733@mail.alporthouse.com>
 <20180622155716.GE10465@dhcp22.suse.cz>
 <20180622161845.GA3497@redhat.com>
 <20180622164026.GA23674@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180622164026.GA23674@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, =?us-ascii?B?PT9VVEYtOD9xP1JhZGltPTIwS3I9QzQ9OERtPUMzPUExPUM1PTk5Pz0=?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, =?us-ascii?B?PT9VVEYtOD9xP0NocmlzdGlhbj0yMEs9QzM9QjZuaWc/PQ==?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

[Resnding with the CC list fixed]

On Fri 22-06-18 18:40:26, Michal Hocko wrote:
> On Fri 22-06-18 12:18:46, Jerome Glisse wrote:
> > On Fri, Jun 22, 2018 at 05:57:16PM +0200, Michal Hocko wrote:
> > > On Fri 22-06-18 16:36:49, Chris Wilson wrote:
> > > > Quoting Michal Hocko (2018-06-22 16:02:42)
> > > > > Hi,
> > > > > this is an RFC and not tested at all. I am not very familiar with the
> > > > > mmu notifiers semantics very much so this is a crude attempt to achieve
> > > > > what I need basically. It might be completely wrong but I would like
> > > > > to discuss what would be a better way if that is the case.
> > > > > 
> > > > > get_maintainers gave me quite large list of people to CC so I had to trim
> > > > > it down. If you think I have forgot somebody, please let me know
> > > > 
> > > > > diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
> > > > > index 854bd51b9478..5285df9331fa 100644
> > > > > --- a/drivers/gpu/drm/i915/i915_gem_userptr.c
> > > > > +++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
> > > > > @@ -112,10 +112,11 @@ static void del_object(struct i915_mmu_object *mo)
> > > > >         mo->attached = false;
> > > > >  }
> > > > >  
> > > > > -static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
> > > > > +static int i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
> > > > >                                                        struct mm_struct *mm,
> > > > >                                                        unsigned long start,
> > > > > -                                                      unsigned long end)
> > > > > +                                                      unsigned long end,
> > > > > +                                                      bool blockable)
> > > > >  {
> > > > >         struct i915_mmu_notifier *mn =
> > > > >                 container_of(_mn, struct i915_mmu_notifier, mn);
> > > > > @@ -124,7 +125,7 @@ static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
> > > > >         LIST_HEAD(cancelled);
> > > > >  
> > > > >         if (RB_EMPTY_ROOT(&mn->objects.rb_root))
> > > > > -               return;
> > > > > +               return 0;
> > > > 
> > > > The principle wait here is for the HW (even after fixing all the locks
> > > > to be not so coarse, we still have to wait for the HW to finish its
> > > > access).
> > > 
> > > Is this wait bound or it can take basically arbitrary amount of time?
> > 
> > Arbitrary amount of time but in desktop use case you can assume that
> > it should never go above 16ms for a 60frame per second rendering of
> > your desktop (in GPU compute case this kind of assumption does not
> > hold). Is the process exit_state already updated by the time this mmu
> > notifier callbacks happen ?
> 
> What do you mean? The process is killed (by SIGKILL) at the time but we
> do not know much more than that. The task might be stuck anywhere in the
> kernel before handling that signal.
> 
> > > > The first pass would be then to not do anything here if
> > > > !blockable.
> > > 
> > > something like this? (incremental diff)
> > 
> > What i wanted to do with HMM and mmu notifier is split the invalidation
> > in 2 pass. First pass tell the drivers to stop/cancel pending jobs that
> > depends on the range and invalidate internal driver states (like clear
> > buffer object pages array in case of GPU but not GPU page table). While
> > the second callback would do the actual wait on the GPU to be done and
> > update the GPU page table.
> 
> What can you do after the first phase? Can I unmap the range?
> 
> > Now in this scheme in case the task is already in some exit state and
> > that all CPU threads are frozen/kill then we can probably find a way to
> > do the first path mostly lock less. AFAICR nor AMD nor Intel allow to
> > share userptr bo hence a uptr bo should only ever be access through
> > ioctl submited by the process.
> > 
> > The second call can then be delayed and ping from time to time to see
> > if GPU jobs are done.
> > 
> > 
> > Note that what you propose might still be useful as in case there is
> > no buffer object for a range then OOM can make progress in freeing a
> > range of memory. It is very likely that significant virtual address
> > range of a process and backing memory can be reclaim that way. This
> > assume OOM reclaim vma by vma or in some form of granularity like
> > reclaiming 1GB by 1GB. Or we could also update blocking callback to
> > return range that are blocking that way OOM can reclaim around.
> 
> Exactly my point. What we have right now is all or nothing which is
> obviously too coarse to be useful.

-- 
Michal Hocko
SUSE Labs
