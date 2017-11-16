Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 91D306B028C
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 22:29:12 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y42so13609554wrd.23
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 19:29:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a4sor51646wra.73.2017.11.15.19.29.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Nov 2017 19:29:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAsGZS5eoSK=Hd5av2bkw=chPGyfOYYNbrdizzCqq2gZ7+XH_g@mail.gmail.com>
References: <20170905193644.GD19397@redhat.com> <CAA_GA1ckfyokvqy3aKi-NoSXxSzwiVsrykC6xNxpa3WUz0bqNQ@mail.gmail.com>
 <20170911233649.GA4892@redhat.com> <CAA_GA1ff4mGKfxxRpjYCRjXOvbUuksM0K2gmH1VrhL4qtGWFbw@mail.gmail.com>
 <20170926161635.GA3216@redhat.com> <0d7273c3-181c-6d68-3c5f-fa518e782374@huawei.com>
 <20170930224927.GC6775@redhat.com> <CAA_GA1dhrs7n-ewZmW4bNtouK8rKnF1_TWv0z+2vrUgJjWpnMQ@mail.gmail.com>
 <20171012153721.GA2986@redhat.com> <CAAsGZS7JeH-cxrmZAVraLm5RjSVHJLXMdwZQ7Cxm91KGdVQocg@mail.gmail.com>
 <20171116024425.GC2934@redhat.com> <CAAsGZS5eoSK=Hd5av2bkw=chPGyfOYYNbrdizzCqq2gZ7+XH_g@mail.gmail.com>
From: chetan L <loke.chetan@gmail.com>
Date: Wed, 15 Nov 2017 19:29:10 -0800
Message-ID: <CAAsGZS43n2_f9sQXGH5Ap=eEx2f099CDwHC0aTTgOEbw7Dc=zg@mail.gmail.com>
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Bob Liu <lliubbo@gmail.com>, Bob Liu <liubo95@huawei.com>, Dan Williams <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan.Cameron@huawei.com, linux-accelerators@lists.ozlabs.org

On Wed, Nov 15, 2017 at 7:23 PM, chetan L <loke.chetan@gmail.com> wrote:
> CC'ing : linux-accelerators@vger.kernel.org
>

Sorry, CC'ing the correct list this time: linux-accelerators@lists.ozlabs.org



> On Wed, Nov 15, 2017 at 6:44 PM, Jerome Glisse <jglisse@redhat.com> wrote:
>> On Wed, Nov 15, 2017 at 06:10:08PM -0800, chet l wrote:
>>> >> You may think it as a CCIX device or CAPI device.
>>> >> The requirement is eliminate any extra copy.
>>> >> A typical usecase/requirement is malloc() and madvise() allocate from
>>> >> device memory, then CPU write data to device memory directly and
>>> >> trigger device to read the data/do calculation.
>>> >
>>> > I suggest you rely on the device driver userspace API to do a migration after malloc
>>> > then. Something like:
>>> >   ptr = malloc(size);
>>> >   my_device_migrate(ptr, size);
>>> >
>>> > Which would call an ioctl of the device driver which itself would migrate memory or
>>> > allocate device memory for the range if pointer return by malloc is not yet back by
>>> > any pages.
>>> >
>>>
>>> So for CCIX, I don't think there is going to be an inline device
>>> driver that would allocate any memory for you. The expansion memory
>>> will become part of the system memory as part of the boot process. So,
>>> if the host DDR is 256GB and the CCIX expansion memory is 4GB, the
>>> total system mem will be 260GB.
>>>
>>> Assume that the 'mm' is taught to mark/anoint the ZONE_DEVICE(or
>>> ZONE_XXX) range from 256 to 260 GB. Then, for kmalloc it(mm) won't use
>>> the ZONE_DEV range. But for a malloc, it will/can use that range.
>>
>> HMM zone device memory would work with that, you just need to teach the
>> platform to identify this memory zone and not hotplug it. Again you
>> should rely on specific device driver API to allocate this memory.
>>
>
> @Jerome - a new linux-accelerator's list has just been created. I have
> CC'd that list since we have overlapping interests w.r.t CCIX.
>
> I cannot comment on surprise add/remove as of now ... will cross the
> bridge later.
>
>
>>> > There has been several discussions already about madvise/mbind/set_mempolicy/
>>> > move_pages and at this time i don't think we want to add or change any of them to
>>> > understand device memory. My personal opinion is that we first need to have enough
>>>
>>> We will visit these APIs when we are more closer to building exotic
>>> CCIX devices. And the plan is to present/express the CCIX proximity
>>> attributes just like a NUMA node-proximity attribute today. That way
>>> there would be minimal disruptions to the existing OS ecosystem.
>>
>> NUMA have been rejected previously see CDM/CAPI threads. So i don't see
>> it being accepted for CCIX either. My belief is that we want to hide this
>> inside device driver and only once we see multiple devices all doing the
>> same kind of thing we should move toward building something generic that
>> catter to CCIX devices.
>
>
> Thanks for pointing out the NUMA thingy. I will visit the CDM/CAPI
> threads to understand what was discussed before commenting further.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
