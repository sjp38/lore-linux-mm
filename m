Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A75A6B0269
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 12:18:52 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u20-v6so5990277qkk.20
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 09:18:52 -0700 (PDT)
Date: Fri, 22 Jun 2018 12:18:46 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [Intel-gfx] [RFC PATCH] mm, oom: distinguish blockable mode for
 mmu notifiers
Message-ID: <20180622161845.GA3497@redhat.com>
References: <20180622150242.16558-1-mhocko@kernel.org>
 <152968180950.11773.3374981930722769733@mail.alporthouse.com>
 <20180622155716.GE10465@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180622155716.GE10465@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko =?utf-8?B?PG1ob2Nrb0BzdXNlLmNvbT4sIGt2bUB2Z2VyLmtlcm5l?= =?utf-8?B?bC5vcmcsICAiIFJhZGltIEtyxI1tw6HFmSA8cmtyY21hckByZWRoYXQuY29t?= =?utf-8?B?Piw=?= David Airlie <airlied@linux.ie>, Sudeep Dutt <sudeep.dutt@intel.com>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Dimitri Sivanich <sivanich@sgi.com>, linux-rdma@vger.kernel.org, amd-gfx@lists.freedesktop.org, Jason Gunthorpe <jgg@ziepe.ca>, Doug Ledford <dledford@redhat.com>, David Rientjes <rientjes@google.com>, xen-devel@lists.xenproject.org, intel-gfx@lists.freedesktop.org, Rodrigo@kvack.org, Vivi@kvack.org, Boris@kvack.org, Ostrovsky@kvack.org, Juergen@kvack.org, Gross@kvack.org, Mike@kvack.org, Marciniszyn@kvack.org, Dennis@kvack.org, Dalessandro@kvack.org, Ashutosh@kvack.org, Dixit@kvack.org, Alex@kvack.org, Deucher@kvack.org, Paolo@kvack.org, Bonzini@kvack.org

On Fri, Jun 22, 2018 at 05:57:16PM +0200, Michal Hocko wrote:
> On Fri 22-06-18 16:36:49, Chris Wilson wrote:
> > Quoting Michal Hocko (2018-06-22 16:02:42)
> > > Hi,
> > > this is an RFC and not tested at all. I am not very familiar with the
> > > mmu notifiers semantics very much so this is a crude attempt to achieve
> > > what I need basically. It might be completely wrong but I would like
> > > to discuss what would be a better way if that is the case.
> > > 
> > > get_maintainers gave me quite large list of people to CC so I had to trim
> > > it down. If you think I have forgot somebody, please let me know
> > 
> > > diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
> > > index 854bd51b9478..5285df9331fa 100644
> > > --- a/drivers/gpu/drm/i915/i915_gem_userptr.c
> > > +++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
> > > @@ -112,10 +112,11 @@ static void del_object(struct i915_mmu_object *mo)
> > >         mo->attached = false;
> > >  }
> > >  
> > > -static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
> > > +static int i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
> > >                                                        struct mm_struct *mm,
> > >                                                        unsigned long start,
> > > -                                                      unsigned long end)
> > > +                                                      unsigned long end,
> > > +                                                      bool blockable)
> > >  {
> > >         struct i915_mmu_notifier *mn =
> > >                 container_of(_mn, struct i915_mmu_notifier, mn);
> > > @@ -124,7 +125,7 @@ static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
> > >         LIST_HEAD(cancelled);
> > >  
> > >         if (RB_EMPTY_ROOT(&mn->objects.rb_root))
> > > -               return;
> > > +               return 0;
> > 
> > The principle wait here is for the HW (even after fixing all the locks
> > to be not so coarse, we still have to wait for the HW to finish its
> > access).
> 
> Is this wait bound or it can take basically arbitrary amount of time?

Arbitrary amount of time but in desktop use case you can assume that
it should never go above 16ms for a 60frame per second rendering of
your desktop (in GPU compute case this kind of assumption does not
hold). Is the process exit_state already updated by the time this mmu
notifier callbacks happen ?

> 
> > The first pass would be then to not do anything here if
> > !blockable.
> 
> something like this? (incremental diff)

What i wanted to do with HMM and mmu notifier is split the invalidation
in 2 pass. First pass tell the drivers to stop/cancel pending jobs that
depends on the range and invalidate internal driver states (like clear
buffer object pages array in case of GPU but not GPU page table). While
the second callback would do the actual wait on the GPU to be done and
update the GPU page table.

Now in this scheme in case the task is already in some exit state and
that all CPU threads are frozen/kill then we can probably find a way to
do the first path mostly lock less. AFAICR nor AMD nor Intel allow to
share userptr bo hence a uptr bo should only ever be access through
ioctl submited by the process.

The second call can then be delayed and ping from time to time to see
if GPU jobs are done.


Note that what you propose might still be useful as in case there is
no buffer object for a range then OOM can make progress in freeing a
range of memory. It is very likely that significant virtual address
range of a process and backing memory can be reclaim that way. This
assume OOM reclaim vma by vma or in some form of granularity like
reclaiming 1GB by 1GB. Or we could also update blocking callback to
return range that are blocking that way OOM can reclaim around.

Cheers,
Jerome
