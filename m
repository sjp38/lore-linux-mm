Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8DA1C6B0493
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 11:04:24 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id 6so67856277qts.7
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 08:04:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m88si24099012qtd.363.2017.07.31.08.04.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 08:04:23 -0700 (PDT)
Subject: Re: [RFC] virtio-mem: paravirtualized memory
References: <547865a9-d6c2-7140-47e2-5af01e7d761d@redhat.com>
 <0a7cd2a8-45ff-11d1-ddb5-036ce36af163@redhat.com>
 <CAPcyv4iYdEAv7wqun5L1C-gT7fMDpO+M918or-bg5XiWLnM3=w@mail.gmail.com>
 <d5a1f1d2-f7c8-cacc-3267-ed6f7d2507ca@redhat.com>
 <20170731162757-mutt-send-email-mst@kernel.org>
From: David Hildenbrand <david@redhat.com>
Message-ID: <730c3076-6bfd-9a96-3851-42ea5c329891@redhat.com>
Date: Mon, 31 Jul 2017 17:04:16 +0200
MIME-Version: 1.0
In-Reply-To: <20170731162757-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, KVM <kvm@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Pankaj Gupta <pagupta@redhat.com>, Rik van Riel <riel@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>

On 31.07.2017 16:12, Michael S. Tsirkin wrote:
> On Fri, Jul 28, 2017 at 05:48:07PM +0200, David Hildenbrand wrote:
>> In general, a paravirtualized interface (for detection of PMEM regions)
>> might have one big advantage: not limited to certain architectures.
> 
> What follows is a generic rant, and slightly offtopic -sorry about that.
> I thought it's worth replying to above since people sometimes propose
> random PV devices and portability is often the argument. I'd claim if
> its the only argument - its not a very good one.

Very good point. Thanks for that comment. I totally agree, that we have
to decide for which parts we really need a paravirtualized interface. We
already paravirtualized quite a lot (starting with clocks and mmios,
ending with network devices).

Related to fake DAX, think about this example (cc'ing Christian, so I
don't talk too much nonsense):

s390x hardware cannot map anything into the address space. Not even PCI
devices on s390x work that way. So the whole architecture (to this point
I am aware of) is built on this fact. We can indicate "valid memory
regions" to the guest via a standardized interface, but the guest will
simply treat it like RAM.

With virtualization, this is different. We can map whatever we want into
the guest address space, but we have to tell the guest that this area is
special. There is no ACPI on s390x to do that.

This implies, that for s390x, we could not support fake DAX, just
because we don't have ACPI. No fake DAX, no avoiding of page caches in
the guest. Which is something we _could_ avoid quite easily.

> 
> One of the points of KVM is to try and reuse the infrastructure in Linux
> that runs containers/bare metal anyway.  The more paravirtualized
> interfaces you build, the more effort you get to spend to maintain
> various aspects of the system. As optimizations force more and more
> paravirtualization into the picture, our solution has been to try to
> localize their effect, so you can mix and match paravirtualization and
> emulation, as well as enable a subset of PV things that makes sense. For
> example, virtio devices look more or less like PCI devices on systems
> that have PCI.
We make paravirtualized devices look like them, but what we (in most
cases) don't do is the following: Detect and use devices via a
!paravirtualized way and later on decide "oh, this device is special"
and treat it suddenly like a paravirtualized device*.

E.g. virtio-scsi, an unmodified guest will not simply detect and use,
say, a virtio-scsi attached disk. (unless I am very wrong on that point ;) )

*This might work for devices, where paravirtualization is e.g. just a
way to speedup things. But if paravirtualization is part of the concept
(fake DAX - we need that flush), this will not work.

In the words of s390x: indicate fake DAX as ordinary ram. The guest will
hotplug it and use it like ordinary ram. At that point, it is too late
to convert it logically into a disk.


What I think is the following: We need a way to advertise devices that
are mapped into the address space via a paravirtualized way. This could
e.g. be fake DAX devices or what virtio-mem's memory hotplug approach
tries to solve.

Basically what virtio-mem proposed: indicating devices in the form of
memory regions that are special to the guest via a paravirtualized
interface and providing paravirtualized features, that can (and even
have to) be used along with these special devices.

> 
> It's not clear it applies here - memory overcommit on bare metal is
> kind of different.

Yes, there is no such thing as fine grained memory hot(un)plug on real
hardware.

-- 

Thanks,

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
