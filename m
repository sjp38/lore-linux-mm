Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7A66B3F50
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 03:41:54 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id w142-v6so499990qkw.8
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 00:41:54 -0700 (PDT)
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680088.outbound.protection.outlook.com. [40.107.68.88])
        by mx.google.com with ESMTPS id i92-v6si13815827qva.15.2018.08.27.00.41.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 27 Aug 2018 00:41:53 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
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
 <20180824135257.GU29735@dhcp22.suse.cz>
 <b78f8b3a-7bc6-0dea-6752-5ea798eccb6b@i-love.sakura.ne.jp>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Message-ID: <0e80c531-4e91-fb1d-e7eb-46a7aecc4c9d@amd.com>
Date: Mon, 27 Aug 2018 09:41:27 +0200
MIME-Version: 1.0
In-Reply-To: <b78f8b3a-7bc6-0dea-6752-5ea798eccb6b@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Michal Hocko <mhocko@kernel.org>
Cc: kvm@vger.kernel.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Sudeep Dutt <sudeep.dutt@intel.com>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Dimitri Sivanich <sivanich@sgi.com>, Jason Gunthorpe <jgg@ziepe.ca>, linux-rdma@vger.kernel.org, amd-gfx@lists.freedesktop.org, David Airlie <airlied@linux.ie>, Doug Ledford <dledford@redhat.com>, David Rientjes <rientjes@google.com>, xen-devel@lists.xenproject.org, intel-gfx@lists.freedesktop.org, Leon Romanovsky <leonro@mellanox.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, LKML <linux-kernel@vger.kernel.org>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Deucher <alexander.deucher@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Felix Kuehling <felix.kuehling@amd.com>

Am 26.08.2018 um 10:40 schrieb Tetsuo Handa:
> On 2018/08/24 22:52, Michal Hocko wrote:
>> @@ -180,11 +180,15 @@ void amdgpu_mn_unlock(struct amdgpu_mn *mn)
>>    */
>>   static int amdgpu_mn_read_lock(struct amdgpu_mn *amn, bool blockable)
>>   {
>> -	if (blockable)
>> -		mutex_lock(&amn->read_lock);
>> -	else if (!mutex_trylock(&amn->read_lock))
>> -		return -EAGAIN;
>> -
>> +	/*
>> +	 * We can take sleepable lock even on !blockable mode because
>> +	 * read_lock is only ever take from this path and the notifier
>> +	 * lock never really sleeps. In fact the only reason why the
>> +	 * later is sleepable is because the notifier itself might sleep
>> +	 * in amdgpu_mn_invalidate_node but blockable mode is handled
>> +	 * before calling into that path.
>> +	 */
>> +	mutex_lock(&amn->read_lock);
>>   	if (atomic_inc_return(&amn->recursion) == 1)
>>   		down_read_non_owner(&amn->lock);
>>   	mutex_unlock(&amn->read_lock);
>>
> I'm not following. Why don't we need to do like below (given that
> nobody except amdgpu_mn_read_lock() holds ->read_lock) because e.g.
> drm_sched_fence_create() from drm_sched_job_init() from amdgpu_cs_submit()
> is doing GFP_KERNEL memory allocation with ->lock held for write?

That's a bug which needs to be fixed separately.

Allocating memory with GFP_KERNEL while holding a lock which is also 
taken in the reclaim code path is illegal not matter what you do.

Patches to fix this are already on the appropriate mailing list and will 
be pushed upstream today.

Regards,
Christian.

>
> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> index e55508b..e1cb344 100644
> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> @@ -64,8 +64,6 @@
>    * @node: hash table node to find structure by adev and mn
>    * @lock: rw semaphore protecting the notifier nodes
>    * @objects: interval tree containing amdgpu_mn_nodes
> - * @read_lock: mutex for recursive locking of @lock
> - * @recursion: depth of recursion
>    *
>    * Data for each amdgpu device and process address space.
>    */
> @@ -85,8 +83,6 @@ struct amdgpu_mn {
>   	/* objects protected by lock */
>   	struct rw_semaphore	lock;
>   	struct rb_root_cached	objects;
> -	struct mutex		read_lock;
> -	atomic_t		recursion;
>   };
>   
>   /**
> @@ -181,14 +177,9 @@ void amdgpu_mn_unlock(struct amdgpu_mn *mn)
>   static int amdgpu_mn_read_lock(struct amdgpu_mn *amn, bool blockable)
>   {
>   	if (blockable)
> -		mutex_lock(&amn->read_lock);
> -	else if (!mutex_trylock(&amn->read_lock))
> +		down_read(&amn->lock);
> +	else if (!down_read_trylock(&amn->lock))
>   		return -EAGAIN;
> -
> -	if (atomic_inc_return(&amn->recursion) == 1)
> -		down_read_non_owner(&amn->lock);
> -	mutex_unlock(&amn->read_lock);
> -
>   	return 0;
>   }
>   
> @@ -199,8 +190,7 @@ static int amdgpu_mn_read_lock(struct amdgpu_mn *amn, bool blockable)
>    */
>   static void amdgpu_mn_read_unlock(struct amdgpu_mn *amn)
>   {
> -	if (atomic_dec_return(&amn->recursion) == 0)
> -		up_read_non_owner(&amn->lock);
> +	up_read(&amn->lock);
>   }
>   
>   /**
> @@ -410,8 +400,6 @@ struct amdgpu_mn *amdgpu_mn_get(struct amdgpu_device *adev,
>   	amn->type = type;
>   	amn->mn.ops = &amdgpu_mn_ops[type];
>   	amn->objects = RB_ROOT_CACHED;
> -	mutex_init(&amn->read_lock);
> -	atomic_set(&amn->recursion, 0);
>   
>   	r = __mmu_notifier_register(&amn->mn, mm);
>   	if (r)
