Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 413A58E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 13:09:17 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id y86so3444292ita.2
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 10:09:17 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id q3si2417292ith.113.2019.01.15.10.09.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 10:09:15 -0800 (PST)
Subject: Re: [RFC PATCH] mm: align anon mmap for THP
References: <20190111201003.19755-1-mike.kravetz@oracle.com>
 <20190111215506.jmp2s5end2vlzhvb@black.fi.intel.com>
 <ebd57b51-117b-4a3d-21d9-fc0287f437d6@oracle.com>
 <ad3a53ba-82e2-2dc7-1cd2-feef7def0bc3@oracle.com>
 <50c6abdc-b906-d16a-2f8f-8647b3d129aa@oracle.com>
 <20190115082450.stl6vlrgbvikbwzq@kshutemo-mobl1>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <9a1c07f8-68d0-835c-6461-bb64fef977bf@oracle.com>
Date: Tue, 15 Jan 2019 10:08:58 -0800
MIME-Version: 1.0
In-Reply-To: <20190115082450.stl6vlrgbvikbwzq@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Steven Sistare <steven.sistare@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux_lkml_grp@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Toshi Kani <toshi.kani@hpe.com>, Boaz Harrosh <boazh@netapp.com>, Andrew Morton <akpm@linux-foundation.org>

On 1/15/19 12:24 AM, Kirill A. Shutemov wrote:
> On Mon, Jan 14, 2019 at 10:54:45AM -0800, Mike Kravetz wrote:
>> On 1/14/19 7:35 AM, Steven Sistare wrote:
>>> On 1/11/2019 6:28 PM, Mike Kravetz wrote:
>>>> On 1/11/19 1:55 PM, Kirill A. Shutemov wrote:
>>>>> On Fri, Jan 11, 2019 at 08:10:03PM +0000, Mike Kravetz wrote:
>>>>>> At LPC last year, Boaz Harrosh asked why he had to 'jump through hoops'
>>>>>> to get an address returned by mmap() suitably aligned for THP.  It seems
>>>>>> that if mmap is asking for a mapping length greater than huge page
>>>>>> size, it should align the returned address to huge page size.
>>>
>>> A better heuristic would be to return an aligned address if the length
>>> is a multiple of the huge page size.  The gap (if any) between the end of
>>> the previous VMA and the start of this VMA would be filled by subsequent
>>> smaller mmap requests.  The new behavior would need to become part of the
>>> mmap interface definition so apps can rely on it and omit their hoop-jumping
>>> code.
>>
>> Yes, the heuristic really should be 'length is a multiple of the huge page
>> size'.  As you mention, this would still leave gaps.  I need to look closer
>> but this may not be any worse than the trick of mapping an area with rounded
>> up length and then unmapping pages at the beginning.
> 
> The question why is it any better. Virtual address space is generally
> cheap, additional VMA maybe more signficiant due to find_vma() overhead.
> 
> And you don't *need* to unmap anything. Just use alinged pointer.

You are correct, it is not any better.

I know you do not need to unmap anything.  However, I believe people are
writing code which does this today.  For example, qemu's qemu_ram_mmap()
utility routine does this, but it may have other reasons for creating
the gap.

Thanks for all of the feedback.  I do not think there is anything we can
or should do in this area.  As Steve said, 'power users' who want to get
optimal THP usage will write the code to make that happen.
-- 
Mike Kravetz
