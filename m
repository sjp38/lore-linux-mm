Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 79F7C6B2F68
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:38:43 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so5749953edd.2
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 04:38:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q9sor4149837eda.25.2018.11.23.04.38.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Nov 2018 04:38:41 -0800 (PST)
Date: Fri, 23 Nov 2018 13:38:38 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH 2/3] mm, notifier: Catch sleeping/blocking for !blockable
Message-ID: <20181123123838.GL4266@phenom.ffwll.local>
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
 <20181122165106.18238-3-daniel.vetter@ffwll.ch>
 <20181123111237.GE8625@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181123111237.GE8625@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>

On Fri, Nov 23, 2018 at 12:12:37PM +0100, Michal Hocko wrote:
> On Thu 22-11-18 17:51:05, Daniel Vetter wrote:
> > We need to make sure implementations don't cheat and don't have a
> > possible schedule/blocking point deeply burried where review can't
> > catch it.
> > 
> > I'm not sure whether this is the best way to make sure all the
> > might_sleep() callsites trigger, and it's a bit ugly in the code flow.
> > But it gets the job done.
> 
> Yeah, it is quite ugly. Especially because it makes DEBUG config
> bahavior much different. So is this really worth it? Has this already
> discovered any existing bug?

Given that we need an oom trigger to hit this we're not hitting this in CI
(oom is just way to unpredictable to even try). I'd kinda like to also add
some debug interface so I can provoke an oom kill of a specially prepared
process, to make sure we can reliably exercise this path without killing
the kernel accidentally. We do similar tricks for our shrinker already.

There's been patches floating with this kind of bug I think, and the call
chains we're dealing with a fairly deep. I don't trust review to reliably
catch this kind of fail, that's why I'm looking into tools to better
validat this stuff to augment review.

And yes it's ugly :-/

Wrt the behavior difference: I guess we could put another counter into the
task struct, and change might_sleep() to check it. All under
CONFIG_DEBUG_ATOMIC_SLEEP only ofc. That would avoid the preempt-disable
sideeffect. My worry with that is that people will spot it, and abuse it
in creative ways that do affect semantics. See horrors like
drm_can_sleep() (and I'm sure gfx folks are not the only ones who
seriously lacked taste here).

Up to the experts really how to best paint this shed I think.

Thanks, Daniel

> 
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: "Christian K�nig" <christian.koenig@amd.com>
> > Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> > Cc: "J�r�me Glisse" <jglisse@redhat.com>
> > Cc: linux-mm@kvack.org
> > Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
> > ---
> >  mm/mmu_notifier.c | 8 +++++++-
> >  1 file changed, 7 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> > index 59e102589a25..4d282cfb296e 100644
> > --- a/mm/mmu_notifier.c
> > +++ b/mm/mmu_notifier.c
> > @@ -185,7 +185,13 @@ int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
> >  	id = srcu_read_lock(&srcu);
> >  	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
> >  		if (mn->ops->invalidate_range_start) {
> > -			int _ret = mn->ops->invalidate_range_start(mn, mm, start, end, blockable);
> > +			int _ret;
> > +
> > +			if (IS_ENABLED(CONFIG_DEBUG_ATOMIC_SLEEP) && !blockable)
> > +				preempt_disable();
> > +			_ret = mn->ops->invalidate_range_start(mn, mm, start, end, blockable);
> > +			if (IS_ENABLED(CONFIG_DEBUG_ATOMIC_SLEEP) && !blockable)
> > +				preempt_enable();
> >  			if (_ret) {
> >  				pr_info("%pS callback failed with %d in %sblockable context.\n",
> >  						mn->ops->invalidate_range_start, _ret,
> > -- 
> > 2.19.1
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch
