Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2CD358E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 10:36:16 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id t133so20176113iof.20
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 07:36:16 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id v185si351704itv.93.2019.01.14.07.36.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jan 2019 07:36:14 -0800 (PST)
Subject: Re: [RFC PATCH] mm: align anon mmap for THP
References: <20190111201003.19755-1-mike.kravetz@oracle.com>
 <20190111215506.jmp2s5end2vlzhvb@black.fi.intel.com>
 <ebd57b51-117b-4a3d-21d9-fc0287f437d6@oracle.com>
From: Steven Sistare <steven.sistare@oracle.com>
Message-ID: <ad3a53ba-82e2-2dc7-1cd2-feef7def0bc3@oracle.com>
Date: Mon, 14 Jan 2019 10:35:46 -0500
MIME-Version: 1.0
In-Reply-To: <ebd57b51-117b-4a3d-21d9-fc0287f437d6@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux_lkml_grp@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Toshi Kani <toshi.kani@hpe.com>, Boaz Harrosh <boazh@netapp.com>, Andrew Morton <akpm@linux-foundation.org>

On 1/11/2019 6:28 PM, Mike Kravetz wrote:
> On 1/11/19 1:55 PM, Kirill A. Shutemov wrote:
>> On Fri, Jan 11, 2019 at 08:10:03PM +0000, Mike Kravetz wrote:
>>> At LPC last year, Boaz Harrosh asked why he had to 'jump through hoops'
>>> to get an address returned by mmap() suitably aligned for THP.  It seems
>>> that if mmap is asking for a mapping length greater than huge page
>>> size, it should align the returned address to huge page size.

A better heuristic would be to return an aligned address if the length
is a multiple of the huge page size.  The gap (if any) between the end of
the previous VMA and the start of this VMA would be filled by subsequent
smaller mmap requests.  The new behavior would need to become part of the
mmap interface definition so apps can rely on it and omit their hoop-jumping
code.

Personally I would like to see a new MAP_ALIGN flag and treat the addr
argument as the alignment (like Solaris), but I am told that adding flags
is problematic because old kernels accept undefined flag bits from userland
without complaint, so their behavior would change.

- Steve

>>> THP alignment has already been added for DAX, shm and tmpfs.  However,
>>> simple anon mappings does not take THP alignment into account.
>>
>> In general case, when no hint address provided, all anonymous memory
>> requests have tendency to clamp into a single bigger VMA and get you
>> better chance having THP, even if a single allocation is too small.
>> This patch will *reduce* the effect and I guess the net result will be
>> net negative.
> 
> Ah!  I forgot about combining like mappings into a single vma.  Increasing
> alignment could/would prevent this.
> 
>> The patch also effectively reduces bit available for ASLR and increases
>> address space fragmentation (increases number of VMA and therefore page
>> fault cost).
>>
>> I think any change in this direction has to be way more data driven.
> 
> Ok, I just wanted to ask the question.  I've seen application code doing
> the 'mmap sufficiently large area' then unmap to get desired alignment
> trick.  Was wondering if there was something we could do to help.
> 
> Thanks
> 
