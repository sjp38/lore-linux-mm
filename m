Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0C46B0006
	for <linux-mm@kvack.org>; Tue, 22 May 2018 15:58:24 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j14-v6so11681005pfn.11
        for <linux-mm@kvack.org>; Tue, 22 May 2018 12:58:24 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00120.outbound.protection.outlook.com. [40.107.0.120])
        by mx.google.com with ESMTPS id 89-v6si17499314plb.154.2018.05.22.12.58.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 May 2018 12:58:23 -0700 (PDT)
Subject: Re: [PATCH v6 17/17] mm: Distinguish VMalloc pages
References: <20180518194519.3820-1-willy@infradead.org>
 <20180518194519.3820-18-willy@infradead.org>
 <74e9bf39-ae17-cc00-8fca-c34b75675d49@virtuozzo.com>
 <20180522175836.GB1237@bombadil.infradead.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <e8d8fd85-89a2-8e4f-24bf-b930b705bc49@virtuozzo.com>
Date: Tue, 22 May 2018 22:57:34 +0300
MIME-Version: 1.0
In-Reply-To: <20180522175836.GB1237@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>



On 05/22/2018 08:58 PM, Matthew Wilcox wrote:
> On Tue, May 22, 2018 at 07:10:52PM +0300, Andrey Ryabinin wrote:
>> On 05/18/2018 10:45 PM, Matthew Wilcox wrote:
>>> From: Matthew Wilcox <mawilcox@microsoft.com>
>>>
>>> For diagnosing various performance and memory-leak problems, it is helpful
>>> to be able to distinguish pages which are in use as VMalloc pages.
>>> Unfortunately, we cannot use the page_type field in struct page, as
>>> this is in use for mapcount by some drivers which map vmalloced pages
>>> to userspace.
>>>
>>> Use a special page->mapping value to distinguish VMalloc pages from
>>> other kinds of pages.  Also record a pointer to the vm_struct and the
>>> offset within the area in struct page to help reconstruct exactly what
>>> this page is being used for.
>>
>> This seems useless. page->vm_area and page->vm_offset are never used.
>> There are no follow up patches which use this new information 'For diagnosing various performance and memory-leak problems',
>> and no explanation how is it can be used in current form.
> 
> Right now, it's by-hand.  tools/vm/page-types.c will tell you which pages
> are allocated to VMalloc.  Many people use kernel debuggers, crashdumps
> and similar to examine the kernel's memory.  Leaving these breadcrumbs
> is helpful, and those fields simply weren't in use before.
> 
>> Also, this patch breaks code like this:
>> 	if (mapping = page_mapping(page))
>> 		// access mapping
> 
> Example of broken code, please?  Pages allocated from the page allocator
> with alloc_page() come with page->mapping == NULL.  This code snippet
> would not have granted access to vmalloc pages before.
> 

Some implementation of the flush_dcache_page(), also set_page_dirty() can be called
on userspace-mapped vmalloc pages during unmap - zap_pte_range() -> set_page_dirty()
