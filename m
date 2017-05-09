Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8325A6B02F4
	for <linux-mm@kvack.org>; Tue,  9 May 2017 10:18:38 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b5so1241117pfe.0
        for <linux-mm@kvack.org>; Tue, 09 May 2017 07:18:38 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTP id z62si43046pgd.93.2017.05.09.07.11.06
        for <linux-mm@kvack.org>;
        Tue, 09 May 2017 07:18:37 -0700 (PDT)
Message-ID: <5911C9F9.3020802@huawei.com>
Date: Tue, 9 May 2017 21:54:01 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: fix the memory leak after collapsing the huge
 page fails
References: <1494327305-835-1-git-send-email-zhongjiang@huawei.com> <442638e9-d6db-2f1c-e260-9290d7524f1d@suse.cz> <5911B40D.2020007@huawei.com> <0bca4592-efa5-deba-0369-19beacfd2a63@suse.cz>
In-Reply-To: <0bca4592-efa5-deba-0369-19beacfd2a63@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, mgorman@techsingularity.net, linux-mm@kvack.org

Hi, Vlastimil

I review the code again. it works well for NUMA. because
khugepaged_prealloc_page will put_page when *hpage is true.

the memory leak will still exist in !NUMA. because it ingore
the put_page. is it right? I miss something.

Thanks
zhongjiang

On 2017/5/9 20:41, Vlastimil Babka wrote:
> On 05/09/2017 02:20 PM, zhong jiang wrote:
>> On 2017/5/9 19:34, Vlastimil Babka wrote:
>>> On 05/09/2017 12:55 PM, zhongjiang wrote:
>>>> From: zhong jiang <zhongjiang@huawei.com>
>>>>
>>>> Current, when we prepare a huge page to collapse, due to some
>>>> reasons, it can fail to collapse. At the moment, we should
>>>> release the preallocate huge page.
>>>>
>>>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>>> Hmm, scratch that, there's no memory leak. The pointer to new_page is
>>> stored in *hpage, and put_page() is called all the way up in
>>> khugepaged_do_scan().
>>  I see. I miss it. but why the new_page need to be release all the way.
> AFAIK to support preallocation and reusal of preallocated page for
> collapse attempt in different pmd. It only works for !NUMA so it's
> likely not worth all the trouble and complicated code, so I wouldn't be
> opposed to simplifying this.
>
>>  I do not see the count increment when scan success. it save the memory,
>>  only when page fault happen.
> I don't understand what you mean here?
>
>>  Thanks
>>  zhongjiang
>>>> ---
>>>>  mm/khugepaged.c | 4 ++++
>>>>  1 file changed, 4 insertions(+)
>>>>
>>>> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
>>>> index 7cb9c88..586b1f1 100644
>>>> --- a/mm/khugepaged.c
>>>> +++ b/mm/khugepaged.c
>>>> @@ -1082,6 +1082,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>>>>  	up_write(&mm->mmap_sem);
>>>>  out_nolock:
>>>>  	trace_mm_collapse_huge_page(mm, isolated, result);
>>>> +	if (page != NULL && result != SCAN_SUCCEED)
>>>> +		put_page(new_page);
>>>>  	return;
>>>>  out:
>>>>  	mem_cgroup_cancel_charge(new_page, memcg, true);
>>>> @@ -1555,6 +1557,8 @@ static void collapse_shmem(struct mm_struct *mm,
>>>>  	}
>>>>  out:
>>>>  	VM_BUG_ON(!list_empty(&pagelist));
>>>> +	if (page != NULL && result != SCAN_SUCCEED)
>>>> +		put_page(new_page);
>>>>  	/* TODO: tracepoints */
>>>>  }
>>>>  
>>>>
>>> .
>>>
>>
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
