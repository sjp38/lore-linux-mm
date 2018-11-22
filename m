Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 911246B2A4C
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 02:48:03 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id k125so2032663pga.5
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 23:48:03 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id i4si16857698pfg.218.2018.11.21.23.48.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 23:48:02 -0800 (PST)
Subject: Re: [PATCH] mm/gup: finish consolidating error handling
References: <20181121081402.29641-1-jhubbard@nvidia.com>
 <20181121081402.29641-2-jhubbard@nvidia.com>
 <20181121144404.efdab6dbccd7780034a55e1d@linux-foundation.org>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <b6f9adb2-81d0-ae2e-e8b6-1769452a6c00@nvidia.com>
Date: Wed, 21 Nov 2018 23:48:00 -0800
MIME-Version: 1.0
In-Reply-To: <20181121144404.efdab6dbccd7780034a55e1d@linux-foundation.org>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, john.hubbard@gmail.com
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>

On 11/21/18 2:44 PM, Andrew Morton wrote:
> On Wed, 21 Nov 2018 00:14:02 -0800 john.hubbard@gmail.com wrote:
> 
>> Commit df06b37ffe5a4 ("mm/gup: cache dev_pagemap while pinning pages")
>> attempted to operate on each page that get_user_pages had retrieved. In
>> order to do that, it created a common exit point from the routine.
>> However, one case was missed, which this patch fixes up.
>>
>> Also, there was still an unnecessary shadow declaration (with a
>> different type) of the "ret" variable, which this patch removes.
>>
> 
> What is the bug which this supposedly fixes and what is that bug's
> user-visible impact?
> 

Keith's description of the situation is:

  This also fixes a potentially leaked dev_pagemap reference count if a
  failure occurs when an iteration crosses a vma boundary. I don't think
  it's normal to have different vma's on a users mapped zone device memory,
  but good to fix anyway.

I actually thought that this code:

    /* first iteration or cross vma bound */
    if (!vma || start >= vma->vm_end) {
        vma = find_extend_vma(mm, start);
        if (!vma && in_gate_area(mm, start)) {
            ret = get_gate_page(mm, start & PAGE_MASK,
                    gup_flags, &vma,
                    pages ? &pages[i] : NULL);
            if (ret)
                goto out;

...dealt with the "you're trying to pin the gate page, as part of this call",
rather than the generic case of crossing a vma boundary. (I think there's a fine
point that I must be overlooking.) But it's still a valid case, either way.

-- 
thanks,
John Hubbard
NVIDIA
