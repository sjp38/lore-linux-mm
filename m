Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 00A1C6B2D68
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:52:02 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id t18so8715664qtj.3
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 04:52:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k63si633548qkk.82.2018.11.23.04.52.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 04:52:01 -0800 (PST)
Subject: Re: [RFC PATCH 0/4] mm, memory_hotplug: allocate memmap from hotadded
 memory
References: <20181116101222.16581-1-osalvador@suse.com>
 <2571308d-0460-e8b9-ad40-75d6b13b2d09@redhat.com>
 <20181123115519.2dnzscmmgv63fdub@d104.suse.de>
 <20181123124228.GI8625@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <4fd2e8fe-a85d-af96-ee04-8ddfd1fbe79d@redhat.com>
Date: Fri, 23 Nov 2018 13:51:57 +0100
MIME-Version: 1.0
In-Reply-To: <20181123124228.GI8625@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oscar Salvador <osalvador@suse.com>, linux-mm@kvack.org, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, arunks@codeaurora.org, bhe@redhat.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, jglisse@redhat.com, linux-kernel@vger.kernel.org

On 23.11.18 13:42, Michal Hocko wrote:
> On Fri 23-11-18 12:55:41, Oscar Salvador wrote:
>> On Thu, Nov 22, 2018 at 10:21:24AM +0100, David Hildenbrand wrote:
>>> 1. How are we going to present such memory to the system statistics?
>>>
>>> In my opinion, this vmemmap memory should
>>> a) still account to total memory
>>> b) show up as allocated
>>>
>>> So just like before.
>>
>> No, it does not show up under total memory and neither as allocated memory.
>> This memory is not for use for anything but for creating the pagetables
>> for the memmap array for the section/s.
> 
> I haven't read through your patches yet but wanted to clarfify few
> points here.
> 
> This should essentially follow the bootmem allocated memory pattern. So
> it is present and accounted to spanned pages but it is not managed.
> 
>> It is not memory that the system can use.
> 
> same as bootmem ;)

Fair enough, just saying that it represents a change :)

(but people also already complained if their VM has XGB but they don't
see actual XGB as total memory e.g. due to the crash kernel size)

>  
>> I also guess that if there is a strong opinion on this, we could create
>> a counter, something like NR_VMEMMAP_PAGES, and show it under /proc/meminfo.
> 
> Do we really have to? Isn't the number quite obvious from the size of
> the hotpluged memory?

At least the size of vmmaps cannot reliably calculated from "MemTotal" .
But maybe based on something else. (there, it is indeed obvious)

> 
>>
>>> 2. Is this optional, in other words, can a device driver decide to not
>>> to it like that?
>>
>> Right now, is a per arch setup.
>> For example, x86_64/powerpc/arm64 will do it inconditionally.
>>
>> If we want to restrict this a per device-driver thing, I guess that we could
>> allow to pass a flag to add_memory()->add_memory_resource(), and there
>> unset MHP_MEMMAP_FROM_RANGE in case that flag is enabled.
> 
> I believe we will need to make this opt-in. There are some usecases
> which hotplug an expensive (per size) memory via hotplug and it would be
> too wasteful to use it for struct pages. I haven't bothered to address
> that with my previous patches because I just wanted to make the damn
> thing work first.
> 

Good point.


-- 

Thanks,

David / dhildenb
