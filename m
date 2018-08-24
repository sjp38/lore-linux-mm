Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD8846B3003
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 09:44:30 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id s15-v6so7091395iob.11
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 06:44:30 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0075.outbound.protection.outlook.com. [104.47.36.75])
        by mx.google.com with ESMTPS id a185-v6si1023995ite.49.2018.08.24.06.44.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 24 Aug 2018 06:44:29 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
References: <20180824115226.GK29735@dhcp22.suse.cz>
 <a27ad1a3-34bd-6b7d-fd09-7737ec3c888d@gmail.com>
 <20180824120339.GL29735@dhcp22.suse.cz>
 <eb546bcb-9c5f-7d5d-43a7-bfde489f0e7f@amd.com>
 <20180824123341.GN29735@dhcp22.suse.cz>
 <b11df415-baf8-0a41-3c16-60dfe8d32bd3@amd.com>
 <20180824130132.GP29735@dhcp22.suse.cz>
 <23d071d2-82e4-9b78-1000-be44db5f6523@gmail.com>
 <20180824132442.GQ29735@dhcp22.suse.cz>
 <86bd94d5-0ce8-c67f-07a5-ca9ebf399cdd@gmail.com>
 <20180824134009.GS29735@dhcp22.suse.cz>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Message-ID: <735b0a53-5237-8827-d20e-e57fa24d798f@amd.com>
Date: Fri, 24 Aug 2018 15:44:03 +0200
MIME-Version: 1.0
In-Reply-To: <20180824134009.GS29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: kvm@vger.kernel.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sudeep Dutt <sudeep.dutt@intel.com>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Dimitri Sivanich <sivanich@sgi.com>, Jason Gunthorpe <jgg@ziepe.ca>, linux-rdma@vger.kernel.org, amd-gfx@lists.freedesktop.org, David Airlie <airlied@linux.ie>, Doug Ledford <dledford@redhat.com>, David Rientjes <rientjes@google.com>, xen-devel@lists.xenproject.org, intel-gfx@lists.freedesktop.org, Leon Romanovsky <leonro@mellanox.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, LKML <linux-kernel@vger.kernel.org>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Deucher <alexander.deucher@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Felix Kuehling <felix.kuehling@amd.com>

Am 24.08.2018 um 15:40 schrieb Michal Hocko:
> On Fri 24-08-18 15:28:33, Christian KA?nig wrote:
>> Am 24.08.2018 um 15:24 schrieb Michal Hocko:
>>> On Fri 24-08-18 15:10:08, Christian KA?nig wrote:
>>>> Am 24.08.2018 um 15:01 schrieb Michal Hocko:
>>>>> On Fri 24-08-18 14:52:26, Christian KA?nig wrote:
>>>>>> Am 24.08.2018 um 14:33 schrieb Michal Hocko:
>>>>> [...]
>>>>>>> Thiking about it some more, I can imagine that a notifier callback which
>>>>>>> performs an allocation might trigger a memory reclaim and that in turn
>>>>>>> might trigger a notifier to be invoked and recurse. But notifier
>>>>>>> shouldn't really allocate memory. They are called from deep MM code
>>>>>>> paths and this would be extremely deadlock prone. Maybe Jerome can come
>>>>>>> up some more realistic scenario. If not then I would propose to simplify
>>>>>>> the locking here. We have lockdep to catch self deadlocks and it is
>>>>>>> always better to handle a specific issue rather than having a code
>>>>>>> without a clear indication how it can recurse.
>>>>>> Well I agree that we should probably fix that, but I have some concerns to
>>>>>> remove the existing workaround.
>>>>>>
>>>>>> See we added that to get rid of a real problem in a customer environment and
>>>>>> I don't want to that to show up again.
>>>>> It would really help to know more about that case and fix it properly
>>>>> rather than workaround it like this. Anyway, let me think how to handle
>>>>> the non-blocking notifier invocation then. I was not able to come up
>>>>> with anything remotely sane yet.
>>>> With avoiding allocating memory in the write lock path I don't see an issue
>>>> any more with that.
>>>>
>>>> All what the write lock path does now is adding items to a linked lists,
>>>> arrays etc....
>>> Can we change it to non-sleepable lock then?
>> No, the write side doesn't sleep any more, but the read side does.
>>
>> See amdgpu_mn_invalidate_node() and that is where you actually need to
>> handle the non-blocking flag correctly.
> Ohh, right you are. We already handle that by bailing out before calling
> amdgpu_mn_invalidate_node in !blockable mode.

Yeah, that is sufficient.

It could be improved because we have something like 90% chance that 
amdgpu_mn_invalidate_node() actually doesn't need to do anything.

But I can take care of that when the patch set has landed.

> So does this looks good to
> you?

Yeah, that looks perfect to me. Reviewed-by: Christian KA?nig 
<christian.koenig@amd.com>

Thanks,
Christian.

>
> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> index e55508b39496..48fa152231be 100644
> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
> @@ -180,11 +180,15 @@ void amdgpu_mn_unlock(struct amdgpu_mn *mn)
>    */
>   static int amdgpu_mn_read_lock(struct amdgpu_mn *amn, bool blockable)
>   {
> -	if (blockable)
> -		mutex_lock(&amn->read_lock);
> -	else if (!mutex_trylock(&amn->read_lock))
> -		return -EAGAIN;
> -
> +	/*
> +	 * We can take sleepable lock even on !blockable mode because
> +	 * read_lock is only ever take from this path and the notifier
> +	 * lock never really sleeps. In fact the only reason why the
> +	 * later is sleepable is because the notifier itself might sleep
> +	 * in amdgpu_mn_invalidate_node but blockable mode is handled
> +	 * before calling into that path.
> +	 */
> +	mutex_lock(&amn->read_lock);
>   	if (atomic_inc_return(&amn->recursion) == 1)
>   		down_read_non_owner(&amn->lock);
>   	mutex_unlock(&amn->read_lock);
