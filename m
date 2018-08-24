Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 551376B2F81
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 07:52:30 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p51-v6so507370eda.18
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 04:52:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 41-v6si326314edr.186.2018.08.24.04.52.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 04:52:29 -0700 (PDT)
Date: Fri, 24 Aug 2018 13:52:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180824115226.GK29735@dhcp22.suse.cz>
References: <20180716115058.5559-1-mhocko@kernel.org>
 <8cbfb09f-0c5a-8d43-1f5e-f3ff7612e289@I-love.SAKURA.ne.jp>
 <20180824113248.GH29735@dhcp22.suse.cz>
 <b088e382-e90e-df63-a079-19b2ae2b985d@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b088e382-e90e-df63-a079-19b2ae2b985d@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: christian.koenig@amd.com
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kvm@vger.kernel.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, David Airlie <airlied@linux.ie>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Dimitri Sivanich <sivanich@sgi.com>, linux-rdma@vger.kernel.org, amd-gfx@lists.freedesktop.org, Jason Gunthorpe <jgg@ziepe.ca>, Doug Ledford <dledford@redhat.com>, David Rientjes <rientjes@google.com>, xen-devel@lists.xenproject.org, intel-gfx@lists.freedesktop.org, Jani Nikula <jani.nikula@linux.intel.com>, Leon Romanovsky <leonro@mellanox.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, LKML <linux-kernel@vger.kernel.org>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Deucher <alexander.deucher@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Felix Kuehling <felix.kuehling@amd.com>

On Fri 24-08-18 13:43:16, Christian Konig wrote:
> Am 24.08.2018 um 13:32 schrieb Michal Hocko:
> > On Fri 24-08-18 19:54:19, Tetsuo Handa wrote:
> > > Two more worries for this patch.
> > > 
> > > 
> > > 
> > > > --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> > > > +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> > > > @@ -178,12 +178,18 @@ void amdgpu_mn_unlock(struct amdgpu_mn *mn)
> > > >    *
> > > >    * @amn: our notifier
> > > >    */
> > > > -static void amdgpu_mn_read_lock(struct amdgpu_mn *amn)
> > > > +static int amdgpu_mn_read_lock(struct amdgpu_mn *amn, bool blockable)
> > > >   {
> > > > -       mutex_lock(&amn->read_lock);
> > > > +       if (blockable)
> > > > +               mutex_lock(&amn->read_lock);
> > > > +       else if (!mutex_trylock(&amn->read_lock))
> > > > +               return -EAGAIN;
> > > > +
> > > >          if (atomic_inc_return(&amn->recursion) == 1)
> > > >                  down_read_non_owner(&amn->lock);
> > > Why don't we need to use trylock here if blockable == false ?
> > > Want comment why it is safe to use blocking lock here.
> > Hmm, I am pretty sure I have checked the code but it was quite confusing
> > so I might have missed something. Double checking now, it seems that
> > this read_lock is not used anywhere else and it is not _the_ lock we are
> > interested about. It is the amn->lock (amdgpu_mn_lock) which matters as
> > it is taken in exclusive mode for expensive operations.
> 
> The write side of the lock is only taken in the command submission IOCTL.
> 
> So you actually don't need to change anything here (even the proposed
> changes are overkill) since we can't tear down the struct_mm while an IOCTL
> is still using.

I am not so sure. We are not in the mm destruction phase yet. This is
mostly about the oom context which might fire right during the IOCTL. If
any of the path which is holding the write lock blocks for unbound
amount of time or even worse allocates a memory then we are screwed. So
we need to back of when blockable = false.

> > Is that correct Christian? If this is correct then we need to update the
> > locking here. I am struggling to grasp the ref counting part. Why cannot
> > all readers simply take the lock rather than rely on somebody else to
> > take it? 1ed3d2567c800 didn't really help me to understand the locking
> > scheme here so any help would be appreciated.
> 
> That won't work like this there might be multiple
> invalidate_range_start()/invalidate_range_end() pairs open at the same time.
> E.g. the lock might be taken recursively and that is illegal for a
> rw_semaphore.

I am not sure I follow. Are you saying that one invalidate_range might
trigger another one from the same path?
-- 
Michal Hocko
SUSE Labs
