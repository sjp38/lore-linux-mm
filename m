Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id A1EF76B291E
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 10:40:33 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id c6-v6so8054079qta.6
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 07:40:33 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b15-v6si8194793qvl.31.2018.08.24.07.40.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 07:40:32 -0700 (PDT)
Date: Fri, 24 Aug 2018 10:40:27 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180824144027.GA4244@redhat.com>
References: <20180716115058.5559-1-mhocko@kernel.org>
 <8cbfb09f-0c5a-8d43-1f5e-f3ff7612e289@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <8cbfb09f-0c5a-8d43-1f5e-f3ff7612e289@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Felix Kuehling <felix.kuehling@amd.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, Leon Romanovsky <leonro@mellanox.com>

On Fri, Aug 24, 2018 at 07:54:19PM +0900, Tetsuo Handa wrote:
> Two more worries for this patch.

[...]

> 
> > --- a/mm/hmm.c
> > +++ b/mm/hmm.c
> > @@ -177,16 +177,19 @@ static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
> >         up_write(&hmm->mirrors_sem);
> >  }
> > 
> > -static void hmm_invalidate_range_start(struct mmu_notifier *mn,
> > +static int hmm_invalidate_range_start(struct mmu_notifier *mn,
> >                                        struct mm_struct *mm,
> >                                        unsigned long start,
> > -                                      unsigned long end)
> > +                                      unsigned long end,
> > +                                      bool blockable)
> >  {
> >         struct hmm *hmm = mm->hmm;
> > 
> >         VM_BUG_ON(!hmm);
> > 
> >         atomic_inc(&hmm->sequence);
> > +
> > +       return 0;
> >  }
> > 
> >  static void hmm_invalidate_range_end(struct mmu_notifier *mn,
> 
> This assumes that hmm_invalidate_range_end() does not have memory
> allocation dependency. But hmm_invalidate_range() from
> hmm_invalidate_range_end() involves
> 
>         down_read(&hmm->mirrors_sem);
>         list_for_each_entry(mirror, &hmm->mirrors, list)
>                 mirror->ops->sync_cpu_device_pagetables(mirror, action,
>                                                         start, end);
>         up_read(&hmm->mirrors_sem);
> 
> sequence. What is surprising is that there is no in-tree user who assigns
> sync_cpu_device_pagetables field.
> 
>   $ grep -Fr sync_cpu_device_pagetables *
>   Documentation/vm/hmm.rst:     /* sync_cpu_device_pagetables() - synchronize page tables
>   include/linux/hmm.h: * will get callbacks through sync_cpu_device_pagetables() operation (see
>   include/linux/hmm.h:    /* sync_cpu_device_pagetables() - synchronize page tables
>   include/linux/hmm.h:    void (*sync_cpu_device_pagetables)(struct hmm_mirror *mirror,
>   include/linux/hmm.h: * hmm_mirror_ops.sync_cpu_device_pagetables() callback, so that CPU page
>   mm/hmm.c:               mirror->ops->sync_cpu_device_pagetables(mirror, action,
> 
> That is, this API seems to be currently used by only out-of-tree users. Since
> we can't check that nobody has memory allocation dependency, I think that
> hmm_invalidate_range_start() should return -EAGAIN if blockable == false for now.

So you can see update and user of this there:

https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-intel-v00
https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-nouveau-v01
https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-radeon-v00

I am still working on Mellanox and AMD GPU patchset.

I will post the HMM changes that adapt to Michal shortly as anyway
thus have been sufficiently tested by now.

https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-4.20&id=78785dcb5ba0924c2c5e7be027793f99ebbc39f3
https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-4.20&id=4fc25571dc893f2b278e90cda9e71e139e01de70

Cheers,
Jerome
