Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE8666B4996
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 12:28:56 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id x82so27715053ita.9
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 09:28:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j187sor7509641itb.29.2018.11.27.09.28.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 09:28:55 -0800 (PST)
MIME-Version: 1.0
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
 <20181122165106.18238-4-daniel.vetter@ffwll.ch> <20181127074918.GT4266@phenom.ffwll.local>
 <154333737908.11623.17864230889834398136@skylake-alporthouse-com>
In-Reply-To: <154333737908.11623.17864230889834398136@skylake-alporthouse-com>
From: Daniel Vetter <daniel@ffwll.ch>
Date: Tue, 27 Nov 2018 18:28:43 +0100
Message-ID: <CAKMK7uGSP7wWHSRFsCv90qCyHiSBS+o9CK1BPUXbGj6Crcy_Cg@mail.gmail.com>
Subject: Re: [Intel-gfx] [PATCH 3/3] mm, notifier: Add a lockdep map for invalidate_range_start
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Greg KH <gregkh@linuxfoundation.org>, intel-gfx <intel-gfx@lists.freedesktop.org>, dri-devel <dri-devel@lists.freedesktop.org>, Linux MM <linux-mm@kvack.org>, Jerome Glisse <jglisse@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Daniel Vetter <daniel.vetter@intel.com>, Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>

On Tue, Nov 27, 2018 at 5:50 PM Chris Wilson <chris@chris-wilson.co.uk> wro=
te:
>
> Quoting Daniel Vetter (2018-11-27 07:49:18)
> > On Thu, Nov 22, 2018 at 05:51:06PM +0100, Daniel Vetter wrote:
> > > This is a similar idea to the fs_reclaim fake lockdep lock. It's
> > > fairly easy to provoke a specific notifier to be run on a specific
> > > range: Just prep it, and then munmap() it.
> > >
> > > A bit harder, but still doable, is to provoke the mmu notifiers for
> > > all the various callchains that might lead to them. But both at the
> > > same time is really hard to reliable hit, especially when you want to
> > > exercise paths like direct reclaim or compaction, where it's not
> > > easy to control what exactly will be unmapped.
> > >
> > > By introducing a lockdep map to tie them all together we allow lockde=
p
> > > to see a lot more dependencies, without having to actually hit them
> > > in a single challchain while testing.
> > >
> > > Aside: Since I typed this to test i915 mmu notifiers I've only rolled
> > > this out for the invaliate_range_start callback. If there's
> > > interest, we should probably roll this out to all of them. But my
> > > undestanding of core mm is seriously lacking, and I'm not clear on
> > > whether we need a lockdep map for each callback, or whether some can
> > > be shared.
> > >
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Cc: David Rientjes <rientjes@google.com>
> > > Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> > > Cc: Michal Hocko <mhocko@suse.com>
> > > Cc: "Christian K=C3=B6nig" <christian.koenig@amd.com>
> > > Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > > Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> > > Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > > Cc: linux-mm@kvack.org
> > > Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
> >
> > Any comments on this one here? This is really the main ingredient for
> > catching deadlocks in mmu notifier callbacks. The other two patches are
> > more the icing on the cake.
> >
> > Thanks, Daniel
> >
> > > ---
> > >  include/linux/mmu_notifier.h | 7 +++++++
> > >  mm/mmu_notifier.c            | 7 +++++++
> > >  2 files changed, 14 insertions(+)
> > >
> > > diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifie=
r.h
> > > index 9893a6432adf..a39ba218dbbe 100644
> > > --- a/include/linux/mmu_notifier.h
> > > +++ b/include/linux/mmu_notifier.h
> > > @@ -12,6 +12,10 @@ struct mmu_notifier_ops;
> > >
> > >  #ifdef CONFIG_MMU_NOTIFIER
> > >
> > > +#ifdef CONFIG_LOCKDEP
> > > +extern struct lockdep_map __mmu_notifier_invalidate_range_start_map;
> > > +#endif
> > > +
> > >  /*
> > >   * The mmu notifier_mm structure is allocated and installed in
> > >   * mm->mmu_notifier_mm inside the mm_take_all_locks() protected
> > > @@ -267,8 +271,11 @@ static inline void mmu_notifier_change_pte(struc=
t mm_struct *mm,
> > >  static inline void mmu_notifier_invalidate_range_start(struct mm_str=
uct *mm,
> > >                                 unsigned long start, unsigned long en=
d)
> > >  {
> > > +     mutex_acquire(&__mmu_notifier_invalidate_range_start_map, 0, 0,
> > > +                   _RET_IP_);
>
> Would not lock_acquire_shared() be more appropriate, i.e. treat this as
> a rwsem_acquire_read()?

read lock critical sections can't create any dependencies against any
other read lock critical section of the same lock. Switching this to a
read lock would just render the annotation pointless (if you don't
include at least some write lock critical section somewhere, but I
have no idea where you'd do that). A read lock that you only ever take
for reading essentially doesn't do anything at all.

So not clear on why you're suggesting this?

It's the exact same idea like fs_reclaim of intserting a fake lock to
tie all possible callchains to a given functions together with all
possible callchains from that function. Of course this is only valid
if all NxM combinations could happen in theory. For fs_reclaim that's
true because direct reclaim can pick anything it wants to
shrink/evict. For mmu notifier that's true as long as we assume any
mmu notifier can be in use by any process, which only depends upon
sufficiently contrived/evil userspace.

I guess I could use lock_map_acquire/release() wrappers for this like
fs_reclaim, would be a bit more clear.
-Daniel
--=20
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch
