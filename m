Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF7B6B055F
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 11:48:14 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d136so62423433qkg.11
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 08:48:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r64si18864316qkr.100.2017.07.28.08.48.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 08:48:13 -0700 (PDT)
Subject: Re: [RFC] virtio-mem: paravirtualized memory
References: <547865a9-d6c2-7140-47e2-5af01e7d761d@redhat.com>
 <0a7cd2a8-45ff-11d1-ddb5-036ce36af163@redhat.com>
 <CAPcyv4iYdEAv7wqun5L1C-gT7fMDpO+M918or-bg5XiWLnM3=w@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <d5a1f1d2-f7c8-cacc-3267-ed6f7d2507ca@redhat.com>
Date: Fri, 28 Jul 2017 17:48:07 +0200
MIME-Version: 1.0
In-Reply-To: <CAPcyv4iYdEAv7wqun5L1C-gT7fMDpO+M918or-bg5XiWLnM3=w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: KVM <kvm@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Michael S. Tsirkin" <mst@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Pankaj Gupta <pagupta@redhat.com>, Rik van Riel <riel@redhat.com>

On 28.07.2017 17:16, Dan Williams wrote:
> On Fri, Jul 28, 2017 at 4:09 AM, David Hildenbrand <david@redhat.com> wrote:
>> Btw, I am thinking about the following addition to the concept:
>>
>> 1. Add a type to each virtio-mem device.
>>
>> This describes the type of the memory region we expose to the guest.
>> Initially, we could have RAM and RAM_HUGE. The latter one would be
>> interesting, because the guest would know that this memory is based on
>> huge pages in case we would ever want to expose different RAM types to a
>> guest (the guest could conclude that this memory might be faster and
>> would also best be used with huge pages in the guest). But we could also
>> simply start only with RAM.
> 
> I think it's up to the hypervisor to manage whether the guest is
> getting huge pages or not and the guest need not know. As for
> communicating differentiated memory media performance we have the ACPI
> HMAT (Heterogeneous Memory Attributes Table) for that.

Yes, in the world of ACPI I agree.

> 
>> 2. Adding also a guest -> host command queue.
>>
>> That can be used to request/notify the host about something. As written
>> in the original proposal, for ordinary RAM this could be used to request
>> more/less memory out of the guest.
> 
> I would hope that where possible we minimize paravirtualized
> interfaces and just use standardized interfaces. In the case of memory
> hotplug, ACPI already defines that interface.

I partly agree in the world of ACPI. If you just want to add/remove
memory in the form of DIMMs, yes. This already works just fine. For
other approaches in the context of virtualization (e.g. ballooners that
XEN or Hyper-V use, or also what virtio-mem tries to achieve), this is
not enough. They need a different way of memory hotplug (as e.g. XEN and
Hyper-V already have).

Especially when trying to standardize stuff in form of virtio - binding
it to a technology specific to a handful of architectures is not
desired. Until now (as far as I remember), all but 2 virtio types
(virtio-balloon and virtio-iommu) operate on their own system resources
only, not on some resources exposed/detected via different interfaces.

> 
>> This might come in handy for other memory regions we just want to expose
>> to the guest via a paravirtualized interface. The resize features
>> (adding/removing memory) might not apply to these, but we can simply
>> restrict that to certain types.
>>
>> E.g. if we want to expose PMEM memory region to a guest using a
>> paravirtualized interface (or anything else that can be mapped into
>> guest memory in the form of memory regions), we could use this. The
>> guest->host control queue can be used for tasks that typically cannot be
>> done if moddeling something like this using ordinary ACPI DIMMs
>> (flushing etc).
>>
>> CCing a couple of people that just thought about something like this in
>> the concept of fake DAX.
> 
> I'm not convinced that there is a use case for paravirtualized PMEM
> commands beyond this "fake-DAX" use case. Everything would seem to
> have a path through the standard ACPI platform communication
> mechanisms.

I don't know about further commands, most likely not really many more in
this scenario. I just pinged you guys to have a look when I heard the
term virtio-pmem.

In general, a paravirtualized interface (for detection of PMEM regions)
might have one big advantage: not limited to certain architectures.

With a paravirtualized interface, we can even support* fake DAX on
architectures that don't provide a "real HW" interface for it. I think
this sounds interesting.

*quite some effort will most likely be necessary for other architectures.

-- 

Thanks,

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
