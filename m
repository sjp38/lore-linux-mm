Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 981C36B0271
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 11:28:06 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id r72-v6so735685pfj.3
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 08:28:06 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id g13-v6si24457479plq.373.2018.10.10.08.28.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 08:28:05 -0700 (PDT)
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
References: <20180925200551.3576.18755.stgit@localhost.localdomain>
 <20180925202053.3576.66039.stgit@localhost.localdomain>
 <20181009170051.GA40606@tiger-server>
 <CAPcyv4g99_rJJSn0kWv5YO0Mzj90q1LH1wC3XrjCh1=x6mo7BQ@mail.gmail.com>
 <25092df0-b7b4-d456-8409-9c004cb6e422@linux.intel.com>
 <CAPcyv4gZV_V=iY0mHiiAWwbynqtPxLTwdZ0j0vQ0F95ZZ4nTZg@mail.gmail.com>
 <20181010125211.GA45572@tiger-server>
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Message-ID: <deb1264e-5a42-3467-9073-e829b8eab8ca@linux.intel.com>
Date: Wed, 10 Oct 2018 08:27:58 -0700
MIME-Version: 1.0
In-Reply-To: <20181010125211.GA45572@tiger-server>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Michal Hocko <mhocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>



On 10/10/2018 5:52 AM, Yi Zhang wrote:
> On 2018-10-09 at 14:19:32 -0700, Dan Williams wrote:
>> On Tue, Oct 9, 2018 at 1:34 PM Alexander Duyck
>> <alexander.h.duyck@linux.intel.com> wrote:
>>>
>>> On 10/9/2018 11:04 AM, Dan Williams wrote:
>>>> On Tue, Oct 9, 2018 at 3:21 AM Yi Zhang <yi.z.zhang@linux.intel.com> wrote:
>> [..]
>>>> That comment is incorrect, device-pages are never onlined. So I think
>>>> we can just skip that call to __SetPageReserved() unless the memory
>>>> range is MEMORY_DEVICE_{PRIVATE,PUBLIC}.
>>>>
>>>
>>> When pages are "onlined" via __free_pages_boot_core they clear the
>>> reserved bit, that is the reason for the comment. The reserved bit is
>>> meant to indicate that the page cannot be swapped out or moved based on
>>> the description of the bit.
>>
>> ...but ZONE_DEVICE pages are never onlined so I would expect
>> memmap_init_zone_device() to know that detail.
>>
>>> I would think with that being the case we still probably need the call
>>> to __SetPageReserved to set the bit with the expectation that it will
>>> not be cleared for device-pages since the pages are not onlined.
>>> Removing the call to __SetPageReserved would probably introduce a number
>>> of regressions as there are multiple spots that use the reserved bit to
>>> determine if a page can be swapped out to disk, mapped as system memory,
>>> or migrated.
> 
> Another things, it seems page_init/set_reserved already been done in the
> move_pfn_range_to_zone
>      |-->memmap_init_zone
>      	|-->for_each_page_in_pfn
> 		|-->__init_single_page
> 		|-->SetPageReserved
> 
> Why we haven't remove these redundant initial in memmap_init_zone?
> 
> Correct me if I missed something.

In this case it isn't redundant as only the vmmemmap pages are 
initialized in memmap_init_zone now. So all of the pages that are going 
to be used as device pages are not initialized until the call to 
memmap_init_zone_device. What I did is split the initialization of the 
pages into two parts in order to allow us to initialize the pages 
outside of the hotplug lock.

>>
>> Right, this is what Yi is working on... the PageReserved flag is
>> problematic for KVM. Auditing those locations it seems as long as we
>> teach hibernation to avoid ZONE_DEVICE ranges we can safely not set
>> the reserved flag for DAX pages. What I'm trying to avoid is a local
>> KVM hack to check for DAX pages when the Reserved flag is not
>> otherwise needed.
> Thanks Dan. Provide the patch link.
> 
> https://lore.kernel.org/lkml/cover.1536342881.git.yi.z.zhang@linux.intel.com

So it looks like your current logic is just working around the bit then 
since it just allows for reserved DAX pages.
