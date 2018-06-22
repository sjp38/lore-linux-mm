Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2C47E6B000C
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 12:44:48 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id y7-v6so3937415plt.17
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 09:44:48 -0700 (PDT)
Received: from out4438.biz.mail.alibaba.com (out4438.biz.mail.alibaba.com. [47.88.44.38])
        by mx.google.com with ESMTPS id 97-v6si8311301pld.345.2018.06.22.09.44.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 09:44:46 -0700 (PDT)
Subject: Re: [v2 PATCH 1/2] mm: thp: register mm for khugepaged when merging
 vma for shmem
References: <1529622949-75504-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180622075958.mzagr2ayufiuokea@black.fi.intel.com>
 <cce4aa50-f8b7-8626-31ae-12464a30f884@linux.alibaba.com>
 <20180622161912.sq32cnhfxo5ctgdp@black.fi.intel.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <6e59a56d-7bb3-76d3-201a-8a4ad4638602@linux.alibaba.com>
Date: Fri, 22 Jun 2018 09:44:27 -0700
MIME-Version: 1.0
In-Reply-To: <20180622161912.sq32cnhfxo5ctgdp@black.fi.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: hughd@google.com, vbabka@suse.cz, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 6/22/18 9:19 AM, Kirill A. Shutemov wrote:
> On Fri, Jun 22, 2018 at 04:04:12PM +0000, yang.shi@linux.alibaba.com wrote:
>>
>> On 6/22/18 12:59 AM, Kirill A. Shutemov wrote:
>>> On Thu, Jun 21, 2018 at 11:15:48PM +0000, yang.shi@linux.alibaba.com wrote:
>>>> When merging anonymous page vma, if the size of vma can fit in at least
>>>> one hugepage, the mm will be registered for khugepaged for collapsing
>>>> THP in the future.
>>>>
>>>> But, it skips shmem vma. Doing so for shmem too, but not file-private
>>>> mapping, when merging vma in order to increase the odd to collapse
>>>> hugepage by khugepaged.
>>>>
>>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>>> Cc: Hugh Dickins <hughd@google.com>
>>>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>>> Cc: Vlastimil Babka <vbabka@suse.cz>
>>>> ---
>>>> v1 --> 2:
>>>> * Exclude file-private mapping per Kirill's comment
>>>>
>>>>    mm/khugepaged.c | 8 ++++++--
>>>>    1 file changed, 6 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
>>>> index d7b2a4b..9b0ec30 100644
>>>> --- a/mm/khugepaged.c
>>>> +++ b/mm/khugepaged.c
>>>> @@ -440,8 +440,12 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
>>>>    		 * page fault if needed.
>>>>    		 */
>>>>    		return 0;
>>>> -	if (vma->vm_ops || (vm_flags & VM_NO_KHUGEPAGED))
>>>> -		/* khugepaged not yet working on file or special mappings */
>>>> +	if ((vma->vm_ops && (!shmem_file(vma->vm_file) || vma->anon_vma)) ||
>>>> +	    (vm_flags & VM_NO_KHUGEPAGED))
>>>> +		/*
>>>> +		 * khugepaged not yet working on non-shmem file or special
>>>> +		 * mappings. And, file-private shmem THP is not supported.
>>>> +		 */
>>>>    		return 0;
>>> My point was that vma->anon_vma check above this one should not prevent
>>> collapse for shmem.
>>>
>>> Looking into this more, I think we should just replace all these checks
>>> with hugepage_vma_check() call.
>> I got a little bit confused here. I thought the condition to *not* collapse
>> file-private shmem mapping should be:
>>
>> shmem_file(vma->vm_file) && vma->anon_vma
>>
>> Is this right?
> No, if shmem_file(vma->vm_file) is true, vma->anon_vma doesn't matter.
> We don't care about anon_vma in such VMA as we don't touch file-private
> pages.

Thanks, I misunderstood that. hugepage_vma_check() sounds reasonable. 
Will fix in v3 soon.

Yang

>
