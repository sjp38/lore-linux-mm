Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D6D416B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 04:12:10 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r21-v6so217450edp.23
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 01:12:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g4-v6si473539edq.282.2018.07.17.01.12.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 01:12:08 -0700 (PDT)
Date: Tue, 17 Jul 2018 10:12:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180717081201.GB16803@dhcp22.suse.cz>
References: <20180716115058.5559-1-mhocko@kernel.org>
 <20180716161249.c76240cd487c070fb271d529@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180716161249.c76240cd487c070fb271d529@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Felix Kuehling <felix.kuehling@amd.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, Leon Romanovsky <leonro@mellanox.com>

On Mon 16-07-18 16:12:49, Andrew Morton wrote:
> On Mon, 16 Jul 2018 13:50:58 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > There are several blockable mmu notifiers which might sleep in
> > mmu_notifier_invalidate_range_start and that is a problem for the
> > oom_reaper because it needs to guarantee a forward progress so it cannot
> > depend on any sleepable locks.
> > 
> > Currently we simply back off and mark an oom victim with blockable mmu
> > notifiers as done after a short sleep. That can result in selecting a
> > new oom victim prematurely because the previous one still hasn't torn
> > its memory down yet.
> > 
> > We can do much better though. Even if mmu notifiers use sleepable locks
> > there is no reason to automatically assume those locks are held.
> > Moreover majority of notifiers only care about a portion of the address
> > space and there is absolutely zero reason to fail when we are unmapping an
> > unrelated range. Many notifiers do really block and wait for HW which is
> > harder to handle and we have to bail out though.
> > 
> > This patch handles the low hanging fruid. __mmu_notifier_invalidate_range_start
> > gets a blockable flag and callbacks are not allowed to sleep if the
> > flag is set to false. This is achieved by using trylock instead of the
> > sleepable lock for most callbacks and continue as long as we do not
> > block down the call chain.
> 
> I assume device driver developers are wondering "what does this mean
> for me".  As I understand it, the only time they will see
> blockable==false is when their driver is being called in response to an
> out-of-memory condition, yes?  So it is a very rare thing.

Yes, this is the case right now. Maybe we will grow other users in
future. Those other potential users is the reason why I used blockable
rather than oom parameter name.

> Any suggestions regarding how the driver developers can test this code
> path?  I don't think we presently have a way to fake an oom-killing
> event?  Perhaps we should add such a thing, given the problems we're
> having with that feature.

The simplest way is to wrap an userspace code which uses these notifiers
into a memcg and set the hard limit to hit the oom. This can be done
e.g. after the test faults in all the mmu notifier managed memory and
set the hard limit to something really small. Then we are looking for a
proper process tear down.

> > I think we can improve that even further because there is a common
> > pattern to do a range lookup first and then do something about that.
> > The first part can be done without a sleeping lock in most cases AFAICS.
> > 
> > The oom_reaper end then simply retries if there is at least one notifier
> > which couldn't make any progress in !blockable mode. A retry loop is
> > already implemented to wait for the mmap_sem and this is basically the
> > same thing.
> > 
> > ...
> >
> > +static inline int mmu_notifier_invalidate_range_start_nonblock(struct mm_struct *mm,
> > +				  unsigned long start, unsigned long end)
> > +{
> > +	int ret = 0;
> > +	if (mm_has_notifiers(mm))
> > +		ret = __mmu_notifier_invalidate_range_start(mm, start, end, false);
> > +
> > +	return ret;
> >  }
> 
> nit,
> 
> {
> 	if (mm_has_notifiers(mm))
> 		return __mmu_notifier_invalidate_range_start(mm, start, end, false);
> 	return 0;
> }
> 
> would suffice.

Sure. Fixed
 
> > 
> > ...
> >
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -3074,7 +3074,7 @@ void exit_mmap(struct mm_struct *mm)
> >  		 * reliably test it.
> >  		 */
> >  		mutex_lock(&oom_lock);
> > -		__oom_reap_task_mm(mm);
> > +		(void)__oom_reap_task_mm(mm);
> >  		mutex_unlock(&oom_lock);
> 
> What does this do?

There is no error to be returned here as the comment above explains
		 * Nothing can be holding mm->mmap_sem here and the above call
		 * to mmu_notifier_release(mm) ensures mmu notifier callbacks in
		 * __oom_reap_task_mm() will not block.
-- 
Michal Hocko
SUSE Labs
