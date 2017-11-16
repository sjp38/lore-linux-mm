Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 028556B027F
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 21:10:11 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id l188so1569213wma.0
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 18:10:10 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w14sor70154wmd.91.2017.11.15.18.10.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 Nov 2017 18:10:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171012153721.GA2986@redhat.com>
References: <20170721014106.GB25991@redhat.com> <CAPcyv4jJraGPW214xJ+wU3G=88UUP45YiA6hV5_NvNZSNB4qGA@mail.gmail.com>
 <20170905193644.GD19397@redhat.com> <CAA_GA1ckfyokvqy3aKi-NoSXxSzwiVsrykC6xNxpa3WUz0bqNQ@mail.gmail.com>
 <20170911233649.GA4892@redhat.com> <CAA_GA1ff4mGKfxxRpjYCRjXOvbUuksM0K2gmH1VrhL4qtGWFbw@mail.gmail.com>
 <20170926161635.GA3216@redhat.com> <0d7273c3-181c-6d68-3c5f-fa518e782374@huawei.com>
 <20170930224927.GC6775@redhat.com> <CAA_GA1dhrs7n-ewZmW4bNtouK8rKnF1_TWv0z+2vrUgJjWpnMQ@mail.gmail.com>
 <20171012153721.GA2986@redhat.com>
From: chet l <loke.chetan@gmail.com>
Date: Wed, 15 Nov 2017 18:10:08 -0800
Message-ID: <CAAsGZS7JeH-cxrmZAVraLm5RjSVHJLXMdwZQ7Cxm91KGdVQocg@mail.gmail.com>
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Bob Liu <lliubbo@gmail.com>, Bob Liu <liubo95@huawei.com>, Dan Williams <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

>> You may think it as a CCIX device or CAPI device.
>> The requirement is eliminate any extra copy.
>> A typical usecase/requirement is malloc() and madvise() allocate from
>> device memory, then CPU write data to device memory directly and
>> trigger device to read the data/do calculation.
>
> I suggest you rely on the device driver userspace API to do a migration after malloc
> then. Something like:
>   ptr = malloc(size);
>   my_device_migrate(ptr, size);
>
> Which would call an ioctl of the device driver which itself would migrate memory or
> allocate device memory for the range if pointer return by malloc is not yet back by
> any pages.
>

So for CCIX, I don't think there is going to be an inline device
driver that would allocate any memory for you. The expansion memory
will become part of the system memory as part of the boot process. So,
if the host DDR is 256GB and the CCIX expansion memory is 4GB, the
total system mem will be 260GB.

Assume that the 'mm' is taught to mark/anoint the ZONE_DEVICE(or
ZONE_XXX) range from 256 to 260 GB. Then, for kmalloc it(mm) won't use
the ZONE_DEV range. But for a malloc, it will/can use that range.


> There has been several discussions already about madvise/mbind/set_mempolicy/
> move_pages and at this time i don't think we want to add or change any of them to
> understand device memory. My personal opinion is that we first need to have enough

We will visit these APIs when we are more closer to building exotic
CCIX devices. And the plan is to present/express the CCIX proximity
attributes just like a NUMA node-proximity attribute today. That way
there would be minimal disruptions to the existing OS ecosystem.



Chetan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
