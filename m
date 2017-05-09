Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 584F0831F4
	for <linux-mm@kvack.org>; Tue,  9 May 2017 06:02:17 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m13so91006522pgd.12
        for <linux-mm@kvack.org>; Tue, 09 May 2017 03:02:17 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id i123si15691047pfc.167.2017.05.09.03.02.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 03:02:16 -0700 (PDT)
Message-ID: <5911927A.6080708@huawei.com>
Date: Tue, 9 May 2017 17:57:14 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix the memory leak after collapsing the huge page
 fails
References: <1494317557-49680-1-git-send-email-zhongjiang@huawei.com> <7d5fd103-f997-e445-2ce6-2e44deed33d8@suse.cz>
In-Reply-To: <7d5fd103-f997-e445-2ce6-2e44deed33d8@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, hannes@cmpxchg.org, kirill.shutemov@linux.intel.com, linux-mm@kvack.org

On 2017/5/9 16:42, Vlastimil Babka wrote:
> On 05/09/2017 10:12 AM, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> Current, when we prepare a huge page to collapse, due to some
>> reasons, it can fail to collapse. At the moment, we should
>> release the preallocate huge page.
> Yeah, looks like the leak is there...
>
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  mm/khugepaged.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
>> index 7cb9c88..3f5749e 100644
>> --- a/mm/khugepaged.c
>> +++ b/mm/khugepaged.c
>> @@ -1080,6 +1080,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>>  	result = SCAN_SUCCEED;
>>  out_up_write:
>>  	up_write(&mm->mmap_sem);
>> +	put_page(new_page);
> This doesn't seem correct.
> - the put_page() will be called also on success, so a premature free?
> - the out_nolock: case should be also handled
> - collapse_shmem() seems to have the same problem
>
>>  out_nolock:
>>  	trace_mm_collapse_huge_page(mm, isolated, result);
>>  	return;
>>
>
> .
>
 >Subject: [PATCH v2] mm: fix the memory leak after collapsing the huge page
 fails

Current, when we prepare a huge page to collapse, due to some
reasons, it can fail to collapse. At the moment, we should
release the preallocate huge page.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/khugepaged.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 7cb9c88..586b1f1 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1082,6 +1082,8 @@ static void collapse_huge_page(struct mm_struct *mm,
        up_write(&mm->mmap_sem);
 out_nolock:
        trace_mm_collapse_huge_page(mm, isolated, result);
+       if (page != NULL && result != SCAN_SUCCEED)
+               put_page(new_page);
        return;
 out:
        mem_cgroup_cancel_charge(new_page, memcg, true);
@@ -1555,6 +1557,8 @@ static void collapse_shmem(struct mm_struct *mm,
        }
 out:
        VM_BUG_ON(!list_empty(&pagelist));
+       if (page != NULL && result != SCAN_SUCCEED)
+               put_page(new_page);
        /* TODO: tracepoints */
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
