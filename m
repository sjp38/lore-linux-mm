Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E4D5F6B0008
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 08:14:03 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z5-v6so9914483pln.20
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 05:14:03 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0084.outbound.protection.outlook.com. [104.47.42.84])
        by mx.google.com with ESMTPS id m75-v6si16043112pfj.192.2018.07.02.05.14.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 02 Jul 2018 05:14:02 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom: distinguish blockable mode for mmu notifiers
References: <20180622150242.16558-1-mhocko@kernel.org>
 <20180627074421.GF32348@dhcp22.suse.cz>
 <71f4184c-21ea-5af1-eeb6-bf7787614e2d@amd.com>
 <20180702115423.GK19043@dhcp22.suse.cz>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Message-ID: <725cb1ad-01b0-42b5-56f0-c08c29804cb4@amd.com>
Date: Mon, 2 Jul 2018 14:13:42 +0200
MIME-Version: 1.0
In-Reply-To: <20180702115423.GK19043@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Felix Kuehling <felix.kuehling@amd.com>

Am 02.07.2018 um 13:54 schrieb Michal Hocko:
> On Mon 02-07-18 11:14:58, Christian KA?nig wrote:
>> Am 27.06.2018 um 09:44 schrieb Michal Hocko:
>>> This is the v2 of RFC based on the feedback I've received so far. The
>>> code even compiles as a bonus ;) I haven't runtime tested it yet, mostly
>>> because I have no idea how.
>>>
>>> Any further feedback is highly appreciated of course.
>> That sounds like it should work and at least the amdgpu changes now look
>> good to me on first glance.
>>
>> Can you split that up further in the usual way? E.g. adding the blockable
>> flag in one patch and fixing all implementations of the MMU notifier in
>> follow up patches.
> But such a code would be broken, no? Ignoring the blockable state will
> simply lead to lockups until the fixup parts get applied.

Well to still be bisect-able you only need to get the interface change 
in first with fixing the function signature of the implementations.

Then add all the new code to the implementations and last start to 
actually use the new interface.

That is a pattern we use regularly and I think it's good practice to do 
this.

> Is the split up really worth it? I was thinking about that but had hard
> times to end up with something that would be bisectable. Well, except
> for returning -EBUSY until all notifiers are implemented. Which I found
> confusing.

It at least makes reviewing changes much easier, cause as driver 
maintainer I can concentrate on the stuff only related to me.

Additional to that when you cause some unrelated side effect in a driver 
we can much easier pinpoint the actual change later on when the patch is 
smaller.

>
>> This way I'm pretty sure Felix and I can give an rb on the amdgpu/amdkfd
>> changes.
> If you are worried to give r-b only for those then this can be done even
> for larger patches. Just make your Reviewd-by more specific
> R-b: name # For BLA BLA

Yeah, possible alternative but more work for me when I review it :)

Regards,
Christian.
