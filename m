Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E89F2806D7
	for <linux-mm@kvack.org>; Tue,  9 May 2017 09:46:13 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y106so169136wrb.14
        for <linux-mm@kvack.org>; Tue, 09 May 2017 06:46:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l125si240606wmg.143.2017.05.09.06.46.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 06:46:12 -0700 (PDT)
Subject: Re: [PATCH v2] mm: fix the memory leak after collapsing the huge page
 fails
References: <1494327305-835-1-git-send-email-zhongjiang@huawei.com>
 <442638e9-d6db-2f1c-e260-9290d7524f1d@suse.cz> <5911B40D.2020007@huawei.com>
 <0bca4592-efa5-deba-0369-19beacfd2a63@suse.cz> <5911C4AC.2090402@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5c1ad068-1998-b384-c1e2-8cbbbf15506b@suse.cz>
Date: Tue, 9 May 2017 15:46:09 +0200
MIME-Version: 1.0
In-Reply-To: <5911C4AC.2090402@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, mgorman@techsingularity.net, linux-mm@kvack.org

On 05/09/2017 03:31 PM, zhong jiang wrote:
> On 2017/5/9 20:41, Vlastimil Babka wrote:
>> On 05/09/2017 02:20 PM, zhong jiang wrote:
>>> On 2017/5/9 19:34, Vlastimil Babka wrote:
>>>> On 05/09/2017 12:55 PM, zhongjiang wrote:
>>>>> From: zhong jiang <zhongjiang@huawei.com>
>>>>>
>>>>> Current, when we prepare a huge page to collapse, due to some
>>>>> reasons, it can fail to collapse. At the moment, we should
>>>>> release the preallocate huge page.
>>>>>
>>>>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>>>> Hmm, scratch that, there's no memory leak. The pointer to new_page is
>>>> stored in *hpage, and put_page() is called all the way up in
>>>> khugepaged_do_scan().
>>>  I see. I miss it. but why the new_page need to be release all the way.
>> AFAIK to support preallocation and reusal of preallocated page for
>> collapse attempt in different pmd. It only works for !NUMA so it's
>> likely not worth all the trouble and complicated code, so I wouldn't be
>> opposed to simplifying this.
>>
>>>  I do not see the count increment when scan success. it save the memory,
>>>  only when page fault happen.
>> I don't understand what you mean here?
>  I mean that whether collapse huge page success or nor, preallocate page will
>  alway be release.  by the above description. I seems to true.

Ah, no. In case of success, collapse_huge_page() does *hpage = NULL; so
the put_page() won't get to it anymore.

> 
>  Thanks
>  zhongjiang
>>>  Thanks
>>>  zhongjiang
>>>>> ---
>>>>>  mm/khugepaged.c | 4 ++++
>>>>>  1 file changed, 4 insertions(+)
>>>>>
>>>>> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
>>>>> index 7cb9c88..586b1f1 100644
>>>>> --- a/mm/khugepaged.c
>>>>> +++ b/mm/khugepaged.c
>>>>> @@ -1082,6 +1082,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>>>>>  	up_write(&mm->mmap_sem);
>>>>>  out_nolock:
>>>>>  	trace_mm_collapse_huge_page(mm, isolated, result);
>>>>> +	if (page != NULL && result != SCAN_SUCCEED)
>>>>> +		put_page(new_page);
>>>>>  	return;
>>>>>  out:
>>>>>  	mem_cgroup_cancel_charge(new_page, memcg, true);
>>>>> @@ -1555,6 +1557,8 @@ static void collapse_shmem(struct mm_struct *mm,
>>>>>  	}
>>>>>  out:
>>>>>  	VM_BUG_ON(!list_empty(&pagelist));
>>>>> +	if (page != NULL && result != SCAN_SUCCEED)
>>>>> +		put_page(new_page);
>>>>>  	/* TODO: tracepoints */
>>>>>  }
>>>>>  
>>>>>
>>>> .
>>>>
>>>
>>
>> .
>>
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
