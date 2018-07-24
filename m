Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB956B026D
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 09:28:01 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id b8-v6so3189475qto.16
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 06:28:01 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w57-v6si8268679qtj.360.2018.07.24.06.28.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 06:28:00 -0700 (PDT)
Subject: Re: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
References: <20180720123422.10127-1-david@redhat.com>
 <9f46f0ed-e34c-73be-60ca-c892fb19ed08@suse.cz>
 <20180723123043.GD31229@dhcp22.suse.cz>
 <8daae80c-871e-49b6-1cf1-1f0886d3935d@redhat.com>
 <20180724072536.GB28386@dhcp22.suse.cz>
 <8eb22489-fa6b-9825-bc63-07867a40d59b@redhat.com>
 <20180724131343.GK28386@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <af5353ee-319e-17ec-3a39-df997a5adf43@redhat.com>
Date: Tue, 24 Jul 2018 15:27:51 +0200
MIME-Version: 1.0
In-Reply-To: <20180724131343.GK28386@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>

On 24.07.2018 15:13, Michal Hocko wrote:
> On Tue 24-07-18 14:17:12, David Hildenbrand wrote:
>> On 24.07.2018 09:25, Michal Hocko wrote:
>>> On Mon 23-07-18 19:20:43, David Hildenbrand wrote:
>>>> On 23.07.2018 14:30, Michal Hocko wrote:
>>>>> On Mon 23-07-18 13:45:18, Vlastimil Babka wrote:
>>>>>> On 07/20/2018 02:34 PM, David Hildenbrand wrote:
>>>>>>> Dumping tools (like makedumpfile) right now don't exclude reserved pages.
>>>>>>> So reserved pages might be access by dump tools although nobody except
>>>>>>> the owner should touch them.
>>>>>>
>>>>>> Are you sure about that? Or maybe I understand wrong. Maybe it changed
>>>>>> recently, but IIRC pages that are backing memmap (struct pages) are also
>>>>>> PG_reserved. And you definitely do want those in the dump.
>>>>>
>>>>> You are right. reserve_bootmem_region will make all early bootmem
>>>>> allocations (including those backing memmaps) PageReserved. I have asked
>>>>> several times but I haven't seen a satisfactory answer yet. Why do we
>>>>> even care for kdump about those. If they are reserved the nobody should
>>>>> really look at those specific struct pages and manipulate them. Kdump
>>>>> tools are using a kernel interface to read the content. If the specific
>>>>> content is backed by a non-existing memory then they should simply not
>>>>> return anything.
>>>>>
>>>>
>>>> "new kernel" provides an interface to read memory from "old kernel".
>>>>
>>>> The new kernel has no idea about
>>>> - which memory was added/online in the old kernel
>>>> - where struct pages of the old kernel are and what their content is
>>>> - which memory is save to touch and which not
>>>>
>>>> Dump tools figure all that out by interpreting the VMCORE. They e.g.
>>>> identify "struct pages" and see if they should be dumped. The "new
>>>> kernel" only allows to read that memory. It cannot hinder to crash the
>>>> system (e.g. if a dump tool would try to read a hwpoison page).
>>>>
>>>> So how should the "new kernel" know if a page can be touched or not?
>>>
>>> I am sorry I am not familiar with kdump much. But from what I remember
>>> it reads from /proc/vmcore and implementation of this interface should
>>> simply return EINVAL or alike when you try to dump inaccessible memory
>>> range.
>>
>> Oh, and BTW, while something like -EINVAL could work, we usually don't
>> want to try to read certain pages at all (e.g. ballooned pages -
>> accessing the page might work but involves quite some overhead in the
>> hypervisor).
>>
>> So we should either handle this in dump tools (reserved + ...?) or while
>> doing the read similar to XEN (is_ram_page()).
> 
> Yes, I think this is the proper way. Just test for PageOnline
> in read_from_oldmem/copy_oldmem_page. Btw. we already page
> pfn_to_online_page which performs the per-section online/offline
> status. This should be extendable to consider your new PageOffline
> state.

That is the important bit:

What the new kernel sees is not what the old kernel saw.

Checking for pfn_to_online_page() from
read_from_oldmem/copy_oldmem_page() is plain wrong.

E.g. ACPI hotplug memory is not even added in the new kernel - see
"acpi_no_memhotplug" which is used in kdump environments.

The only thing we can do is
- query the hypervisor
- try to access and get an exception

-- 

Thanks,

David / dhildenb
