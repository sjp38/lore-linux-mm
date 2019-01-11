Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9059B8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 18:28:52 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id e14so3406177ybf.4
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 15:28:52 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id p124si14199438ywd.454.2019.01.11.15.28.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 15:28:51 -0800 (PST)
Subject: Re: [RFC PATCH] mm: align anon mmap for THP
References: <20190111201003.19755-1-mike.kravetz@oracle.com>
 <20190111215506.jmp2s5end2vlzhvb@black.fi.intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <ebd57b51-117b-4a3d-21d9-fc0287f437d6@oracle.com>
Date: Fri, 11 Jan 2019 15:28:37 -0800
MIME-Version: 1.0
In-Reply-To: <20190111215506.jmp2s5end2vlzhvb@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Toshi Kani <toshi.kani@hpe.com>, Boaz Harrosh <boazh@netapp.com>, Andrew Morton <akpm@linux-foundation.org>

On 1/11/19 1:55 PM, Kirill A. Shutemov wrote:
> On Fri, Jan 11, 2019 at 08:10:03PM +0000, Mike Kravetz wrote:
>> At LPC last year, Boaz Harrosh asked why he had to 'jump through hoops'
>> to get an address returned by mmap() suitably aligned for THP.  It seems
>> that if mmap is asking for a mapping length greater than huge page
>> size, it should align the returned address to huge page size.
>>
>> THP alignment has already been added for DAX, shm and tmpfs.  However,
>> simple anon mappings does not take THP alignment into account.
> 
> In general case, when no hint address provided, all anonymous memory
> requests have tendency to clamp into a single bigger VMA and get you
> better chance having THP, even if a single allocation is too small.
> This patch will *reduce* the effect and I guess the net result will be
> net negative.

Ah!  I forgot about combining like mappings into a single vma.  Increasing
alignment could/would prevent this.

> The patch also effectively reduces bit available for ASLR and increases
> address space fragmentation (increases number of VMA and therefore page
> fault cost).
> 
> I think any change in this direction has to be way more data driven.

Ok, I just wanted to ask the question.  I've seen application code doing
the 'mmap sufficiently large area' then unmap to get desired alignment
trick.  Was wondering if there was something we could do to help.

Thanks
-- 
Mike Kravetz
