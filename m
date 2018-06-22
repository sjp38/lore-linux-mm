Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 748F86B000A
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 11:57:21 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x14-v6so595312edr.16
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 08:57:21 -0700 (PDT)
Date: Fri, 22 Jun 2018 17:57:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Intel-gfx] [RFC PATCH] mm, oom: distinguish blockable mode for
 mmu notifiers
Message-ID: <20180622155716.GE10465@dhcp22.suse.cz>
References: <20180622150242.16558-1-mhocko@kernel.org>
 <152968180950.11773.3374981930722769733@mail.alporthouse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152968180950.11773.3374981930722769733@mail.alporthouse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko =?utf-8?B?PG1ob2Nrb0BzdXNlLmNvbT4sIGt2bUB2Z2VyLmtlcm5l?= =?utf-8?B?bC5vcmcsICAiIFJhZGltIEtyxI1tw6HFmSA8cmtyY21hckByZWRoYXQuY29t?= =?utf-8?B?Piw=?= David Airlie <airlied@linux.ie>, Sudeep Dutt <sudeep.dutt@intel.com>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Dimitri Sivanich <sivanich@sgi.com>, linux-rdma@vger.kernel.org, amd-gfx@lists.freedesktop.org, Jason Gunthorpe <jgg@ziepe.ca>, Doug Ledford <dledford@redhat.com>, David Rientjes <rientjes@google.com>, xen-devel@lists.xenproject.org, intel-gfx@lists.freedesktop.org, =?iso-8859-1?B?IiBK6XL0bWU=?= Glisse <jglisse@redhat.com>, Rodrigo@kvack.org, Vivi@kvack.org, Boris@kvack.org, Ostrovsky@kvack.org, Juergen@kvack.org, Gross@kvack.org, Mike@kvack.org, Marciniszyn@kvack.org, Dennis@kvack.org, Dalessandro@kvack.org, Ashutosh@kvack.org, Dixit@kvack.org, Alex@kvack.org, Deucher@kvack.org, Paolo@kvack.org, Bonzini@kvack.org

On Fri 22-06-18 16:36:49, Chris Wilson wrote:
> Quoting Michal Hocko (2018-06-22 16:02:42)
> > Hi,
> > this is an RFC and not tested at all. I am not very familiar with the
> > mmu notifiers semantics very much so this is a crude attempt to achieve
> > what I need basically. It might be completely wrong but I would like
> > to discuss what would be a better way if that is the case.
> > 
> > get_maintainers gave me quite large list of people to CC so I had to trim
> > it down. If you think I have forgot somebody, please let me know
> 
> > diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
> > index 854bd51b9478..5285df9331fa 100644
> > --- a/drivers/gpu/drm/i915/i915_gem_userptr.c
> > +++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
> > @@ -112,10 +112,11 @@ static void del_object(struct i915_mmu_object *mo)
> >         mo->attached = false;
> >  }
> >  
> > -static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
> > +static int i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
> >                                                        struct mm_struct *mm,
> >                                                        unsigned long start,
> > -                                                      unsigned long end)
> > +                                                      unsigned long end,
> > +                                                      bool blockable)
> >  {
> >         struct i915_mmu_notifier *mn =
> >                 container_of(_mn, struct i915_mmu_notifier, mn);
> > @@ -124,7 +125,7 @@ static void i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
> >         LIST_HEAD(cancelled);
> >  
> >         if (RB_EMPTY_ROOT(&mn->objects.rb_root))
> > -               return;
> > +               return 0;
> 
> The principle wait here is for the HW (even after fixing all the locks
> to be not so coarse, we still have to wait for the HW to finish its
> access).

Is this wait bound or it can take basically arbitrary amount of time?

> The first pass would be then to not do anything here if
> !blockable.

something like this? (incremental diff)

diff --git a/drivers/gpu/drm/i915/i915_gem_userptr.c b/drivers/gpu/drm/i915/i915_gem_userptr.c
index 5285df9331fa..e9ed0d2cfabc 100644
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c
@@ -122,6 +122,7 @@ static int i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
 		container_of(_mn, struct i915_mmu_notifier, mn);
 	struct i915_mmu_object *mo;
 	struct interval_tree_node *it;
+	int ret = 0;
 	LIST_HEAD(cancelled);
 
 	if (RB_EMPTY_ROOT(&mn->objects.rb_root))
@@ -133,6 +134,10 @@ static int i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
 	spin_lock(&mn->lock);
 	it = interval_tree_iter_first(&mn->objects, start, end);
 	while (it) {
+		if (!blockable) {
+			ret = -EAGAIN;
+			goto out_unlock;
+		}
 		/* The mmu_object is released late when destroying the
 		 * GEM object so it is entirely possible to gain a
 		 * reference on an object in the process of being freed
@@ -154,8 +159,10 @@ static int i915_gem_userptr_mn_invalidate_range_start(struct mmu_notifier *_mn,
 	spin_unlock(&mn->lock);
 
 	/* TODO: can we skip waiting here? */
-	if (!list_empty(&cancelled) && blockable)
+	if (!list_empty(&cancelled))
 		flush_workqueue(mn->wq);
+
+	return ret;
 }
 
 static const struct mmu_notifier_ops i915_gem_userptr_notifier = {
-- 
Michal Hocko
SUSE Labs
