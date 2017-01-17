Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id AEBC56B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 19:58:25 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id 65so35766459otq.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 16:58:25 -0800 (PST)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id t10si9277406otf.51.2017.01.16.16.58.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 16:58:24 -0800 (PST)
Received: by mail-oi0-x22f.google.com with SMTP id j15so111663637oih.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 16:58:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170116201311.GB4182@redhat.com>
References: <1484238642-10674-1-git-send-email-jglisse@redhat.com>
 <1484238642-10674-5-git-send-email-jglisse@redhat.com> <CAPcyv4gnXyxHGitBCLbksy8PnHtePQ8260DKiF7CX8FXj2CtFQ@mail.gmail.com>
 <20170116151713.GA4182@redhat.com> <CAPcyv4jajtY4Q1PtPe9Jr4PwYUPAxhaGBno7tmt+KraSwCNswQ@mail.gmail.com>
 <20170116201311.GB4182@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 16 Jan 2017 16:58:24 -0800
Message-ID: <CAPcyv4gLrykv-Dn9dKM-8kDVdYwtRU4XDXt+OndYAnrzP73U6g@mail.gmail.com>
Subject: Re: [HMM v16 04/15] mm/ZONE_DEVICE/unaddressable: add support for
 un-addressable device memory v2
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, Jan 16, 2017 at 12:13 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> On Mon, Jan 16, 2017 at 11:31:39AM -0800, Dan Williams wrote:
[..]
>> >> dev_pagemap is only meant for get_user_pages() to do lookups of ptes
>> >> with _PAGE_DEVMAP and take a reference against the hosting device..
>> >
>> > And i want to build on top of that to extend _PAGE_DEVMAP to support
>> > a new usecase for unaddressable device memory.
>> >
>> >>
>> >> Why can't HMM use the typical vm_operations_struct fault path and push
>> >> more of these details to a driver rather than the core?
>> >
>> > Because the vm_operations_struct has nothing to do with the device.
>> > We are talking about regular vma here. Think malloc, mmap, share
>> > memory, ...  not about mmap(/dev/thedevice,...)
>> >
>> > So the vm_operations_struct is never under device control and we can
>> > not, nor want to, rely on that.
>>
>> Can you explain more what's behind that "can not, nor want to"
>> statement? It seems to me that any awkwardness of moving to a
>> standalone device file interface is less than a maintaining a new /
>> parallel mm fault path through dev_pagemap.
>
> The whole point of HMM is to allow transparent usage of process address
> space on to a device like GPU. So it imply any vma (vm_area_struct) that
> result from usual mmap (ie any mmap either PRIVATE or SHARE as long as it
> is not a an mmap of a device file).
>
> It means that application can use malloc or the usual memory allocation
> primitive of the langage (c++, rust, python, ...) and directly use the
> memory it gets from that with the device.

So you need 100% support of all these mm paths for this hardware to be
useful at all? Does a separate device-driver and a userpace helper
library get you something like 80% of the functionality and then we
can debate the core mm changes to get the final 20%? Or am I just
completely off base with how people want to use this hardware?

> Device like GPU have a large pool of device memory that is not accessible
> by the CPU. This device memory has 10 times more bandwidth than system
> memory and has better latency then PCIE. Hence for the whole thing to
> make sense you need to allow to use it.
>
> For that you need to allow migration from system memory to device memory.
> Because you can not rely on special userspace allocator you have to
> assume that the vma (vm_area_struct) is a regular one. So we are left
> with having struct page for the device memory to allow migration to
> work without requiring too much changes to existing mm.
>
> Because device memory is not accessible by the CPU, you can not allow
> anyone to pin it and thus get_user_page* must trigger a migration back
> as CPU page fault would.
>
>
>> > So what we looking for here is struct page that can behave mostly
>> > like anyother except that we do not want to allow GUP to take a
>> > reference almost exactly what ZONE_DEVICE already provide.
>> >
>> > So do you have any fundamental objections to this patchset ? And if
>> > so, how do you propose i solve the problem i am trying to address ?
>> > Because hardware exist today and without something like HMM we will
>> > not be able to support such hardware.
>>
>> My pushback stems from it being a completely different use case for
>> devm_memremap_pages(), as evidenced by it growing from 4 arguments to
>> 9, and the ongoing maintenance overhead of understanding HMM
>> requirements when updating the pmem usage of ZONE_DEVICE.
>
> I rather reuse something existing and modify it to support more use case
> than try to add ZONE_DEVICE2 or ZONE_DEVICE_I_AM_DIFFERENT. I have made
> sure that my modifications to ZONE_DEVICE can be use without HMM. It is
> just a generic interface to support page fault and to allow to track last
> user of a device page. Both can be use indepentently from each other.
>
> To me the whole point of kernel is trying to share infrastructure accross
> as many hardware as possible and i am doing just that. I do not think HMM
> should be block because something that use to be for one specific use case
> now support 2 use cases. I am not breaking anything existing. Is it more
> work for you ? Maybe, but at Red Hat we intend to support it for as long
> as it is needed so you always have some one to talk to if you want to
> update ZONE_DEVICE.

Sharing infrastructure should not come at the expense of type safety
and clear usage rules.

For example the pmem case, before exposing ZONE_DEVICE memory to other
parts of the kernel, introduced the pfn_t type to distinguish DMA
capable pfns from other raw pfns. All programmatic ways of discovering
if a pmem range can support DMA use this type and explicit flags.

While we may not need ZONE_DEVICE2 we obviously need a different
wrapper around arch_add_memory() than devm_memremap_pages() for HMM
and likely a different physical address radix than pgmap_radix because
they are servicing 2 distinct purposes. For example, I don't think HMM
should be using unmodified arch_add_memory(). We shouldn't add
unaddressable memory to the linear address mappings when we know there
is nothing behind it, especially when it seems all you need from
arch_add_memory() is pfn_to_page() to be valid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
