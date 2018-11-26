Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8C81C6B3F78
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 08:05:45 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id n45so16608080qta.5
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 05:05:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p65si248471qkh.93.2018.11.26.05.05.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 05:05:44 -0800 (PST)
Subject: Re: [RFC PATCH 0/4] mm, memory_hotplug: allocate memmap from hotadded
 memory
References: <20181116101222.16581-1-osalvador@suse.com>
 <2571308d-0460-e8b9-ad40-75d6b13b2d09@redhat.com>
 <20181123115519.2dnzscmmgv63fdub@d104.suse.de>
From: David Hildenbrand <david@redhat.com>
Message-ID: <7095eab7-bcff-204b-beb1-fed5e4151f87@redhat.com>
Date: Mon, 26 Nov 2018 14:05:39 +0100
MIME-Version: 1.0
In-Reply-To: <20181123115519.2dnzscmmgv63fdub@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.com>
Cc: linux-mm@kvack.org, mhocko@suse.com, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, arunks@codeaurora.org, bhe@redhat.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, jglisse@redhat.com, linux-kernel@vger.kernel.org

On 23.11.18 12:55, Oscar Salvador wrote:
> On Thu, Nov 22, 2018 at 10:21:24AM +0100, David Hildenbrand wrote:
>> 1. How are we going to present such memory to the system statistics?
>>
>> In my opinion, this vmemmap memory should
>> a) still account to total memory
>> b) show up as allocated
>>
>> So just like before.
> 
> No, it does not show up under total memory and neither as allocated memory.
> This memory is not for use for anything but for creating the pagetables
> for the memmap array for the section/s.
> 
> It is not memory that the system can use.
> 
> I also guess that if there is a strong opinion on this, we could create
> a counter, something like NR_VMEMMAP_PAGES, and show it under /proc/meminfo.
> 
>> 2. Is this optional, in other words, can a device driver decide to not
>> to it like that?
> 
> Right now, is a per arch setup.
> For example, x86_64/powerpc/arm64 will do it inconditionally.
> 

Just FYI another special case is s390x right now when it comes to adding
standby memory: (linux/drivers/s390/char/sclp_cmd.c)

There are two issues:

a) Storage keys

On s390x, storage keys have to be initialized before memory might be
used (think of it as 7bit page status/protection for each 4k page
managed and stored by the HW separately)

Storage keys are initialized in sclp_assign_storage(), when the memory
is going online (MEM_GOING_ONLINE).

b) Hypervisor making memory accessible

Only when onlining memory, the memory is actually made accessible in the
hypervisor (sclp_assign_storage()). Touching it before that is bad and
will fail.

You can think of standby memory on s390x like memory that is only
onlined on request by an administrator. Once onlined, the hypervisor
will allocate memory for it.


However, once we have other ways of adding memory to a s390x guest (e.g.
virtio-mem) at least b) is not an issue anymore. a) would require manual
tweaking (e.g. initialize storage keys of memory for vmmaps early).


So in summary as of now your approach will not work on s390x, but with
e.g. virtio-mem it could. We would need some interface to specify how to
add memory. (To somehow allow a driver to specify it - e.g. SCLP vs.
virtio-mem)

Cheers!

-- 

Thanks,

David / dhildenb
