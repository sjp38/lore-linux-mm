Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 374886B080F
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 07:56:41 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c27-v6so7372025qkj.3
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 04:56:41 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k1-v6si1752321qvf.138.2018.08.17.04.56.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Aug 2018 04:56:40 -0700 (PDT)
Subject: Re: [PATCH RFC 1/2] drivers/base: export
 lock_device_hotplug/unlock_device_hotplug
References: <20180817075901.4608-1-david@redhat.com>
 <20180817075901.4608-2-david@redhat.com> <20180817084146.GB14725@kroah.com>
 <5a5d73e9-e4aa-ffed-a2e3-8aef64e61923@redhat.com>
 <CAJZ5v0gkYV8o2Eq+EcGT=OP1tQGPGVVe3n9VGD6z7KAVVqhv9w@mail.gmail.com>
 <42df9062-f647-3ad6-5a07-be2b99531119@redhat.com>
 <20180817100604.GA18164@kroah.com>
 <4ac624be-d2d6-5975-821f-b20a475781dc@redhat.com>
 <20180817112850.GB3565@osiris>
From: David Hildenbrand <david@redhat.com>
Message-ID: <ecc08303-96ee-76ad-fba4-0425413afa5a@redhat.com>
Date: Fri, 17 Aug 2018 13:56:35 +0200
MIME-Version: 1.0
In-Reply-To: <20180817112850.GB3565@osiris>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Michal Hocko <mhocko@suse.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linux Memory Management List <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, linux-s390@vger.kernel.org, sthemmin@microsoft.com, Pavel Tatashin <pasha.tatashin@oracle.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, David Rientjes <rientjes@google.com>, xen-devel@lists.xenproject.org, Len Brown <lenb@kernel.org>, haiyangz@microsoft.com, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, osalvador@suse.de, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, devel@linuxdriverproject.org, Vitaly Kuznetsov <vkuznets@redhat.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On 17.08.2018 13:28, Heiko Carstens wrote:
> On Fri, Aug 17, 2018 at 01:04:58PM +0200, David Hildenbrand wrote:
>>>> If there are no objections, I'll go into that direction. But I'll wait
>>>> for more comments regarding the general concept first.
>>>
>>> It is the middle of the merge window, and maintainers are really busy
>>> right now.  I doubt you will get many review comments just yet...
>>>
>>
>> This has been broken since 2015, so I guess it can wait a bit :)
> 
> I hope you figured out what needs to be locked why. Your patch description
> seems to be "only" about locking order ;)

Well I hope so, too ... but there is a reason for the RFC mark ;) There
is definitely a lot of magic in the current code. And that's why it is
also not that obvious that locking is wrong.

To avoid/fix the locking order problem was the motivation for the
original patch that dropped mem_hotplug_lock on one path. So I focused
on that in my description.

> 
> I tried to figure out and document that partially with 55adc1d05dca ("mm:
> add private lock to serialize memory hotplug operations"), and that wasn't
> easy to figure out. I was especially concerned about sprinkling

Haven't seen that so far as that was reworked by 3f906ba23689
("mm/memory-hotplug: switch locking to a percpu rwsem"). Thanks for the
pointer. There is a long history to all this.

> lock/unlock_device_hotplug() calls, which has the potential to make it the
> next BKL thing.

Well, the thing with memory hotplug and device_hotplug_lock is that

a) ACPI already holds it while adding/removing memory via add_memory()
b) we hold it during online/offline of memory (via sysfs calls to
   device_online()/device_offline())

So it is already pretty much involved in all memory hotplug/unplug
activities on x86 (except paravirt). And as far as I understand, there
are good reasons to hold the lock in core.c and ACPI. (as mentioned by
Rafael)

The exceptions are add_memory() called on s390x, hyper-v, xen and ppc
(including manual probing). And device_online()/device_offline() called
from the kernel.

Holding device_hotplug_lock when adding/removing memory from the system
doesn't sound too wrong (especially as devices are created/removed). At
least that way (documenting and following the rules in the patch
description) we might at least get locking right.


I am very open to other suggestions (but as noted by Greg, many
maintainers might be busy by know).

E.g. When adding the memory block devices, we know that there won't be a
driver to attach to (as there are no drivers for the "memory" subsystem)
- the bus_probe_device() function that takes the device_lock() could
pretty much be avoided for that case. But burying such special cases
down in core driver code definitely won't make locking related to memory
hotplug easier.

Thanks for having a look!

-- 

Thanks,

David / dhildenb
