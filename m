Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AFE8A6B2FE4
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 09:53:00 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k16-v6so744679ede.6
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 06:53:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p43-v6si484233eda.158.2018.08.24.06.52.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 06:52:59 -0700 (PDT)
Date: Fri, 24 Aug 2018 15:52:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180824135257.GU29735@dhcp22.suse.cz>
References: <20180824120339.GL29735@dhcp22.suse.cz>
 <eb546bcb-9c5f-7d5d-43a7-bfde489f0e7f@amd.com>
 <20180824123341.GN29735@dhcp22.suse.cz>
 <b11df415-baf8-0a41-3c16-60dfe8d32bd3@amd.com>
 <20180824130132.GP29735@dhcp22.suse.cz>
 <23d071d2-82e4-9b78-1000-be44db5f6523@gmail.com>
 <20180824132442.GQ29735@dhcp22.suse.cz>
 <86bd94d5-0ce8-c67f-07a5-ca9ebf399cdd@gmail.com>
 <20180824134009.GS29735@dhcp22.suse.cz>
 <735b0a53-5237-8827-d20e-e57fa24d798f@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <735b0a53-5237-8827-d20e-e57fa24d798f@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>
Cc: kvm@vger.kernel.org, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sudeep Dutt <sudeep.dutt@intel.com>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Dimitri Sivanich <sivanich@sgi.com>, Jason Gunthorpe <jgg@ziepe.ca>, linux-rdma@vger.kernel.org, amd-gfx@lists.freedesktop.org, David Airlie <airlied@linux.ie>, Doug Ledford <dledford@redhat.com>, David Rientjes <rientjes@google.com>, xen-devel@lists.xenproject.org, intel-gfx@lists.freedesktop.org, Leon Romanovsky <leonro@mellanox.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, LKML <linux-kernel@vger.kernel.org>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Deucher <alexander.deucher@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Felix Kuehling <felix.kuehling@amd.com>

On Fri 24-08-18 15:44:03, Christian Konig wrote:
> Am 24.08.2018 um 15:40 schrieb Michal Hocko:
> > On Fri 24-08-18 15:28:33, Christian Konig wrote:
> > > Am 24.08.2018 um 15:24 schrieb Michal Hocko:
> > > > On Fri 24-08-18 15:10:08, Christian Konig wrote:
> > > > > Am 24.08.2018 um 15:01 schrieb Michal Hocko:
> > > > > > On Fri 24-08-18 14:52:26, Christian Konig wrote:
> > > > > > > Am 24.08.2018 um 14:33 schrieb Michal Hocko:
> > > > > > [...]
> > > > > > > > Thiking about it some more, I can imagine that a notifier callback which
> > > > > > > > performs an allocation might trigger a memory reclaim and that in turn
> > > > > > > > might trigger a notifier to be invoked and recurse. But notifier
> > > > > > > > shouldn't really allocate memory. They are called from deep MM code
> > > > > > > > paths and this would be extremely deadlock prone. Maybe Jerome can come
> > > > > > > > up some more realistic scenario. If not then I would propose to simplify
> > > > > > > > the locking here. We have lockdep to catch self deadlocks and it is
> > > > > > > > always better to handle a specific issue rather than having a code
> > > > > > > > without a clear indication how it can recurse.
> > > > > > > Well I agree that we should probably fix that, but I have some concerns to
> > > > > > > remove the existing workaround.
> > > > > > > 
> > > > > > > See we added that to get rid of a real problem in a customer environment and
> > > > > > > I don't want to that to show up again.
> > > > > > It would really help to know more about that case and fix it properly
> > > > > > rather than workaround it like this. Anyway, let me think how to handle
> > > > > > the non-blocking notifier invocation then. I was not able to come up
> > > > > > with anything remotely sane yet.
> > > > > With avoiding allocating memory in the write lock path I don't see an issue
> > > > > any more with that.
> > > > > 
> > > > > All what the write lock path does now is adding items to a linked lists,
> > > > > arrays etc....
> > > > Can we change it to non-sleepable lock then?
> > > No, the write side doesn't sleep any more, but the read side does.
> > > 
> > > See amdgpu_mn_invalidate_node() and that is where you actually need to
> > > handle the non-blocking flag correctly.
> > Ohh, right you are. We already handle that by bailing out before calling
> > amdgpu_mn_invalidate_node in !blockable mode.
> 
> Yeah, that is sufficient.
> 
> It could be improved because we have something like 90% chance that
> amdgpu_mn_invalidate_node() actually doesn't need to do anything.
> 
> But I can take care of that when the patch set has landed.
> 
> > So does this looks good to you?
> 
> Yeah, that looks perfect to me. Reviewed-by: Christian Konig
> <christian.koenig@amd.com>

Cool! Thanks for your guidance and patience with me. Here is the full
patch. Feel free to take it and route per your preference.
