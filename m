Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4CFF16B026B
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 08:40:12 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id e1-v6so9846788pld.23
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 05:40:12 -0700 (PDT)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0075.outbound.protection.outlook.com. [104.47.37.75])
        by mx.google.com with ESMTPS id t65-v6si14395454pgt.300.2018.07.02.05.40.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 02 Jul 2018 05:40:11 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom: distinguish blockable mode for mmu notifiers
References: <20180622150242.16558-1-mhocko@kernel.org>
 <20180627074421.GF32348@dhcp22.suse.cz>
 <71f4184c-21ea-5af1-eeb6-bf7787614e2d@amd.com>
 <20180702115423.GK19043@dhcp22.suse.cz>
 <725cb1ad-01b0-42b5-56f0-c08c29804cb4@amd.com>
 <20180702122003.GN19043@dhcp22.suse.cz>
 <02d1d52c-f534-f899-a18c-a3169123ac7c@amd.com>
 <20180702123521.GO19043@dhcp22.suse.cz>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Message-ID: <91ad1106-6bd4-7d2c-4d40-7c5be945ba36@amd.com>
Date: Mon, 2 Jul 2018 14:39:50 +0200
MIME-Version: 1.0
In-Reply-To: <20180702123521.GO19043@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Felix Kuehling <felix.kuehling@amd.com>

Am 02.07.2018 um 14:35 schrieb Michal Hocko:
> On Mon 02-07-18 14:24:29, Christian KA?nig wrote:
>> Am 02.07.2018 um 14:20 schrieb Michal Hocko:
>>> On Mon 02-07-18 14:13:42, Christian KA?nig wrote:
>>>> Am 02.07.2018 um 13:54 schrieb Michal Hocko:
>>>>> On Mon 02-07-18 11:14:58, Christian KA?nig wrote:
>>>>>> Am 27.06.2018 um 09:44 schrieb Michal Hocko:
>>>>>>> This is the v2 of RFC based on the feedback I've received so far. The
>>>>>>> code even compiles as a bonus ;) I haven't runtime tested it yet, mostly
>>>>>>> because I have no idea how.
>>>>>>>
>>>>>>> Any further feedback is highly appreciated of course.
>>>>>> That sounds like it should work and at least the amdgpu changes now look
>>>>>> good to me on first glance.
>>>>>>
>>>>>> Can you split that up further in the usual way? E.g. adding the blockable
>>>>>> flag in one patch and fixing all implementations of the MMU notifier in
>>>>>> follow up patches.
>>>>> But such a code would be broken, no? Ignoring the blockable state will
>>>>> simply lead to lockups until the fixup parts get applied.
>>>> Well to still be bisect-able you only need to get the interface change in
>>>> first with fixing the function signature of the implementations.
>>> That would only work if those functions return -AGAIN unconditionally.
>>> Otherwise they would pretend to not block while that would be obviously
>>> incorrect. This doesn't sound correct to me.
>>>
>>>> Then add all the new code to the implementations and last start to actually
>>>> use the new interface.
>>>>
>>>> That is a pattern we use regularly and I think it's good practice to do
>>>> this.
>>> But we do rely on the proper blockable handling.
>> Yeah, but you could add the handling only after you have all the
>> implementations in place. Don't you?
> Yeah, but then I would be adding a code with no user. And I really
> prefer to no do so because then the code is harder to argue about.
>
>>>>> Is the split up really worth it? I was thinking about that but had hard
>>>>> times to end up with something that would be bisectable. Well, except
>>>>> for returning -EBUSY until all notifiers are implemented. Which I found
>>>>> confusing.
>>>> It at least makes reviewing changes much easier, cause as driver maintainer
>>>> I can concentrate on the stuff only related to me.
>>>>
>>>> Additional to that when you cause some unrelated side effect in a driver we
>>>> can much easier pinpoint the actual change later on when the patch is
>>>> smaller.
>>>>
>>>>>> This way I'm pretty sure Felix and I can give an rb on the amdgpu/amdkfd
>>>>>> changes.
>>>>> If you are worried to give r-b only for those then this can be done even
>>>>> for larger patches. Just make your Reviewd-by more specific
>>>>> R-b: name # For BLA BLA
>>>> Yeah, possible alternative but more work for me when I review it :)
>>> I definitely do not want to add more work to reviewers and I completely
>>> see how massive "flag days" like these are not popular but I really
>>> didn't find a reasonable way around that would be both correct and
>>> wouldn't add much more churn on the way. So if you really insist then I
>>> would really appreciate a hint on the way to achive the same without any
>>> above downsides.
>> Well, I don't insist on this. It's just from my point of view that this
>> patch doesn't needs to be one patch, but could be split up.
> Well, if there are more people with the same concern I can try to do
> that. But if your only concern is to focus on your particular part then
> I guess it would be easier both for you and me to simply apply the patch
> and use git show $files_for_your_subystem on your end. I have put the
> patch to attempts/oom-vs-mmu-notifiers branch to my tree at
> git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git

Not wanting to block something as important as this, so feel free to add 
an Acked-by: Christian KA?nig <christian.koenig@amd.com> to the patch.

Let's rather face the next topic: Any idea how to runtime test this?

I mean I can rather easily provide a test which crashes an AMD GPU, 
which in turn then would mean that the MMU notifier would block forever 
without this patch.

But do you know a way to let the OOM killer kill a specific process?

Regards,
Christian.
