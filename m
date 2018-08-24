Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 545CC6B2F88
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 07:57:56 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id m28-v6so7607908wrf.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 04:57:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z14-v6sor314783wmf.7.2018.08.24.04.57.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 04:57:54 -0700 (PDT)
Reply-To: christian.koenig@amd.com
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
References: <20180716115058.5559-1-mhocko@kernel.org>
 <8cbfb09f-0c5a-8d43-1f5e-f3ff7612e289@I-love.SAKURA.ne.jp>
 <20180824113248.GH29735@dhcp22.suse.cz>
 <b088e382-e90e-df63-a079-19b2ae2b985d@gmail.com>
 <20180824115226.GK29735@dhcp22.suse.cz>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <ckoenig.leichtzumerken@gmail.com>
Message-ID: <a27ad1a3-34bd-6b7d-fd09-7737ec3c888d@gmail.com>
Date: Fri, 24 Aug 2018 13:57:52 +0200
MIME-Version: 1.0
In-Reply-To: <20180824115226.GK29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, christian.koenig@amd.com
Cc: kvm@vger.kernel.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Dimitri Sivanich <sivanich@sgi.com>, Jason Gunthorpe <jgg@ziepe.ca>, linux-rdma@vger.kernel.org, amd-gfx@lists.freedesktop.org, David Airlie <airlied@linux.ie>, Doug Ledford <dledford@redhat.com>, David Rientjes <rientjes@google.com>, xen-devel@lists.xenproject.org, intel-gfx@lists.freedesktop.org, Jani Nikula <jani.nikula@linux.intel.com>, Leon Romanovsky <leonro@mellanox.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, LKML <linux-kernel@vger.kernel.org>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Deucher <alexander.deucher@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Felix Kuehling <felix.kuehling@amd.com>

Am 24.08.2018 um 13:52 schrieb Michal Hocko:
> On Fri 24-08-18 13:43:16, Christian KA?nig wrote:
>> Am 24.08.2018 um 13:32 schrieb Michal Hocko:
>>> On Fri 24-08-18 19:54:19, Tetsuo Handa wrote:
>>>> Two more worries for this patch.
>>>>
>>>>
>>>>
>>>>> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
>>>>> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c
>>>>> @@ -178,12 +178,18 @@ void amdgpu_mn_unlock(struct amdgpu_mn *mn)
>>>>>     *
>>>>>     * @amn: our notifier
>>>>>     */
>>>>> -static void amdgpu_mn_read_lock(struct amdgpu_mn *amn)
>>>>> +static int amdgpu_mn_read_lock(struct amdgpu_mn *amn, bool blockable)
>>>>>    {
>>>>> -       mutex_lock(&amn->read_lock);
>>>>> +       if (blockable)
>>>>> +               mutex_lock(&amn->read_lock);
>>>>> +       else if (!mutex_trylock(&amn->read_lock))
>>>>> +               return -EAGAIN;
>>>>> +
>>>>>           if (atomic_inc_return(&amn->recursion) == 1)
>>>>>                   down_read_non_owner(&amn->lock);
>>>> Why don't we need to use trylock here if blockable == false ?
>>>> Want comment why it is safe to use blocking lock here.
>>> Hmm, I am pretty sure I have checked the code but it was quite confusing
>>> so I might have missed something. Double checking now, it seems that
>>> this read_lock is not used anywhere else and it is not _the_ lock we are
>>> interested about. It is the amn->lock (amdgpu_mn_lock) which matters as
>>> it is taken in exclusive mode for expensive operations.
>> The write side of the lock is only taken in the command submission IOCTL.
>>
>> So you actually don't need to change anything here (even the proposed
>> changes are overkill) since we can't tear down the struct_mm while an IOCTL
>> is still using.
> I am not so sure. We are not in the mm destruction phase yet. This is
> mostly about the oom context which might fire right during the IOCTL. If
> any of the path which is holding the write lock blocks for unbound
> amount of time or even worse allocates a memory then we are screwed. So
> we need to back of when blockable = false.

Oh, yeah good point. Haven't thought about that possibility.

>
>>> Is that correct Christian? If this is correct then we need to update the
>>> locking here. I am struggling to grasp the ref counting part. Why cannot
>>> all readers simply take the lock rather than rely on somebody else to
>>> take it? 1ed3d2567c800 didn't really help me to understand the locking
>>> scheme here so any help would be appreciated.
>> That won't work like this there might be multiple
>> invalidate_range_start()/invalidate_range_end() pairs open at the same time.
>> E.g. the lock might be taken recursively and that is illegal for a
>> rw_semaphore.
> I am not sure I follow. Are you saying that one invalidate_range might
> trigger another one from the same path?

No, but what can happen is:

invalidate_range_start(A,B);
invalidate_range_start(C,D);
...
invalidate_range_end(C,D);
invalidate_range_end(A,B);

Grabbing the read lock twice would be illegal in this case.

Regards,
Christian.
