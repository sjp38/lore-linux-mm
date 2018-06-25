Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5FB646B0005
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 09:32:01 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i19-v6so2332080eds.20
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 06:32:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a24-v6si7059569edc.227.2018.06.25.06.31.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jun 2018 06:31:59 -0700 (PDT)
Date: Mon, 25 Jun 2018 15:31:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180625133157.GL28965@dhcp22.suse.cz>
References: <20180622150242.16558-1-mhocko@kernel.org>
 <0aa9f695-5702-6704-9462-7779cbfdb3fd@amd.com>
 <20180622152444.GC10465@dhcp22.suse.cz>
 <dd260800-6457-f3ff-47df-b65ef258f4b7@amd.com>
 <20180625080103.GB28965@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180625080103.GB28965@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Felix Kuehling <felix.kuehling@amd.com>
Cc: Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, LKML <linux-kernel@vger.kernel.org>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Mon 25-06-18 10:01:03, Michal Hocko wrote:
> On Fri 22-06-18 16:09:06, Felix Kuehling wrote:
> > On 2018-06-22 11:24 AM, Michal Hocko wrote:
> > > On Fri 22-06-18 17:13:02, Christian Konig wrote:
> > >> Hi Michal,
> > >>
> > >> [Adding Felix as well]
> > >>
> > >> Well first of all you have a misconception why at least the AMD graphics
> > >> driver need to be able to sleep in an MMU notifier: We need to sleep because
> > >> we need to wait for hardware operations to finish and *NOT* because we need
> > >> to wait for locks.
> > >>
> > >> I'm not sure if your flag now means that you generally can't sleep in MMU
> > >> notifiers any more, but if that's the case at least AMD hardware will break
> > >> badly. In our case the approach of waiting for a short time for the process
> > >> to be reaped and then select another victim actually sounds like the right
> > >> thing to do.
> > > Well, I do not need to make the notifier code non blocking all the time.
> > > All I need is to ensure that it won't sleep if the flag says so and
> > > return -EAGAIN instead.
> > >
> > > So here is what I do for amdgpu:
> > 
> > In the case of KFD we also need to take the DQM lock:
> > 
> > amdgpu_mn_invalidate_range_start_hsa -> amdgpu_amdkfd_evict_userptr ->
> > kgd2kfd_quiesce_mm -> kfd_process_evict_queues -> evict_process_queues_cpsch
> > 
> > So we'd need to pass the blockable parameter all the way through that
> > call chain.
> 
> Thanks, I have missed that part. So I guess I will start with something
> similar to intel-gfx and back off when the current range needs some
> treatment. So this on top. Does it look correct?
> 
> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> index d138a526feff..e2d422b3eb0b 100644
> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> @@ -266,6 +266,11 @@ static int amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
>  		struct amdgpu_mn_node *node;
>  		struct amdgpu_bo *bo;
>  
> +		if (!blockable) {
> +			amdgpu_mn_read_unlock();
> +			return -EAGAIN;
> +		}
> +
>  		node = container_of(it, struct amdgpu_mn_node, it);
>  		it = interval_tree_iter_next(it, start, end);

Ble, just noticed that half of the change didn't get to git index...
This is what I have
commit c4701b36ac2802b903db3d05cf77c030fccce3a8
Author: Michal Hocko <mhocko@suse.com>
Date:   Mon Jun 25 15:24:03 2018 +0200

    fold me
    
    - amd gpu notifiers can sleep deeper in the callchain (evict_process_queues_cpsch
      on a lock and amdgpu_mn_invalidate_node on unbound timeout) make sure
      we bail out when we have an intersecting range for starter

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
index d138a526feff..3399a4a927fb 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
@@ -225,6 +225,11 @@ static int amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
 	while (it) {
 		struct amdgpu_mn_node *node;
 
+		if (!blockable) {
+			amdgpu_mn_read_unlock(rmn);
+			return -EAGAIN;
+		}
+
 		node = container_of(it, struct amdgpu_mn_node, it);
 		it = interval_tree_iter_next(it, start, end);
 
@@ -266,6 +271,11 @@ static int amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
 		struct amdgpu_mn_node *node;
 		struct amdgpu_bo *bo;
 
+		if (!blockable) {
+			amdgpu_mn_read_unlock(rmn);
+			return -EAGAIN;
+		}
+
 		node = container_of(it, struct amdgpu_mn_node, it);
 		it = interval_tree_iter_next(it, start, end);
 
-- 
Michal Hocko
SUSE Labs
