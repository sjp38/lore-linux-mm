Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E4DD16B0006
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 16:09:21 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u20-v6so6565574qkk.20
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 13:09:21 -0700 (PDT)
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680073.outbound.protection.outlook.com. [40.107.68.73])
        by mx.google.com with ESMTPS id e33-v6si8369313qte.258.2018.06.22.13.09.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 22 Jun 2018 13:09:20 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom: distinguish blockable mode for mmu notifiers
References: <20180622150242.16558-1-mhocko@kernel.org>
 <0aa9f695-5702-6704-9462-7779cbfdb3fd@amd.com>
 <20180622152444.GC10465@dhcp22.suse.cz>
From: Felix Kuehling <felix.kuehling@amd.com>
Message-ID: <dd260800-6457-f3ff-47df-b65ef258f4b7@amd.com>
Date: Fri, 22 Jun 2018 16:09:06 -0400
MIME-Version: 1.0
In-Reply-To: <20180622152444.GC10465@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-CA
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 2018-06-22 11:24 AM, Michal Hocko wrote:
> On Fri 22-06-18 17:13:02, Christian KA?nig wrote:
>> Hi Michal,
>>
>> [Adding Felix as well]
>>
>> Well first of all you have a misconception why at least the AMD graphics
>> driver need to be able to sleep in an MMU notifier: We need to sleep because
>> we need to wait for hardware operations to finish and *NOT* because we need
>> to wait for locks.
>>
>> I'm not sure if your flag now means that you generally can't sleep in MMU
>> notifiers any more, but if that's the case at least AMD hardware will break
>> badly. In our case the approach of waiting for a short time for the process
>> to be reaped and then select another victim actually sounds like the right
>> thing to do.
> Well, I do not need to make the notifier code non blocking all the time.
> All I need is to ensure that it won't sleep if the flag says so and
> return -EAGAIN instead.
>
> So here is what I do for amdgpu:

In the case of KFD we also need to take the DQM lock:

amdgpu_mn_invalidate_range_start_hsa -> amdgpu_amdkfd_evict_userptr ->
kgd2kfd_quiesce_mm -> kfd_process_evict_queues -> evict_process_queues_cpsch

So we'd need to pass the blockable parameter all the way through that
call chain.

Regards,
A  Felix

>
>>> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
>>> index 83e344fbb50a..d138a526feff 100644
>>> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
>>> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
>>> @@ -136,12 +136,18 @@ void amdgpu_mn_unlock(struct amdgpu_mn *mn)
>>>    *
>>>    * Take the rmn read side lock.
>>>    */
>>> -static void amdgpu_mn_read_lock(struct amdgpu_mn *rmn)
>>> +static int amdgpu_mn_read_lock(struct amdgpu_mn *rmn, bool blockable)
>>>   {
>>> -	mutex_lock(&rmn->read_lock);
>>> +	if (blockable)
>>> +		mutex_lock(&rmn->read_lock);
>>> +	else if (!mutex_trylock(&rmn->read_lock))
>>> +		return -EAGAIN;
>>> +
>>>   	if (atomic_inc_return(&rmn->recursion) == 1)
>>>   		down_read_non_owner(&rmn->lock);
>>>   	mutex_unlock(&rmn->read_lock);
>>> +
>>> +	return 0;
>>>   }
>>>   /**
>>> @@ -197,10 +203,11 @@ static void amdgpu_mn_invalidate_node(struct amdgpu_mn_node *node,
>>>    * We block for all BOs between start and end to be idle and
>>>    * unmap them by move them into system domain again.
>>>    */
>>> -static void amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
>>> +static int amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
>>>   						 struct mm_struct *mm,
>>>   						 unsigned long start,
>>> -						 unsigned long end)
>>> +						 unsigned long end,
>>> +						 bool blockable)
>>>   {
>>>   	struct amdgpu_mn *rmn = container_of(mn, struct amdgpu_mn, mn);
>>>   	struct interval_tree_node *it;
>>> @@ -208,7 +215,11 @@ static void amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
>>>   	/* notification is exclusive, but interval is inclusive */
>>>   	end -= 1;
>>> -	amdgpu_mn_read_lock(rmn);
>>> +	/* TODO we should be able to split locking for interval tree and
>>> +	 * amdgpu_mn_invalidate_node
>>> +	 */
>>> +	if (amdgpu_mn_read_lock(rmn, blockable))
>>> +		return -EAGAIN;
>>>   	it = interval_tree_iter_first(&rmn->objects, start, end);
>>>   	while (it) {
>>> @@ -219,6 +230,8 @@ static void amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
>>>   		amdgpu_mn_invalidate_node(node, start, end);
>>>   	}
>>> +
>>> +	return 0;
>>>   }
>>>   /**
>>> @@ -233,10 +246,11 @@ static void amdgpu_mn_invalidate_range_start_gfx(struct mmu_notifier *mn,
>>>    * necessitates evicting all user-mode queues of the process. The BOs
>>>    * are restorted in amdgpu_mn_invalidate_range_end_hsa.
>>>    */
>>> -static void amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
>>> +static int amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
>>>   						 struct mm_struct *mm,
>>>   						 unsigned long start,
>>> -						 unsigned long end)
>>> +						 unsigned long end,
>>> +						 bool blockable)
>>>   {
>>>   	struct amdgpu_mn *rmn = container_of(mn, struct amdgpu_mn, mn);
>>>   	struct interval_tree_node *it;
>>> @@ -244,7 +258,8 @@ static void amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
>>>   	/* notification is exclusive, but interval is inclusive */
>>>   	end -= 1;
>>> -	amdgpu_mn_read_lock(rmn);
>>> +	if (amdgpu_mn_read_lock(rmn, blockable))
>>> +		return -EAGAIN;
>>>   	it = interval_tree_iter_first(&rmn->objects, start, end);
>>>   	while (it) {
>>> @@ -262,6 +277,8 @@ static void amdgpu_mn_invalidate_range_start_hsa(struct mmu_notifier *mn,
>>>   				amdgpu_amdkfd_evict_userptr(mem, mm);
>>>   		}
>>>   	}
>>> +
>>> +	return 0;
>>>   }
>>>   /**
