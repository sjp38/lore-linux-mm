Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D880E6B0260
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 09:16:00 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l23so858082lfk.5
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 06:16:00 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b72sor1797770ljf.14.2017.10.11.06.15.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Oct 2017 06:15:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170930224927.GC6775@redhat.com>
References: <20170720150305.GA2767@redhat.com> <ab3e67d5-5ed5-816f-6f8e-3228866be1fe@huawei.com>
 <20170721014106.GB25991@redhat.com> <CAPcyv4jJraGPW214xJ+wU3G=88UUP45YiA6hV5_NvNZSNB4qGA@mail.gmail.com>
 <20170905193644.GD19397@redhat.com> <CAA_GA1ckfyokvqy3aKi-NoSXxSzwiVsrykC6xNxpa3WUz0bqNQ@mail.gmail.com>
 <20170911233649.GA4892@redhat.com> <CAA_GA1ff4mGKfxxRpjYCRjXOvbUuksM0K2gmH1VrhL4qtGWFbw@mail.gmail.com>
 <20170926161635.GA3216@redhat.com> <0d7273c3-181c-6d68-3c5f-fa518e782374@huawei.com>
 <20170930224927.GC6775@redhat.com>
From: Bob Liu <lliubbo@gmail.com>
Date: Wed, 11 Oct 2017 21:15:57 +0800
Message-ID: <CAA_GA1dhrs7n-ewZmW4bNtouK8rKnF1_TWv0z+2vrUgJjWpnMQ@mail.gmail.com>
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Bob Liu <liubo95@huawei.com>, Dan Williams <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Oct 1, 2017 at 6:49 AM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Sat, Sep 30, 2017 at 10:57:38AM +0800, Bob Liu wrote:
>> On 2017/9/27 0:16, Jerome Glisse wrote:
>> > On Tue, Sep 26, 2017 at 05:56:26PM +0800, Bob Liu wrote:
>> >> On Tue, Sep 12, 2017 at 7:36 AM, Jerome Glisse <jglisse@redhat.com> wrote:
>> >>> On Sun, Sep 10, 2017 at 07:22:58AM +0800, Bob Liu wrote:
>> >>>> On Wed, Sep 6, 2017 at 3:36 AM, Jerome Glisse <jglisse@redhat.com> wrote:
>> >>>>> On Thu, Jul 20, 2017 at 08:48:20PM -0700, Dan Williams wrote:
>> >>>>>> On Thu, Jul 20, 2017 at 6:41 PM, Jerome Glisse <jglisse@redhat.com> wrote:
>> [...]
>> >>>>> So i pushed a branch with WIP for nouveau to use HMM:
>> >>>>>
>> >>>>> https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-nouveau
>> >>>>>
>> >>>>
>> >>>> Nice to see that.
>> >>>> Btw, do you have any plan for a CDM-HMM driver? CPU can write to
>> >>>> Device memory directly without extra copy.
>> >>>
>> >>> Yes nouveau CDM support on PPC (which is the only CDM platform commercialy
>> >>> available today) is on the TODO list. Note that the driver changes for CDM
>> >>> are minimal (probably less than 100 lines of code). From the driver point
>> >>> of view this is memory and it doesn't matter if it is CDM or not.
>> >>>
>> >>
>> >> It seems have to migrate/copy memory between system-memory and
>> >> device-memory even in HMM-CDM solution.
>> >> Because device-memory is not added into buddy system, the page fault
>> >> for normal malloc() always allocate memory from system-memory!!
>> >> If the device then access the same virtual address, the data is copied
>> >> to device-memory.
>> >>
>> >> Correct me if I misunderstand something.
>> >> @Balbir, how do you plan to make zero-copy work if using HMM-CDM?
>> >
>> > Device can access system memory so copy to device is _not_ mandatory. Copying
>> > data to device is for performance only ie the device driver take hint from
>> > userspace and monitor device activity to decide which memory should be migrated
>> > to device memory to maximize performance.
>> >
>> > Moreover in some previous version of the HMM patchset we had an helper that
>>
>> Could you point in which version? I'd like to have a look.
>
> I will need to dig in.
>

Thank you.

>>
>> > allowed to directly allocate device memory on device page fault. I intend to
>> > post this helper again. With that helper you can have zero copy when device
>> > is the first to access the memory.
>> >
>> > Plan is to get what we have today work properly with the open source driver
>> > and make it perform well. Once we get some experience with real workload we
>> > might look into allowing CPU page fault to be directed to device memory but
>> > at this time i don't think we need this.
>> >
>>
>> For us, we need this feature that CPU page fault can be direct to device memory.
>> So that don't need to copy data from system memory to device memory.
>> Do you have any suggestion on the implementation? I'll try to make a prototype patch.
>
> Why do you need that ? What is the device and what are the requirement ?
>

You may think it as a CCIX device or CAPI device.
The requirement is eliminate any extra copy.
A typical usecase/requirement is malloc() and madvise() allocate from
device memory, then CPU write data to device memory directly and
trigger device to read the data/do calculation.

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
