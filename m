Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6436B0007
	for <linux-mm@kvack.org>; Wed, 23 May 2018 05:26:59 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u10-v6so6446805pgp.8
        for <linux-mm@kvack.org>; Wed, 23 May 2018 02:26:59 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0135.outbound.protection.outlook.com. [104.47.1.135])
        by mx.google.com with ESMTPS id h67-v6si18829020pfk.15.2018.05.23.02.26.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 23 May 2018 02:26:58 -0700 (PDT)
Subject: Re: [PATCH v6 17/17] mm: Distinguish VMalloc pages
References: <20180518194519.3820-1-willy@infradead.org>
 <20180518194519.3820-18-willy@infradead.org>
 <74e9bf39-ae17-cc00-8fca-c34b75675d49@virtuozzo.com>
 <20180522175836.GB1237@bombadil.infradead.org>
 <e8d8fd85-89a2-8e4f-24bf-b930b705bc49@virtuozzo.com>
 <20180523063439.GD20441@dhcp22.suse.cz>
 <e76d4238-9cfe-1f0f-0a52-cfaf476380a8@virtuozzo.com>
 <20180523092515.GL20441@dhcp22.suse.cz>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <c6501d68-2f53-7bfa-6065-785df0c63de2@virtuozzo.com>
Date: Wed, 23 May 2018 12:28:10 +0300
MIME-Version: 1.0
In-Reply-To: <20180523092515.GL20441@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>



On 05/23/2018 12:25 PM, Michal Hocko wrote:
> On Wed 23-05-18 12:14:10, Andrey Ryabinin wrote:
>>
>>
>> On 05/23/2018 09:34 AM, Michal Hocko wrote:
>>> On Tue 22-05-18 22:57:34, Andrey Ryabinin wrote:
>>>>
>>>>
>>>> On 05/22/2018 08:58 PM, Matthew Wilcox wrote:
>>>>> On Tue, May 22, 2018 at 07:10:52PM +0300, Andrey Ryabinin wrote:
>>>>>> On 05/18/2018 10:45 PM, Matthew Wilcox wrote:
>>>>>>> From: Matthew Wilcox <mawilcox@microsoft.com>
>>>>>>>
>>>>>>> For diagnosing various performance and memory-leak problems, it is helpful
>>>>>>> to be able to distinguish pages which are in use as VMalloc pages.
>>>>>>> Unfortunately, we cannot use the page_type field in struct page, as
>>>>>>> this is in use for mapcount by some drivers which map vmalloced pages
>>>>>>> to userspace.
>>>>>>>
>>>>>>> Use a special page->mapping value to distinguish VMalloc pages from
>>>>>>> other kinds of pages.  Also record a pointer to the vm_struct and the
>>>>>>> offset within the area in struct page to help reconstruct exactly what
>>>>>>> this page is being used for.
>>>>>>
>>>>>> This seems useless. page->vm_area and page->vm_offset are never used.
>>>>>> There are no follow up patches which use this new information 'For diagnosing various performance and memory-leak problems',
>>>>>> and no explanation how is it can be used in current form.
>>>>>
>>>>> Right now, it's by-hand.  tools/vm/page-types.c will tell you which pages
>>>>> are allocated to VMalloc.  Many people use kernel debuggers, crashdumps
>>>>> and similar to examine the kernel's memory.  Leaving these breadcrumbs
>>>>> is helpful, and those fields simply weren't in use before.
>>>>>
>>>>>> Also, this patch breaks code like this:
>>>>>> 	if (mapping = page_mapping(page))
>>>>>> 		// access mapping
>>>>>
>>>>> Example of broken code, please?  Pages allocated from the page allocator
>>>>> with alloc_page() come with page->mapping == NULL.  This code snippet
>>>>> would not have granted access to vmalloc pages before.
>>>>>
>>>>
>>>> Some implementation of the flush_dcache_page(), also set_page_dirty() can be called
>>>> on userspace-mapped vmalloc pages during unmap - zap_pte_range() -> set_page_dirty()
>>>
>>> Do you have any specific example?
>>
>> git grep -e remap_vmalloc_range -e vmalloc_user
>>
>> But that's not all, vmalloc*() + vmalloc_to_page() + vm_insert_page() are another candidates.
> 
> Thanks for the pointer. I was not aware of remap_vmalloc_range.
>>
>>> Why would anybody map vmalloc pages to the userspace?
>>
>> To have shared memory between usespace and the kernel.
> 
> OK, so the point seems to be to share large physically contiguous memory
> with userspace.
> 

Not physically, but virtually contiguous.
