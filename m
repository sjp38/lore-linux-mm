Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1383B6B0032
	for <linux-mm@kvack.org>; Sat, 18 Apr 2015 12:17:05 -0400 (EDT)
Received: by paboj16 with SMTP id oj16so158406713pab.0
        for <linux-mm@kvack.org>; Sat, 18 Apr 2015 09:17:04 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id p9si21182926pdi.204.2015.04.18.09.17.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 18 Apr 2015 09:17:03 -0700 (PDT)
Message-ID: <55328375.20407@oracle.com>
Date: Sat, 18 Apr 2015 09:16:53 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 4/4] mm: madvise allow remove operation for hugetlbfs
References: <00e601d078da$9e762190$db6264b0$@alibaba-inc.com> <00ef01d078dd$96bfc480$c43f4d80$@alibaba-inc.com> <55313ECD.3050604@oracle.com>
In-Reply-To: <55313ECD.3050604@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Dave Hansen' <dave.hansen@linux.intel.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

On 04/17/2015 10:11 AM, Mike Kravetz wrote:
> On 04/17/2015 12:10 AM, Hillf Danton wrote:
>>>
>>> Now that we have hole punching support for hugetlbfs, we can
>>> also support the MADV_REMOVE interface to it.
>>>
>>> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>>> ---
>>>   mm/madvise.c | 2 +-
>>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/mm/madvise.c b/mm/madvise.c
>>> index d551475..c4a1027 100644
>>> --- a/mm/madvise.c
>>> +++ b/mm/madvise.c
>>> @@ -299,7 +299,7 @@ static long madvise_remove(struct vm_area_struct
>>> *vma,
>>>
>>>       *prev = NULL;    /* tell sys_madvise we drop mmap_sem */
>>>
>>> -    if (vma->vm_flags & (VM_LOCKED | VM_HUGETLB))
>>> +    if (vma->vm_flags & VM_LOCKED)
>>>           return -EINVAL;
>>>
>>>       f = vma->vm_file;
>>> --
>>> 2.1.0
>>
>> After the above change offset is computed,
>>
>>     offset = (loff_t)(start - vma->vm_start)
>>         + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
>>
>> and I wonder if it is correct for huge page mapping.
>
> I think it will be correct.
>
> The above will be a (base) page size aligned offset into the file.
> This offset will be huge page aligned in the fallocate hole punch
> code.
>
>      /*
>       * For hole punch round up the beginning offset of the hole and
>       * round down the end.
>       */
>      hole_start = (offset + hpage_size - 1) & ~huge_page_mask(h);
>      hole_end = (offset + len - (hpage_size - 1)) * ~huge_page_mask(h);
>
> Was the alignment your concern, or something else?

Well, that alignment code in fallocate hole punch obviously wrong. :(
Sorry about that.  I'll send out an updated RFC with working hole punch.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
